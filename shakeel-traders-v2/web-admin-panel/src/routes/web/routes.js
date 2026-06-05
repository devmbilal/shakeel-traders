'use strict';

const express = require('express');
const router = express.Router();
const RouteController = require('../../controllers/RouteController');

router.get('/',                      RouteController.index);
router.post('/',                     RouteController.create);
router.get('/:id',                   RouteController.detail);
router.post('/:id',                  RouteController.update);
router.post('/:id/deactivate',       RouteController.deactivate);
router.get('/:id/shops/search',      RouteController.searchShops);
router.get('/:id/shops/list',        RouteController.listShops);
router.post('/:id/shops',            RouteController.addShop);
router.delete('/:id/shops/:shopId',  RouteController.deleteShop);
router.post('/:id/shops/remove',     RouteController.removeShop);

module.exports = router;
