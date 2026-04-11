'use strict';

const { query, getConnection } = require('../config/db');
const AuditModel = require('./AuditModel');

const RecoveryModel = {
  async listOutstandingBills(filters = {}) {
    const conditions = ['b.outstanding_amount > 0', 'b.status != \'cleared\''];
    const params = [];

    // Exclude bills already actively assigned
    conditions.push(`NOT EXISTS (
      SELECT 1 FROM bill_recovery_assignments bra
      WHERE bra.bill_id = b.id AND bra.status IN ('assigned','partially_recovered')
    )`);

    if (filters.route_id)  { conditions.push('s.route_id = ?');  params.push(filters.route_id); }
    if (filters.shop_id)   { conditions.push('b.shop_id = ?');   params.push(filters.shop_id); }

    return query(
      `SELECT b.*, s.name AS shop_name, r.name AS route_name
       FROM bills b
       JOIN shops s ON s.id = b.shop_id
       JOIN routes r ON r.id = s.route_id
       WHERE ${conditions.join(' AND ')}
       ORDER BY b.bill_date ASC`,
      params
    );
  },

  async assignBills(billIds, bookerId, adminId) {
    const today = new Date().toISOString().slice(0, 10);
    const conn = await getConnection();
    try {
      await conn.beginTransaction();
      for (const billId of billIds) {
        // Check no active assignment
        const [[existing]] = await conn.query(
          `SELECT id FROM bill_recovery_assignments
           WHERE bill_id = ? AND status IN ('assigned','partially_recovered') LIMIT 1`,
          [billId]
        );
        if (existing) continue; // Skip already assigned

        await conn.query(
          `INSERT INTO bill_recovery_assignments
             (bill_id, assigned_to_booker_id, assigned_date, assigned_by)
           VALUES (?, ?, ?, ?)`,
          [billId, bookerId, today, adminId]
        );
      }
      await AuditModel.insertLog({ userId: adminId, action: 'ASSIGN_RECOVERY_BILLS', entityType: 'bill_recovery_assignments', newValue: { billIds, bookerId } }, conn);
      await conn.commit();
    } catch (err) { await conn.rollback(); throw err; }
    finally { conn.release(); }
  },

  async listPendingVerifications() {
    return query(
      `SELECT rc.*, b.bill_number, b.outstanding_amount, b.net_amount,
              s.name AS shop_name, u.full_name AS booker_name
       FROM recovery_collections rc
       JOIN bills b ON b.id = rc.bill_id
       JOIN shops s ON s.id = b.shop_id
       JOIN users u ON u.id = rc.collected_by_booker_id
       WHERE rc.verified_by_admin_id IS NULL
       ORDER BY rc.created_at ASC`
    );
  },

  async verifyCollection(collectionId, adminId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();

      const [[rc]] = await conn.query(
        'SELECT * FROM recovery_collections WHERE id = ? FOR UPDATE', [collectionId]
      );
      if (!rc) throw new Error('Collection not found');
      if (rc.verified_by_admin_id) throw new Error('Already verified');

      const [[bill]] = await conn.query('SELECT * FROM bills WHERE id = ? FOR UPDATE', [rc.bill_id]);
      const newAmountPaid = parseFloat(bill.amount_paid) + parseFloat(rc.amount_collected);
      const newOutstanding = Math.max(0, parseFloat(bill.net_amount) - newAmountPaid);
      const newStatus = newOutstanding <= 0 ? 'cleared' : 'partially_paid';

      await conn.query(
        'UPDATE bills SET amount_paid=?, outstanding_amount=?, status=? WHERE id=?',
        [newAmountPaid, newOutstanding, newStatus, rc.bill_id]
      );

      // Update assignment status
      await conn.query(
        `UPDATE bill_recovery_assignments SET status=? WHERE id=?`,
        [newOutstanding <= 0 ? 'fully_recovered' : 'partially_recovered', rc.assignment_id]
      );

      // Shop ledger entry
      const [[balRow]] = await conn.query(
        'SELECT COALESCE(balance_after,0) AS bal FROM shop_ledger_entries WHERE shop_id=? ORDER BY created_at DESC LIMIT 1',
        [bill.shop_id]
      );
      const newBalance = parseFloat(balRow.bal) - parseFloat(rc.amount_collected);
      await conn.query(
        `INSERT INTO shop_ledger_entries
           (shop_id, entry_type, reference_id, reference_type, debit, credit, balance_after, note, entry_date)
         VALUES (?, 'recovery', ?, 'recovery_collections', 0, ?, ?, ?, CURDATE())`,
        [bill.shop_id, collectionId, rc.amount_collected, newBalance, `Recovery for bill ${bill.bill_number}`]
      );

      // Centralized cash
      await conn.query(
        `INSERT INTO centralized_cash_entries (entry_type, reference_id, reference_type, amount, cash_date, recorded_by)
         VALUES ('recovery', ?, 'recovery_collections', ?, CURDATE(), ?)`,
        [collectionId, rc.amount_collected, adminId]
      );

      // Mark verified
      await conn.query(
        'UPDATE recovery_collections SET verified_by_admin_id=?, verified_at=NOW() WHERE id=?',
        [adminId, collectionId]
      );

      await AuditModel.insertLog({ userId: adminId, action: 'VERIFY_RECOVERY', entityType: 'recovery_collections', entityId: collectionId }, conn);
      await conn.commit();
    } catch (err) { await conn.rollback(); throw err; }
    finally { conn.release(); }
  },

  async listHistory(filters = {}) {
    const conditions = ['rc.verified_by_admin_id IS NOT NULL'];
    const params = [];
    if (filters.date)      { conditions.push('DATE(rc.verified_at) = ?'); params.push(filters.date); }
    if (filters.booker_id) { conditions.push('rc.collected_by_booker_id = ?'); params.push(filters.booker_id); }
    if (filters.shop_id)   { conditions.push('b.shop_id = ?'); params.push(filters.shop_id); }

    return query(
      `SELECT rc.*, b.bill_number, s.name AS shop_name, u.full_name AS booker_name
       FROM recovery_collections rc
       JOIN bills b ON b.id = rc.bill_id
       JOIN shops s ON s.id = b.shop_id
       JOIN users u ON u.id = rc.collected_by_booker_id
       WHERE ${conditions.join(' AND ')}
       ORDER BY rc.verified_at DESC`,
      params
    );
  },
};

module.exports = RecoveryModel;
