'use strict';

const { query } = require('../config/db');

const ExpenseModel = {
  async countAll(filters = {}) {
    let sql = `
      SELECT COUNT(*) AS total
      FROM expenses e
      WHERE 1=1
    `;
    const params = [];

    if (filters.type) {
      sql += ' AND e.expense_type = ?';
      params.push(filters.type);
    }

    if (filters.dateFrom) {
      sql += ' AND e.expense_date >= ?';
      params.push(filters.dateFrom);
    }

    if (filters.dateTo) {
      sql += ' AND e.expense_date <= ?';
      params.push(filters.dateTo);
    }

    if (filters.userId) {
      sql += ' AND e.related_user_id = ?';
      params.push(filters.userId);
    }

    const rows = await query(sql, params);
    return rows[0].total;
  },

  async listAll(filters = {}, { limit = 25, offset = 0 } = {}) {
    let sql = `
      SELECT e.*, u.full_name AS related_user_name
      FROM expenses e
      LEFT JOIN users u ON u.id = e.related_user_id
      WHERE 1=1
    `;
    const params = [];

    if (filters.type) {
      sql += ' AND e.expense_type = ?';
      params.push(filters.type);
    }

    if (filters.dateFrom) {
      sql += ' AND e.expense_date >= ?';
      params.push(filters.dateFrom);
    }

    if (filters.dateTo) {
      sql += ' AND e.expense_date <= ?';
      params.push(filters.dateTo);
    }

    if (filters.userId) {
      sql += ' AND e.related_user_id = ?';
      params.push(filters.userId);
    }

    sql += ' ORDER BY e.expense_date DESC, e.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return query(sql, params);
  },

  async create(data) {
    const result = await query(
      `INSERT INTO expenses (expense_type, amount, expense_date, related_user_id, note, recorded_by)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        data.expense_type,
        data.amount,
        data.expense_date,
        data.related_user_id || null,
        data.note || null,
        data.recorded_by
      ]
    );
    return result.insertId;
  },

  async getTotalByType(dateFrom, dateTo) {
    return query(
      `SELECT expense_type, SUM(amount) AS total
       FROM expenses
       WHERE expense_date BETWEEN ? AND ?
       GROUP BY expense_type
       ORDER BY total DESC`,
      [dateFrom, dateTo]
    );
  },
};

module.exports = ExpenseModel;
