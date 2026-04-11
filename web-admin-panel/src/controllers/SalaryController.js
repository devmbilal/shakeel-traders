'use strict';

const SalaryModel = require('../models/SalaryModel');
const { query } = require('../config/db');
const { renderWithLayout } = require('../utils/render');

const SalaryController = {

  async index(req, res) {
    try {
      const activeTab = req.query.tab || 'salesmen';
      const staffTypeMap = { salesmen: 'salesman', order_bookers: 'order_booker', delivery_men: 'delivery_man' };
      const staffType = staffTypeMap[activeTab] || 'salesman';

      const [salesmen, orderBookers, deliveryMen] = await Promise.all([
        SalaryModel.listByStaffType('salesman'),
        SalaryModel.listByStaffType('order_booker'),
        SalaryModel.listByStaffType('delivery_man'),
      ]);

      renderWithLayout(req, res, 'salaries/index', {
        title: 'Staff Salary Management',
        activeTab, salesmen, orderBookers, deliveryMen,
        now: new Date(),
      });
    } catch (err) {
      req.flash('error', 'Failed to load salaries.'); res.redirect('/dashboard');
    }
  },

  async recordSalary(req, res) {
    try {
      const { staff_id, staff_type, month, year, basic_salary } = req.body;
      await SalaryModel.recordBasicSalary(staff_id, staff_type, month, year, basic_salary, req.session.user.id);
      req.flash('success', 'Salary recorded.');
      res.redirect('/salaries?tab=' + (staff_type === 'salesman' ? 'salesmen' : staff_type === 'order_booker' ? 'order_bookers' : 'delivery_men'));
    } catch (err) { req.flash('error', err.message); res.redirect('/salaries'); }
  },

  async recordAdvance(req, res) {
    try {
      const { staff_id, staff_type, amount, advance_date, note } = req.body;
      await SalaryModel.recordAdvance(staff_id, staff_type, amount, advance_date, note, req.session.user.id);
      req.flash('success', 'Advance recorded.');
      res.redirect('/salaries?tab=' + (staff_type === 'salesman' ? 'salesmen' : staff_type === 'order_booker' ? 'order_bookers' : 'delivery_men'));
    } catch (err) { req.flash('error', err.message); res.redirect('/salaries'); }
  },

  async clearance(req, res) {
    try {
      const { staff_id, staff_type, month, year } = req.body;
      await SalaryModel.performClearance(staff_id, staff_type, month, year, req.session.user.id);
      req.flash('success', 'Month-end clearance performed.');
      res.redirect('/salaries?tab=' + (staff_type === 'salesman' ? 'salesmen' : staff_type === 'order_booker' ? 'order_bookers' : 'delivery_men'));
    } catch (err) { req.flash('error', err.message); res.redirect('/salaries'); }
  },

  async addDeliveryMan(req, res) {
    try {
      await query('INSERT INTO delivery_men (full_name, contact) VALUES (?, ?)', [req.body.full_name, req.body.contact || null]);
      req.flash('success', 'Delivery man added.');
      res.redirect('/salaries?tab=delivery_men');
    } catch (err) { req.flash('error', err.message); res.redirect('/salaries?tab=delivery_men'); }
  },

  async deactivateDeliveryMan(req, res) {
    try {
      await query('UPDATE delivery_men SET is_active = 0 WHERE id = ?', [req.params.id]);
      req.flash('success', 'Delivery man deactivated.');
      res.redirect('/salaries?tab=delivery_men');
    } catch (err) { req.flash('error', err.message); res.redirect('/salaries?tab=delivery_men'); }
  },

  async ledger(req, res) {
    try {
      const { staffType, staffId } = req.params;
      const page = parseInt(req.query.page) || 1;
      
      // Validate staffType
      const validTypes = ['salesman', 'order_booker', 'delivery_man'];
      if (!validTypes.includes(staffType)) {
        req.flash('error', 'Invalid staff type.');
        return res.redirect('/salaries');
      }
      
      // Fetch staff member name
      let staff;
      if (staffType === 'delivery_man') {
        [staff] = await query('SELECT id, full_name FROM delivery_men WHERE id = ?', [staffId]);
      } else {
        [staff] = await query('SELECT id, full_name FROM users WHERE id = ? AND role = ?', [staffId, staffType]);
      }
      
      if (!staff) {
        req.flash('error', 'Staff member not found.');
        return res.redirect('/salaries');
      }
      
      // Fetch ledger and net balance
      const ledgerData = await SalaryModel.getLedger(staffId, staffType, page, 25);
      const netBalance = await SalaryModel.getNetBalance(staffId, staffType);
      
      renderWithLayout(req, res, 'salaries/ledger', {
        title: `Salary Ledger - ${staff.full_name}`,
        staff: { ...staff, staffType },
        entries: ledgerData.entries,
        netBalance,
        pagination: {
          page: ledgerData.page,
          limit: ledgerData.limit,
          total: ledgerData.total,
          pages: ledgerData.pages
        }
      });
    } catch (err) {
      console.error('Ledger error:', err);
      req.flash('error', 'Failed to load ledger.');
      res.redirect('/salaries');
    }
  },

  async exportLedger(req, res) {
    try {
      const { staffType, staffId } = req.params;
      
      // Validate staffType
      const validTypes = ['salesman', 'order_booker', 'delivery_man'];
      if (!validTypes.includes(staffType)) {
        req.flash('error', 'Invalid staff type.');
        return res.redirect('/salaries');
      }
      
      // Fetch staff member name
      let staff;
      if (staffType === 'delivery_man') {
        [staff] = await query('SELECT id, full_name FROM delivery_men WHERE id = ?', [staffId]);
      } else {
        [staff] = await query('SELECT id, full_name FROM users WHERE id = ? AND role = ?', [staffId, staffType]);
      }
      
      if (!staff) {
        req.flash('error', 'Staff member not found.');
        return res.redirect('/salaries');
      }
      
      // Fetch all ledger entries (no pagination)
      const allEntries = await query(
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
         ORDER BY entry_date DESC`,
        [staffId, staffType, staffId, staffType]
      );
      
      const netBalance = await SalaryModel.getNetBalance(staffId, staffType);
      
      // Generate Excel using exceljs
      const ExcelJS = require('exceljs');
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet('Salary Ledger');
      
      // Add header
      worksheet.addRow([`Salary Ledger - ${staff.full_name}`]);
      worksheet.addRow([`Staff Type: ${staffType.replace('_', ' ')}`]);
      worksheet.addRow([`Net Balance: Rs ${Number(netBalance).toLocaleString()}`]);
      worksheet.addRow([]);
      
      // Add table headers
      const headerRow = worksheet.addRow(['Date', 'Entry Type', 'Amount', 'Note']);
      headerRow.font = { bold: true };
      
      // Add data rows
      allEntries.forEach(entry => {
        const entryType = entry.entry_type === 'basic_salary' 
          ? `Basic Salary (${entry.month}/${entry.year})` 
          : 'Advance';
        worksheet.addRow([
          new Date(entry.entry_date).toLocaleDateString('en-PK'),
          entryType,
          Number(entry.amount),
          entry.note || ''
        ]);
      });
      
      // Auto-fit columns
      worksheet.columns.forEach(column => {
        column.width = 20;
      });
      
      // Set response headers
      res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      res.setHeader('Content-Disposition', `attachment; filename=salary-ledger-${staff.full_name.replace(/\s+/g, '-')}.xlsx`);
      
      // Write to response
      await workbook.xlsx.write(res);
      res.end();
    } catch (err) {
      console.error('Export error:', err);
      req.flash('error', 'Failed to export ledger.');
      res.redirect('/salaries');
    }
  },
};

module.exports = SalaryController;
