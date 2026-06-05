-- Migration 006: Shop Ledger & Advances (Group F)

-- Chronological ledger of ALL financial events for a shop.
-- APPEND ONLY — no updates or deletes ever.
CREATE TABLE IF NOT EXISTS `shop_ledger_entries` (
  `id`            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `shop_id`       INT UNSIGNED  NOT NULL,
  `entry_type`    ENUM(
                    'bill',
                    'payment_delivery_man',
                    'recovery',
                    'advance_payment',
                    'advance_adjustment',
                    'claim_credit'
                  ) NOT NULL,
  `reference_id`   INT UNSIGNED  NULL DEFAULT NULL,
  `reference_type` VARCHAR(50)   NULL DEFAULT NULL,
  `debit`          DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `credit`         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `balance_after`  DECIMAL(12,2) NOT NULL,
  -- Negative value = shop has credit (advance remaining)
  `note`           TEXT          NULL DEFAULT NULL,
  `entry_date`     DATE          NOT NULL,
  `created_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_shop_date` (`shop_id`, `entry_date`),
  INDEX `idx_entry_type` (`entry_type`),
  CONSTRAINT `fk_sle_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`)
  -- APPEND ONLY for audit integrity — never UPDATE or DELETE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_advances` (
  `id`                INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `shop_id`           INT UNSIGNED  NOT NULL,
  `amount`            DECIMAL(12,2) NOT NULL,
  `remaining_balance` DECIMAL(12,2) NOT NULL,
  `advance_date`      DATE          NOT NULL,
  `payment_method`    ENUM('cash','bank_transfer','cheque','other') NOT NULL,
  `note`              TEXT          NULL DEFAULT NULL,
  `recorded_by`       INT UNSIGNED  NOT NULL,
  `created_at`        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_shop` (`shop_id`),
  CONSTRAINT `fk_sadv_shop`        FOREIGN KEY (`shop_id`)     REFERENCES `shops` (`id`),
  CONSTRAINT `fk_sadv_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
  -- remaining_balance decremented when bills are created for this shop
  -- Only admin can record shop advances
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
