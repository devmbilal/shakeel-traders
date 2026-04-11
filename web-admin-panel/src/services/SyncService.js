'use strict';
const { pool, getConnection } = require('../config/db');

class SyncService {
  // ─── Order Booker: Morning Sync ───────────────────────────────────────────
  static async assembleMorningSyncPayload(bookerId) {
    const today = new Date().toISOString().split('T')[0];

    // Routes assigned to this booker today
    const [routes] = await pool.query(
      `SELECT r.id, r.name
       FROM route_assignments ra
       JOIN routes r ON r.id = ra.route_id
       WHERE ra.user_id = ? AND ra.assignment_date = ? AND r.is_active = 1`,
      [bookerId, today]
    );

    const routeIds = routes.map(r => r.id);

    // Shops in those routes
    let shops = [];
    if (routeIds.length > 0) {
      const placeholders = routeIds.map(() => '?').join(',');
      const [shopRows] = await pool.query(
        `SELECT s.id, s.name AS shop_name, s.owner_name, s.phone, s.address,
                s.route_id, s.shop_type, s.price_edit_allowed,
                s.price_min_pct, s.price_max_pct,
                COALESCE((
                  SELECT SUM(sa.remaining_balance)
                  FROM shop_advances sa
                  WHERE sa.shop_id = s.id AND sa.remaining_balance > 0
                ), 0) AS advance_balance,
                COALESCE((
                  SELECT SUM(b.outstanding_amount)
                  FROM bills b
                  WHERE b.shop_id = s.id AND b.status IN ('open','partially_paid')
                ), 0) AS outstanding_balance,
                CASE WHEN EXISTS (
                  SELECT 1
                  FROM bills b
                  JOIN bill_recovery_assignments bra ON bra.bill_id = b.id
                  WHERE b.shop_id = s.id
                    AND bra.assigned_to_booker_id = ?
                    AND bra.assigned_date = ?
                    AND bra.status IN ('assigned','partially_recovered')
                ) THEN 1 ELSE 0 END AS has_recovery_bill
         FROM shops s
         WHERE s.route_id IN (${placeholders}) AND s.is_active = 1`,
        [bookerId, today, ...routeIds]
      );
      shops = shopRows;
    }

    // All active products with current stock
    const [products] = await pool.query(
      `SELECT id, sku_code, name AS product_name, brand, units_per_carton,
              retail_price, wholesale_price,
              current_stock_cartons, current_stock_loose
       FROM products WHERE is_active = 1`
    );

    // Last prices per shop+product
    const [lastPrices] = await pool.query(
      `SELECT shop_id, product_id, last_price
       FROM shop_last_prices`
    );

    const [recoveryAssignments] = await pool.query(
      `SELECT bra.id, bra.bill_id, bra.assigned_date, bra.status,
              b.bill_number, b.bill_date, b.gross_amount,
              b.outstanding_amount, b.amount_paid,
              s.name AS shop_name, s.address as shop_address
       FROM bill_recovery_assignments bra
       JOIN bills b ON b.id = bra.bill_id
       JOIN shops s ON s.id = b.shop_id
       WHERE bra.assigned_to_booker_id = ? AND bra.assigned_date = ?
         AND bra.status IN ('assigned','partially_recovered')`,
      [bookerId, today]
    );

    return {
      routes,
      shops,
      products,
      lastPrices,
      recoveryAssignments,
      syncDate: today,
    };
  }

  // ─── Order Booker: Mid-day Sync ───────────────────────────────────────────
  static async assembleMiddaySyncPayload(bookerId, lastSyncTime) {
    const today = new Date().toISOString().split('T')[0];

    const [recoveryAssignments] = await pool.query(
      `SELECT bra.id, bra.bill_id, bra.assigned_date, bra.status,
              b.bill_number, b.bill_date, b.gross_amount,
              b.outstanding_amount, b.amount_paid,
              s.name AS shop_name, s.address as shop_address
       FROM bill_recovery_assignments bra
       JOIN bills b ON b.id = bra.bill_id
       JOIN shops s ON s.id = b.shop_id
       WHERE bra.assigned_to_booker_id = ? AND bra.assigned_date = ?
         AND bra.status IN ('assigned','partially_recovered')
         AND bra.assigned_at > ?`,
      [bookerId, today, lastSyncTime || '1970-01-01']
    );

    return { recoveryAssignments };
  }

