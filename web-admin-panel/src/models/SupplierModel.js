'use strict';

const { query, getConnection } = require('../config/db');
const StockService = require('../services/StockService');
const AuditModel = require('./AuditModel');

const SupplierModel = {
  async listAll() {
    return query('SELECT * FROM supplier_companies ORDER BY name ASC');
  },

  async findById(id) {
    const rows = await query('SELECT * FROM supplier_companies WHERE id = ? LIMIT 1', [id]);
    return rows[0] || null;
  },

  async create(data) {
    const result = await query(
      'INSERT INTO supplier_companies (name, contact_person, phone) VALUES (?, ?, ?)',
      [data.name, data.contact_person || null, data.phone || null]
    );
    return result.insertId;
  },

  async update(id, data) {
    await query(
      'UPDATE supplier_companies SET name=?, contact_person=?, phone=? WHERE id=?',
      [data.name, data.contact_person || null, data.phone || null, id]
    );
  },

  async recordAdvance(companyId, data, userId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();
      const [result] = await conn.query(
        'INSERT INTO supplier_advances (company_id, amount, payment_date, payment_method, note, recorded_by) VALUES (?, ?, ?, ?, ?, ?)',
        [companyId, data.amount, data.payment_date, data.payment_method, data.note || null, userId]
      );
      await conn.query(
        'UPDATE supplier_companies SET current_advance_balance = current_advance_balance + ? WHERE id = ?',
        [data.amount, companyId]
      );
      await AuditModel.insertLog({ userId, action: 'RECORD_SUPPLIER_ADVANCE', entityType: 'supplier_advances', entityId: result.insertId, newValue: { companyId, amount: data.amount } }, conn);
      await conn.commit();
      return result.insertId;
    } catch (err) { await conn.rollback(); throw err; }
    finally { conn.release(); }
  },

  async recordStockReceipt(companyId, items, userId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();

      // Calculate total value
      let totalValue = 0;
      for (const item of items) {
        const [[product]] = await conn.query('SELECT units_per_carton FROM products WHERE id = ?', [item.product_id]);
        if (!product) throw new Error(`Product ID ${item.product_id} not found`);
        const units = parseInt(item.cartons) * product.units_per_carton + parseInt(item.loose_units || 0);
        item.line_value = units * parseFloat(item.unit_price);
        totalValue += item.line_value;
      }

      // Insert stock_receipts header
      const [receiptResult] = await conn.query(
        'INSERT INTO stock_receipts (company_id, receipt_date, total_value, note, recorded_by) VALUES (?, ?, ?, ?, ?)',
        [companyId, items[0].receipt_date || new Date().toISOString().slice(0,10), totalValue, items[0].note || null, userId]
      );
      const receiptId = receiptResult.insertId;

      // Insert items + add stock
      for (const item of items) {
        await conn.query(
          'INSERT INTO stock_receipt_items (receipt_id, product_id, cartons, loose_units, unit_price, line_value) VALUES (?, ?, ?, ?, ?, ?)',
          [receiptId, item.product_id, item.cartons, item.loose_units || 0, item.unit_price, item.line_value]
        );
        await StockService.addStock(item.product_id, parseInt(item.cartons), parseInt(item.loose_units || 0), 'receipt_supplier', receiptId, 'stock_receipts', null, userId, conn);
      }

      // Deduct from supplier advance balance
      await conn.query(
        'UPDATE supplier_companies SET current_advance_balance = current_advance_balance - ? WHERE id = ?',
        [totalValue, companyId]
      );

      await AuditModel.insertLog({ userId, action: 'RECORD_STOCK_RECEIPT', entityType: 'stock_receipts', entityId: receiptId, newValue: { companyId, totalValue } }, conn);
      await conn.commit();
      return receiptId;
    } catch (err) { await conn.rollback(); throw err; }
    finally { conn.release(); }
  },

  async getLedger(companyId) {
    const advances = await query(
      'SELECT \'advance\' AS type, payment_date AS date, amount, payment_method, note FROM supplier_advances WHERE company_id = ?',
      [companyId]
    );
    const receipts = await query(
      'SELECT \'receipt\' AS type, receipt_date AS date, total_value AS amount, NULL AS payment_method, note FROM stock_receipts WHERE company_id = ?',
      [companyId]
    );
    const claims = await query(
      'SELECT \'claim\' AS type, claim_date AS date, claim_value AS amount, status, reason AS note FROM claims WHERE company_id = ?',
      [companyId]
    );
    return [...advances, ...receipts, ...claims].sort((a, b) => new Date(b.date) - new Date(a.date));
  },

  async listClaims(companyId) {
    return query(
      `SELECT c.*, GROUP_CONCAT(p.name SEPARATOR ', ') AS products
       FROM claims c
       LEFT JOIN claim_items ci ON ci.claim_id = c.id
       LEFT JOIN products p ON p.id = ci.product_id
       WHERE c.company_id = ?
       GROUP BY c.id
       ORDER BY c.claim_date DESC`,
      [companyId]
    );
  },

  async addClaim(companyId, data, items, userId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();
      const [result] = await conn.query(
        'INSERT INTO claims (company_id, claim_date, reason, claim_value, recorded_by) VALUES (?, ?, ?, ?, ?)',
        [companyId, data.claim_date, data.reason, data.claim_value, userId]
      );
      for (const item of items) {
        await conn.query(
          'INSERT INTO claim_items (claim_id, product_id, cartons, loose_units) VALUES (?, ?, ?, ?)',
          [result.insertId, item.product_id, item.cartons || 0, item.loose_units || 0]
        );
      }
      // NO stock movement — claimed products never enter warehouse
      await AuditModel.insertLog({ userId, action: 'RECORD_CLAIM', entityType: 'claims', entityId: result.insertId }, conn);
      await conn.commit();
      return result.insertId;
    } catch (err) { await conn.rollback(); throw err; }
    finally { conn.release(); }
  },

  async markClaimCleared(claimId, userId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();
      const [[claim]] = await conn.query('SELECT * FROM claims WHERE id = ? FOR UPDATE', [claimId]);
      if (!claim) throw new Error('Claim not found');
      if (claim.status === 'cleared') throw new Error('Claim already cleared');

      await conn.query(
        'UPDATE claims SET status = \'cleared\', cleared_at = NOW() WHERE id = ?',
        [claimId]
      );
      await conn.query(
        'UPDATE supplier_companies SET current_advance_balance = current_advance_balance + ? WHERE id = ?',
        [claim.claim_value, claim.company_id]
      );
      await AuditModel.insertLog({ userId, action: 'CLEAR_CLAIM', entityType: 'claims', entityId: claimId, newValue: { claim_value: claim.claim_value } }, conn);
      await conn.commit();
    } catch (err) { await conn.rollback(); throw err; }
    finally { conn.release(); }
  },
};

module.exports = SupplierModel;
