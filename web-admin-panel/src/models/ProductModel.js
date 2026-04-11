'use strict';

const { query } = require('../config/db');

const ProductModel = {
  async countAll(filter = '') {
    const where = filter === 'active'   ? 'WHERE is_active = 1'
                : filter === 'inactive' ? 'WHERE is_active = 0'
                : '';
    const rows = await query(`SELECT COUNT(*) AS total FROM products ${where}`);
    return rows[0].total;
  },

  async listAll(filter = '', { limit = 25, offset = 0 } = {}) {
    const where = filter === 'active'   ? 'WHERE is_active = 1'
                : filter === 'inactive' ? 'WHERE is_active = 0'
                : '';
    return query(`SELECT * FROM products ${where} ORDER BY name ASC LIMIT ? OFFSET ?`, [limit, offset]);
  },

  async findById(id) {
    const rows = await query('SELECT * FROM products WHERE id = ? LIMIT 1', [id]);
    return rows[0] || null;
  },

  async findBySku(sku) {
    const rows = await query('SELECT * FROM products WHERE sku_code = ? LIMIT 1', [sku]);
    return rows[0] || null;
  },

  async create(data) {
    const result = await query(
      `INSERT INTO products
         (sku_code, name, brand, units_per_carton, retail_price, wholesale_price, low_stock_threshold)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [data.sku_code, data.name, data.brand || null, data.units_per_carton,
       data.retail_price, data.wholesale_price, data.low_stock_threshold || null]
    );
    return result.insertId;
  },

  async update(id, data) {
    await query(
      `UPDATE products SET
         sku_code = ?, name = ?, brand = ?, units_per_carton = ?,
         retail_price = ?, wholesale_price = ?, low_stock_threshold = ?
       WHERE id = ?`,
      [data.sku_code, data.name, data.brand || null, data.units_per_carton,
       data.retail_price, data.wholesale_price, data.low_stock_threshold || null, id]
    );
  },

  async deactivate(id) {
    await query('UPDATE products SET is_active = 0 WHERE id = ?', [id]);
  },

  async activate(id) {
    await query('UPDATE products SET is_active = 1 WHERE id = ?', [id]);
  },

  async getStockMovements(productId) {
    return query(
      `SELECT sm.*, u.full_name AS created_by_name
       FROM stock_movements sm
       JOIN users u ON u.id = sm.created_by
       WHERE sm.product_id = ?
       ORDER BY sm.created_at DESC
       LIMIT 100`,
      [productId]
    );
  },

  async searchActive(term) {
    const like = `%${term}%`;
    return query(
      `SELECT id, sku_code, name, brand, units_per_carton, retail_price, wholesale_price,
              current_stock_cartons, current_stock_loose
       FROM products
       WHERE is_active = 1 AND (name LIKE ? OR sku_code LIKE ?)
       ORDER BY name ASC LIMIT 50`,
      [like, like]
    );
  },
};

module.exports = ProductModel;
