# Order Edit Enhancement - Complete Solution

## Overview
Enhanced the order view/edit page to allow full order modification before converting to bill:
- ✅ Add new products to order
- ✅ Remove products from order
- ✅ Edit quantities (cartons and loose units)
- ✅ Edit prices with auto-calculation
- ✅ Auto-suggest prices based on shop type (retail/wholesale)
- ✅ Real-time calculation of line totals and grand total

## Features Implemented

### 1. **Product Management in Order**
- **Add Products**: Search and add any active product to the order
- **Remove Products**: Delete items from order before conversion
- **Search Functionality**: Search products by SKU or name
- **Product Details**: Shows retail and wholesale prices for reference

### 2. **Quantity Editing**
- Edit cartons and loose units for each item
- Real-time calculation of total units
- Cartons × units_per_carton + loose = total units

### 3. **Intelligent Price Calculation**
- **Auto-suggest based on shop type**:
  - Retail shops → suggest retail_price
  - Wholesale shops → suggest wholesale_price
- **"Use R" / "Use W" button**: Quick apply suggested price
- **Custom pricing**: Allow any price (admin override)
- **Visual indicators**: Badge shows "Custom Price" or "NEW" item

### 4. **Real-time Calculations**
- Line total updates as you type quantities or prices
- Grand total recalculates automatically
- Total units display updates instantly

### 5. **Shop Type Display**
- Shows shop type badge (Retail/Wholesale) in header
- Suggested prices automatically match shop type
- Quick reference for pricing decisions

## Files Modified/Created

### New Files:
1. **`src/routes/api/products.js`** - API endpoint for fetching products

### Modified Files:
1. **`src/app.js`** - Added API products route
2. **`src/controllers/OrderController.js`** 
   - Enhanced `updateOrderPrices()` to handle:
     - New items (id = 0)
     - Removed items
     - Quantity changes
     - Price updates
3. **`src/controllers/ProductController.js`** - Added `getActiveProducts()` API method
4. **`src/models/OrderModel.js`** - Added `shop_type` to order query
5. **`src/views/orders/view.ejs`** - Complete rewrite with:
   - Add product modal
   - Editable quantities
   - Remove item buttons
   - Suggested price buttons
   - Real-time calculations
   - Enhanced UX

## User Interface

### Order Details Page Layout:
```
┌─────────────────────────────────────────────────────────┐
│ Order #123                      [Back to Orders]        │
│ Shop: ABC Store [WHOLESALE] | Route: North | Booker: X │
├─────────────────────────────────────────────────────────┤
│ Order Items                    [+ Add Product]          │
├──────┬─────────┬────┬────┬─────┬───────┬───────┬───────┤
│ SKU  │ Product │ C  │ L  │Units│ Price │ Sugg  │ Total │
├──────┼─────────┼────┼────┼─────┼───────┼───────┼───────┤
│ 001  │ Item A  │ [5]│[10]│ 130 │[15.00]│R:15 W │150.00 │
│      │[CUSTOM] │    │    │     │       │[Use W]│ [🗑️]  │
├──────┴─────────┴────┴────┴─────┴───────┴───────┴───────┤
│                          Grand Total: Rs. 150.00        │
├─────────────────────────────────────────────────────────┤
│            [Save Changes]  [Convert to Bill]            │
└─────────────────────────────────────────────────────────┘
```

### Add Product Modal:
```
┌───────────────────────────────┐
│ Add Product to Order     [X]  │
├───────────────────────────────┤
│ Search: [________]            │
│                               │
│ ┌───────────────────────────┐ │
│ │ CBL-001 - Biscuit 100g    │ │
│ │ R: 15.00 | W: 13.50       │ │
│ ├───────────────────────────┤ │
│ │ CBL-002 - Cake 50g        │ │
│ │ R: 10.00 | W: 9.00        │ │
│ └───────────────────────────┘ │
└───────────────────────────────┘
```

## Data Flow

### 1. View Order
```
User clicks "View/Edit" 
  ↓
OrderController.viewOrder()
  ↓
OrderModel.findById() - includes shop_type
  ↓
Render view.ejs with:
  - order items
  - shop type
  - retail & wholesale prices
```

### 2. Add Product
```
User clicks "Add Product"
  ↓
Modal opens
  ↓
JavaScript fetches /api/products/active
  ↓
User searches and selects product
  ↓
New row added to table with:
  - id = 0 (indicates new item)
  - suggested price based on shop type
  - cartons = 0, loose = 0
```

