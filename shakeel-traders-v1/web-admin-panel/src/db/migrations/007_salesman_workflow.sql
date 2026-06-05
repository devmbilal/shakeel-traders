-- Migration 007: Salesman Issuances & Returns (Group G)

CREATE TABLE IF NOT EXISTS `salesman_issuances` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `salesman_id`  INT UNSIGNED  NOT NULL,
  `issuance_date` DATE         NOT NULL,
  `status`       ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `approved_by`  INT UNSIGNED  NULL DEFAULT NULL,
  `approved_at`  DATETIME      NULL DEFAULT NULL,
  `created_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_salesman_date` (`salesman_id`, `issuance_date`),
  -- One issuance per salesman per day
  INDEX `idx_status` (`status`),
  CONSTRAINT `fk_si_salesman`    FOREIGN KEY (`salesman_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_si_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`)
  -- Warehouse stock deducted ONLY after status = 'approved'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `issuance_items` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `issuance_id` INT UNSIGNED  NOT NULL,
  `product_id`  INT UNSIGNED  NOT NULL,
  `cartons`     INT UNSIGNED  NOT NULL DEFAULT 0,
  `loose_units` INT UNSIGNED  NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_ii_issuance` FOREIGN KEY (`issuance_id`) REFERENCES `salesman_issuances` (`id`),
  CONSTRAINT `fk_ii_product`  FOREIGN KEY (`product_id`)  REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Evening return submission from a salesman — one per issuance
CREATE TABLE IF NOT EXISTS `salesman_returns` (
  `id`                     INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `issuance_id`            INT UNSIGNED   NOT NULL,
  `salesman_id`            INT UNSIGNED   NOT NULL,
  `return_date`            DATE           NOT NULL,
  `status`                 ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `system_sale_value`      DECIMAL(12,2)  NULL DEFAULT NULL,
  `admin_edited_sale_value` DECIMAL(12,2) NULL DEFAULT NULL,
  `final_sale_value`       DECIMAL(12,2)  NULL DEFAULT NULL,
  -- final_sale_value = admin_edited_sale_value if set, else system_sale_value
  `cash_collected`         DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
  `approved_by`            INT UNSIGNED   NULL DEFAULT NULL,
  `approved_at`            DATETIME       NULL DEFAULT NULL,
  `created_at`             DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_issuance_return` (`issuance_id`),
  -- One return per issuance
  INDEX `idx_status` (`status`),
  CONSTRAINT `fk_ret_issuance`   FOREIGN KEY (`issuance_id`) REFERENCES `salesman_issuances` (`id`),
  CONSTRAINT `fk_ret_salesman`   FOREIGN KEY (`salesman_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_ret_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`)
  -- On approval: returned stock added back to products warehouse stock
  -- On approval: final_sale_value posted to centralized_cash_entries
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `return_items` (
  `id`               INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `return_id`        INT UNSIGNED   NOT NULL,
  `product_id`       INT UNSIGNED   NOT NULL,
  `returned_cartons` INT UNSIGNED   NOT NULL DEFAULT 0,
  `returned_loose`   INT UNSIGNED   NOT NULL DEFAULT 0,
  `sold_cartons`     INT UNSIGNED   NOT NULL DEFAULT 0,  -- issued - returned
  `sold_loose`       INT UNSIGNED   NOT NULL DEFAULT 0,
  `retail_price`     DECIMAL(10,2)  NOT NULL,  -- Snapshotted at time of return
  `line_sale_value`  DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
  -- line_sale_value = (sold_cartons * units_per_carton + sold_loose) * retail_price
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_ri_return`  FOREIGN KEY (`return_id`)  REFERENCES `salesman_returns` (`id`),
  CONSTRAINT `fk_ri_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
