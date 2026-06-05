# Implementation Plan: Web Panel UX Redesign

## Overview

Eleven incremental improvements to the existing Node.js + Express + EJS + Bootstrap 5 admin panel. All changes follow the existing MVC pattern: router → controller → service/model → MySQL → EJS view. Tasks are ordered so shared utilities (pagination) are built first, then each feature area is wired in sequence.

## Tasks

- [x] 1. Build system-wide pagination utility
  - [x] 1.1 Create `web-admin-panel/src/utils/paginate.js` with `paginate(totalCount, page, limit = 25)` function
    - Return `{ page, limit, total, pages, offset }` with page clamped to `[1, pages]`
    - Handle edge cases: `total = 0` returns `pages = 0`, `page > pages` clamps to `pages`
    - _Requirements: 11.1, 11.2, 11.3, 11.5_

  - [ ]* 1.2 Write property test for `paginate()` utility
    - **Property 3: Pagination utility produces correct metadata**
    - **Validates: Requirements 5.3, 5.4, 8.1, 8.2, 11.1, 11.2, 11.3, 11.5**
    - Use `fast-check`: generate random `total` (0–10000), `page` (1–500), `limit` (1–100)
    - Assert `result.pages === Math.ceil(total / limit)`, `result.page` in `[1, max(1, pages)]`, `result.offset === (result.page - 1) * result.limit`

  - [ ]* 1.3 Write property test for paginated slice behavior
    - **Property 4: Paginated list returns at most `limit` records**
    - **Validates: Requirements 5.3, 8.1, 11.1, 11.5**
    - Generate random arrays of records, apply `slice(offset, offset + limit)`, assert `data.length <= limit`

- [x] 2. Create shared pagination EJS partial
  - [x] 2.1 Create `web-admin-panel/src/views/layout/pagination.ejs`
    - Render Bootstrap 5 `pagination-sm` nav with first/prev/page-info/next/last links
    - Accept `pagination` and `queryString` locals; hide entirely when `pagination.pages <= 1`
    - Build each href as `?<%= queryString %>&page=N`
    - _Requirements: 5.4, 8.2, 11.2_

- [x] 3. Apply pagination to all list controllers and views
  - [x] 3.1 Add `countAll(filters)` method to `ShopModel.js` and update `listAll(filters, {limit, offset})` to accept pagination params
    - _Requirements: 11.1, 11.5_

  - [x] 3.2 Add `countAll(filters)` and paginated `listAll` to `ProductModel.js`, `UserModel.js`, `RouteModel.js`, `ExpenseModel.js`
    - _Requirements: 11.1, 11.5_

  - [x] 3.3 Add `countPending(filters)` / `countConverted(filters)` and paginated list methods to `OrderModel.js`
    - _Requirements: 11.1, 11.5_

  - [x] 3.4 Add `countEntries(filters)` and paginated list method to `CentralizedCashModel.js` (or equivalent service)
    - _Requirements: 11.1, 11.5_

  - [x] 3.5 Update `ShopController.index()` to use `paginate()`, pass `pagination` and `queryString` to `views/shops/index.ejs`
    - Compute `queryString = new URLSearchParams({...req.query, page: undefined}).toString()`
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

  - [x] 3.6 Update `ProductController.index()`, `UserController.index()`, `RouteController.index()`, `ExpenseController.index()` with same pagination pattern
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

  - [x] 3.7 Update `OrderController.pendingOrders()` and `OrderController.convertedBills()` with pagination
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

  - [x] 3.8 Update `CentralizedCashController.index()` with pagination
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

  - [x] 3.9 Add `<%- include('../layout/pagination', {pagination, queryString}) %>` below the data table in each affected list view: `shops/index.ejs`, `products/index.ejs`, `users/index.ejs`, `routes/index.ejs`, `expenses/index.ejs`, `orders/pending.ejs`, `orders/converted.ejs`, `centralized-cash/index.ejs`
    - Also add total record count display above each table: `<p class="text-muted small"><%= pagination.total %> records</p>`
    - _Requirements: 11.2, 11.3_

