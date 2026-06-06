'use strict';
const express = require('express');
const router = express.Router();

// OLD SALARY SYSTEM - Redirecting to new HR & Payroll system
// All routes now redirect to /payroll

router.get('/', (req, res) => {
  const tab = req.query.tab || 'salesmen';
  // Map old tabs to new advances tab
  res.redirect(`/payroll?tab=advances&staff_tab=${tab}`);
});

router.get('/:staffType/:staffId/ledger', (req, res) => {
  const { staffType, staffId } = req.params;
  res.redirect(`/payroll/ledger/${staffType}/${staffId}${req.query.page ? '?page=' + req.query.page : ''}`);
});

router.get('/:staffType/:staffId/ledger/export', (req, res) => {
  const { staffType, staffId } = req.params;
  res.redirect(`/payroll/ledger/${staffType}/${staffId}/export`);
});

// All POST requests redirect to /payroll routes
router.post('/advance', (req, res) => {
  req.flash('info', 'Please use the new HR & Payroll system.');
  res.redirect('/payroll?tab=advances');
});

router.post('/record', (req, res) => {
  req.flash('info', 'Please use the new HR & Payroll system.');
  res.redirect('/payroll?tab=advances');
});

router.post('/clearance', (req, res) => {
  req.flash('info', 'Clearance is now handled automatically by payroll generation.');
  res.redirect('/payroll');
});

router.post('/delivery-men', (req, res) => {
  req.flash('info', 'Please add delivery men from Users page.');
  res.redirect('/users');
});

router.post('/delivery-men/:id/deactivate', (req, res) => {
  req.flash('info', 'Please deactivate delivery men from Users page.');
  res.redirect('/users');
});

module.exports = router;
