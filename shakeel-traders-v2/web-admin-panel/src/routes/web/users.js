'use strict';

const express = require('express');
const router = express.Router();
const UserController = require('../../controllers/UserController');

router.get('/',                              UserController.index);
router.get('/new',                           UserController.newForm);
router.post('/',                             UserController.create);
router.get('/:id/edit',                      UserController.editForm);
router.post('/:id',                          UserController.update);
router.post('/:id/deactivate',               UserController.deactivate);
router.post('/:id/activate',                 UserController.activate);

// Delivery Men routes
router.get('/delivery-men/new',              UserController.newDeliveryManForm);
router.post('/delivery-men',                 UserController.createDeliveryMan);
router.get('/delivery-men/:id/edit',         UserController.editDeliveryManForm);
router.post('/delivery-men/:id',             UserController.updateDeliveryMan);
router.post('/delivery-men/:id/deactivate',  UserController.deactivateDeliveryMan);
router.post('/delivery-men/:id/activate',    UserController.activateDeliveryMan);

module.exports = router;
