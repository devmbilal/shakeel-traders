'use strict';

const { query, getConnection } = require('../config/db');
const StockService = require('../services/StockService');
const AuditModel = require('./AuditModel');

const IssuanceModel = {
  async listPending() {
    const issuances = await query(
      `SELECT si.*, u.full_name AS salesman_name
       FROM salesman_issuances si
       JOIN users u ON u.id = si.salesman_id
       WHERE si.status = 'pending'
       ORDER BY si.created_at ASC`
    );
    // Attach items to each issuance
    for (const iss of issuances) {
      iss.items = await query(
        `SELECT ii.*, p.name AS product_name, p.sku_code, p.units_per_carton
         FROM issuance_items ii
         JOIN products p ON p.id = ii.product_id
         WHERE ii.issuance_id = ?`,
        [iss.id]
      );
    }
    return issuances;
  },

  async findById(id) {
    const rows = await query(
      `SELECT si.*, u.full_name AS salesman_name
       FROM salesman_issuances si
       JOIN users u ON u.id = si.salesman_id
       WHERE si.id = ? LIMIT 1`,
      [id]
    );
    if (!rows.length) return null;
    const issuance = rows[0];
    issuance.items = await query(
      `SELECT ii.*, p.name AS product_name, p.sku_code, p.units_per_carton
       FROM issuance_items ii
       JOIN products p ON p.id = ii.product_id
       WHERE ii.issuance_id = ?`,
      [id]
    );
    return issuance;
  },

  async approve(id, adminId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();
      const [[issuance]] = await conn.query(
        'SELECT * FROM salesman_issuances WHERE id = ? FOR UPDATE', [id]
      );
      if (!issuance) throw new Error('Issuance not found');
      if (issuance.status !== 'pending') throw new Error('Issuance is not pending');

      const [items] = await conn.query(
        'SELECT * FROM issuance_items WHERE issuance_id = ?', [id]
      );

      for (const item of items) {
        const { stockAfterCartons, stockAfterLoose } = await StockService.deductStock(
          item.product_id, item.cartons, item.loose_units, conn
        );
        await StockService.recordDeductionMovement(
          item.product_id, item.cartons, item.loose_units,
          'issuance_salesman', id, 'salesman_issuances', null, adminId,
          stockAfterCartons, stockAfterLoose, conn
        );
      }

      await conn.query(
        'UPDATE salesman_issuances SET status=\'approved\', approved_by=?, approved_at=NOW() WHERE id=?',
        [adminId, id]
      );
      await AuditModel.insertLog({ userId: adminId, action: 'APPROVE_ISSUANCE', entityType: 'salesman_issuances', entityId: id }, conn);
      await conn.commit();
    } catch (err) { await conn.rollback().catch(() => {}); throw err; }
    finally { conn.release(); }
  },
};

module.exports = IssuanceModel;
