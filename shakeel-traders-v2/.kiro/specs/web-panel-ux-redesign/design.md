# Design Document

## Web Panel UX Redesign — Shakeel Traders Distribution System

**Feature:** web-panel-ux-redesign
**Stack:** Node.js + Express + EJS + Bootstrap 5 + MySQL 8.x

---

## Overview

This document covers the technical design for eleven UX and functional improvements to the existing web admin panel. All changes are additive or in-place modifications to the existing MVC structure — no architectural changes are required. The panel runs on a local LAN with no internet dependency.

The eleven areas of work are:
1. Dashboard KPI redesign
2. Navigation reordering
3. Route Management interactive shop search
4. Route Assignment edit/delete
5. Shop Management outstanding filter + ledger pagination fix
6. Centralized Cash real-time polling (10s interval)
7. Staff Salary Ledger per staff member
8. Reports pagination and error fixes
9. Searchable dropdowns via Tom Select
10. Order Management bulk operations + PDF export
11. System-wide pagination utility

---

## Architecture

The existing architecture is unchanged: Express router → Controller → Service/Model → MySQL → EJS view. All new endpoints follow the same pattern.

```
Request
  └─► Router (routes/web/*.js)
        └─► authMiddleware
              └─► Controller (controllers/*.js)
                    └─► Service / Model
                          └─► MySQL (mysql2/promise pool)
                    └─► renderWithLayout() or res.json()
```

New client-side interactivity (AJAX shop search, polling, bulk checkboxes, Select2) is added as inline `<script>` blocks in the relevant EJS views, consistent with the existing pattern in `centralized-cash/index.ejs`.

**New npm dependencies to install:**
- `pdfkit` — PDF generation for consolidated stock and open bills export
- No server-side dependency needed for Tom Select (loaded via CDN in layout)

---

## Components and Interfaces

### Req 1 — Dashboard KPI Redesign

**Files to modify:**
- `controllers/DashboardController.js` — `getData()` already returns most required data; add missing KPIs
- `views/dashboard/index.ejs` — replace current view with KPI card grid + performance tables

**Missing data in current `getData()`:**
- `ordersBookedToday` — count of orders with `DATE(created_at) = today`
- `salesmanSalesToday` — sum of `final_sale_value` from `salesman_returns` where `return_date = today`
- `directSalesToday` — already in `sales.direct_shop` from `salesSummary`
- `cashRecoveryToday` — already in `recoveryStats.total_collected`
- `pendingApprovals` — sum of `pendingIssuances + pendingReturns + pendingVerifications` (already fetched separately)
- `totalOutstandingReceivables` — already in `financials.outstandingReceivables`
- `totalSupplierAdvanceBalance` — sum of `current_advance_balance` across all active suppliers

**KPI card → detail page routing:**

| KPI Card | Links to |
|---|---|
| Daily Cash Collected | `/centralized-cash` |
| Supplier Advances | `/suppliers` |
| Low Stock | `/stock` |
| Orders Booked Today | `/orders` |
| Salesman Sales Today | `/stock` (pending returns) |
| Direct Shop Sales Today | `/direct-sales` |
| Cash Recovery Today | `/cash-recovery` |
| Outstanding Receivables | `/cash-recovery/outstanding` |
| Pending Approvals | `/stock/pending-issuances` |

**Dashboard view layout** (`views/dashboard/index.ejs`):
- 3-column Bootstrap row of KPI cards (col-md-4), each card has a colored left border, metric value, label, and is wrapped in `<a href="...">` for navigation
- Below KPI cards: two tables side-by-side — Order Booker Performance and Salesman Performance
- Data loaded via `fetch('/dashboard/data')` on page load (existing AJAX pattern)

---

### Req 2 — Navigation Reordering

**File to modify:** `views/layout/nav.ejs`

Move the User Management `<li>` block to be the last item in `<ul class="sidebar-nav">`, just before the closing `</ul>`. All other items keep their current order. This is a single cut-and-paste in the EJS file.

---

### Req 3 — Route Management Interactive Shop Search

