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
 * Generate a PDF of all open bills - 2 bills per page with divider
 * @param {Array} bills - Array of bill objects with items
 * @param {Object} companyProfile - Company info for header
 * @returns {Buffer} PDF buffer
 */
function generateOpenBillsPDF(bills, companyProfile) {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ margin: 30, size: 'A4' });
      const chunks = [];

      doc.on('data', chunk => chunks.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);

      const pageHeight = 842; // A4 height in points
      const billHeight = (pageHeight - 60) / 2; // Space for 2 bills per page with margins
      const dividerY = 30 + billHeight;

      /**
       * Render a single bill at specified Y position
       */
      function renderBill(bill, startY) {
        const leftMargin = 40;
        const rightMargin = 555;
        let currentY = startY;

        // Format date
        const billDate = new Date(bill.bill_date);
        const formattedDate = billDate.toLocaleDateString('en-GB', { 
          day: 'numeric', 
          month: 'long', 
          year: 'numeric'
        }) + '/' + billDate.toLocaleDateString('en-US', { weekday: 'long' });

        // Header - Left side (Distributor info)
        doc.fontSize(11).font('Helvetica-Bold').text(companyProfile.company_name || 'Shakeel Traders (Khurian Wala)', leftMargin, currentY, { underline: true });
        currentY += 14;
        
        doc.fontSize(7).font('Helvetica');
        doc.text(companyProfile.address || 'Karian Wala Road, Adda Chowk Khurainwala', leftMargin, currentY, { width: 250 });
        currentY += 10;
        doc.text(`N.T.N No: ${companyProfile.gst_ntn || 'Not Available'}`, leftMargin, currentY);
        currentY += 10;
        doc.text(`Sales Tax #: ${companyProfile.sales_tax || 'Not Available'}`, leftMargin, currentY);
        currentY += 10;
        doc.text(`CNIC #: ${companyProfile.cnic || 'Not Available'}`, leftMargin, currentY);
        currentY += 10;
        doc.text(`M/S: ${bill.shop_name || ''}`, leftMargin, currentY);
        currentY += 10;
        doc.text(`Address: ${bill.shop_address || 'Not Available'}`, leftMargin, currentY, { width: 250 });

        // Header - Right side (Invoice info)
        let rightY = startY;
        doc.fontSize(10).font('Helvetica-Bold').text('CASH MEMO / INVOICE', rightMargin - 150, rightY, { width: 150, align: 'right' });
        rightY += 14;
        doc.fontSize(7).font('Helvetica');
        doc.text(`Invoice No #: ${bill.bill_number}`, rightMargin - 150, rightY, { width: 150, align: 'right' });
        rightY += 10;
        doc.text(`Date/Day: ${formattedDate}`, rightMargin - 150, rightY, { width: 150, align: 'right' });
        rightY += 10;
        doc.text(`Route: ${bill.route_name || 'Not Available'}`, rightMargin - 150, rightY, { width: 150, align: 'right' });
        rightY += 12;
        doc.text(`Sales Tax No: Not Available`, rightMargin - 150, rightY, { width: 150, align: 'right' });
        rightY += 10;
        doc.text(`N.T.N No: Not Available`, rightMargin - 150, rightY, { width: 150, align: 'right' });

        // Line separator after header
        currentY = Math.max(currentY, rightY) + 5;
        doc.moveTo(leftMargin, currentY).lineTo(rightMargin, currentY).stroke();
        currentY += 8;

        // Items table header
        const tableTop = currentY;
        doc.fontSize(7).font('Helvetica-Bold');
        doc.text('Product', leftMargin, tableTop, { width: 180 });
        doc.text('Qty', leftMargin + 180, tableTop, { width: 60 });
        doc.text('Rate', leftMargin + 240, tableTop, { width: 70 });
        doc.text('Amount', leftMargin + 310, tableTop, { width: 80, align: 'right' });
        currentY = tableTop + 12;
        doc.moveTo(leftMargin, currentY).lineTo(rightMargin, currentY).stroke();
        currentY += 5;

        // Items
        doc.font('Helvetica').fontSize(6);
        const maxItems = 8; // Limit items to fit in half page
        const itemsToShow = (bill.items || []).slice(0, maxItems);
        
        itemsToShow.forEach(item => {
          const y = currentY;
          doc.text(item.product_name || '', leftMargin, y, { width: 180 });
          doc.text(`${item.cartons || 0}C ${item.loose_units || 0}L`, leftMargin + 180, y, { width: 60 });
          doc.text(`Rs ${Number(item.unit_price || 0).toFixed(2)}`, leftMargin + 240, y, { width: 70 });
          doc.text(`Rs ${Number(item.line_total || 0).toFixed(2)}`, leftMargin + 310, y, { width: 80, align: 'right' });
          currentY += 10;
        });

        if (bill.items && bill.items.length > maxItems) {
          doc.fontSize(6).font('Helvetica-Oblique');
          doc.text(`... and ${bill.items.length - maxItems} more items`, leftMargin, currentY);
          currentY += 10;
        }

        // Totals section
        currentY += 5;
        doc.moveTo(leftMargin, currentY).lineTo(rightMargin, currentY).stroke();
        currentY += 5;

        doc.fontSize(7).font('Helvetica-Bold');
        const totalsX = rightMargin - 150;
        doc.text(`Gross Amount:`, totalsX, currentY);
        doc.text(`Rs ${Number(bill.gross_amount).toFixed(2)}`, totalsX + 80, currentY, { width: 70, align: 'right' });
        currentY += 10;

        if (bill.advance_deducted > 0) {
          doc.text(`Advance Deducted:`, totalsX, currentY);
          doc.text(`Rs ${Number(bill.advance_deducted).toFixed(2)}`, totalsX + 80, currentY, { width: 70, align: 'right' });
          currentY += 10;
        }

        doc.text(`Net Amount:`, totalsX, currentY);
        doc.text(`Rs ${Number(bill.net_amount).toFixed(2)}`, totalsX + 80, currentY, { width: 70, align: 'right' });
        currentY += 10;

        doc.text(`Amount Paid:`, totalsX, currentY);
        doc.text(`Rs ${Number(bill.amount_paid || 0).toFixed(2)}`, totalsX + 80, currentY, { width: 70, align: 'right' });
        currentY += 10;

        doc.fontSize(8).font('Helvetica-Bold');
        doc.text(`Outstanding:`, totalsX, currentY);
        doc.text(`Rs ${Number(bill.outstanding_amount).toFixed(2)}`, totalsX + 80, currentY, { width: 70, align: 'right' });
      }

      // Render bills - 2 per page
      bills.forEach((bill, index) => {
        const billPosition = index % 2; // 0 = top, 1 = bottom
        
        if (index > 0 && billPosition === 0) {
          doc.addPage();
        }

        const startY = billPosition === 0 ? 30 : dividerY + 10;

        renderBill(bill, startY);

        // Draw divider line between bills (except for last bill on page)
        if (billPosition === 0 && index < bills.length - 1) {
          doc.moveTo(30, dividerY).lineTo(565, dividerY).dash(5, { space: 3 }).stroke();
          doc.undash();
        }
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
