'use strict';

const express = require('express');
const router = express.Router();
const ShopController = require('../../controllers/ShopController');

router.get('/',         ShopController.index);
router.get('/new',      ShopController.newForm);
router.post('/',        ShopController.create);

router.post('/import',
  (req, res, next) => {
    ShopController.csvUploadMiddleware(req, res, (err) => {
      if (err) {
        req.flash('error', err.message);
        return res.redirect('/shops');
      }
      next();
    });
  },
  ShopController.importCSV
);

router.get('/:id/ledger/export',  ShopController.exportLedger);
router.get('/:id/ledger',         ShopController.ledger);
router.post('/:id/advance',       ShopController.addAdvance);
router.get('/:id',                ShopController.detail);
router.post('/:id',               ShopController.update);

module.exports = router;
