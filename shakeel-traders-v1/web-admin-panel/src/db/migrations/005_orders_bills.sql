-- Migration 005: Orders, Bills & Line Items (Group E)

CREATE TABLE IF NOT EXISTS `orders` (
  `id`               INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `order_booker_id`  INT UNSIGNED  NOT NULL,
  `shop_id`          INT UNSIGNED  NOT NULL,
  `route_id`         INT UNSIGNED  NOT NULL,
  `created_at_device` DATETIME     NOT NULL,  -- Device timestamp (offline)
  `synced_at`        DATETIME      NULL DEFAULT NULL,
  `status`           ENUM('pending','stock_adjusted','converted','cancelled') NOT NULL DEFAULT 'pending',
  `stock_check_note` TEXT          NULL DEFAULT NULL,
  `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_booker_date` (`order_booker_id`, `created_at_device`),
  INDEX `idx_shop` (`shop_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_route` (`route_id`),
  CONSTRAINT `fk_order_booker` FOREIGN KEY (`order_booker_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_order_shop`   FOREIGN KEY (`shop_id`)         REFERENCES `shops` (`id`),
  CONSTRAINT `fk_order_route`  FOREIGN KEY (`route_id`)        REFERENCES `routes` (`id`)
  -- One order per shop visit. Multiple visits = multiple orders = multiple bills.
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `order_items` (
  `id`               INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `order_id`         INT UNSIGNED   NOT NULL,
  `product_id`       INT UNSIGNED   NOT NULL,
  `ordered_cartons`  INT UNSIGNED   NOT NULL DEFAULT 0,  -- As entered by booker
  `ordered_loose`    INT UNSIGNED   NOT NULL DEFAULT 0,
  `final_cartons`    INT UNSIGNED   NOT NULL DEFAULT 0,  -- After stock adjustment
  `final_loose`      INT UNSIGNED   NOT NULL DEFAULT 0,
  `unit_price`       DECIMAL(10,2)  NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_order` (`order_id`),
  CONSTRAINT `fk_oi_order`   FOREIGN KEY (`order_id`)   REFERENCES `orders` (`id`),
  CONSTRAINT `fk_oi_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bills` (
  `id`                INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `order_id`          INT UNSIGNED  NULL DEFAULT NULL,  -- NULL for direct_shop and salesman bills
  `shop_id`           INT UNSIGNED  NOT NULL,
  `bill_type`         ENUM('order_booker','direct_shop','salesman') NOT NULL,
  `bill_date`         DATE          NOT NULL,
  `bill_number`       VARCHAR(30)   NOT NULL,
  `gross_amount`      DECIMAL(12,2) NOT NULL,
  `advance_deducted`  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `net_amount`        DECIMAL(12,2) NOT NULL,
  -- net_amount = gross_amount - advance_deducted
  `amount_paid`       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `outstanding_amount` DECIMAL(12,2) NOT NULL,
  -- outstanding_amount = net_amount - amount_paid
  `status`            ENUM('open','partially_paid','cleared') NOT NULL DEFAULT 'open',
  `created_by`        INT UNSIGNED  NOT NULL,
  `created_at`        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_bill_number` (`bill_number`),
  INDEX `idx_shop_status` (`shop_id`, `status`),
  INDEX `idx_bill_type` (`bill_type`),
  INDEX `idx_bill_date` (`bill_date`),
  INDEX `idx_status` (`status`),
  CONSTRAINT `fk_bill_order`      FOREIGN KEY (`order_id`)   REFERENCES `orders` (`id`),
  CONSTRAINT `fk_bill_shop`       FOREIGN KEY (`shop_id`)    REFERENCES `shops` (`id`),
  CONSTRAINT `fk_bill_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
  -- On INSERT: shop_ledger_entries row inserted (entry_type = 'bill')
  -- On INSERT: if shop has advance balance, advance_deducted populated
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bill_items` (
  `id`          INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `bill_id`     INT UNSIGNED   NOT NULL,
  `product_id`  INT UNSIGNED   NOT NULL,
  `cartons`     INT UNSIGNED   NOT NULL DEFAULT 0,
  `loose_units` INT UNSIGNED   NOT NULL DEFAULT 0,
  `unit_price`  DECIMAL(10,2)  NOT NULL,
  `line_total`  DECIMAL(12,2)  NOT NULL,
  -- line_total = (cartons * units_per_carton + loose_units) * unit_price
  PRIMARY KEY (`id`),
  INDEX `idx_bill` (`bill_id`),
  CONSTRAINT `fk_bi_bill`    FOREIGN KEY (`bill_id`)    REFERENCES `bills` (`id`),
  CONSTRAINT `fk_bi_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
