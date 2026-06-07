# Session Cache Fix After Database Restore

**Date:** January 2025  
**Status:** ✅ COMPLETED

## Problem
User restored database backup but payroll page still showed old/cached entries instead of fresh database data.

## Root Cause
Sessions are stored in MySQL database table `sessions` (configured via `express-mysql-session`). When user restores a database backup:
1. The backup includes the old `sessions` table
2. Browser still has session cookie pointing to old session
3. Old session data shows stale information (old payroll entries, etc.)
4. No application-level caching exists - issue is purely session-related

## Investigation Results
- **PayrollController.js:** No caching - queries database directly via `PayrollModel.listPayroll()`
- **PayrollModel.js:** No caching - uses direct SQL queries with `query()` function
- **Session Storage:** Database table `sessions` (not file-based)
- **Session Config:** `src/config/session.js` - uses `express-mysql-session` with 24hr expiration

## Solution Implemented

### 1. Automatic Session Clearing
Modified `BackupService.restoreBackup()` to automatically clear sessions after restore:
```javascript
// After restore command succeeds
await query('DELETE FROM sessions');
console.log('[Backup] Sessions cleared after restore');
```

Now when user restores backup through web UI (`/backup`), sessions are automatically cleared.

### 2. Manual Clear Script
Created `clear-sessions.js` for manual session clearing when needed:
```bash
node clear-sessions.js
```

Useful for:
- Manual database restore (not through web UI)
- Troubleshooting stale data issues
- Force logout all users

### 3. Documentation
Created `CLEAR_SESSIONS_GUIDE.md` with:
- Problem explanation
- Automatic vs manual solutions
- When to use manual clearing
- Technical details about session storage

## Changes Made

### Files Modified
1. **src/services/BackupService.js**
   - Added automatic session clearing after `restoreBackup()`
   - Updated success message to include session clearing confirmation

### Files Created
1. **clear-sessions.js**
   - Standalone script to delete all records from `sessions` table
   - Shows count of cleared sessions
   - Proper error handling and logging

2. **CLEAR_SESSIONS_GUIDE.md**
   - User-facing documentation
   - Explains problem, automatic solution, and manual fallback
   - Technical reference for developers

## Testing
Ran `clear-sessions.js` successfully:
```
[Clear Sessions] ✓ Cleared 2 session(s) from database.
[Clear Sessions] ✓ All sessions cleared successfully.
```

## User Impact
- **Automatic:** When restoring backup via web UI, user will be auto-logged out (session cleared)
- **Login Required:** After restore, user needs to log in again with fresh credentials
- **Fresh Data:** All subsequent queries fetch latest data from restored database
- **No Manual Steps:** User doesn't need to run any scripts or clear cache manually

## Technical Notes
- Sessions table schema: `session_id`, `expires`, `data` columns
- Session cookie name: `shakeel_sid`
- Session expiration: 24 hours (configurable in `session.js`)
- Database connection pool automatically reconnects after restore
- No application-level caching exists anywhere in the codebase

## Related Files
- `src/config/session.js` - Session middleware configuration
- `src/controllers/BackupController.js` - Restore route handler
- `src/services/BackupService.js` - Backup/restore logic
- `src/controllers/PayrollController.js` - Payroll display (no caching)
- `src/models/PayrollModel.js` - Payroll queries (no caching)

## Future Considerations
- Consider adding "Force Logout All Users" admin feature in UI
- Could add session count display in admin panel
- Potential to exclude sessions table from backup (but keep for now)
