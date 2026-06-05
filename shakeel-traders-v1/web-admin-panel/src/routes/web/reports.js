const express = require('express');
const router = express.Router();
const ReportController = require('../../controllers/ReportController');

// Reports index
router.get('/', ReportController.index);

// Individual report routes
router.get('/daily-sales', ReportController.dailySalesReport);
router.get('/monthly-sales', ReportController.monthlySalesReport);
router.get('/order-booker-performance', ReportController.orderBookerPerformance);
router.get('/salesman-performance', ReportController.salesmanPerformance);
router.get('/stock-movement', ReportController.stockMovement);
router.get('/stock-requirement', ReportController.stockRequirement);
router.get('/shop-ledger', ReportController.shopLedger);
router.get('/cash-recovery', ReportController.cashRecovery);
router.get('/supplier-advance', ReportController.supplierAdvance);
router.get('/staff-salary', ReportController.staffSalary);
router.get('/claims', ReportController.claims);
router.get('/cash-flow', ReportController.cashFlow);

module.exports = router;