**New endpoint:**
```
GET /routes/:id/shops/search?q=<term>   → JSON: [{id, name, owner_name}]
```

**Files to modify:**
- `routes/web/routes.js` — add `GET /:id/shops/search` route
- `controllers/RouteController.js` — add `searchShops(req, res)` method
- `models/RouteModel.js` — add `searchShopsNotInRoute(routeId, term)` query
- `views/routes/detail.ejs` — replace static `<select>` + form with AJAX search UI

**Controller method `searchShops`:**
- Requires `q` param with at least 2 characters; return 400 otherwise
- Calls `RouteModel.searchShopsNotInRoute(id, q)`
- Returns JSON array

**Model query `searchShopsNotInRoute`:**
```sql
SELECT id, name, owner_name
FROM shops
WHERE route_id != ? AND is_active = 1
  AND (name LIKE ? OR owner_name LIKE ?)
ORDER BY name ASC
LIMIT 20
```

**View AJAX pattern** (inline script in `detail.ejs`):
- Input with `id="shopSearch"` debounced 300ms
- On ≥2 chars: `fetch('/routes/:id/shops/search?q=...')` → render dropdown list
- On shop click: `fetch('/routes/:id/shops', {method:'POST', body: {shop_id}})` → reload shop list section via `fetch('/routes/:id/shops/list')` or full page reload
- Remove shop: existing `DELETE /routes/:id/shops/:shopId` endpoint, called via `fetch` with `method:'DELETE'`; on success reload shop list

**New endpoint for AJAX shop list refresh:**
```
GET /routes/:id/shops/list   → JSON: [{id, name, owner_name}]
```
Returns current shops in route as JSON for partial DOM update.

---

### Req 4 — Route Assignment Edit and Delete

**Files to modify:**
- `controllers/RouteAssignmentController.js` — add `edit()`, `update()`, enhanced `deleteAssignment()`
- `routes/web/routeAssignments.js` — add `GET /:id/edit`, `POST /:id/edit`
- `views/route-assignments/index.ejs` — add Edit button, edit modal, Delete button with confirmation

**New controller methods:**

`edit(req, res)` — `GET /route-assignments/:id/edit`
- Fetch assignment by ID, render edit form (modal or inline)
- Pass `orderBookers`, `routes`, `assignment` to view

`update(req, res)` — `POST /route-assignments/:id/edit`
- Validate `user_id`, `assignment_date`, `route_id`
- Call `RouteModel.updateAssignment(id, data)`
- Flash success, redirect to `/route-assignments`

Enhanced `deleteAssignment(req, res)`:
- Before deleting, check if any orders exist for this assignment's route+date+booker combination
- If orders exist, flash warning and redirect without deleting (or add `?force=1` param to confirm)
- Add `RouteModel.countOrdersForAssignment(assignmentId)` model method

**New model methods in `RouteModel.js`:**
- `updateAssignment(id, {route_id, user_id, assignment_date})`
- `countOrdersForAssignment(assignmentId)` — joins `route_assignments` → `orders` on route_id + booker_id + date

**View changes:**
- Each assignment row gets Edit (pencil icon) and Delete (trash icon) buttons
- Edit opens a Bootstrap modal with pre-filled form
- Delete button triggers `confirm()` dialog before POST to `/:id/delete`
- If orders exist warning: show a dismissible alert before the delete confirmation

---

### Req 5 — Shop Management Filter + Ledger Pagination

**Outstanding recovery filter** — already partially implemented in `ShopController.index()` via `has_outstanding` filter param and `ShopModel.listAll(filters)`. Verify `ShopModel.listAll` handles `has_outstanding` by joining `bills` and filtering `outstanding_amount > 0`. Add `outstanding_balance` column to the shops list view when filter is active.

**Ledger pagination fix** — current `ShopController.ledger()` uses `limit: 50`. Change to `limit: 25` per requirement 5.3.

**Files to modify:**
- `controllers/ShopController.js` — change ledger page size from 50 to 25
- `views/shops/index.ejs` — add outstanding balance column when filter active
- `views/shops/ledger.ejs` — verify pagination controls show first/prev/next/last

