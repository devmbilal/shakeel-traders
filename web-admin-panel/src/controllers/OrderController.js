'use strict';

const OrderModel   = require('../models/OrderModel');
const OrderService = require('../services/OrderService');
const UserModel    = require('../models/UserModel');
const RouteModel   = require('../models/RouteModel');
const ShopModel    = require('../models/ShopModel');
const { formatBillForPrint } = require('../utils/printFormatter');
const { renderWithLayout } = require('../utils/render');
const { query } = require('../config/db');

const OrderController = {

  // GET /orders — Pending Orders
  async pendingOrders(req, res) {
    try {
      const { paginate } = require('../utils/paginate');
      const filters = {
        date:      req.query.date      || '',
        booker_id: req.query.booker_id || '',
        route_id:  req.query.route_id  || '',
        shop_id:   req.query.shop_id   || '',
      };
      const page = parseInt(req.query.page) || 1;
      const total = await OrderModel.countPending(filters);
      const pagination = paginate(total, page);
      const [orders, bookers, routes] = await Promise.all([
        OrderModel.listPending(filters, { limit: pagination.limit, offset: pagination.offset }),
        UserModel.listByRole('order_booker'),
        RouteModel.listAll(),
      ]);
      const queryString = new URLSearchParams({ ...req.query, page: undefined }).toString();
      
      renderWithLayout(req, res, 'orders/pending', {
        title: 'Order Management',
        orders,
        bookers,
        routes,
        filters,
        pagination,
        queryString,
      });
    } catch (err) {
      req.flash('error', 'Failed to load orders.'); res.redirect('/dashboard');
    }
  },

  // GET /orders/converted — Converted Bills
  async convertedBills(req, res) {
    try {
      const { paginate } = require('../utils/paginate');
      const filters = { date: req.query.date || '', shop_id: req.query.shop_id || '' };
      const page = parseInt(req.query.page) || 1;
      const total = await OrderModel.countConverted(filters);
      const pagination = paginate(total, page);
      const bills = await OrderModel.listConverted(filters, { limit: pagination.limit, offset: pagination.offset });
      const queryString = new URLSearchParams({ ...req.query, page: undefined }).toString();
      
      renderWithLayout(req, res, 'orders/converted', {
        title: 'Converted Bills',
        bills,
        filters,
        pagination,
        queryString,
      });
    } catch (err) {
      req.flash('error', 'Failed to load bills.'); res.redirect('/orders');
    }
  },

  // GET /orders/consolidated — Consolidated Stock View
  async consolidated(req, res) {
    try {
      const report = await query(
        `SELECT p.sku_code, p.name, p.units_per_carton,
                SUM(oi.final_cartons) AS total_cartons,
                SUM(oi.final_loose)   AS total_loose
         FROM order_items oi
         JOIN orders o ON o.id = oi.order_id
         JOIN products p ON p.id = oi.product_id
         WHERE o.status IN ('pending','stock_adjusted')
         GROUP BY p.id ORDER BY p.name ASC`
      );
      renderWithLayout(req, res, 'orders/consolidated', { title: 'Consolidated Stock View', report });
    } catch (err) {
      req.flash('error', 'Failed to load report.'); res.redirect('/orders');
    }
  },

  // POST /orders/:id/convert
  async convertToBill(req, res) {
    try {
      const { billId, billNumber } = await OrderService.convertOrderToBill(req.params.id, req.session.user.id);
      req.flash('success', `Bill ${billNumber} created. Stock deducted.`);
      res.redirect('/orders/converted');
    } catch (err) {
      req.flash('error', err.message); res.redirect('/orders');
    }
  },

  // GET /orders/bills/:id/print
  async printBill(req, res) {
    try {
      const bill = await OrderModel.findBillById(req.params.id);
      if (!bill) { req.flash('error', 'Bill not found.'); return res.redirect('/orders/converted'); }
      res.send(formatBillForPrint(bill));
    } catch (err) {
      req.flash('error', 'Failed to generate print.'); res.redirect('/orders/converted');
    }
  },

  // POST /orders/bulk-convert
  async bulkConvert(req, res) {
    try {
      const orderIds = req.body.order_ids || [];
      if (!Array.isArray(orderIds) || orderIds.length === 0) {
        req.flash('error', 'No orders selected.');
        return res.redirect('/orders');
      }

      const succeeded = [];
      const failed = [];

      for (const orderId of orderIds) {
        try {
          const { billId, billNumber } = await OrderService.convertOrderToBill(orderId, req.session.user.id);
          succeeded.push({ orderId, billNumber });
        } catch (err) {
          failed.push({ orderId, reason: err.message });
        }
      }

      if (succeeded.length > 0) {
        req.flash('success', `Converted ${succeeded.length} order(s) to bills.`);
      }
      if (failed.length > 0) {
        req.flash('error', `Failed to convert ${failed.length} order(s): ${failed.map(f => `#${f.orderId} (${f.reason})`).join(', ')}`);
      }

      res.redirect('/orders');
    } catch (err) {
      req.flash('error', 'Bulk conversion failed.'); res.redirect('/orders');
    }
  },

  // POST /orders/bulk-delete
  async bulkDelete(req, res) {
    try {
      const orderIds = req.body.order_ids || [];
      if (!Array.isArray(orderIds) || orderIds.length === 0) {
        req.flash('error', 'No orders selected.');
        return res.redirect('/orders');
      }

      const deleted = [];
      const skipped = [];

      for (const orderId of orderIds) {
        const rows = await query('SELECT status FROM orders WHERE id = ?', [orderId]);
        if (rows.length === 0) continue;
        
        const status = rows[0].status;
        if (status === 'converted') {
          skipped.push(orderId);
        } else {
          await query('DELETE FROM order_items WHERE order_id = ?', [orderId]);
          await query('DELETE FROM orders WHERE id = ?', [orderId]);
          deleted.push(orderId);
        }
      }

      if (deleted.length > 0) {
        req.flash('success', `Deleted ${deleted.length} order(s).`);
      }
      if (skipped.length > 0) {
        req.flash('error', `Skipped ${skipped.length} already-converted order(s): ${skipped.join(', ')}`);
      }

      res.redirect('/orders');
    } catch (err) {
      req.flash('error', 'Bulk delete failed.'); res.redirect('/orders');
    }
  },

  // GET /orders/consolidated-selected?ids=1,2,3
  async consolidatedSelected(req, res) {
    try {
      const idsParam = req.query.ids || '';
      const orderIds = idsParam.split(',').map(id => parseInt(id)).filter(id => !isNaN(id));
      
      if (orderIds.length === 0) {
        return res.json({ error: 'No valid order IDs provided' });
      }

      const products = await OrderModel.getConsolidatedForIds(orderIds);
      
      // Calculate shortfall
      products.forEach(p => {
        const requiredUnits = (p.total_cartons * p.units_per_carton) + p.total_loose;
        const availableUnits = (p.current_stock_cartons * p.units_per_carton) + p.current_stock_loose;
        p.shortfall = requiredUnits > availableUnits;
      });

      res.json({ products, totalOrders: orderIds.length });
    } catch (err) {
      res.status(500).json({ error: 'Failed to fetch consolidated stock' });
    }
  },

  // GET /orders/consolidated-pdf?ids=1,2,3
  async consolidatedPdf(req, res) {
    try {
      const { generateConsolidatedStockPDF } = require('../utils/pdfGenerator');
      const idsParam = req.query.ids || '';
      const orderIds = idsParam.split(',').map(id => parseInt(id)).filter(id => !isNaN(id));
      
      if (orderIds.length === 0) {
        req.flash('error', 'No orders selected.');
        return res.redirect('/orders');
      }

      const products = await OrderModel.getConsolidatedForIds(orderIds);
      
      // Calculate shortfall
      products.forEach(p => {
        const requiredUnits = (p.total_cartons * p.units_per_carton) + p.total_loose;
        const availableUnits = (p.current_stock_cartons * p.units_per_carton) + p.current_stock_loose;
        p.shortfall = requiredUnits > availableUnits;
      });

      const pdfBuffer = await generateConsolidatedStockPDF({
        products,
        totalOrders: orderIds.length,
        date: new Date().toLocaleDateString(),
      });

      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename="consolidated-stock-${Date.now()}.pdf"`);
      res.send(pdfBuffer);
    } catch (err) {
      req.flash('error', 'Failed to generate PDF.'); res.redirect('/orders');
    }
  },

  // GET /orders/bills/print-open
  async printOpenBills(req, res) {
    try {
      const { generateOpenBillsPDF } = require('../utils/pdfGenerator');
      const bills = await OrderModel.listOpenBills();
      
      if (bills.length === 0) {
        req.flash('error', 'No open bills found.');
        return res.redirect('/orders/converted');
      }

      const companyProfile = await query('SELECT * FROM company_profile WHERE id = 1 LIMIT 1');
      const company = companyProfile[0] || { company_name: 'Shakeel Traders' };

      const pdfBuffer = await generateOpenBillsPDF(bills, company);

      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename="open-bills-${Date.now()}.pdf"`);
      res.send(pdfBuffer);
    } catch (err) {
      req.flash('error', 'Failed to generate PDF.'); res.redirect('/orders/converted');
    }
  },
};

module.exports = OrderController;
