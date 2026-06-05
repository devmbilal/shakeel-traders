-- Migration 002: Routes & Shops (Group B)

CREATE TABLE IF NOT EXISTS `routes` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(100)  NOT NULL,
  `is_active`  TINYINT(1)    NOT NULL DEFAULT 1,
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_route_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Daily assignment of routes to order bookers — FOR ORDER BOOKING ONLY.
-- Cash recovery assignment is in bill_recovery_assignments (completely separate).
CREATE TABLE IF NOT EXISTS `route_assignments` (
  `id`              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `route_id`        INT UNSIGNED  NOT NULL,
  `user_id`         INT UNSIGNED  NOT NULL,
  `assignment_date` DATE          NOT NULL,
  `created_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_route_date` (`route_id`, `assignment_date`),
  INDEX `idx_user_date` (`user_id`, `assignment_date`),
  INDEX `idx_assignment_date` (`assignment_date`),
  CONSTRAINT `fk_ra_route` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`),
  CONSTRAINT `fk_ra_user`  FOREIGN KEY (`user_id`)  REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shops` (
  `id`                 INT UNSIGNED               NOT NULL AUTO_INCREMENT,
  `name`               VARCHAR(150)               NOT NULL,
  `owner_name`         VARCHAR(100)               NULL DEFAULT NULL,
  `phone`              VARCHAR(20)                NULL DEFAULT NULL,
  `address`            TEXT                       NULL DEFAULT NULL,
  `route_id`           INT UNSIGNED               NOT NULL,
  `shop_type`          ENUM('retail','wholesale') NOT NULL DEFAULT 'retail',
  `price_edit_allowed` TINYINT(1)                 NOT NULL DEFAULT 0,
  `price_min_pct`      DECIMAL(5,2)               NULL DEFAULT NULL,
  `price_max_pct`      DECIMAL(5,2)               NULL DEFAULT NULL,
  `is_active`          TINYINT(1)                 NOT NULL DEFAULT 1,
  `created_at`         DATETIME                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_route` (`route_id`),
  INDEX `idx_is_active` (`is_active`),
  CONSTRAINT `fk_shop_route` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