---

### Req 6 — Centralized Cash Real-Time Polling

**File to modify:** `views/centralized-cash/index.ejs`

Current polling interval is `setInterval(refreshDaily, 30000)` (30s). Change to `10000` (10s).

Add error handling to the `fetch` call:
```javascript
.catch(err => {
  const indicator = document.getElementById('pollError');
  if (indicator) indicator.classList.remove('d-none');
});
```

Add a hidden error indicator element:
```html
<div id="pollError" class="alert alert-danger d-none small py-1 px-2 mb-2">
  <i class="bi bi-exclamation-triangle me-1"></i>Connection lost — retrying...
</div>
```

On successful fetch, hide the error indicator.

The `lastRefreshed` timestamp element already exists in the view.

**No backend changes needed** — `/centralized-cash/data` endpoint already exists in `CentralizedCashController`.

---

### Req 7 — Staff Salary Ledger

**New endpoints:**
```
GET  /salaries/:staffType/:staffId/ledger          → EJS view
GET  /salaries/:staffType/:staffId/ledger/export   → Excel download
```

**Files to modify/create:**
- `controllers/SalaryController.js` — add `ledger()` and `exportLedger()` methods
- `routes/web/salaries.js` — add new routes
- `models/SalaryModel.js` — add `getLedger(staffId, staffType, page, limit)` and `getNetBalance(staffId, staffType)`
- `views/salaries/ledger.ejs` — new view file

**Controller `ledger(req, res)`:**
- Params: `staffType` (salesman/order_booker/delivery_man), `staffId`
- Fetch staff member name from `users` or `delivery_men` table
- Call `SalaryModel.getLedger(staffId, staffType, page, 25)`
- Call `SalaryModel.getNetBalance(staffId, staffType)`
- Render `salaries/ledger` with `{staff, entries, netBalance, pagination}`

**Model `getLedger` query** — union of `salary_records` and `salary_advances` for the staff member, ordered by date DESC, paginated:
```sql
SELECT 'basic_salary' AS entry_type, month, year,
       CONCAT(year,'-',LPAD(month,2,'0'),'-01') AS entry_date,
       basic_salary AS amount, NULL AS note
FROM salary_records
WHERE staff_id = ? AND staff_type = ?
UNION ALL
SELECT 'advance', NULL, NULL, advance_date, amount, note
FROM salary_advances
WHERE staff_id = ? AND staff_type = ?
ORDER BY entry_date DESC
LIMIT ? OFFSET ?
```

**Model `getNetBalance`:**
```sql
SELECT COALESCE(SUM(basic_salary),0) - COALESCE(SUM(total_advances_paid),0) AS net_balance
FROM salary_records
WHERE staff_id = ? AND staff_type = ?
```

**View `salaries/ledger.ejs`:**
- Net balance card at top (green if positive, red if negative)
- Table: Date | Entry Type | Amount | Running Balance
- Pagination controls (first/prev/next/last)
- Export to Excel button → `GET /salaries/:staffType/:staffId/ledger/export`
- "Record Salary" and "Record Advance" forms (reuse existing modal pattern from `salaries/index.ejs`)

**Salary index view** — add "View Ledger" link/button per staff member row linking to `/salaries/:staffType/:staffId/ledger`.

---

### Req 8 — Reports Pagination and Error Fixes

**Core change:** All 12 report controllers must pass a `pagination` object to their views. Currently only `stockMovement` does this (with limit=100). All others need it with limit=25.

**Pattern to apply to each report controller method:**
```javascript
const page = parseInt(req.query.page) || 1;
const limit = 25;
const allData = await ReportService.someReport(filters);
const total = allData.length;
const data = allData.slice((page - 1) * limit, page * limit);
renderWithLayout(req, res, 'reports/some-report', {
  ..., data, pagination: { page, limit, total, pages: Math.ceil(total / limit) }
});
```

