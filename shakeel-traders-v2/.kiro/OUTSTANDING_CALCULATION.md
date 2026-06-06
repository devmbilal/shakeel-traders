# Total Outstanding Amount Calculation

## How It's Calculated

The **Total Outstanding Amount** shown on the dashboard is calculated using this SQL query:

```sql
SELECT 
  SUM(outstanding_amount) AS total_outstanding,
  COUNT(*) AS bill_count
FROM bills 
WHERE status IN ('open', 'partially_paid')
  AND bill_type IN ('order_booker', 'direct_shop')
```

---

## Breakdown

### What Gets Included:

#### 1. **Bill Status Filter**
Only bills with these statuses:
- `'open'` - Bills that haven't been paid at all
- `'partially_paid'` - Bills that have been partially paid

**Excluded statuses:**
- ❌ `'cleared'` - Fully paid bills (outstanding = 0)
- ❌ `'cancelled'` - Cancelled bills

#### 2. **Bill Type Filter**
Only these types of bills:
- ✅ `'order_booker'` - Orders taken by salesman/booker
- ✅ `'direct_shop'` - Direct shop sales

**Excluded types:**
- ❌ `'salesman_sale'` - Salesman sales (handled differently)
- ❌ Other bill types (if any)

#### 3. **Outstanding Amount**
For each bill, the `outstanding_amount` field is calculated as:

```
outstanding_amount = net_amount - amount_paid
```

Where:
- `net_amount` = `gross_amount - advance_deducted`
- `amount_paid` = Total amount collected so far
- `outstanding_amount` = Remaining amount to be collected

---

## Example Calculation

### Scenario:
You have 3 bills in the system:

**Bill 1:**
- Gross Amount: Rs 10,000
- Advance Deducted: Rs 1,000
- Net Amount: Rs 9,000
- Amount Paid: Rs 5,000
- **Outstanding Amount: Rs 4,000**
- Status: `partially_paid`
- Type: `order_booker`

**Bill 2:**
- Gross Amount: Rs 15,000
- Advance Deducted: Rs 0
- Net Amount: Rs 15,000
- Amount Paid: Rs 0
- **Outstanding Amount: Rs 15,000**
- Status: `open`
- Type: `direct_shop`

**Bill 3:**
- Gross Amount: Rs 8,000
- Advance Deducted: Rs 0
- Net Amount: Rs 8,000
- Amount Paid: Rs 8,000
- **Outstanding Amount: Rs 0**
- Status: `cleared`
- Type: `order_booker`

### Calculation:
```
Total Outstanding = Bill 1 + Bill 2 + Bill 3
                  = Rs 4,000 + Rs 15,000 + Rs 0 (excluded - cleared)
                  = Rs 19,000
```

**Result:** Dashboard shows **"Rs 19,000"** as Total Outstanding

---

## Bill Status Lifecycle

```
┌─────────────────────────────────────────────────────┐
│  Bill Created                                       │
│  outstanding_amount = net_amount                    │
│  status = 'open'                                    │
└─────────────────┬───────────────────────────────────┘
                  │
                  │ Customer makes partial payment
                  ↓
┌─────────────────────────────────────────────────────┐
│  Partial Payment Received                           │
│  outstanding_amount = net_amount - amount_paid      │
│  status = 'partially_paid'                          │
└─────────────────┬───────────────────────────────────┘
                  │
                  │ Customer pays remaining amount
                  ↓
┌─────────────────────────────────────────────────────┐
│  Fully Paid                                         │
│  outstanding_amount = 0                             │
│  status = 'cleared'                                 │
│  ❌ NO LONGER INCLUDED IN TOTAL OUTSTANDING         │
└─────────────────────────────────────────────────────┘
```

---

## Where Outstanding Amount Is Updated

### 1. **Cash Recovery**
When a booker collects cash from a shop:
```javascript
newAmountPaid = currentAmountPaid + collectedAmount;
newOutstanding = netAmount - newAmountPaid;

UPDATE bills 
SET amount_paid = newAmountPaid,
    outstanding_amount = newOutstanding,
    status = (newOutstanding === 0) ? 'cleared' : 'partially_paid'
WHERE id = billId
```

