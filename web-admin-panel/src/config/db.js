'use strict';

const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || '',
  database: process.env.DB_NAME || 'shakeel_traders',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  timezone: '+00:00',
  charset: 'utf8mb4',
  enableKeepAlive: true,
  keepAliveInitialDelay: 10000,
});

/**
 * Get a connection from the pool (for transactions).
 * Caller must call conn.release() when done.
 */
async function getConnection() {
  return pool.getConnection();
}

/**
 * Execute a query on the pool (for simple reads/writes).
 * Uses pool.query (text protocol) to avoid mysql2 binary protocol bugs.
 */
async function query(sql, params) {
  const [rows] = params !== undefined
    ? await pool.query(sql, params)
    : await pool.query(sql);
  return rows;
}

module.exports = { pool, getConnection, query };
