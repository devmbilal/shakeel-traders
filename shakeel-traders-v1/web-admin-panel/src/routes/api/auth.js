'use strict';
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../../config/db');

const JWT_SECRET = process.env.JWT_SECRET || process.env.SESSION_SECRET || 'shakeel_jwt_secret';
const JWT_EXPIRES = '24h';

// GET /api/auth/test-connection — mobile app connectivity check
router.get('/test-connection', (req, res) => {
  res.json({ status: 'ok', server: 'Shakeel Traders', version: '1.0.0' });
});

// POST /api/auth/test-connection — also support POST
router.post('/test-connection', (req, res) => {
  res.json({ status: 'ok', server: 'Shakeel Traders', version: '1.0.0' });
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password required' });
    }

    const [user] = await db.query(
      `SELECT id, username, full_name, password_hash, role, is_active
       FROM users WHERE username = ? AND role IN ('order_booker','salesman')`,
      [username]
    );

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    if (!user.is_active) {
      return res.status(403).json({ error: 'Account is deactivated' });
    }

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: user.id, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES }
    );

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        full_name: user.full_name,
        role: user.role,
      },
    });
  } catch (err) {
    console.error('Mobile login error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
