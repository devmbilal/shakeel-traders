'use strict';

require('dotenv').config();
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

async function seed() {
  const conn = await mysql.createConnection({
    host:     process.env.DB_HOST || 'localhost',
    port:     parseInt(process.env.DB_PORT) || 3306,
    user:     process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'shakeel_traders',
  });

  console.log('Seeding database...');

  // ── Admin User ──────────────────────────────────────────────────────────────
  const adminHash = await bcrypt.hash('admin123', 12);
  await conn.execute(
    `INSERT IGNORE INTO users (full_name, username, password_hash, role)
     VALUES (?, ?, ?, 'admin')`,
    ['Administrator', 'admin', adminHash]
  );
  console.log('  ✓ Admin user (username: admin, password: admin123)');

  // ── Sample Order Booker ─────────────────────────────────────────────────────
  const bookerHash = await bcrypt.hash('booker123', 12);
  await conn.execute(
    `INSERT IGNORE INTO users (full_name, username, password_hash, role, contact)
     VALUES (?, ?, ?, 'order_booker', ?)`,
    ['Ahmed Khan', 'ahmed', bookerHash, '03001234567']
  );
  console.log('  ✓ Order Booker (username: ahmed, password: booker123)');

  // ── Sample Salesman ─────────────────────────────────────────────────────────
  const salesmanHash = await bcrypt.hash('salesman123', 12);
  await conn.execute(
    `INSERT IGNORE INTO users (full_name, username, password_hash, role, contact)
     VALUES (?, ?, ?, 'salesman', ?)`,
    ['Bilal Raza', 'bilal', salesmanHash, '03009876543']
  );
  console.log('  ✓ Salesman (username: bilal, password: salesman123)');

  // ── Sample Delivery Man ─────────────────────────────────────────────────────
  await conn.execute(
    `INSERT IGNORE INTO delivery_men (full_name, contact) VALUES (?, ?)`,
    ['Usman Ali', '03111234567']
  );
  console.log('  ✓ Delivery Man: Usman Ali');

  // ── Sample Supplier ─────────────────────────────────────────────────────────
  await conn.execute(
    `INSERT IGNORE INTO supplier_companies (name, contact_person, phone, current_advance_balance)
     VALUES (?, ?, ?, ?)`,
    ['CBL', 'CBL Sales Rep', '04212345678', 50000.00]
  );
  console.log('  ✓ Supplier: CBL');

  // ── Sample Routes ───────────────────────────────────────────────────────────
  await conn.execute(`INSERT IGNORE INTO routes (name) VALUES ('Route A - North')`, []);
  await conn.execute(`INSERT IGNORE INTO routes (name) VALUES ('Route B - South')`, []);
  console.log('  ✓ Routes: Route A - North, Route B - South');

  // ── Sample Shops ────────────────────────────────────────────────────────────
  const [routes] = await conn.execute(`SELECT id FROM routes LIMIT 2`);
  if (routes.length >= 1) {
    await conn.execute(
      `INSERT IGNORE INTO shops (name, owner_name, phone, route_id, shop_type)
       VALUES (?, ?, ?, ?, 'retail')`,
      ['Al-Noor General Store', 'Noor Ahmed', '03211111111', routes[0].id]
    );
    await conn.execute(
      `INSERT IGNORE INTO shops (name, owner_name, phone, route_id, shop_type)
       VALUES (?, ?, ?, ?, 'wholesale')`,
      ['City Wholesale', 'Tariq Mehmood', '03222222222', routes[0].id]
    );
  }
  if (routes.length >= 2) {
    await conn.execute(
      `INSERT IGNORE INTO shops (name, owner_name, phone, route_id, shop_type)
       VALUES (?, ?, ?, ?, 'retail')`,
      ['Pak Kiryana', 'Imran Shah', '03233333333', routes[1].id]
    );
  }
  console.log('  ✓ Sample shops created');

  // ── Sample Products ─────────────────────────────────────────────────────────
  const products = [
    { sku: 'CBL-001', name: 'CBL Biscuit 100g', brand: 'CBL', upc: 24, retail: 15.00, wholesale: 13.50 },
    { sku: 'CBL-002', name: 'CBL Cake 50g',     brand: 'CBL', upc: 48, retail: 10.00, wholesale: 9.00  },
    { sku: 'CBL-003', name: 'CBL Wafer 75g',    brand: 'CBL', upc: 36, retail: 12.00, wholesale: 10.50 },
  ];
  for (const p of products) {
    await conn.execute(
      `INSERT IGNORE INTO products
         (sku_code, name, brand, units_per_carton, retail_price, wholesale_price,
          current_stock_cartons, current_stock_loose, low_stock_threshold)
       VALUES (?, ?, ?, ?, ?, ?, 50, 0, 5)`,
      [p.sku, p.name, p.brand, p.upc, p.retail, p.wholesale]
    );
  }
  console.log('  ✓ Sample products created (CBL-001, CBL-002, CBL-003)');

  // ── Company Profile ─────────────────────────────────────────────────────────
  await conn.execute(
    `INSERT INTO company_profile (id, company_name, owner_name, address, phone_1, gst_ntn)
     VALUES (1, 'Shakeel Traders', 'Muhammad Shakeel', 'Main Market, Lahore', '04235000000', 'NTN-1234567')
     ON DUPLICATE KEY UPDATE
       company_name = VALUES(company_name),
       owner_name   = VALUES(owner_name),
       address      = VALUES(address),
       phone_1      = VALUES(phone_1),
       gst_ntn      = VALUES(gst_ntn)`,
    []
  );
  console.log('  ✓ Company profile seeded');

  await conn.end();
  console.log('\nSeed completed successfully.');
}

seed().catch(err => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});
