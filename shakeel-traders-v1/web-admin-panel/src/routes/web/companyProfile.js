'use strict';

const express = require('express');
const router = express.Router();
const CompanyProfileController = require('../../controllers/CompanyProfileController');

router.get('/', CompanyProfileController.getForm);

router.post(
  '/',
  (req, res, next) => {
    CompanyProfileController.uploadMiddleware(req, res, (err) => {
      if (err) {
        req.flash('error', err.message);
        return res.redirect('/company-profile');
      }
      next();
    });
  },
  CompanyProfileController.saveProfile
);

module.exports = router;
