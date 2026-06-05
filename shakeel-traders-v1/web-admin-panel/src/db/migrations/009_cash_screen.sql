-- Migration 009: Centralized Cash Screen (Group I)

-- All cash received by the business across all three channels
CREATE TABLE IF NOT EXISTS `centralized_cash_entries` (
  `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `entry_type`     ENUM(
                     'salesman_sale',
                     'recovery',
                     'delivery_man_collection'
                   ) NOT NULL,
  `reference_id`   INT UNSIGNED  NULL DEFAULT NULL,
  `reference_type` VARCHAR(50)   NULL DEFAULT NULL,
  `amount`         DECIMAL(12,2) NOT NULL,
  `cash_date`      DATE          NOT NULL,
  `recorded_by`    INT UNSIGNED  NOT NULL,
  `created_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_entry_type_date` (`entry_type`, `cash_date`),
  INDEX `idx_cash_date` (`cash_date`),
  CONSTRAINT `fk_cce_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
  -- Three triggers create entries:
  --   a. Salesman return approved → entry_type = 'salesman_sale'
  --   b. Recovery collection verified → entry_type = 'recovery'
  --   c. Delivery man collection recorded → entry_type = 'delivery_man_collection'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Cash brought by delivery man for same-day bill settlement
CREATE TABLE IF NOT EXISTS `delivery_man_collections` (
  `id`               INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `bill_id`          INT UNSIGNED   NOT NULL,
  `delivery_man_id`  INT UNSIGNED   NOT NULL,
  `amount_collected` DECIMAL(12,2)  NOT NULL,
  `collection_date`  DATE           NOT NULL,
  `recorded_by`      INT UNSIGNED   NOT NULL,
  `created_at`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_bill` (`bill_id`),
  INDEX `idx_delivery_man` (`delivery_man_id`),
  INDEX `idx_date` (`collection_date`),
  CONSTRAINT `fk_dmc_bill`         FOREIGN KEY (`bill_id`)         REFERENCES `bills` (`id`),
  CONSTRAINT `fk_dmc_delivery_man` FOREIGN KEY (`delivery_man_id`) REFERENCES `delivery_men` (`id`),
  CONSTRAINT `fk_dmc_recorded_by`  FOREIGN KEY (`recorded_by`)     REFERENCES `users` (`id`)
  -- On INSERT: bills.amount_paid incremented
  -- On INSERT: if fully paid → bills.status = 'cleared'
  -- On INSERT: centralized_cash_entries row inserted (entry_type = 'delivery_man_collection')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
