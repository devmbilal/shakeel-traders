const { exec } = require('child_process');
const fs = require('fs').promises;
const path = require('path');
const util = require('util');
const execPromise = util.promisify(exec);
const GoogleDriveService = require('./GoogleDriveService');

class BackupService {
  static getBackupDir() {
    return process.env.BACKUP_DIR || path.join(__dirname, '../../backups');
  }

  static async ensureBackupDir() {
    const backupDir = this.getBackupDir();
    try {
      await fs.access(backupDir);
    } catch {
      await fs.mkdir(backupDir, { recursive: true });
    }
    return backupDir;
  }

  /**
   * Update last backup timestamp in database
   */
  static async updateLastBackupTime() {
    try {
      const { query } = require('../config/db');
      const now = new Date();
      await query(
        'UPDATE company_profile SET last_backup_time = ? WHERE id = 1',
        [now]
      );
    } catch (error) {
      console.warn('[Backup] Failed to update last backup time:', error.message);
    }
  }

  /**
   * Get last backup time from database
   */
  static async getLastBackupTime() {
    try {
      const { query } = require('../config/db');
      const rows = await query('SELECT last_backup_time FROM company_profile WHERE id = 1');
      return rows[0]?.last_backup_time || null;
    } catch (error) {
      console.warn('[Backup] Failed to get last backup time:', error.message);
      return null;
    }
  }

  /**
   * Check if backup was missed and should run now
   * Returns true if last backup is older than scheduled time yesterday
   */
  static async shouldRunMissedBackup(scheduledTime) {
    try {
      const lastBackupTime = await this.getLastBackupTime();
      
      if (!lastBackupTime) {
        // No previous backup recorded, don't auto-run
        return false;
      }

      // Parse scheduled time (HH:MM)
      const [hours, minutes] = scheduledTime.split(':').map(Number);
      
      // Get current Pakistan time
      const now = new Date();
      const pktNow = new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Karachi' }));
      
      // Calculate yesterday's scheduled backup time
      const yesterdayScheduled = new Date(pktNow);
      yesterdayScheduled.setDate(yesterdayScheduled.getDate() - 1);
      yesterdayScheduled.setHours(hours, minutes, 0, 0);
      
      // Convert last backup to PKT for comparison
      const lastBackupPKT = new Date(lastBackupTime.toLocaleString('en-US', { timeZone: 'Asia/Karachi' }));
      
      // If last backup is older than yesterday's scheduled time, we missed it
      return lastBackupPKT < yesterdayScheduled;
      
    } catch (error) {
      console.warn('[Backup] Error checking missed backup:', error.message);
      return false;
    }
  }

  static async runBackup() {
    try {
      const backupDir = await this.ensureBackupDir();
      
      // Format timestamp as: YYYY-MM-DD_HH-MM-SS (Pakistan time)
      const now = new Date();
      const pktTime = new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Karachi' }));
      const year = pktTime.getFullYear();
      const month = String(pktTime.getMonth() + 1).padStart(2, '0');
      const day = String(pktTime.getDate()).padStart(2, '0');
      const hours = String(pktTime.getHours()).padStart(2, '0');
      const minutes = String(pktTime.getMinutes()).padStart(2, '0');
      const seconds = String(pktTime.getSeconds()).padStart(2, '0');
      const timestamp = `${year}-${month}-${day}_${hours}-${minutes}-${seconds}`;
      
      const filename = `shakeel_traders_${timestamp}.sql`;
      const filepath = path.join(backupDir, filename);

      const dbHost = process.env.DB_HOST || 'localhost';
      const dbPort = process.env.DB_PORT || '3306';
      const dbUser = process.env.DB_USER || 'root';
      const dbPass = process.env.DB_PASS || '';
      const dbName = process.env.DB_NAME || 'shakeel_traders';

      // Build mysqldump command
      const command = `mysqldump -h ${dbHost} -P ${dbPort} -u ${dbUser} ${dbPass ? `-p${dbPass}` : ''} ${dbName} > "${filepath}"`;

      await execPromise(command);

      // Verify file was created
      const stats = await fs.stat(filepath);

      // Update last backup time in database
      await this.updateLastBackupTime();

      // Upload to Google Drive (non-blocking — failure doesn't break backup)
      let driveResult = { skipped: true };
      try {
        driveResult = await GoogleDriveService.uploadBackup(filepath, filename);
        if (driveResult.success) {
          console.log(`[Backup] Drive upload OK → ${driveResult.folder}/${filename}`);
        } else if (!driveResult.skipped) {
          console.warn(`[Backup] Drive upload failed: ${driveResult.error}`);
        }
      } catch (driveErr) {
        console.warn('[Backup] Drive upload error:', driveErr.message);
      }

      return {
        success: true,
        filename,
        filepath,
        size: stats.size,
        timestamp: new Date(),
        driveUpload: driveResult,
      };
    } catch (error) {
      console.error('Backup failed:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async listBackups() {
    try {
      const backupDir = await this.ensureBackupDir();
      const files = await fs.readdir(backupDir);
      
      const backups = await Promise.all(
        files
          .filter(file => file.endsWith('.sql'))
          .map(async (file) => {
            const filepath = path.join(backupDir, file);
            const stats = await fs.stat(filepath);
            return {
              filename: file,
              filepath,
              size: stats.size,
              created_at: stats.birthtime
            };
          })
      );

      // Sort by creation date, newest first
      backups.sort((a, b) => b.created_at - a.created_at);

      return backups;
    } catch (error) {
      console.error('Error listing backups:', error);
      return [];
    }
  }

  static async restoreBackup(filename) {
    try {
      const backupDir = this.getBackupDir();
      const filepath = path.join(backupDir, filename);

      // Verify file exists
      await fs.access(filepath);

      const dbHost = process.env.DB_HOST || 'localhost';
      const dbPort = process.env.DB_PORT || '3306';
      const dbUser = process.env.DB_USER || 'root';
      const dbPass = process.env.DB_PASS || '';
      const dbName = process.env.DB_NAME || 'shakeel_traders';

      // Build mysql restore command
      const command = `mysql -h ${dbHost} -P ${dbPort} -u ${dbUser} ${dbPass ? `-p${dbPass}` : ''} ${dbName} < "${filepath}"`;

      await execPromise(command);

      return {
        success: true,
        message: 'Database restored successfully'
      };
    } catch (error) {
      console.error('Restore failed:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  static async deleteBackup(filename) {
    try {
      const backupDir = this.getBackupDir();
      const filepath = path.join(backupDir, filename);

      await fs.unlink(filepath);

      return {
        success: true,
        message: 'Backup deleted successfully'
      };
    } catch (error) {
      console.error('Delete backup failed:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  static formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  }
}

module.exports = BackupService;
