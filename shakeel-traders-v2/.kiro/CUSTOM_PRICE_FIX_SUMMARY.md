# Custom Price Sync Issue - FIXED

## Problem
Orders created on mobile app with custom prices (within allowed discount range) were syncing to server correctly, but when admin converted orders to bills, the custom prices were lost and default retail prices were used instead.

## Root Cause
In `OrderService.js` line 30-33, when fetching order items for bill conversion, the code was using:
```javascript
`SELECT oi.*, p.units_per_carton, p.retail_price AS unit_price`
```

This was overwriting the custom `oi.unit_price` from the order_items table with the product's default `p.retail_price`.

## Solution

### 1. Fixed Bill Conversion (OrderService.js)
**File:** `src/services/OrderService.js`

Changed line 30-33 from:
```javascript
const [items] = await conn.query(
  `SELECT oi.*, p.units_per_carton, p.retail_price AS unit_price
   FROM order_items oi
   JOIN products p ON p.id = oi.product_id
   WHERE oi.order_id = ?`,
  [orderId]
);
```

To:
```javascript
const [items] = await conn.query(
  `SELECT oi.*, p.units_per_carton, oi.unit_price
   FROM order_items oi
   JOIN products p ON p.id = oi.product_id
   WHERE oi.order_id = ?`,
  [orderId]
);
```

Now the bill conversion respects the custom `unit_price` saved in `order_items` table by the mobile app sync.

### 2. Added Order View/Edit UI

**New Files:**
- `src/views/orders/view.ejs` - Order details view with price editing

**Modified Files:**
- `src/controllers/OrderController.js` - Added `viewOrder()` and `updateOrderPrices()` methods
- `src/routes/web/orders.js` - Added routes for `/orders/:id/view` and `/orders/:id/update-prices`
- `src/models/OrderModel.js` - Added `retail_price` and `wholesale_price` to order items query
- `src/views/orders/pending.ejs` - Added "View/Edit" button for each order

**Features:**
1. **View Order Details** - Admin can click "View/Edit" button to see order details
2. **See Custom Prices** - Items with custom prices show a blue "Custom Price" badge
3. **Edit Prices** - Admin can adjust prices before converting to bill
4. **Live Calculations** - Line totals and grand total update as prices are edited
5. **Price Reference** - Shows retail and wholesale prices for reference
6. **Convert to Bill** - Can convert directly from the view page

### 3. Price Validation

The system respects shop-level price editing permissions:
- **Column:** `shops.price_edit_allowed` (0 or 1)
- **Discount Limit:** `shops.price_max_discount_pct` (e.g., 10 means up to 10% discount)
- **Mobile App:** Enforces price range when shop has `price_edit_allowed = 1`
- **Web Admin:** Can edit prices freely (override if needed)

## Data Flow

1. **Mobile App (Order Booker):**
   - Books order with custom price (within allowed discount range)
   - Saves locally with `unit_price`

2. **Evening Sync:**
   - Uploads order to server
   - `SyncService.js` saves order_items with `unit_price` column

3. **Web Admin (Order Management):**
   - Views pending orders
   - Clicks "View/Edit" to see/modify prices
   - Clicks "Convert to Bill"
   - **OrderService.js** now uses `oi.unit_price` (custom price)
   - **BillService.js** creates bill with correct prices

4. **Bill Created:**
   - Bill items have correct custom prices
   - Shop ledger updated with correct amounts
   - Stock deducted from warehouse

## Testing Checklist

✅ Custom prices saved during sync
✅ Order view shows custom prices with badge
✅ Admin can edit prices before conversion
✅ Bill conversion uses custom prices
✅ Line totals calculate correctly
✅ Grand total updates live
✅ Shop price editing permission respected
✅ Price reference shows retail/wholesale for comparison

## Database Schema

**order_items table:**
```sql
unit_price DECIMAL(10,2) NOT NULL -- Custom price from mobile app
```

**shops table:**
```sql
price_edit_allowed TINYINT(1) DEFAULT 0
price_max_discount_pct DECIMAL(5,2) DEFAULT 0.00
```

## Files Modified

1. `src/services/OrderService.js` - Fixed unit_price query
2. `src/controllers/OrderController.js` - Added viewOrder + updateOrderPrices
3. `src/routes/web/orders.js` - Added new routes
4. `src/models/OrderModel.js` - Enhanced order items query
5. `src/views/orders/pending.ejs` - Added View/Edit button
6. `src/views/orders/view.ejs` - NEW file for order details

## Status: ✅ COMPLETE

The custom price sync issue is now fully resolved. Orders maintain their custom prices throughout the entire flow from mobile app → server sync → bill conversion.
