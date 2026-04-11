const ReportService = require('../services/ReportService');
const ExcelExporter = require('../utils/excelExport');
const { renderWithLayout } = require('../utils/render');
const { query } = require('../config/db');

class ReportController {
  // Reports index page
  static async index(req, res) {
    try {
      const [shops, suppliers, bookers] = await Promise.all([
        query('SELECT id, name FROM shops WHERE is_active = 1 ORDER BY name ASC'),
        query('SELECT id, name FROM supplier_companies WHERE is_active = 1 ORDER BY name ASC'),
        query("SELECT id, full_name FROM users WHERE role = 'order_booker' AND is_active = 1 ORDER BY full_name ASC"),
      ]);
      renderWithLayout(req, res, 'reports/index', {
        title: 'Reports',
        shops,
        suppliers,
        bookers,
      });
    } catch (error) {
      console.error('Error loading reports page:', error);
      req.flash('error', 'Failed to load reports page');
      res.redirect('/dashboard');
    }
  }

  // 1. Daily Sales Report
  static async dailySalesReport(req, res) {
    try {
      const { date, export: exportExcel } = req.query;
      const reportDate = date || new Date().toISOString().split('T')[0];
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      
      const data = await ReportService.dailySalesReport(reportDate);
      
      if (exportExcel === 'excel') {
        const columns = [
          { header: 'Sales Channel', key: 'channel', width: 20 },
          { header: 'Bill Count', key: 'bill_count', type: 'number', width: 15 },
          { header: 'Gross Amount', key: 'gross_amount', type: 'currency', width: 18 },
          { header: 'Advance Deducted', key: 'advance_deducted', type: 'currency', width: 18 },
          { header: 'Net Amount', key: 'net_amount', type: 'currency', width: 18 },
          { header: 'Amount Paid', key: 'amount_paid', type: 'currency', width: 18 },
          { header: 'Outstanding', key: 'outstanding_amount', type: 'currency', width: 18 }
        ];
        
        const reportData = [
          { channel: 'Order Booker Sales', ...data.order_booker },
          { channel: 'Salesman Sales', ...data.salesman },
          { channel: 'Direct Shop Sales', ...data.direct_shop }
        ];
        
        const buffer = await ExcelExporter.exportToExcel(
          reportData,
          columns,
          'Daily Sales Report',
          { reportTitle: `Daily Sales Report - ${reportDate}` }
        );
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=daily-sales-${reportDate}.xlsx`);
        return res.send(buffer);
      }
      
      // Pagination for bills list (if data.bills exists)
      let paginatedData = data;
      let pagination = null;
      if (data.bills && Array.isArray(data.bills)) {
        const total = data.bills.length;
        paginatedData = { ...data, bills: data.bills.slice((page - 1) * limit, page * limit) };
        pagination = { page, limit, total, pages: Math.ceil(total / limit) };
      }
      
      renderWithLayout(req, res, 'reports/daily-sales', {
        title: 'Daily Sales Report',
        data: paginatedData,
        reportDate,
        pagination
      });
    } catch (error) {
      console.error('Error generating daily sales report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }

  // 2. Monthly Sales Report
  static async monthlySalesReport(req, res) {
    try {
      const { month, year, export: exportExcel } = req.query;
      const reportMonth = month || new Date().getMonth() + 1;
      const reportYear = year || new Date().getFullYear();
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      
      const data = await ReportService.monthlySalesReport(reportMonth, reportYear);
      
      if (exportExcel === 'excel') {
        const columns = [
          { header: 'Sales Channel', key: 'channel', width: 20 },
          { header: 'Bill Count', key: 'bill_count', type: 'number', width: 15 },
          { header: 'Gross Amount', key: 'gross_amount', type: 'currency', width: 18 },
          { header: 'Advance Deducted', key: 'advance_deducted', type: 'currency', width: 18 },
          { header: 'Net Amount', key: 'net_amount', type: 'currency', width: 18 },
          { header: 'Amount Paid', key: 'amount_paid', type: 'currency', width: 18 },
          { header: 'Outstanding', key: 'outstanding_amount', type: 'currency', width: 18 }
        ];
        
        const reportData = [
          { channel: 'Order Booker Sales', ...data.order_booker },
          { channel: 'Salesman Sales', ...data.salesman },
          { channel: 'Direct Shop Sales', ...data.direct_shop }
        ];
        
        const buffer = await ExcelExporter.exportToExcel(
          reportData,
          columns,
          'Monthly Sales Report',
          { reportTitle: `Monthly Sales Report - ${reportMonth}/${reportYear}` }
        );
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=monthly-sales-${reportMonth}-${reportYear}.xlsx`);
        return res.send(buffer);
      }
      
      // Pagination for bills list (if data.bills exists)
      let paginatedData = data;
      let pagination = null;
      if (data.bills && Array.isArray(data.bills)) {
        const total = data.bills.length;
        paginatedData = { ...data, bills: data.bills.slice((page - 1) * limit, page * limit) };
        pagination = { page, limit, total, pages: Math.ceil(total / limit) };
      }
      
      renderWithLayout(req, res, 'reports/monthly-sales', {
        title: 'Monthly Sales Report',
        data: paginatedData,
        reportMonth,
        reportYear,
        pagination
      });
    } catch (error) {
      console.error('Error generating monthly sales report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }

  // 3. Order Booker Performance Report
  static async orderBookerPerformance(req, res) {
    try {
      const { startDate, endDate, bookerId, export: exportExcel } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      
      const allData = await ReportService.orderBookerPerformanceReport({
        startDate,
        endDate,
        bookerId
      });
      
      if (exportExcel === 'excel') {
        const columns = [
          { header: 'Booker Name', key: 'full_name', width: 25 },
          { header: 'Username', key: 'username', width: 20 },
          { header: 'Orders Booked', key: 'orders_booked', type: 'number', width: 15 },
          { header: 'Bills Converted', key: 'bills_converted', type: 'number', width: 15 },
          { header: 'Recovery Bills Assigned', key: 'recovery_bills_assigned', type: 'number', width: 20 },
          { header: 'Recoveries Collected', key: 'recoveries_collected', type: 'currency', width: 20 }
        ];
        
        const buffer = await ExcelExporter.exportToExcel(
          allData,
          columns,
          'Order Booker Performance',
          { reportTitle: 'Order Booker Performance Report' }
        );
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=order-booker-performance.xlsx');
        return res.send(buffer);
      }
      
      const total = allData.length;
      const data = allData.slice((page - 1) * limit, page * limit);
      
      renderWithLayout(req, res, 'reports/order-booker-performance', {
        title: 'Order Booker Performance',
        data,
        filters: { startDate, endDate, bookerId },
        pagination: { page, limit, total, pages: Math.ceil(total / limit) }
      });
    } catch (error) {
      console.error('Error generating order booker performance report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }

  // 4. Salesman Performance Report
  static async salesmanPerformance(req, res) {
    try {
      const { startDate, endDate, salesmanId, export: exportExcel } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      
      const allData = await ReportService.salesmanPerformanceReport({
        startDate,
        endDate,
        salesmanId
      });
      
      if (exportExcel === 'excel') {
        const columns = [
          { header: 'Salesman Name', key: 'full_name', width: 25 },
          { header: 'Username', key: 'username', width: 20 },
          { header: 'Issuances', key: 'issuances_count', type: 'number', width: 12 },
          { header: 'Issued Cartons', key: 'total_issued_cartons', type: 'number', width: 15 },
          { header: 'Issued Loose', key: 'total_issued_loose', type: 'number', width: 15 },
          { header: 'Returns', key: 'returns_count', type: 'number', width: 12 },
          { header: 'Returned Cartons', key: 'total_returned_cartons', type: 'number', width: 15 },
          { header: 'Returned Loose', key: 'total_returned_loose', type: 'number', width: 15 },
          { header: 'Total Sale Value', key: 'total_sale_value', type: 'currency', width: 20 }
        ];
        
        const buffer = await ExcelExporter.exportToExcel(
          allData,
          columns,
          'Salesman Performance',
          { reportTitle: 'Salesman Performance Report' }
        );
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=salesman-performance.xlsx');
        return res.send(buffer);
      }
      
      const total = allData.length;
      const data = allData.slice((page - 1) * limit, page * limit);
      
      renderWithLayout(req, res, 'reports/salesman-performance', {
        title: 'Salesman Performance',
        data,
        filters: { startDate, endDate, salesmanId },
        pagination: { page, limit, total, pages: Math.ceil(total / limit) }
      });
    } catch (error) {
      console.error('Error generating salesman performance report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }

  // 5. Stock Movement Report
  static async stockMovement(req, res) {
    try {
      const { startDate, endDate, productId, movementType, export: exportExcel } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = 25;

      const allData = await ReportService.stockMovementReport({ startDate, endDate, productId, movementType });

      if (exportExcel === 'excel') {
        const columns = [
          { header: 'Date', key: 'movement_date', type: 'date', width: 15 },
          { header: 'Type', key: 'movement_type', width: 20 },
          { header: 'SKU', key: 'sku_code', width: 15 },
          { header: 'Product', key: 'product_name', width: 25 },
          { header: 'Cartons', key: 'cartons', type: 'number', width: 12 },
          { header: 'Loose', key: 'loose_units', type: 'number', width: 12 },
          { header: 'Stock After (Cartons)', key: 'stock_after_cartons', type: 'number', width: 18 },
          { header: 'Stock After (Loose)', key: 'stock_after_loose', type: 'number', width: 18 },
          { header: 'Recorded By', key: 'recorded_by_name', width: 20 },
          { header: 'Note', key: 'note', width: 30 }
        ];
        
        const buffer = await ExcelExporter.exportToExcel(
          allData,
          columns,
          'Stock Movement Report',
          { reportTitle: 'Stock Movement Report' }
        );
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=stock-movement.xlsx');
        return res.send(buffer);
      }
      
      const total = allData.length;
      const data = allData.slice((page - 1) * limit, page * limit);
      renderWithLayout(req, res, 'reports/stock-movement', {
        title: 'Stock Movement Report',
        data,
        filters: { startDate, endDate, productId, movementType },
        pagination: { page, limit, total, pages: Math.ceil(total / limit) },
      });
    } catch (error) {
      console.error('Error generating stock movement report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }

  // 6. Stock Requirement Report
  static async stockRequirement(req, res) {
    try {
      const { bookerId, export: exportExcel } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      
      if (!bookerId) {
        req.flash('error', 'Please select an order booker');
        return res.redirect('/reports');
      }
      
      const allData = await ReportService.stockRequirementReport(bookerId);
      
      if (exportExcel === 'excel') {
        const columns = [
          { header: 'SKU', key: 'sku_code', width: 15 },
          { header: 'Product Name', key: 'product_name', width: 30 },
          { header: 'Units per Carton', key: 'units_per_carton', type: 'number', width: 15 },
          { header: 'Required Cartons', key: 'total_cartons', type: 'number', width: 15 },
          { header: 'Required Loose', key: 'total_loose', type: 'number', width: 15 },
          { header: 'Current Stock (Cartons)', key: 'current_stock_cartons', type: 'number', width: 20 },
          { header: 'Current Stock (Loose)', key: 'current_stock_loose', type: 'number', width: 20 }
        ];
        
        const buffer = await ExcelExporter.exportToExcel(
          allData,
          columns,
          'Stock Requirement Report',
          { reportTitle: 'Stock Requirement Report' }
        );
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=stock-requirement.xlsx');
        return res.send(buffer);
      }
      
      const total = allData.length;
      const data = allData.slice((page - 1) * limit, page * limit);
      
      renderWithLayout(req, res, 'reports/stock-requirement', {
        title: 'Stock Requirement Report',
        data,
        bookerId,
        pagination: { page, limit, total, pages: Math.ceil(total / limit) }
      });
    } catch (error) {
      console.error('Error generating stock requirement report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }

  // 7. Shop Ledger Report
  static async shopLedger(req, res) {
    try {
      const { shopId, export: exportExcel } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      
      if (!shopId) {
        // Render with noSelection flag instead of redirect
        return renderWithLayout(req, res, 'reports/shop-ledger', {
          title: 'Shop Ledger Report',
          data: null,
          noSelection: true,
          pagination: null
        });
      }
      
      const data = await ReportService.shopLedgerReport(shopId);
      
      if (exportExcel === 'excel') {
        const columns = [
          { header: 'Date', key: 'entry_date', type: 'date', width: 15 },
          { header: 'Entry Type', key: 'entry_type', width: 20 },
          { header: 'Debit', key: 'debit', type: 'currency', width: 15 },
          { header: 'Credit', key: 'credit', type: 'currency', width: 15 },
          { header: 'Balance', key: 'balance_after', type: 'currency', width: 15 },
          { header: 'Reference Type', key: 'reference_type', width: 20 },
          { header: 'Note', key: 'note', width: 30 }
        ];
        
        const buffer = await ExcelExporter.exportToExcel(
          data.entries,
          columns,
          'Shop Ledger Report',
          { reportTitle: `Shop Ledger Report - ${data.shop.name}` }
        );
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=shop-ledger-${shopId}.xlsx`);
        return res.send(buffer);
      }
      
      // Pagination for entries
      const total = data.entries.length;
      const paginatedEntries = data.entries.slice((page - 1) * limit, page * limit);
      const paginatedData = { ...data, entries: paginatedEntries };
      
      renderWithLayout(req, res, 'reports/shop-ledger', {
        title: 'Shop Ledger Report',
        data: paginatedData,
        noSelection: false,
        pagination: { page, limit, total, pages: Math.ceil(total / limit) }
      });
    } catch (error) {
      console.error('Error generating shop ledger report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }

  // 8. Cash Recovery Report
  static async cashRecovery(req, res) {
    try {
      const { startDate, endDate, bookerId, shopId, export: exportExcel } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      
      const allData = await ReportService.cashRecoveryReport({
        startDate,
        endDate,
        bookerId,
        shopId
      });
      
      if (exportExcel === 'excel') {
        const columns = [
          { header: 'Assigned Date', key: 'assigned_date', type: 'date', width: 15 },
          { header: 'Bill Number', key: 'bill_number', width: 20 },
          { header: 'Bill Date', key: 'bill_date', type: 'date', width: 15 },
          { header: 'Shop', key: 'shop_name', width: 25 },
          { header: 'Booker', key: 'booker_name', width: 20 },
          { header: 'Bill Amount', key: 'gross_amount', type: 'currency', width: 15 },
          { header: 'Outstanding', key: 'outstanding_amount', type: 'currency', width: 15 },
          { header: 'Collected', key: 'amount_collected', type: 'currency', width: 15 },
          { header: 'Payment Method', key: 'payment_method', width: 15 },
          { header: 'Status', key: 'status', width: 15 },
          { header: 'Verified By', key: 'verified_by_name', width: 20 }
        ];
        
        const buffer = await ExcelExporter.exportToExcel(
          allData,
          columns,
          'Cash Recovery Report',
          { reportTitle: 'Cash Recovery Report' }
        );
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=cash-recovery.xlsx');
        return res.send(buffer);
      }
      
      const total = allData.length;
      const data = allData.slice((page - 1) * limit, page * limit);
      
      renderWithLayout(req, res, 'reports/cash-recovery', {
        title: 'Cash Recovery Report',
        data,
        filters: { startDate, endDate, bookerId, shopId },
        pagination: { page, limit, total, pages: Math.ceil(total / limit) }
      });
    } catch (error) {
      console.error('Error generating cash recovery report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }

  // 9. Supplier Advance Report
  static async supplierAdvance(req, res) {
    try {
      const { companyId, export: exportExcel } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      
      if (!companyId) {
        // Render with noSelection flag instead of redirect
        return renderWithLayout(req, res, 'reports/supplier-advance', {
          title: 'Supplier Advance Report',
          data: null,
          noSelection: true,
          pagination: null
        });
      }
      
      const data = await ReportService.supplierAdvanceReport(companyId);
      
      if (exportExcel === 'excel') {
        // Create workbook with multiple sheets
        const ExcelJS = require('exceljs');
        const workbook = new ExcelJS.Workbook();
        
        // Advances sheet
        const advancesSheet = workbook.addWorksheet('Advances');
        advancesSheet.columns = [
          { header: 'Date', key: 'advance_date', width: 15 },
          { header: 'Amount', key: 'amount', width: 15 },
          { header: 'Payment Method', key: 'payment_method', width: 15 },
          { header: 'Note', key: 'note', width: 30 }
        ];
        data.advances.forEach(adv => advancesSheet.addRow(adv));
        
        // Receipts sheet
        const receiptsSheet = workbook.addWorksheet('Stock Receipts');
        receiptsSheet.columns = [
          { header: 'Date', key: 'receipt_date', width: 15 },
          { header: 'Total Value', key: 'total_value', width: 15 },
          { header: 'Item Count', key: 'item_count', width: 15 }
        ];
        data.receipts.forEach(rec => receiptsSheet.addRow(rec));
        
        // Claims sheet
        const claimsSheet = workbook.addWorksheet('Claims');
        claimsSheet.columns = [
          { header: 'Date', key: 'claim_date', width: 15 },
          { header: 'Value', key: 'claim_value', width: 15 },
          { header: 'Status', key: 'status', width: 15 },
          { header: 'Cleared At', key: 'cleared_at', width: 15 },
          { header: 'Item Count', key: 'item_count', width: 15 }
        ];
        data.claims.forEach(claim => claimsSheet.addRow(claim));
        
        const buffer = await workbook.xlsx.writeBuffer();
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=supplier-advance-${companyId}.xlsx`);
        return res.send(buffer);
      }
      
      // Pagination for advances
      const total = data.advances.length;
      const paginatedAdvances = data.advances.slice((page - 1) * limit, page * limit);
      const paginatedData = { ...data, advances: paginatedAdvances };
      
      renderWithLayout(req, res, 'reports/supplier-advance', {
        title: 'Supplier Advance Report',
        data: paginatedData,
        pagination: { page, limit, total, pages: Math.ceil(total / limit) }
      });
    } catch (error) {
      console.error('Error generating supplier advance report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }

  // 10. Staff Salary Report
  static async staffSalary(req, res) {
    try {
      const { staffType, staffId, month, year, export: exportExcel } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      
      const allData = await ReportService.staffSalaryReport({
        staffType,
        staffId,
        month,
        year
      });
      
      if (exportExcel === 'excel') {
        const columns = [
          { header: 'Staff Name', key: 'staff_name', width: 25 },
          { header: 'Staff Type', key: 'staff_type', width: 15 },
          { header: 'Month', key: 'month', type: 'number', width: 10 },
          { header: 'Year', key: 'year', type: 'number', width: 10 },
          { header: 'Basic Salary', key: 'basic_salary', type: 'currency', width: 15 },
          { header: 'Advances Paid', key: 'total_advances_paid', type: 'currency', width: 15 },
          { header: 'Running Balance', key: 'running_balance', type: 'currency', width: 15 },
          { header: 'Clearance Date', key: 'clearance_date', type: 'date', width: 15 }
        ];
        
        const buffer = await ExcelExporter.exportToExcel(
          allData,
          columns,
          'Staff Salary Report',
          { reportTitle: 'Staff Salary Report' }
        );
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=staff-salary.xlsx');
        return res.send(buffer);
      }
      
      const total = allData.length;
      const data = allData.slice((page - 1) * limit, page * limit);
      
      renderWithLayout(req, res, 'reports/staff-salary', {
        title: 'Staff Salary Report',
        data,
        filters: { staffType, staffId, month, year },
        pagination: { page, limit, total, pages: Math.ceil(total / limit) }
      });
    } catch (error) {
      console.error('Error generating staff salary report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }

  // 11. Claims Report
  static async claims(req, res) {
    try {
      const { companyId, export: exportExcel } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      
      if (!companyId) {
        // Render with noSelection flag instead of redirect
        return renderWithLayout(req, res, 'reports/claims', {
          title: 'Claims Report',
          data: null,
          noSelection: true,
          pagination: null
        });
      }
      
      const data = await ReportService.claimsReport(companyId);
      
      if (exportExcel === 'excel') {
        const columns = [
          { header: 'Claim Date', key: 'claim_date', type: 'date', width: 15 },
          { header: 'Claim Value', key: 'claim_value', type: 'currency', width: 15 },
          { header: 'Reason', key: 'reason', width: 30 },
          { header: 'Status', key: 'status', width: 15 },
          { header: 'Cleared At', key: 'cleared_at', type: 'date', width: 15 },
          { header: 'Cleared By', key: 'cleared_by_name', width: 20 },
          { header: 'Products', key: 'products', width: 40 }
        ];
        
        const buffer = await ExcelExporter.exportToExcel(
          data.claims,
          columns,
          'Claims Report',
          { reportTitle: `Claims Report - ${data.company.company_name}` }
        );
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename=claims-${companyId}.xlsx`);
        return res.send(buffer);
      }
      
      // Pagination for claims
      const total = data.claims.length;
      const paginatedClaims = data.claims.slice((page - 1) * limit, page * limit);
      const paginatedData = { ...data, claims: paginatedClaims };
      
      renderWithLayout(req, res, 'reports/claims', {
        title: 'Claims Report',
        data: paginatedData,
        pagination: { page, limit, total, pages: Math.ceil(total / limit) }
      });
    } catch (error) {
      console.error('Error generating claims report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }

  // 12. Centralized Cash Flow Report
  static async cashFlow(req, res) {
    try {
      const { startDate, endDate, view, export: exportExcel } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = 25;
      
      const allData = await ReportService.cashFlowReport({
        startDate,
        endDate,
        view: view || 'daily'
      });
      
      if (exportExcel === 'excel') {
        const columns = view === 'monthly' ? [
          { header: 'Year', key: 'year', type: 'number', width: 10 },
          { header: 'Month', key: 'month', type: 'number', width: 10 },
          { header: 'Entry Type', key: 'entry_type', width: 25 },
          { header: 'Total Amount', key: 'total_amount', type: 'currency', width: 18 },
          { header: 'Entry Count', key: 'entry_count', type: 'number', width: 15 }
        ] : [
          { header: 'Date', key: 'cash_date', type: 'date', width: 15 },
          { header: 'Entry Type', key: 'entry_type', width: 25 },
          { header: 'Total Amount', key: 'total_amount', type: 'currency', width: 18 },
          { header: 'Entry Count', key: 'entry_count', type: 'number', width: 15 }
        ];
        
        const buffer = await ExcelExporter.exportToExcel(
          allData,
          columns,
          'Cash Flow Report',
          { reportTitle: 'Centralized Cash Flow Report' }
        );
        
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=cash-flow.xlsx');
        return res.send(buffer);
      }
      
      const total = allData.length;
      const data = allData.slice((page - 1) * limit, page * limit);
      
      renderWithLayout(req, res, 'reports/cash-flow', {
        title: 'Cash Flow Report',
        data,
        filters: { startDate, endDate, view },
        pagination: { page, limit, total, pages: Math.ceil(total / limit) }
      });
    } catch (error) {
      console.error('Error generating cash flow report:', error);
      req.flash('error', 'Failed to generate report');
      res.redirect('/reports');
    }
  }
}

module.exports = ReportController;