**Error fix — missing required filters:** Reports that require a selection (`shopLedger` needs `shopId`, `supplierAdvance` and `claims` need `companyId`) currently redirect with a flash error. Change to render the report page with a `noSelection: true` flag and display a prompt in the view instead of an error.

**Files to modify:**
- `controllers/ReportController.js` — add pagination to all 12 report methods; change missing-filter behavior
- All 12 report EJS views in `views/reports/` — add pagination controls partial; add "no selection" prompt; add "no records found" message

**Shared pagination partial** — create `views/layout/pagination.ejs`:
```html
<% if (pagination && pagination.pages > 1) { %>
<nav><ul class="pagination pagination-sm">
  <li class="page-item <%= pagination.page===1?'disabled':'' %>">
    <a class="page-link" href="?<%= queryString %>&page=1">«</a></li>
  <li class="page-item <%= pagination.page===1?'disabled':'' %>">
    <a class="page-link" href="?<%= queryString %>&page=<%= pagination.page-1 %>">‹</a></li>
  <li class="page-item disabled"><a class="page-link">
    Page <%= pagination.page %> of <%= pagination.pages %> (<%= pagination.total %> records)
  </a></li>
  <li class="page-item <%= pagination.page===pagination.pages?'disabled':'' %>">
    <a class="page-link" href="?<%= queryString %>&page=<%= pagination.page+1 %>">›</a></li>
  <li class="page-item <%= pagination.page===pagination.pages?'disabled':'' %>">
    <a class="page-link" href="?<%= queryString %>&page=<%= pagination.pages %>">»</a></li>
</ul></nav>
<% } %>
```

Each report view passes `queryString` (current query params minus `page`) to the partial via `locals`.

---

### Req 9 — Searchable Dropdowns

**Library:** Tom Select (CDN, no npm install needed)
- CDN CSS: `https://cdn.jsdelivr.net/npm/tom-select@2/dist/css/tom-select.bootstrap5.min.css`
- CDN JS: `https://cdn.jsdelivr.net/npm/tom-select@2/dist/js/tom-select.complete.min.js`

**File to modify:** `views/layout/main.ejs` — add Tom Select CDN links in `<head>` and a global init script before `</body>`:

```html
<script>
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('select[data-searchable]').forEach(el => {
    new TomSelect(el, { placeholder: 'Search...', allowEmptyOption: true });
  });
});
</script>
```

**Implementation:** Add `data-searchable` attribute to all `<select>` elements with more than 5 options across all forms. Affected views:
- `views/shops/detail.ejs` — route_id select
- `views/orders/pending.ejs` — booker, route, shop filters
- `views/route-assignments/index.ejs` — booker, route selects
- `views/reports/index.ejs` — shop, supplier, booker selects
- `views/reports/*.ejs` — any inline filter selects
- `views/salaries/index.ejs` — staff selects
- `views/cash-recovery/*.ejs` — shop, booker selects
- `views/stock/*.ejs` — product, salesman selects
- `views/direct-sales/*.ejs` — shop, product selects

No backend changes required.

---

### Req 10 — Order Management Bulk Operations + PDF Export

**New endpoints:**
```
POST /orders/bulk-convert          → bulk convert selected orders
POST /orders/bulk-delete           → bulk delete selected orders
GET  /orders/consolidated-selected?ids=1,2,3  → JSON consolidated stock for selected IDs
GET  /orders/consolidated-pdf?ids=1,2,3       → PDF download
GET  /orders/bills/print-open                 → PDF of all open bills
```

**Files to modify/create:**
- `controllers/OrderController.js` — add bulk methods
- `routes/web/orders.js` — add new routes
- `views/orders/pending.ejs` — add checkboxes, Select All, bulk toolbar
- `views/orders/converted.ejs` — add date filter, Print All Open Bills button
- `utils/pdfGenerator.js` — new utility wrapping pdfkit

**`pdfGenerator.js` utility:**
```javascript
const PDFDocument = require('pdfkit');
function generateConsolidatedStockPDF(data) { /* returns Buffer */ }
function generateOpenBillsPDF(bills, companyProfile) { /* returns Buffer */ }
module.exports = { generateConsolidatedStockPDF, generateOpenBillsPDF };
```

