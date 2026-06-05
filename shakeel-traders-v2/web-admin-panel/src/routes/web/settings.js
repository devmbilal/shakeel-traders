'use strict';

const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { query } = require('../../config/db');
const { renderWithLayout } = require('../../utils/render');

// GET /settings/profile
router.get('/profile', async (req, res) => {
  try {
    renderWithLayout(req, res, 'settings/profile', {
      title: 'Profile Settings',
    });
  } catch (err) {
    console.error('Profile page error:', err);
    req.flash('error', 'Failed to load profile page');
    res.redirect('/dashboard');
  }
});

// POST /settings/change-password
router.post('/change-password', async (req, res) => {
  const { currentPassword, newPassword, confirmPassword } = req.body;
  const userId = req.session.user.id;

  try {
    // Validate inputs
    if (!currentPassword || !newPassword || !confirmPassword) {
      req.flash('error', 'All fields are required');
      return res.redirect('/settings/profile');
    }

    if (newPassword !== confirmPassword) {
      req.flash('error', 'New password and confirmation do not match');
      return res.redirect('/settings/profile');
    }

    if (newPassword.length < 6) {
      req.flash('error', 'Password must be at least 6 characters long');
      return res.redirect('/settings/profile');
    }

    // Get current user
    const users = await query(
      'SELECT password_hash FROM users WHERE id = ?',
      [userId]
    );

    if (!users.length) {
      req.flash('error', 'User not found');
      return res.redirect('/settings/profile');
    }

    // Verify current password
    const match = await bcrypt.compare(currentPassword, users[0].password_hash);
    if (!match) {
      req.flash('error', 'Current password is incorrect');
      return res.redirect('/settings/profile');
    }

    // Hash new password
    const newPasswordHash = await bcrypt.hash(newPassword, 10);

    // Update password
    await query(
      'UPDATE users SET password_hash = ? WHERE id = ?',
      [newPasswordHash, userId]
    );

    req.flash('success', 'Password updated successfully');
    res.redirect('/settings/profile');
  } catch (err) {
    console.error('Change password error:', err);
    req.flash('error', 'Failed to update password');
    res.redirect('/settings/profile');
  }
});

// POST /settings/change-username
router.post('/change-username', async (req, res) => {
  const { newUsername, password } = req.body;
  const userId = req.session.user.id;

  try {
    // Validate inputs
    if (!newUsername || !password) {
      req.flash('error', 'All fields are required');
      return res.redirect('/settings/profile');
    }

    if (newUsername.length < 3) {
      req.flash('error', 'Username must be at least 3 characters long');
      return res.redirect('/settings/profile');
    }

    // Get current user
    const users = await query(
      'SELECT password_hash FROM users WHERE id = ?',
      [userId]
    );

    if (!users.length) {
      req.flash('error', 'User not found');
      return res.redirect('/settings/profile');
    }

    // Verify password
    const match = await bcrypt.compare(password, users[0].password_hash);
    if (!match) {
      req.flash('error', 'Password is incorrect');
      return res.redirect('/settings/profile');
    }

    // Check if username already exists
    const existingUsers = await query(
      'SELECT id FROM users WHERE username = ? AND id != ?',
      [newUsername.trim(), userId]
    );

    if (existingUsers.length > 0) {
      req.flash('error', 'Username already taken');
      return res.redirect('/settings/profile');
    }

    // Update username
    await query(
      'UPDATE users SET username = ? WHERE id = ?',
      [newUsername.trim(), userId]
    );

    // Update session
    req.session.user.username = newUsername.trim();

    req.flash('success', 'Username updated successfully');
    res.redirect('/settings/profile');
  } catch (err) {
    console.error('Change username error:', err);
    req.flash('error', 'Failed to update username');
    res.redirect('/settings/profile');
  }
});

module.exports = router;
