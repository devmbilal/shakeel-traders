# Requirements Document

## Shakeel Traders — Distribution Order System

## Introduction

Shakeel Traders Distribution Order System is a fully offline, locally hosted ERP that replaces the existing Salesflo software. The system runs on a single local office computer with no cloud or internet dependency for daily operations. It manages three distinct sales channels — Order Booker Sales, Salesman (Van) Sales, and Direct Shop Sales — each tracked separately across all dashboards and reports.

The system consists of two components: a web-based admin panel (Node.js + Express + EJS + Bootstrap, MVC architecture) and an Android mobile app (Flutter, offline-first). Four user roles exist: Admin (web panel only), Order Booker (mobile only), Salesman (mobile only), and Delivery Man (no system login, admin-managed).

---

## Glossary

- **System**: The Shakeel Traders Distribution Order System as a whole.
- **Web_Panel**: The Node.js + Express + EJS admin web application.
- **Mobile_App**: The Flutter Android application used by Order Bookers and Salesmen.
- **Admin**: The authenticated web panel user with full system access.
- **Order_Booker**: A mobile app user who books orders in the field and optionally collects cash recoveries.
- **Salesman**: A mobile app user who receives stock in the morning and returns unsold stock in the evening.
- **Delivery_Man**: A physical staff member with no system login; managed entirely by Admin.
- **Route**: A named collection of shops grouped geographically, used as the unit of order booking assignment.
- **Route_Assignment**: A per-day assignment of one Route to one Order_Booker for order booking only.
- **Shop**: A retail or wholesale outlet belonging to exactly one Route, with a running ledger.
- **Product**: A sellable item identified by a unique SKU_Code, tracked in cartons and loose units.
- **SKU_Code**: The unique mandatory business identifier for a Product.
- **Supplier_Company**: A source of stock (e.g., CBL) with its own separate advance and claims ledger.
- **Order**: A field-created record by an Order_Booker, synced to the server and converted to a Bill by Admin.
- **Bill**: A financial document generated from an approved Order or created directly by Admin for a Direct Shop Sale.
- **Bill_Number**: A unique identifier for a Bill in the format [TYPE_PREFIX]-[YEAR]-[MONTH]-[SEQUENCE].
- **Salesman_Issuance**: A morning record of stock issued to a Salesman, requiring Admin approval before warehouse deduction.
- **Salesman_Return**: An evening record of unsold stock returned by a Salesman, requiring Admin approval.
- **Cash_Recovery**: Collection of outstanding Bill payments by an Order_Booker, assigned independently of Route_Assignment.
- **Recovery_Assignment**: Admin's assignment of specific outstanding Bills to an Order_Booker for same-day cash collection.
- **Shop_Advance**: A prepayment made by a Shop, auto-deducted from future Bills until exhausted.
- **Supplier_Advance**: Money paid to a Supplier_Company before stock arrives; decremented on stock receipt.
- **Claim**: A complaint or return raised against a Supplier_Company; claimed products never enter warehouse stock.
- **Centralized_Cash_Screen**: The consolidated view of all cash received across all three sales channels.
- **Shop_Ledger**: The append-only chronological record of all financial events for a Shop.
- **Audit_Log**: The append-only record of every significant system action with user and timestamp.
- **Midnight_Cron**: The server-side scheduled job that runs at 00:00 daily to auto-return unrecovered Recovery_Assignments to the outstanding pool.
- **Stock_Movement**: A record of every warehouse stock change with type, quantity, and balance snapshot.
- **Warehouse**: The central stock repository tracked in the products table.
- **Outstanding_Pool**: The set of Bills with outstanding amounts not yet assigned for recovery.
- **Sync**: The mobile app operation that uploads locally stored data to the server and downloads updated data.

---

## Requirements

### Requirement 1: System Infrastructure & Offline Operation

**User Story:** As an Admin, I want the system to run entirely on a local office computer without internet dependency, so that daily operations are never disrupted by connectivity issues.

#### Acceptance Criteria

