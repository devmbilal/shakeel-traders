'use strict';

const { query, getConnection } = require('../config/db');

const RouteModel = {
  async countAll() {
    const rows = await query('SELECT COUNT(*) AS total FROM routes');
    return rows[0].total;
  },

  async listAll({ limit = 25, offset = 0 } = {}) {
    return query(`
      SELECT r.*, COUNT(s.id) AS shop_count
      FROM routes r
      LEFT JOIN shops s ON s.route_id = r.id AND s.is_active = 1
      GROUP BY r.id
      ORDER BY r.name ASC
      LIMIT ? OFFSET ?
    `, [limit, offset]);
  },

  async findById(id) {
    const rows = await query('SELECT * FROM routes WHERE id = ? LIMIT 1', [id]);
    return rows[0] || null;
  },

  async create(name) {
    const result = await query('INSERT INTO routes (name) VALUES (?)', [name]);
    return result.insertId;
  },

  async update(id, name) {
    await query('UPDATE routes SET name = ? WHERE id = ?', [name, id]);
  },

  async deactivate(id) {
    await query('UPDATE routes SET is_active = 0 WHERE id = ?', [id]);
  },

  async getShopsInRoute(routeId) {
    return query(
      'SELECT id, name, owner_name, phone, shop_type, is_active FROM shops WHERE route_id = ? ORDER BY name ASC',
      [routeId]
    );
  },

  async getShopCount(routeId) {
    const rows = await query(
      'SELECT COUNT(*) AS cnt FROM shops WHERE route_id = ? AND is_active = 1',
      [routeId]
    );
    return rows[0].cnt;
  },

  // Shops not yet in this route (for the "add shop" dropdown)
  async getShopsNotInRoute(routeId) {
    return query(
      'SELECT id, name FROM shops WHERE (route_id != ? OR route_id IS NULL) AND is_active = 1 ORDER BY name ASC',
      [routeId]
    );
  },

  // Search shops not in this route by name or owner name
  async searchShopsNotInRoute(routeId, term) {
    const searchPattern = `%${term}%`;
    return query(
      'SELECT id, name, owner_name FROM shops WHERE (route_id != ? OR route_id IS NULL) AND is_active = 1 AND (name LIKE ? OR owner_name LIKE ?) ORDER BY name ASC LIMIT 20',
      [routeId, searchPattern, searchPattern]
    );
  },

  async addShopToRoute(routeId, shopId) {
    await query('UPDATE shops SET route_id = ? WHERE id = ?', [routeId, shopId]);
  },

  async removeShopFromRoute(routeId, shopId) {
    // Removing a shop from a route is not supported without a new route assignment.
    // Per schema, every shop must belong to exactly one route.
    // This operation is intentionally a no-op guard — callers should reassign instead.
    throw new Error('Shops cannot be removed from a route without being assigned to another route.');
  },

  async removeShopFromRouteById(routeId, shopId) {
    // Remove shop from route by setting route_id to NULL
    // This allows shops to be temporarily unassigned
    await query('UPDATE shops SET route_id = NULL WHERE id = ? AND route_id = ?', [shopId, routeId]);
  },

  // ── Route Assignments ──────────────────────────────────────────────────────

  async createAssignment(routeId, userId, date) {
    const result = await query(
      'INSERT INTO route_assignments (route_id, user_id, assignment_date) VALUES (?, ?, ?)',
      [routeId, userId, date]
    );
    return result.insertId;
  },

  async getAssignmentsByDate(date) {
    return query(`
      SELECT ra.*, r.name AS route_name, u.full_name AS booker_name
      FROM route_assignments ra
      JOIN routes r ON r.id = ra.route_id
      JOIN users  u ON u.id = ra.user_id
      WHERE ra.assignment_date = ?
      ORDER BY r.name ASC
    `, [date]);
  },

  async getAssignmentsByBooker(userId) {
    return query(`
      SELECT ra.*, r.name AS route_name, u.full_name AS booker_name
      FROM route_assignments ra
      JOIN routes r ON r.id = ra.route_id
      JOIN users  u ON u.id = ra.user_id
      WHERE ra.user_id = ?
      ORDER BY ra.assignment_date DESC, r.name ASC
    `, [userId]);
  },

  async findAssignmentById(id) {
    const rows = await query(`
      SELECT ra.*, r.name AS route_name, u.full_name AS booker_name
      FROM route_assignments ra
      JOIN routes r ON r.id = ra.route_id
      JOIN users  u ON u.id = ra.user_id
      WHERE ra.id = ?
      LIMIT 1
    `, [id]);
    return rows[0] || null;
  },

  async deleteAssignment(id) {
    await query('DELETE FROM route_assignments WHERE id = ?', [id]);
  },

  async updateAssignment(id, data) {
    const { route_id, user_id, assignment_date } = data;
    await query(
      'UPDATE route_assignments SET route_id = ?, user_id = ?, assignment_date = ? WHERE id = ?',
      [route_id, user_id, assignment_date, id]
    );
  },

  async countOrdersForAssignment(assignmentId) {
    const rows = await query(`
      SELECT COUNT(*) AS order_count
      FROM orders o
      JOIN route_assignments ra ON ra.id = ?
      WHERE o.route_id = ra.route_id
        AND o.booker_id = ra.user_id
        AND DATE(o.created_at) = ra.assignment_date
    `, [assignmentId]);
    return rows[0].order_count;
  },
};

module.exports = RouteModel;
