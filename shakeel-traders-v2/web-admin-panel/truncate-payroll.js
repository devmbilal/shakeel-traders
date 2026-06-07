/**
 * Truncate Payroll Records
 * This script will DELETE ALL payroll records from the database
 * WARNING: This action cannot be undone!
 */

'use strict';

require('dotenv').config();
const mysql = require('mysql2/promise');

async function truncatePayroll() {
  console.log('[Truncate] Connecting to database...');
  console.log('[Truncate] Database:', process.env.DB_NAME || 'shakeel_traders');
  
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'shakeel_traders',
  });

  try {
    console.log('[Truncate] Connected to database.');
    
    // Count before
    const [beforeCount] = await connection.query('SELECT COUNT(*) as count FROM payroll_records');
    console.log(`\n[Before] Payroll records: ${beforeCount[0].count}`);
    
    if (beforeCount[0].count === 0) {
      console.log('[Truncate] Table is already empty. Nothing to truncate.');
      return;
    }
    
    // Truncate
    await connection.query('TRUNCATE TABLE payroll_records');
    console.log('[Truncate] ✓ Table truncated successfully');
    
    // Count after
    const [afterCount] = await connection.query('SELECT COUNT(*) as count FROM payroll_records');
    console.log(`[After] Payroll records: ${afterCount[0].count}`);
    
    // Also clear sessions to ensure fresh data
    const [sessionsBefore] = await connection.query('SELECT COUNT(*) as count FROM sessions');
    console.log(`\n[Before] Sessions: ${sessionsBefore[0].count}`);
    
    await connection.query('DELETE FROM sessions');
    console.log('[Sessions] ✓ All sessions cleared');
    
    const [sessionsAfter] = await connection.query('SELECT COUNT(*) as count FROM sessions');
    console.log(`[After] Sessions: ${sessionsAfter[0].count}`);
    
    console.log('\n[Success] All payroll records and sessions cleared!');
    console.log('[Next Step] Restart the server and log in again.');
    
  } catch (err) {
    console.error('[Truncate] Error:', err.message);
    process.exit(1);
  } finally {
    await connection.end();
    console.log('\n[Truncate] Database connection closed.');
  }
}

// Run the script
truncatePayroll()
  .then(() => process.exit(0))
  .catch(err => {
    console.error('[Truncate] Fatal error:', err);
    process.exit(1);
  });