1. THE System SHALL operate on a single local office computer using MySQL as the database engine with no cloud or internet dependency for daily operations.
2. THE Web_Panel SHALL require an authenticated admin session for every page and action.
3. THE Mobile_App SHALL display a Connection Screen before login on first launch, requiring Server IP Address and Port Number fields and a Test Connection button.
4. WHEN the Test Connection button is tapped, THE Mobile_App SHALL verify reachability of the server before enabling the login screen.
5. THE Mobile_App SHALL store all data locally after morning Sync and operate fully offline until the next Sync.
6. THE System SHALL store all passwords as bcrypt-hashed values and never store plaintext credentials.
7. THE System SHALL perform a daily automatic MySQL backup at a configurable time and store backup files in a dedicated local folder.
8. WHEN Admin initiates a database restore, THE Web_Panel SHALL restore the MySQL database from the selected backup file.


---

### Requirement 2: User & Role Management

**User Story:** As an Admin, I want to create and manage Order Bookers, Salesmen, and Delivery Men, so that each staff member has appropriate system access.

#### Acceptance Criteria

1. THE System SHALL enforce exactly four role types: Admin (web panel only), Order_Booker (mobile only), Salesman (mobile only), and Delivery_Man (no system login).
2. THE Web_Panel SHALL allow Admin to create Order_Booker and Salesman accounts with fields: full name, username, password, and contact number.
3. THE Web_Panel SHALL allow Admin to deactivate any Order_Booker or Salesman account; deactivated users cannot log in.
4. THE System SHALL prevent deletion of any user account; only deactivation is permitted.
5. THE Web_Panel SHALL allow Admin to add, edit, and deactivate Delivery_Man records under Staff Salary Management; Delivery_Men have no login credentials.
6. WHEN a deactivated user attempts to log in, THE System SHALL reject the login attempt with a clear error message.

---

### Requirement 3: Route & Shop Management

**User Story:** As an Admin, I want to manage routes and shops, so that Order Bookers can be assigned to geographic areas for order booking.

#### Acceptance Criteria

1. THE Web_Panel SHALL allow Admin to create, edit, and deactivate Routes with a unique name.
2. THE Web_Panel SHALL allow Admin to add and remove Shops from a Route via the Route Details view.
3. THE Web_Panel SHALL allow Admin to create Shop records with fields: name, owner name, phone, address, Route, shop type (Retail or Wholesale), and price editing permission settings.
4. THE Web_Panel SHALL allow Admin to enable price editing for a Shop with a defined minimum percentage and maximum percentage range.
5. THE Web_Panel SHALL allow Admin to import Shops in bulk via CSV upload.
6. THE System SHALL enforce that every Shop belongs to exactly one Route at all times.
7. WHEN Admin deactivates a Route, THE Web_Panel SHALL retain all historical data associated with that Route.

---

### Requirement 4: Route Assignment (Order Booking Only)

**User Story:** As an Admin, I want to assign routes to Order Bookers on a per-day basis, so that each booker knows which shops to visit for order booking.

#### Acceptance Criteria

1. THE Web_Panel SHALL allow Admin to assign one or more Routes to an Order_Booker for a specific date for order booking purposes only.
2. THE System SHALL enforce that each Route is assigned to at most one Order_Booker per day; duplicate assignment of the same Route on the same date SHALL be rejected.
3. THE Web_Panel SHALL display all Route_Assignments for a selected date and for a selected Order_Booker across dates.
4. THE System SHALL treat Route_Assignment as completely independent from Recovery_Assignment; the same Order_Booker may have both on the same day.

---

### Requirement 5: Product Management

**User Story:** As an Admin, I want to manage the product catalogue with unique SKU codes, so that all stock movements are accurately tracked.

#### Acceptance Criteria

1. THE Web_Panel SHALL allow Admin to create Products with fields: SKU_Code (unique, mandatory), Product Name, Brand, Units per Carton, Retail Price, and Wholesale Price.
2. THE System SHALL enforce uniqueness of SKU_Code across all Products; duplicate SKU_Code submission SHALL be rejected with a descriptive error.
3. THE System SHALL prevent deletion of any Product; only deactivation is permitted.
4. THE Web_Panel SHALL display all Products with current stock in cartons and loose units, filterable by active or inactive status.
5. WHEN a Product is deactivated, THE System SHALL retain all historical stock movement and billing records for that Product.

---

### Requirement 6: Warehouse Stock Management

**User Story:** As an Admin, I want to manage warehouse stock with full movement history, so that stock levels are always accurate and auditable.

#### Acceptance Criteria

