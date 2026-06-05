-- Add sales_tax and cnic fields to company_profile for SalesFlo format bills
ALTER TABLE `company_profile`
ADD COLUMN `sales_tax` VARCHAR(50) NULL DEFAULT NULL AFTER `gst_ntn`,
ADD COLUMN `cnic` VARCHAR(20) NULL DEFAULT NULL AFTER `sales_tax`;
