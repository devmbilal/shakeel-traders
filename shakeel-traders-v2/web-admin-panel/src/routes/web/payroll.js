'use strict';

const express = require('express');
const router = express.Router();
const PayrollController = require('../../controllers/PayrollController');
const SalaryController = require('../../controllers/SalaryController');

router.get('/', PayrollController.index);
router.post('/generate', PayrollController.generate);
router.get('/:id', PayrollController.view);
router.post('/:id/pay', PayrollController.markPaid);

// Salary advance routes (integrated from old /salaries routes)
router.post('/advance', SalaryController.recordAdvance);
router.get('/ledger/:staffType/:staffId', SalaryController.ledger);
router.get('/ledger/:staffType/:staffId/export', SalaryController.exportLedger);

module.exports = router;
