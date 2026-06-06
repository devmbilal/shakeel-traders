'use strict';

const AttendanceModel = require('../models/AttendanceModel');
const HolidayModel = require('../models/HolidayModel');
const { renderWithLayout } = require('../utils/render');
const { getPakistanDateString } = require('../utils/dateHelpers');

const AttendanceController = {
  
  // GET /attendance - Mark attendance for today or selected date
  async index(req, res) {
    try {
      const selectedDate = req.query.date || getPakistanDateString();
      
      // Check if it's a holiday
      const isHoliday = await HolidayModel.isHoliday(selectedDate);
      
      // Check if it's Friday
      const date = new Date(selectedDate);
      const isFriday = date.getDay() === 5;
      
      // Get all staff with their attendance status for this date
      const staff = await AttendanceModel.getAllStaffWithAttendance(selectedDate);
      
      renderWithLayout(req, res, 'attendance/index', {
        title: 'Mark Attendance',
        selectedDate,
        staff,
        isHoliday,
        isFriday,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load attendance page.');
      res.redirect('/dashboard');
    }
  },

  // POST /attendance/mark - Mark/update attendance (bulk)
  async markAttendance(req, res) {
    try {
      const { attendance_date, attendance } = req.body;
      
      if (!attendance_date || !attendance) {
        req.flash('error', 'Please provide attendance data.');
        return res.redirect('/attendance?date=' + attendance_date);
      }

      // Parse attendance data (format: {staff_type_staff_id: status, ...})
      // Example keys: "order_booker_10", "salesman_5", "delivery_man_3"
      const attendanceRecords = [];
      
      for (const key in attendance) {
        const status = attendance[key];
        
        if (status) {
          // Split from the last underscore to handle staff_types with underscores
          const lastUnderscoreIndex = key.lastIndexOf('_');
          const staff_type = key.substring(0, lastUnderscoreIndex);
          const staff_id = key.substring(lastUnderscoreIndex + 1);
          
          attendanceRecords.push({
            staff_id: parseInt(staff_id),
            staff_type,
            attendance_date,
            status,
            note: null,
          });
        }
      }

      if (attendanceRecords.length === 0) {
        req.flash('error', 'No attendance records to save.');
        return res.redirect('/attendance?date=' + attendance_date);
      }

      await AttendanceModel.bulkMark(attendanceRecords, req.session.user.id);
      
      req.flash('success', `Attendance marked for ${attendanceRecords.length} staff members on ${attendance_date}.`);
      res.redirect('/attendance?date=' + attendance_date);
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to mark attendance: ' + err.message);
      res.redirect('/attendance');
    }
  },

  // GET /attendance/report - Attendance report
  async report(req, res) {
    try {
      const currentDate = new Date();
      const month = parseInt(req.query.month) || currentDate.getMonth() + 1;
      const year = parseInt(req.query.year) || currentDate.getFullYear();
      const staffFilter = req.query.staff_id || '';
      const staffTypeFilter = req.query.staff_type || '';

      // Get all active staff
      const allStaff = await AttendanceModel.getAllStaffWithAttendance(getPakistanDateString());
      
      // Get attendance for the month
      const startDate = `${year}-${String(month).padStart(2, '0')}-01`;
      // Get last day of month (day 0 of next month = last day of current month)
      const lastDay = new Date(year, month, 0).getDate();
      const endDate = `${year}-${String(month).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`;
      
      let reportData = [];
      
      for (const staff of allStaff) {
        // Apply filters
        if (staffFilter && staff.id != staffFilter) continue;
        if (staffTypeFilter && staff.staff_type != staffTypeFilter) continue;
        
        const summary = await AttendanceModel.getMonthlySummary(
          staff.id,
          staff.staff_type,
          month,
          year
        );
        
        const totalDays = new Date(year, month, 0).getDate();
        
        // Calculate Fridays in the month (automatic off days)
        let fridaysCount = 0;
        for (let day = 1; day <= totalDays; day++) {
          const date = new Date(year, month - 1, day);
          if (date.getDay() === 5) { // Friday is day 5
            fridaysCount++;
          }
        }
        
        const offDays = fridaysCount; // Fridays are automatic off days
        const holidayDays = summary.holiday_days || 0;
        const workingDays = totalDays - offDays - holidayDays;
        
        // Auto-present logic: Present = Working Days - Absent
        // If no attendance is marked, all working days count as present
        const presentDays = workingDays - (summary.absent_days || 0);
        
        const attendancePercentage = workingDays > 0 
          ? ((presentDays / workingDays) * 100).toFixed(1)
          : 0;
        
        reportData.push({
          staff_id: staff.id,
          staff_name: staff.full_name,
          staff_type: staff.staff_type,
          total_days: totalDays,
          working_days: workingDays,
          present_days: presentDays,
          absent_days: summary.absent_days || 0,
          holiday_days: holidayDays,
          off_days: offDays,
          attendance_percentage: attendancePercentage,
        });
      }

      renderWithLayout(req, res, 'attendance/report', {
        title: 'Attendance Report',
        month,
        year,
        reportData,
        allStaff,
        staffFilter,
        staffTypeFilter,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to generate report.');
      res.redirect('/attendance');
    }
  },

  // GET /attendance/staff/:id/:type - Individual staff attendance history
  async staffAttendance(req, res) {
    try {
      const staffId = req.params.id;
      const staffType = req.params.type;
      
      const currentDate = new Date();
      const month = parseInt(req.query.month) || currentDate.getMonth() + 1;
      const year = parseInt(req.query.year) || currentDate.getFullYear();

      const startDate = `${year}-${String(month).padStart(2, '0')}-01`;
      // Get last day of month (day 0 of next month = last day of current month)
      const lastDay = new Date(year, month, 0).getDate();
      const endDate = `${year}-${String(month).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`;

      const attendance = await AttendanceModel.getByStaffAndRange(
        staffId,
        staffType,
        startDate,
        endDate
      );

      const summary = await AttendanceModel.getMonthlySummary(
        staffId,
        staffType,
        month,
        year
      );

      // Calculate total days and Fridays (auto off days)
      const totalDays = new Date(year, month, 0).getDate();
      let fridaysCount = 0;
      for (let day = 1; day <= totalDays; day++) {
        const date = new Date(year, month - 1, day);
        if (date.getDay() === 5) { // Friday is day 5
          fridaysCount++;
        }
      }

      // Apply auto-present logic
      const offDays = fridaysCount;
      const holidayDays = summary.holiday_days || 0;
      const absentDays = summary.absent_days || 0;
      const workingDays = totalDays - offDays - holidayDays;
      const presentDays = workingDays - absentDays; // Auto-present: present = working - absent

      // Override summary with calculated values
      const calculatedSummary = {
        total_days: totalDays,
        present_days: presentDays,
        absent_days: absentDays,
        holiday_days: holidayDays,
        off_days: offDays,
      };

      // Get staff name
      let staffName = 'Unknown';
      if (staffType === 'delivery_man') {
        const { query } = require('../config/db');
        const rows = await query('SELECT full_name FROM delivery_men WHERE id = ?', [staffId]);
        staffName = rows[0]?.full_name || 'Unknown';
      } else {
        const { query } = require('../config/db');
        const rows = await query('SELECT full_name FROM users WHERE id = ?', [staffId]);
        staffName = rows[0]?.full_name || 'Unknown';
      }

      renderWithLayout(req, res, 'attendance/staff', {
        title: `${staffName} - Attendance`,
        staffId,
        staffType,
        staffName,
        month,
        year,
        attendance,
        summary: calculatedSummary,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load staff attendance.');
      res.redirect('/attendance/report');
    }
  },
};

module.exports = AttendanceController;
