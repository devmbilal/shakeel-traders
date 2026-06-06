-- Migration 020: Attendance & Holidays System
-- Adds attendance tracking, holiday management, and payroll deductions

-- Add base_salary field to users table
ALTER TABLE `users` 
ADD COLUMN `base_salary` DECIMAL(10,2) NULL DEFAULT NULL COMMENT 'Monthly base salary for payroll calculation';

-- Add enable_payroll field to users table to control who appears in attendance/payroll
ALTER TABLE `users`
ADD COLUMN `enable_payroll` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=Include in attendance/payroll, 0=Exclude (e.g., admin/system users)';

-- Set admin users to NOT appear in payroll by default
UPDATE `users` SET `enable_payroll` = 0 WHERE `role` = 'admin';

ALTER TABLE `delivery_men` 
ADD COLUMN `base_salary` DECIMAL(10,2) NULL DEFAULT NULL COMMENT 'Monthly base salary for payroll calculation';

-- Holidays table (system-wide holidays marked by admin)
CREATE TABLE IF NOT EXISTS `holidays` (
  `id`            INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `holiday_date`  DATE           NOT NULL,
  `name`          VARCHAR(100)   NOT NULL,
  `description`   TEXT           NULL DEFAULT NULL,
  `created_by`    INT UNSIGNED   NOT NULL,
  `created_at`    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_holiday_date` (`holiday_date`),
  INDEX `idx_holiday_date` (`holiday_date`),
  CONSTRAINT `fk_holidays_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='System-wide holidays. Admin marks these dates as non-working days.';

-- Attendance records table
CREATE TABLE IF NOT EXISTS `attendance` (
  `id`              INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `staff_id`        INT UNSIGNED   NOT NULL,
  `staff_type`      ENUM('admin','order_booker','salesman','delivery_man') NOT NULL,
  `attendance_date` DATE           NOT NULL,
  `status`          ENUM('present','absent','holiday','off') NOT NULL DEFAULT 'present',
  `marked_by`       INT UNSIGNED   NULL DEFAULT NULL,
  `note`            VARCHAR(255)   NULL DEFAULT NULL,
  `created_at`      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_staff_date` (`staff_id`, `staff_type`, `attendance_date`),
  INDEX `idx_attendance_date` (`attendance_date`),
  INDEX `idx_staff_type_date` (`staff_type`, `attendance_date`),
  INDEX `idx_status` (`status`),
  CONSTRAINT `fk_attendance_marked_by` FOREIGN KEY (`marked_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Daily attendance records. Status: present, absent, holiday, off (Fridays default)';

-- Payroll records with attendance deductions
CREATE TABLE IF NOT EXISTS `payroll_records` (
  `id`                      INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `staff_id`                INT UNSIGNED   NOT NULL,
  `staff_type`              ENUM('admin','order_booker','salesman','delivery_man') NOT NULL,
  `month`                   TINYINT UNSIGNED NOT NULL COMMENT '1-12',
  `year`                    YEAR           NOT NULL,
  `base_salary`             DECIMAL(10,2)  NOT NULL,
  `working_days`            TINYINT UNSIGNED NOT NULL COMMENT 'Total working days in month (excluding Fridays and holidays)',
  `present_days`            TINYINT UNSIGNED NOT NULL COMMENT 'Days marked present',
  `absent_days`             TINYINT UNSIGNED NOT NULL COMMENT 'Days marked absent',
  `holiday_days`            TINYINT UNSIGNED NOT NULL COMMENT 'Public holidays in month',
  `off_days`                TINYINT UNSIGNED NOT NULL COMMENT 'Weekly offs (Fridays)',
  `per_day_salary`          DECIMAL(10,2)  NOT NULL COMMENT 'base_salary / working_days',
  `absence_deduction`       DECIMAL(10,2)  NOT NULL DEFAULT 0.00 COMMENT 'absent_days * per_day_salary',
  `net_salary`              DECIMAL(10,2)  NOT NULL COMMENT 'base_salary - absence_deduction',
  `advances_paid`           DECIMAL(10,2)  NOT NULL DEFAULT 0.00 COMMENT 'Total advances during month',
  `final_payable`           DECIMAL(10,2)  NOT NULL COMMENT 'net_salary - advances_paid',
  `payment_status`          ENUM('pending','paid') NOT NULL DEFAULT 'pending',
  `paid_at`                 DATETIME       NULL DEFAULT NULL,
  `paid_by`                 INT UNSIGNED   NULL DEFAULT NULL,
  `payment_method`          ENUM('cash','bank_transfer') NULL DEFAULT NULL,
  `payment_note`            TEXT           NULL DEFAULT NULL,
  `generated_at`            DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `generated_by`            INT UNSIGNED   NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_staff_month_year` (`staff_id`, `staff_type`, `month`, `year`),
  INDEX `idx_month_year` (`month`, `year`),
  INDEX `idx_payment_status` (`payment_status`),
  CONSTRAINT `fk_payroll_generated_by` FOREIGN KEY (`generated_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_payroll_paid_by` FOREIGN KEY (`paid_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Monthly payroll with attendance-based deductions. Generated at month end.';
