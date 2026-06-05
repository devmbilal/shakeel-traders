# Implementation Plan

- [x] 1. Write bug condition exploration tests (financially critical bugs)
  - **Property 1: Bug Condition** - Wholesale Price Default, Price Range Clamping, and Order Total Formula
  - **CRITICAL**: Write these tests BEFORE implementing any fix — failure confirms the bugs exist
  - **DO NOT attempt to fix the test or the code when it fails**
  - **GOAL**: Surface counterexamples that demonstrate each financial bug exists
  - **Scoped PBT Approach**: Scope each property to the concrete failing case(s) for reproducibility
  - Test 1 — Wholesale price default (`isBugCondition_Issue3`): for any wholesale shop with `retailPrice != wholesalePrice`, assert `_OrderEntry` initialised price equals `wholesalePrice`. Run on unfixed code — **EXPECTED FAILURE** (returns `retailPrice` instead)
  - Test 2 — Price range clamping (`isBugCondition_Issue4`): for any price-editable shop where entered price is outside `[basePrice*(1+minPct/100), basePrice*(1+maxPct/100)]`, assert stored price is within bounds after `_update()`. Run on unfixed code — **EXPECTED FAILURE** (stores raw out-of-range value)
  - Test 3 — Order total formula (`isBugCondition_Issue6`): for any `LocalOrderItem` with `cartons > 0` and `unitsPerCarton > 1`, assert `LocalOrder.total == (cartons * unitsPerCarton + looseUnits) * unitPrice`. Run on unfixed code — **EXPECTED FAILURE** (returns `(cartons + looseUnits) * unitPrice`)
  - Document counterexamples found (e.g., wholesale shop: price `100` returned instead of `85`; order total: `50` returned instead of `270`)
  - Mark task complete when all three tests are written, run, and failures are documented
  - _Requirements: 3.1, 4.1, 4.2, 6.2_

