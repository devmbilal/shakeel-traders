-- Query to verify Total Outstanding calculation
-- This shows exactly how the Rs 2.7L is calculated

-- 1. Total Outstanding (as dashboard calculates it)
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

-- 2. Breakdown by shop (see which shops contribute to the total)
SELECT 
  s.id,
  s.name AS shop_name,
  s.owner_name,
  r.name AS route_name,
  sle.balance_after AS outstanding_amount,
  sle.entry_date AS last_entry_date
FROM (
  SELECT 
    shop_id,
    balance_after,
    entry_date,
    ROW_NUMBER() OVER (PARTITION BY shop_id ORDER BY created_at DESC, id DESC) as rn
  FROM shop_ledger_entries
) AS sle
INNER JOIN shops s ON s.id = sle.shop_id
LEFT JOIN routes r ON r.id = s.route_id
WHERE sle.rn = 1 
  AND s.is_active = 1 
  AND sle.balance_after > 0
ORDER BY sle.balance_after DESC;

-- 3. Total from bills.outstanding_amount (old method for comparison)
SELECT 
  SUM(outstanding_amount) AS bill_outstanding_total,
  COUNT(*) AS bill_count
FROM bills 
WHERE status IN ('open', 'partially_paid')
  AND bill_type IN ('order_booker', 'direct_shop');

-- 4. Comparison: Ledger vs Bills
SELECT 
  'Shop Ledger' AS source,
  SUM(latest.balance_after) AS total
FROM (
  SELECT 
    sle.shop_id,
    sle.balance_after,
    ROW_NUMBER() OVER (PARTITION BY sle.shop_id ORDER BY sle.created_at DESC, sle.id DESC) as rn
  FROM shop_ledger_entries sle
  INNER JOIN shops s ON s.id = sle.shop_id
  WHERE s.is_active = 1
) AS latest
WHERE latest.rn = 1 AND latest.balance_after > 0

UNION ALL

SELECT 
  'Bills Outstanding' AS source,
  SUM(outstanding_amount) AS total
FROM bills 
WHERE status IN ('open', 'partially_paid')
  AND bill_type IN ('order_booker', 'direct_shop');

-- 5. Top 10 shops with highest outstanding
SELECT 
  s.name AS shop_name,
  s.owner_name,
  r.name AS route_name,
  sle.balance_after AS outstanding,
  CONCAT('Rs ', FORMAT(sle.balance_after, 0)) AS formatted_amount
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
ORDER BY sle.balance_after DESC
LIMIT 10;

-- 6. Check for any negative balances (shops with credit)
SELECT 
  COUNT(*) AS shops_with_credit,
  SUM(ABS(balance_after)) AS total_credit_amount
FROM (
  SELECT 
    shop_id,
    balance_after,
    ROW_NUMBER() OVER (PARTITION BY shop_id ORDER BY created_at DESC, id DESC) as rn
  FROM shop_ledger_entries
) AS sle
INNER JOIN shops s ON s.id = sle.shop_id
WHERE sle.rn = 1 
  AND s.is_active = 1 
  AND sle.balance_after < 0;
