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

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Bill ${bill.bill_number}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Manrope:wght@700;800&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Inter', sans-serif; font-size: 12px; color: #1E293B; padding: 20px; }
    .header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px; border-bottom: 2px solid #1E293B; padding-bottom: 12px; }
    .company-name { font-family: 'Manrope', sans-serif; font-weight: 800; font-size: 18px; }
    .company-sub { font-size: 11px; color: #64748B; margin-top: 2px; }
    .bill-meta { text-align: right; }
    .bill-number { font-family: 'Manrope', sans-serif; font-weight: 800; font-size: 14px; color: #3B82F6; }
    .shop-info { background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 6px; padding: 10px 14px; margin-bottom: 16px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 16px; }
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
    <div>
      ${bill.logo_path ? `<img src="${bill.logo_path}" style="height:40px;margin-bottom:6px;display:block;">` : ''}
      <div class="company-name">${bill.company_name || 'Shakeel Traders'}</div>
      <div class="company-sub">${bill.company_address || ''}</div>
      <div class="company-sub">NTN/GST: ${bill.gst_ntn || ''} | ${bill.phone_1 || ''}</div>
    </div>
    <div class="bill-meta">
      <div class="bill-number">${bill.bill_number}</div>
      <div style="font-size:11px;color:#64748B;margin-top:4px;">Date: ${bill.bill_date}</div>
      <div style="font-size:11px;color:#64748B;">Type: ${bill.bill_type.replace(/_/g,' ').toUpperCase()}</div>
    </div>
  </div>

  <div class="shop-info">
    <strong>${bill.shop_name}</strong>
    <span style="margin-left:16px;color:#64748B;">Route: ${bill.route_name || ''}</span>
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

  <div class="footer">
    Shakeel Traders Distribution Order System | Printed: ${new Date().toLocaleString()}
  </div>
  <script>window.onload = () => window.print();</script>
</body>
</html>`;
}

module.exports = { formatBillForPrint };
