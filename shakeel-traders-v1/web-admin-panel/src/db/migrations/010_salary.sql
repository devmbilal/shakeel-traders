-- Migration 010: Staff Salary Management (Group J)

-- Monthly salary records for all staff types (Salesman, Order Booker, Delivery Man)
CREATE TABLE IF NOT EXISTS `salary_records` (
  `id`                  INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `staff_id`            INT UNSIGNED   NOT NULL,
  -- Polymorphic: users.id OR delivery_men.id
  `staff_type`          ENUM('salesman','order_booker','delivery_man') NOT NULL,
  -- Determines which table staff_id references
  `month`               TINYINT UNSIGNED NOT NULL,  -- 1-12
  `year`                YEAR           NOT NULL,
  `basic_salary`        DECIMAL(10,2)  NOT NULL,
  `total_advances_paid` DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  `cleared_at`          DATETIME       NULL DEFAULT NULL,
  `cleared_by`          INT UNSIGNED   NULL DEFAULT NULL,
  `created_at`          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_staff_month_year` (`staff_id`, `staff_type`, `month`, `year`),
  INDEX `idx_staff_type` (`staff_type`),
  CONSTRAINT `fk_sr_cleared_by` FOREIGN KEY (`cleared_by`) REFERENCES `users` (`id`)
  -- Check staff_type to determine source table for staff_id
  -- total_advances_paid is incremented when salary_advances are added
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Partial advance payments against monthly salary for any staff type
CREATE TABLE IF NOT EXISTS `salary_advances` (
  `id`          INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `staff_id`    INT UNSIGNED   NOT NULL,  -- Polymorphic
  `staff_type`  ENUM('salesman','order_booker','delivery_man') NOT NULL,
  `amount`      DECIMAL(10,2)  NOT NULL,
  `advance_date` DATE          NOT NULL,
  `note`        TEXT           NULL DEFAULT NULL,
  `recorded_by` INT UNSIGNED   NOT NULL,
  `created_at`  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_staff_date` (`staff_id`, `staff_type`, `advance_date`),
  CONSTRAINT `fk_sadv2_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
  -- On INSERT: salary_records.total_advances_paid incremented for matching month/year/staff
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
