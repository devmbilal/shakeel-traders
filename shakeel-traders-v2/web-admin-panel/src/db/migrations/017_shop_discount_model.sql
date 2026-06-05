-- Migration 017: Replace price_min_pct + price_max_pct with single price_max_discount_pct
-- The new model: order booker can give a discount of 0% to price_max_discount_pct%.
-- Price must be >= basePrice * (1 - price_max_discount_pct / 100).
-- Price can never exceed the base price (no markup allowed).

ALTER TABLE shops
  ADD COLUMN price_max_discount_pct DECIMAL(5,2) DEFAULT 0.00 AFTER price_edit_allowed;

-- Migrate existing data: use price_max_pct as the discount cap (if it was negative, use 0)
-- Old price_min_pct was e.g. -10 meaning 10% below base — that becomes max_discount_pct = 10
UPDATE shops
  SET price_max_discount_pct = CASE
    WHEN price_min_pct IS NOT NULL AND price_min_pct < 0 THEN ABS(price_min_pct)
    ELSE 0
  END
  WHERE price_edit_allowed = 1;

-- Keep old columns for now (backward compat with any existing queries), but they are deprecated.
-- They can be dropped in a future migration once all code is updated.
