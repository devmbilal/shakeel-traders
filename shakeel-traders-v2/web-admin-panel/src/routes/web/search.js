'use strict';

const express = require('express');
const router = express.Router();
const { query } = require('../../config/db');

router.get('/api/search', async (req, res) => {
  try {
    const searchQuery = req.query.q || '';
    
    if (searchQuery.length < 2) {
      return res.json({ orders: [], products: [], shops: [], routes: [] });
    }

    const searchPattern = `%${searchQuery}%`;

    // Search Orders
    const orders = await query(
      `SELECT 
        o.id, 
        o.status, 
        o.created_at,
        s.name AS shop_name,
        u.full_name AS booker_name
       FROM orders o
       LEFT JOIN shops s ON s.id = o.shop_id
       LEFT JOIN users u ON u.id = o.order_booker_id
       WHERE CAST(o.id AS CHAR) LIKE ? 
         OR s.name LIKE ?
         OR u.full_name LIKE ?
       ORDER BY o.created_at DESC
       LIMIT 5`,
      [searchPattern, searchPattern, searchPattern]
    );

    // Search Outstanding Bills
    const bills = await query(
      `SELECT 
        b.id,
        b.bill_number,
        b.bill_type,
        b.bill_date,
        b.outstanding_amount,
        b.status,
        s.name AS shop_name,
        s.owner_name AS shop_owner_name
       FROM bills b
       LEFT JOIN shops s ON s.id = b.shop_id
       WHERE b.outstanding_amount > 0
         AND (
           CAST(b.id AS CHAR) LIKE ?
           OR b.bill_number LIKE ?
           OR s.name LIKE ?
           OR s.owner_name LIKE ?
         )
       ORDER BY b.outstanding_amount DESC, b.bill_date DESC
       LIMIT 5`,
      [searchPattern, searchPattern, searchPattern, searchPattern]
    );

    // Search Products
    const products = await query(
      `SELECT 
        id, 
        sku_code, 
        name, 
        brand, 
        current_stock_cartons,
        current_stock_loose,
        retail_price,
        wholesale_price
       FROM products
       WHERE sku_code LIKE ? 
         OR name LIKE ? 
         OR brand LIKE ?
         OR CAST(id AS CHAR) LIKE ?
       ORDER BY name ASC
       LIMIT 5`,
      [searchPattern, searchPattern, searchPattern, searchPattern]
    );

    // Enhanced Search Shops - Include contact info
    const shops = await query(
      `SELECT 
        s.id, 
        s.name AS shop_name, 
        s.owner_name AS shop_owner_name,
        s.phone,
        s.address,
        r.name AS route_name,
        r.id AS route_id
       FROM shops s
       LEFT JOIN routes r ON r.id = s.route_id
       WHERE s.name LIKE ? 
         OR s.owner_name LIKE ?
         OR s.phone LIKE ?
         OR s.address LIKE ?
       ORDER BY s.name ASC
       LIMIT 5`,
      [searchPattern, searchPattern, searchPattern, searchPattern]
    );

    // Enhanced Search Routes - Include assignment info
    const routes = await query(
      `SELECT 
        r.id, 
        r.name, 
        COUNT(s.id) AS shop_count,
        GROUP_CONCAT(DISTINCT u.full_name ORDER BY u.full_name SEPARATOR ', ') AS assigned_bookers
       FROM routes r
       LEFT JOIN shops s ON s.route_id = r.id
       LEFT JOIN route_assignments ra ON ra.route_id = r.id AND ra.assignment_date = CURDATE()
       LEFT JOIN users u ON u.id = ra.user_id
       WHERE r.name LIKE ?
       GROUP BY r.id, r.name
       ORDER BY r.name ASC
       LIMIT 5`,
      [searchPattern]
    );

    res.json({
      orders,
      bills,
      products,
      shops,
      routes
    });

  } catch (err) {
    console.error('Search error:', err);
    res.status(500).json({ error: 'Search failed', message: err.message });
  }
});

module.exports = router;
