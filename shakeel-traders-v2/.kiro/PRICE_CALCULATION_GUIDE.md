# Price Calculation Guide - Complete Flow

## Overview
This document explains how prices are calculated in every scenario of the Shakeel Traders Distribution System.

---

## 1. Product Master Prices

Every product has TWO base prices stored in the `products` table:

```sql
retail_price     DECIMAL(10,2)  -- Price for retail shops
wholesale_price  DECIMAL(10,2)  -- Price for wholesale shops
```

**Example:**
- Product: CBL Biscuit 100g
- Retail Price: Rs. 15.00
- Wholesale Price: Rs. 13.50

---

## 2. Shop Configuration

Every shop has a type that determines which base price to use:

```sql
shop_type ENUM('retail', 'wholesale')
```

**Shop Type Determines Default Price:**
- `shop_type = 'retail'` → Use `retail_price`
- `shop_type = 'wholesale'` → Use `wholesale_price`

**Optional: Price Editing Permission**
```sql
price_edit_allowed      TINYINT(1)      -- 0 = No, 1 = Yes
price_max_discount_pct  DECIMAL(5,2)    -- e.g., 10.00 = max 10% discount
```

---

## 3. Price Calculation Scenarios

### **Scenario 1: Order Booker Creates Order on Mobile App**

#### **Case 1A: Shop Has NO Price Edit Permission**
```
Shop: ABC Store (RETAIL)
price_edit_allowed = 0

Mobile App Behavior:
- Shows product with retail_price: Rs. 15.00
- Price field is READ-ONLY
- Order booker CANNOT change price
- Order syncs with unit_price = 15.00 (retail_price)
```

**Flow:**
```
Product.retail_price (15.00)
  ↓
Mobile App (READ-ONLY)
  ↓
order_items.unit_price = 15.00
```

#### **Case 1B: Shop Has Price Edit Permission**
```
Shop: XYZ Wholesale (WHOLESALE)
price_edit_allowed = 1
price_max_discount_pct = 10.00  (max 10% discount)

Mobile App Behavior:
- Shows product with wholesale_price: Rs. 13.50
- Price field is EDITABLE
- Minimum allowed: 13.50 - (13.50 × 10%) = Rs. 12.15
- Maximum allowed: 13.50 (cannot exceed base price)
- Order booker can adjust price between 12.15 - 13.50
- Order syncs with custom unit_price (e.g., 12.80)
```

**Flow:**
```
Product.wholesale_price (13.50)
  ↓
Mobile App (EDITABLE with range 12.15 - 13.50)
  ↓
Order Booker sets custom price: 12.80
  ↓
order_items.unit_price = 12.80 (CUSTOM PRICE)
```

**Validation on Mobile:**
```javascript
const basePrice = shopType === 'wholesale' ? wholesalePrice : retailPrice;
const maxDiscount = priceMaxDiscountPct / 100;
const minAllowedPrice = basePrice * (1 - maxDiscount);
const maxAllowedPrice = basePrice;

if (customPrice < minAllowedPrice || customPrice > maxAllowedPrice) {
  // Show error: "Price must be between Rs. X and Rs. Y"
}
```

---

### **Scenario 2: Evening Sync - Order Arrives at Server**

**What Happens:**
```javascript
// SyncService.js - processEveningSync()

// Order item from mobile app includes:
{
  product_id: 5,
  cartons: 10,
  loose_units: 5,
  unit_price: 12.80  // Custom price from mobile
}

// Server saves to database:
INSERT INTO order_items 
  (order_id, product_id, ordered_cartons, ordered_loose, 
   final_cartons, final_loose, unit_price)
VALUES 
  (123, 5, 10, 5, 10, 5, 12.80);
  //                        ^^^^^ Custom price is saved!
```

**Key Point:** The `unit_price` from mobile app is saved directly to `order_items` table.

---

### **Scenario 3: Admin Views Order (Before Conversion)**

**Web Admin Panel - Order View Page:**

```
Shop: XYZ Wholesale (WHOLESALE)

Product: CBL Biscuit 100g
Cartons: 10
Loose: 5
Total Units: 245 (10 × 24 + 5)

Suggested Price (Wholesale): Rs. 13.50  ← From product.wholesale_price
Current Price: Rs. 12.80                ← From order_items.unit_price
Badge: [Custom Price]                   ← Shows because 12.80 ≠ 13.50

Line Total: 245 × 12.80 = Rs. 3,136.00
```

