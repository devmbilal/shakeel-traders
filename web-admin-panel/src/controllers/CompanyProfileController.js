'use strict';

const path = require('path');
const multer = require('multer');
const CompanyProfileModel = require('../models/CompanyProfileModel');
const { renderWithLayout } = require('../utils/render');

// Multer storage for logo uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../public/uploads/logos'));
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, 'company-logo' + ext);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 }, // 2 MB
  fileFilter: (req, file, cb) => {
    if (/image\/(jpeg|png|gif|webp)/.test(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  },
});

const CompanyProfileController = {
  uploadMiddleware: upload.single('logo'),

  async getForm(req, res) {
    try {
      const profile = await CompanyProfileModel.getProfile();
      renderWithLayout(req, res, 'company-profile/index', {
        title: 'Company Profile',
        profile: profile || {},
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load company profile.');
      res.redirect('/dashboard');
    }
  },

  async saveProfile(req, res) {
    try {
      const data = {
        company_name: req.body.company_name,
        owner_name:   req.body.owner_name,
        address:      req.body.address,
        phone_1:      req.body.phone_1,
        phone_2:      req.body.phone_2,
        email:        req.body.email,
        gst_ntn:      req.body.gst_ntn,
        sales_tax:    req.body.sales_tax,
        cnic:         req.body.cnic,
      };

      if (req.file) {
        data.logo_path = '/uploads/logos/' + req.file.filename;
      }

      await CompanyProfileModel.upsertProfile(data);
      req.flash('success', 'Company profile saved successfully.');
      res.redirect('/company-profile');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to save company profile: ' + err.message);
      res.redirect('/company-profile');
    }
  },
};

module.exports = CompanyProfileController;
