const ExcelJS = require('exceljs');
const db = require('../config/db');

class ExcelExporter {
  static async exportToExcel(reportData, columns, sheetName, options = {}) {
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet(sheetName);

    // Get company profile for header
    const [companyProfile] = await db.query(`SELECT * FROM company_profile WHERE id = 1`);

    // Add company header
    if (companyProfile && !options.skipHeader) {
      worksheet.mergeCells('A1:' + String.fromCharCode(64 + columns.length) + '1');
      const headerCell = worksheet.getCell('A1');
      headerCell.value = companyProfile.company_name || 'Shakeel Traders';
      headerCell.font = { size: 16, bold: true };
      headerCell.alignment = { horizontal: 'center', vertical: 'middle' };
      
      worksheet.mergeCells('A2:' + String.fromCharCode(64 + columns.length) + '2');
      const subHeaderCell = worksheet.getCell('A2');
      subHeaderCell.value = companyProfile.address || '';
      subHeaderCell.font = { size: 10 };
      subHeaderCell.alignment = { horizontal: 'center' };
      
      if (companyProfile.gst_ntn) {
        worksheet.mergeCells('A3:' + String.fromCharCode(64 + columns.length) + '3');
        const gstCell = worksheet.getCell('A3');
        gstCell.value = `GST/NTN: ${companyProfile.gst_ntn}`;
        gstCell.font = { size: 9 };
        gstCell.alignment = { horizontal: 'center' };
      }
      
      // Add report title
      worksheet.mergeCells('A4:' + String.fromCharCode(64 + columns.length) + '4');
      const titleCell = worksheet.getCell('A4');
      titleCell.value = options.reportTitle || sheetName;
      titleCell.font = { size: 12, bold: true };
      titleCell.alignment = { horizontal: 'center' };
      
      // Add generation date
      worksheet.mergeCells('A5:' + String.fromCharCode(64 + columns.length) + '5');
      const dateCell = worksheet.getCell('A5');
      dateCell.value = `Generated on: ${new Date().toLocaleString()}`;
      dateCell.font = { size: 9, italic: true };
      dateCell.alignment = { horizontal: 'center' };
      
      worksheet.addRow([]); // Empty row
    }

    // Add column headers
    const headerRow = worksheet.addRow(columns.map(col => col.header));
    headerRow.font = { bold: true, color: { argb: 'FFFFFFFF' } };
    headerRow.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FF1E293B' }
    };
    headerRow.alignment = { horizontal: 'center', vertical: 'middle' };
    headerRow.height = 25;

    // Add data rows
    reportData.forEach(row => {
      const dataRow = worksheet.addRow(columns.map(col => {
        const value = row[col.key];
        
        // Format based on column type
        if (col.type === 'currency') {
          return parseFloat(value || 0);
        } else if (col.type === 'number') {
          return parseInt(value || 0);
        } else if (col.type === 'date') {
          return value ? new Date(value) : '';
        }
        
        return value || '';
      }));
      
      // Apply formatting
      columns.forEach((col, index) => {
        const cell = dataRow.getCell(index + 1);
        
        if (col.type === 'currency') {
          cell.numFmt = 'Rs #,##0.00';
          cell.alignment = { horizontal: 'right' };
        } else if (col.type === 'number') {
          cell.numFmt = '#,##0';
          cell.alignment = { horizontal: 'right' };
        } else if (col.type === 'date') {
          cell.numFmt = 'dd-mmm-yyyy';
          cell.alignment = { horizontal: 'center' };
        } else {
          cell.alignment = { horizontal: 'left' };
        }
      });
    });

    // Auto-fit columns
    worksheet.columns.forEach((column, index) => {
      const col = columns[index];
      column.width = col.width || 15;
    });

    // Add borders to all cells
    const lastRow = worksheet.lastRow.number;
    const startRow = options.skipHeader ? 1 : 7;
    for (let row = startRow; row <= lastRow; row++) {
      for (let col = 1; col <= columns.length; col++) {
        const cell = worksheet.getCell(row, col);
        cell.border = {
          top: { style: 'thin' },
          left: { style: 'thin' },
          bottom: { style: 'thin' },
          right: { style: 'thin' }
        };
      }
    }

    // Generate buffer
    const buffer = await workbook.xlsx.writeBuffer();
    return buffer;
  }
}

module.exports = ExcelExporter;