**Bulk convert logic** (`OrderController.bulkConvert`):
- Accepts `{ order_ids: [1,2,3] }` from POST body
- Iterates each ID, calls `OrderService.convertOrderToBill(id, userId)` in try/catch
- Collects successes and failures (stock-negative rejections)
- Returns redirect with flash listing results

**Bulk delete logic** (`OrderController.bulkDelete`):
- Accepts `{ order_ids: [1,2,3] }`
- For each ID, check `orders.status` — skip if `converted`
- Delete only `pending`/`stock_adjusted` orders
- Report skipped IDs in flash message

**Consolidated stock for selected orders:**
```sql
SELECT p.sku_code, p.name, p.units_per_carton,
       p.current_stock_cartons, p.current_stock_loose,
       SUM(oi.final_cartons) AS total_cartons,
       SUM(oi.final_loose) AS total_loose
FROM order_items oi
JOIN orders o ON o.id = oi.order_id
JOIN products p ON p.id = oi.product_id
WHERE o.id IN (?) AND o.status IN ('pending','stock_adjusted')
GROUP BY p.id ORDER BY p.name ASC
```
Shortfall computed in JS: `shortfall = (total_cartons * units_per_carton + total_loose) > (current_stock_cartons * units_per_carton + current_stock_loose)`

**View changes (`views/orders/pending.ejs`):**
- Add `<input type="checkbox" class="order-cb" value="<%= order.id %>">` per row
- Add `<input type="checkbox" id="selectAll">` in thead
- Add bulk toolbar div (hidden by default, shown when ≥1 checkbox checked):
  ```html
  <div id="bulkToolbar" class="d-none">
    <button onclick="viewConsolidated()">View Consolidated Stock</button>
    <button onclick="bulkConvert()">Convert to Bills</button>
    <button onclick="bulkDelete()">Delete Selected</button>
    <button onclick="printOpenBills()">Print All Open Bills</button>
  </div>
  ```
- Inline JS handles checkbox state, toolbar visibility, and form submissions

**Bills list date filter** (`views/orders/converted.ejs`):
- Add date input to existing filter form, pass `date` param to `OrderModel.listConverted(filters)`

---

### Req 11 — System-Wide Pagination Utility

**New utility:** `utils/paginate.js`
```javascript
function paginate(totalCount, page, limit = 25) {
  const pages = Math.ceil(totalCount / limit);
  const currentPage = Math.max(1, Math.min(page, pages));
  return { page: currentPage, limit, total: totalCount, pages, offset: (currentPage - 1) * limit };
}
module.exports = { paginate };
```

**All list controllers** must be updated to use this utility and pass `pagination` to their views. Controllers to update:

| Controller | Method | Current state |
|---|---|---|
| `OrderController` | `pendingOrders` | No pagination |
| `OrderController` | `convertedBills` | No pagination |
| `ShopController` | `index` | No pagination |
| `ProductController` | `index` | No pagination |
| `UserController` | `index` | No pagination |
| `RouteController` | `index` | No pagination |
| `ExpenseController` | `index` | No pagination |
| `CentralizedCashController` | `index` | No pagination |
| `ShopController` | `ledger` | Has pagination (limit=50, change to 25) |

Each controller fetches total count with a `COUNT(*)` query, then fetches the page slice with `LIMIT ? OFFSET ?`. The `paginate()` utility computes the pagination object.

**Filter preservation:** Pagination links must include all current query params. Pass `queryString` to views:
```javascript
const queryString = new URLSearchParams({ ...req.query, page: undefined }).toString();
```

All list views include `<%- include('../layout/pagination', {pagination, queryString}) %>` below their tables.

---

## Data Models

No new database tables are required. All changes use existing tables.

**New model methods summary:**

