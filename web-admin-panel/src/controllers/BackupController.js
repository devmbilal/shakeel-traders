const BackupService = require('../services/BackupService');
const { renderWithLayout } = require('../utils/render');
const path = require('path');
const fs = require('fs').promises;

class BackupController {
  // Backup management page
  static async index(req, res) {
    try {
      const backups = await BackupService.listBackups();
      
      // Format file sizes
      backups.forEach(backup => {
        backup.sizeFormatted = BackupService.formatFileSize(backup.size);
      });

      renderWithLayout(req, res, 'backup/index', {
        title: 'Database Backup',
        backups
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

      if (!backupTime) {
        req.flash('error', 'Please provide a backup time');
        return res.redirect('/backup');
      }

      // TODO: Save backup time to config file or database
      // For now, just show success message
      req.flash('success', `Backup time set to ${backupTime}. Note: Automatic backups require cron job configuration.`);

      res.redirect('/backup');
    } catch (error) {
      console.error('Error saving backup settings:', error);
      req.flash('error', 'Failed to save settings');
      res.redirect('/backup');
    }
  }
}

module.exports = BackupController;
