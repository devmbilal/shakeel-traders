/**
 * Clear Sessions Script
 * Run this after restoring a database backup to clear all cached sessions
 * Usage: node clear-sessions.js
 */

'use strict';

require('dotenv').config();
const mysql = require('mysql2/promise');

async function clearSessions() {
  console.log('[Clear Sessions] Connecting to database...');
  
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'shakeel_traders',
  });

  try {
    console.log('[Clear Sessions] Connected to database.');
    
    // Clear all sessions
    const [result] = await connection.query('DELETE FROM sessions');
    console.log(`[Clear Sessions] ✓ Cleared ${result.affectedRows} session(s) from database.`);
    
    console.log('[Clear Sessions] ✓ All sessions cleared successfully.');
    console.log('[Clear Sessions] Please restart the server for changes to take effect.');
    
  } catch (err) {
    console.error('[Clear Sessions] ✗ Error:', err.message);
    process.exit(1);
  } finally {
    await connection.end();
    console.log('[Clear Sessions] Database connection closed.');
  }
}

// Run the script
clearSessions()
  .then(() => process.exit(0))
  .catch(err => {
    console.error('[Clear Sessions] Fatal error:', err);
    process.exit(1);
  });