1. THE System SHALL enforce that warehouse stock for any Product can never go negative under any circumstance; any operation that would result in negative stock SHALL be rejected.
2. THE Web_Panel SHALL allow Admin to manually add stock to the Warehouse with fields: product, quantity in cartons and loose units, date, and note.
3. THE Web_Panel SHALL display a complete Stock_Movement history per Product showing movement type, quantities in/out, and stock balance after each movement.
4. THE System SHALL record a Stock_Movement entry for every warehouse stock change, capturing movement type, reference, quantities, balance snapshot, and the user who performed the action.
5. WHEN Admin adds stock from a Supplier_Company, THE System SHALL increase warehouse stock immediately and record a Stock_Movement of type receipt_supplier.
6. THE Web_Panel SHALL display a Stock Requirement Report per Order_Booker showing consolidated product quantities needed across all pending orders.

---

### Requirement 7: Supplier Company Management

**User Story:** As an Admin, I want to manage supplier companies with separate advance and claims ledgers, so that all supplier financial transactions are accurately tracked.

#### Acceptance Criteria

1. THE Web_Panel SHALL allow Admin to create and manage Supplier_Company records with fields: name, contact person, and phone.
2. THE Web_Panel SHALL allow Admin to record a Supplier_Advance payment with fields: amount, date, payment method, and optional note; the Supplier_Company advance balance SHALL increase by the recorded amount.
3. WHEN Admin records a stock receipt from a Supplier_Company, THE System SHALL increase warehouse stock for each received product and decrease the Supplier_Company advance balance by the total receipt value.
4. THE Web_Panel SHALL display the full Supplier_Company ledger showing all advances paid, stock receipts, and cleared claims in chronological order.
5. THE Web_Panel SHALL allow Admin to record a Claim against a Supplier_Company with fields: product(s), quantity, date, and reason; claimed products SHALL NOT be added to warehouse stock.
6. WHEN Admin marks a Claim as Cleared, THE System SHALL increase the Supplier_Company advance balance by the claim value.
7. THE Web_Panel SHALL display all Claims per Supplier_Company with status (pending or cleared) and full history.

---

### Requirement 8: Order Management (Order Booker → Admin Conversion)

**User Story:** As an Admin, I want to review synced orders from Order Bookers and convert them to bills, so that stock is deducted and shops are billed accurately.

#### Acceptance Criteria

1. THE Web_Panel SHALL display all Orders synced from Order_Bookers that have not yet been converted, filterable by date, Order_Booker, Route, and Shop.
2. THE Web_Panel SHALL allow Admin to edit product quantities on a pending Order before conversion.
3. WHEN Admin converts an Order to a Bill, THE System SHALL generate exactly one Bill per Order and deduct the ordered stock from the Warehouse at the moment of conversion.
4. WHEN Admin converts an Order to a Bill, THE System SHALL reject the conversion if any product quantity would cause warehouse stock to go negative.
5. THE System SHALL tag every Bill generated from an Order as bill_type = order_booker.
6. THE System SHALL add a Shop_Ledger entry for every Bill created.
7. WHEN a Shop has a remaining Shop_Advance balance at the time of Bill creation, THE System SHALL automatically deduct the Bill amount from the Shop_Advance balance and record the deducted amount on the Bill.
8. THE Web_Panel SHALL allow Admin to view and print converted Bills in CBL Salesflo format with company profile information.
9. WHEN evening Sync is processed, THE System SHALL remove order items for products completely out of stock and reduce quantities for products with partial stock, then record a stock_check_note on the Order.


---

### Requirement 9: Direct Shop Sales

**User Story:** As an Admin, I want to create instant bills for shops without an order booker workflow, so that walk-in or direct sales are captured immediately.

#### Acceptance Criteria

1. THE Web_Panel SHALL allow Admin to create a Direct Shop Sale Bill by selecting a Shop, adding Products by SKU_Code or name, and entering quantities in cartons and loose units.
2. WHEN Admin confirms a Direct Shop Sale, THE System SHALL deduct stock from the Warehouse immediately and create a Bill tagged as bill_type = direct_shop.
3. WHEN Admin confirms a Direct Shop Sale, THE System SHALL reject the operation if any product quantity would cause warehouse stock to go negative.
4. THE System SHALL add a Shop_Ledger entry for every Direct Shop Sale Bill at the moment of creation.
5. WHEN a Shop has a remaining Shop_Advance balance at the time of Direct Shop Sale Bill creation, THE System SHALL automatically deduct the Bill amount from the Shop_Advance balance.
6. THE Web_Panel SHALL display all Direct Shop Sale Bills filterable by date and Shop, with view and print capability.

