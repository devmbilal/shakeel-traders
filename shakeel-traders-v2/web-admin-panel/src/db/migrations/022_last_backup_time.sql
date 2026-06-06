-- Migration 022: Add last_backup_time column to company_profile
-- Purpose: Track last successful backup to detect missed backups on startup

ALTER TABLE company_profile 
ADD COLUMN last_backup_time DATETIME NULL 
COMMENT 'Timestamp of last successful backup';