- [x] 4. Checkpoint — Pagination utility and list views
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Dashboard KPI redesign
  - [x] 5.1 Update `DashboardController.js` `getData()` to add missing KPI fields
    - Add `ordersBookedToday`: `SELECT COUNT(*) FROM orders WHERE DATE(created_at) = CURDATE()`
    - Add `salesmanSalesToday`: `SELECT SUM(final_sale_value) FROM salesman_returns WHERE DATE(return_date) = CURDATE()`
    - Add `totalSupplierAdvanceBalance`: `SELECT SUM(current_advance_balance) FROM supplier_companies WHERE is_active = 1`
    - Ensure response shape includes all fields listed in Property 1
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9_

  - [ ]* 5.2 Write property test for dashboard `getData()` response shape
    - **Property 1: Dashboard getData returns all required KPI fields**
    - **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 1.12, 1.13**
    - Mock DB responses with random numeric values; assert all required keys present in response

  - [x] 5.3 Rewrite `views/dashboard/index.ejs` with KPI card grid and performance tables
    - 3-column Bootstrap row (`col-md-4`) of KPI cards; each card has colored left border, metric value, label, wrapped in `<a href="...">` per routing table in design
    - Below cards: two side-by-side tables for Order Booker Performance and Salesman Performance
    - Data loaded via existing `fetch('/dashboard/data')` AJAX pattern on page load
    - _Requirements: 1.1–1.13_

- [x] 6. Navigation reordering
  - [x] 6.1 Edit `views/layout/nav.ejs` — cut the User Management `<li>` block and paste it as the last item inside `<ul class="sidebar-nav">` before the closing `</ul>`
    - All other nav items remain in their current relative order
    - _Requirements: 2.1, 2.2_

- [x] 7. Route Management interactive shop search
  - [x] 7.1 Add `searchShopsNotInRoute(routeId, term)` method to `models/RouteModel.js`
    - SQL: `SELECT id, name, owner_name FROM shops WHERE route_id != ? AND is_active = 1 AND (name LIKE ? OR owner_name LIKE ?) ORDER BY name ASC LIMIT 20`
    - _Requirements: 3.1, 3.2, 3.6_

  - [x] 7.2 Add `getShopsInRoute(routeId)` method to `models/RouteModel.js` returning JSON array
    - _Requirements: 3.4_

  - [x] 7.3 Add `searchShops(req, res)` and `listShops(req, res)` methods to `controllers/RouteController.js`
    - `searchShops`: require `q` param ≥ 2 chars (return 400 otherwise), call `searchShopsNotInRoute`, return JSON
    - `listShops`: call `getShopsInRoute`, return JSON
    - _Requirements: 3.2, 3.4_

  - [x] 7.4 Register new routes in `routes/web/routes.js`
    - `GET /:id/shops/search` → `RouteController.searchShops`
    - `GET /:id/shops/list` → `RouteController.listShops`
    - _Requirements: 3.2, 3.4_

  - [x] 7.5 Replace static shop `<select>` + form in `views/routes/detail.ejs` with AJAX search UI
    - Add `<input id="shopSearch">` with debounced (300ms) `fetch('/routes/:id/shops/search?q=...')` on input
    - Render dropdown results below input; on shop click POST to `/routes/:id/shops` then reload shop list via `fetch('/routes/:id/shops/list')`
    - Show "No shops found" message when results array is empty
    - Remove shop: call `fetch` with `method:'DELETE'` to existing `DELETE /routes/:id/shops/:shopId`, then reload shop list
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 8. Route Assignment edit and delete
  - [x] 8.1 Add `updateAssignment(id, data)` and `countOrdersForAssignment(assignmentId)` to `models/RouteModel.js`
    - `updateAssignment`: UPDATE `route_assignments` SET `route_id`, `user_id`, `assignment_date` WHERE `id = ?`
    - `countOrdersForAssignment`: JOIN `route_assignments` → `orders` on route_id + booker_id + date, return count
    - _Requirements: 4.2, 4.6_

  - [x] 8.2 Add `edit(req, res)` and `update(req, res)` methods to `controllers/RouteAssignmentController.js`; enhance `deleteAssignment` with order-count check
    - `edit`: fetch assignment by ID, pass `orderBookers`, `routes`, `assignment` to view
    - `update`: validate `user_id`, `assignment_date`, `route_id`; call `updateAssignment`; flash success; redirect
    - `deleteAssignment`: call `countOrdersForAssignment`; if > 0 flash warning; proceed only on `?force=1` or if count = 0
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

  - [x] 8.3 Register `GET /:id/edit` and `POST /:id/edit` in `routes/web/routeAssignments.js`
    - _Requirements: 4.1, 4.2_

  - [x] 8.4 Update `views/route-assignments/index.ejs` with Edit and Delete buttons, edit modal, and delete confirmation
    - Add pencil-icon Edit button per row that opens a Bootstrap modal with pre-filled form (booker, route, date)
    - Add trash-icon Delete button per row with `confirm()` dialog before POST to `/:id/delete`
    - Show dismissible alert when orders exist warning before delete confirmation
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