---

### Requirement 10: Salesman Stock Issuance & Return Workflow

**User Story:** As an Admin, I want to approve salesman stock issuances and returns, so that warehouse stock is accurately adjusted and salesman sales values are correctly recorded.

#### Acceptance Criteria

1. THE Mobile_App SHALL allow a Salesman to submit one Salesman_Issuance request per day with product quantities in cartons and loose units; the request status SHALL be set to pending.
2. THE System SHALL enforce that a Salesman may submit at most one Salesman_Issuance per day.
3. THE Web_Panel SHALL display all pending Salesman_Issuance requests for Admin review.
4. WHEN Admin approves a Salesman_Issuance, THE System SHALL deduct the issued quantities from the Warehouse immediately and lock the issuance record from further modification.
5. THE System SHALL reject a Salesman_Issuance approval if any product quantity would cause warehouse stock to go negative.
6. THE Mobile_App SHALL allow a Salesman to submit a Salesman_Return only after today's issuance has been approved by Admin; the return screen SHALL be pre-populated with the approved issuance product list.
7. THE Mobile_App SHALL automatically calculate and display the sold quantity per product as issued quantity minus returned quantity.
8. THE Web_Panel SHALL display pending Salesman_Return requests showing issued quantities, returned quantities, system-calculated sold quantities, and sale value at retail price per product.
9. WHEN Admin approves a Salesman_Return, THE System SHALL add returned stock back to the Warehouse, post the final sale value to the Centralized_Cash_Screen, and record Stock_Movement entries of type return_salesman.
10. THE Web_Panel SHALL allow Admin to edit the total sale value before approving a Salesman_Return.
11. THE System SHALL calculate Salesman sales value as the sum of (sold cartons × units per carton + sold loose units) × retail price per product.

---

### Requirement 11: Cash Recovery & Bill Settlement

**User Story:** As an Admin, I want to assign outstanding bills to Order Bookers for cash recovery independently of route assignments, so that cash collection is flexible and fully tracked.

#### Acceptance Criteria

1. THE Web_Panel SHALL display all Bills with outstanding amounts in the Outstanding_Pool, filterable by Route, Shop, and status.
2. THE Web_Panel SHALL allow Admin to assign any outstanding Bill to any Order_Booker as a Recovery_Assignment, regardless of which Routes that Order_Booker has been assigned.
3. THE System SHALL enforce that a Bill has at most one active Recovery_Assignment at a time (status not equal to returned_to_pool).
4. THE Mobile_App SHALL display all Recovery_Assignments for the current day in a Recovery Tab that is fully independent from the Routes and order booking screens.
5. THE Mobile_App SHALL allow an Order_Booker to record a collected amount and payment method (Cash or Bank Transfer) per assigned Bill, supporting partial or full collection, stored offline.
6. THE Web_Panel SHALL display all recovery collections uploaded by Order_Bookers that are pending Admin verification.
7. WHEN Admin verifies a recovery collection, THE System SHALL deduct the collected amount from the Bill's outstanding balance, update the Bill status, add a Shop_Ledger entry of type recovery, and post the amount to the Centralized_Cash_Screen.
8. THE Web_Panel SHALL allow Admin to record delivery man cash settlement per Bill; full payment SHALL clear the Bill directly without going through the recovery tab, and the cash SHALL be posted to the Centralized_Cash_Screen.
9. WHEN a delivery man payment partially settles a Bill, THE System SHALL move the Bill to the Outstanding_Pool with the remaining outstanding amount.
10. THE Web_Panel SHALL display full recovery history filterable by date, Order_Booker, Shop, and Bill.

---

### Requirement 12: Midnight Cron Job — Auto-Return of Unrecovered Bills

**User Story:** As an Admin, I want unrecovered bill assignments to be automatically returned to the outstanding pool at midnight, so that no bills are lost due to Order Bookers failing to sync in the evening.

#### Acceptance Criteria

1. THE Midnight_Cron SHALL run at 00:00 daily on the server.
2. WHEN the Midnight_Cron runs, THE System SHALL set the status of all Recovery_Assignments from the previous day that are still in status assigned or partially_recovered to returned_to_pool and record the returned_at timestamp.
3. WHEN the Midnight_Cron runs, THE System SHALL make all auto-returned Bills available again in the Outstanding_Pool.
4. THE Web_Panel SHALL display flagged items in the dashboard for any Order_Booker who had Recovery_Assignments but did not sync on the assigned day.

