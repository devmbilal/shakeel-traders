# Technical Design Document

## Shakeel Traders — Distribution Order System

**Version 1.0 | April 2026**
**Feature:** shakeel-traders-distribution-system
**References:** SRS v1.2, DB Schema v1.2

---

## Overview

The Shakeel Traders Distribution Order System is a fully offline, locally hosted ERP replacing the existing Salesflo software. It runs on a single office computer with no internet dependency. The system manages three distinct sales channels — Order Booker Sales, Salesman (Van) Sales, and Direct Shop Sales — each tracked separately across all dashboards and reports.

**Two components:**
- **Web Admin Panel** — Node.js + Express + EJS + Bootstrap, MVC architecture, served on the local LAN
- **Mobile App** — Flutter (Android), offline-first, communicates with the same Express server via REST API

**Four user roles:**
- Admin (web panel only, full access)
- Order Booker (mobile only, order booking + cash recovery)
- Salesman (mobile only, stock issuance + return)
- Delivery Man (no system login, admin-managed)

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Local Office Computer                     │
│                                                             │
│  ┌──────────────────────┐    ┌──────────────────────────┐  │
│  │   Web Admin Panel    │    │   Express REST API        │  │
│  │  (EJS + Bootstrap)   │◄──►│   (Mobile Endpoints)      │  │
│  └──────────────────────┘    └──────────────────────────┘  │
│              │                           │                  │
│              └───────────┬───────────────┘                  │
│                          ▼                                  │
│                  ┌───────────────┐                          │
│                  │  MySQL 8.x    │                          │
│                  │  (InnoDB)     │                          │
│                  └───────────────┘                          │
│                          │                                  │
│                  ┌───────────────┐                          │
│                  │  node-cron    │                          │
│                  │ (Midnight Job)│                          │
│                  └───────────────┘                          │
└─────────────────────────────────────────────────────────────┘
         ▲                              ▲
         │ Browser (LAN)                │ Wi-Fi (LAN)
         │                              │
┌────────────────┐            ┌─────────────────────┐
│  Admin Browser │            │  Flutter Android App │
│  (Chrome/Edge) │            │  (Order Booker /     │
└────────────────┘            │   Salesman)          │
                              └─────────────────────┘
```

### MVC Architecture (Web Panel)

```
Request → Router → Middleware (auth, audit, validation)
                        ↓
                   Controller
                        ↓
                   Service Layer (business logic)
                        ↓
                   Model (MySQL queries)
                        ↓
                   Response (EJS view or JSON)
