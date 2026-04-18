'use strict';

const os   = require('os');
const { query } = require('../config/db');
const { renderWithLayout } = require('../utils/render');

function getLocalIP() {
  const ifaces = os.networkInterfaces();
  // Adapter names to skip (virtual adapters)
  const skipNames = ['virtualbox', 'vbox', 'vmware', 'vethernet', 'wsl', 'loopback', 'hyper-v'];
  let fallback = '127.0.0.1';

  for (const name of Object.keys(ifaces)) {
    const nameLower = name.toLowerCase();
    // Skip virtual/WSL adapters
    if (skipNames.some(s => nameLower.includes(s))) continue;

    for (const iface of ifaces[name]) {
      if (iface.family !== 'IPv4' || iface.internal) continue;
      const ip = iface.address;
      if (ip.startsWith('192.168.') || ip.startsWith('10.')) return ip;
      fallback = ip;
    }
  }
  return fallback;
}

const DashboardController = {

  async index(req, res) {
    try {
      const { query } = require('../config/db');
      const logoRows = await query('SELECT logo_path FROM company_profile WHERE id = 1 LIMIT 1');
      const logoPath = (logoRows[0] && logoRows[0].logo_path) ? logoRows[0].logo_path : null;
      renderWithLayout(req, res, 'dashboard/index', {
        title: 'Dashboard - Shakeel Traders',
        logoPath,
      });
    } catch (err) {
      console.error('Dashboard error:', err);
      req.flash('error', 'Failed to load dashboard.');
      res.redirect('/login');
    }
  },

  async getData(req, res) {
    try {
      const view = req.query.view || 'daily';
      // Use MySQL CURDATE() to avoid JS UTC vs local timezone mismatch
      const dateRows = await query('SELECT CURDATE() AS today, DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL DAY(CURDATE())-1 DAY), \'%Y-%m-%d\') AS first_of_month, DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL DAYOFYEAR(CURDATE())-1 DAY), \'%Y-%m-%d\') AS first_of_year');
      const today           = dateRows[0].today;
      const firstDayOfMonth = dateRows[0].first_of_month;
      const firstDayOfYear  = dateRows[0].first_of_year;

      let dateFilter, dateParam, dateLabel;
      if (view === 'daily') {
        dateFilter = 'b.bill_date = ?';
        dateParam = today;
        dateLabel = 'Today';
      } else if (view === 'monthly') {
        dateFilter = 'b.bill_date >= ?';
        dateParam = firstDayOfMonth;
        dateLabel = 'This Month';
      } else {
        dateFilter = 'b.bill_date >= ?';
        dateParam = firstDayOfYear;
        dateLabel = 'This Year';
      }

      // Financial Metrics
      const [outstandingData] = await query(
        `SELECT 
          SUM(outstanding_amount) AS total_outstanding,
          COUNT(*) AS bill_count
         FROM bills 
         WHERE status IN ('open', 'partially_paid')`
      );


      const [stockValue] = await query(
        `SELECT 
          SUM(current_stock_cartons) AS total_cartons,
          SUM(current_stock_loose) AS total_loose,
          SUM((current_stock_cartons * units_per_carton + current_stock_loose) * retail_price) AS stock_value
         FROM products 
         WHERE is_active = 1`
      );

      const [supplierAdvance] = await query(
        `SELECT 
          SUM(current_advance_balance) AS total_advance,
          COUNT(*) AS supplier_count
         FROM supplier_companies 
         WHERE is_active = 1`
      );

      // Sales by Channel — order_booker and direct_shop from bills, salesman from returns
      const salesByChannel = await query(
        `SELECT 
          bill_type,
          COUNT(*) AS bill_count,
          SUM(gross_amount) AS total_sales,
          SUM(outstanding_amount) AS total_outstanding
         FROM bills
         WHERE ${dateFilter.replace('b.bill_date', 'bill_date')}
           AND bill_type IN ('order_booker','direct_shop')
         GROUP BY bill_type`,
        [dateParam]
      );

      // Salesman sales from centralized_cash_entries (posted on return approval)
      const salesmanCashFilter = view === 'daily'
        ? 'cash_date = ?'
        : 'cash_date >= ?';
      const [salesmanSales] = await query(
        `SELECT COALESCE(SUM(amount), 0) AS total_sales
         FROM centralized_cash_entries
         WHERE entry_type = 'salesman_sale' AND ${salesmanCashFilter}`,
        [dateParam]
      );

      const sales = {
        order_booker: { sales: 0, count: 0, outstanding: 0 },
        salesman: {
          sales: parseFloat(salesmanSales.total_sales || 0),
          count: 0,
          outstanding: 0
        },
        direct_shop: { sales: 0, count: 0, outstanding: 0 },
        total: parseFloat(salesmanSales.total_sales || 0),
        totalCount: 0
      };

      salesByChannel.forEach(row => {
        sales[row.bill_type] = {
          sales: parseFloat(row.total_sales || 0),
          count: parseInt(row.bill_count || 0),
          outstanding: parseFloat(row.total_outstanding || 0)
        };
        sales.total += parseFloat(row.total_sales || 0);
        sales.totalCount += parseInt(row.bill_count || 0);
      });


      // Route breakdown
      const routeBreakdown = await query(
        `SELECT 
          r.id,
          r.name AS route_name,
          COUNT(DISTINCT b.id) AS bill_count,
          SUM(b.gross_amount) AS total_sales,
          COUNT(DISTINCT b.shop_id) AS shop_count
         FROM bills b
         JOIN shops s ON s.id = b.shop_id
         JOIN routes r ON r.id = s.route_id
         WHERE b.bill_type = 'order_booker' AND ${dateFilter}
         GROUP BY r.id, r.name
         ORDER BY total_sales DESC
         LIMIT 5`,
        [dateParam]
      );

      // Salesman breakdown — sales from centralized_cash_entries, stock sold from return_items
      const salesmanBreakdown = await query(
        `SELECT 
          u.id,
          u.full_name AS salesman_name,
          COALESCE(SUM(cce.amount), 0) AS total_sales,
          COALESCE(SUM(ri.sold_cartons), 0) AS total_sold_cartons,
          COALESCE(SUM(ri.sold_loose), 0) AS total_sold_loose
         FROM users u
         LEFT JOIN salesman_returns sr ON sr.salesman_id = u.id
           AND sr.status = 'approved'
           AND sr.approved_at >= ?
         LEFT JOIN centralized_cash_entries cce ON cce.reference_id = sr.id
           AND cce.entry_type = 'salesman_sale'
           AND cce.cash_date >= ?
         LEFT JOIN return_items ri ON ri.return_id = sr.id
         WHERE u.role = 'salesman' AND u.is_active = 1
         GROUP BY u.id, u.full_name
         HAVING total_sales > 0
         ORDER BY total_sales DESC
         LIMIT 5`,
        [view === 'daily' ? today : dateParam, view === 'daily' ? today : dateParam]
      );


      // Order Booker Performance (bills.order_id references orders.id)
      const bookerPerformance = await query(
        `SELECT 
          u.id,
          u.full_name,
          u.contact,
          COUNT(DISTINCT o.id) AS orders_booked,
          COUNT(DISTINCT CASE WHEN o.status = 'converted' THEN o.id END) AS bills_converted,
          COALESCE(SUM(CASE WHEN o.status = 'converted' THEN b.gross_amount END), 0) AS total_sales,
          COUNT(DISTINCT bra.id) AS recovery_assigned,
          COALESCE(SUM(rc.amount_collected), 0) AS recovery_collected,
          COUNT(DISTINCT ra.id) AS routes_assigned
         FROM users u
         LEFT JOIN orders o ON o.order_booker_id = u.id 
           AND DATE(o.created_at) >= ? 
           AND DATE(o.created_at) <= ?
         LEFT JOIN bills b ON b.order_id = o.id
         LEFT JOIN bill_recovery_assignments bra ON bra.assigned_to_booker_id = u.id 
           AND DATE(bra.assigned_date) = ?
         LEFT JOIN recovery_collections rc ON rc.assignment_id = bra.id 
           AND rc.verified_by_admin_id IS NOT NULL
         LEFT JOIN route_assignments ra ON ra.user_id = u.id 
           AND ra.assignment_date = ?
         WHERE u.role = 'order_booker' AND u.is_active = 1
         GROUP BY u.id, u.full_name, u.contact
         ORDER BY total_sales DESC, orders_booked DESC
         LIMIT 10`,
        [view === 'daily' ? today : dateParam, today, today, today]
      );


      // Salesman Performance
      const salesmanPerformance = await query(
        `SELECT 
          u.id,
          u.full_name,
          u.contact,
          COALESCE(SUM(ii.cartons * p.units_per_carton + ii.loose_units), 0) AS issued_units,
          COALESCE(SUM(ri.returned_cartons * p.units_per_carton + ri.returned_loose), 0) AS returned_units,
          COALESCE(SUM((ii.cartons * p.units_per_carton + ii.loose_units) - 
                       (ri.returned_cartons * p.units_per_carton + ri.returned_loose)), 0) AS sold_units,
          COALESCE(MAX(sr.final_sale_value), 0) AS sale_value,
          MAX(si.status) AS issuance_status,
          MAX(sr.status) AS return_status
         FROM users u
         LEFT JOIN salesman_issuances si ON si.salesman_id = u.id 
           AND si.issuance_date = ?
         LEFT JOIN issuance_items ii ON ii.issuance_id = si.id
         LEFT JOIN products p ON p.id = ii.product_id
         LEFT JOIN salesman_returns sr ON sr.salesman_id = u.id 
           AND sr.return_date = ?
         LEFT JOIN return_items ri ON ri.return_id = sr.id
         WHERE u.role = 'salesman' AND u.is_active = 1
         GROUP BY u.id, u.full_name, u.contact
         ORDER BY sale_value DESC
         LIMIT 10`,
        [today, today]
      );

      // Alerts
      const lowStockProducts = await query(
        `SELECT 
          id, sku_code, name, brand,
          current_stock_cartons, current_stock_loose,
          units_per_carton, low_stock_threshold,
          (current_stock_cartons * units_per_carton + current_stock_loose) AS total_units
         FROM products
         WHERE is_active = 1 
           AND low_stock_threshold IS NOT NULL
           AND (current_stock_cartons * units_per_carton + current_stock_loose) <= low_stock_threshold
         ORDER BY total_units ASC
         LIMIT 10`
      );


      const [pendingCounts] = await query(
        `SELECT 
          (SELECT COUNT(*) FROM salesman_issuances WHERE status = 'pending') AS pending_issuances,
          (SELECT COUNT(*) FROM salesman_returns WHERE status = 'pending') AS pending_returns,
          (SELECT COUNT(*) FROM recovery_collections WHERE verified_by_admin_id IS NULL) AS pending_verifications,
          (SELECT COUNT(*) FROM orders WHERE status = 'pending') AS pending_orders`
      );

      // yesterday = CURDATE() - 1 day (MySQL-based to avoid timezone issues)
      const yesterdayRows = await query("SELECT DATE_SUB(CURDATE(), INTERVAL 1 DAY) AS yesterday");
      const yesterdayStr = yesterdayRows[0].yesterday;

      const unsyncedBookers = await query(
        `SELECT DISTINCT
          u.id,
          u.full_name,
          COUNT(DISTINCT bra.id) AS assigned_recoveries
         FROM users u
         JOIN bill_recovery_assignments bra ON bra.assigned_to_booker_id = u.id
         WHERE bra.assigned_date = ?
           AND bra.status = 'returned_to_pool'
           AND u.is_active = 1
         GROUP BY u.id, u.full_name`,
        [yesterdayStr]
      );

      // Cash Flow
      const cashFlow = await query(
        `SELECT 
          entry_type,
          COUNT(*) AS entry_count,
          SUM(amount) AS total_amount
         FROM centralized_cash_entries
         WHERE cash_date >= ? AND cash_date <= ?
         GROUP BY entry_type`,
        [view === 'daily' ? today : dateParam, today]
      );

      const cash = {
        salesman_sale: 0,
        recovery: 0,
        delivery_man_collection: 0,
        total: 0
      };

      cashFlow.forEach(row => {
        cash[row.entry_type] = parseFloat(row.total_amount || 0);
        cash.total += parseFloat(row.total_amount || 0);
      });


      const [quickStats] = await query(
        `SELECT 
          (SELECT COUNT(*) FROM shops WHERE is_active = 1) AS total_shops,
          (SELECT COUNT(*) FROM products WHERE is_active = 1) AS total_products,
          (SELECT COUNT(*) FROM users WHERE role = 'order_booker' AND is_active = 1) AS active_bookers,
          (SELECT COUNT(*) FROM users WHERE role = 'salesman' AND is_active = 1) AS active_salesmen,
          (SELECT COUNT(*) FROM routes WHERE is_active = 1) AS total_routes`
      );

      // Company logo
      const logoRows = await query('SELECT logo_path FROM company_profile WHERE id = 1 LIMIT 1');
      const logoPath = (logoRows[0] && logoRows[0].logo_path) ? logoRows[0].logo_path : '/images/logo.png';

      res.json({
        view,
        dateLabel,
        financials: {
          totalOutstanding: parseFloat(outstandingData.total_outstanding || 0),
          outstandingBillCount: parseInt(outstandingData.bill_count || 0),
          stockValue: parseFloat(stockValue.stock_value || 0),
          totalCartons: parseInt(stockValue.total_cartons || 0),
          totalLoose: parseInt(stockValue.total_loose || 0),
          supplierAdvance: parseFloat(supplierAdvance.total_advance || 0),
          supplierCount: parseInt(supplierAdvance.supplier_count || 0)
        },
        sales,
        routeBreakdown,
        salesmanBreakdown,
        bookerPerformance,
        salesmanPerformance,
        alerts: {
          lowStockCount: lowStockProducts.length,
          lowStockProducts,
          pendingIssuances: parseInt(pendingCounts.pending_issuances || 0),
          pendingReturns: parseInt(pendingCounts.pending_returns || 0),
          pendingVerifications: parseInt(pendingCounts.pending_verifications || 0),
          pendingOrders: parseInt(pendingCounts.pending_orders || 0),
          unsyncedBookers
        },
        cash,
        stats: quickStats,
        server: {
          ip:   getLocalIP(),
          port: process.env.PORT || 3000
        },
        logoPath
      });

    } catch (err) {
      console.error('Dashboard data error:', err);
      res.status(500).json({ error: 'Failed to load dashboard data', message: err.message });
    }
  },
};

module.exports = DashboardController;
