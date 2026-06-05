# Run Migration 017 - Add last_sync_at Column

## Quick Setup

This migration adds the `last_sync_at` column to the `users` table for tracking when order bookers last synced their data.

### Option 1: Using MySQL Command Line

```bash
mysql -u root -p shakeel_traders
```

Then paste this SQL:

```sql
ALTER TABLE `users`
ADD COLUMN `last_sync_at` DATETIME NULL DEFAULT NULL AFTER `is_active`;
EXIT;
```

### Option 2: Using PowerShell (Recommended)

From the project root directory:

```powershell
Get-Content web-admin-panel/src/db/migrations/017_add_last_sync_at.sql | mysql -u root -p shakeel_traders
```

### Option 3: Using MySQL Workbench

1. Open MySQL Workbench
2. Connect to your database
3. Select `shakeel_traders` database
4. Open the SQL file: `web-admin-panel/src/db/migrations/017_add_last_sync_at.sql`
5. Execute the query

## Verify Migration

After running the migration, verify it worked:

```sql
USE shakeel_traders;
DESCRIBE users;
```

You should see `last_sync_at` column in the output.

## Restart Server

After running the migration, restart your Node.js server:

```bash
cd web-admin-panel
npm start
```

Or if using nodemon:

```bash
npm run dev
```

## What This Enables

- Real-time tracking of order booker sync status
- Notifications for unsynced users (24+ hours)
- Better monitoring of field agent activity
- Improved system reliability alerts

---

**Status:** Ready to run
**Required:** Yes (for notifications feature)
**Safe:** Yes (only adds a column, doesn't modify existing data)
