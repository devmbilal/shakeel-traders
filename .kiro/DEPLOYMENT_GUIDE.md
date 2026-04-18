# Shakeel Traders Distribution Order System
## Deployment & Operations Guide — v1.2

---

## 1. System Overview

A fully **offline, locally hosted ERP** that replaces Salesflo. Runs on a single office computer on the local LAN. No internet required for daily operations.

**Two components:**
- **Web Admin Panel** — Node.js + Express + EJS + Bootstrap (this repo)
- **Mobile App** — Flutter Android (separate repo: `mobile-app/`)

**Four user roles:**

| Role | Access | Device |
|---|---|---|
| Admin | Full web panel | PC/Laptop browser |
| Order Booker | Mobile app only | Android phone |
| Salesman | Mobile app only | Android phone |
| Delivery Man | No login — admin managed | — |

**Three sales channels tracked separately:**
1. Order Booker Sales (field orders → converted to bills)
2. Salesman (Van) Sales (morning issuance → evening return)
3. Direct Shop Sales (instant bills from admin panel)

---

## 2. Prerequisites — What to Install

### On the Server Machine (Office PC/Laptop)

| Software | Version | Download |
|---|---|---|
| Node.js | v18 LTS or higher | https://nodejs.org |
| MySQL | 8.x | https://dev.mysql.com/downloads/mysql/ |
| MySQL Workbench (optional) | Latest | https://dev.mysql.com/downloads/workbench/ |
| Git (optional) | Latest | https://git-scm.com |

> The machine must be connected to the office Wi-Fi/LAN so mobile devices can reach it.

---

## 3. Database Setup

### Step 1 — Create the database

Open MySQL Workbench or MySQL CLI and run:

```sql
CREATE DATABASE shakeel_traders CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'shakeel'@'localhost' IDENTIFIED BY 'your_strong_password';
GRANT ALL PRIVILEGES ON shakeel_traders.* TO 'shakeel'@'localhost';
FLUSH PRIVILEGES;
```

### Step 2 — Run migrations

```bash
cd web-admin-panel
npm run migrate
```

This runs all SQL files in `src/db/migrations/` in order:

| Migration | What it creates |
|---|---|
| 001 | users, delivery_men |
| 002 | routes, route_assignments, shops |
| 003 | products, stock_movements |
| 004 | supplier_companies, advances, receipts, claims |
| 005 | orders, order_items, bills, bill_items |
| 006 | shop_ledger_entries, shop_advances, shop_last_prices |
| 007 | salesman_issuances, issuance_items, salesman_returns, return_items |
| 008 | bill_recovery_assignments, recovery_collections |
| 009 | centralized_cash_entries, delivery_man_collections |
| 010 | salary_records, salary_advances |
| 011 | expenses, audit_log |
| 012 | company_profile, sessions |
| 016 | adds sales_tax, cnic columns to company_profile |

### Step 3 — Seed default admin user

```bash
npm run seed
```

Default credentials (change immediately after first login):
- **Username:** `admin`
- **Password:** `admin123`

---

## 4. Environment Configuration

Copy and edit the `.env` file:

```bash
cp .env.example .env
```

Edit `.env`:

```env
# Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=shakeel
DB_PASS=your_strong_password
DB_NAME=shakeel_traders

# Session — CHANGE THIS to a long random string
SESSION_SECRET=replace_with_64_char_random_string

# Server port
PORT=3000

# Backup directory
BACKUP_DIR=./backups

# Environment
NODE_ENV=production
```

> **Important:** Change `SESSION_SECRET` to a long random string before going live.

---

## 5. Installation & Running

```bash
# Install dependencies
cd web-admin-panel
npm install

# Start the server
npm start
```

The server starts at: `http://localhost:3000`

From other devices on the same LAN: `http://<SERVER_IP>:3000`

> The server IP and port are shown on the **Dashboard** hero card under "Mobile App Connection" for easy reference.

### Running as a background service (Windows)

Install PM2 to keep the server running after closing the terminal:

```bash
npm install -g pm2
pm2 start src/app.js --name shakeel-traders
pm2 save
pm2 startup
```

---

## 6. First-Time Setup Checklist (After Deployment)

1. **Login** at `http://localhost:3000` with `admin` / `admin123`
2. **Change admin password** → Settings → Admin Profile
3. **Set company profile** → Company Profile (name, address, NTN, logo)
4. **Create routes** → Routes → Add Route
5. **Add shops** to each route (or bulk import via CSV)
6. **Add products** with SKU codes, prices, units per carton
7. **Add initial stock** → Stock → Manual Add
8. **Add suppliers** → Suppliers
9. **Create Order Booker accounts** → Users → Add User
10. **Create Salesman accounts** → Users → Add User
11. **Configure mobile app** — enter server IP and port on Connection Screen

---

## 7. Exporting for Deployment Team

To send the project to the deployment team:

```bash
# From the project root
# 1. Export the database
mysqldump -u root -p shakeel_traders > shakeel_traders_export.sql

# 2. Create a zip of the web panel (exclude node_modules and backups)
# On Windows PowerShell:
Compress-Archive -Path web-admin-panel -DestinationPath shakeel-traders-v1.2.zip `
  -CompressionLevel Optimal
