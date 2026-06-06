# How Dashboard Shows Rs 2.7L Outstanding

## Where Rs 270,000 Comes From

The dashboard calculates **Total Outstanding** by summing the **latest ledger balance** for each shop that has a positive balance (owes money).

---

## To Verify the Rs 2.7L Amount

### Method 1: Run SQL Query

Open your database client and run:

```sql
SELECT 
  SUM(latest.balance_after) AS total_outstanding,
  COUNT(DISTINCT latest.shop_id) AS shop_count
FROM (
  SELECT 
    sle.shop_id,
    sle.balance_after,
    ROW_NUMBER() OVER (PARTITION BY sle.shop_id ORDER BY sle.created_at DESC, sle.id DESC) as rn
  FROM shop_ledger_entries sle
  INNER JOIN shops s ON s.id = sle.shop_id
  WHERE s.is_active = 1
) AS latest
WHERE latest.rn = 1 AND latest.balance_after > 0;
```

**Expected Result:**
```
total_outstanding: 270000 (or similar)
shop_count: X (number of shops with outstanding)
```

---

### Method 2: See Breakdown by Shop

To see which shops contribute to the Rs 2.7L:

```sql
SELECT 
  s.name AS shop_name,
  s.owner_name,
  r.name AS route_name,
  sle.balance_after AS outstanding,
  CONCAT('Rs ', FORMAT(sle.balance_after, 0)) AS formatted
FROM (
  SELECT 
    shop_id,
    balance_after,
    ROW_NUMBER() OVER (PARTITION BY shop_id ORDER BY created_at DESC, id DESC) as rn
  FROM shop_ledger_entries
) AS sle
INNER JOIN shops s ON s.id = sle.shop_id
LEFT JOIN routes r ON r.id = s.route_id
WHERE sle.rn = 1 
  AND s.is_active = 1 
  AND sle.balance_after > 0
ORDER BY sle.balance_after DESC;
```

**This shows:**
- Shop Name
- Owner Name
- Route
- Outstanding Amount
- Formatted Amount

**Example Output:**
```
Shop A    | Owner 1 | Route X | 50,000  | Rs 50,000
Shop B    | Owner 2 | Route Y | 45,000  | Rs 45,000
Shop C    | Owner 3 | Route Z | 38,000  | Rs 38,000
...
Total: Rs 270,000
```

---

## Understanding the Calculation

### Each Shop Has a Ledger:

The `shop_ledger_entries` table tracks all transactions for each shop:

```
Shop #1 Ledger:
├─ Jan 1:  Bill created     +50,000 → Balance: 50,000
├─ Jan 5:  Payment          -20,000 → Balance: 30,000
├─ Jan 10: Bill created     +25,000 → Balance: 55,000
└─ Jan 15: Payment          -15,000 → Balance: 40,000 ← Latest

Shop #1 Outstanding: Rs 40,000
```

### Dashboard Sums All Latest Balances:

```
Shop #1:  Rs 40,000
Shop #2:  Rs 35,000
Shop #3:  Rs 28,000
Shop #4:  Rs 22,000
... (more shops)
─────────────────────
Total:    Rs 270,000 (2.7L)
```

---

## Why This Number Might Seem Different

### Possible Reasons for Rs 2.7L:

#### 1. **Historical Outstanding**
Shops had previous balances that were never fully paid:
```
Old outstanding: Rs 150,000
New bills:       Rs 120,000
Total:           Rs 270,000
```

#### 2. **Multiple Unpaid Bills Per Shop**
Each shop might have several unpaid bills:
```
Shop A: Bill 1 (Rs 30k) + Bill 2 (Rs 20k) = Rs 50k
Shop B: Bill 1 (Rs 40k) + Bill 2 (Rs 15k) = Rs 55k
...
```

#### 3. **Opening Balances**
Shops started with outstanding amounts when system launched

#### 4. **Advances Not Recovered**
Money given as advances that shops haven't repaid

---

## To Find Specific Details

### Query 1: See All Ledger Entries for a Specific Shop

```sql
SELECT 
  entry_date,
  entry_type,
  reference_type,
  debit,
  credit,
  balance_after,
  note
FROM shop_ledger_entries
WHERE shop_id = ? -- Replace ? with shop ID
ORDER BY created_at ASC;
```

### Query 2: Compare Ledger vs Bills

