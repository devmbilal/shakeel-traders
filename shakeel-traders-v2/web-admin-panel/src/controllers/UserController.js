'use strict';

const UserModel = require('../models/UserModel');
const { renderWithLayout } = require('../utils/render');

const UserController = {
  // GET /users
  async index(req, res) {
    try {
      const { query } = require('../config/db');
      const { paginate } = require('../utils/paginate');
      const activeTab = req.query.tab || 'order_bookers';
      const page = parseInt(req.query.page) || 1;
      
      const [obTotal, smTotal, dmTotal] = await Promise.all([
        UserModel.countByRole('order_booker'),
        UserModel.countByRole('salesman'),
        query('SELECT COUNT(*) as count FROM delivery_men').then(r => r[0].count),
      ]);
      
      const obPagination = paginate(obTotal, page);
      const smPagination = paginate(smTotal, page);
      const dmPagination = paginate(dmTotal, page);
      
      const [orderBookers, salesmen, deliveryMen] = await Promise.all([
        UserModel.listByRole('order_booker', { limit: obPagination.limit, offset: obPagination.offset }),
        UserModel.listByRole('salesman', { limit: smPagination.limit, offset: smPagination.offset }),
        query('SELECT * FROM delivery_men ORDER BY full_name ASC LIMIT ? OFFSET ?', 
              [dmPagination.limit, dmPagination.offset]),
      ]);
      
      // Create queryString without page parameter
      const params = { ...req.query };
      delete params.page;
      const queryString = new URLSearchParams(params).toString();
      
      renderWithLayout(req, res, 'users/index', {
        title: 'User Management',
        orderBookers,
        salesmen,
        deliveryMen,
        activeTab,
        obPagination,
        smPagination,
        dmPagination,
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
      const { full_name, username, password, contact, role, base_salary, enable_payroll } = req.body;
      if (!password || password.trim() === '') {
        req.flash('error', 'Password is required when creating a new user.');
        return res.redirect(`/users/new?role=${role}`);
      }
      await UserModel.create({ 
        full_name, username, password, contact, role, 
        base_salary: base_salary || null,
        enable_payroll: enable_payroll === '1' ? 1 : 0
      });
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
      const { full_name, username, password, contact, base_salary, enable_payroll } = req.body;
      await UserModel.update(req.params.id, { 
        full_name, username, password, contact, 
        base_salary: base_salary || null,
        enable_payroll: enable_payroll === '1' ? 1 : 0
      });
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

  // POST /users/:id/activate
  async activate(req, res) {
    try {
      const user = await UserModel.findById(req.params.id);
      if (!user) {
        req.flash('error', 'User not found.');
        return res.redirect('/users');
      }
      await UserModel.activate(req.params.id);
      req.flash('success', `User "${user.full_name}" has been reactivated.`);
      res.redirect('/users?tab=' + (user.role === 'salesman' ? 'salesmen' : 'order_bookers'));
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to activate user.');
      res.redirect('/users');
    }
  },

  // ============ DELIVERY MEN MANAGEMENT ============

  // GET /users/delivery-men/new
  newDeliveryManForm(req, res) {
    renderWithLayout(req, res, 'users/delivery-man-form', {
      title: 'Add Delivery Man',
      deliveryMan: null,
      isEdit: false,
    });
  },

  // POST /users/delivery-men
  async createDeliveryMan(req, res) {
    try {
      const { query } = require('../config/db');
      const { full_name, contact, base_salary, enable_payroll } = req.body;
      await query(
        'INSERT INTO delivery_men (full_name, contact, base_salary, enable_payroll) VALUES (?, ?, ?, ?)', 
        [full_name, contact || null, base_salary || null, enable_payroll === '1' ? 1 : 0]
      );
      req.flash('success', `Delivery man "${full_name}" created successfully.`);
      res.redirect('/users?tab=delivery_men');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to create delivery man: ' + err.message);
      res.redirect('/users/delivery-men/new');
    }
  },

  // GET /users/delivery-men/:id/edit
  async editDeliveryManForm(req, res) {
    try {
      const { query } = require('../config/db');
      const [deliveryMan] = await query('SELECT * FROM delivery_men WHERE id = ? LIMIT 1', [req.params.id]);
      if (!deliveryMan) {
        req.flash('error', 'Delivery man not found.');
        return res.redirect('/users?tab=delivery_men');
      }
      renderWithLayout(req, res, 'users/delivery-man-form', {
        title: 'Edit Delivery Man',
        deliveryMan,
        isEdit: true,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load delivery man.');
      res.redirect('/users?tab=delivery_men');
    }
  },

  // POST /users/delivery-men/:id
  async updateDeliveryMan(req, res) {
    try {
      const { query } = require('../config/db');
      const { full_name, contact, base_salary, enable_payroll } = req.body;
      await query(
        'UPDATE delivery_men SET full_name = ?, contact = ?, base_salary = ?, enable_payroll = ? WHERE id = ?',
        [full_name, contact || null, base_salary || null, enable_payroll === '1' ? 1 : 0, req.params.id]
      );
      req.flash('success', `Delivery man "${full_name}" updated successfully.`);
      res.redirect('/users?tab=delivery_men');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to update delivery man: ' + err.message);
      res.redirect(`/users/delivery-men/${req.params.id}/edit`);
    }
  },

  // POST /users/delivery-men/:id/deactivate
  async deactivateDeliveryMan(req, res) {
    try {
      const { query } = require('../config/db');
      const [deliveryMan] = await query('SELECT full_name FROM delivery_men WHERE id = ? LIMIT 1', [req.params.id]);
      if (!deliveryMan) {
        req.flash('error', 'Delivery man not found.');
        return res.redirect('/users?tab=delivery_men');
      }
      await query('UPDATE delivery_men SET is_active = 0 WHERE id = ?', [req.params.id]);
      req.flash('success', `Delivery man "${deliveryMan.full_name}" has been deactivated.`);
      res.redirect('/users?tab=delivery_men');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to deactivate delivery man.');
      res.redirect('/users?tab=delivery_men');
    }
  },

  // POST /users/delivery-men/:id/activate
  async activateDeliveryMan(req, res) {
    try {
      const { query } = require('../config/db');
      const [deliveryMan] = await query('SELECT full_name FROM delivery_men WHERE id = ? LIMIT 1', [req.params.id]);
      if (!deliveryMan) {
        req.flash('error', 'Delivery man not found.');
        return res.redirect('/users?tab=delivery_men');
      }
      await query('UPDATE delivery_men SET is_active = 1 WHERE id = ?', [req.params.id]);
      req.flash('success', `Delivery man "${deliveryMan.full_name}" has been reactivated.`);
      res.redirect('/users?tab=delivery_men');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to activate delivery man.');
      res.redirect('/users?tab=delivery_men');
    }
  },
};

module.exports = UserController;
