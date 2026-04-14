'use strict';

const { query } = require('../config/db');

const OrderModel = {
  async countPending(filters = {}) {
    const conditions = ['o.status IN (\'pending\',\'stock_adjusted\')'];
    const params = [];

    if (filters.date)      { conditions.push('DATE(o.created_at_device) = ?'); params.push(filters.date); }
    if (filters.booker_id) { conditions.push('o.order_booker_id = ?');         params.push(filters.booker_id); }
    if (filters.route_id)  { conditions.push('o.route_id = ?');                params.push(filters.route_id); }
    if (filters.shop_id)   { conditions.push('o.shop_id = ?');                 params.push(filters.shop_id); }

    const rows = await query(
      `SELECT COUNT(*) AS total
       FROM orders o
       WHERE ${conditions.join(' AND ')}`,
      params
    );
    return rows[0].total;
  },

  async listPending(filters = {}, { limit = 25, offset = 0 } = {}) {
    const conditions = ['o.status IN (\'pending\',\'stock_adjusted\')'];
    const params = [];

    if (filters.date)      { conditions.push('DATE(o.created_at_device) = ?'); params.push(filters.date); }
    if (filters.booker_id) { conditions.push('o.order_booker_id = ?');         params.push(filters.booker_id); }
    if (filters.route_id)  { conditions.push('o.route_id = ?');                params.push(filters.route_id); }
    if (filters.shop_id)   { conditions.push('o.shop_id = ?');                 params.push(filters.shop_id); }

    params.push(limit, offset);

    return query(
      `SELECT o.*, u.full_name AS booker_name, s.name AS shop_name, r.name AS route_name
       FROM orders o
       JOIN users u ON u.id = o.order_booker_id
       JOIN shops s ON s.id = o.shop_id
       JOIN routes r ON r.id = o.route_id
       WHERE ${conditions.join(' AND ')}
       ORDER BY o.created_at_device DESC
       LIMIT ? OFFSET ?`,
      params
    );
  },

  async findById(id) {
    const rows = await query(
      `SELECT o.*, u.full_name AS booker_name, s.name AS shop_name, r.name AS route_name
       FROM orders o
       JOIN users u ON u.id = o.order_booker_id
       JOIN shops s ON s.id = o.shop_id
       JOIN routes r ON r.id = o.route_id
       WHERE o.id = ? LIMIT 1`,
      [id]
    );
    if (!rows.length) return null;
    const order = rows[0];
    order.items = await query(
      `SELECT oi.*, p.name AS product_name, p.sku_code, p.units_per_carton
       FROM order_items oi
       JOIN products p ON p.id = oi.product_id
       WHERE oi.order_id = ?`,
      [id]
    );
    return order;
  },

  async countConverted(filters = {}) {
    const conditions = ['b.bill_type = \'order_booker\''];
    const params = [];
    if (filters.date)    { conditions.push('b.bill_date = ?'); params.push(filters.date); }
    if (filters.shop_id) { conditions.push('b.shop_id = ?');   params.push(filters.shop_id); }

    const rows = await query(
      `SELECT COUNT(*) AS total
       FROM bills b
       WHERE ${conditions.join(' AND ')}`,
      params
    );
    return rows[0].total;
  },

  async listConverted(filters = {}, { limit = 25, offset = 0 } = {}) {
    const conditions = ['b.bill_type = \'order_booker\''];
    const params = [];
    if (filters.date)    { conditions.push('b.bill_date = ?'); params.push(filters.date); }
    if (filters.shop_id) { conditions.push('b.shop_id = ?');   params.push(filters.shop_id); }

    params.push(limit, offset);

    return query(
      `SELECT b.*, s.name AS shop_name, u.full_name AS created_by_name
       FROM bills b
       JOIN shops s ON s.id = b.shop_id
       JOIN users u ON u.id = b.created_by
       WHERE ${conditions.join(' AND ')}
       ORDER BY b.created_at DESC
       LIMIT ? OFFSET ?`,
      params
    );
  },

  async findBillById(id) {
    const rows = await query(
      `SELECT b.*, 
              s.name AS shop_name, 
              s.owner_name AS shop_owner_name,
              s.address AS shop_address,
              r.name AS route_name,
              cp.company_name, 
              cp.owner_name AS company_owner, 
              cp.address AS company_address,
              cp.phone_1, 
              cp.gst_ntn, 
              cp.sales_tax,
              cp.cnic,
              cp.logo_path
       FROM bills b
       JOIN shops s ON s.id = b.shop_id
       JOIN routes r ON r.id = s.route_id
       LEFT JOIN company_profile cp ON cp.id = 1
       WHERE b.id = ? LIMIT 1`,
      [id]
    );
    if (!rows.length) return null;
    const bill = rows[0];
    bill.items = await query(
      `SELECT bi.*, p.name AS product_name, p.sku_code, p.units_per_carton
       FROM bill_items bi
       JOIN products p ON p.id = bi.product_id
       WHERE bi.bill_id = ?`,
      [id]
    );
    return bill;
  },

  async getConsolidatedForIds(orderIds) {
    if (!orderIds || orderIds.length === 0) return [];
    const placeholders = orderIds.map(() => '?').join(',');
    return query(
      `SELECT p.sku_code, p.name, p.units_per_carton,
              p.current_stock_cartons, p.current_stock_loose,
              SUM(oi.final_cartons) AS total_cartons,
              SUM(oi.final_loose) AS total_loose
       FROM order_items oi
       JOIN orders o ON o.id = oi.order_id
       JOIN products p ON p.id = oi.product_id
       WHERE o.id IN (${placeholders}) AND o.status IN ('pending','stock_adjusted')
       GROUP BY p.id ORDER BY p.name ASC`,
      orderIds
    );
  },

  async listOpenBills() {
    const bills = await query(
      `SELECT b.*, s.name AS shop_name
       FROM bills b
       JOIN shops s ON s.id = b.shop_id
       WHERE b.outstanding_amount > 0
       ORDER BY b.bill_date DESC`
    );
    for (const bill of bills) {
      bill.items = await query(
        `SELECT bi.*, p.name AS product_name, p.sku_code, p.units_per_carton
         FROM bill_items bi
         JOIN products p ON p.id = bi.product_id
         WHERE bi.bill_id = ?`,
        [bill.id]
      );
    }
    return bills;
  },
};

module.exports = OrderModel;
