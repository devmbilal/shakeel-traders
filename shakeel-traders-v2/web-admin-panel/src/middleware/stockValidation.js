'use strict';

const { getConnection } = require('../config/db');

/**
 * Custom error class for stock insufficiency.
 */
class StockInsufficientError extends Error {
  constructor(productId, required, available) {
    super(`Insufficient stock for product ID ${productId}. Required: ${required}, Available: ${available}`);
    this.name = 'StockInsufficientError';
    this.status = 422;
    this.productId = productId;
    this.required = required;
    this.available = available;
  }
}

/**
 * validateStockForItems — checks that all items in a deduction list
 * have sufficient warehouse stock. Uses SELECT FOR UPDATE to prevent
 * race conditions.
 *
 * @param {Array<{productId, cartons, loose}>} items
 * @param {object} conn  — active transaction connection (required)
 * @throws {StockInsufficientError} if any product has insufficient stock
 */
async function validateStockForItems(items, conn) {
  for (const item of items) {
    const [rows] = await conn.execute(
      'SELECT id, name, sku_code, current_stock_cartons, current_stock_loose FROM products WHERE id = ? FOR UPDATE',
      [item.productId]
    );

    if (!rows.length) {
      throw new Error(`Product ID ${item.productId} not found.`);
    }

    const product = rows[0];

    if (
      product.current_stock_cartons < (item.cartons || 0) ||
      product.current_stock_loose   < (item.loose   || 0)
    ) {
      const availableUnits =
        product.current_stock_cartons * product.units_per_carton + product.current_stock_loose;
      throw new StockInsufficientError(
        item.productId,
        `${item.cartons} cartons + ${item.loose} loose`,
        `${product.current_stock_cartons} cartons + ${product.current_stock_loose} loose`
      );
    }
  }
}

/**
 * Express middleware — validates stock before deduction routes.
 * Expects req.stockItems = [{productId, cartons, loose}] to be set
 * by the controller before calling next().
 *
 * For most use cases, call validateStockForItems() directly inside
 * a transaction in the service layer instead.
 */
async function stockValidationMiddleware(req, res, next) {
  if (!req.stockItems || !req.stockItems.length) return next();

  let conn;
  try {
    conn = await getConnection();
    await conn.beginTransaction();
    await validateStockForItems(req.stockItems, conn);
    await conn.rollback(); // Just checking — actual deduction happens in service
    conn.release();
    next();
  } catch (err) {
    if (conn) {
      await conn.rollback().catch(() => {});
      conn.release();
    }
    if (err.name === 'StockInsufficientError') {
      return res.status(422).json({ error: err.message });
    }
    next(err);
  }
}

module.exports = { stockValidationMiddleware, validateStockForItems, StockInsufficientError };