- [x] 9. Shop Management outstanding filter and ledger pagination
  - [x] 9.1 Verify `ShopModel.listAll` handles `has_outstanding` filter by joining `bills` and filtering `outstanding_amount > 0`; add `outstanding_balance` to SELECT when filter active
    - _Requirements: 5.1, 5.2_

  - [ ]* 9.2 Write property test for outstanding recovery filter
    - **Property 10: Outstanding recovery filter returns only shops with unpaid balances**
    - **Validates: Requirements 5.1, 5.2**
    - Generate random shop+bill datasets; apply filter; assert every returned shop has `outstanding_amount > 0` and `outstanding_balance` equals sum of open bill amounts

  - [x] 9.3 Update `views/shops/index.ejs` to show `outstanding_balance` column when `has_outstanding` filter is active
    - _Requirements: 5.2_

  - [x] 9.4 Change `ShopController.ledger()` page size from 50 to 25; ensure `ShopModel.ledger` accepts `{limit, offset}` params
    - _Requirements: 5.3_

  - [x] 9.5 Verify `views/shops/ledger.ejs` pagination controls show first/prev/next/last using the shared `pagination.ejs` partial
    - _Requirements: 5.3, 5.4, 5.5_

- [x] 10. Centralized Cash real-time polling
  - [x] 10.1 Edit `views/centralized-cash/index.ejs` — change `setInterval(refreshDaily, 30000)` to `setInterval(refreshDaily, 10000)`
    - _Requirements: 6.1, 6.2_

  - [x] 10.2 Add error indicator element and `.catch()` handler in `views/centralized-cash/index.ejs`
    - Add `<div id="pollError" class="alert alert-danger d-none small py-1 px-2 mb-2">` with connection-lost message
    - In fetch `.catch()`: `document.getElementById('pollError').classList.remove('d-none')`
    - On successful fetch: `document.getElementById('pollError').classList.add('d-none')`
    - _Requirements: 6.3, 6.4_

- [x] 11. Staff Salary Ledger
  - [x] 11.1 Add `getLedger(staffId, staffType, page, limit)` and `getNetBalance(staffId, staffType)` to `models/SalaryModel.js`
    - `getLedger`: UNION of `salary_records` and `salary_advances` ordered by `entry_date DESC`, paginated with LIMIT/OFFSET
    - `getNetBalance`: `SELECT COALESCE(SUM(basic_salary),0) - COALESCE(SUM(total_advances_paid),0) AS net_balance FROM salary_records WHERE staff_id = ? AND staff_type = ?`
    - _Requirements: 7.1, 7.2, 7.3, 7.7_

  - [ ]* 11.2 Write property test for salary ledger net balance invariant
    - **Property 5: Salary ledger net balance invariant**
    - **Validates: Requirements 7.3**
    - Generate random arrays of salary records and advances; compute net balance via formula and via `getNetBalance` mock; assert equality

  - [x] 11.3 Add `ledger(req, res)` and `exportLedger(req, res)` methods to `controllers/SalaryController.js`
    - `ledger`: parse `staffType`, `staffId`; fetch staff name from `users`/`delivery_men`; call `getLedger` + `getNetBalance`; use `paginate()`; render `salaries/ledger`
    - `exportLedger`: fetch all ledger entries (no pagination); generate Excel using existing export pattern; send as download
    - _Requirements: 7.1, 7.2, 7.3, 7.7, 7.8_

  - [x] 11.4 Register `GET /salaries/:staffType/:staffId/ledger` and `GET /salaries/:staffType/:staffId/ledger/export` in `routes/web/salaries.js`
    - _Requirements: 7.1, 7.8_

  - [x] 11.5 Create `views/salaries/ledger.ejs`
    - Net balance card at top (Bootstrap `text-success` if positive, `text-danger` if negative)
    - Table columns: Date | Entry Type | Amount | Running Balance
    - Include `<%- include('../layout/pagination', {pagination, queryString}) %>` below table
    - Export to Excel button linking to `/salaries/:staffType/:staffId/ledger/export`
    - Reuse existing modal pattern from `salaries/index.ejs` for "Record Salary" and "Record Advance" forms
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.7, 7.8_

  - [x] 11.6 Add "View Ledger" link per staff member row in `views/salaries/index.ejs` linking to `/salaries/:staffType/:staffId/ledger`
    - _Requirements: 7.1_

