-- Migration 008: Cash Recovery (Group H)
-- DESIGN NOTE: Cash recovery assignment is COMPLETELY DECOUPLED from route assignment.
-- bill_recovery_assignments has NO dependency on route_assignments.

CREATE TABLE IF NOT EXISTS `bill_recovery_assignments` (
  `id`                    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `bill_id`               INT UNSIGNED  NOT NULL,
  `assigned_to_booker_id` INT UNSIGNED  NOT NULL,
  -- INDEPENDENT of route_assignments. Any booker can be assigned.
  `assigned_date`         DATE          NOT NULL,
  `assigned_by`           INT UNSIGNED  NOT NULL,
  `status`                ENUM(
                            'assigned',
                            'partially_recovered',
                            'fully_recovered',
                            'returned_to_pool'
                          ) NOT NULL DEFAULT 'assigned',
  `assigned_at`           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `returned_at`           DATETIME      NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_bill` (`bill_id`),
  INDEX `idx_booker_date` (`assigned_to_booker_id`, `assigned_date`),
  INDEX `idx_status` (`status`),
  INDEX `idx_assigned_date` (`assigned_date`),
  CONSTRAINT `fk_bra_bill`    FOREIGN KEY (`bill_id`)               REFERENCES `bills` (`id`),
  CONSTRAINT `fk_bra_booker`  FOREIGN KEY (`assigned_to_booker_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_bra_assigner` FOREIGN KEY (`assigned_by`)          REFERENCES `users` (`id`)
  -- MIDNIGHT CRON JOB: At 00:00 daily, all assignments from the previous day
  -- still in status 'assigned' or 'partially_recovered' are:
  --   SET status = 'returned_to_pool', returned_at = NOW()
  -- A bill can only have ONE active assignment at a time (status != 'returned_to_pool')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recovery_collections` (
  `id`                     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `assignment_id`          INT UNSIGNED  NOT NULL,
  `bill_id`                INT UNSIGNED  NOT NULL,  -- denormalized for query convenience
  `collected_by_booker_id` INT UNSIGNED  NOT NULL,
  `amount_collected`       DECIMAL(12,2) NOT NULL,
  `payment_method`         ENUM('cash','bank_transfer') NOT NULL,
  `collected_at_device`    DATETIME      NOT NULL,  -- Device timestamp (offline)
  `synced_at`              DATETIME      NULL DEFAULT NULL,
  `verified_by_admin_id`   INT UNSIGNED  NULL DEFAULT NULL,
  `verified_at`            DATETIME      NULL DEFAULT NULL,
  `created_at`             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_assignment` (`assignment_id`),
  INDEX `idx_bill` (`bill_id`),
  INDEX `idx_verified` (`verified_by_admin_id`),
  CONSTRAINT `fk_rc_assignment` FOREIGN KEY (`assignment_id`)        REFERENCES `bill_recovery_assignments` (`id`),
  CONSTRAINT `fk_rc_bill`       FOREIGN KEY (`bill_id`)              REFERENCES `bills` (`id`),
  CONSTRAINT `fk_rc_booker`     FOREIGN KEY (`collected_by_booker_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rc_verifier`   FOREIGN KEY (`verified_by_admin_id`) REFERENCES `users` (`id`)
  -- On admin verification:
  --   bills.amount_paid += amount_collected
  --   bills.outstanding_amount -= amount_collected
  --   bills.status updated (partially_paid or cleared)
  --   shop_ledger_entries row inserted (entry_type = 'recovery')
  --   centralized_cash_entries row inserted (entry_type = 'recovery')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
