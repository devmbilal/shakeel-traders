# Implementation Plan: Shakeel Traders Distribution Order System

## Overview

Incremental implementation starting with the database layer, then the web admin panel (all 17 pages in dependency order), then the mobile app. Every multi-table write is wrapped in a MySQL transaction. Stock non-negativity is enforced at both the DB CHECK constraint and application layer. All 25 correctness properties have corresponding property-based tests using fast-check.

**Tech stack:** Node.js + Express + EJS + Bootstrap (web), Flutter Android (mobile), MySQL 8.x InnoDB.

---

## Tasks

- [x] 1. Phase 1 — Database Setup & Migrations
  - [x] 1.1 Initialise the web-admin-panel project scaffold
    - Create `Shakeel Traders/web-admin-panel/` directory with `package.json` (express, mysql2, express-session, bcryptjs, connect-mysql2, node-cron, exceljs, multer, fast-check, jest)
    - Create `src/config/db.js` — mysql2/promise connection pool, env-driven host/port/user/pass/db
    - Create `.env.example` with all required variables (DB_HOST, DB_PORT, DB_USER, DB_PASS, DB_NAME, SESSION_SECRET, BACKUP_DIR, PORT)
    - Create `src/app.js` — Express app wiring (session, static, body-parser, router mounts)
    - _Requirements: 1.1_

  - [x] 1.2 Write and run all database migrations (Groups A–L)
    - Create `src/db/migrations/001_users_delivery_men.sql` — `users`, `delivery_men` tables with all constraints
    - Create `src/db/migrations/002_routes_shops.sql` — `routes`, `route_assignments`, `shops` tables
    - Create `src/db/migrations/003_products_stock.sql` — `products` (with CHECK constraint), `stock_movements` tables
    - Create `src/db/migrations/004_suppliers.sql` — `supplier_companies`, `supplier_advances`, `stock_receipts`, `stock_receipt_items`, `claims`, `claim_items`
    - Create `src/db/migrations/005_orders_bills.sql` — `orders`, `order_items`, `bills`, `bill_items`
    - Create `src/db/migrations/006_shop_ledger.sql` — `shop_ledger_entries`, `shop_advances`
    - Create `src/db/migrations/007_salesman_workflow.sql` — `salesman_issuances`, `issuance_items`, `salesman_returns`, `return_items`
    - Create `src/db/migrations/008_cash_recovery.sql` — `bill_recovery_assignments`, `recovery_collections`
    - Create `src/db/migrations/009_cash_screen.sql` — `centralized_cash_entries`, `delivery_man_collections`
    - Create `src/db/migrations/010_salary.sql` — `salary_records`, `salary_advances`
    - Create `src/db/migrations/011_expenses_audit.sql` — `expenses`, `audit_log`
    - Create `src/db/migrations/012_supporting.sql` — `shop_last_prices`, `company_profile`
    - Create `src/db/migrate.js` — migration runner that executes all SQL files in order
    - _Requirements: 1.1, 5.2, 6.1, 24.5, 24.6_

  - [x] 1.3 Create database seed file for development
    - Create `src/db/seed.js` — inserts one admin user (bcrypt-hashed password), sample routes, shops, products, and a company_profile row (id=1)
    - _Requirements: 1.6, 17.1_


- [x] 2. Phase 2 — Web Panel Foundation (Auth, Middleware, Layout)
  - [x] 2.1 Implement admin authentication (login/logout)
    - Create `src/controllers/AuthController.js` — GET /login (render form), POST /login (bcrypt verify, set session), POST /logout (destroy session)
    - Create `src/routes/web/auth.js` — mount login/logout routes (no auth middleware on these)
    - Create `src/views/auth/login.ejs` — login form with Bootstrap styling
    - _Requirements: 1.2, 1.6, 2.6_

  - [x] 2.2 Implement session auth middleware
    - Create `src/middleware/auth.js` — checks `req.session.user`; redirects to `/login` with flash message if absent; attaches user to `res.locals`
    - Apply middleware to all web routes except `/login`
    - _Requirements: 1.2_

  - [x] 2.3 Implement audit log middleware
    - Create `src/middleware/audit.js` — wraps mutating POST routes; after successful response, inserts one row into `audit_log` capturing `user_id`, `action`, `entity_type`, `entity_id`, `old_value` (JSON), `new_value` (JSON), `ip_address`, `created_at`
    - Create `src/models/AuditModel.js` — `insertLog(data)` method; never runs UPDATE or DELETE on audit_log
    - _Requirements: 19.1, 19.2_

  - [x] 2.4 Implement stock validation middleware
    - Create `src/middleware/stockValidation.js` — pre-deduction check using `SELECT ... FOR UPDATE` inside a transaction; throws 422 with descriptive message if stock would go negative
    - _Requirements: 6.1, 24.6_

  - [x] 2.5 Create base EJS layout and navigation
    - Create `src/views/layout/main.ejs` — Bootstrap 5 base layout with sidebar nav, flash message area, and `<%- body %>` block
    - Create `src/views/layout/nav.ejs` — sidebar with links to all 17 pages; active state highlighting
    - Create `src/utils/flash.js` — helper to set/read flash messages via session
    - _Requirements: 1.2_