  // ─── Order Booker: Evening Sync ───────────────────────────────────────────
  static async processEveningSync(bookerId, orders, collections) {
    const stockAdjustments = [];
    const conn = await getConnection();

    try {
      await conn.beginTransaction();

      // Process orders
      for (const order of orders) {
        // Get current stock levels
        const [stockRows] = await conn.query(
          `SELECT id, current_stock_cartons, current_stock_loose
           FROM products WHERE is_active = 1`
        );
        const stockMap = {};
        for (const s of stockRows) {
          stockMap[s.id] = { cartons: s.current_stock_cartons, loose: s.current_stock_loose };
        }

        // Adjust order items for available stock using total units
        const adjustedItems = [];
        for (const item of order.items) {
          const stock = stockMap[item.product_id] || { cartons: 0, loose: 0 };
          const [[prod]] = await conn.query(
            'SELECT name AS product_name, units_per_carton FROM products WHERE id = ?',
            [item.product_id]
          );
          const upc = prod ? parseInt(prod.units_per_carton) : 1;
          const stockTotal   = stock.cartons * upc + stock.loose;
          const requestTotal = (item.cartons || 0) * upc + (item.loose_units || 0);
          const finalTotal   = Math.min(requestTotal, stockTotal);

          if (finalTotal < requestTotal) {
            const note = `Reduced from ${item.cartons}C+${item.loose_units}L to ${Math.floor(finalTotal/upc)}C+${finalTotal%upc}L (stock limit)`;
            stockAdjustments.push({
              product_id: item.product_id,
              product_name: prod?.product_name || 'Unknown',
              note,
            });
          }

          if (finalTotal > 0) {
            const finalCartons = Math.floor(finalTotal / upc);
            const finalLoose   = finalTotal % upc;
            adjustedItems.push({
              ...item,
              final_cartons: finalCartons,
              final_loose: finalLoose,
              stock_check_note: finalTotal < requestTotal ? 'Adjusted for stock availability' : null,
            });
          }
        }

        if (adjustedItems.length === 0) continue;

        // Insert order
        const [orderResult] = await conn.query(
          `INSERT INTO orders (order_booker_id, shop_id, route_id, status, created_at_device, created_at)
           VALUES (?, ?, ?, 'pending', NOW(), NOW())`,
          [bookerId, order.shop_id, order.route_id]
        );
        const orderId = orderResult.insertId;

        // Insert order items
        for (const item of adjustedItems) {
          await conn.query(
            `INSERT INTO order_items
             (order_id, product_id, ordered_cartons, ordered_loose,
              final_cartons, final_loose, unit_price)
             VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [orderId, item.product_id, item.cartons, item.loose_units,
             item.final_cartons, item.final_loose, item.unit_price]
          );
        }
      }

      // Process recovery collections
      for (const col of collections) {
        if (!col.amount_collected || col.amount_collected <= 0) continue;

        // Check assignment still valid
        const [[assignment]] = await conn.query(
          `SELECT id FROM bill_recovery_assignments
           WHERE id = ? AND assigned_to_booker_id = ? AND status IN ('assigned','partially_recovered')`,
          [col.assignment_id, bookerId]
        );
        if (!assignment) continue;

        // Insert collection
        await conn.query(
          `INSERT INTO recovery_collections
           (assignment_id, bill_id, amount_collected, payment_method, collected_at_device, collected_by_booker_id)
           VALUES (?, ?, ?, ?, NOW(), ?)`,
          [col.assignment_id, col.bill_id, col.amount_collected,
           col.payment_method || 'cash', bookerId]
        );

        // Update assignment status
        await conn.query(
          `UPDATE bill_recovery_assignments SET status = 'partially_recovered'
           WHERE id = ?`,
          [col.assignment_id]
        );
      }

      await conn.commit();
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }

    return { stockAdjustments };
  }

  // ─── Salesman: Morning Sync ───────────────────────────────────────────────
  static async assembleSalesmanMorningSyncPayload(salesmanId) {
    const today = new Date().toISOString().split('T')[0];

    const [products] = await pool.query(
      `SELECT id, sku_code, name AS product_name, brand, units_per_carton,
              retail_price, wholesale_price,
              current_stock_cartons, current_stock_loose
       FROM products WHERE is_active = 1`
    );

    // Get today's issuance with items if exists
    const [[issuance]] = await pool.query(
      `SELECT id, status FROM salesman_issuances
       WHERE salesman_id = ? AND issuance_date = ?
       ORDER BY created_at DESC LIMIT 1`,
      [salesmanId, today]
    );

    let issuanceItems = [];
    if (issuance) {
      const [items] = await pool.query(
        `SELECT ii.product_id, ii.cartons, ii.loose_units,
                p.name AS product_name, p.sku_code, p.units_per_carton
         FROM issuance_items ii
         JOIN products p ON p.id = ii.product_id
         WHERE ii.issuance_id = ?`,
        [issuance.id]
      );
      issuanceItems = items;
    }

    // Get today's return if exists
    const [[ret]] = await pool.query(
      `SELECT id, status, cash_collected FROM salesman_returns
       WHERE salesman_id = ? AND return_date = ?
       ORDER BY created_at DESC LIMIT 1`,
      [salesmanId, today]
    );

    return {
      products,
      issuanceStatus: issuance ? issuance.status : 'none',
      issuanceId: issuance ? issuance.id : null,
      issuanceItems,
      returnStatus: ret ? ret.status : 'none',
      syncDate: today,
    };
  }

  // ─── Salesman: Submit Issuance ────────────────────────────────────────────
  static async processSalesmanIssuance(salesmanId, issuanceDate, items) {
    const today = new Date().toISOString().split('T')[0];

    // Check for duplicate — one issuance per salesman per day (SRS BR)
    const [[existing]] = await pool.query(
      `SELECT id, status FROM salesman_issuances
       WHERE salesman_id = ? AND issuance_date = ?`,
      [salesmanId, today]
    );
    if (existing) {
      throw Object.assign(new Error('Issuance already submitted for today'), { status: 409 });
    }

    const conn = await getConnection();
    try {
      await conn.beginTransaction();

      const [result] = await conn.query(
        `INSERT INTO salesman_issuances (salesman_id, issuance_date, status, created_at)
         VALUES (?, ?, 'pending', NOW())`,
        [salesmanId, today]
      );
      const issuanceId = result.insertId;

      for (const item of items) {
        await conn.query(
          `INSERT INTO issuance_items (issuance_id, product_id, cartons, loose_units)
           VALUES (?, ?, ?, ?)`,
          [issuanceId, item.product_id, item.cartons, item.loose_units]
        );
      }

      await conn.commit();
      return { issuance_id: issuanceId, status: 'pending' };
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  }

  // ─── Salesman: Check Issuance Status ─────────────────────────────────────
  static async getSalesmanIssuanceStatus(salesmanId) {
    const today = new Date().toISOString().split('T')[0];
    const [[issuance]] = await pool.query(
      `SELECT id, status FROM salesman_issuances
       WHERE salesman_id = ? AND issuance_date = ?`,
      [salesmanId, today]
    );
    const [[ret]] = await pool.query(
      `SELECT id, status FROM salesman_returns
       WHERE salesman_id = ? AND return_date = ?`,
      [salesmanId, today]
    );
    return {
      status: issuance ? issuance.status : 'none',
      returnStatus: ret ? ret.status : 'none',
    };
  }

  // ─── Salesman: Submit Return ──────────────────────────────────────────────
  static async processSalesmanReturn(salesmanId, returnDate, items, cashCollected) {
    const today = new Date().toISOString().split('T')[0];

    // Must have an approved issuance today
    const [[issuance]] = await pool.query(
      `SELECT id FROM salesman_issuances
       WHERE salesman_id = ? AND issuance_date = ? AND status = 'approved'
       ORDER BY created_at DESC LIMIT 1`,
      [salesmanId, today]
    );
    if (!issuance) {
      throw Object.assign(
        new Error('No approved issuance found for today'), { status: 400 }
      );
    }

    // If a pending return already exists, delete it and re-submit (allow editing before admin approval)
    const [[existing]] = await pool.query(
      `SELECT id, status FROM salesman_returns
       WHERE salesman_id = ? AND return_date = ?
       ORDER BY created_at DESC LIMIT 1`,
      [salesmanId, today]
    );
    if (existing && existing.status === 'approved') {
      throw Object.assign(new Error('Return already approved by admin'), { status: 409 });
    }

    const conn = await getConnection();
    try {
      await conn.beginTransaction();

      // Delete existing pending return if any (allow re-submission)
      if (existing) {
        await conn.query('DELETE FROM return_items WHERE return_id = ?', [existing.id]);
        await conn.query('DELETE FROM salesman_returns WHERE id = ?', [existing.id]);
      }

      const [result] = await conn.query(
        `INSERT INTO salesman_returns
         (salesman_id, issuance_id, return_date, status, cash_collected, created_at)
         VALUES (?, ?, ?, 'pending', ?, NOW())`,
        [salesmanId, issuance.id, today, cashCollected || 0]
      );
      const returnId = result.insertId;

      for (const item of items) {
        const [[product]] = await conn.query(
          'SELECT retail_price, units_per_carton FROM products WHERE id = ?',
          [item.product_id]
        );
        const retailPrice = product ? parseFloat(product.retail_price) : 0;
        const upc = product ? parseInt(product.units_per_carton) : 1;

        const [[issued]] = await conn.query(
          'SELECT cartons, loose_units FROM issuance_items WHERE issuance_id = ? AND product_id = ?',
          [issuance.id, item.product_id]
        );
        const soldCartons = issued ? Math.max(0, issued.cartons - (item.returned_cartons || 0)) : 0;
        const soldLoose   = issued ? Math.max(0, issued.loose_units - (item.returned_loose || 0)) : 0;
        const lineSaleValue = (soldCartons * upc + soldLoose) * retailPrice;

        await conn.query(
          `INSERT INTO return_items
           (return_id, product_id, returned_cartons, returned_loose, sold_cartons, sold_loose, retail_price, line_sale_value)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
          [returnId, item.product_id, item.returned_cartons || 0, item.returned_loose || 0,
           soldCartons, soldLoose, retailPrice, lineSaleValue]
        );
      }

      const [[saleRow]] = await conn.query(
        'SELECT SUM(line_sale_value) AS total FROM return_items WHERE return_id = ?',
        [returnId]
      );
      const systemSaleValue = parseFloat(saleRow?.total || 0);
      await conn.query(
        'UPDATE salesman_returns SET system_sale_value = ? WHERE id = ?',
        [systemSaleValue, returnId]
      );

      await conn.commit();
      return { return_id: returnId, status: 'pending' };
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  }
}

module.exports = SyncService;
