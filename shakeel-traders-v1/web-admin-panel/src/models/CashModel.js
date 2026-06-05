'use strict';

const { query, getConnection } = require('../config/db');
const AuditModel = require('./AuditModel');

const CashModel = {
  async recordDeliveryManCollection(billId, deliveryManId, amount, adminId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();

      const [[bill]] = await conn.query('SELECT * FROM bills WHERE id = ? FOR UPDATE', [billId]);
      if (!bill) throw new Error('Bill not found');

      const collected = parseFloat(amount);
      const newAmountPaid = parseFloat(bill.amount_paid) + collected;
      const newOutstanding = Math.max(0, parseFloat(bill.net_amount) - newAmountPaid);
      const newStatus = newOutstanding <= 0 ? 'cleared' : 'partially_paid';

      // Insert delivery_man_collections
      const [result] = await conn.query(
        `INSERT INTO delivery_man_collections
           (bill_id, delivery_man_id, amount_collected, collection_date, recorded_by)
         VALUES (?, ?, ?, CURDATE(), ?)`,
        [billId, deliveryManId, collected, adminId]
      );

      // Update bill
      await conn.query(
        'UPDATE bills SET amount_paid=?, outstanding_amount=?, status=? WHERE id=?',
        [newAmountPaid, newOutstanding, newStatus, billId]
      );

      // Shop ledger entry
      const [[balRow]] = await conn.query(
        'SELECT COALESCE(balance_after,0) AS bal FROM shop_ledger_entries WHERE shop_id=? ORDER BY created_at DESC LIMIT 1',
        [bill.shop_id]
      );
      const newBalance = parseFloat(balRow.bal) - collected;
      await conn.query(
        `INSERT INTO shop_ledger_entries
           (shop_id, entry_type, reference_id, reference_type, debit, credit, balance_after, note, entry_date)
         VALUES (?, 'payment_delivery_man', ?, 'delivery_man_collections', 0, ?, ?, ?, CURDATE())`,
        [bill.shop_id, result.insertId, collected, newBalance, `Delivery man payment for ${bill.bill_number}`]
      );

      // Centralized cash
      await conn.query(
        `INSERT INTO centralized_cash_entries (entry_type, reference_id, reference_type, amount, cash_date, recorded_by)
         VALUES ('delivery_man_collection', ?, 'delivery_man_collections', ?, CURDATE(), ?)`,
        [result.insertId, collected, adminId]
      );

      await AuditModel.insertLog({ userId: adminId, action: 'RECORD_DELIVERY_MAN_COLLECTION', entityType: 'delivery_man_collections', entityId: result.insertId }, conn);
      await conn.commit();
      return { newStatus, newOutstanding };
    } catch (err) { await conn.rollback(); throw err; }
    finally { conn.release(); }
  },

  async listOpenBills() {
    return query(
      `SELECT b.*, s.name AS shop_name FROM bills b
       JOIN shops s ON s.id = b.shop_id
       WHERE b.status != 'cleared' AND b.outstanding_amount > 0
       ORDER BY b.bill_date ASC`
    );
  },

  async listDeliveryMen() {
    return query('SELECT * FROM delivery_men WHERE is_active = 1 ORDER BY full_name ASC');
  },

  async getDailyView(date) {
    return query(
      `SELECT entry_type, SUM(amount) AS total
       FROM centralized_cash_entries
       WHERE cash_date = ?
       GROUP BY entry_type`,
      [date]
    );
  },

  async getMonthlyView(dateFrom, dateTo) {
    return query(
      `SELECT cash_date, entry_type, SUM(amount) AS total
       FROM centralized_cash_entries
       WHERE cash_date BETWEEN ? AND ?
       GROUP BY cash_date, entry_type
       ORDER BY cash_date ASC`,
      [dateFrom, dateTo]
    );
  },
};

module.exports = CashModel;
