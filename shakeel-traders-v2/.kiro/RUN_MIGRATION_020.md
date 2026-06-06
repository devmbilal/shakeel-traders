# Run Migration 020 - Attendance & Holidays System

## ⚠️ IMPORTANT: Run This Migration

This migration adds the **Attendance & Holidays** system to your database.

## What It Adds

1. **Base Salary Fields**
   - Adds `base_salary` column to `users` table
   - Adds `base_salary` column to `delivery_men` table

2. **Holidays Table**
   - System-wide holidays marked by admin
   - Fridays are automatic weekly offs

3. **Attendance Table**
   - Daily attendance tracking
   - Status: present, absent, holiday, off

4. **Payroll Records Table**
   - Monthly payroll with attendance deductions
   - Automatic calculation: Base Salary - (Absent Days × Per Day Salary)

## How to Run

### Option 1: Using MySQL Workbench or phpMyAdmin
1. Open the migration file: `src/db/migrations/020_attendance_holidays.sql`
2. Copy the entire content
3. Paste and execute in your MySQL client
4. Verify all 4 tables/columns were created successfully

### Option 2: Using Command Line
```bash
cd web-admin-panel
mysql -u root -p shakeel_traders < src/db/migrations/020_attendance_holidays.sql
```

### Option 3: Using Node.js Script (if available)
```bash
cd web-admin-panel
node scripts/run-migration.js 020
```

## Verification

After running the migration, verify with these queries:

```sql
-- Check base_salary columns added
DESCRIBE users;
DESCRIBE delivery_men;

-- Check new tables created
SHOW TABLES LIKE 'holidays';
SHOW TABLES LIKE 'attendance';
SHOW TABLES LIKE 'payroll_records';

-- Check table structures
DESCRIBE holidays;
DESCRIBE attendance;
DESCRIBE payroll_records;
```

## Migration File Location
```
src/db/migrations/020_attendance_holidays.sql
```

## ⚠️ Backup First
Before running, ensure you have a recent backup of your database:
```bash
mysqldump -u root -p shakeel_traders > backup_before_migration_020.sql
```

## Next Steps
After successful migration:
1. Set base salaries for existing users
2. Start marking daily attendance
3. Mark system holidays
4. Generate monthly payroll at month end

---

**Created:** [Current Date]  
**Migration Number:** 020  
**Status:** Ready to Run ⚠️
