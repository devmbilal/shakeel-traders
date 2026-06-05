-- Migration 012: Supporting Tables (Group L)

-- Most recent price charged to each shop per product.
-- Downloaded to mobile for order booker reference.
CREATE TABLE IF NOT EXISTS `shop_last_prices` (
  `id`         INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `shop_id`    INT UNSIGNED   NOT NULL,
  `product_id` INT UNSIGNED   NOT NULL,
  `last_price` DECIMAL(10,2)  NOT NULL,
  `updated_at` DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_shop_product` (`shop_id`, `product_id`),
  CONSTRAINT `fk_slp_shop`    FOREIGN KEY (`shop_id`)    REFERENCES `shops` (`id`),
  CONSTRAINT `fk_slp_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
  -- Updated automatically whenever a bill is created or converted for this shop/product
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Shakeel Traders' own business profile — printed on all bills.
-- Single-row table. Always use id = 1.
CREATE TABLE IF NOT EXISTS `company_profile` (
  `id`           INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `company_name` VARCHAR(200)   NOT NULL,
  `owner_name`   VARCHAR(100)   NULL DEFAULT NULL,
  `address`      TEXT           NULL DEFAULT NULL,
  `phone_1`      VARCHAR(20)    NULL DEFAULT NULL,
  `phone_2`      VARCHAR(20)    NULL DEFAULT NULL,
  `email`        VARCHAR(100)   NULL DEFAULT NULL,
  `gst_ntn`      VARCHAR(50)    NULL DEFAULT NULL,
  `logo_path`    VARCHAR(500)   NULL DEFAULT NULL,
  `updated_at`   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default company profile row (id=1)
INSERT IGNORE INTO `company_profile` (`id`, `company_name`) VALUES (1, 'Shakeel Traders');
