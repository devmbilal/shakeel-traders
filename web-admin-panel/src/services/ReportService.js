'use strict';
const db = require('../config/db');

class ReportService {
  // 1. Daily Sales Report
  static async dailySalesReport(date) {
    // Order booker + direct shop sales from bills
    const billRows = await db.query(`
      SELECT 
        bill_type,
        COUNT(*) as bill_count,
        SUM(gross_amount) as gross_amount,
        SUM(advance_deducted) as advance_deducted,
        SUM(net_amount) as net_amount,
        SUM(amount_paid) as amount_paid,
        SUM(outstanding_amount) as outstanding_amount
      FROM bills
      WHERE DATE(created_at) = ?
        AND bill_type IN ('order_booker','direct_shop')
      GROUP BY bill_type
    `, [date]);

    // Salesman sales from approved returns (stock-based, no bills)
    const [salesmanRow] = await db.query(`
      SELECT 
        COALESCE(SUM(final_sale_value), 0) AS total_sale_value,
        COUNT(*) AS returns_count
      FROM salesman_returns
      WHERE status = 'approved' AND DATE(approved_at) = ?
    `, [date]);

    return {
      date,
      order_booker: billRows.find(r => r.bill_type === 'order_booker') || { bill_count: 0, gross_amount: 0, net_amount: 0 },
      salesman: {
        sale_value: parseFloat(salesmanRow.total_sale_value || 0),
        returns_count: parseInt(salesmanRow.returns_count || 0)
      },
      direct_shop: billRows.find(r => r.bill_type === 'direct_shop') || { bill_count: 0, gross_amount: 0, net_amount: 0 },
      total: billRows.reduce((sum, r) => sum + parseFloat(r.net_amount || 0), 0) +
             parseFloat(salesmanRow.total_sale_value || 0)
    };
  }

  // 2. Monthly Sales Report
  static async monthlySalesReport(month, year) {
    const billRows = await db.query(`
      SELECT 
        bill_type,
        COUNT(*) as bill_count,
        SUM(gross_amount) as gross_amount,
        SUM(advance_deducted) as advance_deducted,
        SUM(net_amount) as net_amount,
        SUM(amount_paid) as amount_paid,
        SUM(outstanding_amount) as outstanding_amount
      FROM bills
      WHERE MONTH(created_at) = ? AND YEAR(created_at) = ?
        AND bill_type IN ('order_booker','direct_shop')
      GROUP BY bill_type
    `, [month, year]);

    const [salesmanRow] = await db.query(`
      SELECT 
        COALESCE(SUM(final_sale_value), 0) AS total_sale_value,
        COUNT(*) AS returns_count
      FROM salesman_returns
      WHERE status = 'approved'
        AND MONTH(approved_at) = ? AND YEAR(approved_at) = ?
    `, [month, year]);

    return {
      month,
      year,
      order_booker: billRows.find(r => r.bill_type === 'order_booker') || { bill_count: 0, gross_amount: 0, net_amount: 0 },
      salesman: {
        sale_value: parseFloat(salesmanRow.total_sale_value || 0),
        returns_count: parseInt(salesmanRow.returns_count || 0)
      },
      direct_shop: billRows.find(r => r.bill_type === 'direct_shop') || { bill_count: 0, gross_amount: 0, net_amount: 0 },
      total: billRows.reduce((sum, r) => sum + parseFloat(r.net_amount || 0), 0) +
             parseFloat(salesmanRow.total_sale_value || 0)
    };
  }