| Model | New Method | Purpose |
|---|---|---|
| `RouteModel` | `searchShopsNotInRoute(routeId, term)` | Req 3 AJAX search |
| `RouteModel` | `getShopsInRoute(routeId)` as JSON | Req 3 list refresh |
| `RouteModel` | `updateAssignment(id, data)` | Req 4 edit |
| `RouteModel` | `countOrdersForAssignment(assignmentId)` | Req 4 delete warning |
| `SalaryModel` | `getLedger(staffId, staffType, page, limit)` | Req 7 |
| `SalaryModel` | `getNetBalance(staffId, staffType)` | Req 7 |
| `OrderModel` | `listConverted(filters)` with date filter | Req 10 |
| `OrderModel` | `getConsolidatedForIds(ids)` | Req 10 |
| `OrderModel` | `listOpenBills()` | Req 10 print all |

**Pagination pattern for models** — all list methods gain optional `{limit, offset}` params:
```javascript
async listAll(filters = {}, { limit = 25, offset = 0 } = {}) {
  // existing WHERE clause
  sql += ' LIMIT ? OFFSET ?';
  params.push(limit, offset);
}
async countAll(filters = {}) { /* SELECT COUNT(*) */ }
```

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Dashboard getData returns all required KPI fields

*For any* database state, the `GET /dashboard/data` endpoint response must contain all required KPI fields: `financials.cashCollectedToday`, `financials.outstandingReceivables`, `financials.supplierAdvances`, `alerts.lowStock`, `alerts.pendingIssuances`, `alerts.pendingReturns`, `alerts.pendingVerifications`, `sales.order_booker`, `sales.salesman`, `sales.direct_shop`, `bookerPerformance` (array), and `salesmanPerformance` (array).

**Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 1.12, 1.13**

### Property 2: Shop search returns only unassigned matching shops

*For any* route ID and search term of 2+ characters, the `GET /routes/:id/shops/search?q=<term>` endpoint must return only shops that (a) are not currently assigned to the given route and (b) have a name or owner_name containing the search term (case-insensitive).

**Validates: Requirements 3.2, 3.6**

### Property 3: Pagination utility produces correct metadata

*For any* total record count, page number, and limit, the `paginate(total, page, limit)` utility must return an object where `pages = ceil(total / limit)`, `offset = (page - 1) * limit`, and `page` is clamped to `[1, pages]`.

**Validates: Requirements 5.3, 5.4, 8.1, 8.2, 11.1, 11.2, 11.3, 11.5**

### Property 4: Paginated list returns at most `limit` records

*For any* list controller with pagination applied, when fetching page N with limit 25, the returned data array must contain at most 25 items, and the pagination metadata must correctly reflect the total count and page count.

**Validates: Requirements 5.3, 8.1, 11.1, 11.5**

### Property 5: Salary ledger net balance invariant

*For any* staff member, the `net_balance` returned by `SalaryModel.getNetBalance()` must equal `SUM(basic_salary) - SUM(total_advances_paid)` across all salary records for that staff member.

**Validates: Requirements 7.3**

### Property 6: Duplicate salary entry is rejected

*For any* staff member, submitting a basic salary entry for a month/year combination that already has a record must result in an error response, and the existing record must remain unchanged.

**Validates: Requirements 7.6**

### Property 7: Consolidated stock totals are correct

*For any* set of selected order IDs, the consolidated stock view must show for each product a `total_cartons` equal to the sum of `final_cartons` across all selected orders for that product, and a `total_loose` equal to the sum of `final_loose`.

**Validates: Requirements 10.4, 10.5**

### Property 8: Bulk convert applies single-convert rules per order

*For any* set of selected orders, bulk conversion must produce the same result as converting each order individually — same stock deductions, same bill creation, same advance rules — and a stock-negative failure on one order must not prevent conversion of the remaining orders.

**Validates: Requirements 10.8, 10.9**

### Property 9: Bulk delete skips converted orders

*For any* set of selected order IDs containing a mix of pending and converted orders, bulk delete must delete only the pending/stock_adjusted orders and return the IDs of skipped (already-converted) orders in the response.

**Validates: Requirements 10.12**

### Property 10: Outstanding recovery filter returns only shops with unpaid balances