### 2. **Centralized Cash**
When cash is recorded in the centralized cash system:
```javascript
newAmountPaid = currentAmountPaid + receivedAmount;
newOutstanding = netAmount - newAmountPaid;

UPDATE bills 
SET amount_paid = newAmountPaid,
    outstanding_amount = newOutstanding,
    status = (newOutstanding === 0) ? 'cleared' : 'partially_paid'
WHERE id = billId
```

### 3. **Bill Creation**
When a new bill is created:
```javascript
outstanding_amount = net_amount - amount_paid
// Initially amount_paid = 0, so outstanding = net_amount
status = 'open'
```

---

## SQL Query Breakdown

```sql
SELECT 
  SUM(outstanding_amount) AS total_outstanding,  -- Add all outstanding amounts
  COUNT(*) AS bill_count                         -- Count of bills
FROM bills 
WHERE status IN ('open', 'partially_paid')       -- Only unpaid/partially paid
  AND bill_type IN ('order_booker', 'direct_shop') -- Only these types
```

### Result Structure:
```javascript
{
  total_outstanding: 125000.50,  // Total Rs amount
  bill_count: 45                 // Number of bills with outstanding
}
```

---

## Dashboard Display

The result is formatted and displayed in the **Financial Hero Card**:

```javascript
financials: {
  totalOutstanding: parseFloat(outstandingData.total_outstanding || 0),
  outstandingBillCount: parseInt(outstandingData.bill_count || 0),
  // ... other metrics
}
```

**Display:**
```
┌─────────────────────────────┐
│ Total Outstanding           │
│ Rs 125,000.50              │
│ 45 bills                    │
└─────────────────────────────┘
```

---

## Important Notes

### ✅ What IS Included:
- Bills with status `'open'` or `'partially_paid'`
- Only `order_booker` and `direct_shop` bill types
- All amounts in `outstanding_amount` field

### ❌ What IS NOT Included:
- Cleared bills (status = `'cleared'`)
- Cancelled bills (status = `'cancelled'`)
- Salesman sales (different flow)
- Shop ledger balances (tracked separately)
- Supplier advances (shown as separate metric)

### 🔄 Real-Time Updates:
- Updates immediately when payment is recorded
- Recalculated on every dashboard load
- No caching - always current data

---

## Related Metrics

### On Dashboard:

**1. Total Outstanding** (This metric)
- Sum of all unpaid/partially paid bills
- Source: `bills.outstanding_amount`

**2. Cash Collected**
- Total cash received today/month/year
- Source: Various cash collection tables

**3. Supplier Advance**
- Money given to suppliers in advance
- Source: `supplier_companies.current_advance_balance`

**4. Stock Value**
- Total value of inventory
- Source: `products` (stock × price)

---

## Verification Query

To manually verify the total outstanding, run:

```sql
-- Total Outstanding
SELECT 
  SUM(outstanding_amount) AS total_outstanding,
  COUNT(*) AS bill_count
FROM bills 
WHERE status IN ('open', 'partially_paid')
  AND bill_type IN ('order_booker', 'direct_shop');

-- Detailed breakdown by status
SELECT 
  status,
  COUNT(*) AS count,
  SUM(outstanding_amount) AS outstanding
FROM bills 
WHERE status IN ('open', 'partially_paid')
  AND bill_type IN ('order_booker', 'direct_shop')
GROUP BY status;

-- Detailed breakdown by bill type
SELECT 
  bill_type,
  COUNT(*) AS count,
  SUM(outstanding_amount) AS outstanding
FROM bills 
WHERE status IN ('open', 'partially_paid')
  AND bill_type IN ('order_booker', 'direct_shop')
GROUP BY bill_type;
```

---

## Summary

**Total Outstanding** = Sum of all money that customers owe (haven't paid yet) from:
- Open bills (not paid at all)
- Partially paid bills (some amount still pending)
- Only from order booker and direct shop bills

This amount decreases when:
- ✅ Customers make payments (cash recovery)
- ✅ Cash is collected and recorded
- ✅ Bills are marked as cleared

This amount increases when:
- ⬆️ New bills are created
- ⬆️ New orders are dispatched

**Formula:** `Outstanding = Net Amount - Amount Paid` (for each bill)

Simple and accurate! 📊✅
