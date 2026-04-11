'use strict';

const cron = require('node-cron');

// Midnight cron job — auto-return unrecovered bill recovery assignments
// Full implementation in Phase 9 (task 10.1)
cron.schedule('0 0 * * *', async () => {
  console.log('[CRON] Midnight job triggered at', new Date().toISOString());
  try {
    const CronService = require('../services/CronService');
    await CronService.runMidnightJob();
  } catch (err) {
    console.error('[CRON] Midnight job failed:', err.message);
  }
}, {
  timezone: 'Asia/Karachi',
});

console.log('[CRON] Midnight job scheduled (00:00 Asia/Karachi)');
