-- Migration 018: Add backup_time column to company_profile
-- Stores the daily auto-backup time as HH:MM (24-hour format), e.g. '23:00'
ALTER TABLE company_profile
  ADD COLUMN backup_time VARCHAR(5) NOT NULL DEFAULT '23:00' AFTER logo_path;