**Calculation in view.ejs:**
```javascript
const shopType = order.shop_type; // 'wholesale'
const suggestedPrice = shopType === 'wholesale' 
  ? item.wholesale_price  // Rs. 13.50
  : item.retail_price;    // Rs. 15.00

const currentPrice = item.unit_price; // Rs. 12.80 (from DB)
const isCustomPrice = currentPrice !== suggestedPrice; // true
```

---

### **Scenario 4: Admin Edits Order**

#### **Case 4A: Admin Changes Quantity Only**
```
Before:
  Cartons: 10, Loose: 5, Price: 12.80
  Line Total: 245 × 12.80 = Rs. 3,136.00

Admin changes:
  Cartons: 15, Loose: 0, Price: 12.80 (unchanged)
  
After:
  New Total Units: 15 × 24 + 0 = 360
  Line Total: 360 × 12.80 = Rs. 4,608.00
```

#### **Case 4B: Admin Changes Price Only**
```
Before:
  Cartons: 10, Loose: 5, Price: 12.80
  Line Total: 245 × 12.80 = Rs. 3,136.00

Admin changes:
  Price: 13.00 (closer to suggested 13.50)
  
After:
  Line Total: 245 × 13.00 = Rs. 3,185.00
```

#### **Case 4C: Admin Uses "Use W" Button**
```
Before:
  Price: 12.80 (custom)
  
Admin clicks "Use W":
  Price: 13.50 (wholesale_price)
  
After:
  Line Total: 245 × 13.50 = Rs. 3,307.50
```

#### **Case 4D: Admin Adds New Product**
```
Admin clicks "+ Add Product"
Searches for: "CBL Cake"
Selects: CBL Cake 50g

System auto-fills:
  Shop Type: WHOLESALE
  Suggested Price: 9.00 (wholesale_price)
  Cartons: 0
  Loose: 0
  
Admin enters:
  Cartons: 5
  Loose: 10
  Price: 9.00 (uses suggested)
  
New Line:
  Total Units: (5 × 48) + 10 = 250
  Line Total: 250 × 9.00 = Rs. 2,250.00
```

---

### **Scenario 5: Admin Converts Order to Bill**

**What Happens:**
```javascript
// OrderService.js - convertOrderToBill()

// Fetch order items with custom prices
const [items] = await conn.query(`
  SELECT oi.*, p.units_per_carton, oi.unit_price
  FROM order_items oi
  JOIN products p ON p.id = oi.product_id
  WHERE oi.order_id = ?
`, [orderId]);

// oi.unit_price = 12.80 (custom price from order)
// NOT p.retail_price = 15.00 ✅ CORRECT!

// Create bill items
for (const item of items) {
  billItems.push({
    product_id: item.product_id,
    cartons: item.final_cartons,      // 10
    loose_units: item.final_loose,    // 5
    unit_price: item.unit_price,      // 12.80 ← USES CUSTOM PRICE!
    units_per_carton: item.units_per_carton
  });
}
```

**BillService.js - createBill():**
```javascript
// Calculate bill amounts
for (const item of billItems) {
  const units = (item.cartons * item.units_per_carton) + item.loose_units;
  // units = (10 × 24) + 5 = 245
  
  const lineTotal = units * item.unit_price;
  // lineTotal = 245 × 12.80 = 3,136.00
  
  grossAmount += lineTotal;
}

// Insert bill_items with custom price
INSERT INTO bill_items 
  (bill_id, product_id, cartons, loose_units, unit_price, line_total)
VALUES 
  (456, 5, 10, 5, 12.80, 3136.00);
  //               ^^^^^ Custom price preserved!
```

**Result:**
```
Bill #B-20260605-001
Shop: XYZ Wholesale

Item: CBL Biscuit 100g
Quantity: 10C + 5L = 245 units
Unit Price: Rs. 12.80  ← CUSTOM PRICE ✅
Line Total: Rs. 3,136.00

Gross Amount: Rs. 3,136.00
Shop Advance: Rs. 0.00
Net Amount: Rs. 3,136.00
```

---

### **Scenario 6: Direct Shop Sale (Admin Creates Bill Directly)**

**What Happens:**
```javascript
// DirectSalesController.js

Admin selects:
  Shop: ABC Store (RETAIL)
  Product: CBL Biscuit 100g
  Cartons: 5
  Loose: 10

System auto-fills price based on shop type:
  Price: 15.00 (retail_price)
  
Admin can override:
  Price: 14.50 (gives custom discount)

Total Units: (5 × 24) + 10 = 130
Line Total: 130 × 14.50 = Rs. 1,885.00

Bill created with:
  bill_items.unit_price = 14.50
```

---

## 4. Price Calculation Summary Table

