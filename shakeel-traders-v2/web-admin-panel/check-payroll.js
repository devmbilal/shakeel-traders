/**
 * Check Payroll Records
 * Quick script to verify payroll_records table contents
 */

'use strict';

require('dotenv').config();
const mysql = require('mysql2/promise');

async function checkPayroll() {
  console.log('[Check] Connecting to database...');
  
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'shakeel_traders',
  });

  try {
    console.log('[Check] Connected to database.');
    
    // Count records in payroll_records
    const [countResult] = await connection.query('SELECT COUNT(*) as count FROM payroll_records');
    console.log(`\n[Payroll Records] Total: ${countResult[0].count}`);
    
    if (countResult[0].count > 0) {
      // Show sample records
      const [records] = await connection.query('SELECT * FROM payroll_records LIMIT 5');
      console.log('\n[Sample Records]:');
      records.forEach(r => {
        console.log(`  - ID: ${r.id}, Staff: ${r.staff_id}, Type: ${r.staff_type}, Month: ${r.month}/${r.year}, Payable: Rs ${r.final_payable}`);
      });
    } else {
      console.log('\n[Payroll Records] Table is EMPTY ✓');
    }
    
    // Count sessions
    const [sessionResult] = await connection.query('SELECT COUNT(*) as count FROM sessions');
    console.log(`\n[Sessions] Total: ${sessionResult[0].count}`);
    
    if (sessionResult[0].count > 0) {
      console.log('[Sessions] WARNING: Sessions exist (should be cleared)');
    } else {
      console.log('[Sessions] Table is EMPTY ✓');
    }
    
  } catch (err) {
    console.error('[Check] Error:', err.message);
    process.exit(1);
  } finally {
    await connection.end();
    console.log('\n[Check] Database connection closed.');
  }
}

// Run the script
checkPayroll()
  .then(() => process.exit(0))
  .catch(err => {
    console.error('[Check] Fatal error:', err);
    process.exit(1);
  });