  // 3. Order Booker Performance Report
  static async orderBookerPerformanceReport(filters = {}) {
    const { startDate, endDate, bookerId } = filters;
    let query = `
      SELECT 
        u.id,
        u.full_name,
        u.username,
        COUNT(DISTINCT o.id) as orders_booked,
        COUNT(DISTINCT CASE WHEN o.status = 'converted' THEN o.id END) as bills_converted,
        COUNT(DISTINCT bra.id) as recovery_bills_assigned,
        COALESCE(SUM(rc.amount_collected), 0) as recoveries_collected
      FROM users u
      LEFT JOIN orders o ON o.order_booker_id = u.id
      LEFT JOIN bill_recovery_assignments bra ON bra.assigned_to_booker_id = u.id
      LEFT JOIN recovery_collections rc ON rc.assignment_id = bra.id AND rc.verified_at IS NOT NULL
      WHERE u.role = 'order_booker' AND u.is_active = 1
    `;
    
    const params = [];
    if (startDate && endDate) {
      query += ` AND (o.created_at BETWEEN ? AND ? OR bra.assigned_date BETWEEN ? AND ?)`;
      params.push(startDate, endDate, startDate, endDate);
    }
    if (bookerId) {
      query += ` AND u.id = ?`;
      params.push(bookerId);
    }
    
    query += ` GROUP BY u.id ORDER BY orders_booked DESC`;
    
    return db.query(query, params);
  }

  // 4. Salesman Performance Report
  static async salesmanPerformanceReport(filters = {}) {
    const { startDate, endDate, salesmanId } = filters;
    let query = `
      SELECT 
        u.id,
        u.full_name,
        u.username,
        COUNT(DISTINCT si.id) as issuances_count,
        COALESCE(SUM(ii.cartons), 0) as total_issued_cartons,
        COALESCE(SUM(ii.loose_units), 0) as total_issued_loose,
        COUNT(DISTINCT sr.id) as returns_count,
        COALESCE(SUM(ri.returned_cartons), 0) as total_returned_cartons,
        COALESCE(SUM(ri.returned_loose), 0) as total_returned_loose,
        COALESCE(SUM(sr.final_sale_value), 0) as total_sale_value
      FROM users u
      LEFT JOIN salesman_issuances si ON si.salesman_id = u.id AND si.status = 'approved'
      LEFT JOIN issuance_items ii ON ii.issuance_id = si.id
      LEFT JOIN salesman_returns sr ON sr.salesman_id = u.id AND sr.status = 'approved'
      LEFT JOIN return_items ri ON ri.return_id = sr.id
      WHERE u.role = 'salesman' AND u.is_active = 1
    `;
    
    const params = [];
    if (startDate && endDate) {
      query += ` AND (si.created_at BETWEEN ? AND ? OR sr.created_at BETWEEN ? AND ?)`;
      params.push(startDate, endDate, startDate, endDate);
    }
    if (salesmanId) {
      query += ` AND u.id = ?`;
      params.push(salesmanId);
    }
    
    query += ` GROUP BY u.id ORDER BY total_sale_value DESC`;
    
    return db.query(query, params);
  }

  // 5. Stock Movement Report
  static async stockMovementReport(filters = {}) {
    const { startDate, endDate, productId, movementType } = filters;
    let query = `
      SELECT 
        sm.id,
        sm.created_at AS movement_date,
        sm.movement_type,
        p.sku_code,
        p.name AS product_name,
        sm.cartons_out AS cartons,
        sm.loose_out AS loose_units,
        sm.stock_after_cartons,
        sm.stock_after_loose,
        sm.reference_type,
        sm.reference_id,
        sm.note,
        u.full_name as recorded_by_name
      FROM stock_movements sm
      JOIN products p ON p.id = sm.product_id
      LEFT JOIN users u ON u.id = sm.created_by
      WHERE 1=1
    `;
    
    const params = [];
    if (startDate && endDate) {
      query += ` AND DATE(sm.created_at) BETWEEN ? AND ?`;
      params.push(startDate, endDate);
    }
    if (productId) {
      query += ` AND sm.product_id = ?`;
      params.push(productId);
    }
    if (movementType) {
      query += ` AND sm.movement_type = ?`;
      params.push(movementType);
    }
    
    query += ` ORDER BY sm.created_at DESC, sm.id DESC`;
    
    return db.query(query, params);
  }