```

### Middleware Stack

1. **Session Auth Middleware** — checks `req.session.user` on every web panel route; redirects to `/login` if absent
2. **Audit Log Middleware** — wraps mutating routes to write `audit_log` entries after successful operations
3. **Stock Validation Middleware** — pre-checks stock availability before any deduction operation; rejects with 422 if stock would go negative
4. **Request Logger** — logs all requests with timestamp and IP


---

## Components and Interfaces

### Web Admin Panel — Pages & Controllers

Each SRS section maps to one Express router file and one EJS view directory.

| SRS Section | Route Prefix | Controller | View Directory |
|---|---|---|---|
| 7.1 Dashboard | `/dashboard` | `DashboardController` | `views/dashboard/` |
| 7.2 Company Profile | `/company-profile` | `CompanyProfileController` | `views/company-profile/` |
| 7.3 User Management | `/users` | `UserController` | `views/users/` |
| 7.4 Route Management | `/routes` | `RouteController` | `views/routes/` |
| 7.5 Route Assignment | `/route-assignments` | `RouteAssignmentController` | `views/route-assignments/` |
| 7.6 Shop Management | `/shops` | `ShopController` | `views/shops/` |
| 7.7 Product Management | `/products` | `ProductController` | `views/products/` |
| 7.8 Stock Management | `/stock` | `StockController` | `views/stock/` |
| 7.9 Order Management | `/orders` | `OrderController` | `views/orders/` |
| 7.10 Direct Shop Sales | `/direct-sales` | `DirectSalesController` | `views/direct-sales/` |
| 7.11 Cash Recovery & Bill Settlement | `/cash-recovery` | `CashRecoveryController` | `views/cash-recovery/` |
| 7.12 Supplier / Company Management | `/suppliers` | `SupplierController` | `views/suppliers/` |
| 7.13 Centralized Cash Screen | `/centralized-cash` | `CentralizedCashController` | `views/centralized-cash/` |
| 7.14 Staff Salary Management | `/salaries` | `SalaryController` | `views/salaries/` |
| 7.15 Expenses Management | `/expenses` | `ExpenseController` | `views/expenses/` |
| 7.16 Reports | `/reports` | `ReportController` | `views/reports/` |
| 7.17 Database Backup | `/backup` | `BackupController` | `views/backup/` |

### Mobile App — Screens

| SRS Section | Screen Class | Role |
|---|---|---|
| 8.1.1 Connection Screen | `ConnectionScreen` | Shared |
| 8.1.2 Login Screen | `LoginScreen` | Shared |
| 8.2.1 Home Screen | `OrderBookerHomeScreen` | Order Booker |
| 8.2.2 Routes Screen | `RoutesScreen` | Order Booker |
| 8.2.3 Order Booking Screen | `OrderBookingScreen` | Order Booker |
| 8.2.4 Recovery Tab | `RecoveryTabScreen` | Order Booker |
| 8.2.5 Sync Screen | `OrderBookerSyncScreen` | Order Booker |
| 8.2.6 Today's Summary Screen | `OrderBookerSummaryScreen` | Order Booker |
| 8.3.1 Home Screen | `SalesmanHomeScreen` | Salesman |
| 8.3.2 Stock Issuance Screen | `StockIssuanceScreen` | Salesman |
| 8.3.3 Stock Return Screen | `StockReturnScreen` | Salesman |
| 8.3.4 Sync Screen | `SalesmanSyncScreen` | Salesman |
| 8.3.5 Today's Summary Screen | `SalesmanSummaryScreen` | Salesman |

### Service Layer

Business logic is separated from controllers into service classes:

| Service | Responsibilities |
|---|---|
| `StockService` | All stock deductions/additions, non-negativity enforcement, stock_movements writes |
| `BillService` | Bill creation, bill number generation, advance auto-deduction, ledger entry creation |
| `OrderService` | Order conversion to bill, stock adjustment on evening sync |
| `RecoveryService` | Recovery assignment, collection verification, ledger + cash entry writes |
| `SalaryService` | Salary record management, advance recording, month-end clearance |
| `SupplierService` | Advance recording, stock receipt processing, claim management |
| `SyncService` | Mobile sync payload assembly (download) and processing (upload) |
| `ReportService` | All report queries and Excel export generation |
| `BackupService` | MySQL dump execution, backup file management, restore |
| `CronService` | Midnight job logic — auto-return of unrecovered assignments |


---

## Data Models

All tables are defined in `Shakeel Traders/db-schema.md` (v1.2). This section summarizes the groups and key business logic constraints.

### Group A — Users & Roles
- `users`: Admin, Order Booker, Salesman. No deletion — only `is_active = 0`. Passwords stored as bcrypt hashes.
- `delivery_men`: No login credentials. Admin-managed only. Referenced in salary and delivery collection tables.

### Group B — Routes & Shops
- `routes`: Named collections of shops. Unique name. Soft-delete only.
- `route_assignments`: One order booker per route per day (`UNIQUE KEY uq_route_date`). FOR ORDER BOOKING ONLY — completely independent from `bill_recovery_assignments`.
- `shops`: Belongs to exactly one route. Has `price_edit_allowed`, `price_min_pct`, `price_max_pct` for mobile price editing control.

### Group C — Products & Stock
- `products`: Unique `sku_code`. `CHECK (current_stock_cartons >= 0 AND current_stock_loose >= 0)`. No deletion.
- `stock_movements`: Append-only audit ledger of every warehouse stock change. Six movement types: `receipt_supplier`, `manual_add`, `bill_deduction`, `issuance_salesman`, `return_salesman`, `direct_sale_deduction`.

### Group D — Supplier Companies, Advances & Claims
- `supplier_companies`: `current_advance_balance` updated transactionally: +advance, -stock_receipt_value, +cleared_claim_value.
- `supplier_advances`, `stock_receipts`, `stock_receipt_items`: Track the advance → receipt flow.
- `claims`, `claim_items`: Record-only. Claimed products NEVER enter warehouse stock. Clearing a claim adds `claim_value` back to supplier advance balance.

### Group E — Orders, Bills & Line Items
- `orders`: Created by order bookers offline. Status flow: `pending` → `stock_adjusted` → `converted` / `cancelled`.
- `bills`: Three types: `order_booker`, `direct_shop`, `salesman`. Bill number format: `[TYPE_PREFIX]-[YEAR]-[MONTH]-[SEQUENCE]` (OB, DS, SM). `net_amount = gross_amount - advance_deducted`. `outstanding_amount = net_amount - amount_paid`.
- `bill_items`: Line items with snapshotted `unit_price`.

### Group F — Shop Ledger & Advances
- `shop_ledger_entries`: **APPEND ONLY**. Six entry types: `bill`, `payment_delivery_man`, `recovery`, `advance_payment`, `advance_adjustment`, `claim_credit`. `balance_after` is a running balance snapshot.
- `shop_advances`: `remaining_balance` decremented when bills are created for the shop.

### Group G — Salesman Issuances & Returns
- `salesman_issuances`: `UNIQUE KEY uq_salesman_date (salesman_id, issuance_date)`. Stock deducted ONLY after `status = 'approved'`.
- `salesman_returns`: One per issuance (`UNIQUE KEY uq_issuance_return`). `final_sale_value = admin_edited_sale_value ?? system_sale_value`.
- `return_items`: `sold_cartons = issued_cartons - returned_cartons`. `line_sale_value = (sold_cartons * units_per_carton + sold_loose) * retail_price`.

### Group H — Cash Recovery
- `bill_recovery_assignments`: **INDEPENDENT from route_assignments**. One active assignment per bill at a time. Midnight cron sets `status = 'returned_to_pool'` for all previous-day `assigned`/`partially_recovered` records.
- `recovery_collections`: Uploaded by order booker on sync. Admin verification triggers: bill outstanding update, shop ledger entry, centralized cash entry.

### Group I — Centralized Cash Screen
- `centralized_cash_entries`: Three entry types: `salesman_sale`, `recovery`, `delivery_man_collection`. Posted by exactly three triggers.
- `delivery_man_collections`: Admin records cash brought by delivery man per bill.

### Group J — Staff Salary Management
- `salary_records`: Polymorphic `staff_id` (references `users.id` or `delivery_men.id` based on `staff_type`). `UNIQUE KEY uq_staff_month_year`.
- `salary_advances`: Partial payments. On insert, increments `salary_records.total_advances_paid`.

### Group K — Expenses & Audit Log
- `expenses`: Five types: `fuel`, `daily_allowance`, `vehicle_maintenance`, `office`, `other`.
- `audit_log`: **APPEND ONLY**. Captures `user_id`, `action`, `entity_type`, `entity_id`, `old_value` (JSON), `new_value` (JSON), `ip_address`, `created_at`.

### Group L — Supporting Tables
- `shop_last_prices`: `UNIQUE KEY uq_shop_product`. Updated automatically on every bill creation/conversion for a shop+product combination. Downloaded to mobile for order booker reference.
- `company_profile`: Single-row table (`id = 1`). Printed on all bills and reports.

### Key Business Logic Constraints

```
Bill amount integrity:
  net_amount = gross_amount - advance_deducted
  outstanding_amount = net_amount - amount_paid

Supplier advance balance:
  balance = SUM(advances) - SUM(stock_receipt_values) + SUM(cleared_claim_values)

Salesman sale value:
  system_sale_value = SUM((sold_cartons * units_per_carton + sold_loose) * retail_price)

Running salary balance:
  running_balance = basic_salary - total_advances_paid

