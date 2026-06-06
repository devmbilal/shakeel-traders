'use strict';

const { query } = require('../config/db');

const HolidayModel = {
  
  // Get all holidays
  async listAll() {
    return query(
      `SELECT h.*, u.full_name AS created_by_name
       FROM holidays h
       JOIN users u ON u.id = h.created_by
       ORDER BY h.holiday_date DESC`
    );
  },

  // Get holidays for a specific year
  async listByYear(year) {
    return query(
      `SELECT h.*, u.full_name AS created_by_name
       FROM holidays h
       JOIN users u ON u.id = h.created_by
       WHERE YEAR(h.holiday_date) = ?
       ORDER BY h.holiday_date ASC`,
      [year]
    );
  },

  // Get holidays in a date range
  async listByDateRange(startDate, endDate) {
    return query(
      `SELECT * FROM holidays
       WHERE holiday_date BETWEEN ? AND ?
       ORDER BY holiday_date ASC`,
      [startDate, endDate]
    );
  },

  // Check if a date is a holiday
  async isHoliday(date) {
    const rows = await query(
      `SELECT id FROM holidays WHERE holiday_date = ? LIMIT 1`,
      [date]
    );
    return rows.length > 0;
  },

  // Create a new holiday
  async create(data, createdBy) {
    const result = await query(
      `INSERT INTO holidays (holiday_date, name, description, created_by)
       VALUES (?, ?, ?, ?)`,
      [data.holiday_date, data.name, data.description || null, createdBy]
    );
    return result.insertId;
  },

  // Update a holiday
  async update(id, data) {
    await query(
      `UPDATE holidays
       SET name = ?, description = ?
       WHERE id = ?`,
      [data.name, data.description || null, id]
    );
  },

  // Delete a holiday
  async delete(id) {
    await query(`DELETE FROM holidays WHERE id = ?`, [id]);
  },

  // Get holiday by ID
  async findById(id) {
    const rows = await query(`SELECT * FROM holidays WHERE id = ? LIMIT 1`, [id]);
    return rows[0] || null;
  },

  // Check if date already exists
  async existsByDate(date, excludeId = null) {
    let sql = `SELECT id FROM holidays WHERE holiday_date = ?`;
    const params = [date];
    
    if (excludeId) {
      sql += ` AND id != ?`;
      params.push(excludeId);
    }
    
    const rows = await query(sql, params);
    return rows.length > 0;
  },
};

module.exports = HolidayModel;
