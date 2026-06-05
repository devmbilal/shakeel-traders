'use strict';

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

const MIGRATIONS_DIR = path.join(__dirname, 'migrations');

async function runMigrations() {
  const conn = await mysql.createConnection({
    host:     process.env.DB_HOST || 'localhost',
    port:     parseInt(process.env.DB_PORT) || 3306,
    user:     process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'shakeel_traders',
    multipleStatements: true,
  });

  console.log('Running migrations...');

  const files = fs.readdirSync(MIGRATIONS_DIR)
    .filter(f => f.endsWith('.sql'))
    .sort();

  for (const file of files) {
    const filePath = path.join(MIGRATIONS_DIR, file);
    const sql = fs.readFileSync(filePath, 'utf8');
    try {
      await conn.query(sql);
      console.log(`  ✓ ${file}`);
    } catch (err) {
      // ER_DUP_FIELDNAME (1060) = column already exists — safe to skip
      if (err.errno === 1060) {
        console.log(`  ✓ ${file} (columns already exist — skipped)`);
      } else {
        console.error(`  ✗ ${file}: ${err.message}`);
        await conn.end();
        process.exit(1);
      }
    }
  }

  await conn.end();
  console.log('All migrations completed successfully.');
}

runMigrations().catch(err => {
  console.error('Migration failed:', err.message);
  process.exit(1);
});