- [x] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Retail Price Unchanged, Read-Only Field Unchanged, Zero-Carton Total Unchanged
  - **IMPORTANT**: Follow observation-first methodology — run unfixed code with non-buggy inputs first
  - Observe: retail shop entry initialised with `retailPrice` on unfixed code → record value
  - Observe: shop with `priceEditAllowed = false`, price field value unchanged after `_update()` → record value
  - Observe: `LocalOrder.total` for items with `cartons = 0` equals `looseUnits * unitPrice` on unfixed code → record value
  - Write property-based test 1: for all retail shops (`shopType != 'wholesale'`), `_OrderEntry.price == product.retailPrice` (from Preservation Requirements in design)
  - Write property-based test 2: for all shops with `priceEditAllowed = false`, `_update()` leaves price unchanged — no clamping applied
  - Write property-based test 3: for all orders where every item has `cartons = 0`, `LocalOrder.total == sum(looseUnits * unitPrice)` — formula is identical before and after fix
  - Verify all three tests PASS on unfixed code (confirms baseline behaviour to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3_

- [x] 3. Fix models layer (`models.dart`)

  - [x] 3.1 Add `unitsPerCarton` field to `LocalOrderItem`
    - Add `final int unitsPerCarton;` to `LocalOrderItem` class
    - Update constructor to include `required this.unitsPerCarton`
    - Update `fromMap` to read `_toInt(m['units_per_carton'])`
    - Update `toMap` to write `'units_per_carton': unitsPerCarton`
    - _Bug_Condition: isBugCondition_Issue6 — any item with cartons > 0 triggers wrong total_
    - _Requirements: 6.2_

  - [x] 3.2 Fix `LocalOrder.total` getter
    - Replace `sum + (i.cartons * i.unitPrice) + (i.looseUnits * i.unitPrice)` with `sum + (i.cartons * i.unitsPerCarton + i.looseUnits) * i.unitPrice`
    - _Bug_Condition: isBugCondition_Issue6(order) — order.items.any(i => i.cartons > 0)_
    - _Expected_Behavior: total = SUM((cartons * unitsPerCarton + looseUnits) * unitPrice) per item_
    - _Preservation: items with cartons = 0 produce identical result (looseUnits * unitPrice unchanged)_
    - _Requirements: 6.2, 3.10_

  - [x] 3.3 Add `ShopPriceHistory` model
    - Add new class `ShopPriceHistory` with fields: `final int shopId`, `final int productId`, `final double unitPrice`, `final String orderDate`
    - Add `fromMap` factory reading `shop_id`, `product_id`, `unit_price`, `order_date`
    - Add `toMap()` method
    - _Requirements: 5.3, 5.4_

- [x] 4. Fix DB service layer (`local_db_service.dart`)

  - [x] 4.1 Add `units_per_carton` column to `local_order_items` in `_onCreate`
    - Add `units_per_carton INTEGER DEFAULT 1` column to the `CREATE TABLE local_order_items` DDL
    - _Requirements: 6.2_

  - [x] 4.2 Add `shop_price_history` table to `_onCreate`
    - Add DDL: `CREATE TABLE shop_price_history (id INTEGER PRIMARY KEY AUTOINCREMENT, shop_id INTEGER NOT NULL, product_id INTEGER NOT NULL, unit_price REAL NOT NULL, order_date TEXT NOT NULL)`
    - Add index: `CREATE INDEX idx_sph ON shop_price_history (shop_id, product_id, order_date DESC)`
    - _Requirements: 5.3, 5.4_

  - [x] 4.3 Bump DB version to 2 and add `onUpgrade` migration
    - Change `version: 1` to `version: 2` in `openDatabase` call
    - Add `onUpgrade: _onUpgrade` parameter
    - Implement `_onUpgrade(Database db, int oldVersion, int newVersion)`: when `oldVersion < 2`, run `ALTER TABLE local_order_items ADD COLUMN units_per_carton INTEGER DEFAULT 1` and create `shop_price_history` table + index
    - _Requirements: 5.3, 6.2_

  - [x] 4.4 Add `getLastThreePrices(shopId, productId)` method
    - Implement `static Future<List<double>> getLastThreePrices(int shopId, int productId)` using `rawQuery` on `shop_price_history` ordered by `order_date DESC LIMIT 3`
    - Return `List<double>` mapped from `unit_price` column
    - _Bug_Condition: isBugCondition_Issue5 — shop.priceEditAllowed = true_
    - _Expected_Behavior: returns up to 3 prices ordered most-recent-first_
    - _Requirements: 5.4_

  - [x] 4.5 Update `saveOrder()` to write price history rows
    - After inserting each `LocalOrderItem`, insert a row into `shop_price_history` with `shop_id`, `product_id`, `unit_price`, `order_date` (today's date as `yyyy-MM-dd`)
    - After inserting, prune rows beyond the 3 most recent per `(shop_id, product_id)` using the `DELETE … NOT IN (SELECT id … ORDER BY order_date DESC LIMIT 3)` pattern from the design
    - _Bug_Condition: isBugCondition_Issue5 — price history never written on save_
    - _Preservation: existing local_orders and local_order_items insert behaviour unchanged_
    - _Requirements: 5.3, 3.8_

  - [x] 4.6 Add `getBookedShopIds(routeId, today)` method
    - Implement `static Future<Set<int>> getBookedShopIds(int routeId, String today)` using `rawQuery` with `SELECT DISTINCT shop_id FROM local_orders WHERE route_id = ? AND created_at_device LIKE ?`
    - Return `Set<int>` of shop IDs
    - _Requirements: 2.2, 2.3, 2.4_

- [x] 5. Fix routes/shops screen (`ob_routes_screen.dart`)

  - [x] 5.1 Load booked shop IDs in `_ShopsScreenState._load()`
    - After loading shops, call `LocalDbService.getBookedShopIds(widget.route.id, today)` where `today` is `DateFormat('yyyy-MM-dd').format(DateTime.now())`
    - Store result in `Set<int> _bookedShopIds` state field (initialise to empty set)
    - _Requirements: 2.2, 2.3, 2.4_

  - [x] 5.2 Add filter toggle state and enum
    - Add `enum _ShopFilter { all, remaining, orderBooked }` (file-level or inside state)
    - Add `_ShopFilter _filter = _ShopFilter.all` field to `_ShopsScreenState`
    - _Requirements: 2.1, 2.4_

  - [x] 5.3 Add filter toggle widget above the shop list
    - Insert a `SegmentedButton<_ShopFilter>` (or `ToggleButtons`) row between the search bar and the list, with segments "All", "Remaining", "Order Booked"
    - On selection change, update `_filter` and call `_applyFilter()`
    - _Requirements: 2.1, 2.4_

  - [x] 5.4 Update `_filter()` to `_applyFilter()` — apply both text search and active filter tab
    - Rename `_filter()` to `_applyFilter()` and update the `_searchCtrl` listener reference
    - Apply text search first, then additionally filter by `_filter` value: `remaining` excludes IDs in `_bookedShopIds`; `orderBooked` includes only IDs in `_bookedShopIds`
    - _Preservation: shop search by name/owner continues to work regardless of active filter tab_
    - _Requirements: 2.4, 3.5_

  - [x] 5.5 Update `_ShopTile` to accept and use `isBooked` flag
    - Add `final bool isBooked` parameter to `_ShopTile`
    - Pass `isBooked: _bookedShopIds.contains(shop.id)` from the list builder
    - Replace `Border.all(color: AppTheme.border)` with `Border.all(color: isBooked ? Colors.green.shade400 : Colors.red.shade300, width: 1.5)`
    - _Requirements: 2.2, 2.3_

  - [x] 5.6 Add shop type badge to `_ShopTile`
    - Add a "Retail" or "Wholesale" chip in the trailing area of `_ShopTile`, next to the existing Recovery badge, using `shop.shopType`
    - Use a neutral blue/grey colour for Retail and a distinct colour (e.g. `AppTheme.accent`) for Wholesale
    - _Preservation: Recovery badge continues to display when hasRecoveryBill is true_
    - _Requirements: 2.5, 3.6_

- [x] 6. Fix order booking screen (`ob_order_booking_screen.dart`)

  - [x] 6.1 Fix price default — use `basePrice` based on shop type
    - In the `itemBuilder` where `_OrderEntry` is initialised, replace `_OrderEntry(price: p.retailPrice)` with: `final basePrice = widget.shop.shopType == 'wholesale' ? p.wholesalePrice : p.retailPrice; final entry = _entries[p.id] ?? _OrderEntry(price: basePrice);`
    - Update `_ProductRow` subtitle to display `basePrice` instead of always `widget.product.retailPrice`
    - _Bug_Condition: isBugCondition_Issue3 — shop.shopType = 'wholesale'_
    - _Expected_Behavior: entry.price = product.wholesalePrice for wholesale shops_
    - _Preservation: retail shops continue to default to retailPrice_
    - _Requirements: 3.1, 3.2_

  - [x] 6.2 Add `basePrice` field to `_ProductRow` and pass it from the list builder
    - Add `final double basePrice` to `_ProductRow` constructor
    - Pass `basePrice: basePrice` (the computed value from 6.1) when constructing each `_ProductRow`
    - Use `widget.basePrice` as the fallback in `_update()` instead of `widget.product.retailPrice`
    - _Requirements: 3.1, 4.1_

  - [x] 6.3 Add price range validation in `_ProductRow._update()`
    - After parsing the price value, if `widget.shopPriceEditAllowed` is true, compute `minAllowed = widget.basePrice * (1 + widget.shopMinPct / 100)` and `maxAllowed = widget.basePrice * (1 + widget.shopMaxPct / 100)`
    - If price is outside `[minAllowed, maxAllowed]`, clamp with `p = p.clamp(minAllowed, maxAllowed)`, update `_priceCtrl.text`, and show a `ScaffoldMessenger` snackbar stating the allowed range
    - _Bug_Condition: isBugCondition_Issue4 — priceEditAllowed AND price outside [min, max]_
    - _Expected_Behavior: stored price clamped to nearest boundary; snackbar shown_
    - _Preservation: when priceEditAllowed is false, no clamping is applied_
    - _Requirements: 4.1, 4.2, 3.2_

  - [x] 6.4 Load price history for price-editable shops in `_load()`
    - If `widget.shop.priceEditAllowed`, after loading products, call `LocalDbService.getLastThreePrices(widget.shop.id, p.id)` for each product
    - Store results in `Map<int, List<double>> _priceHistory` state field
    - Pass `priceHistory: _priceHistory[p.id] ?? []` to each `_ProductRow`
    - _Bug_Condition: isBugCondition_Issue5 — shopLastPrice always null, history never loaded_
    - _Requirements: 5.1, 5.2_

  - [x] 6.5 Display last three prices in expanded `_ProductRow`
    - Replace the single `shopLastPrice` parameter on `_ProductRow` with `final List<double> priceHistory`
    - In the expanded section, when `widget.shopPriceEditAllowed` and `priceHistory.isNotEmpty`, render up to three price chips (e.g. `Rs 90 · Rs 88 · Rs 92`) instead of the single "Last price" hint
    - _Requirements: 5.2_

  - [x] 6.6 Display shop type tag in app bar
    - In `OBOrderBookingScreen.build()`, add a "Retail" or "Wholesale" chip in the app bar `Column` subtitle row alongside the "Order Booking" text, using `widget.shop.shopType`
    - _Requirements: 2.6_

  - [x] 6.7 Accept optional `existingOrder` parameter for edit mode
    - Add `final LocalOrder? existingOrder` to `OBOrderBookingScreen` (null = new order, non-null = edit mode)
    - In `_load()`, if `widget.existingOrder != null`, after loading products, populate `_entries` from existing items using stored `unitPrice` and quantities
    - Store `_localId` as a state field; initialise to `widget.existingOrder?.localId ?? const Uuid().v4()` so edit mode reuses the same UUID
    - Use `_localId` in `_saveOrder()` instead of generating a new UUID each time
    - _Preservation: new order save path (existingOrder == null) unchanged_
    - _Requirements: 8.1, 8.2, 3.3_

  - [x] 6.8 Pass `unitsPerCarton` when constructing `LocalOrderItem` in `_saveOrder()`
    - Add `unitsPerCarton: product.unitsPerCarton` to the `LocalOrderItem(...)` constructor call inside `_saveOrder()`
    - _Requirements: 6.2_

- [x] 7. Fix summary screen (`ob_summary_screen.dart`)

  - [x] 7.1 Display order total on each order card
    - In `_OrdersTab` item builder, add `Text('Rs ${o.total.toStringAsFixed(0)}', ...)` below the `'${o.items.length} products · ...'` line on each card
    - _Bug_Condition: isBugCondition_Issue6 — total was wrong before model fix; now correct after task 3.2_
    - _Requirements: 6.1_

  - [x] 7.2 Add grand total sticky footer to `_OrdersTab`
    - Compute `grandTotal = orders.fold(0.0, (s, o) => s + o.total)` in `_OrdersTab.build()`
    - Wrap the `ListView` in a `Column`; add a `Container` footer below it showing `Grand Total: Rs ${grandTotal.toStringAsFixed(0)}` with a prominent style
    - _Requirements: 7.1_

  - [x] 7.3 Make pending order cards tappable (edit mode)
    - Wrap each order card `Container` in an `InkWell` (or `GestureDetector`)
    - On tap, if `o.status == 'pending_sync'`: call `LocalDbService.getShop(o.shopId)` to retrieve the `LocalShop`, then push `OBOrderBookingScreen(shop: shop, existingOrder: o)`
    - If `getShop` returns null, show a snackbar error
    - _Requirements: 8.1, 8.2_

- [x] 8. Verify bug condition exploration tests now pass
  - [x] 8.1 Re-run wholesale price default test
    - **Property 1: Expected Behavior** - Wholesale Price Default
    - **IMPORTANT**: Re-run the SAME test from task 1 — do NOT write a new test
    - Run on fixed code after task 6.1 is complete
    - **EXPECTED OUTCOME**: Test PASSES (confirms wholesale price default is fixed)
    - _Requirements: 3.1_

  - [x] 8.2 Re-run price range clamping test
    - **Property 1: Expected Behavior** - Price Range Clamping
    - Re-run the SAME test from task 1 after task 6.3 is complete
    - **EXPECTED OUTCOME**: Test PASSES (confirms out-of-range prices are clamped)
    - _Requirements: 4.1, 4.2_

  - [x] 8.3 Re-run order total formula test
    - **Property 1: Expected Behavior** - Order Total Formula
    - Re-run the SAME test from task 1 after tasks 3.1, 3.2, and 6.8 are complete
    - **EXPECTED OUTCOME**: Test PASSES (confirms total uses unitsPerCarton multiplier)
    - _Requirements: 6.2_

- [x] 9. Verify preservation tests still pass
  - **Property 2: Preservation** - Retail Price, Read-Only Field, Zero-Carton Total
  - **IMPORTANT**: Re-run the SAME tests from task 2 — do NOT write new tests
  - Run after all implementation tasks (3–7) are complete
  - **EXPECTED OUTCOME**: All three preservation tests PASS (confirms no regressions)
  - _Requirements: 3.1, 3.2, 3.3_

- [x] 10. Checkpoint — Ensure all tests pass
  - Run the full test suite (unit tests + property-based tests)
  - Verify exploration tests (task 8) all pass — bugs are fixed
  - Verify preservation tests (task 9) all pass — no regressions
  - Manually verify the integration flows from the design: wholesale shop price default → price range clamping → save order → price history written → summary total correct → grand total shown → pending card tappable → edit and re-save uses same localId
  - Ask the user if any questions arise
