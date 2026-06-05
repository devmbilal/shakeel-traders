-- Migration 003: Products & Warehouse Stock (Group C)

CREATE TABLE IF NOT EXISTS `products` (
  `id`                    INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `sku_code`              VARCHAR(50)    NOT NULL,
  `name`                  VARCHAR(150)   NOT NULL,
  `brand`                 VARCHAR(100)   NULL DEFAULT NULL,
  `units_per_carton`      INT UNSIGNED   NOT NULL,
  `retail_price`          DECIMAL(10,2)  NOT NULL,
  `wholesale_price`       DECIMAL(10,2)  NOT NULL,
  `current_stock_cartons` INT UNSIGNED   NOT NULL DEFAULT 0,
  `current_stock_loose`   INT UNSIGNED   NOT NULL DEFAULT 0,
  `low_stock_threshold`   INT UNSIGNED   NULL DEFAULT NULL,
  `is_active`             TINYINT(1)     NOT NULL DEFAULT 1,
  `created_at`            DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`            DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_sku` (`sku_code`),
  INDEX `idx_is_active` (`is_active`),
  -- Stock can NEVER go negative
  CONSTRAINT `chk_stock_non_negative`
    CHECK (`current_stock_cartons` >= 0 AND `current_stock_loose` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Complete audit ledger of every warehouse stock change
CREATE TABLE IF NOT EXISTS `stock_movements` (
  `id`                  INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `product_id`          INT UNSIGNED  NOT NULL,
  `movement_type`       ENUM(
                          'receipt_supplier',
                          'manual_add',
                          'bill_deduction',
                          'issuance_salesman',
                          'return_salesman',
                          'direct_sale_deduction'
                        ) NOT NULL,
  `reference_id`        INT UNSIGNED  NULL DEFAULT NULL,
  `reference_type`      VARCHAR(50)   NULL DEFAULT NULL,
  `cartons_in`          INT UNSIGNED  NOT NULL DEFAULT 0,
  `loose_in`            INT UNSIGNED  NOT NULL DEFAULT 0,
  `cartons_out`         INT UNSIGNED  NOT NULL DEFAULT 0,
  `loose_out`           INT UNSIGNED  NOT NULL DEFAULT 0,
  `stock_after_cartons` INT UNSIGNED  NOT NULL,
  `stock_after_loose`   INT UNSIGNED  NOT NULL,
  `note`                TEXT          NULL DEFAULT NULL,
  `created_by`          INT UNSIGNED  NOT NULL,
  `created_at`          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_product_date` (`product_id`, `created_at`),
  INDEX `idx_movement_type` (`movement_type`),
  CONSTRAINT `fk_sm_product`    FOREIGN KEY (`product_id`)  REFERENCES `products` (`id`),
  CONSTRAINT `fk_sm_created_by` FOREIGN KEY (`created_by`)  REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
