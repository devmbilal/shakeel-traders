'use strict';

const { getConnection } = require('../config/db');
const ProductModel  = require('../models/ProductModel');
const SupplierModel = require('../models/SupplierModel');
const IssuanceModel = require('../models/IssuanceModel');
const ReturnModel   = require('../models/ReturnModel');
const StockService  = require('../services/StockService');
const AuditModel    = require('../models/AuditModel');
const UserModel     = require('../models/UserModel');
const { renderWithLayout } = require('../utils/render');

const StockController = {

  // GET /stock — Stock Overview
  async overview(req, res) {
    try {
      const products = await ProductModel.listAll('active');
      renderWithLayout(req, res, 'stock/overview', { title: 'Stock Management', products });
    } catch (err) {
      console.error('Stock overview error:', err);
      req.flash('error', 'Failed to load stock: ' + err.message);
      res.redirect('/dashboard');
    }
  },

  // GET /stock/:productId/movements
  async movements(req, res) {
    try {
      const [product, movements] = await Promise.all([
        ProductModel.findById(req.params.productId),
        ProductModel.getStockMovements(req.params.productId),
      ]);
      if (!product) { req.flash('error', 'Product not found.'); return res.redirect('/stock'); }
      renderWithLayout(req, res, 'stock/movements', { title: `${product.name} — Movements`, product, movements });
    } catch (err) {
      req.flash('error', 'Failed to load movements.'); res.redirect('/stock');
    }
  },

  // GET /stock/manual-add
  async manualAddForm(req, res) {
    try {
      const products = await ProductModel.listAll('active');
      renderWithLayout(req, res, 'stock/manual-add', { title: 'Add Stock (Manual)', products });
    } catch (err) {
      req.flash('error', 'Failed to load form.'); res.redirect('/stock');
    }
  },

  // POST /stock/manual-add
  async manualAdd(req, res) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();
      const { product_id, cartons, loose_units, note } = req.body;
      await StockService.addStock(
        product_id, parseInt(cartons) || 0, parseInt(loose_units) || 0,
        'manual_add', null, null, note, req.session.user.id, conn
      );
      await AuditModel.insertLog({ userId: req.session.user.id, action: 'MANUAL_STOCK_ADD', entityType: 'products', entityId: product_id }, conn);
      await conn.commit();
      req.flash('success', 'Stock added successfully.');
      res.redirect('/stock');
    } catch (err) {
      await conn.rollback();
      req.flash('error', 'Failed to add stock: ' + err.message); res.redirect('/stock/manual-add');
    } finally { conn.release(); }
  },

  // GET /stock/add-from-supplier
  async fromSupplierForm(req, res) {
    try {
      const [suppliers, products] = await Promise.all([
        SupplierModel.listAll(),
        ProductModel.listAll('active'),
      ]);
      renderWithLayout(req, res, 'stock/from-supplier', { title: 'Add Stock from Supplier', suppliers, products });
    } catch (err) {
      req.flash('error', 'Failed to load form.'); res.redirect('/stock');
    }
  },

  // POST /stock/add-from-supplier
  async fromSupplierSubmit(req, res) {
    try {
      const { company_id, receipt_date, note } = req.body;
      const product_ids   = [].concat(req.body.product_id   || []);
      const cartons_arr   = [].concat(req.body.cartons       || []);
      const loose_arr     = [].concat(req.body.loose_units   || []);
      const price_arr     = [].concat(req.body.unit_price    || []);

      const items = product_ids.map((pid, i) => ({
        product_id:   pid,
        cartons:      parseInt(cartons_arr[i]) || 0,
        loose_units:  parseInt(loose_arr[i])   || 0,
        unit_price:   parseFloat(price_arr[i]) || 0,
        receipt_date,
        note,
      })).filter(item => item.cartons > 0 || item.loose_units > 0);

      if (!items.length) {
        req.flash('error', 'Please enter quantities for at least one product.');
        return res.redirect('/stock/add-from-supplier');
      }

      await SupplierModel.recordStockReceipt(company_id, items, req.session.user.id);
      req.flash('success', 'Stock receipt recorded and warehouse updated.');
      res.redirect('/stock');
    } catch (err) {
      req.flash('error', 'Failed to record receipt: ' + err.message);
      res.redirect('/stock/add-from-supplier');
    }
  },

  // GET /stock/pending-issuances
  async pendingIssuances(req, res) {
    try {
      const issuances = await IssuanceModel.listPending();
      renderWithLayout(req, res, 'stock/pending-issuances', { title: 'Pending Issuance Requests', issuances });
    } catch (err) {
      req.flash('error', 'Failed to load issuances.'); res.redirect('/stock');
    }
  },

  // POST /stock/issuances/:id/approve
  async approveIssuance(req, res) {
    try {
      await IssuanceModel.approve(req.params.id, req.session.user.id);
      req.flash('success', 'Issuance approved. Warehouse stock deducted.');
      res.redirect('/stock/pending-issuances');
    } catch (err) {
      req.flash('error', err.message); res.redirect('/stock/pending-issuances');
    }
  },

  // GET /stock/pending-returns
  async pendingReturns(req, res) {
    try {
      const returns = await ReturnModel.listPending();
      renderWithLayout(req, res, 'stock/pending-returns', { title: 'Pending Return Requests', returns });
    } catch (err) {
      req.flash('error', 'Failed to load returns.'); res.redirect('/stock');
    }
  },

  // GET /stock/returns/:id — view single return detail
  async returnDetail(req, res) {
    try {
      const ret = await ReturnModel.findById(req.params.id);
      if (!ret) { req.flash('error', 'Return not found.'); return res.redirect('/stock/pending-returns'); }
      renderWithLayout(req, res, 'stock/return-detail', { title: 'Return Detail', ret });
    } catch (err) {
      req.flash('error', 'Failed to load return.'); res.redirect('/stock/pending-returns');
    }
  },

  // POST /stock/returns/:id/approve
  async approveReturn(req, res) {
    try {
      const { final_sale_value } = req.body;
      await ReturnModel.approve(req.params.id, req.session.user.id, final_sale_value);
      req.flash('success', 'Return approved. Stock added back. Sale value posted to Centralized Cash.');
      res.redirect('/stock/pending-returns');
    } catch (err) {
      req.flash('error', err.message); res.redirect('/stock/pending-returns');
    }
  },

  // GET /stock/requirement-report
  async requirementReport(req, res) {
    try {
      const { query } = require('../config/db');
      const bookers = await UserModel.listByRole('order_booker');
      let report = [];
      const selectedBookerId = req.query.booker_id || '';

      if (selectedBookerId) {
        report = await query(
          `SELECT p.sku_code, p.name, p.units_per_carton,
                  SUM(oi.final_cartons) AS total_cartons,
                  SUM(oi.final_loose)   AS total_loose
           FROM order_items oi
           JOIN orders o ON o.id = oi.order_id
           JOIN products p ON p.id = oi.product_id
           WHERE o.order_booker_id = ? AND o.status = 'pending'
           GROUP BY p.id
           ORDER BY p.name ASC`,
          [selectedBookerId]
        );
      }

      renderWithLayout(req, res, 'stock/requirement-report', {
        title: 'Stock Requirement Report',
        bookers: bookers.filter(b => b.is_active),
        report,
        selectedBookerId,
      });
    } catch (err) {
      req.flash('error', 'Failed to load report.'); res.redirect('/stock');
    }
  },
};

module.exports = StockController;
