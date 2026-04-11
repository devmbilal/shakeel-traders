'use strict';

const PDFDocument = require('pdfkit');

/**
 * Generate a consolidated stock PDF for selected orders
 * @param {Object} data - { products: [...], totalOrders, bookers, routes, date }
 * @returns {Buffer} PDF buffer
 */
function generateConsolidatedStockPDF(data) {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ margin: 50 });
      const chunks = [];

      doc.on('data', chunk => chunks.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);

      // Header
      doc.fontSize(18).text('Consolidated Stock Report', { align: 'center' });
      doc.moveDown(0.5);
      doc.fontSize(10).text(`Date: ${data.date || new Date().toLocaleDateString()}`, { align: 'center' });
      doc.text(`Total Orders: ${data.totalOrders || 0}`, { align: 'center' });
      if (data.bookers) doc.text(`Order Bookers: ${data.bookers}`, { align: 'center' });
      if (data.routes) doc.text(`Routes: ${data.routes}`, { align: 'center' });
      doc.moveDown(1);

      // Table header
      const tableTop = doc.y;
      const colWidths = { sku: 80, name: 150, cartons: 60, loose: 60, stock: 80, shortfall: 70 };
      let x = 50;

      doc.fontSize(9).font('Helvetica-Bold');
      doc.text('SKU', x, tableTop, { width: colWidths.sku });
      x += colWidths.sku;
      doc.text('Product', x, tableTop, { width: colWidths.name });
      x += colWidths.name;
      doc.text('Cartons', x, tableTop, { width: colWidths.cartons });
      x += colWidths.cartons;
      doc.text('Loose', x, tableTop, { width: colWidths.loose });
      x += colWidths.loose;
      doc.text('Stock', x, tableTop, { width: colWidths.stock });
      x += colWidths.stock;
      doc.text('Shortfall', x, tableTop, { width: colWidths.shortfall });

      doc.moveTo(50, tableTop + 15).lineTo(550, tableTop + 15).stroke();
      doc.moveDown(0.5);

      // Table rows
      doc.font('Helvetica').fontSize(8);
      (data.products || []).forEach(p => {
        const y = doc.y;
        if (y > 700) { doc.addPage(); doc.y = 50; }

        x = 50;
        doc.text(p.sku_code || '', x, doc.y, { width: colWidths.sku });
        x += colWidths.sku;
        doc.text(p.name || '', x, y, { width: colWidths.name });
        x += colWidths.name;
        doc.text(String(p.total_cartons || 0), x, y, { width: colWidths.cartons });
        x += colWidths.cartons;
        doc.text(String(p.total_loose || 0), x, y, { width: colWidths.loose });
        x += colWidths.loose;
        doc.text(`${p.current_stock_cartons || 0}C ${p.current_stock_loose || 0}L`, x, y, { width: colWidths.stock });
        x += colWidths.stock;
        doc.text(p.shortfall ? 'YES' : 'NO', x, y, { width: colWidths.shortfall, color: p.shortfall ? 'red' : 'green' });

        doc.moveDown(0.8);
      });

      doc.end();
    } catch (err) {
      reject(err);
    }
  });
}

/**
 * Generate a PDF of all open bills
 * @param {Array} bills - Array of bill objects with items
 * @param {Object} companyProfile - Company info for header
 * @returns {Buffer} PDF buffer
 */
function generateOpenBillsPDF(bills, companyProfile) {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ margin: 50 });
      const chunks = [];

      doc.on('data', chunk => chunks.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);

      bills.forEach((bill, index) => {
        if (index > 0) doc.addPage();

        // Company header
        doc.fontSize(16).font('Helvetica-Bold').text(companyProfile.company_name || 'Shakeel Traders', { align: 'center' });
        doc.fontSize(9).font('Helvetica').text(companyProfile.address || '', { align: 'center' });
        doc.text(`Phone: ${companyProfile.phone_1 || ''}`, { align: 'center' });
        if (companyProfile.gst_ntn) doc.text(`GST/NTN: ${companyProfile.gst_ntn}`, { align: 'center' });
        doc.moveDown(1);

        // Bill header
        doc.fontSize(12).font('Helvetica-Bold').text(`Bill #${bill.bill_number}`, 50, doc.y);
        doc.fontSize(9).font('Helvetica');
        doc.text(`Date: ${bill.bill_date}`, 50, doc.y);
        doc.text(`Shop: ${bill.shop_name}`, 50, doc.y);
        doc.moveDown(0.5);

        // Items table
        const tableTop = doc.y;
        doc.fontSize(9).font('Helvetica-Bold');
        doc.text('Product', 50, tableTop, { width: 200 });
        doc.text('Qty', 250, tableTop, { width: 80 });
        doc.text('Rate', 330, tableTop, { width: 80 });
        doc.text('Amount', 410, tableTop, { width: 100, align: 'right' });
        doc.moveTo(50, tableTop + 15).lineTo(550, tableTop + 15).stroke();
        doc.moveDown(0.5);

        doc.font('Helvetica').fontSize(8);
        (bill.items || []).forEach(item => {
          const y = doc.y;
          doc.text(item.product_name, 50, y, { width: 200 });
          doc.text(`${item.final_cartons}C ${item.final_loose}L`, 250, y, { width: 80 });
          doc.text(`Rs ${Number(item.rate_per_unit).toFixed(2)}`, 330, y, { width: 80 });
          doc.text(`Rs ${Number(item.total_amount).toFixed(2)}`, 410, y, { width: 100, align: 'right' });
          doc.moveDown(0.8);
        });

        doc.moveDown(0.5);
        doc.moveTo(50, doc.y).lineTo(550, doc.y).stroke();
        doc.moveDown(0.3);

        // Totals
        doc.fontSize(9).font('Helvetica-Bold');
        doc.text(`Gross Amount: Rs ${Number(bill.gross_amount).toFixed(2)}`, 350, doc.y, { align: 'right' });
        doc.text(`Advance Deducted: Rs ${Number(bill.advance_deducted).toFixed(2)}`, 350, doc.y, { align: 'right' });
        doc.text(`Net Amount: Rs ${Number(bill.net_amount).toFixed(2)}`, 350, doc.y, { align: 'right' });
        doc.text(`Amount Paid: Rs ${Number(bill.amount_paid || 0).toFixed(2)}`, 350, doc.y, { align: 'right' });
        doc.font('Helvetica-Bold').fontSize(10);
        doc.text(`Outstanding: Rs ${Number(bill.outstanding_amount).toFixed(2)}`, 350, doc.y, { align: 'right' });
      });

      doc.end();
    } catch (err) {
      reject(err);
    }
  });
}

module.exports = {
  generateConsolidatedStockPDF,
  generateOpenBillsPDF,
};