  // 6. Stock Requirement Report (per booker)
  static async stockRequirementReport(bookerId) {
    return db.query(`
      SELECT 
        p.id,
        p.sku_code,
        p.name AS product_name,
        p.units_per_carton,
        SUM(oi.final_cartons) as total_cartons,
        SUM(oi.final_loose) as total_loose,
        p.current_stock_cartons,
        p.current_stock_loose
      FROM orders o
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p ON p.id = oi.product_id
      WHERE o.order_booker_id = ? AND o.status = 'pending'
      GROUP BY p.id
      ORDER BY p.name
    `, [bookerId]);
  }

  // 7. Shop Ledger Report
  static async shopLedgerReport(shopId) {
    const shopRows = await db.query(`SELECT * FROM shops WHERE id = ?`, [shopId]);
    const entries = await db.query(`
      SELECT 
        sle.id,
        sle.created_at AS entry_date,
        sle.entry_type,
        sle.debit,
        sle.credit,
        sle.balance_after,
        sle.reference_type,
        sle.reference_id,
        sle.note
      FROM shop_ledger_entries sle
      WHERE sle.shop_id = ?
      ORDER BY sle.created_at ASC, sle.id ASC
    `, [shopId]);
    
    return {
      shop: shopRows[0],
      entries,
      current_balance: entries.length > 0 ? entries[entries.length - 1].balance_after : 0
    };
  }

  // 8. Cash Recovery Report
  static async cashRecoveryReport(filters = {}) {
    const { startDate, endDate, bookerId, shopId } = filters;
    let query = `
      SELECT 
        bra.id,
        bra.assigned_date,
        bra.status,
        b.bill_number,
        b.bill_date,
        b.gross_amount,
        b.outstanding_amount,
        s.name AS shop_name,
        u.full_name as booker_name,
        rc.amount_collected,
        rc.payment_method,
        rc.collected_at_device AS collection_date,
        rc.verified_at,
        v.full_name as verified_by_name
      FROM bill_recovery_assignments bra
      JOIN bills b ON b.id = bra.bill_id
      JOIN shops s ON s.id = b.shop_id
      JOIN users u ON u.id = bra.assigned_to_booker_id
      LEFT JOIN recovery_collections rc ON rc.assignment_id = bra.id
      LEFT JOIN users v ON v.id = rc.verified_by_admin_id
      WHERE 1=1
    `;
    
    const params = [];
    if (startDate && endDate) {
      query += ` AND bra.assigned_date BETWEEN ? AND ?`;
      params.push(startDate, endDate);
    }
    if (bookerId) {
      query += ` AND bra.assigned_to_booker_id = ?`;
      params.push(bookerId);
    }
    if (shopId) {
      query += ` AND b.shop_id = ?`;
      params.push(shopId);
    }
    
    query += ` ORDER BY bra.assigned_date DESC, bra.id DESC`;
    
    return db.query(query, params);
  }

  // 9. Supplier Advance & Stock Report
  static async supplierAdvanceReport(companyId) {
    const companyRows = await db.query(`SELECT * FROM supplier_companies WHERE id = ?`, [companyId]);
    const advances = await db.query(`
      SELECT * FROM supplier_advances 
      WHERE company_id = ? 
      ORDER BY payment_date DESC
    `, [companyId]);
    const receipts = await db.query(`
      SELECT 
        sr.id,
        sr.receipt_date,
        sr.total_value,
        COUNT(sri.id) as item_count
      FROM stock_receipts sr
      LEFT JOIN stock_receipt_items sri ON sri.receipt_id = sr.id
      WHERE sr.company_id = ?
      GROUP BY sr.id
      ORDER BY sr.receipt_date DESC
    `, [companyId]);
    const claims = await db.query(`
      SELECT 
        c.id,
        c.claim_date,
        c.claim_value,
        c.status,
        c.cleared_at,
        COUNT(ci.id) as item_count
      FROM claims c
      LEFT JOIN claim_items ci ON ci.claim_id = c.id
      WHERE c.company_id = ?
      GROUP BY c.id
      ORDER BY c.claim_date DESC
    `, [companyId]);
    
    return {
      company: companyRows[0],
      advances,
      receipts,
      claims,
      current_balance: companyRows[0]?.current_advance_balance || 0
    };
  }

