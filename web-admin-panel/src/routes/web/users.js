'use strict';

const express = require('express');
const router = express.Router();
const UserController = require('../../controllers/UserController');

router.get('/',                    UserController.index);
router.get('/new',                 UserController.newForm);
router.post('/',                   UserController.create);
router.get('/:id/edit',            UserController.editForm);
router.post('/:id',                UserController.update);
router.post('/:id/deactivate',     UserController.deactivate);

module.exports = router;
