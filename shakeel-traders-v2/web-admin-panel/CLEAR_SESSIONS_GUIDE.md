# Clear Sessions After Database Restore

## Problem
When you restore a database backup, the **sessions table** is also restored with old data. This can cause the system to show outdated information like old payroll entries, even though the database has been restored.

## Root Cause
- Sessions are stored in a MySQL database table named `sessions` (not files)
- When you restore a backup, this table is included and contains old session data
- Your browser still has the old session cookie, so it continues using the stale session

## Solution (Automatic)
**Now fixed automatically!** When you restore a database backup through the web interface (`/backup`), the system will automatically:
1. Restore the database
2. Clear all sessions from the `sessions` table
3. Show message: "Database restored successfully. All sessions cleared."

You will be automatically logged out and need to log in again with fresh data.

## Manual Solution (If Needed)
If you restore the database manually (not through the web interface), run this script:

```bash
cd web-admin-panel
node clear-sessions.js
```

Then restart the server:
```bash
# Stop the server (Ctrl+C)
# Start it again
npm start
```

## What Gets Cleared
- All active user sessions
- Any cached query results stored in sessions
- All users will need to log in again

## When to Use Manual Clear
- After manually restoring a database backup (not through web UI)
- When you notice stale/outdated data showing in the system
- When payroll or other reports show old entries after restore

## Files Modified
- `src/services/BackupService.js` - Added automatic session clearing after restore
- `clear-sessions.js` - Manual script for clearing sessions

## Technical Details
Sessions are configured in:
- **Table:** `sessions` in MySQL database
- **Config:** `src/config/session.js`
- **Middleware:** `express-session` with `express-mysql-session` store
- **Expiration:** 24 hours (86400000 ms)
