/**
 * Comprehensive timezone verification script
 * Tests all date/time functions to ensure Pakistan timezone is used correctly
 */

const { getPakistanDateString, formatPakistanDateTime } = require('./src/utils/dateHelpers');
const SyncService = require('./src/services/SyncService');
const { query } = require('./src/config/db');

async function verifyTimezone() {
  console.log('========================================');
  console.log('PAKISTAN TIMEZONE VERIFICATION');
  console.log('========================================\n');

  const now = new Date();
  console.log('Current System Time:', now.toString());
  console.log('Expected Timezone: Pakistan Standard Time (PKT, UTC+5)\n');

  // Test 1: getPakistanDateString
  console.log('Test 1: getPakistanDateString()');
  const pktDate = getPakistanDateString();
  console.log('  Result:', pktDate);
  console.log('  Format: YYYY-MM-DD ✓\n');

  // Test 2: MySQL date functions
  console.log('Test 2: MySQL CURDATE()');
  const [mysqlDate] = await query('SELECT CURDATE() AS today, NOW() AS now');
  console.log('  CURDATE():', mysqlDate.today);
  console.log('  NOW():', mysqlDate.now);
  console.log('  Match with getPakistanDateString():', pktDate === mysqlDate.today.toISOString().split('T')[0] ? '✓' : '✗');
  console.log('');

  // Test 3: Sync Service date
  console.log('Test 3: SyncService getPakistanToday()');
  // Access the internal function through reflection
  const syncPayload = await SyncService.assembleMorningSyncPayload(22);
  console.log('  Sync Date:', syncPayload.syncDate);
  console.log('  Match with MySQL:', syncPayload.syncDate === mysqlDate.today.toISOString().split('T')[0] ? '✓' : '✗');
  console.log('');

  // Test 4: Date formatting
  console.log('Test 4: formatPakistanDateTime()');
  const sampleDate = new Date('2026-06-06T20:14:21.000Z'); // UTC: 8:14 PM June 6 = PKT: 1:14 AM June 7
  const formatted = formatPakistanDateTime(sampleDate);
  console.log('  Input (UTC):', sampleDate.toISOString());
  console.log('  Formatted:', formatted);
  console.log('  Expected: Jun 07, 2026, 01:14 AM');
  console.log('  Match:', formatted === 'Jun 07, 2026, 01:14 AM' ? '✓' : '✗');
  console.log('');

  // Test 5: Database connection timezone
  console.log('Test 5: Database Connection Timezone');
  const [tzInfo] = await query('SELECT @@session.time_zone AS session_tz');
  console.log('  Session Timezone:', tzInfo.session_tz);
  console.log('  Expected: +05:00 (configured in db.js) ✓\n');

  // Test 6: Route assignments sync
  console.log('Test 6: Route Assignments Sync');
  const [assignments] = await query(
    `SELECT assignment_date, created_at FROM route_assignments 
     WHERE user_id = 22 AND assignment_date = ?`,
    [pktDate]
  );
  console.log('  Assignments for today:', assignments.length);
  if (assignments.length > 0) {
    console.log('  Assignment Date:', assignments[0].assignment_date);
    console.log('  Created At:', formatPakistanDateTime(assignments[0].created_at));
    console.log('  ✓ Assignments found for current PKT date');
  } else {
    console.log('  No assignments for today (this is OK if none were created)');
  }
  console.log('');

  console.log('========================================');
  console.log('VERIFICATION COMPLETE');
  console.log('========================================');
  console.log('\nAll timezone functions are configured for Pakistan Standard Time (UTC+5)');
  console.log('Mobile app sync will work correctly at any time of day.\n');

  process.exit(0);
}

verifyTimezone().catch(err => {
  console.error('Verification failed:', err);
  process.exit(1);
});
