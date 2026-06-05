# Shakeel Traders Distribution Order System
# Client User Guide — v1.2
# For: Admin, Order Bookers, Salesmen

---

## SYSTEM OVERVIEW

This system manages three sales channels for Shakeel Traders:

1. **Order Booker Sales** — Field staff books orders at shops, admin converts to bills
2. **Salesman (Van) Sales** — Salesman takes stock in morning, returns unsold in evening
3. **Direct Shop Sales** — Admin creates instant bills for walk-in or direct customers

The system has two parts:
- **Web Admin Panel** — Used by Admin on the office PC (browser)
- **Mobile App** — Used by Order Bookers and Salesmen on Android phones

---

## PART 1 — ADMIN WEB PANEL

### How to Login

1. Open browser on the office PC
2. Go to: `http://localhost:3000`
3. Enter username and password
4. Click **Sign In**

> First time login: username `admin`, password `admin123` — change immediately

---

## SECTION 1: DASHBOARD

The dashboard shows a live overview of the business.

**What you see:**
- **Total Outstanding** — Total unpaid amount across all open bills
- **Supplier Advance** — Money paid to suppliers in advance
- **Stock Value** — Current warehouse stock value
- **Cash Collected Today** — Broken into Salesman Sale, Recovery, Delivery Collection
- **Orders Booked** — Today's orders from order bookers with top bookers list
- **Alerts** — Low stock, pending orders, pending issuances, pending returns, unsynced bookers
- **Salesman Sales Breakdown** — Bar chart of each salesman's sales
- **Top Routes by Sales** — Bar chart of top performing routes
- **Mobile App Connection** — Shows server IP and port for mobile app setup

**Period toggle:** Switch between Today / Month / Year view using the buttons at the top right.

**Refresh:** Click the refresh button to update data without reloading the page.

---

## SECTION 2: DAILY OPERATIONS — MORNING ROUTINE

Every morning, Admin must complete these steps before field staff starts work.

### Step 1 — Assign Routes to Order Bookers

**Go to:** Route Assignments → Assign Today tab

1. Select the **Order Booker** from the dropdown
2. Select the **Date** (defaults to today)
3. Select one or more **Routes** to assign
4. Click **Assign**

Each route can only be assigned to one booker per day.

### Step 2 — Assign Recovery Bills to Order Bookers

**Go to:** Cash Recovery → Outstanding Bills

1. Check the bills you want to assign for collection
2. Select the **Order Booker** from the dropdown
3. Click **Assign for Recovery**

Order bookers will see these bills in their Recovery Tab on the mobile app.

### Step 3 — Approve Salesman Issuances

**Go to:** Stock → Pending Issuances

When a salesman submits a stock request from the mobile app, it appears here.

1. Review the requested quantities
2. Click **Approve** to deduct stock from warehouse and allow salesman to take goods

> Stock is only deducted AFTER approval. Never approve if stock is insufficient.

---

## SECTION 3: DAILY OPERATIONS — EVENING ROUTINE

### Step 1 — Convert Pending Orders to Bills

**Go to:** Orders → Pending Orders

Orders synced by order bookers appear here.

1. Review each order
2. Click **Convert to Bill** to create a bill and deduct stock
3. Or select multiple orders and use **Bulk Convert**

> Converted bills appear in Orders → Converted Bills

### Step 2 — Verify Recovery Collections

**Go to:** Cash Recovery → Pending Verifications

When order bookers sync their cash collections, they appear here for verification.

1. Review the collected amount and payment method
2. Click **Verify** to post cash to the Centralized Cash Screen and update the bill

### Step 3 — Approve Salesman Returns

**Go to:** Stock → Pending Returns

When a salesman submits their evening return from the mobile app:

1. Review issued quantities, returned quantities, and system-calculated sold quantities
2. Edit the sale value if needed
3. Click **Approve** to add returned stock back to warehouse and post sale value to cash screen

### Step 4 — Record Delivery Man Collections

**Go to:** Cash Recovery → Bill Settlement

When a delivery man brings cash for a bill:

1. Select the **Bill** from the dropdown
2. Select the **Delivery Man**
3. Enter the **Amount Collected**
4. Click **Record Payment**

This updates the bill status and posts cash to the Centralized Cash Screen.

---

## SECTION 4: ROUTES & SHOPS

### Managing Routes

**Go to:** Routes

- **Add Route** — Click "Add Route" button, enter route name
- **View Route Details** — Click the eye icon to see shops in the route
- **Deactivate Route** — Click the red slash button (data is preserved)

> Route ID is shown in the ID column — needed for CSV shop import

### Managing Shops

**Go to:** Shops

- **Add Shop** — Click "Add Shop", fill in name, owner, phone, address, route, type
- **Import via CSV** — Click "Import CSV" to bulk upload shops
- **View Shop Ledger** — Click the ledger icon to see full financial history
- **Add Shop Advance** — In shop details, record advance payment from shop

**CSV format for bulk shop import:**
```
name,owner_name,phone,address,route_id,shop_type,price_edit_allowed
Al-Noor Store,Ahmed Ali,03001234567,Main Bazar,1,retail,0
City Mart,Bilal Khan,03211234567,GT Road,2,wholesale,1
```

---

## SECTION 5: PRODUCTS & STOCK

### Managing Products

**Go to:** Products

- **Add Product** — Click "Add Product", fill SKU code, name, brand, units per carton, retail price, wholesale price
- **Import via CSV** — Click "Import CSV" to bulk upload products
- **Edit Product** — Click the pencil icon
- **View Stock History** — Click the clock icon

**CSV format for bulk product import:**
```
sku_code,name,brand,units_per_carton,retail_price,wholesale_price,low_stock_threshold
CBL-001,Sooper Biscuit,CBL,12,850.00,800.00,10
CBL-002,Rio Biscuit,CBL,24,450.00,420.00,5
```

> If SKU already exists, the product is updated. Stock is never changed by CSV import.

### Managing Stock

**Go to:** Stock

- **Stock Overview** — See all products with current cartons and loose units
- **Manual Add Stock** — Add stock received without a supplier receipt
- **Add from Supplier** — Record stock received from a supplier (deducts from supplier advance)
- **Pending Issuances** — Approve salesman morning stock requests
- **Pending Returns** — Approve salesman evening returns
- **Stock Requirement Report** — See consolidated stock needed for all pending orders

**Stock status indicators:**
- Green = sufficient stock
- Orange = low stock (below threshold)
- Red = out of stock

---

## SECTION 6: ORDER MANAGEMENT

### Pending Orders

**Go to:** Orders → Pending Orders

Shows all orders synced from order bookers that have not been converted yet.

- Filter by date, booker, route, or shop
- Click **Convert** on individual orders
- Select multiple and use **Bulk Convert**
- Use **Consolidated View** to see total stock needed across all pending orders

### Converted Bills

**Go to:** Orders → Converted Bills

Shows all bills generated from order booker orders.

- Filter by date or shop
- Click the printer icon to print a bill
- Click **Print Open Bills** to print multiple outstanding bills

### Bill Statuses

| Status | Meaning |
|---|---|
| Open | Bill created, nothing paid yet |
| Partially Paid | Some amount collected, balance remaining |
| Cleared | Fully paid, zero outstanding |

---

## SECTION 7: DIRECT SHOP SALES

**Go to:** Direct Shop Sales → New Bill

For walk-in customers or shops that buy directly without an order booker.

1. Select the **Shop**
2. Add products by searching SKU or name
3. Enter cartons and loose units
4. Prices auto-fill from retail price (editable)
5. Click **Create Bill**

Stock is deducted immediately. Bill starts as "open" until cash is collected via Bill Settlement.

---

## SECTION 8: PRINT BILLS

**Go to:** Print Bills (in sidebar, after Direct Shop Sales)

Print outstanding bills for delivery or collection.

1. **Filter** by type: All / Order Booker / Direct Shop
2. **Select** bills using checkboxes (or Select All)
3. Click **Print Selected**

The print output includes:
- One bill per page in CBL Salesflo format
- **Stock Requirement Summary** on the last page showing total cartons and loose needed across all selected bills

