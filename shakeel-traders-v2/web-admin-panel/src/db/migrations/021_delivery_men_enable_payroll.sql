-- Migration 021: Add enable_payroll to delivery_men table
-- This column controls whether delivery men appear in attendance and payroll

ALTER TABLE `delivery_men` 
ADD COLUMN `enable_payroll` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Include in attendance and payroll (1=yes, 0=no)' 
AFTER `base_salary`;
