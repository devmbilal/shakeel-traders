'use strict';

const { getConnection, query } = require('../config/db');
const ShopModel    = require('../models/ShopModel');
const ProductModel = require('../models/ProductModel');
const StockService = require('../services/StockService');
const BillService  = require('../services/BillService');
const AuditModel   = require('../models/AuditModel');
const OrderModel   = require('../models/OrderModel');
const { formatBillForPrint } = require('../utils/printFormatter');
const { renderWithLayout } = require('../utils/render');

const DirectSalesController = {

  // GET /direct-sales/new
  async newForm(req, res) {
    try {
      const [shops, products] = await Promise.all([
        ShopModel.listAll({ is_active: '1' }),
        ProductModel.listAll('active'),
      ]);
      renderWithLayout(req, res, 'direct-sales/new', { title: 'New Direct Sale', shops, products });
    } catch (err) {
      req.flash('error', 'Failed to load form.'); res.redirect('/direct-sales');
    }
  },

  // POST /direct-sales
  async create(req, res) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();

      const { shop_id } = req.body;
      const product_ids  = [].concat(req.body.product_id  || []);
      const cartons_arr  = [].concat(req.body.cartons      || []);
      const loose_arr    = [].concat(req.body.loose_units  || []);
      const price_arr    = [].concat(req.body.unit_price   || []);

      const items = [];
      for (let i = 0; i < product_ids.length; i++) {
        const cartons = parseInt(cartons_arr[i]) || 0;
        const loose   = parseInt(loose_arr[i])   || 0;
        if (cartons === 0 && loose === 0) continue;

        const [[product]] = await conn.query(
          'SELECT id, units_per_carton, retail_price FROM products WHERE id = ?', [product_ids[i]]
        );
        if (!product) continue;

        // Deduct stock immediately
        const { stockAfterCartons, stockAfterLoose } = await StockService.deductStock(
          product_ids[i], cartons, loose, conn
        );
        await StockService.recordDeductionMovement(
          product_ids[i], cartons, loose,
          'direct_sale_deduction', null, null, null, req.session.user.id,
          stockAfterCartons, stockAfterLoose, conn
        );

        items.push({
          product_id:       product_ids[i],
          cartons,
          loose_units:      loose,
          unit_price:       parseFloat(price_arr[i]) || product.retail_price,
          units_per_carton: product.units_per_carton,
        });
      }

      if (!items.length) {
        await conn.rollback();
        req.flash('error', 'Please add at least one product with quantity.');
        return res.redirect('/direct-sales/new');
      }

      const { billId, billNumber } = await BillService.createBill(
        shop_id, 'direct_shop', items, req.session.user.id, conn
      );

      await AuditModel.insertLog({
        userId: req.session.user.id, action: 'CREATE_DIRECT_SALE',
        entityType: 'bills', entityId: billId, newValue: { billNumber }
      }, conn);

      await conn.commit();
      req.flash('success', `Direct sale bill ${billNumber} created.`);
      res.redirect('/direct-sales');
    } catch (err) {
      await conn.rollback();
      req.flash('error', err.message); res.redirect('/direct-sales/new');
    } finally { conn.release(); }
  },

  // GET /direct-sales
  async index(req, res) {
    try {
      const filters = { date: req.query.date || '', shop_id: req.query.shop_id || '' };
      const conditions = ['b.bill_type = \'direct_shop\''];
      const params = [];
      if (filters.date)    { conditions.push('b.bill_date = ?'); params.push(filters.date); }
      if (filters.shop_id) { conditions.push('b.shop_id = ?');   params.push(filters.shop_id); }

      const bills = await query(
        `SELECT b.*, s.name AS shop_name FROM bills b
         JOIN shops s ON s.id = b.shop_id
         WHERE ${conditions.join(' AND ')}
         ORDER BY b.created_at DESC`,
        params
      );
      const shops = await ShopModel.listAll({ is_active: '1' });
      renderWithLayout(req, res, 'direct-sales/index', { title: 'Direct Shop Sales', bills, shops, filters });
    } catch (err) {
      req.flash('error', 'Failed to load bills.'); res.redirect('/dashboard');
    }
  },

  // GET /direct-sales/:id/print
  async printBill(req, res) {
    try {
      const bill = await OrderModel.findBillById(req.params.id);
      if (!bill) { req.flash('error', 'Bill not found.'); return res.redirect('/direct-sales'); }
      res.send(formatBillForPrint(bill));
    } catch (err) {
      req.flash('error', 'Failed to generate print.'); res.redirect('/direct-sales');
    }
  },
};

module.exports = DirectSalesController;