```

**What to send:**
- `shakeel-traders-v1.2.zip` (web panel source)
- `shakeel_traders_export.sql` (database dump with schema + seed data)
- `mobile-app/` folder (Flutter project)
- This `DEPLOYMENT_GUIDE.md`
- `.env.example` (with placeholder values — never send the real `.env`)

**What NOT to send:**
- `.env` (contains real passwords)
- `node_modules/` folder
- `backups/` folder
- Any `.git` history if sensitive

---

## 8. Mobile App Connection Setup

1. Find the server IP on the Dashboard → hero card → "Mobile App Connection"
2. On the Android device, open the app
3. On the **Connection Screen**, enter:
   - **Server IP:** e.g. `192.168.1.100`
   - **Port:** `3000`
4. Tap **Test Connection** — should show "Connected"
5. Login with Order Booker or Salesman credentials

> All mobile devices must be on the **same Wi-Fi network** as the server machine.

---

## 9. Daily Backup

Automatic backup runs at **midnight (00:00 Asia/Karachi)** daily.

Manual backup: **Backup** page → "Run Backup Now"

Backup files are stored in `web-admin-panel/backups/` as `.sql` files.

To restore: **Backup** page → select file → "Restore"

---

## 10. System Workflow — How It Works

### Morning Routine (Admin)

1. **Assign routes** to Order Bookers for today → Route Assignments
2. **Assign recovery bills** to Order Bookers → Cash Recovery → Assign
3. **Approve any pending salesman issuances** → Stock → Pending Issuances

### Field Operations (Order Bookers — Mobile App)

1. **Morning Sync** — downloads routes, shops, products, prices, recovery assignments
2. **Book orders** throughout the day (fully offline)
3. **Record cash recoveries** against assigned bills (offline)
4. **Evening Sync** — uploads all orders and recovery collections to server

### Field Operations (Salesmen — Mobile App)

1. **Submit issuance request** in the morning (products + quantities)
2. Admin approves → stock deducted from warehouse
3. **Submit return** in the evening (unsold stock quantities)
4. Admin approves → returned stock added back, sale value posted to cash screen

### Evening Routine (Admin)

1. **Convert pending orders** to bills → Orders → Pending Orders
2. **Verify recovery collections** → Cash Recovery → Pending Verifications
3. **Approve salesman returns** → Stock → Pending Returns
4. **Record delivery man collections** → Cash Recovery → Bill Settlement
5. **Review dashboard** for alerts and daily summary

---

## 11. Module Reference

| Module | URL | Purpose |
|---|---|---|
| Dashboard | `/dashboard` | Live KPIs, alerts, cash summary |
| Users | `/users` | Order Bookers & Salesmen accounts |
| Routes | `/routes` | Geographic route management |
| Route Assignments | `/route-assignments` | Daily booker-to-route assignment |
| Shops | `/shops` | Shop directory + ledger + advances |
| Products | `/products` | Product catalogue + stock levels |
| Stock | `/stock` | Warehouse stock, movements, issuances, returns |
| Orders | `/orders` | Pending orders + converted bills |
| Direct Sales | `/direct-sales` | Instant bills without order workflow |
| Cash Recovery | `/cash-recovery` | Outstanding bills, assignments, verification |
| Suppliers | `/suppliers` | Supplier advances, receipts, claims |
| Centralized Cash | `/centralized-cash` | All cash received across all channels |
| Salaries | `/salaries` | Staff salary, advances, month-end clearance |
| Expenses | `/expenses` | Business expense tracking |
| Reports | `/reports` | All Excel-exportable reports |
| Backup | `/backup` | DB backup and restore |
| Audit Log | `/audit-log` | Immutable action history |
| Company Profile | `/company-profile` | Business info + logo for bills |
| Settings | `/settings/profile` | Admin password and username change |

---

## 12. Staff Training Guide

### For Admin

**Daily tasks (5 minutes each):**
- Morning: Assign routes + recovery bills
- Evening: Convert orders, verify recoveries, approve returns

**Key rules:**
- Never delete users or products — only deactivate
- Stock can never go negative — system enforces this
- All financial actions are logged in Audit Log
- Change admin password immediately after first login

### For Order Bookers

**Morning:**
1. Connect to office Wi-Fi
2. Open app → tap Sync (morning)
3. Go to field — app works fully offline

**During the day:**
1. Select route → select shop → book order
2. For recovery: go to Recovery tab → enter collected amount

**Evening:**
1. Return to office Wi-Fi range
2. Open app → tap Sync (evening)
3. Check for any stock adjustment notifications

### For Salesmen

**Morning:**
1. Open app → submit issuance request (products + quantities)
2. Wait for admin approval notification
3. Collect stock from warehouse

**Evening:**
1. Open app → submit return (enter quantities returned)
2. System auto-calculates sold quantities
3. Wait for admin approval

---

## 13. Troubleshooting

| Problem | Solution |
|---|---|
| Mobile app can't connect | Check server is running, both devices on same Wi-Fi, correct IP/port |
| "Stock would go negative" error | Check current stock levels in Stock module before converting |
| Login fails | Verify username/password, check if account is active in Users |
| Dashboard shows no data | Check DB connection in `.env`, restart server |
| Logo not showing on dashboard | Upload via Company Profile, refresh dashboard page |
| Backup fails | Check `backups/` folder exists and has write permissions |
| Server won't start | Check `.env` DB credentials, verify MySQL is running |

---

## 14. Tech Stack Summary

| Layer | Technology |
|---|---|
| Backend | Node.js 18 + Express 4 |
| View Engine | EJS + Bootstrap 5 |
| Database | MySQL 8 (InnoDB) |
| Session | express-session + MySQL store |
| Auth (web) | Session-based |
| Auth (mobile) | JWT (jsonwebtoken) |
| File uploads | Multer |
| PDF generation | PDFKit |
| Excel export | ExcelJS |
| Scheduled jobs | node-cron |
| Mobile | Flutter (Android) |

---

**Version:** 1.2  
**Date:** April 2026  
**System:** Shakeel Traders Distribution Order System
