'use strict';

/**
 * Format a single bill into CBL Salesflo-style HTML for printing.
 * Updated to print 2 bills per A4 page (bill duplicated twice on same page)
 */
function formatBillForPrint(bill) {
  const items = bill.items || [];
  const itemRows = items.map(item => {
    const units = item.cartons * item.units_per_carton + item.loose_units;
    return `
      <tr>
        <td>${item.sku_code}</td>
        <td>${item.product_name}</td>
        <td>${item.cartons}</td>
        <td>${item.loose_units}</td>
        <td>${units}</td>
        <td>Rs ${Number(item.unit_price).toFixed(2)}</td>
        <td>Rs ${Number(item.line_total).toFixed(2)}</td>
      </tr>`;
  }).join('');

  const billDate = new Date(bill.bill_date);
  const formattedDate = billDate.toLocaleDateString('en-GB', {
    day: 'numeric', month: 'long', year: 'numeric'
  }) + '/' + billDate.toLocaleDateString('en-US', { weekday: 'long' });

  // Create bill HTML template
  const billTemplate = `
  <div class="bill-half">
    <div class="header">
      <div class="header-left">
        <div class="company-name">${bill.company_name || 'Shakeel Traders'}</div>
        <div class="company-info">
          <div>${bill.company_address || ''}</div>
          <div><strong>N.T.N No:</strong> ${bill.gst_ntn || 'Not Available'}</div>
          <div><strong>Sales Tax #:</strong> ${bill.sales_tax || 'Not Available'}</div>
          <div><strong>CNIC #:</strong> ${bill.cnic || 'Not Available'}</div>
          <div><strong>M/S:</strong> ${bill.shop_name || ''}</div>
          <div><strong>Address:</strong> ${bill.shop_address || 'Not Available'}</div>
        </div>
      </div>
      <div class="header-right">
        <div class="invoice-title">CASH MEMO / INVOICE</div>
        <div class="invoice-meta">
          <div><strong>Invoice No #:</strong> ${bill.bill_number}</div>
          <div><strong>Date/Day:</strong> ${formattedDate}</div>
          <div><strong>Route:</strong> ${bill.route_name || 'Not Available'}</div>
          <div style="margin-top:4px;"><strong>Sales Tax No:</strong> Not Available</div>
          <div><strong>N.T.N No:</strong> Not Available</div>
        </div>
      </div>
    </div>
    <table>
      <thead>
        <tr><th>SKU</th><th>Product</th><th>Cartons</th><th>Loose</th><th>Units</th><th>Rate</th><th>Amount</th></tr>
      </thead>
      <tbody>${itemRows}</tbody>
    </table>
    <div class="totals">
      <table>
        <tr><td>Gross Amount</td><td style="text-align:right;">Rs ${Number(bill.gross_amount).toFixed(2)}</td></tr>
        ${bill.advance_deducted > 0 ? `<tr><td>Advance Deducted</td><td style="text-align:right;color:#10B981;">- Rs ${Number(bill.advance_deducted).toFixed(2)}</td></tr>` : ''}
        <tr class="total-row"><td>Net Amount</td><td style="text-align:right;">Rs ${Number(bill.net_amount).toFixed(2)}</td></tr>
        <tr><td>Amount Paid</td><td style="text-align:right;color:#10B981;">Rs ${Number(bill.amount_paid).toFixed(2)}</td></tr>
        <tr><td style="color:#EF4444;">Outstanding</td><td style="text-align:right;color:#EF4444;font-weight:700;">Rs ${Number(bill.outstanding_amount).toFixed(2)}</td></tr>
      </table>
    </div>
  </div>`;

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Bill ${bill.bill_number}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Manrope:wght@700;800&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Inter', sans-serif; font-size: 10px; color: #1E293B; }
    
    /* Print buttons - hide when printing */
    .print-actions {
      position: fixed;
      top: 20px;
      right: 20px;
      display: flex;
      gap: 10px;
      z-index: 1000;
    }
    .btn {
      padding: 10px 20px;
      border: none;
      border-radius: 6px;
      font-family: 'Inter', sans-serif;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: all 0.2s;
    }
    .btn-primary {
      background: #3B82F6;
      color: white;
    }
    .btn-primary:hover {
      background: #2563EB;
    }
    .btn-secondary {
      background: #F1F5F9;
      color: #334155;
      border: 1px solid #CBD5E1;
    }
    .btn-secondary:hover {
      background: #E2E8F0;
    }
    
    /* Each bill takes half page with border */
    .bill-half {
      height: 48vh;
      padding: 12px 16px;
      border: 1px dashed #CBD5E1;
      position: relative;
    }
    
    /* Scissors icon between bills */
    .bill-half:first-child::after {
      content: "✂";
      position: absolute;
      bottom: -12px;
      left: 50%;
      transform: translateX(-50%);
      font-size: 16px;
      color: #94A3B8;
      background: white;
      padding: 0 8px;
    }
    
    .header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px; border-bottom: 2px solid #1E293B; padding-bottom: 6px; }
    .header-left { flex: 1; }
    .company-name { font-family: 'Manrope', sans-serif; font-weight: 800; font-size: 14px; margin-bottom: 2px; text-decoration: underline; }
    .company-info { font-size: 8px; line-height: 1.4; color: #1E293B; }
    .company-info div { margin-bottom: 0px; }
    .header-right { text-align: right; flex-shrink: 0; }
    .invoice-title { font-family: 'Manrope', sans-serif; font-weight: 800; font-size: 12px; margin-bottom: 3px; }
    .invoice-meta { font-size: 8px; line-height: 1.5; }
    .invoice-meta div { margin-bottom: 1px; }
    .invoice-meta strong { font-weight: 700; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 8px; margin-top: 8px; }
    th { background: #1E293B; color: #fff; padding: 4px 6px; font-size: 8px; text-transform: uppercase; letter-spacing: 0.05em; text-align: left; }
    td { padding: 3px 6px; border-bottom: 1px solid #E2E8F0; font-size: 8px; }
    tr:last-child td { border-bottom: none; }
    .totals { margin-left: auto; width: 200px; }
    .totals table { margin: 0; }
    .totals td { padding: 2px 6px; font-size: 8px; }
    .totals .total-row td { font-weight: 700; font-size: 9px; border-top: 2px solid #1E293B; }
    
    @media print { 
      body { padding: 0; }
      .bill-half { page-break-inside: avoid; }
      .bill-half:first-child::after { display: block; }
      .print-actions { display: none !important; }
    }
  </style>
</head>
<body>
  <div class="print-actions">
    <button class="btn btn-secondary" onclick="window.print()">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <polyline points="6 9 6 2 18 2 18 9"></polyline>
        <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path>
        <rect x="6" y="14" width="12" height="8"></rect>
      </svg>
      Print
    </button>
    <button class="btn btn-primary" onclick="downloadPDF()">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
        <polyline points="7 10 12 15 17 10"></polyline>
        <line x1="12" y1="15" x2="12" y2="3"></line>
      </svg>
      Download PDF
    </button>
  </div>
  ${billTemplate}
  ${billTemplate}
  <script>
    function downloadPDF() {
      window.print();
    }
  </script>
</body>
</html>`;
}

/**
 * Format multiple bills — TWO per page — plus a stock summary page at the end.
 */
function formatMultiBillPrint(bills) {

  function billHalf(bill) {
    const items = bill.items || [];
    const itemRows = items.map(item => {
      const units = (item.cartons * item.units_per_carton) + item.loose_units;
      return `<tr>
        <td>${item.sku_code || ''}</td>
        <td>${item.product_name || ''}</td>
        <td>${item.cartons || 0}</td>
        <td>${item.loose_units || 0}</td>
        <td>${units}</td>
        <td>Rs ${Number(item.unit_price || 0).toFixed(2)}</td>
        <td class="tar">Rs ${Number(item.line_total || 0).toFixed(2)}</td>
      </tr>`;
    }).join('');

    const billDate = new Date(bill.bill_date);
    const formattedDate = billDate.toLocaleDateString('en-GB', {
      day: 'numeric', month: 'long', year: 'numeric'
    }) + '/' + billDate.toLocaleDateString('en-US', { weekday: 'long' });

    return `<div class="bill-half">
      <div class="bh">
        <div class="bh-left">
          <div class="co-name">${bill.company_name || 'Shakeel Traders'}</div>
          <div class="co-info">
            <div>${bill.company_address || ''}</div>
            <div><b>N.T.N No:</b> ${bill.gst_ntn || 'Not Available'}</div>
            <div><b>Sales Tax #:</b> ${bill.sales_tax || 'Not Available'}</div>
            <div><b>CNIC #:</b> ${bill.cnic || 'Not Available'}</div>
            <div><b>M/S:</b> ${bill.shop_name || ''}</div>
            <div><b>Address:</b> ${bill.shop_address || 'Not Available'}</div>
          </div>
        </div>
        <div class="bh-right">
          <div class="inv-title">CASH MEMO / INVOICE</div>
          <div class="inv-meta">
            <div><b>Invoice No #:</b> ${bill.bill_number}</div>
            <div><b>Date/Day:</b> ${formattedDate}</div>
            <div><b>Route:</b> ${bill.route_name || 'Not Available'}</div>
            <div style="margin-top:3px;"><b>Sales Tax No:</b> Not Available</div>
            <div><b>N.T.N No:</b> Not Available</div>
          </div>
        </div>
      </div>
      <table>
        <thead><tr><th>SKU</th><th>Product</th><th>Cartons</th><th>Loose</th><th>Units</th><th>Rate</th><th>Amount</th></tr></thead>
        <tbody>${itemRows}</tbody>
      </table>
      <div class="totals">
        <table>
          <tr><td>Gross Amount</td><td class="tar">Rs ${Number(bill.gross_amount || 0).toFixed(2)}</td></tr>
          ${bill.advance_deducted > 0 ? `<tr><td>Advance Deducted</td><td class="tar" style="color:#10B981;">- Rs ${Number(bill.advance_deducted).toFixed(2)}</td></tr>` : ''}
          <tr class="net-row"><td>Net Amount</td><td class="tar">Rs ${Number(bill.net_amount || 0).toFixed(2)}</td></tr>
          <tr><td>Amount Paid</td><td class="tar" style="color:#10B981;">Rs ${Number(bill.amount_paid || 0).toFixed(2)}</td></tr>
          <tr class="out-row"><td>Outstanding</td><td class="tar">Rs ${Number(bill.outstanding_amount || 0).toFixed(2)}</td></tr>
        </table>
      </div>
    </div>`;
  }

  // Group bills into pairs (2 per page)
  const pages = [];
  for (let i = 0; i < bills.length; i += 2) {
    const bill1 = billHalf(bills[i]);
    const bill2 = i + 1 < bills.length ? billHalf(bills[i + 1]) : ''; // If odd number, second half empty
    
    pages.push(`<div class="page">
      ${bill1}
      ${bill2 ? `<div class="separator"></div>${bill2}` : ''}
    </div>`);
  }

  // Build consolidated stock summary
  const stockMap = {};
  for (const bill of bills) {
    for (const item of (bill.items || [])) {
      const key = item.sku_code || String(item.product_id);
      if (!stockMap[key]) {
        stockMap[key] = {
          sku_code: item.sku_code || '',
          product_name: item.product_name || '',
          units_per_carton: item.units_per_carton || 1,
          total_cartons: 0,
          total_loose: 0,
        };
      }
      stockMap[key].total_cartons += parseInt(item.cartons || 0);
      stockMap[key].total_loose   += parseInt(item.loose_units || 0);
    }
  }

  const stockRows = Object.values(stockMap)
    .sort((a, b) => a.product_name.localeCompare(b.product_name))
    .map(p => {
      const totalUnits = p.total_cartons * p.units_per_carton + p.total_loose;
      return `<tr>
        <td>${p.sku_code}</td>
        <td>${p.product_name}</td>
        <td class="tar">${p.total_cartons}</td>
        <td class="tar">${p.total_loose}</td>
        <td class="tar">${totalUnits}</td>
      </tr>`;
    }).join('');

  const printDate = new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });

  const summaryPage = `<div class="page summary-page">
    <div class="bh">
      <div class="bh-left"><div class="co-name">Shakeel Traders</div></div>
      <div class="bh-right"><div class="inv-title">STOCK REQUIREMENT SUMMARY</div></div>
    </div>
    <div style="font-size:9px;color:#64748B;margin:8px 0;">
      Bills selected: <b>${bills.length}</b> &nbsp;|&nbsp; Printed: <b>${printDate}</b>
    </div>
    <table>
      <thead>
        <tr>
          <th>SKU</th><th>Product</th>
          <th class="tar">Total Cartons</th>
          <th class="tar">Total Loose</th>
          <th class="tar">Total Units</th>
        </tr>
      </thead>
      <tbody>${stockRows}</tbody>
    </table>
  </div>`;

  const billPages = pages.join('');

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Open Bills Print</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Manrope:wght@700;800&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Inter', sans-serif; font-size: 9px; color: #1E293B; }
    
    /* Print buttons - hide when printing */
    .print-actions {
      position: fixed;
      top: 20px;
      right: 20px;
      display: flex;
      gap: 10px;
      z-index: 1000;
    }
    .btn {
      padding: 10px 20px;
      border: none;
      border-radius: 6px;
      font-family: 'Inter', sans-serif;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: all 0.2s;
    }
    .btn-primary {
      background: #3B82F6;
      color: white;
    }
    .btn-primary:hover {
      background: #2563EB;
    }
    .btn-secondary {
      background: #F1F5F9;
      color: #334155;
      border: 1px solid #CBD5E1;
    }
    .btn-secondary:hover {
      background: #E2E8F0;
    }
    
    /* Page layout - holds 2 bills */
    .page { page-break-after: always; padding: 12px; }
    .page:last-child { page-break-after: auto; }
    
    /* Each bill takes half page */
    .bill-half {
      height: 48vh;
      padding: 12px;
      border: 1px dashed #CBD5E1;
      position: relative;
    }
    
    /* Separator with scissors between bills */
    .separator {
      height: 20px;
      text-align: center;
      position: relative;
    }
    .separator::after {
      content: "✂ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -";
      font-size: 12px;
      color: #94A3B8;
      letter-spacing: 2px;
    }
    
    .bh { display: flex; justify-content: space-between; border-bottom: 2px solid #1E293B; padding-bottom: 6px; margin-bottom: 6px; }
    .bh-left { flex: 1; padding-right: 8px; }
    .co-name { font-family: 'Manrope', sans-serif; font-weight: 800; font-size: 13px; text-decoration: underline; margin-bottom: 2px; }
    .co-info { font-size: 7.5px; line-height: 1.4; }
    .bh-right { text-align: right; flex-shrink: 0; }
    .inv-title { font-family: 'Manrope', sans-serif; font-weight: 800; font-size: 11px; margin-bottom: 2px; }
    .inv-meta { font-size: 7.5px; line-height: 1.5; }
    table { width: 100%; border-collapse: collapse; margin: 6px 0; }
    th { background: #1E293B; color: #fff; padding: 4px 5px; font-size: 7.5px; text-transform: uppercase; letter-spacing: 0.04em; text-align: left; }
    td { padding: 3px 5px; border-bottom: 1px solid #E2E8F0; font-size: 7.5px; }
    tr:last-child td { border-bottom: none; }
    .tar { text-align: right; }
    .totals { margin-left: auto; width: 180px; margin-top: 4px; }
    .totals table { margin: 0; }
    .totals td { padding: 2px 5px; font-size: 7.5px; }
    .net-row td { font-weight: 700; border-top: 2px solid #1E293B; }
    .out-row td { font-weight: 700; color: #EF4444; }
    
    /* Summary page - full page */
    .summary-page {
      height: auto;
      padding: 20px 24px;
    }
    .summary-page .bh { padding-bottom: 10px; margin-bottom: 12px; }
    .summary-page .co-name { font-size: 16px; }
    .summary-page .inv-title { font-size: 14px; }
    .summary-page table { margin: 12px 0; }
    .summary-page th { padding: 6px 8px; font-size: 9px; }
    .summary-page td { padding: 5px 8px; font-size: 9px; }
    
    @media print { 
      @page { size: A4; margin: 10mm; } 
      body { margin: 0; }
      .page { padding: 0; }
      .bill-half { page-break-inside: avoid; }
      .separator { page-break-inside: avoid; }
      .print-actions { display: none !important; }
    }
  </style>
</head>
<body>
  <div class="print-actions">
    <button class="btn btn-secondary" onclick="window.print()">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <polyline points="6 9 6 2 18 2 18 9"></polyline>
        <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path>
        <rect x="6" y="14" width="12" height="8"></rect>
      </svg>
      Print
    </button>
    <button class="btn btn-primary" onclick="downloadPDF()">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
        <polyline points="7 10 12 15 17 10"></polyline>
        <line x1="12" y1="15" x2="12" y2="3"></line>
      </svg>
      Download PDF
    </button>
  </div>
  ${billPages}
  ${summaryPage}
  <script>
    function downloadPDF() {
      window.print();
    }
  </script>
</body>
</html>`;
}

module.exports = { formatBillForPrint, formatMultiBillPrint };