---

## SECTION 9: CASH RECOVERY

### Outstanding Bills

**Go to:** Cash Recovery → Outstanding Bills

Shows all bills with remaining outstanding amounts.

- Filter by route or shop
- Assign bills to order bookers for field collection

### Bill Settlement (Delivery Man)

**Go to:** Cash Recovery → Bill Settlement

Record cash brought by delivery men for direct bill payment.

### Pending Verifications

**Go to:** Cash Recovery → Pending Verifications

Verify cash collections uploaded by order bookers from the field.

### Recovery History

**Go to:** Cash Recovery → History

Full history of all recovery assignments and collections.

---

## SECTION 10: SUPPLIERS

**Go to:** Suppliers

### Adding a Supplier

Click **Add Supplier**, enter name, contact person, phone.

### Recording Supplier Advance

In supplier details, click **Record Advance**:
- Enter amount, date, payment method, note
- Supplier advance balance increases

### Adding Stock from Supplier

In supplier details, click **Add Stock Receipt**:
- Select products and quantities received
- Supplier advance balance decreases by receipt value
- Warehouse stock increases

### Claims

Record complaints or returns against a supplier:
- Claimed products are NOT added to warehouse stock
- When claim is cleared, supplier advance balance increases by claim value

---

## SECTION 11: CENTRALIZED CASH SCREEN

**Go to:** Centralized Cash

Shows all cash received across all three channels.

**Daily View** — Today's totals broken into:
- Salesman Sale (from approved salesman returns)
- Recovery (from verified order booker collections)
- Delivery Man Collection (from bill settlements)

**Monthly View** — Day-by-day breakdown for a date range.

> Cash only appears here after the triggering action:
> - Salesman return approved → Salesman Sale posted
> - Recovery collection verified → Recovery posted
> - Delivery man settlement recorded → Delivery Man Collection posted

---

## SECTION 12: REPORTS

**Go to:** Reports

All reports can be exported to Excel using the **Export** button.

| Report | What it shows |
|---|---|
| Daily Sales | Sales by all 3 channels for a specific date |
| Monthly Sales | Sales by all 3 channels for a month |
| Order Booker Performance | Orders booked, bills converted, recoveries per booker |
| Salesman Performance | Issued, returned, sold quantities and sale value per salesman |
| Stock Movement | All warehouse stock changes with type and balance |
| Stock Requirement | Consolidated stock needed for pending orders per booker |
| Shop Ledger | Full financial history for a specific shop |
| Cash Recovery | Assigned bills vs collected amounts per booker |
| Supplier Advance | Advances, receipts, claims per supplier |
| Staff Salary | Monthly salary, advances, running balance per staff |
| Claims | All claims per supplier with status |
| Cash Flow | Daily and monthly cash received across all channels |

---

## SECTION 13: STAFF SALARY MANAGEMENT

**Go to:** Salaries

Manage salary for Salesmen, Order Bookers, and Delivery Men.

### Recording Monthly Salary

1. Select staff member
2. Click **Record Salary**
3. Enter basic salary for the month

### Recording Salary Advance

1. Select staff member
2. Click **Record Advance**
3. Enter amount and date

Running balance = Basic Salary − Total Advances Paid

### Month-End Clearance

At end of month, click **Month-End Clearance** to mark salary as settled.

---

## SECTION 14: EXPENSES

**Go to:** Expenses

Record business expenses:
- Fuel
- Daily Allowance
- Vehicle Maintenance
- Office Expenses
- Other

Filter by type, date range, or staff member.

---

## SECTION 15: COMPANY PROFILE

**Go to:** Company Profile

Set business information printed on all bills:
- Company Name
- Owner Name
- Address
- Phone Numbers
- Email
- GST/NTN Number
- Sales Tax Number
- CNIC
- Logo (upload PNG/JPG — appears on dashboard and bills)

---

## SECTION 16: SETTINGS

**Go to:** Settings → Admin Profile

- Change admin **username**
- Change admin **password**

> Always use a strong password. Minimum 6 characters.

---

## SECTION 17: BACKUP & RESTORE

