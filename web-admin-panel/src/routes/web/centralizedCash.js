'use strict';
const express = require('express');
const router = express.Router();
const CentralizedCashController = require('../../controllers/CentralizedCashController');

router.get('/',         CentralizedCashController.daily);
router.get('/monthly',  CentralizedCashController.monthly);
router.get('/data',     CentralizedCashController.data);

module.exports = router;
