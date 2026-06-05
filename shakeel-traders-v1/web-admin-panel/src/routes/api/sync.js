'use strict';
const express = require('express');
const router = express.Router();
const jwtAuth = require('../../middleware/jwtAuth');
const SyncService = require('../../services/SyncService');

// All sync routes require JWT
router.use(jwtAuth);

// ─── Order Booker: Morning Sync ───────────────────────────────────────────────
// GET /api/sync/morning
router.get('/morning', async (req, res) => {
  try {
    if (req.mobileUser.role !== 'order_booker') {
      return res.status(403).json({ error: 'Order booker access only' });
    }
    const payload = await SyncService.assembleMorningSyncPayload(req.mobileUser.id);
    res.json(payload);
  } catch (err) {
    console.error('Morning sync error:', err);
    res.status(500).json({ error: 'Sync failed: ' + err.message });
  }
});

// ─── Order Booker: Mid-day Sync ───────────────────────────────────────────────
// GET /api/sync/midday?lastSync=ISO_TIMESTAMP
router.get('/midday', async (req, res) => {
  try {
    if (req.mobileUser.role !== 'order_booker') {
      return res.status(403).json({ error: 'Order booker access only' });
    }
    const { lastSync } = req.query;
    const payload = await SyncService.assembleMiddaySyncPayload(
      req.mobileUser.id,
      lastSync
    );
    res.json(payload);
  } catch (err) {
    console.error('Midday sync error:', err);
    res.status(500).json({ error: 'Sync failed: ' + err.message });
  }
});

// ─── Order Booker: Evening Sync ───────────────────────────────────────────────
// POST /api/sync/evening  { orders: [...], collections: [...] }
router.post('/evening', async (req, res) => {
  try {
    if (req.mobileUser.role !== 'order_booker') {
      return res.status(403).json({ error: 'Order booker access only' });
    }
    const { orders = [], collections = [] } = req.body;
    const result = await SyncService.processEveningSync(
      req.mobileUser.id,
      orders,
      collections
    );
    res.json({ success: true, ...result });
  } catch (err) {
    console.error('Evening sync error:', err);
    res.status(500).json({ error: 'Sync failed: ' + err.message });
  }
});

// ─── Order Booker: Upload Orders Only ────────────────────────────────────────
// POST /api/sync/orders  { orders: [...] }
router.post('/orders', async (req, res) => {
  try {
    if (req.mobileUser.role !== 'order_booker') {
      return res.status(403).json({ error: 'Order booker access only' });
    }
    const { orders = [] } = req.body;
    const result = await SyncService.processEveningSync(
      req.mobileUser.id,
      orders,
      []
    );
    res.json({ success: true, ...result });
  } catch (err) {
    console.error('Orders sync error:', err);
    res.status(500).json({ error: 'Sync failed: ' + err.message });
  }
});

// ─── Order Booker: Upload Recoveries Only ────────────────────────────────────
// POST /api/sync/recoveries  { collections: [...] }
router.post('/recoveries', async (req, res) => {
  try {
    if (req.mobileUser.role !== 'order_booker') {
      return res.status(403).json({ error: 'Order booker access only' });
    }
    const { collections = [] } = req.body;
    const result = await SyncService.processEveningSync(
      req.mobileUser.id,
      [],
      collections
    );
    res.json({ success: true, ...result });
  } catch (err) {
    console.error('Recoveries sync error:', err);
    res.status(500).json({ error: 'Sync failed: ' + err.message });
  }
});

// ─── Salesman: Morning Sync ───────────────────────────────────────────────────
// GET /api/sync/salesman/morning
router.get('/salesman/morning', async (req, res) => {
  try {
    if (req.mobileUser.role !== 'salesman') {
      return res.status(403).json({ error: 'Salesman access only' });
    }
    const payload = await SyncService.assembleSalesmanMorningSyncPayload(
      req.mobileUser.id
    );
    res.json(payload);
  } catch (err) {
    console.error('Salesman morning sync error:', err);
    res.status(500).json({ error: 'Sync failed: ' + err.message });
  }
});

// ─── Salesman: Submit Issuance ────────────────────────────────────────────────
// POST /api/sync/salesman/issuance  { issuance_date, items: [...] }
router.post('/salesman/issuance', async (req, res) => {
  try {
    if (req.mobileUser.role !== 'salesman') {
      return res.status(403).json({ error: 'Salesman access only' });
    }
    const { issuance_date, items = [] } = req.body;
    if (!items.length) {
      return res.status(400).json({ error: 'No items provided' });
    }
    const result = await SyncService.processSalesmanIssuance(
      req.mobileUser.id,
      issuance_date,
      items
    );
    res.status(201).json(result);
  } catch (err) {
    const status = err.status || 500;
    console.error('Salesman issuance error:', err);
    res.status(status).json({ error: err.message });
  }
});

// ─── Salesman: Check Issuance Status ─────────────────────────────────────────
// GET /api/sync/salesman/issuance-status
router.get('/salesman/issuance-status', async (req, res) => {
  try {
    if (req.mobileUser.role !== 'salesman') {
      return res.status(403).json({ error: 'Salesman access only' });
    }
    const result = await SyncService.getSalesmanIssuanceStatus(req.mobileUser.id);
    res.json(result);
  } catch (err) {
    console.error('Issuance status error:', err);
    res.status(500).json({ error: err.message });
  }
});

// ─── Salesman: Submit Return ──────────────────────────────────────────────────
// POST /api/sync/salesman/return  { return_date, cash_collected, items: [...] }
router.post('/salesman/return', async (req, res) => {
  try {
    if (req.mobileUser.role !== 'salesman') {
      return res.status(403).json({ error: 'Salesman access only' });
    }
    const { return_date, cash_collected, items = [] } = req.body;
    if (!items.length) {
      return res.status(400).json({ error: 'No items provided' });
    }
    const result = await SyncService.processSalesmanReturn(
      req.mobileUser.id,
      return_date,
      items,
      cash_collected
    );
    res.status(201).json(result);
  } catch (err) {
    const status = err.status || 500;
    console.error('Salesman return error:', err);
    res.status(status).json({ error: err.message });
  }
});

module.exports = router;
