-- Migration 004: Supplier Companies, Advances & Claims (Group D)

CREATE TABLE IF NOT EXISTS `supplier_companies` (
  `id`                      INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `name`                    VARCHAR(150)   NOT NULL,
  `contact_person`          VARCHAR(100)   NULL DEFAULT NULL,
  `phone`                   VARCHAR(20)    NULL DEFAULT NULL,
  `current_advance_balance` DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
  `is_active`               TINYINT(1)     NOT NULL DEFAULT 1,
  `created_at`              DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_supplier_name` (`name`)
  -- current_advance_balance updated transactionally:
  --   + Increases when supplier_advance is recorded
  --   - Decreases when stock_receipt is recorded
  --   + Increases when a claim is marked as cleared
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `supplier_advances` (
  `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `company_id`     INT UNSIGNED  NOT NULL,
  `amount`         DECIMAL(12,2) NOT NULL,
  `payment_date`   DATE          NOT NULL,
  `payment_method` ENUM('cash','bank_transfer','cheque','other') NOT NULL,
  `note`           TEXT          NULL DEFAULT NULL,
  `recorded_by`    INT UNSIGNED  NOT NULL,
  `created_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_company_date` (`company_id`, `payment_date`),
  CONSTRAINT `fk_sa_company`     FOREIGN KEY (`company_id`)  REFERENCES `supplier_companies` (`id`),
  CONSTRAINT `fk_sa_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
  -- On INSERT: supplier_companies.current_advance_balance += amount
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `stock_receipts` (
  `id`           INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `company_id`   INT UNSIGNED   NOT NULL,
  `receipt_date` DATE           NOT NULL,
  `total_value`  DECIMAL(12,2)  NOT NULL,
  `note`         TEXT           NULL DEFAULT NULL,
  `recorded_by`  INT UNSIGNED   NOT NULL,
  `created_at`   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_company_date` (`company_id`, `receipt_date`),
  CONSTRAINT `fk_sr_company`     FOREIGN KEY (`company_id`)  REFERENCES `supplier_companies` (`id`),
  CONSTRAINT `fk_sr_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
  -- On INSERT: supplier_companies.current_advance_balance -= total_value
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `stock_receipt_items` (
  `id`          INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `receipt_id`  INT UNSIGNED   NOT NULL,
  `product_id`  INT UNSIGNED   NOT NULL,
  `cartons`     INT UNSIGNED   NOT NULL DEFAULT 0,
  `loose_units` INT UNSIGNED   NOT NULL DEFAULT 0,
  `unit_price`  DECIMAL(10,2)  NOT NULL,
  `line_value`  DECIMAL(12,2)  NOT NULL,
  -- line_value = (cartons * units_per_carton + loose_units) * unit_price
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_sri_receipt` FOREIGN KEY (`receipt_id`) REFERENCES `stock_receipts` (`id`),
  CONSTRAINT `fk_sri_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
  -- On INSERT: products.current_stock_cartons and current_stock_loose incremented
  -- On INSERT: stock_movements row inserted (movement_type = 'receipt_supplier')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `claims` (
  `id`          INT UNSIGNED               NOT NULL AUTO_INCREMENT,
  `company_id`  INT UNSIGNED               NOT NULL,
  `claim_date`  DATE                       NOT NULL,
  `reason`      TEXT                       NOT NULL,
  `claim_value` DECIMAL(12,2)              NOT NULL,
  `status`      ENUM('pending','cleared')  NOT NULL DEFAULT 'pending',
  `cleared_at`  DATETIME                   NULL DEFAULT NULL,
  `recorded_by` INT UNSIGNED               NOT NULL,
  `created_at`  DATETIME                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_company_status` (`company_id`, `status`),
  CONSTRAINT `fk_claim_company`     FOREIGN KEY (`company_id`)  REFERENCES `supplier_companies` (`id`),
  CONSTRAINT `fk_claim_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
  -- When status changed to 'cleared': supplier_companies.current_advance_balance += claim_value
  -- Claimed products are NEVER added to warehouse stock
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `claim_items` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `claim_id`    INT UNSIGNED  NOT NULL,
  `product_id`  INT UNSIGNED  NOT NULL,
  `cartons`     INT UNSIGNED  NOT NULL DEFAULT 0,
  `loose_units` INT UNSIGNED  NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_ci_claim`   FOREIGN KEY (`claim_id`)   REFERENCES `claims` (`id`),
  CONSTRAINT `fk_ci_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
  -- Record only — NO stock movement ever
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
