'use strict';
const express = require('express');
const router = express.Router();
const DirectSalesController = require('../../controllers/DirectSalesController');

router.get('/new',          DirectSalesController.newForm);
router.post('/',            DirectSalesController.create);
router.get('/',             DirectSalesController.index);
router.get('/:id/print',    DirectSalesController.printBill);

module.exports = router;
