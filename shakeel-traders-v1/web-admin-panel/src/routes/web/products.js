'use strict';
const express = require('express');
const router = express.Router();
const ProductController = require('../../controllers/ProductController');

router.get('/',                  ProductController.index);
router.get('/new',               ProductController.newForm);
router.post('/',                 ProductController.create);
router.post('/import',
  (req, res, next) => {
    ProductController.csvUploadMiddleware(req, res, (err) => {
      if (err) { req.flash('error', err.message); return res.redirect('/products'); }
      next();
    });
  },
  ProductController.importCSV
);
router.get('/:id/edit',          ProductController.editForm);
router.post('/:id',              ProductController.update);
router.post('/:id/deactivate',   ProductController.deactivate);
router.post('/:id/activate',     ProductController.activate);
router.get('/:id/movements',     ProductController.movements);

module.exports = router;
