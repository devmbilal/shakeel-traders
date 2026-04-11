'use strict';
const express = require('express');
const router = express.Router();
const CashRecoveryController = require('../../controllers/CashRecoveryController');

router.get('/',                    (req, res) => res.redirect('/cash-recovery/outstanding'));
router.get('/outstanding',         CashRecoveryController.outstanding);
router.post('/assign',             CashRecoveryController.assign);
router.get('/settlement',          CashRecoveryController.settlement);
router.post('/settlement',         CashRecoveryController.recordSettlement);
router.get('/pending',             CashRecoveryController.pendingVerifications);
router.post('/verify/:id',         CashRecoveryController.verify);
router.get('/history',             CashRecoveryController.history);

module.exports = router;