---

### Requirement 13: Shop Ledger & Shop Advances

**User Story:** As an Admin, I want a complete, append-only shop ledger and advance management, so that every shop's financial history is fully auditable.

#### Acceptance Criteria

1. THE System SHALL maintain an append-only Shop_Ledger for every Shop recording all Bills, payments, recoveries, advances, advance adjustments, and claim credits in chronological order.
2. THE System SHALL never update or delete Shop_Ledger entries; corrections SHALL be made via compensating entries only.
3. THE Web_Panel SHALL display the full Shop_Ledger for any Shop with the current outstanding or advance balance prominently shown, and allow export.
4. THE Web_Panel SHALL allow Admin to record a Shop_Advance with fields: amount, date, payment method, and optional note; only Admin may record Shop_Advances.
5. WHEN a Shop_Advance is recorded, THE System SHALL immediately add a credit entry to the Shop_Ledger and make the advance available for auto-deduction on future Bills.
6. WHEN any Bill is created for a Shop with a remaining Shop_Advance balance, THE System SHALL automatically deduct the Bill amount from the advance balance and clearly show the deducted amount and remaining balance on the Bill and in the Shop_Ledger.


---

### Requirement 14: Centralized Cash Screen

**User Story:** As an Admin, I want a centralized view of all cash received across all channels, so that daily and monthly cash flow is immediately visible.

#### Acceptance Criteria

