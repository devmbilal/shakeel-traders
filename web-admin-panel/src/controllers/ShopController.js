'use strict';

const path = require('path');
const multer = require('multer');
const ExcelJS = require('exceljs');
const ShopModel = require('../models/ShopModel');
const RouteModel = require('../models/RouteModel');
const { renderWithLayout } = require('../utils/render');

// Multer for CSV import
const csvUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (file.mimetype === 'text/csv' || file.originalname.endsWith('.csv')) {
      cb(null, true);
    } else {
      cb(new Error('Only CSV files are allowed'));
    }
  },
});

function parseCSV(buffer) {
  const lines = buffer.toString('utf8').split('\n').map(l => l.trim()).filter(Boolean);
  if (lines.length < 2) return [];
  const headers = lines[0].split(',').map(h => h.trim().toLowerCase().replace(/\s+/g, '_'));
  return lines.slice(1).map(line => {
    const vals = line.split(',');
    const obj = {};
    headers.forEach((h, i) => { obj[h] = (vals[i] || '').trim(); });
    return obj;
  });
}

const ShopController = {
  csvUploadMiddleware: csvUpload.single('csv_file'),

  // GET /shops
  async index(req, res) {
    try {
      const { paginate } = require('../utils/paginate');
      const filters = {
        search:          req.query.search          || '',
        route_id:        req.query.route_id        || '',
        shop_type:       req.query.shop_type       || '',
        is_active:       req.query.is_active !== undefined ? req.query.is_active : '',
        has_outstanding: req.query.has_outstanding || '',
      };
      const page = parseInt(req.query.page) || 1;
      const total = await ShopModel.countAll(filters);
      const pagination = paginate(total, page);
      const [shops, routes] = await Promise.all([
        ShopModel.listAll(filters, { limit: pagination.limit, offset: pagination.offset }),
        RouteModel.listAll(),
      ]);
      const queryString = new URLSearchParams({ ...req.query, page: undefined }).toString();
      
      renderWithLayout(req, res, 'shops/index', {
        title: 'Shop Management',
        shops,
        routes,
        filters,
        pagination,
        queryString,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load shops.');
      res.redirect('/dashboard');
    }
  },

  // GET /shops/new
  async newForm(req, res) {
    try {
      const routes = await RouteModel.listAll();
      renderWithLayout(req, res, 'shops/detail', {
        title: 'Add Shop',
        shop: null,
        routes: routes.filter(r => r.is_active),
        isNew: true,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load form.');
      res.redirect('/shops');
    }
  },

  // POST /shops
  async create(req, res) {
    try {
      const rawDiscount = req.body.price_max_discount_pct;
      const parsedDiscount = parseFloat(rawDiscount);
      const data = {
        name:               req.body.name,
        owner_name:         req.body.owner_name,
        phone:              req.body.phone,
        address:            req.body.address,
        route_id:           req.body.route_id,
        shop_type:          req.body.shop_type || 'retail',
        price_edit_allowed: req.body.price_edit_allowed ? 1 : 0,
        price_max_discount_pct: isNaN(parsedDiscount) ? 0 : parsedDiscount,
      };
      const id = await ShopModel.create(data);
      req.flash('success', `Shop "${data.name}" created.`);
      res.redirect('/shops/' + id);
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to create shop: ' + err.message);
      res.redirect('/shops/new');
    }
  },

  // POST /shops/import
  async importCSV(req, res) {
    try {
      if (!req.file) {
        req.flash('error', 'Please upload a CSV file.');
        return res.redirect('/shops');
      }
      const rows = parseCSV(req.file.buffer);
      const result = await ShopModel.bulkImportFromCSV(rows);
      if (result.errors.length > 0) {
        req.flash('error', `Imported ${result.inserted} shops. Errors: ${result.errors.slice(0, 3).join('; ')}`);
      } else {
        req.flash('success', `Successfully imported ${result.inserted} shops.`);
      }
      res.redirect('/shops');
    } catch (err) {
      console.error(err);
      req.flash('error', 'CSV import failed: ' + err.message);
      res.redirect('/shops');
    }
  },

  // GET /shops/:id
  async detail(req, res) {
    try {
      const [shop, routes] = await Promise.all([
        ShopModel.findById(req.params.id),
        RouteModel.listAll(),
      ]);
      if (!shop) {
        req.flash('error', 'Shop not found.');
        return res.redirect('/shops');
      }
      renderWithLayout(req, res, 'shops/detail', {
        title: shop.name,
        shop,
        routes: routes.filter(r => r.is_active),
        isNew: false,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load shop.');
      res.redirect('/shops');
    }
  },

  // POST /shops/:id
  async update(req, res) {
    try {
      const rawDiscount = req.body.price_max_discount_pct;
      const parsedDiscount = parseFloat(rawDiscount);
      const data = {
        name:               req.body.name,
        owner_name:         req.body.owner_name,
        phone:              req.body.phone,
        address:            req.body.address,
        route_id:           req.body.route_id,
        shop_type:          req.body.shop_type || 'retail',
        price_edit_allowed: req.body.price_edit_allowed ? 1 : 0,
        price_max_discount_pct: isNaN(parsedDiscount) ? 0 : parsedDiscount,
      };
      await ShopModel.update(req.params.id, data);
      req.flash('success', 'Shop updated successfully.');
      res.redirect('/shops/' + req.params.id);
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to update shop: ' + err.message);
      res.redirect('/shops/' + req.params.id);
    }
  },

  // GET /shops/:id/ledger
  async ledger(req, res) {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      const offset = (page - 1) * limit;
      
      const [shop, ledgerData, balance] = await Promise.all([
        ShopModel.findById(req.params.id),
        ShopModel.getLedgerEntries(req.params.id, { limit, offset }),
        ShopModel.getCurrentBalance(req.params.id),
      ]);
      if (!shop) {
        req.flash('error', 'Shop not found.');
        return res.redirect('/shops');
      }
      const queryString = new URLSearchParams({ ...req.query, page: undefined }).toString();
      renderWithLayout(req, res, 'shops/ledger', {
        title: `${shop.name} — Ledger`,
        shop,
        entries: ledgerData.entries,
        balance: parseFloat(balance),
        pagination: { page, limit, total: ledgerData.total, pages: Math.ceil(ledgerData.total / limit) },
        queryString,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load ledger.');
      res.redirect('/shops/' + req.params.id);
    }
  },

  // POST /shops/:id/advance
  async addAdvance(req, res) {
    try {
      const { amount, advance_date, payment_method, note } = req.body;
      if (!amount || !advance_date || !payment_method) {
        req.flash('error', 'Amount, date, and payment method are required.');
        return res.redirect('/shops/' + req.params.id + '/ledger');
      }
      await ShopModel.addAdvance(req.params.id, { amount, advance_date, payment_method, note }, req.session.user.id);
      req.flash('success', 'Advance recorded successfully.');
      res.redirect('/shops/' + req.params.id + '/ledger');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to record advance: ' + err.message);
      res.redirect('/shops/' + req.params.id + '/ledger');
    }
  },

  // GET /shops/:id/ledger/export
  async exportLedger(req, res) {
    try {
      const [shop, ledgerData, balance] = await Promise.all([
        ShopModel.findById(req.params.id),
        ShopModel.getLedgerEntries(req.params.id),
        ShopModel.getCurrentBalance(req.params.id),
      ]);
      if (!shop) {
        req.flash('error', 'Shop not found.');
        return res.redirect('/shops');
      }

      const workbook = new ExcelJS.Workbook();
      const sheet = workbook.addWorksheet('Ledger');

      sheet.addRow([`Shop Ledger — ${shop.name}`]);
      sheet.addRow([`Route: ${shop.route_name}`, '', `Current Balance: ${parseFloat(balance).toFixed(2)}`]);
      sheet.addRow([]);
      sheet.addRow(['Date', 'Type', 'Description', 'Debit', 'Credit', 'Balance After']);

      ledgerData.entries.forEach(e => {
        sheet.addRow([
          e.entry_date,
          e.entry_type,
          e.note || '',
          parseFloat(e.debit).toFixed(2),
          parseFloat(e.credit).toFixed(2),
          parseFloat(e.balance_after).toFixed(2),
        ]);
      });

      res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      res.setHeader('Content-Disposition', `attachment; filename="ledger-${shop.id}.xlsx"`);
      await workbook.xlsx.write(res);
      res.end();
    } catch (err) {
      console.error(err);
      req.flash('error', 'Export failed: ' + err.message);
      res.redirect('/shops/' + req.params.id + '/ledger');
    }
  },
};

module.exports = ShopController;
