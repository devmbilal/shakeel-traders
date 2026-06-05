'use strict';

const { query, getConnection } = require('../config/db');
const StockService = require('../services/StockService');
const AuditModel = require('./AuditModel');

const ReturnModel = {
  async listPending() {
    return query(
      `SELECT sr.*, u.full_name AS salesman_name, si.issuance_date,
              COALESCE((
                SELECT SUM((ii.cartons - ri.returned_cartons) * p.units_per_carton * p.retail_price +
                           (ii.loose_units - ri.returned_loose) * p.retail_price)
                FROM return_items ri
                JOIN issuance_items ii ON ii.issuance_id = sr.issuance_id AND ii.product_id = ri.product_id
                JOIN products p ON p.id = ri.product_id
                WHERE ri.return_id = sr.id
              ), 0) AS system_sale_value
       FROM salesman_returns sr
       JOIN users u ON u.id = sr.salesman_id
       JOIN salesman_issuances si ON si.id = sr.issuance_id
       WHERE sr.status = 'pending'
       ORDER BY sr.created_at ASC`
    );
  },

  async findById(id) {
    const rows = await query(
      `SELECT sr.*, u.full_name AS salesman_name, si.issuance_date
       FROM salesman_returns sr
       JOIN users u ON u.id = sr.salesman_id
       JOIN salesman_issuances si ON si.id = sr.issuance_id
       WHERE sr.id = ? LIMIT 1`,
      [id]
    );
    if (!rows.length) return null;
    const ret = rows[0];

    // Get return items with issued quantities
    ret.items = await query(
      `SELECT ri.*,
              p.name AS product_name, p.sku_code, p.units_per_carton,
              ii.cartons AS issued_cartons, ii.loose_units AS issued_loose
       FROM return_items ri
       JOIN products p ON p.id = ri.product_id
       JOIN issuance_items ii ON ii.issuance_id = ? AND ii.product_id = ri.product_id
       WHERE ri.return_id = ?`,
      [ret.issuance_id, id]
    );
    return ret;
  },

  async approve(id, adminId, finalSaleValue) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();
      const [[ret]] = await conn.query(
        'SELECT * FROM salesman_returns WHERE id = ? FOR UPDATE', [id]
      );
      if (!ret) throw new Error('Return not found');
      if (ret.status !== 'pending') throw new Error('Return is not pending');

      const [items] = await conn.query(
        'SELECT * FROM return_items WHERE return_id = ?', [id]
      );

      // Add returned stock back to warehouse
      for (const item of items) {
        await StockService.addStock(
          item.product_id, item.returned_cartons, item.returned_loose,
          'return_salesman', id, 'salesman_returns', null, adminId, conn
        );
      }

      // Compute system_sale_value if not already set
      let systemSaleValue = parseFloat(ret.system_sale_value || 0);
      if (!systemSaleValue) {
        const [saleRows] = await conn.query(
          `SELECT SUM((ii.cartons - ri.returned_cartons) * p.units_per_carton * p.retail_price +
                      (ii.loose_units - ri.returned_loose) * p.retail_price) AS val
           FROM return_items ri
           JOIN issuance_items ii ON ii.issuance_id = ? AND ii.product_id = ri.product_id
           JOIN products p ON p.id = ri.product_id
           WHERE ri.return_id = ?`,
          [ret.issuance_id, id]
        );
        systemSaleValue = parseFloat(saleRows[0]?.val || 0);
      }

      const usedSaleValue = finalSaleValue != null && finalSaleValue !== ''
        ? parseFloat(finalSaleValue)
        : systemSaleValue;

      await conn.query(
        `UPDATE salesman_returns SET status='approved', approved_by=?, approved_at=NOW(), system_sale_value=?, admin_edited_sale_value=?, final_sale_value=? WHERE id=?`,
        [adminId, systemSaleValue, finalSaleValue || null, usedSaleValue, id]
      );

      await conn.query(
        `INSERT INTO centralized_cash_entries (entry_type, reference_id, reference_type, amount, cash_date, recorded_by) VALUES ('salesman_sale', ?, 'salesman_returns', ?, CURDATE(), ?)`,
        [id, usedSaleValue, adminId]
      );

      await AuditModel.insertLog({
        userId: adminId, action: 'APPROVE_RETURN', entityType: 'salesman_returns',
        entityId: id, newValue: { final_sale_value: usedSaleValue }
      }, conn);
      await conn.commit();
    } catch (err) { await conn.rollback().catch(() => {}); throw err; }
    finally { conn.release(); }
  },
};

module.exports = ReturnModel;
