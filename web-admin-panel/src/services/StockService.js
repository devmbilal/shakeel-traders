'use strict';

const { StockInsufficientError } = require('../middleware/stockValidation');

/**
 * Convert cartons + loose to total loose units using units_per_carton.
 */
function toTotalUnits(cartons, loose, upc) {
  return (parseInt(cartons) || 0) * (parseInt(upc) || 1) + (parseInt(loose) || 0);
}

/**
 * Given a total unit count, return optimal cartons + loose split.
 * Maximises cartons, remainder goes to loose.
 */
function fromTotalUnits(totalUnits, upc) {
  const u = parseInt(upc) || 1;
  const cartons = Math.floor(totalUnits / u);
  const loose   = totalUnits % u;
  return { cartons, loose };
}

const StockService = {
  /**
   * Deduct stock from a product inside an active transaction.
   * Works in total units — opens cartons if needed to fulfil loose demand.
   * Throws StockInsufficientError if total units insufficient.
   */
  async deductStock(productId, cartons, loose, conn) {
    const [[product]] = await conn.query(
      `SELECT id, name, sku_code, units_per_carton,
              current_stock_cartons, current_stock_loose
       FROM products WHERE id = ? FOR UPDATE`,
      [productId]
    );
    if (!product) throw new Error(`Product ID ${productId} not found.`);

    const upc = parseInt(product.units_per_carton) || 1;
    const stockTotal   = toTotalUnits(product.current_stock_cartons, product.current_stock_loose, upc);
    const requestTotal = toTotalUnits(cartons, loose, upc);

    if (requestTotal > stockTotal) {
      throw new StockInsufficientError(
        productId,
        `${cartons}C + ${loose}L (${requestTotal} units)`,
        `${product.current_stock_cartons}C + ${product.current_stock_loose}L (${stockTotal} units)`
      );
    }

    // Compute new stock in total units, then split back to cartons + loose
    const newTotal = stockTotal - requestTotal;
    const { cartons: newCartons, loose: newLoose } = fromTotalUnits(newTotal, upc);

    await conn.query(
      'UPDATE products SET current_stock_cartons = ?, current_stock_loose = ? WHERE id = ?',
      [newCartons, newLoose, productId]
    );

    return { stockAfterCartons: newCartons, stockAfterLoose: newLoose };
  },

  /**
   * Add stock to a product inside an active transaction.
   * Merges incoming cartons + loose with existing stock.
   */
  async addStock(productId, cartons, loose, movementType, referenceId, referenceType, note, userId, conn) {
    const [[product]] = await conn.query(
      'SELECT units_per_carton, current_stock_cartons, current_stock_loose FROM products WHERE id = ?',
      [productId]
    );
    const upc = parseInt(product?.units_per_carton) || 1;
    const currentTotal = toTotalUnits(product?.current_stock_cartons || 0, product?.current_stock_loose || 0, upc);
    const addTotal     = toTotalUnits(cartons, loose, upc);
    const newTotal     = currentTotal + addTotal;
    const { cartons: newCartons, loose: newLoose } = fromTotalUnits(newTotal, upc);

    await conn.query(
      'UPDATE products SET current_stock_cartons = ?, current_stock_loose = ? WHERE id = ?',
      [newCartons, newLoose, productId]
    );

    await conn.query(
      `INSERT INTO stock_movements
         (product_id, movement_type, reference_id, reference_type,
          cartons_in, loose_in, cartons_out, loose_out,
          stock_after_cartons, stock_after_loose, note, created_by)
       VALUES (?, ?, ?, ?, ?, ?, 0, 0, ?, ?, ?, ?)`,
      [productId, movementType, referenceId || null, referenceType || null,
       parseInt(cartons) || 0, parseInt(loose) || 0,
       newCartons, newLoose,
       note || null, userId]
    );

    return { stockAfterCartons: newCartons, stockAfterLoose: newLoose };
  },

  /**
   * Record a stock deduction movement (called after deductStock).
   */
  async recordDeductionMovement(productId, cartons, loose, movementType, referenceId, referenceType, note, userId, stockAfterCartons, stockAfterLoose, conn) {
    await conn.query(
      `INSERT INTO stock_movements
         (product_id, movement_type, reference_id, reference_type,
          cartons_in, loose_in, cartons_out, loose_out,
          stock_after_cartons, stock_after_loose, note, created_by)
       VALUES (?, ?, ?, ?, 0, 0, ?, ?, ?, ?, ?, ?)`,
      [productId, movementType, referenceId || null, referenceType || null,
       parseInt(cartons) || 0, parseInt(loose) || 0,
       stockAfterCartons, stockAfterLoose,
       note || null, userId]
    );
  },
};

module.exports = StockService;
