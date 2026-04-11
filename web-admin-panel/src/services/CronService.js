'use strict';

const { getConnection } = require('../config/db');
const AuditModel = require('../models/AuditModel');
const fs = require('fs');
const path = require('path');

const CRON_LOG = path.join(__dirname, '../../cron_errors.log');

const CronService = {
  /**
   * runMidnightJob — auto-returns all unrecovered bill recovery assignments
   * from the previous day to the outstanding pool.
   *
   * Business Rule BR-21: Recovery bills must be actioned on the day they are assigned.
   * At midnight, a server-side scheduled job automatically returns all unrecovered bills
   * (where no collection amount was entered) to the outstanding pool.
   *
   * This job is IDEMPOTENT — safe to re-run on already-returned assignments.
   */
  async runMidnightJob() {
    const conn = await getConnection();
    try {
      await conn.beginTransaction();

      const [result] = await conn.query(
        `UPDATE bill_recovery_assignments
         SET status = 'returned_to_pool', returned_at = NOW()
         WHERE assigned_date < CURDATE()
           AND status IN ('assigned', 'partially_recovered')`
      );

      const affectedRows = result.affectedRows;

      // Log to audit_log — use system user id 1 (admin)
      if (affectedRows > 0) {
        await AuditModel.insertLog({
          userId:     1,
          action:     'MIDNIGHT_CRON_RETURN',
          entityType: 'bill_recovery_assignments',
          newValue:   { returned_count: affectedRows, ran_at: new Date().toISOString() },
        }, conn);
      }

      await conn.commit();
      console.log(`[CRON] Midnight job complete. Returned ${affectedRows} assignment(s) to pool.`);
      return affectedRows;
    } catch (err) {
      await conn.rollback();
      const logLine = `[${new Date().toISOString()}] Midnight job error: ${err.message}\n`;
      fs.appendFileSync(CRON_LOG, logLine);
      throw err;
    } finally {
      conn.release();
    }
  },
};

module.exports = CronService;
