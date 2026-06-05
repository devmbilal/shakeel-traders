'use strict';

const bcrypt = require('bcryptjs');
const { query } = require('../config/db');

const AuthController = {
  // GET /login
  showLogin(req, res) {
    if (req.session.user) return res.redirect('/dashboard');
    res.render('auth/login', { title: 'Login — Shakeel Traders' });
  },

  // POST /login
  async login(req, res) {
    const { username, password } = req.body;

    if (!username || !password) {
      req.flash('error', 'Username and password are required.');
      return res.redirect('/login');
    }

    try {
      const rows = await query(
        'SELECT id, full_name, username, password_hash, role, is_active FROM users WHERE username = ?',
        [username.trim()]
      );

      if (!rows.length) {
        req.flash('error', 'Invalid username or password.');
        return res.redirect('/login');
      }

      const user = rows[0];

      if (!user.is_active) {
        req.flash('error', 'Your account has been deactivated. Please contact the administrator.');
        return res.redirect('/login');
      }

      if (user.role !== 'admin') {
        req.flash('error', 'Access denied. This panel is for administrators only.');
        return res.redirect('/login');
      }

      const match = await bcrypt.compare(password, user.password_hash);
      if (!match) {
        req.flash('error', 'Invalid username or password.');
        return res.redirect('/login');
      }

      req.session.user = {
        id:        user.id,
        full_name: user.full_name,
        username:  user.username,
        role:      user.role,
      };

      req.flash('success', `Welcome back, ${user.full_name}!`);
      res.redirect('/dashboard');
    } catch (err) {
      console.error('Login error:', err);
      req.flash('error', 'An error occurred. Please try again.');
      res.redirect('/login');
    }
  },

  // POST /logout
  logout(req, res) {
    req.session.destroy(() => {
      res.redirect('/login');
    });
  },
};

module.exports = AuthController;
