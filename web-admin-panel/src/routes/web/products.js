'use strict';
const express = require('express');
const router = express.Router();
const ProductController = require('../../controllers/ProductController');

router.get('/',                  ProductController.index);
router.get('/new',               ProductController.newForm);
router.post('/',                 ProductController.create);
router.get('/:id/edit',          ProductController.editForm);
router.post('/:id',              ProductController.update);
router.post('/:id/deactivate',   ProductController.deactivate);
router.post('/:id/activate',     ProductController.activate);
router.get('/:id/movements',     ProductController.movements);

module.exports = router;
