'use strict';

const { generateBillNumber } = require('../utils/billNumberGenerator');

const BillService = {
  /**
   * Create a bill with all associated records.
   * Must be called inside an active transaction (conn).
   *
   * @param {number} shopId
   * @param {string} billType  'order_booker' | 'direct_shop' | 'salesman'
   * @param {Array}  items     [{product_id, cartons, loose_units, unit_price, units_per_carton}]
   * @param {number} userId    Admin who created the bill
   * @param {object} conn      Active transaction connection
   * @param {number|null} orderId  For order_booker bills
   * @returns {number} bill id
   */
  async createBill(shopId, billType, items, userId, conn, orderId = null) {
    // Calculate gross amount
    let grossAmount = 0;
    for (const item of items) {
      const units = parseInt(item.cartons) * parseInt(item.units_per_carton) + parseInt(item.loose_units || 0);
      item.line_total = units * parseFloat(item.unit_price);
      grossAmount += item.line_total;
    }

    // Check shop advance balance
    const [[advRow]] = await conn.query(
      'SELECT COALESCE(SUM(remaining_balance), 0) AS total FROM shop_advances WHERE shop_id = ?',
      [shopId]
    );
    const advanceAvailable = parseFloat(advRow.total);
    const advanceDeducted  = Math.min(grossAmount, advanceAvailable);
    const netAmount        = grossAmount - advanceDeducted;
    const outstandingAmount = netAmount; // amount_paid starts at 0

    // Generate bill number
    const billNumber = await generateBillNumber(billType, conn);
    // Use MySQL date to avoid UTC timezone mismatch
    const [[dateRow]] = await conn.query('SELECT CURDATE() AS today');
    const billDate = dateRow.today;

    // Insert bill
    const [billResult] = await conn.query(
      `INSERT INTO bills
         (order_id, shop_id, bill_type, bill_date, bill_number,
          gross_amount, advance_deducted, net_amount, amount_paid, outstanding_amount,
          status, created_by)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?, 'open', ?)`,
      [orderId, shopId, billType, billDate, billNumber,
       grossAmount, advanceDeducted, netAmount, outstandingAmount, userId]
    );
    const billId = billResult.insertId;

    // Insert bill items + update shop_last_prices
    for (const item of items) {
      await conn.query(
        'INSERT INTO bill_items (bill_id, product_id, cartons, loose_units, unit_price, line_total) VALUES (?, ?, ?, ?, ?, ?)',
        [billId, item.product_id, item.cartons, item.loose_units || 0, item.unit_price, item.line_total]
      );
      // Upsert shop_last_prices
      await conn.query(
        `INSERT INTO shop_last_prices (shop_id, product_id, last_price)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE last_price = VALUES(last_price), updated_at = NOW()`,
        [shopId, item.product_id, item.unit_price]
      );
    }

    // Deduct from shop advance if applicable
    if (advanceDeducted > 0) {
      // Deduct from oldest advances first
      const [advances] = await conn.query(
        'SELECT id, remaining_balance FROM shop_advances WHERE shop_id = ? AND remaining_balance > 0 ORDER BY advance_date ASC',
        [shopId]
      );
      let remaining = advanceDeducted;
      for (const adv of advances) {
        if (remaining <= 0) break;
        const deduct = Math.min(remaining, parseFloat(adv.remaining_balance));
        await conn.query(
          'UPDATE shop_advances SET remaining_balance = remaining_balance - ? WHERE id = ?',
          [deduct, adv.id]
        );
        remaining -= deduct;
      }
    }

    // Get current shop ledger balance
    const [[balRow]] = await conn.query(
      'SELECT COALESCE(balance_after, 0) AS bal FROM shop_ledger_entries WHERE shop_id = ? ORDER BY created_at DESC LIMIT 1',
      [shopId]
    );
    const prevBalance = parseFloat(balRow ? balRow.bal : 0);
    const newBalance  = prevBalance + netAmount - advanceDeducted;

    // Insert shop ledger entry (APPEND ONLY)
    await conn.query(
      `INSERT INTO shop_ledger_entries
         (shop_id, entry_type, reference_id, reference_type, debit, credit, balance_after, note, entry_date)
       VALUES (?, 'bill', ?, 'bills', ?, ?, ?, ?, ?)`,
      [shopId, billId, netAmount, advanceDeducted, newBalance, `Bill ${billNumber}`, billDate]
    );

    return { billId, billNumber, grossAmount, advanceDeducted, netAmount };
  },
};

module.exports = BillService;
