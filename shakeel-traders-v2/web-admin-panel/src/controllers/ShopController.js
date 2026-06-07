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
        RouteModel.listAll({ limit: 999999, offset: 0 }),
      ]);
      
      // Create queryString without page parameter
      const params = { ...req.query };
      delete params.page;
      const queryString = new URLSearchParams(params).toString();
      
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
      const routes = await RouteModel.listAll({ limit: 999999, offset: 0 });
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

  // POST /shops/import - Parse and preview CSV
  async importCSV(req, res) {
    try {
      if (!req.file) {
        req.flash('error', 'Please upload a CSV file.');
        return res.redirect('/shops');
      }
      const rows = parseCSV(req.file.buffer);
      const routeFilter = req.body.route_filter || '';
      
      // If route filter is provided, only process rows matching that route_id
      const filteredRows = routeFilter 
        ? rows.filter(row => String(row.route_id).trim() === String(routeFilter).trim())
        : rows;
      
      if (filteredRows.length === 0) {
        req.flash('error', routeFilter 
          ? `No shops found in CSV for route ID ${routeFilter}.`
          : 'CSV file has no valid shop data.');
        return res.redirect('/shops');
      }
      
      // Store parsed data in session for preview
      req.session.csvPreviewData = {
        shops: filteredRows,
        routeFilter: routeFilter,
        timestamp: Date.now()
      };
      
      // Redirect to preview page
      res.redirect('/shops/import/preview');
    } catch (err) {
      console.error(err);
      req.flash('error', 'CSV import failed: ' + err.message);
      res.redirect('/shops');
    }
  },

  // GET /shops/import/preview - Show CSV preview for review
  async importPreview(req, res) {
    try {
      if (!req.session.csvPreviewData) {
        req.flash('error', 'No CSV data to preview. Please upload a file first.');
        return res.redirect('/shops');
      }
      
      const { shops, routeFilter } = req.session.csvPreviewData;
      const routes = await RouteModel.listAll({ limit: 999999, offset: 0 });
      
      renderWithLayout(req, res, 'shops/import-preview', {
        title: 'Review CSV Import',
        shops,
        routes,
        routeFilter
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load preview.');
      res.redirect('/shops');
    }
  },

  // POST /shops/import/confirm - Confirm and import shops
  async importConfirm(req, res) {
    try {
      if (!req.session.csvPreviewData) {
        req.flash('error', 'No CSV data to import. Please upload a file first.');
        return res.redirect('/shops');
      }
      
      // Get the edited data from the form
      const names = [].concat(req.body.name || []);
      const ownerNames = [].concat(req.body.owner_name || []);
      const phones = [].concat(req.body.phone || []);
      const addresses = [].concat(req.body.address || []);
      const routeIds = [].concat(req.body.route_id || []);
      const shopTypes = [].concat(req.body.shop_type || []);
      const keepFlags = [].concat(req.body.keep || []);
      
      // Build the final rows to import (only rows that are marked to keep)
      const rowsToImport = [];
      for (let i = 0; i < names.length; i++) {
        if (keepFlags.includes(String(i))) {
          rowsToImport.push({
            name: names[i],
            owner_name: ownerNames[i],
            phone: phones[i],
            address: addresses[i],
            route_id: routeIds[i],
            shop_type: shopTypes[i] || 'retail'
          });
        }
      }
      
      if (rowsToImport.length === 0) {
        req.flash('error', 'No shops selected for import.');
        return res.redirect('/shops/import/preview');
      }
      
      const result = await ShopModel.bulkImportFromCSV(rowsToImport);
      
      // Clear session data
      delete req.session.csvPreviewData;
      
      const routeMsg = req.session.csvPreviewData?.routeFilter ? ` for route ID ${req.session.csvPreviewData.routeFilter}` : '';
      if (result.errors.length > 0) {
        req.flash('error', `Imported ${result.inserted} shops${routeMsg}. Errors: ${result.errors.slice(0, 3).join('; ')}`);
      } else {
        req.flash('success', `Successfully imported ${result.inserted} shops${routeMsg}.`);
      }
      res.redirect('/shops');
    } catch (err) {
      console.error(err);
      req.flash('error', 'CSV import failed: ' + err.message);
      res.redirect('/shops');
    }
  },

  // POST /shops/import/cancel - Cancel CSV import
  async importCancel(req, res) {
    delete req.session.csvPreviewData;
    req.flash('info', 'CSV import cancelled.');
    res.redirect('/shops');
  },

  // GET /shops/:id
  async detail(req, res) {
    try {
      const [shop, routes] = await Promise.all([
        ShopModel.findById(req.params.id),
        RouteModel.listAll({ limit: 999999, offset: 0 }),
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
        route_id:           req.body.route_id || null,
        shop_type:          req.body.shop_type || 'retail',
        price_edit_allowed: req.body.price_edit_allowed ? 1 : 0,
        price_max_discount_pct: isNaN(parsedDiscount) ? 0 : parsedDiscount,
        is_active:          req.body.is_active ? 1 : 0,
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
      
      // Create queryString without page parameter
      const params = { ...req.query };
      delete params.page;
      const queryString = new URLSearchParams(params).toString();
      
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

  // GET /shops/:id/add-opening-balance
  async addOpeningBalanceForm(req, res) {
    try {
      const shop = await ShopModel.findById(req.params.id);
      if (!shop) {
        req.flash('error', 'Shop not found.');
        return res.redirect('/shops');
      }
      renderWithLayout(req, res, 'shops/add-opening-balance', { 
        title: `Add Opening Balance — ${shop.name}`, 
        shop 
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load form.');
      res.redirect('/shops');
    }
  },

  // POST /shops/:id/add-opening-balance
  async addOpeningBalanceSubmit(req, res) {
    const { getConnection } = require('../config/db');
    const AuditModel = require('../models/AuditModel');
    const conn = await getConnection();
    try {
      await conn.beginTransaction();
      
      const shop = await ShopModel.findById(req.params.id);
      if (!shop) {
        req.flash('error', 'Shop not found.');
        return res.redirect('/shops');
      }

      const { 
        bill_date, 
        gross_amount, 
        amount_paid, 
        note 
      } = req.body;

      const grossAmt = parseFloat(gross_amount) || 0;
      const paidAmt = parseFloat(amount_paid) || 0;
      
      if (grossAmt <= 0) {
        req.flash('error', 'Gross amount must be greater than 0.');
        return res.redirect(`/shops/${req.params.id}/add-opening-balance`);
      }

      if (paidAmt < 0 || paidAmt > grossAmt) {
        req.flash('error', 'Amount paid must be between 0 and gross amount.');
        return res.redirect(`/shops/${req.params.id}/add-opening-balance`);
      }

      const outstandingAmt = grossAmt - paidAmt;
      
      // Determine bill status
      let status = 'open';
      if (paidAmt >= grossAmt) {
        status = 'cleared';
      } else if (paidAmt > 0) {
        status = 'partially_paid';
      }

      // Generate bill number for opening balance
      const billNumber = `OPENING-${shop.id}-${Date.now()}`;

      // Insert bill
      const [billResult] = await conn.query(
        `INSERT INTO bills 
          (order_id, shop_id, bill_type, bill_date, bill_number, gross_amount, advance_deducted, 
           net_amount, amount_paid, outstanding_amount, status, created_by)
         VALUES (NULL, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?)`,
        [shop.id, 'direct_shop', bill_date, billNumber, grossAmt, grossAmt, paidAmt, outstandingAmt, status, req.session.user.id]
      );

      const billId = billResult.insertId;

      // Get current shop balance
      const [[currentBalance]] = await conn.query(
        `SELECT balance_after FROM shop_ledger_entries 
         WHERE shop_id = ? ORDER BY id DESC LIMIT 1`,
        [shop.id]
      );
      const prevBalance = currentBalance ? parseFloat(currentBalance.balance_after) : 0;

      // Add ledger entry for the bill (debit)
      const balanceAfterBill = prevBalance + grossAmt;
      await conn.query(
        `INSERT INTO shop_ledger_entries 
          (shop_id, entry_type, reference_id, reference_type, debit, credit, balance_after, note, entry_date)
         VALUES (?, 'bill', ?, 'bills', ?, 0, ?, ?, ?)`,
        [shop.id, billId, grossAmt, balanceAfterBill, note || 'Opening balance bill', bill_date]
      );

      // If amount was paid, add recovery entry (credit)
      if (paidAmt > 0) {
        const balanceAfterPayment = balanceAfterBill - paidAmt;
        await conn.query(
          `INSERT INTO shop_ledger_entries 
            (shop_id, entry_type, reference_id, reference_type, debit, credit, balance_after, note, entry_date)
           VALUES (?, 'recovery', ?, 'bills', 0, ?, ?, ?, ?)`,
          [shop.id, billId, paidAmt, balanceAfterPayment, 'Opening balance payment', bill_date]
        );
      }

      // Insert audit log
      await AuditModel.insertLog({
        userId: req.session.user.id,
        action: 'ADD_OPENING_BALANCE',
        entityType: 'bills',
        entityId: billId
      }, conn);

      await conn.commit();
      req.flash('success', `Opening balance added: Rs ${grossAmt.toFixed(2)}, Outstanding: Rs ${outstandingAmt.toFixed(2)}`);
      res.redirect(`/shops/${shop.id}/ledger`);
    } catch (err) {
      await conn.rollback();
      console.error(err);
      req.flash('error', 'Failed to add opening balance: ' + err.message);
      res.redirect(`/shops/${req.params.id}/add-opening-balance`);
    } finally {
      conn.release();
    }
  },

  // POST /shops/:id/quick-price-edit (AJAX)
  async quickPriceEdit(req, res) {
    try {
      const { price_edit_allowed, price_max_discount_pct } = req.body;
      
      // Validate inputs
      const allowed = price_edit_allowed ? 1 : 0;
      const discount = parseFloat(price_max_discount_pct) || 0;
      
      if (discount < 0 || discount > 100) {
        return res.json({ success: false, message: 'Discount must be between 0 and 100%.' });
      }
      
      // Update only price-related fields using dedicated method
      const data = {
        price_edit_allowed: allowed,
        price_max_discount_pct: discount,
      };
      
      await ShopModel.updatePriceSettings(req.params.id, data);
      
      res.json({ 
        success: true, 
        message: `Price settings updated: ${allowed ? 'Allowed' : 'Disallowed'} (${discount}% discount)` 
      });
    } catch (err) {
      console.error(err);
      res.json({ success: false, message: 'Failed to update: ' + err.message });
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

  // GET /shops/export/csv
  async exportCSV(req, res) {
    try {
      const filters = {
        search:          req.query.search          || '',
        route_id:        req.query.route_id        || '',
        shop_type:       req.query.shop_type       || '',
        is_active:       req.query.is_active !== undefined ? req.query.is_active : '',
        has_outstanding: req.query.has_outstanding || '',
      };
      
      // Get all shops matching filters (no pagination)
      const shops = await ShopModel.listAll(filters, { limit: 999999, offset: 0 });
      
      if (shops.length === 0) {
        req.flash('error', 'No shops found to export.');
        return res.redirect('/shops');
      }
      
      // Build CSV content
      const headers = ['name', 'owner_name', 'phone', 'address', 'route_id', 'route_name', 'shop_type', 'is_active', 'price_edit_allowed', 'price_max_discount_pct'];
      let csv = headers.join(',') + '\n';
      
      shops.forEach(shop => {
        const row = [
          `"${(shop.name || '').replace(/"/g, '""')}"`,
          `"${(shop.owner_name || '').replace(/"/g, '""')}"`,
          `"${(shop.phone || '').replace(/"/g, '""')}"`,
          `"${(shop.address || '').replace(/"/g, '""')}"`,
          shop.route_id || '',
          `"${(shop.route_name || '').replace(/"/g, '""')}"`,
          shop.shop_type || 'retail',
          shop.is_active ? '1' : '0',
          shop.price_edit_allowed ? '1' : '0',
          shop.price_max_discount_pct || '0',
        ];
        csv += row.join(',') + '\n';
      });
      
      // Set response headers
      const filename = filters.route_id 
        ? `shops-route-${filters.route_id}-${Date.now()}.csv`
        : `shops-all-${Date.now()}.csv`;
      
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
      res.send(csv);
    } catch (err) {
      console.error(err);
      req.flash('error', 'Export failed: ' + err.message);
      res.redirect('/shops');
    }
  },
};

module.exports = ShopController;
