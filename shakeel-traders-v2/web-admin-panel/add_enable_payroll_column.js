require('dotenv').config();
const mysql = require('mysql2/promise');

async function addColumn() {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'shakeel_traders',
  });

  console.log('Connected to database...');

  try {
    // Check if column exists
    const [columns] = await conn.query(
      "SHOW COLUMNS FROM users LIKE 'enable_payroll'"
    );

    if (columns.length > 0) {
      console.log('✓ enable_payroll column already exists');
    } else {
      console.log('Adding enable_payroll column...');
      
      // Add the column
      await conn.query(`
        ALTER TABLE users 
        ADD COLUMN enable_payroll TINYINT(1) NOT NULL DEFAULT 1 
        COMMENT '1=Include in attendance/payroll, 0=Exclude (system users)'
      `);
      
      console.log('✓ enable_payroll column added');
      
      // Set admin users to 0
      const [result] = await conn.query(
        "UPDATE users SET enable_payroll = 0 WHERE role = 'admin'"
      );
      
      console.log(`✓ Updated ${result.affectedRows} admin user(s) to enable_payroll = 0`);
    }

    // Verify
    const [rows] = await conn.query(
      'SELECT id, full_name, role, enable_payroll FROM users LIMIT 5'
    );
    
    console.log('\nSample users:');
    console.table(rows);

  } catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
  } finally {
    await conn.end();
    console.log('\nDone!');
  }
}

addColumn();
