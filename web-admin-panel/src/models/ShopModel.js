'use strict';

const { query, getConnection } = require('../config/db');
const AuditModel = require('./AuditModel');

const ShopModel = {
  async countAll(filters = {}) {
    const conditions = [];
    const params = [];

    if (filters.search) {
      conditions.push('(s.name LIKE ? OR s.owner_name LIKE ? OR s.phone LIKE ?)');
      const like = `%${filters.search}%`;
      params.push(like, like, like);
    }
    if (filters.route_id) {
      conditions.push('s.route_id = ?');
      params.push(filters.route_id);
    }
    if (filters.shop_type) {
      conditions.push('s.shop_type = ?');
      params.push(filters.shop_type);
    }
    if (filters.is_active !== undefined && filters.is_active !== '') {
      conditions.push('s.is_active = ?');
      params.push(filters.is_active);
    }
    if (filters.has_outstanding === '1') {
      conditions.push(`EXISTS (SELECT 1 FROM bills b WHERE b.shop_id = s.id AND b.status IN ('open','partially_paid') AND b.outstanding_amount > 0)`);
    } else if (filters.has_outstanding === '0') {
      conditions.push(`NOT EXISTS (SELECT 1 FROM bills b WHERE b.shop_id = s.id AND b.status IN ('open','partially_paid') AND b.outstanding_amount > 0)`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const rows = await query(`
      SELECT COUNT(*) AS total
      FROM shops s
      JOIN routes r ON r.id = s.route_id
      ${where}
    `, params);
    return rows[0].total;
  },

  async listAll(filters = {}, { limit = 25, offset = 0 } = {}) {
    const conditions = [];
    const params = [];

    if (filters.search) {
      conditions.push('(s.name LIKE ? OR s.owner_name LIKE ? OR s.phone LIKE ?)');
      const like = `%${filters.search}%`;
      params.push(like, like, like);
    }
    if (filters.route_id) {
      conditions.push('s.route_id = ?');
      params.push(filters.route_id);
    }
    if (filters.shop_type) {
      conditions.push('s.shop_type = ?');
      params.push(filters.shop_type);
    }
    if (filters.is_active !== undefined && filters.is_active !== '') {
      conditions.push('s.is_active = ?');
      params.push(filters.is_active);
    }
    if (filters.has_outstanding === '1') {
      conditions.push(`EXISTS (SELECT 1 FROM bills b WHERE b.shop_id = s.id AND b.status IN ('open','partially_paid') AND b.outstanding_amount > 0)`);
    } else if (filters.has_outstanding === '0') {
      conditions.push(`NOT EXISTS (SELECT 1 FROM bills b WHERE b.shop_id = s.id AND b.status IN ('open','partially_paid') AND b.outstanding_amount > 0)`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    params.push(limit, offset);

    // When has_outstanding filter is active, include sum of outstanding amounts from bills
    // Otherwise, use the ledger balance
    const outstandingBalanceSelect = filters.has_outstanding === '1'
      ? `COALESCE((
          SELECT SUM(b.outstanding_amount)
          FROM bills b
          WHERE b.shop_id = s.id
            AND b.status IN ('open','partially_paid')
            AND b.outstanding_amount > 0
        ), 0) AS outstanding_balance`
      : `COALESCE((
          SELECT sle.balance_after
          FROM shop_ledger_entries sle
          WHERE sle.shop_id = s.id
          ORDER BY sle.created_at DESC
          LIMIT 1
        ), 0) AS outstanding_balance`;

    return query(`
      SELECT s.*, r.name AS route_name,
        ${outstandingBalanceSelect}
      FROM shops s
      JOIN routes r ON r.id = s.route_id
      ${where}
      ORDER BY s.name ASC
      LIMIT ? OFFSET ?
    `, params);
  },

  async findById(id) {
    const rows = await query(`
      SELECT s.*, r.name AS route_name
      FROM shops s
      JOIN routes r ON r.id = s.route_id
      WHERE s.id = ? LIMIT 1
    `, [id]);
    return rows[0] || null;
  },

  async create(data) {
    const result = await query(`
      INSERT INTO shops
        (name, owner_name, phone, address, route_id, shop_type,
         price_edit_allowed, price_max_discount_pct)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      data.name,
      data.owner_name   || null,
      data.phone        || null,
      data.address      || null,
      data.route_id,
      data.shop_type    || 'retail',
      data.price_edit_allowed ? 1 : 0,
      data.price_max_discount_pct != null && data.price_max_discount_pct !== '' ? data.price_max_discount_pct : 0,
    ]);
    return result.insertId;
  },

  async update(id, data) {
    const discount = parseFloat(data.price_max_discount_pct);
    await query(`
      UPDATE shops SET
        name = ?, owner_name = ?, phone = ?, address = ?,
        route_id = ?, shop_type = ?,
        price_edit_allowed = ?, price_max_discount_pct = ?
      WHERE id = ?
    `, [
      data.name,
      data.owner_name   || null,
      data.phone        || null,
      data.address      || null,
      data.route_id,
      data.shop_type    || 'retail',
      data.price_edit_allowed ? 1 : 0,
      isNaN(discount) ? 0 : discount,
      id,
    ]);
  },

  async bulkImportFromCSV(rows) {
    const results = { inserted: 0, errors: [] };
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      try {
        if (!row.name || !row.route_id) {
          results.errors.push(`Row ${i + 2}: name and route_id are required.`);
          continue;
        }
        await ShopModel.create(row);
        results.inserted++;
      } catch (err) {
        results.errors.push(`Row ${i + 2}: ${err.message}`);
      }
    }
    return results;
  },

  async getOutstandingBalance(shopId) {
    const rows = await query(`
      SELECT balance_after FROM shop_ledger_entries
      WHERE shop_id = ?
      ORDER BY created_at DESC
      LIMIT 1
    `, [shopId]);
    return rows.length ? rows[0].balance_after : 0;
  },

  // ── Shop Ledger ────────────────────────────────────────────────────────────

  async getLedgerEntries(shopId, { limit = 25, offset = 0 } = {}) {
    const entries = await query(`
      SELECT * FROM shop_ledger_entries
      WHERE shop_id = ?
      ORDER BY entry_date DESC, created_at DESC
      LIMIT ? OFFSET ?
    `, [shopId, limit, offset]);
    const [countRow] = await query('SELECT COUNT(*) AS total FROM shop_ledger_entries WHERE shop_id = ?', [shopId]);
    return { entries, total: countRow.total };
  },

  async getCurrentBalance(shopId) {
    return ShopModel.getOutstandingBalance(shopId);
  },

  async addAdvance(shopId, data, adminId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();

      const sid = parseInt(shopId);
      const uid = parseInt(adminId);
      const amount = parseFloat(data.amount);
      const advanceDate = String(data.advance_date);
      const paymentMethod = String(data.payment_method);
      const note = data.note ? String(data.note) : null;

      // Get current balance
      const [balRows] = await conn.query(
        `SELECT CAST(balance_after AS CHAR) AS balance_after FROM shop_ledger_entries WHERE shop_id = ? ORDER BY created_at DESC LIMIT 1`,
        [sid]
      );
      const prevBalance = balRows.length ? parseFloat(balRows[0].balance_after) : 0;
      const balanceAfter = parseFloat((prevBalance - amount).toFixed(2));
      const noteSQL = note ? `'${note.replace(/'/g, "''")}'` : 'NULL';

      // Insert shop_advances — inline all values to avoid mysql2 binary protocol bug
      const [advResult] = await conn.query(
        `INSERT INTO shop_advances (shop_id, amount, remaining_balance, advance_date, payment_method, note, recorded_by) VALUES (${sid}, ${amount}, ${amount}, '${advanceDate}', '${paymentMethod}', ${noteSQL}, ${uid})`
      );
      const advId = advResult.insertId;

      // Insert shop_ledger_entries — inline all values
      await conn.query(
        `INSERT INTO shop_ledger_entries (shop_id, entry_type, reference_id, reference_type, debit, credit, balance_after, note, entry_date) VALUES (${sid}, 'advance_payment', ${advId}, 'shop_advances', 0, ${amount}, ${balanceAfter}, ${noteSQL}, '${advanceDate}')`
      );

      await AuditModel.insertLog({
        userId: uid,
        action: 'RECORD_SHOP_ADVANCE',
        entityType: 'shop_advances',
        entityId: advId,
        newValue: { shopId: sid, amount, advance_date: advanceDate, payment_method: paymentMethod },
      }, conn);

      await conn.commit();
      return advId;
    } catch (err) {
      await conn.rollback().catch(() => {});
      throw err;
    } finally {
      conn.release();
    }
  },
};

module.exports = ShopModel;