**Go to:** Backup

### Manual Backup

Click **Run Backup Now** — creates a `.sql` file in the backups folder.

If Google Drive is configured, backup also uploads automatically to Drive.

### Automatic Backup

Runs every night at midnight (00:00 Pakistan time) automatically.

### Restore from Backup

1. Select a backup file from the list
2. Click **Restore**
3. Confirm — this replaces all current data with the backup

> Only restore if something went seriously wrong. All data since the backup will be lost.

---

## PART 2 — MOBILE APP (ORDER BOOKERS)

### First-Time Setup

1. Install the APK on your Android phone
2. Open the app
3. On the **Connection Screen**:
   - Enter Server IP (shown on dashboard)
   - Enter Port: `3000`
   - Tap **Test Connection**
4. If connected, tap **Continue to Login**
5. Enter your username and password

> If you already configured the server before, tap **Skip** to go directly to login.

### Morning Routine

1. Connect to office Wi-Fi
2. Open app → tap **Sync** (morning sync)
3. App downloads: your assigned routes, shops, products, prices, recovery assignments
4. Go to field — app works fully offline

### Booking Orders

1. Tap **Routes** → select your assigned route
2. Tap a shop to open order booking
3. Search products by SKU or name
4. Enter cartons and loose units
5. Tap **Save Order**

Orders are saved locally until evening sync.

### Cash Recovery

1. Tap **Recovery** tab
2. See all bills assigned to you for today
3. Tap a bill → enter amount collected → select payment method (Cash/Bank Transfer)
4. Tap **Save**

### Evening Sync

1. Return to office Wi-Fi range
2. Open app → tap **Sync** (evening sync)
3. App uploads all orders and recovery collections
4. Check for any stock adjustment notifications

---

## PART 3 — MOBILE APP (SALESMEN)

### Morning Routine

1. Open app → tap **Request Issuance**
2. Enter products and quantities you need
3. Tap **Submit**
4. Wait for Admin to approve (you will see status change to "Approved")
5. Collect stock from warehouse

### Evening Routine

1. Open app → tap **Submit Return**
2. The screen shows all products from your approved issuance
3. Enter quantities you are returning (unsold stock)
4. System automatically calculates sold quantities
5. Tap **Submit Return**
6. Wait for Admin to approve

---

## QUICK REFERENCE — DAILY WORKFLOW

```
MORNING (Admin):
  1. Assign routes to order bookers
  2. Assign recovery bills to order bookers
  3. Approve salesman issuances

MORNING (Order Bookers):
  1. Morning sync on mobile app
  2. Go to field and book orders

MORNING (Salesmen):
  1. Submit issuance request on mobile app
  2. Wait for approval
  3. Collect stock

EVENING (Order Bookers):
  1. Evening sync on mobile app

EVENING (Salesmen):
  1. Submit return on mobile app

EVENING (Admin):
  1. Convert pending orders to bills
  2. Verify recovery collections
  3. Approve salesman returns
  4. Record delivery man collections
  5. Review dashboard
```

---

## COMMON QUESTIONS

**Q: Order booker synced but orders not showing?**
A: Go to Orders → Pending Orders. Check the date filter — clear it to see all dates.

**Q: Stock went negative error when converting?**
A: Check current stock in Stock → Stock Overview. Add stock first if needed.

**Q: Bill shows as open but cash was collected?**
A: Cash must be recorded via Cash Recovery → Bill Settlement (delivery man) or verified via Cash Recovery → Pending Verifications (order booker collection).

**Q: Salesman sale not showing on cash screen?**
A: The salesman return must be approved first. Go to Stock → Pending Returns and approve it.

**Q: Mobile app can't connect?**
A: Check both phone and PC are on the same Wi-Fi. Verify IP and port on the dashboard.

**Q: How to add a new shop to a route?**
A: Go to Routes → click the route → Add Shop. Or go to Shops → Add Shop and select the route.

**Q: How to see a shop's full payment history?**
A: Go to Shops → click the shop → View Ledger.

---

**Version:** 1.2
**Date:** April 2026
**System:** Shakeel Traders Distribution Order System
