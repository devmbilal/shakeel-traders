'use strict';

const { query, getConnection } = require('../config/db');
const AuditModel = require('./AuditModel');

const SalaryModel = {
  async listByStaffType(staffType) {
    if (staffType === 'delivery_man') {
      return query(
        `SELECT dm.id, dm.full_name, dm.contact, dm.is_active, 'delivery_man' AS staff_type,
                sr.id AS record_id, sr.month, sr.year, sr.basic_salary, sr.total_advances_paid, sr.cleared_at
         FROM delivery_men dm
         LEFT JOIN salary_records sr ON sr.staff_id = dm.id AND sr.staff_type = 'delivery_man'
           AND sr.month = MONTH(CURDATE()) AND sr.year = YEAR(CURDATE())
         WHERE dm.is_active = 1
         ORDER BY dm.full_name ASC`
      );
    }
    return query(
      `SELECT u.id, u.full_name, u.contact, u.is_active, u.role AS staff_type,
              sr.id AS record_id, sr.month, sr.year, sr.basic_salary, sr.total_advances_paid, sr.cleared_at
       FROM users u
       LEFT JOIN salary_records sr ON sr.staff_id = u.id AND sr.staff_type = ?
         AND sr.month = MONTH(CURDATE()) AND sr.year = YEAR(CURDATE())
       WHERE u.role = ? AND u.is_active = 1
       ORDER BY u.full_name ASC`,
      [staffType, staffType]
    );
  },

  async recordBasicSalary(staffId, staffType, month, year, amount, adminId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();
      await conn.query(
        `INSERT INTO salary_records (staff_id, staff_type, month, year, basic_salary)
         VALUES (?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE basic_salary = VALUES(basic_salary)`,
        [staffId, staffType, month, year, amount]
      );
      await AuditModel.insertLog({ userId: adminId, action: 'RECORD_SALARY', entityType: 'salary_records', newValue: { staffId, staffType, month, year, amount } }, conn);
      await conn.commit();
    } catch (err) { await conn.rollback(); throw err; }
    finally { conn.release(); }
  },

  async recordAdvance(staffId, staffType, amount, date, note, adminId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();
      const month = new Date(date).getMonth() + 1;
      const year  = new Date(date).getFullYear();

      // Ensure salary record exists
      await conn.query(
        `INSERT IGNORE INTO salary_records (staff_id, staff_type, month, year, basic_salary) VALUES (?, ?, ?, ?, 0)`,
        [staffId, staffType, month, year]
      );

      const [result] = await conn.query(
        'INSERT INTO salary_advances (staff_id, staff_type, amount, advance_date, note, recorded_by) VALUES (?, ?, ?, ?, ?, ?)',
        [staffId, staffType, amount, date, note || null, adminId]
      );

      await conn.query(
        `UPDATE salary_records SET total_advances_paid = total_advances_paid + ?
         WHERE staff_id = ? AND staff_type = ? AND month = ? AND year = ?`,
        [amount, staffId, staffType, month, year]
      );

      await AuditModel.insertLog({ userId: adminId, action: 'RECORD_SALARY_ADVANCE', entityType: 'salary_advances', entityId: result.insertId }, conn);
      await conn.commit();
    } catch (err) { await conn.rollback(); throw err; }
    finally { conn.release(); }
  },

  async performClearance(staffId, staffType, month, year, adminId) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();
      await conn.query(
        `UPDATE salary_records SET cleared_at = NOW(), cleared_by = ?
         WHERE staff_id = ? AND staff_type = ? AND month = ? AND year = ?`,
        [adminId, staffId, staffType, month, year]
      );
      await AuditModel.insertLog({ userId: adminId, action: 'SALARY_CLEARANCE', entityType: 'salary_records', newValue: { staffId, staffType, month, year } }, conn);
      await conn.commit();
    } catch (err) { await conn.rollback(); throw err; }
    finally { conn.release(); }
  },

  async getAdvanceHistory(staffId, staffType) {
    return query(
      'SELECT * FROM salary_advances WHERE staff_id = ? AND staff_type = ? ORDER BY advance_date DESC',
      [staffId, staffType]
    );
  },

  async getLedger(staffId, staffType, page = 1, limit = 25) {
    const offset = (page - 1) * limit;
    
    // Get total count
    const [countResult] = await query(
      `SELECT COUNT(*) as total FROM (
        SELECT id FROM salary_records 
        WHERE staff_id = ? AND staff_type = ?
        UNION ALL
        SELECT id FROM salary_advances 
        WHERE staff_id = ? AND staff_type = ?
      ) AS combined`,
      [staffId, staffType, staffId, staffType]
    );
    
    const total = countResult.total;
    
    // Get paginated entries
    const entries = await query(
      `SELECT 'basic_salary' AS entry_type, month, year,
              CONCAT(year, '-', LPAD(month, 2, '0'), '-01') AS entry_date,
              basic_salary AS amount, NULL AS note
       FROM salary_records
       WHERE staff_id = ? AND staff_type = ?
       UNION ALL
       SELECT 'advance' AS entry_type, NULL AS month, NULL AS year, 
              advance_date AS entry_date, amount, note
       FROM salary_advances
       WHERE staff_id = ? AND staff_type = ?
       ORDER BY entry_date DESC
       LIMIT ? OFFSET ?`,
      [staffId, staffType, staffId, staffType, limit, offset]
    );
    
    return { entries, total, page, limit, pages: Math.ceil(total / limit) };
  },

  async getNetBalance(staffId, staffType) {
    const [result] = await query(
      `SELECT 
        COALESCE(SUM(basic_salary), 0) - COALESCE(SUM(total_advances_paid), 0) AS net_balance
       FROM salary_records
       WHERE staff_id = ? AND staff_type = ?`,
      [staffId, staffType]
    );
    return result && result.net_balance !== null ? result.net_balance : 0;
  },
};

module.exports = SalaryModel;
