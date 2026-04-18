'use strict';

/**
 * Format a bill into CBL Salesflo-style HTML for printing.
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

  // Format date as "14 April 2026/Tuesday"
  const billDate = new Date(bill.bill_date);
  const formattedDate = billDate.toLocaleDateString('en-GB', { 
    day: 'numeric', 
    month: 'long', 
    year: 'numeric'
  }) + '/' + billDate.toLocaleDateString('en-US', { weekday: 'long' });

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Bill ${bill.bill_number}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Manrope:wght@700;800&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Inter', sans-serif; font-size: 12px; color: #1E293B; padding: 20px; }
    .header { 
      display: flex; 
      justify-content: space-between; 
      align-items: flex-start; 
      margin-bottom: 20px; 
      border-bottom: 2px solid #1E293B; 
      padding-bottom: 12px; 
    }
    .header-left {
      flex: 1;
    }
    .company-name { 
      font-family: 'Manrope', sans-serif; 
      font-weight: 800; 
      font-size: 18px;
      margin-bottom: 4px;
      text-decoration: underline;
    }
    .company-info { 
      font-size: 10px; 
      line-height: 1.5;
      color: #1E293B;
    }
    .company-info div {
      margin-bottom: 1px;
    }
    .shop-section {
      margin-top: 8px;
      padding-top: 8px;
      border-top: 1px solid #CBD5E1;
    }
    .shop-label {
      font-weight: 700;
      display: inline-block;
      width: 80px;
    }
    .header-right { 
      text-align: right;
      flex-shrink: 0;
    }
    .invoice-title {
      font-family: 'Manrope', sans-serif;
      font-weight: 800;
      font-size: 16px;
      margin-bottom: 6px;
    }
    .invoice-meta {
      font-size: 10px;
      line-height: 1.6;
    }
    .invoice-meta div {
      margin-bottom: 2px;
    }
    .invoice-meta strong {
      font-weight: 700;
    }
    table { width: 100%; border-collapse: collapse; margin-bottom: 16px; margin-top: 16px; }
    th { background: #1E293B; color: #fff; padding: 7px 10px; font-size: 10px; text-transform: uppercase; letter-spacing: 0.05em; text-align: left; }
    td { padding: 7px 10px; border-bottom: 1px solid #E2E8F0; }
    tr:last-child td { border-bottom: none; }
    .totals { margin-left: auto; width: 260px; }
    .totals table { margin: 0; }
    .totals td { padding: 5px 10px; }
    .totals .total-row td { font-weight: 700; font-size: 13px; border-top: 2px solid #1E293B; }
    .footer { margin-top: 24px; border-top: 1px solid #E2E8F0; padding-top: 10px; font-size: 10px; color: #94A3B8; text-align: center; }
    @media print { body { padding: 0; } }
  </style>
</head>
<body>
  <div class="header">
    <div class="header-left">
      <div class="company-name">${bill.company_name || 'Shakeel Traders (Khurian Wala)'}</div>
      <div class="company-info">
        <div>${bill.company_address || 'Karian Wala Road, Adda Chowk Khurainwala'}</div>
        <div><strong>N.T.N No:</strong> ${bill.gst_ntn || 'Not Available'}</div>
        <div><strong>Sales Tax #:</strong>${bill.sales_tax || 'Not Available'}</div>
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
        <div style="margin-top:6px;"><strong>Sales Tax No:</strong> Not Available</div>
        <div><strong>N.T.N No:</strong> Not Available</div>
      </div>
    </div>
  </div>

  <table>
    <thead>
      <tr>
        <th>SKU</th><th>Product</th><th>Cartons</th><th>Loose</th><th>Units</th><th>Rate</th><th>Amount</th>
      </tr>
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

  <script>window.onload = () => window.print();</script>
</body>
</html>`;
}

module.exports = { formatBillForPrint, formatMultiBillPrint };

/**
 * Format multiple bills into a single printable HTML page.
 * Two bills per page, separated by a dashed line — same content as single bill.
 */
