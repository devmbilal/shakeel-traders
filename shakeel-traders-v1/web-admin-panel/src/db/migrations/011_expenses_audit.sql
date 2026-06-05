-- Migration 011: Expenses & Audit Log (Group K)

CREATE TABLE IF NOT EXISTS `expenses` (
  `id`              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `expense_type`    ENUM('fuel','daily_allowance','vehicle_maintenance','office','other') NOT NULL,
  `amount`          DECIMAL(10,2) NOT NULL,
  `expense_date`    DATE          NOT NULL,
  `related_user_id` INT UNSIGNED  NULL DEFAULT NULL,
  `note`            TEXT          NULL DEFAULT NULL,
  `recorded_by`     INT UNSIGNED  NOT NULL,
  `created_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_type_date` (`expense_type`, `expense_date`),
  INDEX `idx_date` (`expense_date`),
  CONSTRAINT `fk_exp_related_user` FOREIGN KEY (`related_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_exp_recorded_by`  FOREIGN KEY (`recorded_by`)     REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Immutable record of every significant action in the system.
-- APPEND ONLY — no updates or deletes permitted.
CREATE TABLE IF NOT EXISTS `audit_log` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  NOT NULL,
  `action`      VARCHAR(100)  NOT NULL,
  -- e.g. APPROVE_ISSUANCE, CONVERT_ORDER_TO_BILL, VERIFY_RECOVERY
  `entity_type` VARCHAR(50)   NOT NULL,
  -- Table being acted upon: salesman_issuances, bills, etc.
  `entity_id`   INT UNSIGNED  NULL DEFAULT NULL,
  `old_value`   JSON          NULL DEFAULT NULL,  -- State before action
  `new_value`   JSON          NULL DEFAULT NULL,  -- State after action
  `ip_address`  VARCHAR(45)   NULL DEFAULT NULL,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_date` (`user_id`, `created_at`),
  INDEX `idx_entity` (`entity_type`, `entity_id`),
  INDEX `idx_action` (`action`),
  CONSTRAINT `fk_al_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
  -- APPEND ONLY — application must never run UPDATE or DELETE on this table
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