- [x] 3. Phase 3 — Core Master Data (Company Profile, Users, Routes, Shops, Products)
  - [x] 3.1 Implement Company Profile page (SRS 7.2)
    - Create `src/models/CompanyProfileModel.js` — `getProfile()`, `upsertProfile(data)` (always upserts id=1)
    - Create `src/controllers/CompanyProfileController.js` — GET renders form pre-filled; POST saves and redirects
    - Create `src/routes/web/companyProfile.js`
    - Create `src/views/company-profile/index.ejs` — form with all fields (name, owner, address, phones, email, GST/NTN, logo upload via multer)
    - _Requirements: 17.1_

  - [x] 3.2 Implement User Management page (SRS 7.3)
    - Create `src/models/UserModel.js` — `listByRole(role)`, `findById(id)`, `create(data)`, `update(id, data)`, `deactivate(id)`; no delete method
    - Create `src/controllers/UserController.js` — GET /users (tabs: Order Bookers | Salesmen), GET /users/new, POST /users (bcrypt hash password), GET /users/:id/edit, POST /users/:id, POST /users/:id/deactivate
    - Create `src/routes/web/users.js`
    - Create `src/views/users/index.ejs` — tabbed list with add/edit/deactivate actions
    - Create `src/views/users/form.ejs` — create/edit form
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.6_

  - [x] 3.3 Implement Route Management page (SRS 7.4)
    - Create `src/models/RouteModel.js` — `listAll()`, `findById(id)`, `create(name)`, `update(id, name)`, `deactivate(id)`, `getShopsInRoute(routeId)`, `addShopToRoute(routeId, shopId)`, `removeShopFromRoute(routeId, shopId)`
    - Create `src/controllers/RouteController.js` — full CRUD + shop assignment endpoints
    - Create `src/routes/web/routes.js`
    - Create `src/views/routes/index.ejs` — all routes list with shop count
    - Create `src/views/routes/detail.ejs` — route detail with shop list, add/remove shop controls
    - _Requirements: 3.1, 3.2, 3.6, 3.7_

  - [x] 3.4 Implement Route Assignment page (SRS 7.5)
    - Create `src/models/RouteModel.js` additions — `createAssignment(routeId, userId, date)`, `getAssignmentsByDate(date)`, `getAssignmentsByBooker(userId)` (enforce UNIQUE KEY uq_route_date, return 409 on duplicate)
    - Create `src/controllers/RouteAssignmentController.js` — GET (Assign Today view), POST (create assignment), GET /by-date, GET /by-booker
    - Create `src/routes/web/routeAssignments.js`
    - Create `src/views/route-assignments/index.ejs` — three tabs: Assign Today | View by Date | View by Booker
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [x] 3.5 Implement Shop Management page (SRS 7.6) — All Shops + Shop Details
    - Create `src/models/ShopModel.js` — `listAll()`, `findById(id)`, `create(data)`, `update(id, data)`, `bulkImportFromCSV(rows)` (validate route_id per row)
    - Create `src/controllers/ShopController.js` — GET /shops, GET /shops/new, POST /shops, POST /shops/import (multer CSV), GET /shops/:id, POST /shops/:id
    - Create `src/routes/web/shops.js`
    - Create `src/views/shops/index.ejs` — searchable list with route, type, outstanding balance; CSV import button
    - Create `src/views/shops/detail.ejs` — edit form including price_edit_allowed, price_min_pct, price_max_pct
    - _Requirements: 3.3, 3.4, 3.5, 3.6_

  - [x] 3.6 Implement Shop Ledger sub-page (SRS 7.6 — Shop Ledger tab)
    - Create `src/models/ShopModel.js` additions — `getLedgerEntries(shopId)`, `getCurrentBalance(shopId)`, `addAdvance(shopId, data)` (inserts shop_advances + shop_ledger_entries in transaction)
    - Add to `ShopController.js` — GET /shops/:id/ledger, POST /shops/:id/advance, GET /shops/:id/ledger/export (Excel via ExcelJS)
    - Create `src/views/shops/ledger.ejs` — chronological ledger table with balance column; Add Advance button; Export button
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_

  - [x] 3.7 Implement Product Management page (SRS 7.7)
    - Create `src/models/ProductModel.js` — `listAll(filter)`, `findById(id)`, `findBySku(sku)`, `create(data)`, `update(id, data)`, `deactivate(id)`, `getStockMovements(productId)`; no delete method
    - Create `src/controllers/ProductController.js` — full CRUD + deactivate; reject duplicate SKU with 409
    - Create `src/routes/web/products.js`
    - Create `src/views/products/index.ejs` — list with SKU, name, current stock (cartons + loose), prices; active/inactive filter
    - Create `src/views/products/form.ejs` — create/edit form with all fields
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_


- [x] 4. Phase 4 — Stock Management (SRS 7.8)
  - [x] 4.1 Implement StockService core (deduction + addition + movement recording)
    - Create `src/services/StockService.js` — `deductStock(productId, cartons, loose, conn)` (SELECT FOR UPDATE, check non-negativity, UPDATE products, INSERT stock_movements); `addStock(productId, cartons, loose, movementType, referenceId, referenceType, note, userId, conn)`
    - _Requirements: 6.1, 6.4, 24.6_

  - [x] 4.2 Implement Stock Overview and Manual Add (SRS 7.8)
    - Create `src/controllers/StockController.js` — GET /stock (overview: all products with current stock), GET /stock/:productId/movements (movement history), POST /stock/manual-add (calls StockService.addStock with type=manual_add, wraps in transaction, writes audit_log)
    - Create `src/routes/web/stock.js`
    - Create `src/views/stock/overview.ejs` — product list with cartons/loose stock; click product to see movement history
    - Create `src/views/stock/manual-add.ejs` — form: product selector, cartons, loose, date, note
    - _Requirements: 6.2, 6.3, 6.4_

  - [x] 4.3 Implement Add Stock from Supplier (SRS 7.8 + US-01)
    - Create `src/models/SupplierModel.js` — `listAll()`, `findById(id)`, `create(data)`, `recordAdvance(companyId, data)`, `recordStockReceipt(companyId, items, userId)` (transaction: INSERT stock_receipts + stock_receipt_items + UPDATE products stock + INSERT stock_movements + UPDATE supplier_companies.current_advance_balance)
    - Add to `StockController.js` — GET /stock/add-from-supplier (form: select supplier → product list), POST /stock/add-from-supplier (calls SupplierModel.recordStockReceipt in transaction)
    - Create `src/views/stock/from-supplier.ejs` — supplier selector, dynamic product rows with cartons/loose/unit_price
    - _Requirements: 6.5, 7.3, US-01_

  - [x] 4.4 Implement Pending Issuance Requests — Admin approval (SRS 7.8 + US-05)
    - Create `src/models/IssuanceModel.js` — `listPending()`, `findById(id)` (with items), `approve(id, adminId)` (transaction: UPDATE salesman_issuances.status='approved' + StockService.deductStock per item + INSERT stock_movements type=issuance_salesman + INSERT audit_log)
    - Add to `StockController.js` — GET /stock/pending-issuances, POST /stock/issuances/:id/approve (reject if stock insufficient with 422)
    - Create `src/views/stock/pending-issuances.ejs` — list of pending requests with product details; Approve button per request
    - _Requirements: 10.3, 10.4, 10.5, US-05_

  - [x] 4.5 Implement Pending Return Requests — Admin approval (SRS 7.8 + US-08)
    - Create `src/models/ReturnModel.js` — `listPending()`, `findById(id)` (with items, issued quantities, sold quantities, system_sale_value), `approve(id, adminId, finalSaleValue)` (transaction: UPDATE salesman_returns.status='approved' + StockService.addStock per returned item type=return_salesman + INSERT centralized_cash_entries type=salesman_sale + INSERT audit_log)
    - Add to `StockController.js` — GET /stock/pending-returns, POST /stock/returns/:id/approve (accepts optional edited sale value)
    - Create `src/views/stock/pending-returns.ejs` — shows issued/returned/sold quantities, system-calculated sale value, editable sale value field; Approve button
    - _Requirements: 10.6, 10.7, 10.8, 10.9, 10.10, 10.11, US-08_

  - [x] 4.6 Implement Stock Requirement Report (SRS 7.8)
    - Add to `StockController.js` — GET /stock/requirement-report (select order booker → aggregate pending order_items by product)
    - Create `src/views/stock/requirement-report.ejs` — booker selector, consolidated product quantity table
    - _Requirements: 6.6_


