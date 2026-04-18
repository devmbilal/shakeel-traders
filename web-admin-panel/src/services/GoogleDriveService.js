'use strict';

const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

/**
 * Google Drive Backup Upload via Rclone
 *
 * ONE-TIME SETUP (5 minutes):
 * 1. Download Rclone: https://rclone.org/downloads/ → Windows zip → extract rclone.exe
 * 2. Put rclone.exe somewhere (e.g. C:\rclone\rclone.exe) or add to PATH
 * 3. Run in CMD: rclone config
 *    - n (new remote) → name it: gdrive
 *    - Storage: Google Drive (pick the number)
 *    - client_id: leave blank
 *    - client_secret: leave blank
 *    - scope: 1 (full access)
 *    - root_folder_id: leave blank
 *    - service_account_file: leave blank
 *    - Edit advanced config: n
 *    - Use auto config: y  → browser opens → sign in with Gmail → Allow
 *    - Configure as Shared Drive: n
 *    - Done!
 * 4. Create a folder in Google Drive called "Shakeel Traders Backups"
 * 5. Add to .env:
 *    RCLONE_ENABLED=true
 *    RCLONE_REMOTE=gdrive
 *    RCLONE_DRIVE_PATH=Shakeel Traders Backups
 *    RCLONE_EXE=rclone   (or full path like C:\rclone\rclone.exe)
 */

class GoogleDriveService {
  static isEnabled() {
    return process.env.RCLONE_ENABLED === 'true';
  }

  static async uploadBackup(localFilePath, filename) {
    if (!this.isEnabled()) {
      return { success: false, skipped: true, reason: 'Rclone upload not configured' };
    }

    try {
      const rclone    = process.env.RCLONE_EXE || 'rclone';
      const remote    = process.env.RCLONE_REMOTE || 'gdrive';
      const drivePath = process.env.RCLONE_DRIVE_PATH || 'Shakeel Traders Backups';

      // Build year/month subfolder path
      const now         = new Date();
      const year        = String(now.getFullYear());
      const month       = `${year}-${String(now.getMonth() + 1).padStart(2, '0')}`;
      const remotePath  = `${remote}:${drivePath}/${year}/${month}`;

      // Pass config file explicitly so Node.js finds the same config as CMD
      const os = require('os');
      const configPath = process.env.RCLONE_CONFIG ||
        require('path').join(os.homedir(), 'AppData', 'Roaming', 'rclone', 'rclone.conf');

      const cmd = `"${rclone}" --config "${configPath}" copy "${localFilePath}" "${remotePath}"`;
      await execPromise(cmd, { shell: 'cmd.exe' });

      console.log(`[Drive] Uploaded via rclone: ${filename} → ${drivePath}/${year}/${month}/`);
      return {
        success: true,
        fileName: filename,
        folder: `${drivePath}/${year}/${month}`,
      };
    } catch (err) {
      console.error('[Drive] Rclone upload failed:', err.message);
      return { success: false, error: err.message };
    }
  }
}

module.exports = GoogleDriveService;

module.exports = GoogleDriveService;
