'use strict';

const express = require('express');
const router = express.Router();
const ExpenseController = require('../../controllers/ExpenseController');

router.get('/', ExpenseController.index);
router.post('/', ExpenseController.create);

module.exports = router;
