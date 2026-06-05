'use strict';

const { getConnection } = require('../config/db');
const StockService = require('./StockService');
const BillService  = require('./BillService');
const AuditModel   = require('../models/AuditModel');

const OrderService = {
  /**
   * Convert a pending order to a bill.
   * Deducts stock, creates bill, updates order status.
   */
  async convertOrderToBill(orderId, adminId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();

      // Lock and fetch order
      const [[order]] = await conn.query(
        'SELECT * FROM orders WHERE id = ? FOR UPDATE', [orderId]
      );
      if (!order) throw new Error('Order not found');
      if (order.status === 'converted') throw new Error('Order already converted');
      if (order.status === 'cancelled') throw new Error('Order is cancelled');

      // Fetch order items with product info
      const [items] = await conn.query(
        `SELECT oi.*, p.units_per_carton, p.retail_price AS unit_price
         FROM order_items oi
         JOIN products p ON p.id = oi.product_id
         WHERE oi.order_id = ?`,
        [orderId]
      );

      if (!items.length) throw new Error('Order has no items');

      // Deduct stock for each item
      const billItems = [];
      for (const item of items) {
        const { stockAfterCartons, stockAfterLoose } = await StockService.deductStock(
          item.product_id, item.final_cartons, item.final_loose, conn
        );
        await StockService.recordDeductionMovement(
          item.product_id, item.final_cartons, item.final_loose,
          'bill_deduction', orderId, 'orders', null, adminId,
          stockAfterCartons, stockAfterLoose, conn
        );
        billItems.push({
          product_id:      item.product_id,
          cartons:         item.final_cartons,
          loose_units:     item.final_loose,
          unit_price:      item.unit_price,
          units_per_carton: item.units_per_carton,
        });
      }

      // Create bill
      const { billId, billNumber } = await BillService.createBill(
        order.shop_id, 'order_booker', billItems, adminId, conn, orderId
      );

      // Update order status
      await conn.query(
        'UPDATE orders SET status = \'converted\' WHERE id = ?', [orderId]
      );

      await AuditModel.insertLog({
        userId: adminId, action: 'CONVERT_ORDER_TO_BILL',
        entityType: 'orders', entityId: orderId,
        newValue: { billId, billNumber }
      }, conn);

      await conn.commit();
      return { billId, billNumber };
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  },

  /**
   * Adjust order items based on available stock.
   * Called during evening sync processing.
   */
  adjustOrderForStock(orderItems, stockMap) {
    const adjustments = [];
    for (const item of orderItems) {
      const available = stockMap[item.product_id] || { cartons: 0, loose: 0 };
      const origCartons = item.ordered_cartons;
      const origLoose   = item.ordered_loose;

      item.final_cartons = Math.min(origCartons, available.cartons);
      item.final_loose   = Math.min(origLoose,   available.loose);

      if (item.final_cartons < origCartons || item.final_loose < origLoose) {
        adjustments.push({
          product_id: item.product_id,
          original:   { cartons: origCartons, loose: origLoose },
          adjusted:   { cartons: item.final_cartons, loose: item.final_loose },
          removed:    item.final_cartons === 0 && item.final_loose === 0,
        });
      }
    }
    return adjustments;
  },
};

module.exports = OrderService;