- [x] 5. Phase 5 — Order Management + Billing (SRS 7.9 + 7.10)
  - [x] 5.1 Implement BillService (bill creation, bill number generation, advance auto-deduction)
    - Create `src/utils/billNumberGenerator.js` — generates `OB/DS/SM-YYYY-MM-NNNNN`; uses SELECT MAX(bill_number) FOR UPDATE within transaction to ensure uniqueness under concurrent writes
    - Create `src/services/BillService.js` — `createBill(shopId, billType, items, userId, conn)`: generates bill_number, checks shop advance balance, computes gross_amount, advance_deducted, net_amount, outstanding_amount; INSERT bills + bill_items + shop_ledger_entries(bill) + UPDATE shop_advances.remaining_balance + UPSERT shop_last_prices per item; all in passed-in transaction connection
    - _Requirements: 8.3, 8.6, 8.7, 13.6, 24.7, 24.8_

  - [x] 5.2 Implement OrderService (order conversion to bill + evening sync stock adjustment)
    - Create `src/services/OrderService.js` — `convertOrderToBill(orderId, adminId)`: BEGIN TRANSACTION → SELECT order + items → StockService.deductStock per item (rollback on insufficient stock) → BillService.createBill → UPDATE orders.status='converted' → INSERT audit_log → COMMIT; `adjustOrderForStock(order, stockLevels)`: caps final_cartons/final_loose to available stock, sets stock_check_note
    - _Requirements: 8.2, 8.3, 8.4, 8.5, 8.9_

  - [x] 5.3 Implement Order Management page — Pending Orders (SRS 7.9 + US-10)
    - Create `src/models/OrderModel.js` — `listPending(filters)`, `findById(id)` (with items), `updateQuantities(id, items)`, `convertToBill(id, adminId)` (delegates to OrderService)
    - Create `src/controllers/OrderController.js` — GET /orders (pending, filterable by date/booker/route/shop), POST /orders/:id/edit-quantities, POST /orders/:id/convert
    - Create `src/routes/web/orders.js`
    - Create `src/views/orders/pending.ejs` — filterable table; per-order: edit quantities inline, Convert to Bill button
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [x] 5.4 Implement Converted Bills view + CBL Salesflo print (SRS 7.9)
    - Create `src/utils/printFormatter.js` — formats bill data + company_profile into CBL Salesflo HTML layout (company name, logo, address, NTN, bill items table, totals, advance deducted, net amount)
    - Add to `OrderController.js` — GET /orders/converted (list), GET /orders/bills/:id/print (renders print-bill.ejs)
    - Create `src/views/orders/converted.ejs` — list of converted bills with print button
    - Create `src/views/orders/print-bill.ejs` — print-optimised CBL Salesflo layout
    - Create `src/views/orders/consolidated.ejs` — consolidated stock view across all pending orders
    - _Requirements: 8.8, 17.2, 24.3_

  - [x] 5.5 Implement Direct Shop Sales page (SRS 7.10 + US-14)
    - Create `src/controllers/DirectSalesController.js` — GET /direct-sales/new (form), POST /direct-sales (BEGIN TRANSACTION → StockService.deductStock per item → BillService.createBill type=direct_shop → COMMIT → INSERT audit_log), GET /direct-sales (all direct bills), GET /direct-sales/:id/print
    - Create `src/routes/web/directSales.js`
    - Create `src/views/direct-sales/new.ejs` — shop selector, product search by SKU/name, quantity entry rows, confirm button
    - Create `src/views/direct-sales/index.ejs` — filterable list of direct bills with view/print
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, US-14_

- [ ] 6. Checkpoint — Ensure all tests pass, ask the user if questions arise.


- [x] 7. Phase 6 — Cash Recovery & Bill Settlement (SRS 7.11)
  - [x] 7.1 Implement RecoveryService
    - Create `src/services/RecoveryService.js` — `assignBillToBooker(billId, bookerId, adminId)`: validates bill has no active assignment (status != returned_to_pool), INSERT bill_recovery_assignments; `verifyCollection(collectionId, adminId)`: BEGIN TRANSACTION → UPDATE bills.amount_paid/outstanding_amount/status → UPDATE bill_recovery_assignments.status → INSERT shop_ledger_entries(recovery) → INSERT centralized_cash_entries(recovery) → UPDATE recovery_collections.verified_by/verified_at → INSERT audit_log → COMMIT
    - _Requirements: 11.3, 11.7_

  - [x] 7.2 Implement Outstanding Bills + Assignment (SRS 7.11 + US-06)
    - Create `src/models/RecoveryModel.js` — `listOutstandingBills(filters)`, `assignBills(billIds, bookerId, adminId)`, `listPendingVerifications()`, `findCollectionById(id)`, `verifyCollection(id, adminId)`, `listHistory(filters)`
    - Create `src/controllers/CashRecoveryController.js` — GET /cash-recovery/outstanding (filterable by route/shop/status), POST /cash-recovery/assign (calls RecoveryService.assignBillToBooker per bill)
    - Create `src/routes/web/cashRecovery.js`
    - Create `src/views/cash-recovery/outstanding.ejs` — bill list with checkboxes; booker selector; Assign button
    - _Requirements: 11.1, 11.2, 11.3, US-06_

  - [x] 7.3 Implement Bill Settlement — Delivery Man (SRS 7.11 + US-11)
    - Create `src/models/CashModel.js` — `recordDeliveryManCollection(billId, deliveryManId, amount, adminId)`: BEGIN TRANSACTION → INSERT delivery_man_collections → UPDATE bills.amount_paid/outstanding_amount/status → INSERT shop_ledger_entries(payment_delivery_man) → INSERT centralized_cash_entries(delivery_man_collection) → INSERT audit_log → COMMIT
    - Add to `CashRecoveryController.js` — GET /cash-recovery/settlement (list open bills), POST /cash-recovery/settlement (calls CashModel.recordDeliveryManCollection)
    - Create `src/views/cash-recovery/settlement.ejs` — bill selector, delivery man selector, amount field; full/partial payment handling
    - _Requirements: 11.8, 11.9, US-11_

  - [x] 7.4 Implement Pending Verifications + Recovery History (SRS 7.11 + US-13)
    - Add to `CashRecoveryController.js` — GET /cash-recovery/pending (list unverified collections), POST /cash-recovery/verify/:id (calls RecoveryService.verifyCollection), GET /cash-recovery/history (filterable by date/booker/shop/bill)
    - Create `src/views/cash-recovery/pending.ejs` — list of uploaded collections with booker, shop, bill, amount; Verify button
    - Create `src/views/cash-recovery/history.ejs` — full recovery history table with filters
    - _Requirements: 11.6, 11.7, 11.10, US-13_


