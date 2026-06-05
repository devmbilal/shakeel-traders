'use strict';

/**
 * Get current date from MySQL (avoids JS UTC vs local timezone mismatch).
 * Always use this instead of new Date().toISOString().slice(0,10) for DB queries.
 */
const { query } = require('../config/db');

async function mysqlToday() {
  const rows = await query('SELECT CURDATE() AS today');
  return rows[0].today; // Returns 'YYYY-MM-DD' in MySQL server's local timezone
}

async function mysqlTodayAndMonth() {
  const rows = await query(`
    SELECT 
      CURDATE() AS today,
      DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL DAY(CURDATE())-1 DAY), '%Y-%m-%d') AS first_of_month,
      DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL DAYOFYEAR(CURDATE())-1 DAY), '%Y-%m-%d') AS first_of_year,
      MONTH(CURDATE()) AS cur_month,
      YEAR(CURDATE()) AS cur_year
  `);
  return rows[0];
}

module.exports = { mysqlToday, mysqlTodayAndMonth };
