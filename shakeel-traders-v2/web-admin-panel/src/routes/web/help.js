'use strict';
const express = require('express');
const router = express.Router();
const HelpController = require('../../controllers/HelpController');

// User guide page (English)
router.get('/user-guide', HelpController.userGuide);

// User guide page (Urdu)
router.get('/user-guide-urdu', HelpController.userGuideUrdu);

module.exports = router;
