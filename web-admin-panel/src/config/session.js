'use strict';

const session = require('express-session');
const MySQLStore = require('express-mysql-session')(session);
const mysql = require('mysql2/promise');
require('dotenv').config();

const sessionStoreOptions = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || '',
  database: process.env.DB_NAME || 'shakeel_traders',
  clearExpired: true,
  checkExpirationInterval: 900000, // 15 minutes
  expiration: 86400000,            // 24 hours
  createDatabaseTable: true,
  schema: {
    tableName: 'sessions',
    columnNames: {
      session_id: 'session_id',
      expires: 'expires',
      data: 'data',
    },
  },
};

const sessionStore = new MySQLStore(sessionStoreOptions);

const sessionMiddleware = session({
  key: 'shakeel_sid',
  secret: process.env.SESSION_SECRET || 'change_this_secret',
  store: sessionStore,
  resave: false,
  saveUninitialized: false,
  cookie: {
    maxAge: 86400000, // 24 hours
    httpOnly: true,
    sameSite: 'lax',
  },
});

module.exports = sessionMiddleware;