Bill number format:
  OB-YYYY-MM-NNNNN  (order_booker)
  DS-YYYY-MM-NNNNN  (direct_shop)
  SM-YYYY-MM-NNNNN  (salesman)
```


---

## API Design

The Express server exposes two sets of endpoints: web panel routes (EJS-rendered, session-authenticated) and mobile REST API endpoints (JSON, JWT-authenticated).

### Authentication

- **Web Panel**: Express session (`express-session` + MySQL session store). Session cookie set on login. All web routes protected by `authMiddleware`.
- **Mobile API**: JWT token issued on login. Token included in `Authorization: Bearer <token>` header on all subsequent requests.

### Mobile REST API Endpoints

#### Auth
```
POST   /api/auth/login              — Login (returns JWT + role)
POST   /api/auth/test-connection    — Test server reachability (no auth required)
```

#### Order Booker Sync
```
GET    /api/sync/morning            — Download: routes, shops, products, prices, stock levels, recovery assignments
POST   /api/sync/evening            — Upload: orders[], recovery_collections[]
GET    /api/sync/midday             — Download: newly assigned recovery bills since last sync
```

#### Salesman Sync
```
GET    /api/sync/salesman/morning   — Download: products, stock levels
POST   /api/sync/salesman/issuance  — Upload: issuance request
GET    /api/sync/salesman/issuance-status — Check approval status of today's issuance
POST   /api/sync/salesman/return    — Upload: return request
```

### Web Panel API Endpoints (Express Routes)

#### Dashboard (7.1)
```
GET    /dashboard                   — Dashboard home (EJS)
GET    /dashboard/data              — AJAX: sales summary, performance metrics, alerts
```

#### Company Profile (7.2)
```
GET    /company-profile             — View/edit company profile
POST   /company-profile             — Save company profile
```

#### User Management (7.3)
```
GET    /users                       — List users (tabs: Order Bookers | Salesmen)
GET    /users/new                   — Add new user form
POST   /users                       — Create user
GET    /users/:id/edit              — Edit user form
POST   /users/:id                   — Update user
POST   /users/:id/deactivate        — Deactivate user
```

#### Route Management (7.4)
```
GET    /routes                      — All Routes list
POST   /routes                      — Create route
GET    /routes/:id                  — Route Details (shops in route)
POST   /routes/:id                  — Update route
POST   /routes/:id/deactivate       — Deactivate route
POST   /routes/:id/shops            — Add shop to route
DELETE /routes/:id/shops/:shopId    — Remove shop from route
```

#### Route Assignment (7.5)
```
GET    /route-assignments           — Assign Today view
POST   /route-assignments           — Create assignment
GET    /route-assignments/by-date   — View by Date
GET    /route-assignments/by-booker — View by Booker
```

#### Shop Management (7.6)
```
GET    /shops                       — All Shops list
GET    /shops/new                   — Add shop form
POST   /shops                       — Create shop
POST   /shops/import                — CSV bulk import
GET    /shops/:id                   — Shop Details
POST   /shops/:id                   — Update shop
GET    /shops/:id/ledger            — Shop Ledger
POST   /shops/:id/advance           — Add advance
GET    /shops/:id/ledger/export     — Export ledger to Excel
```

#### Product Management (7.7)
```
GET    /products                    — All Products list
GET    /products/new                — Add product form
POST   /products                    — Create product
GET    /products/:id/edit           — Edit product form
POST   /products/:id                — Update product
POST   /products/:id/deactivate     — Deactivate product
```

#### Stock Management (7.8)
```
GET    /stock                       — Stock Overview
GET    /stock/:productId/movements  — Movement history for product
POST   /stock/manual-add            — Manual stock addition
GET    /stock/add-from-supplier     — Add from Supplier form
POST   /stock/add-from-supplier     — Submit supplier stock receipt
GET    /stock/pending-issuances     — Pending Issuance Requests
POST   /stock/issuances/:id/approve — Approve issuance
GET    /stock/pending-returns       — Pending Return Requests
POST   /stock/returns/:id/approve   — Approve return (with optional sale value edit)
GET    /stock/requirement-report    — Stock Requirement Report
```

#### Order Management (7.9)
```
GET    /orders                      — Pending Orders
GET    /orders/converted            — Converted Bills
GET    /orders/consolidated         — Consolidated Stock View
POST   /orders/:id/edit-quantities  — Edit order quantities
POST   /orders/:id/convert          — Convert to Bill
GET    /orders/bills/:id/print      — Print bill (CBL Salesflo format)
```

#### Direct Shop Sales (7.10)
```
GET    /direct-sales/new            — New Bill form
POST   /direct-sales                — Create direct sale bill
GET    /direct-sales                — All Direct Bills
GET    /direct-sales/:id/print      — Print bill
```

#### Cash Recovery & Bill Settlement (7.11)
```
GET    /cash-recovery/outstanding   — Outstanding Bills
POST   /cash-recovery/assign        — Assign bills to order booker
GET    /cash-recovery/settlement    — Bill Settlement (Delivery Man)
POST   /cash-recovery/settlement    — Record delivery man payment
GET    /cash-recovery/pending       — Pending Verifications
POST   /cash-recovery/verify/:id    — Verify recovery collection
GET    /cash-recovery/history       — Recovery History
```

#### Supplier / Company Management (7.12)
```
GET    /suppliers                   — All Suppliers
POST   /suppliers                   — Create supplier
GET    /suppliers/:id               — Supplier Details
POST   /suppliers/:id/advance       — Record Advance
GET    /suppliers/:id/claims        — Claims list
POST   /suppliers/:id/claims        — Add new claim
POST   /suppliers/:id/claims/:cid/clear — Mark claim as Cleared
```

#### Centralized Cash Screen (7.13)
```
GET    /centralized-cash            — Daily View (default)
GET    /centralized-cash/monthly    — Monthly View
```

#### Staff Salary Management (7.14)
```
GET    /salaries                    — Salary Management (tabs: Salesmen | Order Bookers | Delivery Men)
POST   /salaries/record             — Record monthly salary
POST   /salaries/advance            — Record salary advance
POST   /salaries/clearance          — Month-End Clearance
GET    /salaries/export/:staffId    — Export salary history
POST   /salaries/delivery-men       — Add delivery man
POST   /salaries/delivery-men/:id   — Edit delivery man
POST   /salaries/delivery-men/:id/deactivate — Deactivate delivery man
```

#### Expenses Management (7.15)
```
GET    /expenses                    — All Expenses
POST   /expenses                    — Add Expense
```

#### Reports (7.16)
```
GET    /reports/daily-sales         — Daily Sales Report
GET    /reports/monthly-sales       — Monthly Sales Report
GET    /reports/order-booker-performance — Order Booker Performance Report
GET    /reports/salesman-performance — Salesman Performance Report
GET    /reports/stock-movement      — Stock Movement Report
GET    /reports/stock-requirement   — Stock Requirement Report
GET    /reports/shop-ledger         — Shop Ledger Report
GET    /reports/cash-recovery       — Cash Recovery Report
GET    /reports/supplier-advance    — Supplier Advance & Stock Report
GET    /reports/staff-salary        — Staff Salary Report
GET    /reports/claims              — Claims Report
GET    /reports/cash-flow           — Centralized Cash Flow Report
```
All report routes accept `?export=excel` query param to trigger Excel download.

#### Database Backup (7.17)
```
GET    /backup                      — Backup Settings + History
POST   /backup/settings             — Save backup time configuration
POST   /backup/run                  — Trigger manual backup
GET    /backup/download/:filename   — Download backup file
POST   /backup/restore              — Restore from selected backup file
```


---

## Data Flow — Major Workflows

### Workflow 1: Morning Sync (Order Booker)

```
Mobile App                    Express Server              MySQL
    │                               │                       │
    │── GET /api/sync/morning ──────►│                       │
    │                               │── SELECT route_assignments WHERE user_id=X AND date=today ──►│
    │                               │◄─ routes[] ───────────────────────────────────────────────────│
    │                               │── SELECT shops WHERE route_id IN (...) ──────────────────────►│
    │                               │── SELECT products WHERE is_active=1 ────────────────────────►│
    │                               │── SELECT shop_last_prices ──────────────────────────────────►│
    │                               │── SELECT bill_recovery_assignments WHERE booker=X AND date=today ──►│
    │◄─ JSON payload ───────────────│                       │
    │   (routes, shops, products,   │                       │
    │    prices, stock, assignments)│                       │
    │                               │                       │
    │ [Store all in sqflite/Hive]   │                       │
