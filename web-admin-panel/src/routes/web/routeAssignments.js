'use strict';

const express = require('express');
const router = express.Router();
const RouteAssignmentController = require('../../controllers/RouteAssignmentController');

router.get('/',                RouteAssignmentController.index);
router.post('/',               RouteAssignmentController.create);
router.get('/by-date',         RouteAssignmentController.byDate);
router.get('/by-booker',       RouteAssignmentController.byBooker);
router.get('/:id/edit',        RouteAssignmentController.edit);
router.post('/:id/edit',       RouteAssignmentController.update);
router.post('/:id/delete',     RouteAssignmentController.deleteAssignment);

module.exports = router;
