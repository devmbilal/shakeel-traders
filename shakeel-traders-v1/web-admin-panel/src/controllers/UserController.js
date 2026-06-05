'use strict';

const UserModel = require('../models/UserModel');
const { renderWithLayout } = require('../utils/render');

const UserController = {
  // GET /users
  async index(req, res) {
    try {
      const { paginate } = require('../utils/paginate');
      const activeTab = req.query.tab || 'order_bookers';
      const page = parseInt(req.query.page) || 1;
      
      const [obTotal, smTotal] = await Promise.all([
        UserModel.countByRole('order_booker'),
        UserModel.countByRole('salesman'),
      ]);
      
      const obPagination = paginate(obTotal, page);
      const smPagination = paginate(smTotal, page);
      
      const [orderBookers, salesmen] = await Promise.all([
        UserModel.listByRole('order_booker', { limit: obPagination.limit, offset: obPagination.offset }),
        UserModel.listByRole('salesman', { limit: smPagination.limit, offset: smPagination.offset }),
      ]);
      
      const queryString = new URLSearchParams({ ...req.query, page: undefined }).toString();
      
      renderWithLayout(req, res, 'users/index', {
        title: 'User Management',
        orderBookers,
        salesmen,
        activeTab,
        obPagination,
        smPagination,
        queryString,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load users.');
      res.redirect('/dashboard');
    }
  },

  // GET /users/new
  newForm(req, res) {
    const role = req.query.role || 'order_booker';
    renderWithLayout(req, res, 'users/form', {
      title: 'Add User',
      user: null,
      role,
      isEdit: false,
    });
  },

  // POST /users
  async create(req, res) {
    try {
      const { full_name, username, password, contact, role } = req.body;
      if (!password || password.trim() === '') {
        req.flash('error', 'Password is required when creating a new user.');
        return res.redirect(`/users/new?role=${role}`);
      }
      await UserModel.create({ full_name, username, password, contact, role });
      req.flash('success', `User "${full_name}" created successfully.`);
      res.redirect('/users?tab=' + (role === 'salesman' ? 'salesmen' : 'order_bookers'));
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        req.flash('error', 'Username already exists. Please choose a different username.');
      } else {
        req.flash('error', 'Failed to create user: ' + err.message);
      }
      res.redirect('/users/new?role=' + (req.body.role || 'order_booker'));
    }
  },

  // GET /users/:id/edit
  async editForm(req, res) {
    try {
      const user = await UserModel.findById(req.params.id);
      if (!user) {
        req.flash('error', 'User not found.');
        return res.redirect('/users');
      }
      renderWithLayout(req, res, 'users/form', {
        title: 'Edit User',
        user,
        role: user.role,
        isEdit: true,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load user.');
      res.redirect('/users');
    }
  },

  // POST /users/:id
  async update(req, res) {
    try {
      const user = await UserModel.findById(req.params.id);
      if (!user) {
        req.flash('error', 'User not found.');
        return res.redirect('/users');
      }
      const { full_name, username, password, contact } = req.body;
      await UserModel.update(req.params.id, { full_name, username, password, contact });
      req.flash('success', `User "${full_name}" updated successfully.`);
      res.redirect('/users?tab=' + (user.role === 'salesman' ? 'salesmen' : 'order_bookers'));
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        req.flash('error', 'Username already exists.');
      } else {
        req.flash('error', 'Failed to update user: ' + err.message);
      }
      res.redirect('/users/' + req.params.id + '/edit');
    }
  },

  // POST /users/:id/deactivate
  async deactivate(req, res) {
    try {
      const user = await UserModel.findById(req.params.id);
      if (!user) {
        req.flash('error', 'User not found.');
        return res.redirect('/users');
      }
      await UserModel.deactivate(req.params.id);
      req.flash('success', `User "${user.full_name}" has been deactivated.`);
      res.redirect('/users?tab=' + (user.role === 'salesman' ? 'salesmen' : 'order_bookers'));
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to deactivate user.');
      res.redirect('/users');
    }
  },
};

module.exports = UserController;
