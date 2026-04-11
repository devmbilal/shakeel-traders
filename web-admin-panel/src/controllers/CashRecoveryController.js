'use strict';

const RecoveryModel = require('../models/RecoveryModel');
const CashModel     = require('../models/CashModel');
const UserModel     = require('../models/UserModel');
const RouteModel    = require('../models/RouteModel');
const ShopModel     = require('../models/ShopModel');
const { renderWithLayout } = require('../utils/render');

const CashRecoveryController = {

  // GET /cash-recovery/outstanding
  async outstanding(req, res) {
    try {
      const filters = { route_id: req.query.route_id || '', shop_id: req.query.shop_id || '' };
      const [bills, bookers, routes, shops] = await Promise.all([
        RecoveryModel.listOutstandingBills(filters),
        UserModel.listByRole('order_booker'),
        RouteModel.listAll(),
        ShopModel.listAll({ is_active: '1' }),
      ]);
      renderWithLayout(req, res, 'cash-recovery/outstanding', {
        title: 'Cash Recovery — Outstanding Bills',
        bills, bookers, routes, shops, filters,
      });
    } catch (err) {
      req.flash('error', 'Failed to load outstanding bills.'); res.redirect('/dashboard');
    }
  },

  // POST /cash-recovery/assign
  async assign(req, res) {
    try {
      const { booker_id, bill_ids } = req.body;
      const ids = [].concat(bill_ids || []).filter(Boolean);
      if (!booker_id || !ids.length) {
        req.flash('error', 'Select an order booker and at least one bill.');
        return res.redirect('/cash-recovery/outstanding');
      }
      await RecoveryModel.assignBills(ids, booker_id, req.session.user.id);
      req.flash('success', `${ids.length} bill(s) assigned for recovery.`);
      res.redirect('/cash-recovery/outstanding');
    } catch (err) {
      req.flash('error', err.message); res.redirect('/cash-recovery/outstanding');
    }
  },

  // GET /cash-recovery/settlement
  async settlement(req, res) {
    try {
      const [bills, deliveryMen] = await Promise.all([
        CashModel.listOpenBills(),
        CashModel.listDeliveryMen(),
      ]);
      renderWithLayout(req, res, 'cash-recovery/settlement', {
        title: 'Bill Settlement — Delivery Man',
        bills, deliveryMen,
      });
    } catch (err) {
      req.flash('error', 'Failed to load settlement page.'); res.redirect('/cash-recovery/outstanding');
    }
  },

  // POST /cash-recovery/settlement
  async recordSettlement(req, res) {
    try {
      const { bill_id, delivery_man_id, amount_collected } = req.body;
      if (!bill_id || !delivery_man_id || !amount_collected) {
        req.flash('error', 'All fields are required.');
        return res.redirect('/cash-recovery/settlement');
      }
      const { newStatus } = await CashModel.recordDeliveryManCollection(
        bill_id, delivery_man_id, amount_collected, req.session.user.id
      );
      req.flash('success', `Payment recorded. Bill status: ${newStatus.replace(/_/g,' ')}.`);
      res.redirect('/cash-recovery/settlement');
    } catch (err) {
      req.flash('error', err.message); res.redirect('/cash-recovery/settlement');
    }
  },

  // GET /cash-recovery/pending
  async pendingVerifications(req, res) {
    try {
      const collections = await RecoveryModel.listPendingVerifications();
      renderWithLayout(req, res, 'cash-recovery/pending', {
        title: 'Pending Recovery Verifications',
        collections,
      });
    } catch (err) {
      req.flash('error', 'Failed to load pending verifications.'); res.redirect('/cash-recovery/outstanding');
    }
  },

  // POST /cash-recovery/verify/:id
  async verify(req, res) {
    try {
      await RecoveryModel.verifyCollection(req.params.id, req.session.user.id);
      req.flash('success', 'Recovery verified. Cash posted to Centralized Cash Screen.');
      res.redirect('/cash-recovery/pending');
    } catch (err) {
      req.flash('error', err.message); res.redirect('/cash-recovery/pending');
    }
  },

  // GET /cash-recovery/history
  async history(req, res) {
    try {
      const filters = {
        date:      req.query.date      || '',
        booker_id: req.query.booker_id || '',
        shop_id:   req.query.shop_id   || '',
      };
      const [collections, bookers] = await Promise.all([
        RecoveryModel.listHistory(filters),
        UserModel.listByRole('order_booker'),
      ]);
      renderWithLayout(req, res, 'cash-recovery/history', {
        title: 'Recovery History',
        collections, bookers, filters,
      });
    } catch (err) {
      req.flash('error', 'Failed to load history.'); res.redirect('/cash-recovery/outstanding');
    }
  },
};

module.exports = CashRecoveryController;