```

### Workflow 2: Evening Sync (Order Booker)

```
Mobile App                    Express Server              MySQL
    │                               │                       │
    │── POST /api/sync/evening ─────►│                       │
    │   { orders[], collections[] } │                       │
    │                               │ For each order:       │
    │                               │── Check stock availability ──────────────────────────────────►│
    │                               │── INSERT orders, order_items ───────────────────────────────►│
    │                               │── Adjust quantities if stock insufficient ───────────────────►│
    │                               │                       │
    │                               │ For each collection:  │
    │                               │── INSERT recovery_collections ──────────────────────────────►│
    │                               │── UPDATE bill_recovery_assignments.status ───────────────────►│
    │                               │                       │
    │◄─ { adjustments[], errors[] } │                       │
```

### Workflow 3: Order to Bill Conversion

```
Admin (Web Panel)             StockService / BillService   MySQL
    │                               │                       │
    │── POST /orders/:id/convert ──►│                       │
    │                               │── BEGIN TRANSACTION ─►│
    │                               │── SELECT order + items ────────────────────────────────────►│
    │                               │── For each item: check stock ──────────────────────────────►│
    │                               │   IF stock < quantity: ROLLBACK, return 422                 │
    │                               │── UPDATE products.current_stock (deduct) ───────────────────►│
    │                               │── INSERT stock_movements (bill_deduction) ──────────────────►│
    │                               │── Generate bill_number (OB-YYYY-MM-NNNNN) ──────────────────►│
    │                               │── Check shop advance balance ──────────────────────────────►│
    │                               │── INSERT bills (with advance_deducted) ─────────────────────►│
    │                               │── INSERT bill_items ────────────────────────────────────────►│
    │                               │── INSERT shop_ledger_entries (bill) ────────────────────────►│
    │                               │── UPDATE shop_advances.remaining_balance ───────────────────►│
    │                               │── UPDATE shop_last_prices ──────────────────────────────────►│
    │                               │── UPDATE orders.status = 'converted' ──────────────────────►│
    │                               │── INSERT audit_log ─────────────────────────────────────────►│
    │                               │── COMMIT ──────────────────────────────────────────────────►│
    │◄─ redirect to bill view ──────│                       │
```

### Workflow 4: Salesman Issuance Approval

```
Admin (Web Panel)             StockService                 MySQL
    │                               │                       │
    │── POST /stock/issuances/:id/approve ──────────────────►│
    │                               │── BEGIN TRANSACTION ─►│
    │                               │── SELECT issuance + items ─────────────────────────────────►│
    │                               │── For each item: check stock ──────────────────────────────►│
    │                               │   IF stock < quantity: ROLLBACK, return 422                 │
    │                               │── UPDATE products.current_stock (deduct) ───────────────────►│
    │                               │── INSERT stock_movements (issuance_salesman) ───────────────►│
    │                               │── UPDATE salesman_issuances.status = 'approved' ────────────►│
    │                               │── INSERT audit_log ─────────────────────────────────────────►│
    │                               │── COMMIT ──────────────────────────────────────────────────►│
    │◄─ success response ───────────│                       │
```

### Workflow 5: Midnight Cron Job

```
node-cron (00:00 daily)       CronService                  MySQL
    │                               │                       │
    │── trigger ────────────────────►│                       │
    │                               │── BEGIN TRANSACTION ─►│
    │                               │── UPDATE bill_recovery_assignments ────────────────────────►│
    │                               │   SET status='returned_to_pool', returned_at=NOW()          │
    │                               │   WHERE assigned_date < CURDATE()                           │
    │                               │   AND status IN ('assigned','partially_recovered')          │
    │                               │── INSERT audit_log (MIDNIGHT_CRON) ────────────────────────►│
    │                               │── COMMIT ──────────────────────────────────────────────────►│
    │                               │── Log result (count of returned assignments) ───────────────►│
