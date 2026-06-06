'use strict';

const { query, getConnection } = require('../config/db');

const AttendanceModel = {
  
  // Get attendance for a specific date
  async getByDate(date) {
    return query(
      `SELECT a.*, 
              CASE 
                WHEN a.staff_type = 'delivery_man' THEN d.full_name
                ELSE u.full_name
              END AS staff_name,
              CASE 
                WHEN a.staff_type = 'delivery_man' THEN d.contact
                ELSE u.contact
              END AS staff_contact
       FROM attendance a
       LEFT JOIN users u ON a.staff_id = u.id AND a.staff_type IN ('admin', 'order_booker', 'salesman')
       LEFT JOIN delivery_men d ON a.staff_id = d.id AND a.staff_type = 'delivery_man'
       WHERE a.attendance_date = ?
       ORDER BY staff_name ASC`,
      [date]
    );
  },

  // Get attendance for a staff member in a date range
  async getByStaffAndRange(staffId, staffType, startDate, endDate) {
    return query(
      `SELECT * FROM attendance
       WHERE staff_id = ? AND staff_type = ? 
         AND attendance_date BETWEEN ? AND ?
       ORDER BY attendance_date ASC`,
      [staffId, staffType, startDate, endDate]
    );
  },

  // Mark attendance for a specific date
  async mark(data, markedBy) {
    const { staff_id, staff_type, attendance_date, status, note } = data;
    
    // Check if already exists
    const existing = await query(
      `SELECT id FROM attendance 
       WHERE staff_id = ? AND staff_type = ? AND attendance_date = ?`,
      [staff_id, staff_type, attendance_date]
    );

    if (existing.length > 0) {
      // Update existing
      await query(
        `UPDATE attendance 
         SET status = ?, marked_by = ?, note = ?, updated_at = NOW()
         WHERE id = ?`,
        [status, markedBy, note || null, existing[0].id]
      );
      return existing[0].id;
    } else {
      // Insert new
      const result = await query(
        `INSERT INTO attendance 
         (staff_id, staff_type, attendance_date, status, marked_by, note)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [staff_id, staff_type, attendance_date, status, markedBy, note || null]
      );
      return result.insertId;
    }
  },

  // Bulk mark attendance for all staff on a date
  async bulkMark(attendanceData, markedBy) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();

      for (const record of attendanceData) {
        const { staff_id, staff_type, attendance_date, status, note } = record;
        
        // Use ON DUPLICATE KEY UPDATE
        await conn.query(
          `INSERT INTO attendance 
           (staff_id, staff_type, attendance_date, status, marked_by, note)
           VALUES (?, ?, ?, ?, ?, ?)
           ON DUPLICATE KEY UPDATE 
             status = VALUES(status),
             marked_by = VALUES(marked_by),
             note = VALUES(note),
             updated_at = NOW()`,
          [staff_id, staff_type, attendance_date, status, markedBy, note || null]
        );
      }

      await conn.commit();
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  },

  // Get attendance summary for a month
  async getMonthlySummary(staffId, staffType, month, year) {
    const rows = await query(
      `SELECT 
         COUNT(*) as total_days,
         SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present_days,
         SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) as absent_days,
         SUM(CASE WHEN status = 'holiday' THEN 1 ELSE 0 END) as holiday_days,
         SUM(CASE WHEN status = 'off' THEN 1 ELSE 0 END) as off_days
       FROM attendance
       WHERE staff_id = ? AND staff_type = ? 
         AND MONTH(attendance_date) = ? AND YEAR(attendance_date) = ?`,
      [staffId, staffType, month, year]
    );
    return rows[0];
  },

  // Get all staff list with their attendance status for a date
  async getAllStaffWithAttendance(date) {
    // First get all active users who are enabled for payroll (controlled by admin)
    const users = await query(
      `SELECT id, full_name, role as staff_type, contact, base_salary
       FROM users
       WHERE is_active = 1 AND enable_payroll = 1
       ORDER BY full_name ASC`
    );

    // Then get all active delivery men
    const deliveryMen = await query(
      `SELECT id, full_name, 'delivery_man' as staff_type, contact, base_salary
       FROM delivery_men
       WHERE is_active = 1 AND enable_payroll = 1
       ORDER BY full_name ASC`
    );

    // Combine both lists
    const allStaff = [...users, ...deliveryMen];

    // Get attendance records for this date
    const attendanceRecords = await query(
      `SELECT staff_id, staff_type, status, note
       FROM attendance
       WHERE attendance_date = ?`,
      [date]
    );

    // Create a map for quick lookup
    const attendanceMap = {};
    attendanceRecords.forEach(record => {
      const key = `${record.staff_type}_${record.staff_id}`;
      attendanceMap[key] = record;
    });

    // Merge staff with attendance
    return allStaff.map(staff => {
      const key = `${staff.staff_type}_${staff.id}`;
      const attendance = attendanceMap[key];
      
      return {
        ...staff,
        attendance_status: attendance ? attendance.status : null,
        attendance_note: attendance ? attendance.note : null,
      };
    });
  },
};

module.exports = AttendanceModel;