function formatMultiBillPrint(bills) {
  function billHtml(bill) {
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
        <td style="text-align:right;">Rs ${Number(item.line_total || 0).toFixed(2)}</td>
      </tr>`;
    }).join('');

    const billDate = new Date(bill.bill_date);
    const formattedDate = billDate.toLocaleDateString('en-GB', {
      day: 'numeric', month: 'long', year: 'numeric'
    }) + '/' + billDate.toLocaleDateString('en-US', { weekday: 'long' });

    return `
    <div class="bill">
      <div class="bill-header">
        <div class="header-left">
          <div class="company-name">${bill.company_name || 'Shakeel Traders'}</div>
          <div class="company-info">
            <div>${bill.company_address || ''}</div>
            <div><b>N.T.N No:</b> ${bill.gst_ntn || 'Not Available'}</div>
            <div><b>Sales Tax #:</b> ${bill.sales_tax || 'Not Available'}</div>
            <div><b>CNIC #:</b> ${bill.cnic || 'Not Available'}</div>
            <div><b>M/S:</b> ${bill.shop_name || ''}</div>
            <div><b>Address:</b> ${bill.shop_address || 'Not Available'}</div>
          </div>
        </div>
        <div class="header-right">
          <div class="invoice-title">CASH MEMO / INVOICE</div>
          <div class="invoice-meta">
            <div><b>Invoice No #:</b> ${bill.bill_number}</div>
            <div><b>Date/Day:</b> ${formattedDate}</div>
            <div><b>Route:</b> ${bill.route_name || 'Not Available'}</div>
            <div style="margin-top:4px;"><b>Sales Tax No:</b> Not Available</div>
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
          <tr><td>Gross Amount</td><td>Rs ${Number(bill.gross_amount || 0).toFixed(2)}</td></tr>
          ${bill.advance_deducted > 0 ? `<tr><td>Advance Deducted</td><td style="color:#10B981;">- Rs ${Number(bill.advance_deducted).toFixed(2)}</td></tr>` : ''}
          <tr class="net-row"><td>Net Amount</td><td>Rs ${Number(bill.net_amount || 0).toFixed(2)}</td></tr>
          <tr><td>Amount Paid</td><td style="color:#10B981;">Rs ${Number(bill.amount_paid || 0).toFixed(2)}</td></tr>
          <tr class="outstanding-row"><td>Outstanding</td><td>Rs ${Number(bill.outstanding_amount || 0).toFixed(2)}</td></tr>
        </table>
      </div>
    </div>`;
  }

  // Group bills in pairs
  const pages = [];
  for (let i = 0; i < bills.length; i += 2) {
    const top = bills[i];
    const bottom = bills[i + 1] || null;
    pages.push({ top, bottom });
  }

  const pagesHtml = pages.map((p, idx) => `
    <div class="page${idx < pages.length - 1 ? ' page-break' : ''}">
      ${billHtml(p.top)}
      ${p.bottom ? `<div class="divider"></div>${billHtml(p.bottom)}` : ''}
    </div>`
  ).join('');

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Open Bills Print</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Manrope:wght@700;800&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Inter', sans-serif; font-size: 11px; color: #1E293B; }
    .page { padding: 20px 24px; }
    .page-break { page-break-after: always; }
    .bill { padding-bottom: 12px; }
    .divider {
      border: none;
      border-top: 2px dashed #94A3B8;
      margin: 14px 0;
    }
    .bill-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      border-bottom: 2px solid #1E293B;
      padding-bottom: 10px;
      margin-bottom: 0;
    }
    .header-left { flex: 1; }
    .company-name {
      font-family: 'Manrope', sans-serif;
      font-weight: 800;
      font-size: 15px;
      text-decoration: underline;
      margin-bottom: 3px;
    }
    .company-info { font-size: 9px; line-height: 1.55; }
    .company-info div { margin-bottom: 1px; }
    .header-right { text-align: right; flex-shrink: 0; }
    .invoice-title {
      font-family: 'Manrope', sans-serif;
      font-weight: 800;
      font-size: 13px;
      margin-bottom: 4px;
    }
    .invoice-meta { font-size: 9px; line-height: 1.6; }
    .invoice-meta div { margin-bottom: 1px; }
    table { width: 100%; border-collapse: collapse; margin: 10px 0 8px; }
    th {
      background: #1E293B; color: #fff;
      padding: 5px 8px; font-size: 9px;
      text-transform: uppercase; letter-spacing: 0.04em;
      text-align: left;
    }
    td { padding: 5px 8px; border-bottom: 1px solid #E2E8F0; font-size: 9px; }
    tr:last-child td { border-bottom: none; }
    .totals { margin-left: auto; width: 240px; }
    .totals table { margin: 0; }
    .totals td { padding: 3px 8px; font-size: 9px; }
    .totals td:last-child { text-align: right; }
    .net-row td { font-weight: 700; border-top: 1.5px solid #1E293B; }
    .outstanding-row td { font-weight: 700; color: #EF4444; }
    @media print {
      body { margin: 0; }
      .page { padding: 14px 18px; }
    }
  </style>
</head>
<body>
  ${pagesHtml}
  <script>window.onload = () => window.print();</script>
</body>
</html>`;
}