```

### Workflow 6: Recovery Verification

```
Admin (Web Panel)             RecoveryService              MySQL
    │                               │                       │
    │── POST /cash-recovery/verify/:id ──────────────────────►│
    │                               │── BEGIN TRANSACTION ─►│
    │                               │── SELECT recovery_collection + bill ───────────────────────►│
    │                               │── UPDATE bills.amount_paid += amount_collected ─────────────►│
    │                               │── UPDATE bills.outstanding_amount -= amount_collected ───────►│
    │                               │── UPDATE bills.status (partially_paid or cleared) ───────────►│
    │                               │── UPDATE bill_recovery_assignments.status ───────────────────►│
    │                               │── INSERT shop_ledger_entries (recovery) ────────────────────►│
    │                               │── INSERT centralized_cash_entries (recovery) ───────────────►│
    │                               │── UPDATE recovery_collections.verified_by/verified_at ───────►│
    │                               │── INSERT audit_log ─────────────────────────────────────────►│
    │                               │── COMMIT ──────────────────────────────────────────────────►│
    │◄─ success response ───────────│                       │
```


---

## Project Structure

```
web-admin-panel/
├── src/
│   ├── config/
│   │   ├── db.js               — MySQL connection pool (mysql2/promise)
│   │   ├── session.js          — express-session + MySQL session store
│   │   └── cron.js             — node-cron midnight job registration
│   ├── controllers/
│   │   ├── DashboardController.js
│   │   ├── CompanyProfileController.js
│   │   ├── UserController.js
│   │   ├── RouteController.js
│   │   ├── RouteAssignmentController.js
│   │   ├── ShopController.js
│   │   ├── ProductController.js
│   │   ├── StockController.js
│   │   ├── OrderController.js
│   │   ├── DirectSalesController.js
│   │   ├── CashRecoveryController.js
│   │   ├── SupplierController.js
│   │   ├── CentralizedCashController.js
│   │   ├── SalaryController.js
│   │   ├── ExpenseController.js
│   │   ├── ReportController.js
│   │   └── BackupController.js
│   ├── models/
│   │   ├── UserModel.js            — users, delivery_men
│   │   ├── RouteModel.js           — routes, route_assignments
│   │   ├── ShopModel.js            — shops, shop_ledger_entries, shop_advances, shop_last_prices
│   │   ├── ProductModel.js         — products, stock_movements
│   │   ├── SupplierModel.js        — supplier_companies, supplier_advances, stock_receipts, claims
│   │   ├── OrderModel.js           — orders, order_items
│   │   ├── BillModel.js            — bills, bill_items
│   │   ├── IssuanceModel.js        — salesman_issuances, issuance_items, salesman_returns, return_items
│   │   ├── RecoveryModel.js        — bill_recovery_assignments, recovery_collections
│   │   ├── CashModel.js            — centralized_cash_entries, delivery_man_collections
│   │   ├── SalaryModel.js          — salary_records, salary_advances
│   │   ├── ExpenseModel.js         — expenses
│   │   ├── AuditModel.js           — audit_log
│   │   └── CompanyProfileModel.js  — company_profile
│   ├── services/
│   │   ├── StockService.js
│   │   ├── BillService.js
│   │   ├── OrderService.js
│   │   ├── RecoveryService.js
│   │   ├── SalaryService.js
│   │   ├── SupplierService.js
│   │   ├── SyncService.js
│   │   ├── ReportService.js
│   │   ├── BackupService.js
│   │   └── CronService.js
│   ├── routes/
│   │   ├── web/
│   │   │   ├── dashboard.js
│   │   │   ├── companyProfile.js
│   │   │   ├── users.js
│   │   │   ├── routes.js
│   │   │   ├── routeAssignments.js
│   │   │   ├── shops.js
│   │   │   ├── products.js
│   │   │   ├── stock.js
│   │   │   ├── orders.js
│   │   │   ├── directSales.js
│   │   │   ├── cashRecovery.js
│   │   │   ├── suppliers.js
│   │   │   ├── centralizedCash.js
│   │   │   ├── salaries.js
│   │   │   ├── expenses.js
│   │   │   ├── reports.js
│   │   │   └── backup.js
│   │   └── api/
│   │       ├── auth.js
│   │       └── sync.js
│   ├── views/
│   │   ├── layout/
│   │   │   ├── main.ejs            — Base layout with nav
│   │   │   └── nav.ejs             — Navigation sidebar
│   │   ├── dashboard/
│   │   │   └── index.ejs
│   │   ├── company-profile/
│   │   │   └── index.ejs
│   │   ├── users/
│   │   │   ├── index.ejs           — Tabs: Order Bookers | Salesmen
│   │   │   └── form.ejs
│   │   ├── routes/
│   │   │   ├── index.ejs           — All Routes
│   │   │   └── detail.ejs          — Route Details
│   │   ├── route-assignments/
│   │   │   └── index.ejs           — Assign Today | View by Date | View by Booker
│   │   ├── shops/
│   │   │   ├── index.ejs           — All Shops
│   │   │   ├── detail.ejs          — Shop Details
│   │   │   └── ledger.ejs          — Shop Ledger
│   │   ├── products/
│   │   │   ├── index.ejs
│   │   │   └── form.ejs
│   │   ├── stock/
│   │   │   ├── overview.ejs        — Stock Overview
│   │   │   ├── manual-add.ejs
│   │   │   ├── from-supplier.ejs
│   │   │   ├── pending-issuances.ejs
│   │   │   ├── pending-returns.ejs
│   │   │   └── requirement-report.ejs
│   │   ├── orders/
│   │   │   ├── pending.ejs         — Pending Orders
│   │   │   ├── converted.ejs       — Converted Bills
│   │   │   ├── consolidated.ejs    — Consolidated Stock View
│   │   │   └── print-bill.ejs      — CBL Salesflo print format
│   │   ├── direct-sales/
│   │   │   ├── new.ejs
│   │   │   └── index.ejs
│   │   ├── cash-recovery/
│   │   │   ├── outstanding.ejs     — Outstanding Bills
│   │   │   ├── settlement.ejs      — Bill Settlement (Delivery Man)
│   │   │   ├── pending.ejs         — Pending Verifications
│   │   │   └── history.ejs         — Recovery History
│   │   ├── suppliers/
│   │   │   ├── index.ejs           — All Suppliers
│   │   │   └── detail.ejs          — Supplier Details + Claims
│   │   ├── centralized-cash/
│   │   │   └── index.ejs           — Daily View | Monthly View
│   │   ├── salaries/
│   │   │   └── index.ejs           — Tabs: Salesmen | Order Bookers | Delivery Men
│   │   ├── expenses/
│   │   │   └── index.ejs
│   │   ├── reports/
│   │   │   └── index.ejs
│   │   └── backup/
│   │       └── index.ejs
│   ├── middleware/
│   │   ├── auth.js                 — Session check, redirect to /login
│   │   ├── audit.js                — Audit log writer
│   │   └── stockValidation.js      — Pre-deduction stock check
│   └── utils/
│       ├── billNumberGenerator.js  — OB/DS/SM-YYYY-MM-NNNNN
│       ├── excelExport.js          — ExcelJS report generation
│       └── printFormatter.js       — CBL Salesflo bill format
│
mobile-app/
├── lib/
│   ├── models/
│   │   ├── local_route.dart
│   │   ├── local_shop.dart
│   │   ├── local_product.dart
│   │   ├── local_order.dart
│   │   ├── local_recovery_assignment.dart
│   │   ├── local_issuance.dart
│   │   └── local_return.dart
│   ├── screens/
│   │   ├── shared/
│   │   │   ├── connection_screen.dart
│   │   │   └── login_screen.dart
│   │   ├── order_booker/
│   │   │   ├── home_screen.dart
│   │   │   ├── routes_screen.dart
│   │   │   ├── order_booking_screen.dart
│   │   │   ├── recovery_tab_screen.dart
│   │   │   ├── sync_screen.dart
│   │   │   └── summary_screen.dart
│   │   └── salesman/
│   │       ├── home_screen.dart
│   │       ├── stock_issuance_screen.dart
│   │       ├── stock_return_screen.dart
│   │       ├── sync_screen.dart
│   │       └── summary_screen.dart
│   ├── services/
│   │   ├── api_service.dart        — HTTP client, JWT management
│   │   ├── sync_service.dart       — Sync orchestration
│   │   └── local_db_service.dart   — sqflite/Hive operations
│   └── widgets/
│       ├── product_search_widget.dart
│       ├── quantity_entry_widget.dart
│       └── sync_progress_widget.dart
```


---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Stock Non-Negativity

*For any* warehouse stock deduction operation (order-to-bill conversion, direct shop sale, salesman issuance approval), the resulting `current_stock_cartons` and `current_stock_loose` for every product must be greater than or equal to zero.

**Validates: Requirements 6.1, 8.4, 9.3, 10.5, 24.6**

---

### Property 2: Bill Amount Integrity

*For any* bill in the system, the following invariants must hold simultaneously:
- `net_amount = gross_amount - advance_deducted`
- `outstanding_amount = net_amount - amount_paid`
- `outstanding_amount >= 0`

**Validates: Requirements 8.3, 8.7, 9.2, 11.7**

---

### Property 3: Supplier Advance Balance Integrity

*For any* supplier company, the `current_advance_balance` must equal the sum of all recorded advances minus the sum of all stock receipt values plus the sum of all cleared claim values:
- `balance = SUM(supplier_advances.amount) - SUM(stock_receipts.total_value) + SUM(claims.claim_value WHERE status='cleared')`

**Validates: Requirements 7.2, 7.3, 7.6**

---

### Property 4: Shop Ledger Append-Only Invariant

*For any* shop and any sequence of operations, the count of `shop_ledger_entries` for that shop must never decrease. No UPDATE or DELETE operations are ever performed on this table.

**Validates: Requirements 13.1, 13.2, 24.5**

---

### Property 5: Recovery Assignment Uniqueness

*For any* bill, there must be at most one `bill_recovery_assignment` with status not equal to `returned_to_pool` at any point in time.

**Validates: Requirements 11.3**

---

### Property 6: Midnight Cron Completeness

*For any* set of `bill_recovery_assignments` from the previous calendar day with status `assigned` or `partially_recovered`, after the midnight cron job runs, all such assignments must have status `returned_to_pool` and a non-null `returned_at` timestamp.

**Validates: Requirements 12.2, 12.3**

---

### Property 7: Salesman Issuance Uniqueness Per Day

*For any* salesman and any calendar date, there must be at most one `salesman_issuances` record with that `(salesman_id, issuance_date)` combination.

**Validates: Requirements 10.1, 10.2, 23.3**

---

### Property 8: Route Assignment Uniqueness Per Day

*For any* route and any calendar date, there must be at most one `route_assignments` record with that `(route_id, assignment_date)` combination.

**Validates: Requirements 4.2**

---

### Property 9: Stock Movement Completeness

*For any* warehouse stock change (manual add, supplier receipt, bill deduction, issuance, return, direct sale), a corresponding `stock_movements` record must exist with the correct `movement_type`, quantities, and `stock_after` snapshot.

**Validates: Requirements 6.4, 6.5**

---

### Property 10: Salesman Sale Value Calculation

*For any* approved `salesman_return`, the `system_sale_value` must equal the sum over all return items of `(sold_cartons * units_per_carton + sold_loose) * retail_price`, where `sold_cartons = issued_cartons - returned_cartons` and `sold_loose = issued_loose - returned_loose`.

**Validates: Requirements 10.7, 10.11**

---

### Property 11: Shop Ledger Entry Per Bill

*For any* bill created (regardless of type: `order_booker`, `direct_shop`, or `salesman`), exactly one `shop_ledger_entries` record of type `bill` must exist referencing that bill.

**Validates: Requirements 8.6, 9.4, 13.1**

---

### Property 12: Advance Auto-Deduction on Bill Creation

*For any* bill created for a shop with a remaining `shop_advances.remaining_balance > 0`, the bill's `advance_deducted` must equal `MIN(gross_amount, remaining_balance)` and the shop advance's `remaining_balance` must be decremented by the same amount.

**Validates: Requirements 8.7, 9.5, 13.6**

---

### Property 13: Centralized Cash Entry Integrity

*For any* cash event — (a) salesman return approval, (b) admin verification of a recovery collection, (c) admin recording a delivery man bill settlement — exactly one `centralized_cash_entries` record must be created with the correct `entry_type`, `reference_id`, `amount`, `cash_date`, and `recorded_by`.

**Validates: Requirements 14.3, 14.4**

---

### Property 14: Salary Running Balance Accuracy

*For any* salary record, the running balance displayed must equal `basic_salary - total_advances_paid`, where `total_advances_paid` is the sum of all `salary_advances.amount` for that staff member in that month and year.

**Validates: Requirements 15.4**

---

### Property 15: Salary Record Uniqueness Per Month

*For any* staff member (salesman, order booker, or delivery man), there must be at most one `salary_records` entry for a given `(staff_id, staff_type, month, year)` combination.

**Validates: Requirements 15.6**

---

### Property 16: Audit Log Append-Only Invariant

*For any* sequence of system operations, the count of `audit_log` entries must never decrease. Every create, update, approve, and verify action must produce exactly one new audit log entry.

**Validates: Requirements 19.1, 19.2**

---

### Property 17: Password Storage Security

*For any* user account in the system, the stored `password_hash` must never equal the plaintext password string. The hash must be a valid bcrypt hash (starts with `$2b$` or `$2a$`).

**Validates: Requirements 1.6**

---

### Property 18: SKU Code Uniqueness

*For any* two distinct products in the system, their `sku_code` values must differ. Any attempt to create a product with a duplicate SKU must be rejected.

**Validates: Requirements 5.1, 5.2**

---

### Property 19: Route Name Uniqueness

*For any* two distinct active routes in the system, their `name` values must differ. Any attempt to create a route with a duplicate name must be rejected.

**Validates: Requirements 3.1**

---

### Property 20: Evening Sync Stock Adjustment

*For any* order item uploaded during evening sync where the ordered quantity exceeds available warehouse stock, the `final_cartons`/`final_loose` on the `order_items` record must be capped at the available stock quantity (or zero if completely out of stock), and a `stock_check_note` must be recorded on the order.

**Validates: Requirements 8.9, 21.8**

---

### Property 21: Bill Number Uniqueness and Format

*For any* two bills in the system, their `bill_number` values must differ. Every bill number must match the pattern `[TYPE_PREFIX]-[YYYY]-[MM]-[NNNNN]` where TYPE_PREFIX is `OB`, `DS`, or `SM` corresponding to the bill type.

**Validates: Requirements 24.7**

---

### Property 22: Deactivated User Login Rejection

*For any* user with `is_active = 0`, any login attempt with that user's credentials must be rejected regardless of whether the password is correct.

**Validates: Requirements 2.3, 2.6**

---

### Property 23: Morning Sync Data Completeness

*For any* order booker performing a morning sync, the downloaded payload must contain: all routes assigned to that booker for today, all shops within those routes, all active products with prices, `shop_last_prices` for all shop+product combinations, current warehouse stock levels, and all `bill_recovery_assignments` for that booker with `assigned_date = today` that were created before the sync time.

**Validates: Requirements 21.1**

---

### Property 24: Claim Products Never Enter Warehouse Stock

*For any* claim recorded against a supplier, the warehouse stock levels of the claimed products must remain unchanged after the claim is recorded (regardless of whether the claim is pending or cleared).

**Validates: Requirements 7.5**

---

### Property 25: Company Profile on All Bills

*For any* printed bill or exported report, the output must contain the company name, logo path, address, and GST/NTN number from the `company_profile` table.

**Validates: Requirements 17.2, 24.3**


---

## Error Handling

### Stock Deduction Errors

All stock deduction operations (order conversion, direct sale, issuance approval) must:
1. Check stock availability at the application layer before executing the transaction
2. Wrap the entire operation in a MySQL transaction
3. Return HTTP 422 with a descriptive error message if stock would go negative
4. Roll back the transaction on any failure
5. Never rely solely on the DB CHECK constraint — application-level validation is the primary guard

```javascript
// StockService pattern
async deductStock(productId, cartons, loose, conn) {
  const [product] = await conn.query(
    'SELECT current_stock_cartons, current_stock_loose FROM products WHERE id = ? FOR UPDATE',
    [productId]
  );
  if (product.current_stock_cartons < cartons || product.current_stock_loose < loose) {
    throw new StockInsufficientError(productId, cartons, loose, product);
  }
  await conn.query(
    'UPDATE products SET current_stock_cartons = current_stock_cartons - ?, current_stock_loose = current_stock_loose - ? WHERE id = ?',
    [cartons, loose, productId]
  );
}
```

### Transaction Boundaries

Every multi-table write operation uses a MySQL transaction:
- Order-to-bill conversion: orders + bill + bill_items + stock_movements + shop_ledger + shop_advances + shop_last_prices + audit_log
- Issuance approval: issuance status + stock_movements + products stock + audit_log
- Return approval: return status + stock_movements + products stock + centralized_cash + audit_log
- Recovery verification: recovery_collections + bills + shop_ledger + centralized_cash + audit_log
- Supplier stock receipt: stock_receipts + stock_receipt_items + products stock + stock_movements + supplier_companies balance + audit_log

### Midnight Cron Failure Handling

If the midnight cron job fails:
- The error is caught, logged to a `cron_errors` log file with timestamp and stack trace
- The job retries on the next scheduled execution (next midnight)
- Admin sees a dashboard alert if the previous midnight job did not complete successfully
- The cron job is idempotent: re-running it on already-returned assignments has no effect

### Mobile Sync Error Handling

- Individual record failures during sync do not abort the entire sync
- Failed records are returned in the response with error details
- The mobile app displays per-record success/failure status
- Failed records remain in the local pending queue for retry on next sync

### Duplicate Submission Guards

- Route assignment: `UNIQUE KEY uq_route_date` — DB rejects duplicate, controller returns 409
- Salesman issuance: `UNIQUE KEY uq_salesman_date` — DB rejects duplicate, controller returns 409
- Bill number: `UNIQUE KEY uq_bill_number` — generated with sequence lock to prevent race conditions
- SKU code: `UNIQUE KEY uq_sku` — DB rejects duplicate, controller returns 409

### Authentication Errors

- Unauthenticated web panel requests: redirect to `/login` with flash message
- Unauthenticated API requests: return HTTP 401 JSON `{ error: 'Unauthorized' }`
- Deactivated user login: return HTTP 403 with message "Account is deactivated"
- Invalid JWT: return HTTP 401

---

## Testing Strategy

### Dual Testing Approach

Both unit tests and property-based tests are required. They are complementary:
- **Unit tests** verify specific examples, integration points, and edge cases
- **Property tests** verify universal invariants across randomly generated inputs

### Property-Based Testing

**Library:** `fast-check` (Node.js) for web panel services; `dart_test` + custom generators for Flutter.

**Configuration:** Minimum 100 iterations per property test.

**Tag format:** `// Feature: shakeel-traders-distribution-system, Property N: <property_text>`

