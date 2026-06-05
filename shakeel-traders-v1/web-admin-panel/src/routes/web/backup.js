const express = require('express');
const router = express.Router();
const BackupController = require('../../controllers/BackupController');

// Backup management page
router.get('/', BackupController.index);

// Run manual backup
router.post('/run', BackupController.runBackup);

// Download backup
router.get('/download/:filename', BackupController.downloadBackup);

// Restore backup
router.post('/restore', BackupController.restoreBackup);

// Delete backup
router.post('/delete/:filename', BackupController.deleteBackup);

// Save backup settings
router.post('/settings', BackupController.saveSettings);

module.exports = router;
