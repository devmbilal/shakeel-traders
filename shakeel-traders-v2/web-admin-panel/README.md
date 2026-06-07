# Shakeel Traders Distribution Order System v3.0 - Setup Guide

## Prerequisites

- **Node.js** (v16 or higher)
- **MySQL** (v8.0 or higher)
- **npm** or **yarn**

## Quick Start

### 1. Database Setup

First, create the MySQL database:

```bash
mysql -u root -p
```

Then in MySQL console:

```sql
CREATE DATABASE shakeel_traders CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

### 2. Install Dependencies

Navigate to the web-admin-panel directory:

```bash
cd "Shakeel Traders/web-admin-panel"
npm install
```

### 3. Configure Environment

Copy the example environment file and update it with your settings:

```bash
cp .env.example .env
```

Edit `.env` file with your database credentials:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASS=your_mysql_password
DB_NAME=shakeel_traders
SESSION_SECRET=your_random_secret_key_here
PORT=3000
BACKUP_DIR=./backups
NODE_ENV=development
```

### 4. Run Database Migrations

This will create all the required tables:

```bash
npm run migrate
```

### 5. Seed Initial Data

This will create an admin user and sample data:

```bash
npm run seed
```

**Default Admin Credentials:**
- Username: `admin`
- Password: `admin123` (change this after first login)

### 6. Start the Application

For development (with auto-reload):

```bash
npm run dev
```

For production:

```bash
npm start
```

The application will be available at: **http://localhost:3000**

## Project Structure

```
web-admin-panel/
├── src/
│   ├── app.js                 # Main Express application
│   ├── config/                # Configuration files
│   │   ├── db.js             # Database connection
│   │   ├── session.js        # Session configuration
│   │   └── cron.js           # Cron job configuration
│   ├── controllers/          # Route controllers
│   ├── models/               # Database models
│   ├── routes/               # Route definitions
│   │   ├── web/             # Web routes
│   │   └── api/             # API routes
│   ├── services/            # Business logic services
│   ├── middleware/          # Custom middleware
│   ├── views/               # EJS templates
│   ├── utils/               # Utility functions
│   └── db/
│       ├── migrations/      # Database migration files
│       ├── migrate.js       # Migration runner
│       └── seed.js          # Database seeder
├── tests/                   # Test files
│   └── pbt/                # Property-based tests
├── .env                    # Environment variables (create from .env.example)
├── .env.example           # Example environment file
└── package.json           # Dependencies and scripts
```

## Available Scripts

- `npm start` - Start the production server
- `npm run dev` - Start development server with auto-reload
- `npm run migrate` - Run database migrations
- `npm run seed` - Seed database with initial data
- `npm test` - Run all tests
- `npm run test:pbt` - Run property-based tests only

### Utility Scripts (v3.0)

- `node clear-sessions.js` - Clear all sessions (after DB restore)
- `node check-payroll.js` - Verify payroll and session tables
- `node truncate-payroll.js` - Delete all payroll records and sessions
- `node verify-timezone-fixes.js` - Verify Pakistan timezone configuration

## Implementation Status

### ✅ Version 3.0 - Fully Implemented & Production Ready

**All core features completed and tested:**

#### User Management & Authentication
- Multi-role system (Admin, Order Booker, Salesman, Delivery Men)
- Secure login with session management
- Password protection and role-based access control

#### Master Data Management
- Company profile configuration
- User management (create, edit, activate/deactivate)
- Route management with assignments
- Shop management with CSV import/export
- Product catalog with CSV import/export
- Quick actions for price updates and stock alerts

#### Stock Management
- Real-time inventory tracking (cartons + loose units)
- Stock adjustments (add/deduct)
- Low stock alerts and thresholds
- Stock movement history
- Filter by stock status (all, active, inactive, low stock)

#### Order & Billing System
- Route-based order assignment
- Order booker mobile app sync
- Salesman mobile app sync (direct sales)
- Automatic bill generation
- Multiple bill types (route-based, direct sales)
- Outstanding balance tracking
- Partial payment support

#### Cash Recovery & Settlement
- Bill settlement with payment tracking
- Recovery management by route
- Pending bills tracking
- Shop ledger with complete transaction history
- Opening balance support for existing customers

#### Financial Management
- Centralized cash tracking
- Expense management by category
- Supplier management
- Purchase tracking
- Payroll system with attendance integration
- Salary advances tracking
- Automatic payroll generation

