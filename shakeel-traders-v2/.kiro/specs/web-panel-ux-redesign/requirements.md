# Requirements Document

## Web Panel UX Redesign — Shakeel Traders Distribution System

## Introduction

This feature covers UI/UX improvements and system enhancements to the existing Node.js + Express + EJS + Bootstrap 5 web admin panel for Shakeel Traders Distribution System. The enhancements span eleven areas: dashboard redesign, navigation reordering, route management interactivity, route assignment editing, shop management filters, centralized cash real-time updates, staff salary ledger, report fixes and pagination, searchable dropdowns, order management bulk operations, and system-wide pagination.

The system manages three sales channels — Order Booker Sales, Salesman (Van) Sales, and Direct Shop Sales — and the dashboard and reports must reflect all three channels clearly.

---

## Glossary

- **Web_Panel**: The Node.js + Express + EJS admin web application.
- **Admin**: The authenticated web panel user with full system access.
- **Dashboard**: The landing page of the Web_Panel showing key business metrics at a glance.
- **KPI_Card**: A summary card on the Dashboard displaying a single business metric with its value.
- **Centralized_Cash_Screen**: The consolidated view of all cash received across all three sales channels.
- **Route**: A named collection of shops grouped geographically.
- **Route_Assignment**: A per-day assignment of one Route to one Order_Booker.
- **Shop**: A retail or wholesale outlet with a running ledger.
- **Shop_Ledger**: The append-only chronological record of all financial events for a Shop.
- **Order**: A field-created record by an Order_Booker, pending conversion to a Bill.
- **Bill**: A financial document generated from an Order or created directly by Admin.
- **Order_Booker**: A mobile app user who books orders in the field.
- **Salesman**: A mobile app user who receives and returns stock.
- **Staff_Member**: Any employee tracked in the system — Order_Booker, Salesman, or Delivery_Man.
- **Salary_Record**: A monthly salary entry for a Staff_Member including basic salary and advances.
- **Salary_Ledger**: The chronological view of all salary and advance entries for a Staff_Member.
- **Searchable_Dropdown**: A dropdown input enhanced with a text search filter to narrow options.
- **Pagination**: The division of large data sets into discrete pages with navigation controls.
- **PDF_Export**: A generated PDF document for printing or saving.
- **Outstanding_Recovery**: A Bill with an unpaid or partially paid balance owed by a Shop.
- **Supplier_Advance**: Money paid to a supplier before stock arrives.

---

## Requirements

### Requirement 1: Dashboard KPI Redesign

**User Story:** As an Admin, I want the dashboard to display key business metrics at a glance, so that I can monitor daily operations without navigating to individual pages.

#### Acceptance Criteria

1. THE Dashboard SHALL display a KPI_Card for daily cash collected, showing the total cash received today across all three sales channels combined.
2. THE Dashboard SHALL display a KPI_Card for total Supplier_Advance balances outstanding across all supplier companies.
3. THE Dashboard SHALL display a KPI_Card for low-stock products, showing the count of products whose current warehouse stock falls below a configurable threshold.
4. THE Dashboard SHALL display a KPI_Card for total orders booked today by all Order_Bookers combined.
5. THE Dashboard SHALL display a KPI_Card for total sales value made by Salesmen today.
6. THE Dashboard SHALL display a KPI_Card for total Direct Shop Sales value today.
7. THE Dashboard SHALL display a KPI_Card for total cash recovery amount collected today.
8. THE Dashboard SHALL display a KPI_Card for total outstanding receivables across all Shops.
9. THE Dashboard SHALL display a KPI_Card for pending approvals count, combining pending Salesman_Issuance requests, pending Salesman_Return requests, and pending recovery verifications.
10. WHEN Admin clicks a KPI_Card, THE Web_Panel SHALL navigate to the relevant detail page for that metric.
11. THE Dashboard SHALL display all KPI_Cards in a responsive Bootstrap 5 grid that adapts to screen width.
12. THE Dashboard SHALL display an Order_Booker performance table showing, per booker: orders booked today, bills converted today, and recoveries collected today.
13. THE Dashboard SHALL display a Salesman performance table showing, per salesman: issued quantity, returned quantity, sold quantity, and sale value for today.

---

### Requirement 2: Navigation — User Management Placement

**User Story:** As an Admin, I want User Management to appear at the end of the navigation bar, so that it is out of the way during routine daily operations.

#### Acceptance Criteria

1. THE Web_Panel SHALL render the User Management link as the last item in the sidebar navigation.
2. WHEN the navigation is rendered, THE Web_Panel SHALL maintain all other navigation links in their existing relative order.

---

### Requirement 3: Route Management — Interactive Shop Search

**User Story:** As an Admin, I want to search for shops and add them to a route interactively, so that route setup is faster and less error-prone.

#### Acceptance Criteria