1. THE Web_Panel SHALL display a Centralized_Cash_Screen showing all cash received broken into three categories: Salesman Sales Cash, Recovery Cash (from Order_Bookers), and Delivery Man Cash (same-day bill settlements).
2. THE Web_Panel SHALL display the Centralized_Cash_Screen in both a Daily View (today's totals) and a Monthly View (aggregated by month, filterable by date range).
3. THE System SHALL post cash to the Centralized_Cash_Screen via exactly three triggers: (a) Salesman_Return approval, (b) Admin verification of a recovery collection, and (c) Admin recording a delivery man bill settlement.
4. THE System SHALL record every Centralized_Cash_Screen entry with entry type, reference, amount, date, and the Admin who recorded it.

---

### Requirement 15: Staff Salary Management

**User Story:** As an Admin, I want to manage salary, advances, and month-end clearance for all staff types, so that payroll is accurately tracked with full history.

#### Acceptance Criteria

1. THE Web_Panel SHALL support salary tracking for all three staff types: Salesman, Order_Booker, and Delivery_Man on a single Staff Salary Management page.
2. THE Web_Panel SHALL allow Admin to record a monthly basic salary for any staff member.
3. THE Web_Panel SHALL allow Admin to record partial salary advance payments at any time with date and optional note.
4. THE Web_Panel SHALL always display the running balance (basic salary minus total advances paid) for each staff member.
5. THE Web_Panel SHALL allow Admin to perform a Month-End Clearance for any staff member for a given month.
6. THE System SHALL enforce uniqueness of one salary record per staff member per month per year.
7. THE Web_Panel SHALL allow export of full salary history per staff member.

---

### Requirement 16: Expenses Management

**User Story:** As an Admin, I want to record and track business expenses separately from sales figures, so that operational costs are visible and reportable.

#### Acceptance Criteria

1. THE Web_Panel SHALL allow Admin to record an expense with fields: expense type (Fuel, Daily Allowance, Vehicle Maintenance, Office Expenses, or Other), amount, date, related user (optional), and note.
2. THE Web_Panel SHALL display all recorded expenses filterable by expense type, date range, and related user.

---

### Requirement 17: Company Profile

**User Story:** As an Admin, I want to manage the company profile, so that all printed bills and reports display accurate business identity information.

#### Acceptance Criteria

1. THE Web_Panel SHALL allow Admin to set and update the company profile with fields: Company Name, Owner Name, Address, Phone Numbers, Email, GST/NTN Number, and Logo.
2. THE System SHALL print the company profile information (name, logo, address, NTN) on all Bills and exported reports.

---

### Requirement 18: Reports & Excel Export

**User Story:** As an Admin, I want to generate and export all business reports to Excel, so that business performance can be analyzed and shared.

#### Acceptance Criteria

1. THE Web_Panel SHALL provide a Daily Sales Report showing sales by all three channels for a selected date, exportable to Excel.
2. THE Web_Panel SHALL provide a Monthly Sales Report showing sales by all three channels for a selected month, exportable to Excel.
3. THE Web_Panel SHALL provide an Order Booker Performance Report showing orders booked, bills converted, recovery bills assigned, and recoveries collected per Order_Booker, exportable to Excel.
4. THE Web_Panel SHALL provide a Salesman Performance Report showing issued, returned, and sold quantities, sale value, and salary status per Salesman, exportable to Excel.
5. THE Web_Panel SHALL provide a Stock Movement Report showing all stock additions, deductions, issuances, and returns filterable by date, exportable to Excel.
6. THE Web_Panel SHALL provide a Stock Requirement Report per Order_Booker showing consolidated product quantities for all pending orders, exportable to Excel.
7. THE Web_Panel SHALL provide a Shop Ledger Report for a selected Shop showing full history with balance, exportable to Excel.
8. THE Web_Panel SHALL provide a Cash Recovery Report showing assigned bills versus collected amounts per Order_Booker and unrecovered bills returned to pool, exportable to Excel.
9. THE Web_Panel SHALL provide a Supplier Advance & Stock Report per Supplier_Company showing advance paid, stock received, remaining balance, and pending claims, exportable to Excel.
10. THE Web_Panel SHALL provide a Staff Salary Report showing monthly salary, advances, and running balance per staff member across all staff types, exportable to Excel.
11. THE Web_Panel SHALL provide a Claims Report showing all claims per Supplier_Company with status, exportable to Excel.
12. THE Web_Panel SHALL provide a Centralized Cash Flow Report showing daily and monthly cash received across all channels, exportable to Excel.

---

### Requirement 19: Audit Log

**User Story:** As an Admin, I want a complete, immutable audit trail of every significant system action, so that all operations are fully accountable.

#### Acceptance Criteria

1. THE System SHALL record an Audit_Log entry for every create, update, approve, and verify action, capturing: user, action type, entity type, entity ID, old value (JSON), new value (JSON), IP address, and timestamp.
2. THE System SHALL never update or delete Audit_Log entries; the log is append-only.
3. THE Web_Panel SHALL allow Admin to view and filter the Audit_Log by user, date range, and entity type.

---

### Requirement 20: Dashboard

**User Story:** As an Admin, I want an at-a-glance dashboard showing daily and monthly business performance, so that I can monitor operations without navigating multiple pages.

#### Acceptance Criteria

1. THE Web_Panel SHALL display a Sales Summary showing today's total sales value split into three columns: Order Booker Sales, Salesman Sales, and Direct Shop Sales, with a toggle between Daily and Monthly view.
2. THE Web_Panel SHALL display Order_Booker performance metrics per booker: orders booked, bills converted, recoveries collected today, and recovery bills assigned today.
3. THE Web_Panel SHALL display Salesman performance metrics per salesman: issued, returned, sold quantities, and sale value for today.
4. THE Web_Panel SHALL display an Alerts Panel showing low stock alerts and pending approval counts for issuance requests, return requests, and pending recovery verifications.
5. THE Web_Panel SHALL display a Financials Summary showing total outstanding receivables across all Shops and Supplier_Company advance balances per company.


---

### Requirement 21: Mobile App — Order Booker Sync & Order Booking

**User Story:** As an Order Booker, I want to sync data in the morning and book orders offline throughout the day, so that I can work in the field without internet connectivity.

#### Acceptance Criteria

1. WHEN an Order_Booker performs a morning Sync, THE Mobile_App SHALL download: assigned Routes for today, all Shops within those Routes, all active Products with SKU_Code and prices, last price charged to each Shop per product, current warehouse stock levels, and any Recovery_Assignments made before the sync.
2. THE Mobile_App SHALL store all downloaded data locally and operate fully offline after morning Sync.
3. THE Mobile_App SHALL allow an Order_Booker to browse Shops by assigned Route and book an Order for any Shop by selecting products searchable by SKU_Code or name.
4. THE Mobile_App SHALL display both the current product price and the last price charged to the selected Shop for each product.
5. WHEN price editing is enabled for a Shop, THE Mobile_App SHALL allow the Order_Booker to adjust the price within the admin-defined minimum and maximum percentage range; otherwise the price field SHALL be read-only.
6. THE Mobile_App SHALL save Orders locally without requiring a server connection.
7. WHEN an Order_Booker performs an evening Sync, THE Mobile_App SHALL upload all locally stored Orders and recovery collection entries to the server.
8. WHEN the evening Sync completes, THE Mobile_App SHALL display an itemized notification of any products removed or quantities reduced from Orders due to stock unavailability.
9. THE Mobile_App SHALL allow an Order_Booker to perform a mid-day Sync to download Recovery_Assignments made by Admin after the morning Sync.

---

### Requirement 22: Mobile App — Order Booker Cash Recovery

**User Story:** As an Order Booker, I want to record cash collections against assigned bills offline, so that recovery data is captured accurately even without connectivity.

#### Acceptance Criteria

1. THE Mobile_App SHALL display a Recovery Tab showing all Bills assigned to the Order_Booker for the current day, with shop name, bill date, Bill_Number, original bill amount, and outstanding amount per bill.
2. THE Recovery Tab SHALL be fully independent from the Routes and order booking screens; recovery bills are shown regardless of which Routes the Order_Booker has been assigned.
3. THE Mobile_App SHALL allow an Order_Booker to record a collected amount and payment method (Cash or Bank Transfer) per assigned Bill, supporting partial or full collection, stored offline.
4. WHEN an Order_Booker syncs, THE Mobile_App SHALL upload all recovery collection entries alongside Orders in the same sync operation.
5. THE Mobile_App SHALL display a Today's Summary Screen showing all Orders booked and all recovery entries recorded today with sync status per item.

---

### Requirement 23: Mobile App — Salesman Issuance & Return

**User Story:** As a Salesman, I want to submit stock issuance requests in the morning and return entries in the evening via the mobile app, so that my daily stock workflow is tracked accurately.

#### Acceptance Criteria

1. WHEN a Salesman performs a morning Sync, THE Mobile_App SHALL download current warehouse stock levels and updated product information.
2. THE Mobile_App SHALL allow a Salesman to submit a Salesman_Issuance request with product quantities in cartons and loose units; the request SHALL be synced to the server with status pending.
3. THE System SHALL enforce that a Salesman may submit at most one Salesman_Issuance per day; the submit button SHALL be disabled after submission.
4. WHEN a Salesman_Issuance is submitted, THE Mobile_App SHALL display the issuance screen as read-only with status clearly shown.
5. THE Mobile_App SHALL allow a Salesman to submit a Salesman_Return only after today's issuance has been approved by Admin; the return screen SHALL be pre-populated with the approved issuance product list.
6. THE Mobile_App SHALL automatically calculate and display the sold quantity per product as issued quantity minus returned quantity.
7. WHEN a Salesman submits a Salesman_Return, THE Mobile_App SHALL allow optional entry of total cash collected during the day.
8. THE Mobile_App SHALL display a Today's Summary Screen showing today's issuance and return with quantities, approval status, and cash collected.

---

### Requirement 24: Non-Functional Requirements

**User Story:** As an Admin, I want the system to meet performance, security, scalability, and print compatibility standards, so that it reliably supports daily business operations.

#### Acceptance Criteria

1. THE Web_Panel SHALL load all standard screens in under 3 seconds on the local network.
2. THE System SHALL support at least 10 Order_Bookers, 10 Salesmen, 10 Delivery_Men, 500 Shops, 200 Products, and 1000 Orders per day without performance degradation.
3. THE System SHALL print Bills in CBL Salesflo format with company profile information (name, logo, address, NTN) on every printed Bill.
4. THE System SHALL export all reports to Excel format.
5. THE System SHALL enforce that the Shop_Ledger and Audit_Log are append-only; no UPDATE or DELETE operations are permitted on these tables.
6. THE System SHALL enforce stock non-negativity via both a database CHECK constraint on the products table and application-level validation before any stock deduction.
7. THE System SHALL generate Bill_Numbers in the format [TYPE_PREFIX]-[YEAR]-[MONTH]-[SEQUENCE] ensuring uniqueness across all bill types (OB for order_booker, DS for direct_shop, SM for salesman).
8. THE System SHALL update the shop_last_prices record automatically whenever a Bill is created or converted for a Shop and Product combination.
9. WHEN the Midnight_Cron fails to run, THE System SHALL log the failure and retry on the next scheduled execution.

