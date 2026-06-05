'use strict';

const SupplierModel = require('../models/SupplierModel');
const ProductModel  = require('../models/ProductModel');
const { renderWithLayout } = require('../utils/render');

const SupplierController = {

  async index(req, res) {
    try {
      const suppliers = await SupplierModel.listAll();
      renderWithLayout(req, res, 'suppliers/index', { title: 'Supplier Management', suppliers });
    } catch (err) { req.flash('error', 'Failed to load suppliers.'); res.redirect('/dashboard'); }
  },

  async create(req, res) {
    try {
      await SupplierModel.create(req.body);
      req.flash('success', `Supplier "${req.body.name}" created.`);
      res.redirect('/suppliers');
    } catch (err) {
      req.flash('error', 'Failed to create supplier: ' + err.message); res.redirect('/suppliers');
    }
  },

  async detail(req, res) {
    try {
      const [supplier, ledger, claims, products] = await Promise.all([
        SupplierModel.findById(req.params.id),
        SupplierModel.getLedger(req.params.id),
        SupplierModel.listClaims(req.params.id),
        ProductModel.listAll('active'),
      ]);
      if (!supplier) { req.flash('error', 'Supplier not found.'); return res.redirect('/suppliers'); }
      renderWithLayout(req, res, 'suppliers/detail', { title: supplier.name, supplier, ledger, claims, products });
    } catch (err) { req.flash('error', 'Failed to load supplier.'); res.redirect('/suppliers'); }
  },

  async recordAdvance(req, res) {
    try {
      const { amount, payment_date, payment_method, note } = req.body;
      await SupplierModel.recordAdvance(req.params.id, { amount, payment_date, payment_method, note }, req.session.user.id);
      req.flash('success', 'Advance recorded. Supplier balance updated.');
      res.redirect('/suppliers/' + req.params.id);
    } catch (err) { req.flash('error', err.message); res.redirect('/suppliers/' + req.params.id); }
  },

  async addClaim(req, res) {
    try {
      const { claim_date, reason, claim_value } = req.body;
      const product_ids  = [].concat(req.body.product_id  || []);
      const cartons_arr  = [].concat(req.body.cartons      || []);
      const loose_arr    = [].concat(req.body.loose_units  || []);
      const items = product_ids.map((pid, i) => ({
        product_id: pid, cartons: cartons_arr[i] || 0, loose_units: loose_arr[i] || 0
      })).filter(i => i.product_id);

      await SupplierModel.addClaim(req.params.id, { claim_date, reason, claim_value }, items, req.session.user.id);
      req.flash('success', 'Claim recorded. Products NOT added to warehouse stock.');
      res.redirect('/suppliers/' + req.params.id);
    } catch (err) { req.flash('error', err.message); res.redirect('/suppliers/' + req.params.id); }
  },

  async clearClaim(req, res) {
    try {
      await SupplierModel.markClaimCleared(req.params.claimId, req.session.user.id);
      req.flash('success', 'Claim cleared. Value added back to supplier advance balance.');
      res.redirect('/suppliers/' + req.params.id);
    } catch (err) { req.flash('error', err.message); res.redirect('/suppliers/' + req.params.id); }
  },
};

module.exports = SupplierController;
