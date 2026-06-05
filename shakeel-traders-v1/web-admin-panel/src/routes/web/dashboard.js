'use strict';
const express = require('express');
const router = express.Router();
const DashboardController = require('../../controllers/DashboardController');

router.get('/', DashboardController.index);
router.get('/data', DashboardController.getData);

module.exports = router;