Each correctness property maps to exactly one property-based test:

| Property | Test File | Generator Strategy |
|---|---|---|
| P1: Stock Non-Negativity | `tests/pbt/stock.test.js` | Generate random products with stock levels, random deduction amounts including amounts > stock |
| P2: Bill Amount Integrity | `tests/pbt/bill.test.js` | Generate random gross amounts, advance amounts, payment amounts |
| P3: Supplier Advance Balance | `tests/pbt/supplier.test.js` | Generate random sequences of advances, receipts, and cleared claims |
| P4: Shop Ledger Append-Only | `tests/pbt/shopLedger.test.js` | Generate random sequences of bill/payment/recovery operations |
| P5: Recovery Assignment Uniqueness | `tests/pbt/recovery.test.js` | Generate random bills and assignment sequences |
| P6: Midnight Cron Completeness | `tests/pbt/cron.test.js` | Generate random sets of assignments from previous day |
| P7: Salesman Issuance Uniqueness | `tests/pbt/issuance.test.js` | Generate random salesman+date combinations with duplicate attempts |
| P8: Route Assignment Uniqueness | `tests/pbt/routeAssignment.test.js` | Generate random route+date combinations with duplicate attempts |
| P9: Stock Movement Completeness | `tests/pbt/stockMovement.test.js` | Generate random stock operations, verify movement records |
| P10: Salesman Sale Value | `tests/pbt/saleValue.test.js` | Generate random issuance/return quantities and prices |
| P11: Shop Ledger Entry Per Bill | `tests/pbt/billLedger.test.js` | Generate random bills of all three types |
| P12: Advance Auto-Deduction | `tests/pbt/advanceDeduction.test.js` | Generate random advance balances and bill amounts |
| P13: Centralized Cash Integrity | `tests/pbt/centralizedCash.test.js` | Generate random cash events across all three triggers |
| P14: Salary Running Balance | `tests/pbt/salary.test.js` | Generate random salary records and advance sequences |
| P15: Salary Record Uniqueness | `tests/pbt/salaryUniqueness.test.js` | Generate random staff+month+year combinations with duplicates |
| P16: Audit Log Append-Only | `tests/pbt/auditLog.test.js` | Generate random sequences of auditable actions |
| P17: Password Security | `tests/pbt/auth.test.js` | Generate random plaintext passwords, verify hash != plaintext |
| P18: SKU Uniqueness | `tests/pbt/sku.test.js` | Generate random product creation sequences with duplicate SKUs |
| P19: Route Name Uniqueness | `tests/pbt/routeName.test.js` | Generate random route creation sequences with duplicate names |
| P20: Evening Sync Stock Adjustment | `tests/pbt/syncAdjustment.test.js` | Generate random orders with quantities exceeding stock |
| P21: Bill Number Format | `tests/pbt/billNumber.test.js` | Generate random bill creation sequences, verify format and uniqueness |
| P22: Deactivated User Rejection | `tests/pbt/auth.test.js` | Generate random deactivated users, verify login rejection |
| P23: Morning Sync Completeness | `tests/pbt/sync.test.js` | Generate random booker assignments, verify all data present in payload |
| P24: Claim Stock Invariant | `tests/pbt/claims.test.js` | Generate random claims, verify stock unchanged before and after |
| P25: Company Profile on Bills | `tests/pbt/billPrint.test.js` | Generate random bills, verify company profile fields in output |

### Unit Tests

Unit tests focus on:
- **Specific examples**: bill number generation format, CSV import parsing, Excel export structure
- **Integration points**: controller → service → model call chains
- **Edge cases**: zero-quantity orders, shops with no advance, bills with full advance coverage, empty sync payloads
- **Error conditions**: duplicate SKU rejection, negative stock rejection, deactivated user login rejection

**Library:** `jest` (Node.js), `flutter_test` (Flutter)

**Key unit test files:**
```
tests/unit/
├── billNumberGenerator.test.js   — Format and uniqueness examples
├── csvImport.test.js             — Valid and invalid CSV parsing
├── excelExport.test.js           — Report structure validation
├── syncPayload.test.js           — Payload assembly for morning sync
├── cronJob.test.js               — Cron logic with mock DB
└── printFormatter.test.js        — CBL Salesflo format output
```

### Test Database

- All tests run against a dedicated test MySQL database (`shakeel_traders_test`)
- Each test suite resets relevant tables using `beforeEach` transactions that are rolled back
- Property tests use `fast-check` model-based testing against the actual service layer with a test DB connection

