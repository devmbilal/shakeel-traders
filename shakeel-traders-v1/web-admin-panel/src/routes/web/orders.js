'use strict';
const express = require('express');
const router = express.Router();
const OrderController = require('../../controllers/OrderController');

router.get('/',                         OrderController.pendingOrders);
router.get('/converted',                OrderController.convertedBills);
router.get('/consolidated',             OrderController.consolidated);
router.post('/:id/convert',             OrderController.convertToBill);
router.get('/bills/:id/print',          OrderController.printBill);
router.post('/bulk-convert',            OrderController.bulkConvert);
router.post('/bulk-delete',             OrderController.bulkDelete);
router.get('/consolidated-selected',    OrderController.consolidatedSelected);
router.get('/consolidated-pdf',         OrderController.consolidatedPdf);
router.get('/bills/print-open',         OrderController.printOpenBillsSelect);
router.post('/bills/print-open',        OrderController.printOpenBills);

module.exports = router;
