'use strict';

const express = require('express');
const router = express.Router();
const AttendanceController = require('../../controllers/AttendanceController');

router.get('/', AttendanceController.index);
router.post('/mark', AttendanceController.markAttendance);
router.get('/report', AttendanceController.report);
router.get('/staff/:id/:type', AttendanceController.staffAttendance);

module.exports = router;