```sql
-- From Ledger
SELECT 'Ledger Balance' AS source, 
       SUM(balance_after) AS amount
FROM (
  SELECT shop_id, balance_after,
    ROW_NUMBER() OVER (PARTITION BY shop_id ORDER BY created_at DESC) as rn
  FROM shop_ledger_entries
) latest
WHERE rn = 1 AND balance_after > 0

UNION ALL

-- From Bills
SELECT 'Bills Outstanding' AS source,
       SUM(outstanding_amount) AS amount
FROM bills
WHERE status IN ('open', 'partially_paid');
```

**If these don't match**, the difference is:
- Historical balances
- Opening amounts
- Non-bill transactions

---

## Common Scenarios

### Scenario 1: Matches Your Records
```
Your calculation: Rs 270,000 ✓
Dashboard shows:  Rs 270,000 ✓
Status: Correct
```

### Scenario 2: Higher Than Expected
```
Your calculation: Rs 150,000
Dashboard shows:  Rs 270,000

Difference (Rs 120,000) could be:
- Historical outstanding you didn't count
- Opening balances from system start
- Advances given to shops
```

Run the breakdown query to see exactly where Rs 270k comes from.

### Scenario 3: Includes Inactive Shops
```sql
-- Check if inactive shops are included (they shouldn't be)
SELECT 
  s.name,
  s.is_active,
  sle.balance_after
FROM (
  SELECT shop_id, balance_after,
    ROW_NUMBER() OVER (PARTITION BY shop_id ORDER BY created_at DESC) as rn
  FROM shop_ledger_entries
) sle
JOIN shops s ON s.id = sle.shop_id
WHERE sle.rn = 1 AND sle.balance_after > 0 AND s.is_active = 0;
```

If this returns results, there's a bug (inactive shops shouldn't be counted).

---

## Quick Verification Steps

### Step 1: Count Shops
```sql
SELECT COUNT(*) AS shop_count
FROM (
  SELECT DISTINCT shop_id
  FROM shop_ledger_entries sle
  JOIN shops s ON s.id = sle.shop_id
  WHERE s.is_active = 1
    AND sle.balance_after > 0
) shops;
```

### Step 2: Get Total
```sql
SELECT SUM(balance_after) AS total
FROM (
  SELECT shop_id, balance_after,
    ROW_NUMBER() OVER (PARTITION BY shop_id ORDER BY created_at DESC) as rn
  FROM shop_ledger_entries
) latest
WHERE rn = 1 AND balance_after > 0;
```

### Step 3: Get Top 5 Contributors
```sql
SELECT s.name, sle.balance_after
FROM (
  SELECT shop_id, balance_after,
    ROW_NUMBER() OVER (PARTITION BY shop_id ORDER BY created_at DESC) as rn
  FROM shop_ledger_entries
) sle
JOIN shops s ON s.id = sle.shop_id
WHERE sle.rn = 1 AND sle.balance_after > 0
ORDER BY sle.balance_after DESC
LIMIT 5;
```

---

## If Number Seems Wrong

### Debug Checklist:

1. **Check for duplicate entries**
```sql
SELECT shop_id, COUNT(*) as entry_count
FROM shop_ledger_entries
GROUP BY shop_id
HAVING COUNT(*) > 1000; -- Unusually high
```

2. **Check for very large balances**
```sql
SELECT s.name, sle.balance_after
FROM (
  SELECT shop_id, balance_after,
    ROW_NUMBER() OVER (PARTITION BY shop_id ORDER BY created_at DESC) as rn
  FROM shop_ledger_entries
) sle
JOIN shops s ON s.id = sle.shop_id
WHERE sle.rn = 1 AND sle.balance_after > 100000; -- Over 1L
```

3. **Check for negative balances (credits)**
```sql
SELECT COUNT(*), SUM(ABS(balance_after))
FROM (
  SELECT balance_after,
    ROW_NUMBER() OVER (PARTITION BY shop_id ORDER BY created_at DESC) as rn
  FROM shop_ledger_entries
) latest
WHERE rn = 1 AND balance_after < 0;
```

---

## Summary

**Rs 2.7L (270,000) is calculated by:**

1. Getting the latest ledger entry for each active shop
2. Taking the `balance_after` value (current outstanding)
3. Summing all positive balances
4. Displaying as "Total Outstanding"

**To verify:**
- Run the SQL queries provided
- Check the breakdown by shop
- Compare with your manual calculation
- Investigate any discrepancies

The number represents the **total amount all shops owe** across all transactions, not just current bills.

**Files to check:**
- Database: `shop_ledger_entries` table
- Code: `src/controllers/DashboardController.js` (line ~72-90)
- SQL: Use queries in `CHECK_OUTSTANDING.sql`

Need help investigating further? Run the queries and share the results!