*For any* shop list query with `has_outstanding=1`, every returned shop must have at least one bill with `outstanding_amount > 0`, and the `outstanding_balance` field in the result must equal the sum of outstanding amounts across all that shop's open bills.

**Validates: Requirements 5.1, 5.2**

---

## Error Handling

**AJAX endpoints (shop search, bulk operations, polling):**
- Return `{ error: 'message' }` with appropriate HTTP status (400 for bad input, 404 for not found, 500 for server error)
- Client-side JS displays inline error messages rather than page redirects

**Bulk convert partial failures:**
- Do not use a transaction across all orders — each order converts independently
- Collect `{ succeeded: [], failed: [{ id, reason }] }` and flash a summary message

**Report missing-filter behavior:**
- Instead of `req.flash('error', ...)` + redirect, render the report view with `{ noSelection: true, data: null }`
- View shows a Bootstrap info alert: "Please select a [shop/supplier] to view this report."

**PDF generation errors:**
- Wrap `pdfkit` calls in try/catch; on error return 500 with flash message

**Polling failure (Req 6):**
- `fetch` `.catch()` shows `#pollError` element; on next successful fetch, hide it
- Polling continues regardless of failures (no exponential backoff needed for LAN)

---

## Testing Strategy

### Unit Tests

Focus on business logic that is independent of HTTP and the database:

- `utils/paginate.js` — test `paginate()` with various total/page/limit combinations including edge cases (page 0, page > total pages, total = 0)
- `SalaryModel.getNetBalance` — test the SQL query logic with mock DB responses
- Consolidated stock calculation — test the shortfall computation logic
- Bulk delete filter — test that converted orders are excluded from deletion list

### Property-Based Tests

Using `fast-check` (already in devDependencies). Each property test runs minimum 100 iterations.

**Property test configuration tag format:** `Feature: web-panel-ux-redesign, Property N: <property_text>`

**Property 3 test** — `Feature: web-panel-ux-redesign, Property 3: Pagination utility produces correct metadata`
```javascript
fc.assert(fc.property(
  fc.integer({min:0, max:10000}), // total
  fc.integer({min:1, max:500}),   // page
  fc.integer({min:1, max:100}),   // limit
  (total, page, limit) => {
    const result = paginate(total, page, limit);
    const expectedPages = Math.ceil(total / limit);
    return result.pages === expectedPages
      && result.page >= 1
      && result.page <= Math.max(1, expectedPages)
      && result.offset === (result.page - 1) * limit;
  }
), { numRuns: 100 });
```

**Property 4 test** — `Feature: web-panel-ux-redesign, Property 4: Paginated list returns at most limit records`
- Generate random arrays of records, call the paginate slice logic, assert `data.length <= 25`

**Property 5 test** — `Feature: web-panel-ux-redesign, Property 5: Salary ledger net balance invariant`
- Generate random arrays of salary records and advances, compute net balance two ways (via formula and via `getNetBalance` mock), assert equality

**Property 7 test** — `Feature: web-panel-ux-redesign, Property 7: Consolidated stock totals are correct`
- Generate random order_items arrays grouped by product, compute expected totals, assert against `getConsolidatedForIds` result

**Property 8 test** — `Feature: web-panel-ux-redesign, Property 8: Bulk convert applies single-convert rules per order`
- Generate random sets of orders with varying stock levels, run bulk convert, assert each result matches individual convert result

**Property 9 test** — `Feature: web-panel-ux-redesign, Property 9: Bulk delete skips converted orders`
- Generate random arrays of orders with mixed statuses, run bulk delete, assert only non-converted orders are deleted

**Property 10 test** — `Feature: web-panel-ux-redesign, Property 10: Outstanding recovery filter`
- Generate random shop+bill datasets, apply filter, assert all returned shops have outstanding_amount > 0

### Integration Tests

- `GET /routes/:id/shops/search?q=ab` — assert returns JSON array of matching shops not in route
- `GET /dashboard/data` — assert response shape contains all required KPI keys
- `POST /orders/bulk-convert` with mixed stock — assert partial success response
- `GET /salaries/salesman/1/ledger` — assert pagination object present in render call
