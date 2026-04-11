'use strict';
const express = require('express');
const router = express.Router();
const StockController = require('../../controllers/StockController');

router.get('/',                           StockController.overview);
router.get('/manual-add',                 StockController.manualAddForm);
router.post('/manual-add',                StockController.manualAdd);
router.get('/add-from-supplier',          StockController.fromSupplierForm);
router.post('/add-from-supplier',         StockController.fromSupplierSubmit);
router.get('/pending-issuances',          StockController.pendingIssuances);
router.post('/issuances/:id/approve',     StockController.approveIssuance);
router.get('/pending-returns',            StockController.pendingReturns);
router.get('/returns/:id',                StockController.returnDetail);
router.post('/returns/:id/approve',       StockController.approveReturn);
router.get('/requirement-report',         StockController.requirementReport);
router.get('/:productId/movements',       StockController.movements);

module.exports = router;