- [x] 12. Checkpoint — Core features complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 13. Reports pagination and error fixes
  - [x] 13.1 Create `views/layout/pagination.ejs` if not already created in task 2.1 (verify it exists)
    - _Requirements: 8.2_

  - [x] 13.2 Update `ReportController.js` — add pagination (page, limit=25, slice) to all 12 report methods: `dailySales`, `monthlySales`, `orderBookerPerformance`, `salesmanPerformance`, `stockMovement`, `stockRequirement`, `shopLedger`, `cashRecovery`, `supplierAdvance`, `staffSalary`, `claims`, `cashFlow`
    - Pattern: `const page = parseInt(req.query.page) || 1; const allData = await ...; const total = allData.length; const data = allData.slice((page-1)*limit, page*limit); renderWithLayout(..., {data, pagination: paginate(total, page, limit), queryString})`
    - Change `stockMovement` limit from 100 to 25 to match the standard
    - _Requirements: 8.1, 8.2, 8.8_

  - [x] 13.3 Update `ReportController.js` — change missing-filter behavior for `shopLedger`, `supplierAdvance`, and `claims`
    - Instead of `req.flash('error') + redirect`, render the view with `{ noSelection: true, data: null, pagination: null }`
    - _Requirements: 8.3, 8.4, 8.5, 8.6_

  - [x] 13.4 Update all 12 report EJS views in `views/reports/` to include pagination partial and handle `noSelection` / empty states
    - Add `<%- include('../layout/pagination', {pagination, queryString}) %>` below each results table
    - Add `<% if (noSelection) { %><div class="alert alert-info">Please select a [shop/supplier] to view this report.</div><% } %>` where applicable
    - Add `<% if (!noSelection && data && data.length === 0) { %><div class="alert alert-secondary">No records found.</div><% } %>` for empty results
    - _Requirements: 8.3, 8.5, 8.6, 8.7_

- [x] 14. Searchable dropdowns via Tom Select
  - [x] 14.1 Add Tom Select CDN links to `views/layout/main.ejs`
    - In `<head>`: `<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tom-select@2/dist/css/tom-select.bootstrap5.min.css">`
    - Before `</body>`: `<script src="https://cdn.jsdelivr.net/npm/tom-select@2/dist/js/tom-select.complete.min.js"></script>`
    - Add global init script: `document.querySelectorAll('select[data-searchable]').forEach(el => new TomSelect(el, { placeholder: 'Search...', allowEmptyOption: true }))`
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

  - [x] 14.2 Add `data-searchable` attribute to all `<select>` elements with more than 5 options in: `views/shops/detail.ejs`, `views/orders/pending.ejs`, `views/route-assignments/index.ejs`, `views/reports/index.ejs`, `views/salaries/index.ejs`
    - _Requirements: 9.1, 9.6_

  - [x] 14.3 Add `data-searchable` to large selects in remaining views: `views/cash-recovery/*.ejs`, `views/stock/*.ejs`, `views/direct-sales/*.ejs`, and any inline filter selects in `views/reports/*.ejs`
    - _Requirements: 9.1, 9.6_

