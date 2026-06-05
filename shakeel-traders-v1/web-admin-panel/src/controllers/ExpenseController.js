'use strict';

const ExpenseModel = require('../models/ExpenseModel');
const UserModel = require('../models/UserModel');
const { renderWithLayout } = require('../utils/render');

const ExpenseController = {

  async index(req, res) {
    try {
      const { paginate } = require('../utils/paginate');
      const filters = {
        type: req.query.type || null,
        dateFrom: req.query.dateFrom || null,
        dateTo: req.query.dateTo || null,
        userId: req.query.userId || null,
      };

      const page = parseInt(req.query.page) || 1;
      const totalCount = await ExpenseModel.countAll(filters);
      const pagination = paginate(totalCount, page);

      const [expenses, users] = await Promise.all([
        ExpenseModel.listAll(filters, { limit: pagination.limit, offset: pagination.offset }),
        UserModel.listAll(),
      ]);

      // Calculate total
      const total = expenses.reduce((sum, e) => sum + parseFloat(e.amount), 0);
      const queryString = new URLSearchParams({ ...req.query, page: undefined }).toString();

      renderWithLayout(req, res, 'expenses/index', {
        title: 'Expenses Management',
        expenses,
        users,
        filters,
        total,
        pagination,
        queryString,
        expenseTypes: ['Fuel', 'Daily Allowance', 'Vehicle Maintenance', 'Office Expenses', 'Other'],
      });
    } catch (err) {
      console.error('Expense index error:', err);
      req.flash('error', 'Failed to load expenses.');
      res.redirect('/dashboard');
    }
  },

  async create(req, res) {
    try {
      const { expense_type, amount, expense_date, related_user_id, note } = req.body;

      if (!expense_type || !amount || !expense_date) {
        req.flash('error', 'Expense type, amount, and date are required.');
        return res.redirect('/expenses');
      }

      await ExpenseModel.create({
        expense_type,
        amount: parseFloat(amount),
        expense_date,
        related_user_id: related_user_id || null,
        note: note || null,
        recorded_by: req.session.user.id,
      });

      req.flash('success', 'Expense recorded successfully.');
      res.redirect('/expenses');
    } catch (err) {
      console.error('Create expense error:', err);
      req.flash('error', 'Failed to record expense: ' + err.message);
      res.redirect('/expenses');
    }
  },
};

module.exports = ExpenseController;
