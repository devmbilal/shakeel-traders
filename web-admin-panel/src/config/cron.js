'use strict';

const cron = require('node-cron');

let _task = null;

async function _runBackup() {
  console.log('[CRON] Auto-backup triggered at', new Date().toISOString());
  try {
    const BackupService = require('../services/BackupService');
    const result = await BackupService.runBackup();
    if (result.success) {
      console.log(`[CRON] Auto-backup complete: ${result.filename}`);
      if (result.driveUpload?.success) {
        console.log(`[CRON] Uploaded to Google Drive: ${result.driveUpload.folder}/${result.filename}`);
      } else if (result.driveUpload?.error) {
        console.warn(`[CRON] Drive upload failed: ${result.driveUpload.error}`);
      }
    } else {
      console.error('[CRON] Auto-backup failed:', result.error);
    }
  } catch (err) {
    console.error('[CRON] Auto-backup error:', err.message);
  }
}

/**
 * Convert HH:MM time string to a cron expression (runs daily at that time).
 * e.g. '23:00' → '0 23 * * *'
 */
function timeToCron(timeStr) {
  const [hours, minutes] = (timeStr || '23:00').split(':').map(Number);
  return `${minutes} ${hours} * * *`;
}

/**
 * Schedule (or reschedule) the backup cron with a new HH:MM time.
 * Called on startup and whenever admin saves new backup time.
 */
function reschedule(timeStr) {
  // Stop existing task if running
  if (_task) {
    _task.stop();
    _task = null;
  }

  const expression = timeToCron(timeStr);
  _task = cron.schedule(expression, _runBackup, { timezone: 'Asia/Karachi' });
  console.log(`[CRON] Auto-backup scheduled at ${timeStr} Asia/Karachi (${expression})`);
}

// ── Startup: load saved time from DB and schedule ────────────────────────────
(async () => {
  try {
    const { query } = require('../config/db');
    const rows = await query('SELECT backup_time FROM company_profile WHERE id = 1');
    const savedTime = rows[0]?.backup_time || '23:00';
    reschedule(savedTime);
  } catch (err) {
    // DB might not be ready yet on first run — fall back to default
    console.warn('[CRON] Could not load backup time from DB, using default 23:00:', err.message);
    reschedule('23:00');
  }
})();

module.exports = { reschedule };
