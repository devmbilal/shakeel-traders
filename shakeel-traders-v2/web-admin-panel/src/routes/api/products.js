'use strict';
const express = require('express');
const router = express.Router();
const ProductController = require('../../controllers/ProductController');

// GET /api/products/active - Get all active products
router.get('/active', ProductController.getActiveProducts);

module.exports = router;
