'use strict';

const bcrypt = require('bcryptjs');
const { query } = require('../config/db');

const UserModel = {
  async countAll() {
    const rows = await query('SELECT COUNT(*) AS total FROM users WHERE is_active = 1');
    return rows[0].total;
  },

  async listAll({ limit = 25, offset = 0 } = {}) {
    return query(
      'SELECT id, full_name, username, role, contact, is_active FROM users WHERE is_active = 1 ORDER BY full_name ASC LIMIT ? OFFSET ?',
      [limit, offset]
    );
  },

  async countByRole(role) {
    const rows = await query('SELECT COUNT(*) AS total FROM users WHERE role = ?', [role]);
    return rows[0].total;
  },

  async listByRole(role, { limit = 25, offset = 0 } = {}) {
    return query(
      'SELECT id, full_name, username, contact, is_active, created_at FROM users WHERE role = ? ORDER BY full_name ASC LIMIT ? OFFSET ?',
      [role, limit, offset]
    );
  },

  async findById(id) {
    const rows = await query(
      'SELECT id, full_name, username, contact, role, is_active FROM users WHERE id = ? LIMIT 1',
      [id]
    );
    return rows[0] || null;
  },

  async create(data) {
    const hash = await bcrypt.hash(data.password, 10);
    const result = await query(
      'INSERT INTO users (full_name, username, password_hash, role, contact) VALUES (?, ?, ?, ?, ?)',
      [data.full_name, data.username, hash, data.role, data.contact || null]
    );
    return result.insertId;
  },

  async update(id, data) {
    const fields = ['full_name = ?', 'username = ?', 'contact = ?'];
    const params = [data.full_name, data.username, data.contact || null];

    if (data.password && data.password.trim() !== '') {
      fields.push('password_hash = ?');
      params.push(await bcrypt.hash(data.password, 10));
    }

    params.push(id);
    await query(`UPDATE users SET ${fields.join(', ')} WHERE id = ?`, params);
  },

  async deactivate(id) {
    await query('UPDATE users SET is_active = 0 WHERE id = ?', [id]);
  },
};

module.exports = UserModel;
