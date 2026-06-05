-- Migration 001: Users & Delivery Men (Group A)
-- Engine: MySQL 8.x | InnoDB | utf8mb4_unicode_ci

CREATE TABLE IF NOT EXISTS `users` (
  `id`            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  `full_name`     VARCHAR(100)    NOT NULL,
  `username`      VARCHAR(50)     NOT NULL,
  `password_hash` VARCHAR(255)    NOT NULL,
  `role`          ENUM('admin','order_booker','salesman') NOT NULL,
  `contact`       VARCHAR(20)     NULL DEFAULT NULL,
  `is_active`     TINYINT(1)      NOT NULL DEFAULT 1,
  `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_username` (`username`),
  INDEX `idx_role` (`role`),
  INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Users cannot be deleted, only deactivated (is_active = 0)
-- Delivery Men are NOT in this table

CREATE TABLE IF NOT EXISTS `delivery_men` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `full_name`  VARCHAR(100)  NOT NULL,
  `contact`    VARCHAR(20)   NULL DEFAULT NULL,
  `is_active`  TINYINT(1)    NOT NULL DEFAULT 1,
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
