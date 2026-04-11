const { exec } = require('child_process');
const fs = require('fs').promises;
const path = require('path');
const util = require('util');
const execPromise = util.promisify(exec);

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

  static async runBackup() {
    try {
      const backupDir = await this.ensureBackupDir();
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-').split('T').join('_').slice(0, -5);
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
      
      return {
        success: true,
        filename,
        filepath,
        size: stats.size,
        timestamp: new Date()
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