- [x] 15. Order Management bulk operations and PDF export
  - [x] 15.1 Install `pdfkit` npm dependency in `web-admin-panel/`
    - Run `npm install pdfkit` in the `web-admin-panel` directory
    - _Requirements: 10.6, 10.14, 10.15_

  - [x] 15.2 Create `web-admin-panel/src/utils/pdfGenerator.js`
    - Export `generateConsolidatedStockPDF(data)` — returns Buffer; include product table, total orders count, booker names, routes, date
    - Export `generateOpenBillsPDF(bills, companyProfile)` — returns Buffer; one bill per page in CBL Salesflo style with bill number, shop, date, itemized products, total, paid, outstanding
    - _Requirements: 10.6, 10.14, 10.15_

  - [x] 15.3 Add `getConsolidatedForIds(ids)`, `listOpenBills()`, and `listConverted(filters)` with date filter to `models/OrderModel.js`
    - `getConsolidatedForIds`: SQL with `WHERE o.id IN (?)` grouping by product, returning sku_code, name, units_per_carton, current_stock, SUM(final_cartons), SUM(final_loose)
    - `listOpenBills`: SELECT bills with `outstanding_amount > 0`
    - `listConverted`: add optional `date` filter to existing query
    - _Requirements: 10.4, 10.5, 10.13, 10.14_

  - [ ]* 15.4 Write property test for consolidated stock totals
    - **Property 7: Consolidated stock totals are correct**
    - **Validates: Requirements 10.4, 10.5**
    - Generate random `order_items` arrays grouped by product; compute expected totals; assert against `getConsolidatedForIds` result

  - [x] 15.5 Add `bulkConvert(req, res)`, `bulkDelete(req, res)`, `consolidatedSelected(req, res)`, `consolidatedPdf(req, res)`, and `printOpenBills(req, res)` to `controllers/OrderController.js`
    - `bulkConvert`: iterate `order_ids`, call `OrderService.convertOrderToBill(id, userId)` per order in try/catch; collect `{succeeded, failed}`; flash summary; redirect
    - `bulkDelete`: for each ID check `orders.status`; skip `converted`; delete `pending`/`stock_adjusted`; flash skipped IDs
    - `consolidatedSelected`: parse `ids` query param; call `getConsolidatedForIds`; compute shortfall in JS; return JSON
    - `consolidatedPdf`: same data; call `generateConsolidatedStockPDF`; send as `application/pdf`
    - `printOpenBills`: call `listOpenBills`; call `generateOpenBillsPDF`; send as `application/pdf`
    - _Requirements: 10.7, 10.8, 10.9, 10.11, 10.12, 10.14, 10.15_

  - [ ]* 15.6 Write property test for bulk convert single-order rule equivalence
    - **Property 8: Bulk convert applies single-convert rules per order**
    - **Validates: Requirements 10.8, 10.9**
    - Generate random sets of orders with varying stock levels; run bulk convert mock; assert each result matches individual convert result; assert stock-negative failure on one order does not block others

  - [ ]* 15.7 Write property test for bulk delete skipping converted orders
    - **Property 9: Bulk delete skips converted orders**
    - **Validates: Requirements 10.12**
    - Generate random arrays of orders with mixed statuses; run bulk delete; assert only `pending`/`stock_adjusted` orders are deleted; assert converted order IDs appear in skipped list

  - [x] 15.8 Register new bulk routes in `routes/web/orders.js`
    - `POST /orders/bulk-convert` → `OrderController.bulkConvert`
    - `POST /orders/bulk-delete` → `OrderController.bulkDelete`
    - `GET /orders/consolidated-selected` → `OrderController.consolidatedSelected`
    - `GET /orders/consolidated-pdf` → `OrderController.consolidatedPdf`
    - `GET /orders/bills/print-open` → `OrderController.printOpenBills`
    - _Requirements: 10.3, 10.6, 10.7, 10.11, 10.14_

  - [x] 15.9 Update `views/orders/pending.ejs` with checkboxes, Select All, and bulk toolbar
    - Add `<input type="checkbox" class="order-cb" value="<%= order.id %>">` per row
    - Add `<input type="checkbox" id="selectAll">` in `<thead>`
    - Add hidden `<div id="bulkToolbar" class="d-none">` with View Consolidated Stock, Convert to Bills, Delete Selected, Print All Open Bills buttons; show when ≥1 checkbox checked
    - Inline JS: selectAll toggle, checkbox state tracking, toolbar visibility, form submissions with `confirm()` dialogs
    - _Requirements: 10.1, 10.2, 10.3, 10.7, 10.10, 10.11_

  - [x] 15.10 Update `views/orders/converted.ejs` with date filter input
    - Add `<input type="date" name="date">` to existing filter form
    - _Requirements: 10.13_

- [x] 16. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at logical milestones
- Property tests validate universal correctness properties using `fast-check`
- Unit tests validate specific examples and edge cases
- `utils/paginate.js` (task 1) must be completed before any controller pagination work (task 3+)
- `views/layout/pagination.ejs` (task 2) must be completed before any view pagination work
- `pdfkit` must be installed (task 15.1) before `pdfGenerator.js` is created (task 15.2)