### 3. Edit Order
```
User modifies quantities/prices
  ↓
JavaScript calculates totals in real-time
  ↓
User clicks "Save Changes"
  ↓
Form submits to /orders/:id/update-prices
  ↓
OrderController.updateOrderPrices():
  - Delete removed items
  - Update existing items (id > 0)
  - Insert new items (id = 0)
  ↓
Redirect back to view page
```

### 4. Convert to Bill
```
User clicks "Convert to Bill"
  ↓
POST /orders/:id/convert
  ↓
OrderService.convertOrderToBill():
  - Uses oi.unit_price (respects custom prices)
  - Uses final_cartons & final_loose (updated quantities)
  - Deducts stock
  - Creates bill with correct amounts
```

## Database Schema

### order_items table:
```sql
id                INT - Primary key
order_id          INT - Foreign key to orders
product_id        INT - Foreign key to products
ordered_cartons   INT - Original quantity ordered
ordered_loose     INT - Original loose units
final_cartons     INT - Final quantity (after edit/stock check)
final_loose       INT - Final loose units
unit_price        DECIMAL(10,2) - Custom or default price
```

### Key Points:
- **id = 0** in form submission → new item to be inserted
- **id > 0** → existing item to be updated
- **Missing from submission** → item was removed, should be deleted
- **final_cartons/loose** can differ from ordered values (admin edit)

## Price Calculation Logic

```javascript
// Suggested price based on shop type
const suggestedPrice = shopType === 'wholesale' 
  ? product.wholesale_price 
  : product.retail_price;

// Line total calculation
const totalUnits = (cartons * unitsPerCarton) + loose;
const lineTotal = totalUnits * unitPrice;

// Grand total
const grandTotal = sum of all line totals;
```

## Usage Instructions

### For Admin:

1. **View Order**:
   - Go to Order Management
   - Click "View/Edit" on any pending order

2. **Add Product**:
   - Click "+ Add Product"
   - Search by SKU or name
   - Click product to add
   - Enter quantities

3. **Edit Quantities**:
   - Click in cartons or loose fields
   - Type new values
   - Totals update automatically

4. **Edit Prices**:
   - Click in price field
   - Type new price
   - Or click "Use R/W" for suggested price

5. **Remove Item**:
   - Click trash icon (🗑️)
   - Confirm removal

6. **Save Changes**:
   - Click "Save Changes" button
   - Changes are saved to database

7. **Convert to Bill**:
   - Review all items and prices
   - Click "Convert to Bill"
   - Bill created with exact quantities and prices

## Testing Checklist

✅ Add new product to order
✅ Remove product from order
✅ Edit cartons quantity
✅ Edit loose units quantity
✅ Total units calculate correctly
✅ Edit unit price
✅ Use suggested price (R/W button)
✅ Line total updates in real-time
✅ Grand total recalculates correctly
✅ Custom price badge shows correctly
✅ NEW badge shows for added items
✅ Save changes persists to database
✅ Convert to bill uses updated data
✅ Stock deduction uses final quantities
✅ Bill has correct prices and totals

## Technical Details

### API Endpoints:
- `GET /api/products/active` - Returns all active products with prices

### Form Submission Format:
```javascript
items[0][id] = 123          // Existing item
items[0][product_id] = 5
items[0][final_cartons] = 10
items[0][final_loose] = 5
items[0][unit_price] = 15.00

items[1][id] = 0            // New item
items[1][product_id] = 8
items[1][final_cartons] = 5
items[1][final_loose] = 0
items[1][unit_price] = 12.50
```

### JavaScript Functions:
- `loadProducts()` - Fetch products from API
- `showAddProductModal()` - Open add product modal
- `addProductToOrder()` - Add new row to table
- `removeItem()` - Remove row from table
- `applySuggestedPrice()` - Apply retail/wholesale price
- `calculateTotalUnits()` - Cartons × UPC + Loose
- `calculateLineTotal()` - Units × Price
- `recalculateGrandTotal()` - Sum all line totals
- `convertToBill()` - Submit to convert endpoint

## Benefits

1. **Flexibility**: Admin can adjust orders before bill creation
2. **Accuracy**: Fix quantity/price errors before stock deduction
3. **Efficiency**: Add missing items without creating new order
4. **Transparency**: See retail/wholesale prices for reference
5. **User Experience**: Real-time feedback, no page refreshes
6. **Data Integrity**: Proper handling of new/existing/removed items

## Status: ✅ COMPLETE

The order edit enhancement is fully functional with:
- Add/remove products
- Edit quantities and prices
- Auto-calculation based on shop type
- Real-time updates
- Complete database persistence

All changes flow correctly from order edit → bill conversion → stock deduction → shop ledger.
