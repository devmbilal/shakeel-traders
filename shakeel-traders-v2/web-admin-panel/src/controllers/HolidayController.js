'use strict';

const HolidayModel = require('../models/HolidayModel');
const { renderWithLayout } = require('../utils/render');

const HolidayController = {
  
  // GET /holidays - List all holidays
  async index(req, res) {
    try {
      const year = parseInt(req.query.year) || new Date().getFullYear();
      const holidays = await HolidayModel.listByYear(year);
      
      renderWithLayout(req, res, 'holidays/index', {
        title: 'Manage Holidays',
        holidays,
        selectedYear: year,
      });
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to load holidays.');
      res.redirect('/dashboard');
    }
  },

  // POST /holidays - Create holiday
  async create(req, res) {
    try {
      const { holiday_date, name, description } = req.body;
      
      if (!holiday_date || !name) {
        req.flash('error', 'Date and name are required.');
        return res.redirect('/holidays');
      }

      // Check if holiday already exists for this date
      const exists = await HolidayModel.existsByDate(holiday_date);
      if (exists) {
        req.flash('error', 'A holiday already exists for this date.');
        return res.redirect('/holidays');
      }

      await HolidayModel.create(
        { holiday_date, name, description },
        req.session.user.id
      );

      req.flash('success', `Holiday "${name}" created for ${holiday_date}.`);
      res.redirect('/holidays');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to create holiday: ' + err.message);
      res.redirect('/holidays');
    }
  },

  // POST /holidays/:id/delete - Delete holiday
  async delete(req, res) {
    try {
      const holiday = await HolidayModel.findById(req.params.id);
      if (!holiday) {
        req.flash('error', 'Holiday not found.');
        return res.redirect('/holidays');
      }

      await HolidayModel.delete(req.params.id);
      req.flash('success', `Holiday "${holiday.name}" deleted.`);
      res.redirect('/holidays');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to delete holiday.');
      res.redirect('/holidays');
    }
  },

  // POST /holidays/:id/update - Update holiday
  async update(req, res) {
    try {
      const { name, description } = req.body;
      
      if (!name) {
        req.flash('error', 'Name is required.');
        return res.redirect('/holidays');
      }

      await HolidayModel.update(req.params.id, { name, description });
      req.flash('success', 'Holiday updated.');
      res.redirect('/holidays');
    } catch (err) {
      console.error(err);
      req.flash('error', 'Failed to update holiday.');
      res.redirect('/holidays');
    }
  },
};

module.exports = HolidayController;