  // 10. Staff Salary Report
  static async staffSalaryReport(filters = {}) {
    const { staffType, staffId, month, year } = filters;
    let query = `
      SELECT 
        sr.id,
        sr.staff_id,
        sr.staff_type,
        sr.month,
        sr.year,
        sr.basic_salary,
        sr.total_advances_paid,
        (sr.basic_salary - sr.total_advances_paid) AS running_balance,
        sr.cleared_at,
        CASE 
          WHEN sr.staff_type = 'salesman' THEN (SELECT full_name FROM users WHERE id = sr.staff_id AND role = 'salesman')
          WHEN sr.staff_type = 'order_booker' THEN (SELECT full_name FROM users WHERE id = sr.staff_id AND role = 'order_booker')
          WHEN sr.staff_type = 'delivery_man' THEN (SELECT full_name FROM delivery_men WHERE id = sr.staff_id)
        END as staff_name
      FROM salary_records sr
      WHERE 1=1
    `;
    
    const params = [];
    if (staffType) {
      query += ` AND sr.staff_type = ?`;
      params.push(staffType);
    }
    if (staffId) {
      query += ` AND sr.staff_id = ?`;
      params.push(staffId);
    }
    if (month) {
      query += ` AND sr.month = ?`;
      params.push(month);
    }
    if (year) {
      query += ` AND sr.year = ?`;
      params.push(year);
    }
    
    query += ` ORDER BY sr.year DESC, sr.month DESC`;
    
    return db.query(query, params);
  }

  // 11. Claims Report
  static async claimsReport(companyId) {
    const companyRows = await db.query(`SELECT * FROM supplier_companies WHERE id = ?`, [companyId]);
    const claims = await db.query(`
      SELECT 
        c.id,
        c.claim_date,
        c.claim_value,
        c.reason,
        c.status,
        c.cleared_at,
        u.full_name as recorded_by_name,
        GROUP_CONCAT(
          CONCAT(p.name, ' (', ci.cartons, ' cartons, ', ci.loose_units, ' loose)')
          SEPARATOR '; '
        ) as products
      FROM claims c
      LEFT JOIN claim_items ci ON ci.claim_id = c.id
      LEFT JOIN products p ON p.id = ci.product_id
      LEFT JOIN users u ON u.id = c.recorded_by
      WHERE c.company_id = ?
      GROUP BY c.id
      ORDER BY c.claim_date DESC
    `, [companyId]);
    
    return {
      company: companyRows[0],
      claims
    };
  }

  // 12. Centralized Cash Flow Report
  static async cashFlowReport(filters = {}) {
    const { startDate, endDate, view = 'daily' } = filters;
    
    let query, groupBy;
    if (view === 'monthly') {
      query = `
        SELECT 
          YEAR(cash_date) as year,
          MONTH(cash_date) as month,
          entry_type,
          SUM(amount) as total_amount,
          COUNT(*) as entry_count
        FROM centralized_cash_entries
        WHERE 1=1
      `;
      groupBy = ` GROUP BY YEAR(cash_date), MONTH(cash_date), entry_type ORDER BY year DESC, month DESC, entry_type`;
    } else {
      query = `
        SELECT 
          cash_date,
          entry_type,
          SUM(amount) as total_amount,
          COUNT(*) as entry_count
        FROM centralized_cash_entries
        WHERE 1=1
      `;
      groupBy = ` GROUP BY cash_date, entry_type ORDER BY cash_date DESC, entry_type`;
    }
    
    const params = [];
    if (startDate && endDate) {
      query += ` AND cash_date BETWEEN ? AND ?`;
      params.push(startDate, endDate);
    }
    
    query += groupBy;
    
    return db.query(query, params);
  }
}

module.exports = ReportService;
