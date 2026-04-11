'use strict';

const CashModel = require('../models/CashModel');
const { renderWithLayout } = require('../utils/render');
const { paginate } = require('../utils/paginate');

const CentralizedCashController = {

  async daily(req, res) {
    try {
      const date = req.query.date || new Date().toISOString().slice(0, 10);
      const entries = await CashModel.getDailyView(date);
      const totals = { salesman_sale: 0, recovery: 0, delivery_man_collection: 0 };
      entries.forEach(e => { totals[e.entry_type] = parseFloat(e.total); });
      totals.grand = totals.salesman_sale + totals.recovery + totals.delivery_man_collection;

      renderWithLayout(req, res, 'centralized-cash/index', {
        title: 'Centralized Cash Screen',
        view: 'daily', date, totals,
        monthlyData: [],
      });
    } catch (err) {
      req.flash('error', 'Failed to load cash screen.'); res.redirect('/dashboard');
    }
  },

  async monthly(req, res) {
    try {
      const now = new Date();
      const dateFrom = req.query.from || `${now.getFullYear()}-${String(now.getMonth()+1).padStart(2,'0')}-01`;
      const dateTo   = req.query.to   || now.toISOString().slice(0, 10);
      
      // Get all rows first
      const rows = await CashModel.getMonthlyView(dateFrom, dateTo);

      // Group by date
      const byDate = {};
      rows.forEach(r => {
        if (!byDate[r.cash_date]) byDate[r.cash_date] = { salesman_sale: 0, recovery: 0, delivery_man_collection: 0 };
        byDate[r.cash_date][r.entry_type] = parseFloat(r.total);
      });
      const allMonthlyData = Object.entries(byDate).map(([date, t]) => ({
        date, ...t, total: t.salesman_sale + t.recovery + t.delivery_man_collection
      }));

      // Pagination
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      const totalCount = allMonthlyData.length;
      const pagination = paginate(totalCount, page, limit);
      
      // Compute queryString for pagination links
      const queryString = new URLSearchParams({...req.query, page: undefined}).toString();
      
      // Slice the data for current page
      const monthlyData = allMonthlyData.slice(pagination.offset, pagination.offset + pagination.limit);

      renderWithLayout(req, res, 'centralized-cash/index', {
        title: 'Centralized Cash Screen',
        view: 'monthly', date: new Date().toISOString().slice(0,10),
        totals: { salesman_sale: 0, recovery: 0, delivery_man_collection: 0, grand: 0 },
        monthlyData, dateFrom, dateTo,
        pagination,
        queryString,
      });
    } catch (err) {
      req.flash('error', 'Failed to load monthly view.'); res.redirect('/centralized-cash');
    }
  },
};

module.exports = CentralizedCashController;

CentralizedCashController.data = async function(req, res) {
  try {
    const { query } = require('../config/db');
    const date = req.query.date || new Date().toISOString().slice(0, 10);
    const entries = await query(
      'SELECT entry_type, SUM(amount) AS total FROM centralized_cash_entries WHERE cash_date = ? GROUP BY entry_type',
      [date]
    );
    const totals = { salesman_sale: 0, recovery: 0, delivery_man_collection: 0 };
    entries.forEach(e => { totals[e.entry_type] = parseFloat(e.total); });
    totals.grand = totals.salesman_sale + totals.recovery + totals.delivery_man_collection;
    res.json(totals);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
