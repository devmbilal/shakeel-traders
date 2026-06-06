'use strict';

const PayrollModel = require('../models/PayrollModel');
const { renderWithLayout } = require('../utils/render');

const SalaryModel = require('../models/SalaryModel');

const PayrollController = {
  
  // GET /payroll - List payroll records with salary advances tab
  async index(req, res) {
    try {
      const activeTab = req.query.tab || 'payroll';
      const staffTab = req.query.staff_tab || 'salesmen';
      const currentDate = new Date();
      const month = parseInt(req.query.month) || currentDate.getMonth() + 1;
      const year = parseInt(req.query.year) || currentDate.getFullYear();
      const paymentStatus = req.query.payment_status || '';

      let payrolls = [];
      let summary = { totalPayable: '0.00', totalPaid: '0.00', totalPending: '0.00' };
      let salesmen = [], orderBookers = [], deliveryMen = [];

      if (activeTab === 'payroll') {
        payrolls = await PayrollModel.listPayroll({
          month,
          year,
          payment_status: paymentStatus,
        });

        // Calculate summary
        let totalPayable = 0;
        let totalPaid = 0;
        let totalPending = 0;

        payrolls.forEach(p => {
          totalPayable += parseFloat(p.final_payable);
          if (p.payment_status === 'paid') {
            totalPaid += parseFloat(p.final_payable);
          } else {
            totalPending += parseFloat(p.final_payable);
          }
        });

        summary = {
          totalPayable: totalPayable.toFixed(2),
          totalPaid: totalPaid.toFixed(2),
          totalPending: totalPending.toFixed(2),
        };
      } else if (activeTab === 'advances') {
        // Load salary advances for all staff types
        [salesmen, orderBookers, deliveryMen] = await Promise.all([
          SalaryModel.listByStaffType('salesman'),
          SalaryModel.listByStaffType('order_booker'),
          SalaryModel.listByStaffType('delivery_man'),
        ]);
      }

      renderWithLayout(req, res, 'payroll/index', {
        title: 'HR & Payroll Management',
        activeTab,
        staff_tab: staffTab,
        payrolls,
        month,
        year,
        paymentStatus,
        summary,
        salesmen,
        orderBookers,
        deliveryMen,
        now: new Date(),
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load payroll.');
      res.redirect('/dashboard');
    }
  },

  // POST /payroll/generate - Generate monthly payroll
  async generate(req, res) {
    try {
      const { month, year } = req.body;
      
      if (!month || !year) {
        req.flash('error', 'Month and year are required.');
        return res.redirect('/payroll');
      }

      const results = await PayrollModel.generateMonthly(
        parseInt(month),
        parseInt(year),
        req.session.user.id
      );

      const created = results.filter(r => r.action === 'created').length;
      const updated = results.filter(r => r.action === 'updated').length;

      req.flash('success', `Payroll generated: ${created} new, ${updated} updated.`);
      res.redirect(`/payroll?month=${month}&year=${year}`);
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to generate payroll: ' + err.message);
      res.redirect('/payroll');
    }
  },

  // GET /payroll/:id - View payroll details
  async view(req, res) {
    try {
      const payroll = await PayrollModel.findById(req.params.id);
      
      if (!payroll) {
        req.flash('error', 'Payroll record not found.');
        return res.redirect('/payroll');
      }

      renderWithLayout(req, res, 'payroll/view', {
        title: `Payroll - ${payroll.staff_name}`,
        payroll,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load payroll details.');
      res.redirect('/payroll');
    }
  },

  // POST /payroll/:id/pay - Mark as paid
  async markPaid(req, res) {
    try {
      const { payment_method, payment_note } = req.body;
      
      if (!payment_method) {
        req.flash('error', 'Payment method is required.');
        return res.redirect(`/payroll/${req.params.id}`);
      }

      await PayrollModel.markPaid(
        req.params.id,
        { payment_method, payment_note },
        req.session.user.id
      );

      req.flash('success', 'Payroll marked as paid.');
      res.redirect(`/payroll/${req.params.id}`);
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to mark as paid.');
      res.redirect(`/payroll/${req.params.id}`);
    }
  },
};

module.exports = PayrollController;