- [x] 8. Phase 7 — Supplier Management, Centralized Cash, Salary, Expenses (SRS 7.12–7.15)
  - [x] 8.1 Implement Supplier / Company Management page (SRS 7.12 + US-16, US-17)
    - Complete `src/models/SupplierModel.js` — `listAll()`, `findById(id)`, `create(data)`, `recordAdvance(companyId, data)` (INSERT supplier_advances + UPDATE current_advance_balance in transaction), `listClaims(companyId)`, `addClaim(companyId, data)` (INSERT claims + claim_items; NO stock movement), `markClaimCleared(claimId, adminId)` (UPDATE claims.status='cleared' + UPDATE supplier_companies.current_advance_balance += claim_value in transaction)
    - Create `src/controllers/SupplierController.js` — GET /suppliers, POST /suppliers, GET /suppliers/:id, POST /suppliers/:id/advance, GET /suppliers/:id/claims, POST /suppliers/:id/claims, POST /suppliers/:id/claims/:cid/clear
    - Create `src/routes/web/suppliers.js`
    - Create `src/views/suppliers/index.ejs` — supplier list with advance balance
    - Create `src/views/suppliers/detail.ejs` — advance balance, ledger history, claims list with add/clear actions
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, US-16, US-17_

  - [x] 8.2 Implement Centralized Cash Screen (SRS 7.13)
    - Create `src/controllers/CentralizedCashController.js` — GET /centralized-cash (daily view: today's entries grouped by type), GET /centralized-cash/monthly (monthly view: aggregated by month, filterable by date range)
    - Create `src/routes/web/centralizedCash.js`
    - Create `src/views/centralized-cash/index.ejs` — three columns: Salesman Sales Cash | Recovery Cash | Delivery Man Cash; daily/monthly toggle; totals
    - _Requirements: 14.1, 14.2, 14.3, 14.4_

  - [x] 8.3 Implement Staff Salary Management page (SRS 7.14 + US-18)
    - Create `src/models/SalaryModel.js` — `listByStaffType(type)`, `findOrCreateRecord(staffId, staffType, month, year)`, `recordBasicSalary(staffId, staffType, month, year, amount)`, `recordAdvance(staffId, staffType, amount, date, note, adminId)` (INSERT salary_advances + UPDATE salary_records.total_advances_paid), `performClearance(recordId, adminId)`, `exportHistory(staffId, staffType)` (Excel)
    - Create `src/controllers/SalaryController.js` — GET /salaries (tabs: Salesmen | Order Bookers | Delivery Men), POST /salaries/record, POST /salaries/advance, POST /salaries/clearance, GET /salaries/export/:staffId, POST /salaries/delivery-men, POST /salaries/delivery-men/:id, POST /salaries/delivery-men/:id/deactivate
    - Create `src/routes/web/salaries.js`
    - Create `src/views/salaries/index.ejs` — three tabs; per staff: basic salary, advances list, running balance, clearance button; Delivery Men tab includes add/edit/deactivate
    - _Requirements: 2.5, 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7, US-18_

  - [x] 8.4 Implement Expenses Management page (SRS 7.15)
    - Create `src/models/ExpenseModel.js` — `listAll(filters)`, `create(data)`
    - Create `src/controllers/ExpenseController.js` — GET /expenses (filterable by type/date/user), POST /expenses
    - Create `src/routes/web/expenses.js`
    - Create `src/views/expenses/index.ejs` — expense list with filters; Add Expense form (type, amount, date, related user optional, note)
    - _Requirements: 16.1, 16.2_


- [x] 9. Phase 8 — Dashboard, Reports & Database Backup (SRS 7.1, 7.16, 7.17)
  - [x] 9.1 Implement Dashboard (SRS 7.1)
    - Create `src/controllers/DashboardController.js` — GET /dashboard (renders index.ejs); GET /dashboard/data (AJAX JSON: sales summary by channel for today/month, per-booker metrics, per-salesman metrics, alerts panel counts, financials summary)
    - Create `src/routes/web/dashboard.js`
    - Create `src/views/dashboard/index.ejs` — Sales Summary (3 columns, daily/monthly toggle), Order Booker Performance table, Salesman Performance table, Alerts Panel (low stock + pending counts), Financials Summary (outstanding receivables + supplier advance balances)
    - _Requirements: 20.1, 20.2, 20.3, 20.4, 20.5_

  - [x] 9.2 Implement ReportService and all 12 report types (SRS 7.16)
    - Create `src/services/ReportService.js` with one method per report: `dailySalesReport(date)`, `monthlySalesReport(month, year)`, `orderBookerPerformanceReport(filters)`, `salesmanPerformanceReport(filters)`, `stockMovementReport(filters)`, `stockRequirementReport(bookerId)`, `shopLedgerReport(shopId)`, `cashRecoveryReport(filters)`, `supplierAdvanceReport(companyId)`, `staffSalaryReport(filters)`, `claimsReport(companyId)`, `cashFlowReport(filters)`
    - Create `src/utils/excelExport.js` — uses ExcelJS; `exportToExcel(reportData, columns, sheetName)` returns buffer; includes company profile header on each sheet
    - _Requirements: 18.1–18.12, 24.4_

  - [x] 9.3 Implement Reports page (SRS 7.16)
    - Create `src/controllers/ReportController.js` — one GET route per report; each accepts filter query params; if `?export=excel` triggers ExcelJS download via ReportService; otherwise renders HTML table
    - Create `src/routes/web/reports.js`
    - Create `src/views/reports/index.ejs` — report selector with filter forms; results table; Export to Excel button per report
    - _Requirements: 18.1–18.12_

  - [x] 9.4 Implement Database Backup page (SRS 7.17)
    - Create `src/services/BackupService.js` — `runBackup()`: executes `mysqldump` via child_process, saves to BACKUP_DIR with timestamp filename; `listBackups()`: reads BACKUP_DIR; `restoreBackup(filename)`: executes `mysql` restore command
    - Create `src/controllers/BackupController.js` — GET /backup (settings + history), POST /backup/settings (save cron time to config), POST /backup/run (manual trigger), GET /backup/download/:filename, POST /backup/restore
    - Create `src/routes/web/backup.js`
    - Create `src/views/backup/index.ejs` — backup time config, backup history list with download links, restore selector
    - _Requirements: 1.7, 1.8_

- [x] 10. Phase 9.5 — UI/UX Complete Overhaul
  - [x] 10.1 Update base layout and design system (main.ejs)
    - Update `src/views/layout/main.ejs` with enhanced design system:
      - Implement modern color palette (dark sidebar: #1E293B, accent: #3B82F6, tertiary: #35260C)
      - Add Manrope font for headlines, Inter for body text
      - Enhance card designs with proper shadows, borders, and rounded corners
      - Improve button styles with hover states and transitions
      - Add avatar component styles with color variants (blue, green, orange, red, purple, teal)
      - Enhance form controls with focus states and better spacing
      - Improve table styling with hover effects and better typography
      - Add badge variants (active, inactive, pending, approved, rejected, etc.)
      - Implement progress bar styles
      - Add modal improvements with better shadows and spacing
    - _Requirements: 1.2, 20.1_

  - [x] 10.2 Redesign Dashboard with modern UI (dashboard/index.ejs)
    - Update `src/views/dashboard/index.ejs` with professional design:
      - Dark hero card for Outstanding Ledger Summary with live indicator
      - Modern sales summary cards with icons (Order Booker, Salesman, Direct Shop)
      - Add progress bars showing individual performance breakdowns
      - Improve Order Booker Performance table with avatars and status badges
      - Enhance Critical Alerts panel with color-coded alert cards
      - Redesign Salesman Performance section with Van Tracking cards
      - Add efficiency metrics with progress bars per salesman
      - Implement daily/monthly toggle with better button group styling
    - _Requirements: 20.1, 20.2, 20.3, 20.4, 20.5_

  - [x] 10.3 Update sidebar navigation (nav.ejs)
    - Create `src/views/layout/nav.ejs` with modern sidebar design:
      - Dark background (#1E293B) with proper contrast
      - Brand section with company name and subtitle
      - New Dispatch button with accent color
      - Organized nav sections with labels (Core, Operations, Finance, System)
      - Icon-based navigation with hover effects
      - Active state highlighting with accent color
      - Sidebar footer with logout link
      - Mobile-responsive with toggle functionality
    - _Requirements: 1.2_

  - [x] 10.4 Redesign Company Profile page
    - Update `src/views/company-profile/index.ejs`:
      - Modern card layout with proper spacing
      - Enhanced form controls with better labels
      - Improved file upload UI for logo
      - Better button placement and styling
      - Add visual feedback for form validation
    - _Requirements: 17.1_

  - [x] 10.5 Redesign User Management pages
    - Update `src/views/users/index.ejs`:
      - Modern tabbed interface (Order Bookers | Salesmen)
      - Enhanced table with avatars and status badges
      - Better action buttons with icons
      - Improved search and filter UI
    - Update `src/views/users/form.ejs`:
      - Clean form layout with proper spacing
      - Enhanced input fields with icons
      - Better role selector UI
      - Improved button placement
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 10.6 Redesign Route Management pages
    - Update `src/views/routes/index.ejs`:
      - Modern card-based route list
      - Enhanced shop count badges
      - Better action buttons
    - Update `src/views/routes/detail.ejs`:
      - Improved route detail layout
      - Modern shop list with better spacing
      - Enhanced add/remove shop controls
    - _Requirements: 3.1, 3.2, 3.6, 3.7_

  - [x] 10.7 Redesign Route Assignment page
    - Update `src/views/route-assignments/index.ejs`:
      - Modern tabbed interface (Assign Today | By Date | By Booker)
      - Enhanced assignment form with better selectors
      - Improved assignment history table
      - Better date picker UI
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [x] 10.8 Redesign Shop Management pages
    - Update `src/views/shops/index.ejs`:
      - Modern table with route badges
      - Enhanced search and filter UI
      - Better CSV import button
      - Improved outstanding balance display
    - Update `src/views/shops/detail.ejs`:
      - Clean form layout with sections
      - Enhanced price control fields
      - Better ledger tab design
    - _Requirements: 3.3, 3.4, 3.5, 3.6, 13.1, 13.2_

  - [x] 10.9 Redesign Product Management pages
    - Update `src/views/products/index.ejs`:
      - Modern product cards or enhanced table
      - Better SKU and stock display
      - Enhanced active/inactive filter
      - Improved action buttons
    - Update `src/views/products/form.ejs`:
      - Clean form layout with proper sections
      - Enhanced input fields for pricing
      - Better carton/loose unit controls
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 10.10 Redesign Stock Management pages (all 6 sub-pages)
    - Update `src/views/stock/overview.ejs`:
      - Modern stock cards with color-coded levels
      - Enhanced product list with better spacing
      - Improved movement history display
    - Update `src/views/stock/manual-add.ejs`:
      - Clean form with better product selector
      - Enhanced quantity inputs
    - Update `src/views/stock/from-supplier.ejs`:
      - Modern supplier selector
      - Enhanced dynamic product rows
      - Better total calculation display
    - Update `src/views/stock/pending-issuances.ejs`:
      - Modern pending request cards
      - Enhanced approval buttons
      - Better product detail display
    - Update `src/views/stock/pending-returns.ejs`:
      - Enhanced return request cards
      - Better issued/returned/sold quantity display
      - Improved sale value editor
    - Update `src/views/stock/requirement-report.ejs`:
      - Modern report layout
      - Enhanced consolidated view
    - _Requirements: 6.2, 6.3, 6.4, 6.5, 6.6, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8_

  - [x] 10.11 Redesign Order Management pages (all 3 sub-pages)
    - Update `src/views/orders/pending.ejs`:
      - Modern filterable table
      - Enhanced inline quantity editor
      - Better Convert to Bill button
      - Improved filter controls
    - Update `src/views/orders/converted.ejs`:
      - Modern bill list with better spacing
      - Enhanced print button
      - Better bill detail display
    - Update `src/views/orders/consolidated.ejs`:
      - Modern consolidated stock view
      - Enhanced product aggregation display
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.8_

  - [x] 10.12 Redesign Direct Sales pages
    - Update `src/views/direct-sales/new.ejs`:
      - Modern shop selector
      - Enhanced product search with SKU lookup
      - Better dynamic quantity rows
      - Improved total calculation display
    - Update `src/views/direct-sales/index.ejs`:
      - Modern bill list with filters
      - Enhanced view/print buttons
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

  - [x] 10.13 Redesign Cash Recovery pages (all 4 sub-pages)
    - Update `src/views/cash-recovery/outstanding.ejs`:
      - Modern bill list with checkboxes
      - Enhanced booker selector
      - Better assignment controls
      - Improved filter UI
    - Update `src/views/cash-recovery/pending.ejs`:
      - Modern verification cards
      - Enhanced collection details
      - Better verify button
    - Update `src/views/cash-recovery/settlement.ejs`:
      - Clean settlement form
      - Enhanced bill and delivery man selectors
      - Better amount input with full/partial toggle
    - Update `src/views/cash-recovery/history.ejs`:
      - Modern history table with filters
      - Enhanced date range picker
      - Better status badges
    - _Requirements: 11.1, 11.2, 11.3, 11.6, 11.7, 11.8, 11.9, 11.10_

  - [x] 10.14 Redesign Supplier Management pages
    - Update `src/views/suppliers/index.ejs`:
      - Modern supplier cards
      - Enhanced advance balance display
      - Better action buttons
    - Update `src/views/suppliers/detail.ejs`:
      - Clean detail layout with sections
      - Enhanced advance history
      - Modern claims list with add/clear actions
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7_

  - [x] 10.15 Redesign Centralized Cash page
    - Update `src/views/centralized-cash/index.ejs`:
      - Modern three-column layout (Salesman | Recovery | Delivery Man)
      - Enhanced daily/monthly toggle
      - Better cash entry cards
      - Improved totals display
    - _Requirements: 14.1, 14.2, 14.3, 14.4_

  - [x] 10.16 Redesign Salary Management page
    - Update `src/views/salaries/index.ejs`:
      - Modern tabbed interface (Salesmen | Order Bookers | Delivery Men)
      - Enhanced salary records with better spacing
      - Improved advance list display
      - Better clearance controls
      - Modern delivery men CRUD section
    - _Requirements: 2.5, 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7_

  - [x] 10.17 Redesign Expenses Management page
    - Update `src/views/expenses/index.ejs`:
      - Modern expense list with filters
      - Enhanced add expense modal
      - Better type and date filters
      - Improved expense cards
    - _Requirements: 16.1, 16.2_

  - [x] 10.18 Redesign Reports page
    - Update `src/views/reports/index.ejs`:
      - Modern report selector with cards
      - Enhanced filter forms per report
      - Better results table styling
      - Improved Export to Excel button
    - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5, 18.6, 18.7, 18.8, 18.9, 18.10, 18.11, 18.12_

  - [x] 10.19 Redesign Database Backup page
    - Update `src/views/backup/index.ejs`:
      - Modern backup settings card
      - Enhanced backup history list
      - Better download and restore buttons
      - Improved restore modal
    - _Requirements: 1.7, 1.8_

  - [x] 10.20 Add interactive elements and polish
    - Add hover effects on all cards and buttons
    - Implement loading states for AJAX operations
    - Add smooth transitions for state changes
    - Enhance toast notifications styling
    - Add skeleton loaders for data fetching
    - Implement better error state displays
    - Add empty state illustrations
    - Improve responsive behavior for mobile
    - _Requirements: 1.2, 20.1_

- [ ] 11. Phase 10 — Cron Job, Audit Log Viewer & Non-Functional Hardening
  - [ ] 11.1 Implement midnight cron job (CronService)
    - Create `src/services/CronService.js` — `runMidnightJob()`: BEGIN TRANSACTION → UPDATE bill_recovery_assignments SET status='returned_to_pool', returned_at=NOW() WHERE assigned_date < CURDATE() AND status IN ('assigned','partially_recovered') → INSERT audit_log(MIDNIGHT_CRON) → COMMIT; catches errors, logs to cron_errors.log; job is idempotent
    - Create `src/config/cron.js` — registers node-cron schedule `'0 0 * * *'`; calls CronService.runMidnightJob(); logs result count
    - Mount cron in `src/app.js`
    - _Requirements: 12.1, 12.2, 12.3, 24.9_

  - [ ] 11.2 Implement Audit Log viewer (SRS 7.19 / Requirement 19)
    - Add to `src/controllers/` — `AuditController.js` — GET /audit-log (filterable by user, date range, entity type; paginated)
    - Create `src/views/audit-log/index.ejs` — filterable, paginated audit log table
    - Add nav link and route
    - _Requirements: 19.3_

  - [ ] 11.3 Wire dashboard midnight-cron failure alert
    - In `DashboardController.js` GET /dashboard/data: query whether last midnight cron completed successfully (check audit_log for MIDNIGHT_CRON entry from last night); include flag in alerts panel if missing
    - Update `src/views/dashboard/index.ejs` Alerts Panel to show cron failure warning
    - _Requirements: 12.4, 24.9_

- [ ] 12. Checkpoint — Ensure all web panel tests pass, ask the user if questions arise.


- [x] 13. Phase 11 — Mobile App (Flutter Android)
  - [x] 13.1 Initialise Flutter project and local DB service
    - Create `Shakeel Traders/mobile-app/` Flutter project with dependencies: sqflite (or hive), http, flutter_secure_storage, provider (or riverpod)
    - Create `lib/services/local_db_service.dart` — initialise sqflite schema mirroring server tables (local_routes, local_shops, local_products, local_orders, local_recovery_assignments, local_issuances, local_returns, local_shop_last_prices); CRUD helpers per entity
    - Create `lib/services/api_service.dart` — HTTP client with base URL from saved settings; JWT attach on every request; `testConnection(ip, port)`, `login(username, password)`, generic GET/POST helpers
    - _Requirements: 1.3, 1.4, 1.5_

  - [x] 13.2 Implement Connection Screen and Login Screen (SRS 8.1)
    - Create `lib/screens/shared/connection_screen.dart` — IP address field, port field (default 3000), Test Connection button (calls api_service.testConnection); saves settings to secure storage; enables Login button only on success
    - Create `lib/screens/shared/login_screen.dart` — username/password fields; calls POST /api/auth/login; stores JWT; routes to OrderBookerHomeScreen or SalesmanHomeScreen based on role
    - _Requirements: 1.3, 1.4, 1.6_

  - [x] 13.3 Implement Order Booker Home Screen and Sync Screen (SRS 8.2.1, 8.2.5)
    - Create `lib/screens/order_booker/home_screen.dart` — today's date, routes count, orders count, recovery bills count, pending sync count, Sync Now button, last sync timestamp
    - Create `lib/screens/order_booker/sync_screen.dart` — Morning Sync: GET /api/sync/morning → store all data in local_db; Mid-day Sync: GET /api/sync/midday → update recovery assignments; Evening Sync: POST /api/sync/evening with orders[] + collections[] → display stock adjustment notifications per item; per-record success/failure display
    - _Requirements: 21.1, 21.2, 21.7, 21.8, 21.9_

  - [x] 13.4 Implement Routes Screen and Order Booking Screen (SRS 8.2.2, 8.2.3)
    - Create `lib/screens/order_booker/routes_screen.dart` — list of today's assigned routes from local DB; tap route → list of shops; each shop shows name, address, recovery bill indicator
    - Create `lib/screens/order_booker/order_booking_screen.dart` — shop name/route header; searchable product list (SKU + name); per product: current price, last price for this shop; cartons + loose quantity entry; price edit within min/max range if enabled (read-only otherwise); order summary before save; saves to local_orders in sqflite
    - _Requirements: 21.3, 21.4, 21.5, 21.6_

  - [x] 13.5 Implement Recovery Tab Screen (SRS 8.2.4)
    - Create `lib/screens/order_booker/recovery_tab_screen.dart` — list of today's assigned recovery bills from local DB (independent of routes); per bill: shop name, bill date, bill number, original amount, outstanding amount; tap bill → enter collected amount + payment method (Cash/Bank Transfer); partial/full supported; saves to local_recovery_assignments; note about midnight auto-return
    - _Requirements: 22.1, 22.2, 22.3, 22.4, 22.5_

  - [x] 13.6 Implement Order Booker Today's Summary Screen (SRS 8.2.6)
    - Create `lib/screens/order_booker/summary_screen.dart` — read-only list of all orders booked today (shop, product count, sync status) and all recovery entries (shop, bill, amount, sync status)
    - _Requirements: 22.5_

  - [x] 13.7 Implement Salesman Home Screen and Sync Screen (SRS 8.3.1, 8.3.4)
    - Create `lib/screens/salesman/home_screen.dart` — today's date, issuance status badge, return status badge, cash collected today, Sync Now button, last sync timestamp
    - Create `lib/screens/salesman/sync_screen.dart` — Morning Sync: GET /api/sync/salesman/morning → store products/stock; upload issuance: POST /api/sync/salesman/issuance; check approval: GET /api/sync/salesman/issuance-status; upload return: POST /api/sync/salesman/return; per-item progress display
    - _Requirements: 23.1_

  - [x] 13.8 Implement Stock Issuance Screen (SRS 8.3.2 + US-04)
    - Create `lib/screens/salesman/stock_issuance_screen.dart` — searchable product list with current stock; cartons + loose entry per product; running total; Submit button (disabled after submission); read-only after submit with status badge; enforces one submission per day via local_db check
    - _Requirements: 10.1, 10.2, 23.2, 23.3, 23.4_

  - [x] 13.9 Implement Stock Return Screen (SRS 8.3.3 + US-07)
    - Create `lib/screens/salesman/stock_return_screen.dart` — accessible only after today's issuance is approved (check local issuance status); pre-populated with approved issuance product list; per product: issued qty shown, return qty entry; auto-calculates sold qty (issued - returned); optional cash collected field; Submit button; read-only after submit
    - _Requirements: 10.6, 10.7, 23.5, 23.6, 23.7_

  - [x] 13.10 Implement Salesman Today's Summary Screen (SRS 8.3.5)
    - Create `lib/screens/salesman/summary_screen.dart` — today's issuance (products, quantities, approval status) and return (returned quantities, sold quantities, cash collected, approval status)
    - _Requirements: 23.8_

  - [x] 13.11 Implement server-side mobile API endpoints (Express)
    - Create `src/routes/api/auth.js` — POST /api/auth/login (bcrypt verify, issue JWT, check is_active), POST /api/auth/test-connection (200 OK)
    - Create `src/services/SyncService.js` — `assembleMorningSyncPayload(bookerId)`: queries routes, shops, products, shop_last_prices, stock levels, recovery_assignments for today; `processEveningSync(bookerId, orders, collections)`: INSERT orders + order_items (with stock adjustment via OrderService.adjustOrderForStock), INSERT recovery_collections + UPDATE bill_recovery_assignments.status; `assembleMiddaySyncPayload(bookerId, lastSyncTime)`: returns recovery_assignments created after lastSyncTime; `assembleSalesmanMorningSyncPayload()`: products + stock; `processSalesmanIssuance(salesmanId, items)`: INSERT salesman_issuances + issuance_items; `processSalesmanReturn(salesmanId, items, cashCollected)`: INSERT salesman_returns + return_items
    - Create `src/routes/api/sync.js` — mount all sync endpoints with JWT middleware
    - _Requirements: 21.1, 21.7, 21.8, 21.9, 22.4, 23.1, 23.2_

- [ ] 14. Checkpoint — Ensure all mobile and sync tests pass, ask the user if questions arise.


- [ ] 15. Phase 12 — Property-Based Tests (fast-check, all 25 properties)
  - [ ]* 15.1 Write property test for Stock Non-Negativity (Property 1)
    - File: `tests/pbt/stock.test.js`
    - **Property 1: Stock Non-Negativity** — for any product with random stock levels and random deduction amounts (including amounts > stock), StockService.deductStock must either succeed with resulting stock >= 0 or throw StockInsufficientError; resulting stock must never be negative
    - Generator: `fc.record({ cartons: fc.nat(), loose: fc.nat(), deductCartons: fc.nat(), deductLoose: fc.nat() })`
    - **Validates: Requirements 6.1, 8.4, 9.3, 10.5, 24.6**

  - [ ]* 15.2 Write property test for Bill Amount Integrity (Property 2)
    - File: `tests/pbt/bill.test.js`
    - **Property 2: Bill Amount Integrity** — for any random gross_amount, advance_deducted (0 ≤ advance ≤ gross), and amount_paid (0 ≤ paid ≤ net), the invariants net_amount = gross - advance, outstanding = net - paid, outstanding >= 0 must all hold simultaneously
    - Generator: `fc.record({ gross: fc.float({ min: 0 }), advance: fc.float({ min: 0 }), paid: fc.float({ min: 0 }) })`
    - **Validates: Requirements 8.3, 8.7, 9.2, 11.7**

  - [ ]* 15.3 Write property test for Supplier Advance Balance Integrity (Property 3)
    - File: `tests/pbt/supplier.test.js`
    - **Property 3: Supplier Advance Balance Integrity** — for any random sequence of advance payments, stock receipts, and cleared claims, current_advance_balance must equal SUM(advances) - SUM(receipt_values) + SUM(cleared_claim_values)
    - Generator: `fc.array(fc.oneof(advanceArb, receiptArb, claimArb))`
    - **Validates: Requirements 7.2, 7.3, 7.6**

  - [ ]* 15.4 Write property test for Shop Ledger Append-Only Invariant (Property 4)
    - File: `tests/pbt/shopLedger.test.js`
    - **Property 4: Shop Ledger Append-Only** — for any sequence of bill/payment/recovery operations on a shop, the count of shop_ledger_entries must never decrease; no UPDATE or DELETE is ever issued on this table
    - Generator: `fc.array(fc.oneof(billOpArb, paymentOpArb, recoveryOpArb))`
    - **Validates: Requirements 13.1, 13.2, 24.5**

  - [ ]* 15.5 Write property test for Recovery Assignment Uniqueness (Property 5)
    - File: `tests/pbt/recovery.test.js`
    - **Property 5: Recovery Assignment Uniqueness** — for any bill, at most one bill_recovery_assignment with status != 'returned_to_pool' exists at any time; attempting to assign an already-assigned bill must be rejected
    - Generator: `fc.array(fc.record({ billId: fc.nat(), bookerId: fc.nat() }))`
    - **Validates: Requirements 11.3**

  - [ ]* 15.6 Write property test for Midnight Cron Completeness (Property 6)
    - File: `tests/pbt/cron.test.js`
    - **Property 6: Midnight Cron Completeness** — for any set of assignments from the previous calendar day with status 'assigned' or 'partially_recovered', after CronService.runMidnightJob() all such assignments must have status='returned_to_pool' and non-null returned_at
    - Generator: `fc.array(fc.record({ status: fc.constantFrom('assigned','partially_recovered'), assigned_date: fc.date() }))`
    - **Validates: Requirements 12.2, 12.3**

  - [ ]* 15.7 Write property test for Salesman Issuance Uniqueness Per Day (Property 7)
    - File: `tests/pbt/issuance.test.js`
    - **Property 7: Salesman Issuance Uniqueness Per Day** — for any salesman and date, at most one salesman_issuances record exists; duplicate submission must be rejected with 409
    - Generator: `fc.array(fc.record({ salesmanId: fc.nat({ max: 10 }), date: fc.date() }))`
    - **Validates: Requirements 10.1, 10.2, 23.3**

  - [ ]* 15.8 Write property test for Route Assignment Uniqueness Per Day (Property 8)
    - File: `tests/pbt/routeAssignment.test.js`
    - **Property 8: Route Assignment Uniqueness Per Day** — for any route and date, at most one route_assignments record exists; duplicate must be rejected with 409
    - Generator: `fc.array(fc.record({ routeId: fc.nat({ max: 10 }), date: fc.date() }))`
    - **Validates: Requirements 4.2**

  - [ ]* 15.9 Write property test for Stock Movement Completeness (Property 9)
    - File: `tests/pbt/stockMovement.test.js`
    - **Property 9: Stock Movement Completeness** — for any warehouse stock change operation, a corresponding stock_movements record must exist with correct movement_type, quantities, and stock_after snapshot matching the products table
    - Generator: `fc.array(fc.oneof(manualAddArb, receiptArb, billDeductArb, issuanceArb, returnArb))`
    - **Validates: Requirements 6.4, 6.5**

  - [ ]* 15.10 Write property test for Salesman Sale Value Calculation (Property 10)
    - File: `tests/pbt/saleValue.test.js`
    - **Property 10: Salesman Sale Value Calculation** — for any random issuance and return quantities and retail prices, system_sale_value must equal SUM((sold_cartons * units_per_carton + sold_loose) * retail_price) where sold = issued - returned
    - Generator: `fc.array(fc.record({ issuedCartons: fc.nat(), issuedLoose: fc.nat(), returnedCartons: fc.nat(), returnedLoose: fc.nat(), unitsPerCarton: fc.integer({ min: 1 }), retailPrice: fc.float({ min: 0.01 }) }))`
    - **Validates: Requirements 10.7, 10.11**

  - [ ]* 15.11 Write property test for Shop Ledger Entry Per Bill (Property 11)
    - File: `tests/pbt/billLedger.test.js`
    - **Property 11: Shop Ledger Entry Per Bill** — for any bill created (all three types), exactly one shop_ledger_entries row of type 'bill' must reference that bill
    - Generator: `fc.record({ billType: fc.constantFrom('order_booker','direct_shop','salesman'), shopId: fc.nat() })`
    - **Validates: Requirements 8.6, 9.4, 13.1**

  - [ ]* 15.12 Write property test for Advance Auto-Deduction on Bill Creation (Property 12)
    - File: `tests/pbt/advanceDeduction.test.js`
    - **Property 12: Advance Auto-Deduction** — for any bill created for a shop with remaining advance > 0, advance_deducted = MIN(gross_amount, remaining_balance) and shop_advances.remaining_balance decremented by the same amount
    - Generator: `fc.record({ grossAmount: fc.float({ min: 0.01 }), remainingBalance: fc.float({ min: 0 }) })`
    - **Validates: Requirements 8.7, 9.5, 13.6**

  - [ ]* 15.13 Write property test for Centralized Cash Entry Integrity (Property 13)
    - File: `tests/pbt/centralizedCash.test.js`
    - **Property 13: Centralized Cash Entry Integrity** — for each of the three cash triggers (salesman return approval, recovery verification, delivery man settlement), exactly one centralized_cash_entries row is created with correct entry_type, reference_id, amount, cash_date, recorded_by
    - Generator: `fc.oneof(salesmanReturnArb, recoveryVerifyArb, deliveryManArb)`
    - **Validates: Requirements 14.3, 14.4**

  - [ ]* 15.14 Write property test for Salary Running Balance Accuracy (Property 14)
    - File: `tests/pbt/salary.test.js`
    - **Property 14: Salary Running Balance Accuracy** — for any salary record with random basic_salary and sequence of advance payments, running_balance = basic_salary - SUM(advances) must always hold
    - Generator: `fc.record({ basicSalary: fc.float({ min: 0 }), advances: fc.array(fc.float({ min: 0 })) })`
    - **Validates: Requirements 15.4**

  - [ ]* 15.15 Write property test for Salary Record Uniqueness Per Month (Property 15)
    - File: `tests/pbt/salaryUniqueness.test.js`
    - **Property 15: Salary Record Uniqueness Per Month** — for any staff member, at most one salary_records entry per (staff_id, staff_type, month, year); duplicate must be rejected
    - Generator: `fc.array(fc.record({ staffId: fc.nat({ max: 10 }), staffType: fc.constantFrom('salesman','order_booker','delivery_man'), month: fc.integer({ min: 1, max: 12 }), year: fc.integer({ min: 2024, max: 2030 }) }))`
    - **Validates: Requirements 15.6**

  - [ ]* 15.16 Write property test for Audit Log Append-Only Invariant (Property 16)
    - File: `tests/pbt/auditLog.test.js`
    - **Property 16: Audit Log Append-Only** — for any sequence of auditable actions, audit_log row count must never decrease; every create/update/approve/verify action produces exactly one new entry
    - Generator: `fc.array(fc.constantFrom('CREATE_USER','APPROVE_ISSUANCE','CONVERT_ORDER','VERIFY_RECOVERY','RECORD_ADVANCE'))`
    - **Validates: Requirements 19.1, 19.2**

  - [ ]* 15.17 Write property test for Password Storage Security (Property 17)
    - File: `tests/pbt/auth.test.js`
    - **Property 17: Password Storage Security** — for any random plaintext password, the stored password_hash must not equal the plaintext and must be a valid bcrypt hash (starts with $2b$ or $2a$)
    - Generator: `fc.string({ minLength: 1, maxLength: 72 })`
    - **Validates: Requirements 1.6**

  - [ ]* 15.18 Write property test for SKU Code Uniqueness (Property 18)
    - File: `tests/pbt/sku.test.js`
    - **Property 18: SKU Code Uniqueness** — for any sequence of product creation attempts including duplicates, no two active products share the same sku_code; duplicate submission must be rejected with 409
    - Generator: `fc.array(fc.string({ minLength: 1, maxLength: 50 }))`
    - **Validates: Requirements 5.1, 5.2**

  - [ ]* 15.19 Write property test for Route Name Uniqueness (Property 19)
    - File: `tests/pbt/routeName.test.js`
    - **Property 19: Route Name Uniqueness** — for any sequence of route creation attempts including duplicates, no two active routes share the same name; duplicate must be rejected
    - Generator: `fc.array(fc.string({ minLength: 1, maxLength: 100 }))`
    - **Validates: Requirements 3.1**

  - [ ]* 15.20 Write property test for Evening Sync Stock Adjustment (Property 20)
    - File: `tests/pbt/syncAdjustment.test.js`
    - **Property 20: Evening Sync Stock Adjustment** — for any order item where ordered quantity exceeds available stock, final_cartons/final_loose must be capped at available stock (or zero), and stock_check_note must be non-null on the order
    - Generator: `fc.record({ orderedCartons: fc.nat(), availableCartons: fc.nat(), orderedLoose: fc.nat(), availableLoose: fc.nat() })`
    - **Validates: Requirements 8.9, 21.8**

  - [ ]* 15.21 Write property test for Bill Number Uniqueness and Format (Property 21)
    - File: `tests/pbt/billNumber.test.js`
    - **Property 21: Bill Number Format and Uniqueness** — for any sequence of bill creations across all three types, every bill_number must match `^(OB|DS|SM)-\d{4}-\d{2}-\d{5}$` and all bill_numbers must be unique
    - Generator: `fc.array(fc.constantFrom('order_booker','direct_shop','salesman'), { minLength: 1, maxLength: 50 })`
    - **Validates: Requirements 24.7**

  - [ ]* 15.22 Write property test for Deactivated User Login Rejection (Property 22)
    - File: `tests/pbt/auth.test.js` (additional test in same file as P17)
    - **Property 22: Deactivated User Login Rejection** — for any user with is_active=0, any login attempt must be rejected with 403 regardless of whether the password is correct
    - Generator: `fc.record({ username: fc.string(), password: fc.string(), isActive: fc.constant(0) })`
    - **Validates: Requirements 2.3, 2.6**

  - [ ]* 15.23 Write property test for Morning Sync Data Completeness (Property 23)
    - File: `tests/pbt/sync.test.js`
    - **Property 23: Morning Sync Data Completeness** — for any order booker with random route assignments, the morning sync payload must contain all assigned routes, all shops in those routes, all active products, shop_last_prices for all shop+product combos, current stock levels, and all recovery_assignments for today created before sync time
    - Generator: `fc.record({ bookerId: fc.nat(), routeCount: fc.integer({ min: 1, max: 5 }), shopsPerRoute: fc.integer({ min: 1, max: 10 }) })`
    - **Validates: Requirements 21.1**

  - [ ]* 15.24 Write property test for Claim Products Never Enter Warehouse Stock (Property 24)
    - File: `tests/pbt/claims.test.js`
    - **Property 24: Claim Stock Invariant** — for any claim recorded (pending or cleared), the warehouse stock of claimed products must remain unchanged before and after the claim operation
    - Generator: `fc.record({ productId: fc.nat(), cartons: fc.nat(), loose: fc.nat(), status: fc.constantFrom('pending','cleared') })`
    - **Validates: Requirements 7.5**

  - [ ]* 15.25 Write property test for Company Profile on All Bills (Property 25)
    - File: `tests/pbt/billPrint.test.js`
    - **Property 25: Company Profile on All Bills** — for any bill rendered via printFormatter.js, the output HTML must contain the company_name, logo_path, address, and gst_ntn values from the company_profile table
    - Generator: `fc.record({ companyName: fc.string({ minLength: 1 }), address: fc.string(), gstNtn: fc.string(), logoPat: fc.string() })`
    - **Validates: Requirements 17.2, 24.3**

- [ ] 16. Final Checkpoint — Ensure all 25 property tests and all unit tests pass, ask the user if questions arise.

---

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task references specific requirements for full traceability
- All multi-table writes must use MySQL transactions (BEGIN / COMMIT / ROLLBACK)
- Stock non-negativity enforced at both DB CHECK constraint and application layer (StockService)
- Shop ledger and audit log are append-only — no UPDATE or DELETE ever on these tables
- Bill numbers generated with sequence lock (SELECT FOR UPDATE) to prevent race conditions
- Midnight cron job is idempotent — safe to re-run on already-returned assignments
- Mobile app operates fully offline after morning sync; all data stored in sqflite/Hive
- Property tests use fast-check with minimum 100 iterations per property
- All report routes accept `?export=excel` to trigger ExcelJS download