#### Attendance & HR
- Daily attendance marking (Present, Absent, Holiday, Off)
- Auto-mark present for unmarked days
- Friday auto-off (weekly holiday)
- Attendance reports by staff type
- Integration with payroll calculations

#### Dashboard & Reports
- Real-time metrics (total outstanding, bills, shops, products)
- Low stock alerts
- Top 10 customers by outstanding
- Quick action shortcuts in topbar
- Role-specific dashboard views

#### System Administration
- Automated daily backups (MySQL)
- Google Drive integration via Rclone
- Backup restore with automatic session clearing
- Database migrations system
- Comprehensive audit logging
- User guide (English & Urdu)

#### Mobile App Sync
- Real-time data synchronization
- Route assignments with date-based filtering
- Product inventory sync (excludes 0 stock items)
- Shop data with custom pricing
- Order submission from mobile to server

### 🎯 Latest Updates (v3.0)

**Recent Enhancements:**
- ✅ Session cache clearing after database restore
- ✅ Product CSV export with filter support
- ✅ Shop CSV export with route filtering
- ✅ Payroll data cleanup utilities
- ✅ Backup timestamp in Pakistan timezone
- ✅ Missed backup detection on startup
- ✅ Interactive user guides (English + Urdu)
- ✅ Topbar icon-only shortcuts with theme colors
- ✅ Total outstanding calculation includes all ledger sources
- ✅ Route assignment mobile app sync fixes
- ✅ Direct sales product dropdown search
- ✅ Opening balance support for shops
- ✅ Delivery men management fixes

### 📊 System Statistics

- **22 Database Migrations** - Fully applied
- **17+ Controllers** - Complete business logic
- **15+ Models** - Full database abstraction
- **50+ Views** - Responsive EJS templates
- **10+ Services** - Backup, sync, stock, payroll
- **Multiple Utilities** - Date helpers, print formatters, pagination
- **Comprehensive Documentation** - 50+ markdown guides in .kiro folder

## Troubleshooting

### Database Connection Issues

If you get connection errors:

1. Verify MySQL is running: `mysql -u root -p`
2. Check your `.env` file has correct credentials
3. Ensure the database exists: `SHOW DATABASES;`

### Port Already in Use

If port 3000 is already in use, change the `PORT` in `.env` file.

### Migration Errors

If migrations fail:

1. Drop and recreate the database:
   ```sql
   DROP DATABASE IF EXISTS shakeel_traders;
   CREATE DATABASE shakeel_traders CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
2. Run migrations again: `npm run migrate`

## Next Steps

After setup, you can:

1. Login at http://localhost:3000/login with admin credentials
2. Configure Company Profile (required for backups and settings)
3. Add Users (Order Bookers, Salesmen, Delivery Men)
4. Create Routes and assign Shops
5. Add Products to catalog
6. Configure automatic backup schedule
7. Set up Google Drive sync (optional, via Rclone)
8. Enable payroll for staff members
9. Start managing daily operations:
   - Assign routes to order bookers
   - Process orders and generate bills
   - Track cash recovery
   - Manage stock levels
   - Generate monthly payroll

## Key Features (v3.0)

### 📱 Mobile Integration
- Order Booker app sync with route assignments
- Salesman app sync for direct sales
- Real-time product and shop data
- Offline-capable with sync on connection

### 💰 Financial Tracking
- Complete bill lifecycle (pending → partially paid → paid)
- Shop ledger with opening balance support
- Recovery tracking by route and date
- Expense categorization and tracking
- Supplier payment management

### 👥 HR & Payroll
- Attendance marking with auto-present for unmarked days
- Friday auto-off (weekly holiday)
- Payroll generation with deductions
- Salary advance tracking and deduction
- Multi-staff type support (users + delivery men)

### 📊 Reporting & Analytics
- Dashboard with key metrics
- Low stock alerts
- Top customers by outstanding
- Stock movement history
- Attendance reports
- Payroll summaries

### 🔧 System Tools
- Automated daily backups with Google Drive upload
- CSV import/export for shops and products
- Session management utilities
- Database migration system
- Comprehensive audit logging

## Support & Documentation

- **Main Documentation:** See `.kiro/` folder for 50+ detailed guides
- **User Guide:** Available in-app at `/help/user-guide` (English & Urdu)
- **SRS Document:** `Shakeel Traders/srs.md`
- **Version:** 3.0 - Production Ready

---

**Shakeel Traders Distribution Order System v3.0**  
A complete ERP solution for distribution and trading businesses.