| Scenario | Price Source | Can Be Custom? | Example |
|----------|-------------|----------------|---------|
| **Mobile App - No Edit Permission** | `product.retail_price` or `product.wholesale_price` | ❌ No | Rs. 15.00 |
| **Mobile App - With Edit Permission** | Order booker sets within allowed range | ✅ Yes | Rs. 12.80 (10% discount) |
| **Order Sync to Server** | Saved as `order_items.unit_price` | ✅ Yes | Rs. 12.80 (preserved) |
| **Admin Views Order** | Displays `order_items.unit_price` | ✅ Yes | Rs. 12.80 (can edit) |
| **Admin Edits Order** | Admin can change to any value | ✅ Yes | Rs. 13.00 (admin override) |
| **Admin Uses "Use R/W"** | Applies `product.retail_price` or `wholesale_price` | ❌ No | Rs. 13.50 (suggested) |
| **Admin Adds Product** | Auto-fills based on shop type | ✅ Yes | Rs. 9.00 (can change) |
| **Order to Bill Conversion** | Uses `order_items.unit_price` | ✅ Yes | Rs. 12.80 (exact match) |
| **Direct Shop Sale** | Auto-fills based on shop type, admin can override | ✅ Yes | Rs. 14.50 (admin set) |

---

## 5. Formula Reference

### **Base Price Selection:**
```javascript
if (shopType === 'wholesale') {
  basePrice = product.wholesale_price;
} else {
  basePrice = product.retail_price;
}
```

### **Price Edit Range (Mobile App):**
```javascript
const maxDiscountDecimal = priceMaxDiscountPct / 100;
minAllowedPrice = basePrice × (1 - maxDiscountDecimal);
maxAllowedPrice = basePrice;

// Example: 10% discount allowed on Rs. 13.50
// minAllowedPrice = 13.50 × (1 - 0.10) = Rs. 12.15
// maxAllowedPrice = Rs. 13.50
```

### **Total Units Calculation:**
```javascript
totalUnits = (cartons × unitsPerCarton) + looseUnits;

// Example:
// 10 cartons × 24 units/carton + 5 loose = 245 units
```

### **Line Total Calculation:**
```javascript
lineTotal = totalUnits × unitPrice;

// Example:
// 245 units × Rs. 12.80 = Rs. 3,136.00
```

### **Grand Total Calculation:**
```javascript
grandTotal = sum of all line totals;
```

### **Bill Net Amount:**
```javascript
grossAmount = sum of all line totals;
advanceDeducted = min(grossAmount, shopAdvanceBalance);
netAmount = grossAmount - advanceDeducted;
outstandingAmount = netAmount - amountPaid;
```

---

## 6. Real-World Examples

### **Example 1: Retail Shop with Standard Pricing**
```
Shop: Al-Noor Store (RETAIL)
price_edit_allowed = 0

Product: CBL Biscuit 100g
- Retail Price: Rs. 15.00
- Wholesale Price: Rs. 13.50

Order Booker books:
  Quantity: 5C + 10L = 130 units
  Price: Rs. 15.00 (cannot change)
  
Bill created:
  Line Total: 130 × 15.00 = Rs. 1,950.00
```

### **Example 2: Wholesale Shop with Discount**
```
Shop: City Wholesale (WHOLESALE)
price_edit_allowed = 1
price_max_discount_pct = 15.00

Product: CBL Biscuit 100g
- Wholesale Price: Rs. 13.50
- Min Allowed: Rs. 11.48 (15% discount)

Order Booker books:
  Quantity: 20C + 0L = 480 units
  Price: Rs. 12.00 (11% discount, within range)
  
Bill created:
  Line Total: 480 × 12.00 = Rs. 5,760.00
```

### **Example 3: Admin Override**
```
Shop: ABC Store (RETAIL)

Original Order:
  Price: Rs. 15.00 (retail)
  Quantity: 10C = 240 units
  Line Total: Rs. 3,600.00

Admin edits before conversion:
  Changes price to: Rs. 14.00 (special discount)
  
Bill created:
  Line Total: 240 × 14.00 = Rs. 3,360.00
  Discount given: Rs. 240.00
```

---

## 7. Key Points to Remember

✅ **Shop type determines suggested price** (retail vs wholesale)
✅ **Mobile app respects price edit permissions** (read-only or editable)
✅ **Custom prices are preserved** throughout the entire flow
✅ **Admin has final override** before bill conversion
✅ **"Use R/W" button** applies suggested price instantly
✅ **All calculations are real-time** in the UI
✅ **Database stores exact prices** used in each transaction

---

## Status: ✅ DOCUMENTED

This guide covers all price calculation scenarios in the Shakeel Traders Distribution System.