1. THE Web_Panel SHALL display a search input on the Route Detail page that filters available shops by name or owner name as the Admin types.
2. WHEN Admin types at least 2 characters in the shop search input, THE Web_Panel SHALL display a filtered list of shops not already assigned to the current route within 300ms.
3. WHEN Admin selects a shop from the filtered list, THE Web_Panel SHALL add the shop to the route immediately without a full page reload.
4. THE Web_Panel SHALL display the updated shop list for the route after each addition.
5. WHEN Admin removes a shop from the route, THE Web_Panel SHALL remove it immediately without a full page reload.
6. IF a shop search returns no results, THEN THE Web_Panel SHALL display a "No shops found" message in the results area.

---

### Requirement 4: Route Assignment — Edit and Delete

**User Story:** As an Admin, I want to edit and delete route assignments, so that mistakes made during assignment can be corrected.

#### Acceptance Criteria

1. THE Web_Panel SHALL display an Edit button for each Route_Assignment in the assignment list.
2. WHEN Admin submits an edited Route_Assignment, THE Web_Panel SHALL update the assignment and display a success confirmation.
3. THE Web_Panel SHALL display a Delete button for each Route_Assignment in the assignment list.
4. WHEN Admin clicks Delete on a Route_Assignment, THE Web_Panel SHALL prompt for confirmation before deleting.
5. WHEN Admin confirms deletion of a Route_Assignment, THE Web_Panel SHALL remove the assignment and display a success confirmation.
6. IF a Route_Assignment being deleted has associated Orders already synced from the mobile app, THEN THE Web_Panel SHALL display a warning message before allowing deletion.

---

### Requirement 5: Shop Management — Outstanding Recovery Filter and Ledger Pagination

**User Story:** As an Admin, I want to filter shops by outstanding recoveries and paginate the shop ledger, so that I can quickly identify shops with unpaid balances and navigate large ledger histories.

#### Acceptance Criteria

1. THE Web_Panel SHALL display a filter control on the Shops list page that, when activated, shows only Shops with at least one Outstanding_Recovery.
2. WHEN the outstanding recovery filter is applied, THE Web_Panel SHALL display the outstanding balance amount alongside each filtered Shop.
3. THE Shop_Ledger view SHALL display ledger entries in pages of 25 entries per page by default.
4. THE Shop_Ledger view SHALL display pagination controls showing current page, total pages, and navigation buttons for first, previous, next, and last page.
5. WHEN Admin navigates to a different page in the Shop_Ledger, THE Web_Panel SHALL load the correct page of entries without losing the current shop context.

---

### Requirement 6: Centralized Cash Screen — Real-Time Updates

**User Story:** As an Admin, I want the Centralized Cash Screen to update in real-time whenever a transaction is made, so that the cash view always reflects the current state without manual refresh.

#### Acceptance Criteria

1. THE Centralized_Cash_Screen SHALL poll the server for new cash entries at an interval of no more than 10 seconds.
2. WHEN a new cash entry is posted to the server, THE Centralized_Cash_Screen SHALL reflect the updated totals within 10 seconds without a full page reload.
3. THE Centralized_Cash_Screen SHALL display the timestamp of the last successful data refresh.
4. IF the polling request fails, THEN THE Centralized_Cash_Screen SHALL display a visible error indicator and continue retrying.
5. THE Centralized_Cash_Screen SHALL display a daily total and a breakdown by channel: Salesman Sales Cash, Recovery Cash, and Delivery Man Cash.

---

### Requirement 7: Staff Salary Ledger

**User Story:** As an Admin, I want a dedicated salary ledger per staff member, so that all salary payments and advances are recorded and auditable.

#### Acceptance Criteria

1. THE Web_Panel SHALL display a Salary_Ledger view for each Staff_Member showing all Salary_Records and advance payments in chronological order.
2. THE Salary_Ledger SHALL display for each entry: date, entry type (basic salary or advance), amount, and running balance.
3. THE Salary_Ledger SHALL display the current net balance (total basic salary minus total advances paid) prominently at the top of the view.
4. THE Web_Panel SHALL allow Admin to record a monthly basic salary entry for any Staff_Member with fields: month, year, and amount.
5. THE Web_Panel SHALL allow Admin to record a salary advance payment for any Staff_Member with fields: date, amount, and optional note.
6. THE System SHALL enforce that only one basic salary entry exists per Staff_Member per month per year; duplicate submission SHALL be rejected with a descriptive error.
7. THE Salary_Ledger SHALL display entries in pages of 25 per page with pagination controls.
8. THE Web_Panel SHALL allow Admin to export the Salary_Ledger for a Staff_Member to Excel.

---

### Requirement 8: Reports — Pagination and Error Fixes

**User Story:** As an Admin, I want all reports to be paginated and free of errors, so that I can view large data sets reliably without the application showing error states.

#### Acceptance Criteria

