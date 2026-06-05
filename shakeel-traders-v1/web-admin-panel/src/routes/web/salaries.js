'use strict';
const express = require('express');
const router = express.Router();
const SalaryController = require('../../controllers/SalaryController');

router.get('/',                                          SalaryController.index);
router.post('/record',                                   SalaryController.recordSalary);
router.post('/advance',                                  SalaryController.recordAdvance);
router.post('/clearance',                                SalaryController.clearance);
router.post('/delivery-men',                             SalaryController.addDeliveryMan);
router.post('/delivery-men/:id/deactivate',              SalaryController.deactivateDeliveryMan);
router.get('/:staffType/:staffId/ledger',                SalaryController.ledger);
router.get('/:staffType/:staffId/ledger/export',         SalaryController.exportLedger);

module.exports = router;
