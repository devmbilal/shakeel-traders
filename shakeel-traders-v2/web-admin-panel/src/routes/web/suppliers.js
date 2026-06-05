'use strict';
const express = require('express');
const router = express.Router();
const SupplierController = require('../../controllers/SupplierController');

router.get('/',                              SupplierController.index);
router.post('/',                             SupplierController.create);
router.get('/:id',                           SupplierController.detail);
router.post('/:id/advance',                  SupplierController.recordAdvance);
router.post('/:id/claims',                   SupplierController.addClaim);
router.post('/:id/claims/:claimId/clear',    SupplierController.clearClaim);

module.exports = router;
