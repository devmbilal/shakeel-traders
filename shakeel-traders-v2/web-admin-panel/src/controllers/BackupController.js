const BackupService = require('../services/BackupService');
const { renderWithLayout } = require('../utils/render');
const path = require('path');
const fs = require('fs').promises;

class BackupController {
  // Backup management page
  static async index(req, res) {
    try {
      const { query } = require('../config/db');
      const backups = await BackupService.listBackups();

      // Format file sizes
      backups.forEach(backup => {
        backup.sizeFormatted = BackupService.formatFileSize(backup.size);
      });

      // Load saved backup time
      const [profileRows] = await query('SELECT backup_time FROM company_profile WHERE id = 1').then(r => [r]);
      const backupTime = (profileRows && profileRows[0]?.backup_time) || '23:00';

      renderWithLayout(req, res, 'backup/index', {
        title: 'Database Backup',
        backups,
        backupTime,
      });
    } catch (error) {
      console.error('Error loading backup page:', error);
      req.flash('error', 'Failed to load backup page');
      res.redirect('/dashboard');
    }
  }

  // Run manual backup
  static async runBackup(req, res) {
    try {
      const result = await BackupService.runBackup();

      if (result.success) {
        let msg = `Backup created: ${result.filename}`;
        if (result.driveUpload?.success) {
          msg += ` — uploaded to Google Drive (${result.driveUpload.folder})`;
        } else if (result.driveUpload?.error) {
          msg += ` — Drive upload failed: ${result.driveUpload.error}`;
        }
        req.flash('success', msg);
      } else {
        req.flash('error', `Backup failed: ${result.error}`);
      }

      res.redirect('/backup');
    } catch (error) {
      console.error('Error running backup:', error);
      req.flash('error', 'Failed to create backup');
      res.redirect('/backup');
    }
  }

  // Download backup file
  static async downloadBackup(req, res) {
    try {
      const { filename } = req.params;
      
      // Security: prevent directory traversal
      if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
        req.flash('error', 'Invalid filename');
        return res.redirect('/backup');
      }

      const backupDir = BackupService.getBackupDir();
      const filepath = path.join(backupDir, filename);

      // Verify file exists
      await fs.access(filepath);

      res.download(filepath, filename, (err) => {
        if (err) {
          console.error('Error downloading backup:', err);
          req.flash('error', 'Failed to download backup');
          res.redirect('/backup');
        }
      });
    } catch (error) {
      console.error('Error downloading backup:', error);
      req.flash('error', 'Backup file not found');
      res.redirect('/backup');
    }
  }

  // Restore from backup
  static async restoreBackup(req, res) {
    try {
      const { filename } = req.body;

      if (!filename) {
        req.flash('error', 'Please select a backup file');
        return res.redirect('/backup');
      }

      // Security: prevent directory traversal
      if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
        req.flash('error', 'Invalid filename');
        return res.redirect('/backup');
      }

      const result = await BackupService.restoreBackup(filename);

      if (result.success) {
        req.flash('success', 'Database restored successfully');
      } else {
        req.flash('error', `Restore failed: ${result.error}`);
      }

      res.redirect('/backup');
    } catch (error) {
      console.error('Error restoring backup:', error);
      req.flash('error', 'Failed to restore backup');
      res.redirect('/backup');
    }
  }

  // Delete backup
  static async deleteBackup(req, res) {
    try {
      const { filename } = req.params;

      // Security: prevent directory traversal
      if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
        req.flash('error', 'Invalid filename');
        return res.redirect('/backup');
      }

      const result = await BackupService.deleteBackup(filename);

      if (result.success) {
        req.flash('success', 'Backup deleted successfully');
      } else {
        req.flash('error', `Delete failed: ${result.error}`);
      }

      res.redirect('/backup');
    } catch (error) {
      console.error('Error deleting backup:', error);
      req.flash('error', 'Failed to delete backup');
      res.redirect('/backup');
    }
  }

  // Save backup settings (cron time)
  static async saveSettings(req, res) {
    try {
      const { backupTime } = req.body;

      if (!backupTime || !/^\d{2}:\d{2}$/.test(backupTime)) {
        req.flash('error', 'Invalid backup time format. Use HH:MM (e.g. 23:00).');
        return res.redirect('/backup');
      }

      const { query } = require('../config/db');
      await query(
        'UPDATE company_profile SET backup_time = ? WHERE id = 1',
        [backupTime]
      );

      // Reschedule the cron job with the new time
      const CronScheduler = require('../config/cron');
      CronScheduler.reschedule(backupTime);

      req.flash('success', `Auto-backup time updated to ${backupTime}.`);
      res.redirect('/backup');
    } catch (error) {
      console.error('Error saving backup settings:', error);
      req.flash('error', 'Failed to save settings: ' + error.message);
      res.redirect('/backup');
    }
  }
}

module.exports = BackupController;
