-- Add missing enable_payroll column

-- Check if column exists, if not add it
ALTER TABLE `users` 
ADD COLUMN IF NOT EXISTS `enable_payroll` TINYINT(1) NOT NULL DEFAULT 1 
COMMENT '1=Include in attendance/payroll, 0=Exclude (system users)';

-- Set admin users to be excluded by default
UPDATE `users` SET `enable_payroll` = 0 WHERE `role` = 'admin';

-- Verify the column was added
SELECT 'Column added successfully' AS status;
