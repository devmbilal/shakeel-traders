'use strict';

const { query, getConnection } = require('../config/db');

const PayrollModel = {
  
  // Generate payroll for a specific month
  async generateMonthly(month, year, generatedBy) {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();

      // Get all active staff who are enabled for payroll (controlled by admin)
      const users = await conn.query(
        `SELECT id, full_name, role as staff_type, base_salary
         FROM users
         WHERE is_active = 1 AND base_salary IS NOT NULL AND enable_payroll = 1`
      );

      const deliveryMen = await conn.query(
        `SELECT id, full_name, 'delivery_man' as staff_type, base_salary
         FROM delivery_men
         WHERE is_active = 1 AND base_salary IS NOT NULL AND enable_payroll = 1`
      );

      const allStaff = [...users[0], ...deliveryMen[0]];

      const results = [];

      for (const staff of allStaff) {
        // Calculate working days, present, absent etc.
        const payrollData = await PayrollModel._calculatePayroll(
          conn,
          staff.id,
          staff.staff_type,
          month,
          year,
          staff.base_salary
        );

        // Check if payroll already exists
        const [existing] = await conn.query(
          `SELECT id FROM payroll_records
           WHERE staff_id = ? AND staff_type = ? AND month = ? AND year = ?`,
          [staff.id, staff.staff_type, month, year]
        );

        if (existing.length > 0) {
          // Update existing
          await conn.query(
            `UPDATE payroll_records
             SET base_salary = ?, working_days = ?, present_days = ?,
                 absent_days = ?, holiday_days = ?, off_days = ?,
                 per_day_salary = ?, absence_deduction = ?,
                 net_salary = ?, advances_paid = ?, final_payable = ?,
                 generated_by = ?, generated_at = NOW()
             WHERE id = ?`,
            [
              payrollData.base_salary,
              payrollData.working_days,
              payrollData.present_days,
              payrollData.absent_days,
              payrollData.holiday_days,
              payrollData.off_days,
              payrollData.per_day_salary,
              payrollData.absence_deduction,
              payrollData.net_salary,
              payrollData.advances_paid,
              payrollData.final_payable,
              generatedBy,
              existing[0].id,
            ]
          );
          results.push({ staff_id: staff.id, staff_name: staff.full_name, action: 'updated' });
        } else {
          // Insert new
          await conn.query(
            `INSERT INTO payroll_records
             (staff_id, staff_type, month, year, base_salary, working_days,
              present_days, absent_days, holiday_days, off_days, per_day_salary,
              absence_deduction, net_salary, advances_paid, final_payable, generated_by)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
              staff.id,
              staff.staff_type,
              month,
              year,
              payrollData.base_salary,
              payrollData.working_days,
              payrollData.present_days,
              payrollData.absent_days,
              payrollData.holiday_days,
              payrollData.off_days,
              payrollData.per_day_salary,
              payrollData.absence_deduction,
              payrollData.net_salary,
              payrollData.advances_paid,
              payrollData.final_payable,
              generatedBy,
            ]
          );
          results.push({ staff_id: staff.id, staff_name: staff.full_name, action: 'created' });
        }
      }

      await conn.commit();
      return results;
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  },

  // Calculate payroll details for a staff member
  async _calculatePayroll(conn, staffId, staffType, month, year, baseSalary) {
    // Get attendance summary
    const [[attendance]] = await conn.query(
      `SELECT 
         SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present_days,
         SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) as absent_days,
         SUM(CASE WHEN status = 'holiday' THEN 1 ELSE 0 END) as holiday_days,
         SUM(CASE WHEN status = 'off' THEN 1 ELSE 0 END) as off_days,
         COUNT(*) as marked_days
       FROM attendance
       WHERE staff_id = ? AND staff_type = ? 
         AND MONTH(attendance_date) = ? AND YEAR(attendance_date) = ?`,
      [staffId, staffType, month, year]
    );

    let presentDays = parseInt(attendance?.present_days) || 0;
    let absentDays = parseInt(attendance?.absent_days) || 0;
    const holidayDays = parseInt(attendance?.holiday_days) || 0;
    let offDays = parseInt(attendance?.off_days) || 0;
    const markedDays = parseInt(attendance?.marked_days) || 0;

    // Total days in month
    const totalDaysInMonth = new Date(year, month, 0).getDate();
    
    // Count Fridays in the month (weekly off)
    let fridaysCount = 0;
    for (let day = 1; day <= totalDaysInMonth; day++) {
      const date = new Date(year, month - 1, day);
      if (date.getDay() === 5) { // 5 = Friday
        fridaysCount++;
      }
    }
    
    // Fridays are automatic offs - add to off_days if not already counted
    offDays = fridaysCount;
    
    // Working days = Total days - Fridays - Holidays
    const workingDays = totalDaysInMonth - offDays - holidayDays;

    // Calculate unmarked days (days with no attendance record)
    const unmarkedDays = totalDaysInMonth - markedDays;
    
    // AUTO-MARK UNMARKED DAYS AS PRESENT
    // If admin didn't mark attendance, assume staff was present
    presentDays = presentDays + unmarkedDays;
    
    // IMPORTANT: Don't count Friday absences
    // If someone is marked absent on Friday, it doesn't affect salary
    // because Fridays are non-working days anyway
    // Only deduct for absences on actual working days
    
    // Recalculate absent days: exclude any that fall on Fridays or Holidays
    const [[actualAbsences]] = await conn.query(
      `SELECT COUNT(*) as actual_absent_days
       FROM attendance
       WHERE staff_id = ? AND staff_type = ? 
         AND MONTH(attendance_date) = ? AND YEAR(attendance_date) = ?
         AND status = 'absent'
         AND DAYOFWEEK(attendance_date) != 6  /* Exclude Fridays (6 in MySQL) */
         AND attendance_date NOT IN (
           SELECT holiday_date FROM holidays WHERE YEAR(holiday_date) = ?
         )`,
      [staffId, staffType, month, year, year]
    );
    
    absentDays = parseInt(actualAbsences?.actual_absent_days) || 0;

    // Per day salary
    const perDaySalary = workingDays > 0 ? parseFloat((baseSalary / workingDays).toFixed(2)) : 0;

    // Absence deduction (only for working day absences)
    const absenceDeduction = parseFloat((absentDays * perDaySalary).toFixed(2));

    // Net salary after deduction
    const netSalary = parseFloat((baseSalary - absenceDeduction).toFixed(2));

    // Get advances paid during this month
    const [[advances]] = await conn.query(
      `SELECT COALESCE(SUM(amount), 0) as total_advances
       FROM salary_advances
       WHERE staff_id = ? AND staff_type = ? 
         AND MONTH(advance_date) = ? AND YEAR(advance_date) = ?`,
      [staffId, staffType, month, year]
    );

    const advancesPaid = parseFloat(advances?.total_advances) || 0;

    // Final payable
    const finalPayable = parseFloat((netSalary - advancesPaid).toFixed(2));

    return {
      base_salary: baseSalary,
      working_days: workingDays,
      present_days: presentDays,
      absent_days: absentDays,
      holiday_days: holidayDays,
      off_days: offDays,
      per_day_salary: perDaySalary,
      absence_deduction: absenceDeduction,
      net_salary: netSalary,
      advances_paid: advancesPaid,
      final_payable: finalPayable,
    };
  },

  // List payroll records
  async listPayroll(filters = {}) {
    const conditions = [];
    const params = [];

    if (filters.month) { conditions.push('pr.month = ?'); params.push(filters.month); }
    if (filters.year) { conditions.push('pr.year = ?'); params.push(filters.year); }
    if (filters.payment_status) { conditions.push('pr.payment_status = ?'); params.push(filters.payment_status); }

    const where = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    return query(
      `SELECT pr.*,
              CASE 
                WHEN pr.staff_type = 'delivery_man' THEN d.full_name
                ELSE u.full_name
              END AS staff_name
       FROM payroll_records pr
       LEFT JOIN users u ON pr.staff_id = u.id AND pr.staff_type IN ('admin', 'order_booker', 'salesman')
       LEFT JOIN delivery_men d ON pr.staff_id = d.id AND pr.staff_type = 'delivery_man'
       ${where}
       ORDER BY pr.year DESC, pr.month DESC, staff_name ASC`,
      params
    );
  },

  // Mark payroll as paid
  async markPaid(id, paymentData, paidBy) {
    await query(
      `UPDATE payroll_records
       SET payment_status = 'paid',
           paid_at = NOW(),
           paid_by = ?,
           payment_method = ?,
           payment_note = ?
       WHERE id = ?`,
      [paidBy, paymentData.payment_method, paymentData.payment_note || null, id]
    );
  },

  // Get payroll by ID
  async findById(id) {
    const rows = await query(
      `SELECT pr.*,
              CASE 
                WHEN pr.staff_type = 'delivery_man' THEN d.full_name
                ELSE u.full_name
              END AS staff_name
       FROM payroll_records pr
       LEFT JOIN users u ON pr.staff_id = u.id AND pr.staff_type IN ('admin', 'order_booker', 'salesman')
       LEFT JOIN delivery_men d ON pr.staff_id = d.id AND pr.staff_type = 'delivery_man'
       WHERE pr.id = ? LIMIT 1`,
      [id]
    );
    return rows[0] || null;
  },
};

module.exports = PayrollModel;
