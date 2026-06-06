'use strict';

const express = require('express');
const router = express.Router();
const HolidayController = require('../../controllers/HolidayController');

router.get('/', HolidayController.index);
router.post('/', HolidayController.create);
router.post('/:id/delete', HolidayController.delete);
router.post('/:id/update', HolidayController.update);

module.exports = router;
