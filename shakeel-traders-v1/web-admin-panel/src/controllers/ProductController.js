'use strict';

const multer = require('multer');
const ProductModel = require('../models/ProductModel');
const { renderWithLayout } = require('../utils/render');

// ── CSV helpers ────────────────────────────────────────────────────────────
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
    const vals = line.split(',').map(v => v.trim());
    const obj = {};
    headers.forEach((h, i) => { obj[h] = vals[i] || ''; });
    return obj;
  });
}

const ProductController = {
  csvUploadMiddleware: csvUpload.single('csv_file'),

  async importCSV(req, res) {
    try {
      if (!req.file) {
        req.flash('error', 'Please upload a CSV file.');
        return res.redirect('/products');
      }
      const rows = parseCSV(req.file.buffer);
      if (rows.length === 0) {
        req.flash('error', 'CSV file is empty or has no data rows.');
        return res.redirect('/products');
      }
      const result = await ProductModel.bulkImportFromCSV(rows);
      const msg = `Imported: ${result.inserted} new, ${result.updated} updated.`;
      if (result.errors.length > 0) {
        req.flash('error', msg + ' Errors: ' + result.errors.slice(0, 3).join('; '));
      } else {
        req.flash('success', msg);
      }
      res.redirect('/products');
    } catch (err) {
      console.error(err);
      req.flash('error', 'CSV import failed: ' + err.message);
      res.redirect('/products');
    }
  },

  async index(req, res) {
    try {
      const { paginate } = require('../utils/paginate');
      const filter = req.query.filter || '';
      const page = parseInt(req.query.page) || 1;
      const total = await ProductModel.countAll(filter);
      const pagination = paginate(total, page);
      const products = await ProductModel.listAll(filter, { limit: pagination.limit, offset: pagination.offset });
      const queryString = new URLSearchParams({ ...req.query, page: undefined }).toString();
      
      renderWithLayout(req, res, 'products/index', { 
        title: 'Product Management', 
        products, 
        filter,
        pagination,
        queryString,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load products.');
      res.redirect('/dashboard');
    }
  },

  newForm(req, res) {
    renderWithLayout(req, res, 'products/form', { title: 'Add Product', product: null, isEdit: false });
  },

  async create(req, res) {
    try {
      const { sku_code, name, brand, units_per_carton, retail_price, wholesale_price, low_stock_threshold } = req.body;
      // Check duplicate SKU
      const existing = await ProductModel.findBySku(sku_code);
      if (existing) {
        req.flash('error', `SKU "${sku_code}" already exists. SKU codes must be unique.`);
        return res.redirect('/products/new');
      }
      await ProductModel.create({ sku_code, name, brand, units_per_carton, retail_price, wholesale_price, low_stock_threshold });
      req.flash('success', `Product "${name}" created.`);
      res.redirect('/products');
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        req.flash('error', 'SKU code already exists.');
      } else {
        req.flash('error', 'Failed to create product: ' + err.message);
      }
      res.redirect('/products/new');
    }
  },

  async editForm(req, res) {
    try {
      const product = await ProductModel.findById(req.params.id);
      if (!product) { req.flash('error', 'Product not found.'); return res.redirect('/products'); }
      renderWithLayout(req, res, 'products/form', { title: 'Edit Product', product, isEdit: true });
    } catch (err) {
      req.flash('error', 'Failed to load product.'); res.redirect('/products');
    }
  },

  async update(req, res) {
    try {
      const { sku_code, name, brand, units_per_carton, retail_price, wholesale_price, low_stock_threshold } = req.body;
      // Check duplicate SKU (excluding self)
      const existing = await ProductModel.findBySku(sku_code);
      if (existing && existing.id != req.params.id) {
        req.flash('error', `SKU "${sku_code}" already exists on another product.`);
        return res.redirect('/products/' + req.params.id + '/edit');
      }
      await ProductModel.update(req.params.id, { sku_code, name, brand, units_per_carton, retail_price, wholesale_price, low_stock_threshold });
      req.flash('success', 'Product updated.');
      res.redirect('/products');
    } catch (err) {
      req.flash('error', 'Failed to update: ' + err.message);
      res.redirect('/products/' + req.params.id + '/edit');
    }
  },

  async deactivate(req, res) {
    try {
      const p = await ProductModel.findById(req.params.id);
      if (!p) { req.flash('error', 'Product not found.'); return res.redirect('/products'); }
      await ProductModel.deactivate(req.params.id);
      req.flash('success', `Product "${p.name}" deactivated.`);
      res.redirect('/products');
    } catch (err) {
      req.flash('error', 'Failed to deactivate.'); res.redirect('/products');
    }
  },

  async activate(req, res) {
    try {
      await ProductModel.activate(req.params.id);
      req.flash('success', 'Product reactivated.');
      res.redirect('/products');
    } catch (err) {
      req.flash('error', 'Failed to activate.'); res.redirect('/products');
    }
  },

  async movements(req, res) {
    try {
      const [product, movements] = await Promise.all([
        ProductModel.findById(req.params.id),
        ProductModel.getStockMovements(req.params.id),
      ]);
      if (!product) { req.flash('error', 'Product not found.'); return res.redirect('/products'); }
      renderWithLayout(req, res, 'products/movements', { title: `${product.name} — Stock History`, product, movements });
    } catch (err) {
      req.flash('error', 'Failed to load movements.'); res.redirect('/products');
    }
  },
};

module.exports = ProductController;
