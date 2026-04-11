'use strict';

const { query } = require('../config/db');

const AuditModel = {
  /**
   * Insert an audit log entry.
   * This table is APPEND ONLY — never UPDATE or DELETE.
   *
   * @param {object} data
   * @param {number} data.userId
   * @param {string} data.action       e.g. 'APPROVE_ISSUANCE', 'CONVERT_ORDER_TO_BILL'
   * @param {string} data.entityType   e.g. 'salesman_issuances', 'bills'
   * @param {number} [data.entityId]
   * @param {object} [data.oldValue]   State before action (JSON)
   * @param {object} [data.newValue]   State after action (JSON)
   * @param {string} [data.ipAddress]
   * @param {object} [conn]            Optional transaction connection
   */
  async insertLog(data, conn = null) {
    const sql = `
      INSERT INTO audit_log
        (user_id, action, entity_type, entity_id, old_value, new_value, ip_address)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.userId,
      data.action,
      data.entityType,
      data.entityId || null,
      data.oldValue ? JSON.stringify(data.oldValue) : null,
      data.newValue ? JSON.stringify(data.newValue) : null,
      data.ipAddress || null,
    ];

    if (conn) {
      await conn.query(sql, params);
    } else {
      await query(sql, params);
    }
  },

  /**
   * List audit log entries with optional filters.
   */
  async list({ userId, entityType, dateFrom, dateTo, page = 1, limit = 50 } = {}) {
    const conditions = [];
    const params = [];

    if (userId) {
      conditions.push('al.user_id = ?');
      params.push(userId);
    }
    if (entityType) {
      conditions.push('al.entity_type = ?');
      params.push(entityType);
    }
    if (dateFrom) {
      conditions.push('DATE(al.created_at) >= ?');
      params.push(dateFrom);
    }
    if (dateTo) {
      conditions.push('DATE(al.created_at) <= ?');
      params.push(dateTo);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const offset = (page - 1) * limit;

    const rows = await query(
      `SELECT al.*, u.full_name AS user_name, u.username
       FROM audit_log al
       JOIN users u ON u.id = al.user_id
       ${where}
       ORDER BY al.created_at DESC
       LIMIT ? OFFSET ?`,
      [...params, limit, offset]
    );

    const [countRow] = await query(
      `SELECT COUNT(*) AS total FROM audit_log al ${where}`,
      params
    );

    return { rows, total: countRow.total, page, limit };
  },
};

module.exports = AuditModel;
