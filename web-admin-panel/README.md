# Shakeel Traders Distribution Order System - Setup Guide

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

## Implementation Status

### ✅ Completed Phases (1-5)

- Phase 1: Database Setup & Migrations
- Phase 2: Web Panel Foundation (Auth, Middleware, Layout)
- Phase 3: Core Master Data (Company Profile, Users, Routes, Shops, Products)
- Phase 4: Stock Management
- Phase 5: Order Management + Billing

### 🚧 Remaining Phases (6-11)

- Phase 6: Checkpoint
- Phase 7: Cash Recovery & Bill Settlement
- Phase 8: Supplier Management, Centralized Cash, Salary, Expenses
- Phase 9: Dashboard, Reports & Database Backup
- Phase 10: Cron Job, Audit Log Viewer & Non-Functional Hardening
- Phase 11: Property-Based Tests

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
2. Configure Company Profile
3. Add Users (Order Bookers, Salesmen)
4. Create Routes and assign Shops
5. Add Products
6. Start managing orders and stock

## Support

For issues or questions, refer to the SRS document in `Shakeel Traders/srs.md`
