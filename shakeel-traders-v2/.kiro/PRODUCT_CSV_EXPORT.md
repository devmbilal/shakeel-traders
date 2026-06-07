# Product CSV Export Feature

**Date:** June 2026  
**Status:** ✅ COMPLETED

## Feature Added
Added CSV export functionality for products, allowing users to export product data in CSV format for backup, editing, or external use.

## Implementation

### 1. Export Controller Method
**File:** `src/controllers/ProductController.js`

Added `exportCSV()` method that:
- Respects current filter (all, active, inactive, low_stock)
- Exports all products without pagination limits (limit: 999999)
- Generates CSV with proper escaping for quotes in product names
- Includes timestamp in filename for easy identification

**CSV Fields Exported:**
1. `sku_code` - Product SKU (unique identifier)
2. `name` - Product name (with quote escaping)
3. `brand` - Product brand
4. `units_per_carton` - Units per carton
5. `retail_price` - Retail price (formatted to 2 decimals)
6. `wholesale_price` - Wholesale price (formatted to 2 decimals)
7. `low_stock_threshold` - Low stock alert threshold
8. `current_stock_cartons` - Current stock in cartons
9. `current_stock_loose` - Current loose units
10. `is_active` - Status (active/inactive)

### 2. Route Added
**File:** `src/routes/web/products.js`

Added route: `GET /products/export-csv`
- Placed before parameterized routes to avoid conflicts
- Accepts `filter` query parameter to respect current view filter

### 3. UI Button Added
**File:** `src/views/products/index.ejs`

Added "Export CSV" button:
- Green outline button with download icon
- Positioned between page header and Import CSV button
- Respects current filter (exports only what user is viewing)
- Filename indicates filter type:
  - `products-all-{timestamp}.csv` - All products
  - `products-active-{timestamp}.csv` - Active products only
  - `products-inactive-{timestamp}.csv` - Inactive products only
  - `products-low_stock-{timestamp}.csv` - Low stock products only

## User Experience

### How to Use
1. Navigate to Products page (`/products`)
2. (Optional) Apply filter: All, Active, Inactive, or Low Stock
3. Click "Export CSV" button
4. Browser downloads CSV file with current filtered products
5. CSV can be opened in Excel, edited, and re-imported via Import CSV

### Use Cases
- **Backup:** Export all products for record keeping
- **Bulk Edit:** Export, edit prices/thresholds in Excel, re-import
- **Active Products Only:** Export only active products for external systems
- **Stock Analysis:** Export low stock products for inventory planning
- **Price Updates:** Export, update prices in bulk, re-import

## CSV Format
```csv
sku_code,name,brand,units_per_carton,retail_price,wholesale_price,low_stock_threshold,current_stock_cartons,current_stock_loose,is_active
CBL-001,"Sooper Biscuit",CBL,12,850.00,800.00,10,50,5,active
CBL-002,"Premium Cookies",CBL,24,1200.00,1100.00,20,30,12,active
```

## Technical Notes
- CSV uses UTF-8 encoding
- Product names with quotes are properly escaped (`"Product ""Quote"" Name"`)
- Prices formatted to 2 decimal places for consistency
- Empty fields (like brand or threshold) exported as empty strings
- Status exported as human-readable: `active` or `inactive`
- No pagination - exports all matching products in one file
- Response headers set for proper browser download:
  - `Content-Type: text/csv`
  - `Content-Disposition: attachment; filename="..."`

## Files Modified
1. **src/controllers/ProductController.js**
   - Added `exportCSV()` method with filter support and CSV generation

2. **src/routes/web/products.js**
   - Added `GET /products/export-csv` route (before parameterized routes)

3. **src/views/products/index.ejs**
   - Added "Export CSV" button with filter parameter

## Testing Recommendations
- Export all products → verify all records included
- Export active products → verify only active products included
- Export inactive products → verify only inactive products included
- Export low stock products → verify threshold logic correct
- Open CSV in Excel → verify proper formatting
- Edit CSV and re-import → verify import still works
- Check product names with quotes → verify proper escaping

## Related Features
- **Import CSV:** `/products` → Import CSV button → Upload edited CSV
- **Shop CSV Export:** Similar feature exists for shops (`/shops/export-csv`)
- **Filters:** All, Active, Inactive, Low Stock filters affect export

## Future Enhancements
- Add option to exclude stock columns (only product master data)
- Add option to export with custom date range filters
- Consider adding Excel (.xlsx) export format
- Add export confirmation modal showing record count