1. THE Web_Panel SHALL display all report result tables in pages of 25 rows per page.
2. EVERY report page SHALL display pagination controls showing current page, total pages, and navigation buttons.
3. WHEN Admin loads a report page without selecting required filters, THE Web_Panel SHALL display a prompt instructing Admin to select the required filters rather than showing an error message.
4. WHEN Admin submits a report with all required filters selected, THE Web_Panel SHALL display the report results without error.
5. THE Shop_Ledger Report SHALL require a shop selection before displaying results and SHALL display a "Please select a shop" prompt when no shop is selected.
6. THE Supplier_Advance Report SHALL require a supplier selection before displaying results and SHALL display a "Please select a supplier" prompt when no supplier is selected.
7. WHEN a report query returns zero results, THE Web_Panel SHALL display a "No records found" message instead of an empty table or error.
8. THE Web_Panel SHALL apply pagination to the following reports: Daily Sales, Monthly Sales, Order Booker Performance, Salesman Performance, Stock Movement, Stock Requirement, Shop Ledger, Cash Recovery, Supplier Advance, Staff Salary, Claims, and Cash Flow.

---

### Requirement 9: Searchable Dropdowns

**User Story:** As an Admin, I want all dropdowns across the system to support text search, so that I can quickly find the correct option without scrolling through long lists.

#### Acceptance Criteria

1. THE Web_Panel SHALL replace all standard HTML select elements that contain more than 5 options with Searchable_Dropdown controls.
2. WHEN Admin types in a Searchable_Dropdown, THE Web_Panel SHALL filter the visible options to those matching the typed text within 200ms.
3. THE Searchable_Dropdown SHALL support keyboard navigation: arrow keys to move between options, Enter to select, and Escape to close.
4. THE Searchable_Dropdown SHALL display a placeholder text of "Search..." when no value is selected.
5. WHEN a Searchable_Dropdown has no matching options for the typed text, THE Web_Panel SHALL display a "No results found" message inside the dropdown.
6. THE Searchable_Dropdown SHALL be applied consistently across all forms including: Shop selection, Product selection, Route selection, Order_Booker selection, Salesman selection, Supplier selection, and Staff_Member selection.

---

### Requirement 10: Order Management — Bulk Operations and PDF Export

**User Story:** As an Admin, I want to select multiple orders, view consolidated stock, convert them to bills in bulk, and print a combined PDF, so that order processing is faster and printing is more efficient.

#### Acceptance Criteria

1. THE Web_Panel SHALL display a checkbox next to each Order in the Orders list.
2. THE Web_Panel SHALL display a "Select All" checkbox that selects or deselects all visible Orders on the current page.
3. WHEN Admin selects one or more Orders, THE Web_Panel SHALL display a bulk action toolbar with options: View Consolidated Stock, Convert to Bills, Delete Selected, and Print All Open Bills.
4. WHEN Admin clicks View Consolidated Stock for selected Orders, THE Web_Panel SHALL display a consolidated product quantity table showing total quantity required per product across all selected Orders.
5. THE consolidated stock view SHALL display: product name, SKU code, total cartons required, total loose units required, current warehouse stock, and a shortfall indicator if warehouse stock is insufficient.
6. THE Web_Panel SHALL allow Admin to print the consolidated stock view as a PDF_Export containing: total stock summary, total orders count, Order_Booker name(s), Route(s), and date.
7. WHEN Admin clicks Convert to Bills for selected Orders, THE Web_Panel SHALL display a confirmation dialog listing the selected orders before proceeding.
8. WHEN Admin confirms bulk conversion, THE System SHALL convert each selected Order to a Bill individually, applying the same stock deduction and Shop_Advance rules as single-order conversion.
9. IF any selected Order would cause warehouse stock to go negative during bulk conversion, THEN THE System SHALL reject only that Order's conversion, report it to Admin, and continue converting the remaining Orders.
10. THE Web_Panel SHALL allow Admin to view or edit an individual Order before bulk conversion by clicking the Order row.
11. WHEN Admin clicks Delete Selected for selected Orders, THE Web_Panel SHALL prompt for confirmation before deleting.
12. WHEN Admin confirms deletion of selected Orders, THE System SHALL delete only Orders that have not yet been converted to Bills; already-converted Orders SHALL be skipped and reported to Admin.
13. THE Web_Panel SHALL display a date filter on the Bills list page to filter Bills by creation date.
14. WHEN Admin clicks Print All Open Bills, THE Web_Panel SHALL generate a single PDF_Export containing all Bills with outstanding balances, formatted in CBL Salesflo style, one Bill per page.
15. THE PDF_Export for Print All Open Bills SHALL include for each Bill: Bill_Number, Shop name, date, itemized products, total amount, amount paid, and outstanding balance.

---

### Requirement 11: System-Wide Pagination

**User Story:** As an Admin, I want pagination applied consistently across all list views in the system, so that pages with large data sets load quickly and remain usable.

#### Acceptance Criteria

1. THE Web_Panel SHALL apply Pagination to all list views that may contain more than 25 records, including: Orders list, Bills list, Shops list, Products list, Users list, Routes list, Expenses list, Audit Log, and Centralized Cash entries.
2. EVERY paginated list SHALL display pagination controls showing current page number, total pages, and navigation buttons for first, previous, next, and last page.
3. THE Web_Panel SHALL display the total record count above each paginated list.
4. WHEN Admin navigates between pages, THE Web_Panel SHALL preserve any active filter or sort state.
5. THE default page size SHALL be 25 records per page for all paginated lists.
