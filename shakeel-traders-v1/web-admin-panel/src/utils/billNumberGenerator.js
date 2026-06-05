'use strict';

const prefixMap = { order_booker: 'OB', direct_shop: 'DS', salesman: 'SM' };

/**
 * Generate a unique bill number in format OB-YYYY-MM-NNNNN.
 * Uses SELECT MAX with FOR UPDATE to prevent race conditions.
 * Must be called inside an active transaction.
 */
async function generateBillNumber(billType, conn) {
  const prefix = prefixMap[billType] || 'XX';
  const now = new Date();
  const year  = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const pattern = `${prefix}-${year}-${month}-%`;

  const [[row]] = await conn.query(
    'SELECT MAX(bill_number) AS max_num FROM bills WHERE bill_number LIKE ? FOR UPDATE',
    [pattern]
  );

  let seq = 1;
  if (row && row.max_num) {
    const parts = row.max_num.split('-');
    seq = parseInt(parts[parts.length - 1]) + 1;
  }

  return `${prefix}-${year}-${month}-${String(seq).padStart(5, '0')}`;
}

module.exports = { generateBillNumber };
