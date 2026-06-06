# Backup System Improvements

## Changes Made

### 1. Missed Backup Detection
**Problem**: If computer shuts down before scheduled backup time (e.g., shutdown at 3:50 PM when backup is at 4:00 PM), backup is missed.

**Solution**: System now checks on startup if a backup was missed and automatically runs it within 5 seconds.

**How it works**:
- Every successful backup records timestamp in `company_profile.last_backup_time`
- On startup, system checks if last backup is older than yesterday's scheduled time
- If missed, backup runs automatically

### 2. Improved Filename with Date + Time
**Before**: `shakeel_traders_2024-01-15T10-30-45.sql` (UTC time, unclear format)

**After**: `shakeel_traders_2024-01-15_16-30-45.sql` (Pakistan time, clear date_time format)

**Format**: `shakeel_traders_YYYY-MM-DD_HH-MM-SS.sql`
- Date: YYYY-MM-DD (e.g., 2024-01-15)
- Time: HH-MM-SS in 24-hour format (e.g., 16-30-45 = 4:30:45 PM)
- Always uses Pakistan timezone (Asia/Karachi)

## Database Migration Required

**Run Migration 022**:
```bash
# Option 1: Run from browser
# Go to: http://localhost:3000/migrate
# Click "Run Pending Migrations"

# Option 2: Run from command line
cd web-admin-panel
node src/db/migrate.js
```

This adds the `last_backup_time` column to track backup history.

## Example Scenarios

### Scenario 1: Missed Backup
- **Backup scheduled**: 4:00 PM daily
- **Last backup**: January 15, 4:00 PM
- **Computer shutdown**: January 16, 3:50 PM (before backup runs)
- **Computer starts**: January 17, 10:00 AM
- **Result**: System detects missed backup from January 16 and runs it automatically within 5 seconds

### Scenario 2: Regular Operation
- **Backup scheduled**: 4:00 PM daily
- **Computer on**: System running at 4:00 PM
- **Result**: Backup runs as scheduled
- **Filename**: `shakeel_traders_2024-01-17_16-00-00.sql`

### Scenario 3: Manual Backup
- **Action**: User clicks "Run Backup Now" button
- **Result**: Immediate backup with current Pakistan date/time
- **Filename**: `shakeel_traders_2024-01-17_10-30-15.sql`

## Console Logs

You'll see these messages:

**On Startup (No Missed Backup)**:
```
[CRON] Auto-backup scheduled at 16:00 Asia/Karachi (0 16 * * *)
```

**On Startup (Missed Backup Detected)**:
```
[CRON] Auto-backup scheduled at 16:00 Asia/Karachi (0 16 * * *)
[CRON] Detected missed backup — running now...
[CRON] Auto-backup triggered at 2024-01-17T10:00:05.000Z
[CRON] Auto-backup complete: shakeel_traders_2024-01-17_10-00-05.sql
```

**Scheduled Backup**:
```
[CRON] Auto-backup triggered at 2024-01-17T16:00:00.000Z
[CRON] Auto-backup complete: shakeel_traders_2024-01-17_16-00-00.sql
[CRON] Uploaded to Google Drive: Shakeel Traders Backups/shakeel_traders_2024-01-17_16-00-00.sql
```

## Important Notes

1. **First Run**: After migration, `last_backup_time` will be NULL. System will NOT auto-run backup on first startup.

2. **Computer Must Start**: Missed backup detection only works when you start the computer and the Node.js server starts. If computer is never turned on, backups won't run.

3. **Timezone**: All timestamps are in Pakistan time (Asia/Karachi, UTC+5).

4. **Google Drive**: Backup files are also uploaded to Google Drive if configured.

5. **File Naming**: Old backup files with ISO format will remain. Only new backups use the improved naming.

## Testing

To test the missed backup feature:

1. Set backup time to a few minutes in the future (e.g., if it's 2:00 PM, set to 2:05 PM)
2. Wait for backup to run at 2:05 PM
3. Change backup time to 2:10 PM
4. Shut down computer before 2:10 PM
5. Start computer after 2:10 PM
6. Check console - should see "Detected missed backup — running now..."

## Files Modified

1. `src/services/BackupService.js` - Added missed backup detection logic and improved timestamp
2. `src/config/cron.js` - Added startup check for missed backups
3. `src/db/migrations/022_last_backup_time.sql` - New migration to add tracking column

## Backup Location

Default: `web-admin-panel/backups/`

All backup files are saved here with the new naming format.
