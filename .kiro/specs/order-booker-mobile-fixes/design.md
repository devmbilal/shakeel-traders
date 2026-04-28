# Order Booker Mobile App — Bugfix Design

## Overview

Eight interconnected defects in the Order Booker Flutter app are fixed together. The bugs span
shop browsing (`ob_routes_screen.dart`), order booking (`ob_order_booking_screen.dart`), the
summary screen (`ob_summary_screen.dart`), the data models (`models.dart`), and the SQLite
service (`local_db_service.dart`). Several bugs compound each other — the wrong-price bug
(Issue 3) and the price-range bug (Issue 4) both depend on correctly identifying shop type,
which is also the subject of the missing-tag bug (Issue 2). The fix strategy is therefore
applied as a single coordinated change across all five files, with a DB schema migration from
version 1 to version 2.

---

## Glossary

- **Bug_Condition (C)**: The set of runtime inputs or states that trigger a defect.
- **Property (P)**: The correct observable behaviour that must hold after the fix.
- **Preservation**: Existing correct behaviour that must remain unchanged by the fix.
- **basePrice**: The correct unit price for a shop — `wholesalePrice` for wholesale shops,
  `retailPrice` for retail shops.
- **minAllowed / maxAllowed**: The price-range boundaries computed as
  `basePrice * (1 + priceMinPct / 100)` and `basePrice * (1 + priceMaxPct / 100)`.
- **LocalOrder.total**: The monetary total of an order, correctly computed as
  `SUM((cartons * unitsPerCarton + looseUnits) * unitPrice)` per item.
- **shop_price_history**: New SQLite table (DB v2) that stores up to three historical prices
  per `(shop_id, product_id)` pair, ordered by `order_date DESC`.
- **edit mode**: Opening `OBOrderBookingScreen` with an existing `LocalOrder` pre-populated
  so the Order Booker can correct a pending order.
- **booked shop**: A shop that has at least one `LocalOrder` in `local_orders` for today.
- **remaining shop**: A shop with no `LocalOrder` in `local_orders` for today.

---

## Bug Details

### Bug Condition

The eight bugs are formalised as four distinct bug conditions (Issues 2 and 7 are pure UI
omissions with no conditional trigger; Issues 1 and 8 are always-missing features).

**Formal Specification:**

```
FUNCTION isBugCondition_Issue3(shop, product)
  INPUT: shop of type LocalShop, product of type LocalProduct
  OUTPUT: boolean
  // Wrong price default — triggers for every wholesale shop
  RETURN shop.shopType = 'wholesale'
END FUNCTION

FUNCTION isBugCondition_Issue4(entry, shop, product)
  INPUT: entry of type _OrderEntry, shop of type LocalShop, product of type LocalProduct
  OUTPUT: boolean
  basePrice ← IF shop.shopType = 'wholesale'
              THEN product.wholesalePrice
              ELSE product.retailPrice
  minAllowed ← basePrice * (1 + shop.priceMinPct / 100)
  maxAllowed ← basePrice * (1 + shop.priceMaxPct / 100)
  RETURN shop.priceEditAllowed
         AND (entry.price < minAllowed OR entry.price > maxAllowed)
END FUNCTION

FUNCTION isBugCondition_Issue6(order)
  INPUT: order of type LocalOrder
  OUTPUT: boolean
  // Wrong total formula — triggers whenever any item has cartons > 0
  RETURN order.items.any(i => i.cartons > 0)
END FUNCTION

FUNCTION isBugCondition_Issue5(shop)
  INPUT: shop of type LocalShop
  OUTPUT: boolean
  // Price history never loaded — triggers for every price-editable shop
  RETURN shop.priceEditAllowed = true
END FUNCTION
```

### Examples

- **Issue 3**: Wholesale shop, product with `retailPrice = 100`, `wholesalePrice = 85`.
  Current: entry initialised with price `100`. Expected: price `85`.
- **Issue 4**: Shop with `priceMinPct = -5`, `priceMaxPct = 10`, `basePrice = 100`.
  Order Booker types `50`. Current: saved as `50`. Expected: clamped to `95`, snackbar shown.
- **Issue 6**: Order item with `cartons = 2`, `unitsPerCarton = 12`, `looseUnits = 3`,
  `unitPrice = 10`. Current total: `2*10 + 3*10 = 50`. Expected: `(2*12+3)*10 = 270`.
- **Issue 5**: Price-editable shop, product previously ordered at Rs 90.
  Current: expanded row shows nothing. Expected: "Rs 90" shown as last price.
- **Issue 1**: Shop list rendered. Current: flat list, no filter, no border colour.
  Expected: filter toggle (All / Remaining / Order Booked), green/red borders.
- **Issue 2**: Shop tile rendered. Current: no type badge. Expected: "Retail" or "Wholesale" badge.
- **Issue 7**: Orders tab rendered. Current: no grand total. Expected: sticky footer with sum.
- **Issue 8**: Pending order tapped. Current: nothing happens. Expected: booking screen opens pre-populated.

---

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Retail shops continue to default all product prices to `retailPrice` (Issue 3 fix must not
  affect retail shops).
- When `priceEditAllowed` is false, the price field remains read-only and no range clamping
  is applied (Issue 4 fix is gated on `priceEditAllowed`).
- Saving an order with valid quantities and prices continues to call
  `LocalDbService.saveOrder()` and pop the screen (Issue 8 edit mode reuses the same save path).
- Product search by SKU or name in `OBOrderBookingScreen` continues to work correctly.
- Shop search by name or owner in `_ShopsScreen` continues to work regardless of active filter.
- The "Recovery" badge on shop tiles continues to display when `hasRecoveryBill` is true.
- The Recovery tab in `OBSummaryScreen` continues to display recovery assignments unchanged.
- Morning sync continues to populate `shop_last_prices` without disrupting `shop_price_history`.
- The order summary bottom sheet inside `OBOrderBookingScreen` (which already uses the correct
  inline formula) continues to compute the correct total.

**Scope:**
All inputs that do NOT satisfy any of the four bug conditions above are completely unaffected
by this fix. This includes retail shop price initialisation, read-only price fields, orders
with zero cartons, and non-price-editable shops.

---

## Hypothesized Root Cause

1. **Hardcoded `retailPrice` in `_OrderEntry` initialisation** (`ob_order_booking_screen.dart`
   line `_OrderEntry(price: p.retailPrice)`): The shop type is available via `widget.shop.shopType`
   but is never consulted when setting the default price.

2. **Missing `unitsPerCarton` on `LocalOrderItem`** (`models.dart`): `LocalOrder.total` cannot
   apply the correct formula because `unitsPerCarton` is a `LocalProduct` field that is not
   copied onto the order item at save time. The getter therefore falls back to
   `cartons * unitPrice` instead of `cartons * unitsPerCarton * unitPrice`.

3. **No price range validation in `_update()`** (`ob_order_booking_screen.dart`): The method
   parses the raw text field value and calls `onChanged` immediately with no clamping logic.
   `shopMinPct` and `shopMaxPct` are passed to `_ProductRow` but never used.

4. **`shopLastPrice` always passed as `null`** (`ob_order_booking_screen.dart`): The comment
   `// loaded lazily` indicates intent that was never implemented. No async load of price
   history is triggered, and the `shop_last_prices` table stores only one row per
   `(shop_id, product_id)`, making three-price history structurally impossible.

5. **No `shop_price_history` table** (`local_db_service.dart`): The DB schema (v1) has no
   table for multi-row price history. `saveOrder()` does not write any price record.

6. **No booked-shop query** (`local_db_service.dart`): There is no method to retrieve which
   shop IDs have orders today, so `_ShopsScreen` cannot colour-code tiles or filter by status.

7. **No filter UI in `_ShopsScreen`** (`ob_routes_screen.dart`): The screen has a search bar
   but no toggle for All / Remaining / Order Booked.

8. **No shop type badge** in `_ShopTile` or `OBOrderBookingScreen` app bar.

9. **No order total on summary card** and no grand total footer in `_OrdersTab`.

10. **No tap handler on pending order cards** in `_OrdersTab`; `OBOrderBookingScreen` has no
    `existingOrder` parameter.

---

## Correctness Properties

Property 1: Bug Condition — Wholesale Price Default

_For any_ product entry initialised for a wholesale shop (`isBugCondition_Issue3` returns
true), the fixed `OBOrderBookingScreen` SHALL set the initial `_OrderEntry.price` to
`product.wholesalePrice`, not `product.retailPrice`.

**Validates: Requirements 3.1**

---

Property 2: Bug Condition — Price Range Clamping

_For any_ price edit where `isBugCondition_Issue4` returns true (price-editable shop, entered
price outside `[minAllowed, maxAllowed]`), the fixed `_update()` SHALL clamp the stored price
to the nearest boundary and display a snackbar informing the Order Booker of the allowed range.

**Validates: Requirements 4.1, 4.2**

---

Property 3: Bug Condition — Correct Order Total

_For any_ order where `isBugCondition_Issue6` returns true (at least one item with cartons > 0),
the fixed `LocalOrder.total` getter SHALL evaluate
`SUM((i.cartons * i.unitsPerCarton + i.looseUnits) * i.unitPrice)` and return the correct
monetary total.

**Validates: Requirements 6.1, 6.2**

---

Property 4: Bug Condition — Price History Loaded and Displayed

_For any_ price-editable shop (`isBugCondition_Issue5` returns true), the fixed
`OBOrderBookingScreen` SHALL load up to three historical prices per product from
`shop_price_history` and pass them to each `_ProductRow`, which SHALL display them in the
expanded section.

**Validates: Requirements 5.1, 5.2, 5.3, 5.4**

---

Property 5: Preservation — Retail Shop Price Unaffected

_For any_ product entry initialised for a retail shop (`shop.shopType != 'wholesale'`), the
fixed initialisation SHALL produce the same `_OrderEntry.price` as the original code
(`product.retailPrice`).

**Validates: Requirements 3.1 (unchanged behaviour clause)**

---

Property 6: Preservation — Read-Only Price Field Unaffected

_For any_ shop where `priceEditAllowed` is false, the fixed `_update()` SHALL produce the
same stored price as the original code — no clamping is applied and the price field remains
read-only.

**Validates: Requirements 3.2 (unchanged behaviour clause)**

---

Property 7: Preservation — Order Save Behaviour Unchanged

_For any_ new order (not edit mode) with valid quantities and prices, the fixed
`LocalDbService.saveOrder()` SHALL insert into `local_orders` and `local_order_items` exactly
as before, and additionally insert price history rows into `shop_price_history`.

**Validates: Requirements 3.3, 3.8**

---

## Fix Implementation

### Changes Required

#### File: `mobile-app/lib/models/models.dart`

**1. Add `unitsPerCarton` to `LocalOrderItem`**

Add `final int unitsPerCarton;` field. Update constructor, `fromMap`, and `toMap` to include
`units_per_carton`. This allows `LocalOrder.total` to use the correct formula without needing
a product lookup.

**2. Fix `LocalOrder.total` getter**

Change:
```dart
// WRONG
double get total => items.fold(0,
    (sum, i) => sum + (i.cartons * i.unitPrice) + (i.looseUnits * i.unitPrice));
```
To:
```dart
// CORRECT
double get total => items.fold(0,
    (sum, i) => sum + (i.cartons * i.unitsPerCarton + i.looseUnits) * i.unitPrice);
```

**3. Add `ShopPriceHistory` model**

New class with fields: `shopId`, `productId`, `unitPrice`, `orderDate`. Includes
`fromMap` / `toMap`. Used by `getLastThreePrices()` and `saveOrder()`.

---

#### File: `mobile-app/lib/services/local_db_service.dart`

**4. Bump DB version to 2, add `onUpgrade`**

```dart
version: 2,
onUpgrade: _onUpgrade,
```

`_onUpgrade` runs when `oldVersion < 2`:
- `ALTER TABLE local_order_items ADD COLUMN units_per_carton INTEGER DEFAULT 1`
- `CREATE TABLE shop_price_history (id INTEGER PRIMARY KEY AUTOINCREMENT, shop_id INTEGER NOT NULL, product_id INTEGER NOT NULL, unit_price REAL NOT NULL, order_date TEXT NOT NULL)`
- `CREATE INDEX idx_sph ON shop_price_history (shop_id, product_id, order_date DESC)`

**5. Add `shop_price_history` table to `_onCreate`**

Include the same DDL so fresh installs also get the table.

**6. Add `units_per_carton` column to `local_order_items` in `_onCreate`**

**7. Add `getLastThreePrices(shopId, productId)` method**

```dart
static Future<List<double>> getLastThreePrices(int shopId, int productId) async {
  final d = await db;
  final rows = await d.rawQuery(
    'SELECT unit_price FROM shop_price_history '
    'WHERE shop_id = ? AND product_id = ? '
    'ORDER BY order_date DESC LIMIT 3',
    [shopId, productId],
  );
  return rows.map((r) => (r['unit_price'] as num).toDouble()).toList();
}
```

**8. Update `saveOrder()` to write price history**

After inserting order items, for each item:
1. Insert a row into `shop_price_history`.
2. Delete rows beyond the three most recent for that `(shop_id, product_id)`:
   ```sql
   DELETE FROM shop_price_history
   WHERE shop_id = ? AND product_id = ?
     AND id NOT IN (
       SELECT id FROM shop_price_history
       WHERE shop_id = ? AND product_id = ?
       ORDER BY order_date DESC LIMIT 3
     )
   ```

**9. Add `getOrdersByShopToday(routeId, today)` method**

Returns a `Set<int>` of shop IDs that have at least one order today for the given route.
Used by `_ShopsScreen` to determine green/red borders and filter state.

```dart
static Future<Set<int>> getBookedShopIds(int routeId, String today) async {
  final d = await db;
  final rows = await d.rawQuery(
    'SELECT DISTINCT shop_id FROM local_orders '
    'WHERE route_id = ? AND created_at_device LIKE ?',
    [routeId, '$today%'],
  );
  return rows.map((r) => (r['shop_id'] as int)).toSet();
}
```

---

#### File: `mobile-app/lib/screens/order_booker/ob_routes_screen.dart`

**10. Load booked shop IDs in `_ShopsScreenState._load()`**

After loading shops, call `LocalDbService.getBookedShopIds(routeId, today)` and store the
result in `Set<int> _bookedShopIds`.

**11. Add filter toggle state**

Add `_ShopFilter _filter = _ShopFilter.all` enum field. Three values: `all`, `remaining`,
`orderBooked`.

**12. Add filter toggle widget above the shop list**

A `SegmentedButton` or `ToggleButtons` row with "All", "Remaining", "Order Booked" labels.
Tapping updates `_filter` and calls `_applyFilter()`.

**13. Update `_applyFilter()` (replaces `_filter()` method)**

Applies both the text search and the active filter tab:
- `all`: no additional filter
- `remaining`: exclude shops whose ID is in `_bookedShopIds`
- `orderBooked`: include only shops whose ID is in `_bookedShopIds`

**14. Update `_ShopTile` to accept `isBooked` flag**

Pass `isBooked: _bookedShopIds.contains(shop.id)` from the list builder.

**15. Green/red border on `_ShopTile`**

```dart
border: Border.all(
  color: isBooked ? Colors.green.shade400 : Colors.red.shade300,
  width: 1.5,
),
```

**16. Shop type badge on `_ShopTile`**

Add a "Retail" or "Wholesale" chip next to the Recovery badge, using `shop.shopType`.

---

#### File: `mobile-app/lib/screens/order_booker/ob_order_booking_screen.dart`

**17. Accept optional `existingOrder` parameter**

```dart
class OBOrderBookingScreen extends StatefulWidget {
  final LocalShop shop;
  final LocalOrder? existingOrder; // null = new order, non-null = edit mode
  const OBOrderBookingScreen({super.key, required this.shop, this.existingOrder});
}
```

**18. Pre-populate `_entries` from `existingOrder` in `_load()`**

If `widget.existingOrder != null`, after loading products, populate `_entries` from the
existing items using the stored `unitPrice` and quantities. Reuse `existingOrder.localId`
instead of generating a new UUID.

**19. Fix price default — use `basePrice` based on shop type**

```dart
final basePrice = widget.shop.shopType == 'wholesale'
    ? p.wholesalePrice
    : p.retailPrice;
final entry = _entries[p.id] ?? _OrderEntry(price: basePrice);
```

**20. Load price history for price-editable shops**

In `_load()`, if `widget.shop.priceEditAllowed`, call `getLastThreePrices` for each product
and store in `Map<int, List<double>> _priceHistory`. Pass to `_ProductRow` as
`priceHistory: _priceHistory[p.id] ?? []`.

**21. Add price range validation in `_ProductRow._update()`**

```dart
void _update() {
  final c = int.tryParse(_cartonsCtrl.text) ?? 0;
  final l = int.tryParse(_looseCtrl.text) ?? 0;
  double p = double.tryParse(_priceCtrl.text) ?? widget.basePrice;
  if (widget.shopPriceEditAllowed) {
    final minAllowed = widget.basePrice * (1 + widget.shopMinPct / 100);
    final maxAllowed = widget.basePrice * (1 + widget.shopMaxPct / 100);
    if (p < minAllowed || p > maxAllowed) {
      p = p.clamp(minAllowed, maxAllowed);
      _priceCtrl.text = p.toStringAsFixed(0);
      // show snackbar via callback or ScaffoldMessenger
    }
  }
  widget.onChanged(widget.entry.copyWith(cartons: c, loose: l, price: p));
}
```

**22. Pass `basePrice` to `_ProductRow`**

Add `final double basePrice` field to `_ProductRow` so the validation can reference it.

**23. Display shop type tag in app bar**

Add a "Retail" or "Wholesale" chip in the app bar subtitle row alongside "Order Booking".

**24. Display last three prices in expanded `_ProductRow`**

Replace the single "Last price" hint with up to three price chips when
`shopPriceEditAllowed` is true and `priceHistory` is non-empty.

**25. Pass `unitsPerCarton` when constructing `LocalOrderItem` in `_saveOrder()`**

```dart
return LocalOrderItem(
  ...
  unitsPerCarton: product.unitsPerCarton,  // NEW
  unitPrice: e.value.price,
);
```

---

#### File: `mobile-app/lib/screens/order_booker/ob_summary_screen.dart`

**26. Display order total on each order card**

In `_OrdersTab` item builder, add `Rs ${o.total.toStringAsFixed(0)}` below the product count
line on each card.

**27. Add grand total sticky footer**

Compute `grandTotal = orders.fold(0.0, (s, o) => s + o.total)` in `_OrdersTab.build()`.
Wrap the `ListView` in a `Column` with a `Container` footer showing the grand total.

**28. Make pending order cards tappable**

Wrap the card `Container` in a `GestureDetector` (or `InkWell`). On tap, if
`o.status == 'pending_sync'`, push `OBOrderBookingScreen(shop: ..., existingOrder: o)`.
Requires loading the `LocalShop` for the order (add `LocalDbService.getShop(o.shopId)`).

---

## Testing Strategy

### Validation Approach

Testing follows a two-phase approach: first surface counterexamples on unfixed code to confirm
root cause analysis, then verify the fix and preservation properties.

---

### Exploratory Bug Condition Checking

**Goal**: Demonstrate each bug on unfixed code before applying the fix.

**Test Cases**:

1. **Wholesale price default** (Issue 3): Construct `_OrderEntry` for a wholesale shop with
   `retailPrice = 100`, `wholesalePrice = 85`. Assert `entry.price == 85`. Will fail on
   unfixed code (returns `100`).

2. **Price range clamping** (Issue 4): Call `_update()` with price `50` on a shop with
   `priceMinPct = -5`, `basePrice = 100`. Assert stored price `>= 95`. Will fail on unfixed
   code (stores `50`).

3. **Order total formula** (Issue 6): Create `LocalOrderItem` with `cartons = 2`,
   `unitsPerCarton = 12`, `looseUnits = 3`, `unitPrice = 10`. Assert `order.total == 270`.
   Will fail on unfixed code (returns `50`).

4. **Price history written on save** (Issue 5): Save an order, then call
   `getLastThreePrices(shopId, productId)`. Assert result is non-empty. Will fail on unfixed
   code (table does not exist / no rows written).

**Expected Counterexamples**:
- `entry.price` equals `retailPrice` for wholesale shops.
- Out-of-range prices are stored verbatim.
- `order.total` ignores `unitsPerCarton`.
- `getLastThreePrices` returns empty list or throws.

---

### Fix Checking

**Goal**: Verify that for all inputs where a bug condition holds, the fixed code produces the
expected behaviour.

**Pseudocode:**

```
// Issue 3
FOR ALL (shop, product) WHERE isBugCondition_Issue3(shop, product) DO
  entry ← initialiseEntry_fixed(shop, product)
  ASSERT entry.price = product.wholesalePrice
END FOR

// Issue 4
FOR ALL (entry, shop, product) WHERE isBugCondition_Issue4(entry, shop, product) DO
  result ← update_fixed(entry, shop, product)
  basePrice ← IF shop.shopType = 'wholesale' THEN product.wholesalePrice ELSE product.retailPrice
  ASSERT result.price >= basePrice * (1 + shop.priceMinPct / 100)
  ASSERT result.price <= basePrice * (1 + shop.priceMaxPct / 100)
END FOR

// Issue 6
FOR ALL order WHERE isBugCondition_Issue6(order) DO
  ASSERT order.total_fixed = SUM((i.cartons * i.unitsPerCarton + i.looseUnits) * i.unitPrice)
END FOR

// Issue 5
FOR ALL shop WHERE isBugCondition_Issue5(shop) DO
  // after saving an order for that shop
  prices ← getLastThreePrices_fixed(shop.id, productId)
  ASSERT prices.length <= 3
  ASSERT prices.length >= 1
END FOR
```

---

### Preservation Checking

**Goal**: Verify that for all inputs where a bug condition does NOT hold, the fixed code
produces the same result as the original code.

**Pseudocode:**

```
// Retail shops unaffected by Issue 3 fix
FOR ALL (shop, product) WHERE shop.shopType != 'wholesale' DO
  ASSERT initialiseEntry_fixed(shop, product).price
       = initialiseEntry_original(shop, product).price
END FOR

// Read-only price field unaffected by Issue 4 fix
FOR ALL shop WHERE NOT shop.priceEditAllowed DO
  ASSERT update_fixed(entry, shop, product).price = entry.price
END FOR

// Order save behaviour unchanged for new orders
FOR ALL order WHERE order is new (not edit mode) DO
  ASSERT saveOrder_fixed(order) produces same local_orders + local_order_items rows
         as saveOrder_original(order)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because
it generates many random inputs automatically, catching edge cases that manual tests miss, and
provides strong guarantees that behaviour is unchanged for all non-buggy inputs.

**Test Cases**:

1. **Retail price preservation**: Generate random retail shops and products; verify default
   price is always `retailPrice` after fix.
2. **Read-only field preservation**: Generate random shops with `priceEditAllowed = false`;
   verify price is never clamped.
3. **Order save preservation**: Generate random orders with zero cartons; verify `total` is
   unchanged (all loose units, no carton multiplier needed).

---

### Unit Tests

- Test `LocalOrder.total` with items having `cartons > 0` and `unitsPerCarton > 1`.
- Test `LocalOrder.total` with items having only `looseUnits` (cartons = 0).
- Test price default for wholesale shop vs retail shop.
- Test price clamping at lower boundary, upper boundary, and within range.
- Test `getLastThreePrices` returns at most 3 rows ordered by `order_date DESC`.
- Test that saving a 4th price for the same `(shop_id, product_id)` drops the oldest row.
- Test `getBookedShopIds` returns correct set for today's orders.

### Property-Based Tests

- Generate random `(cartons, unitsPerCarton, looseUnits, unitPrice)` tuples; verify
  `total_fixed = (cartons * unitsPerCarton + looseUnits) * unitPrice`.
- Generate random retail shops and products; verify `initialiseEntry_fixed.price = retailPrice`.
- Generate random price inputs within `[minAllowed, maxAllowed]`; verify no clamping occurs
  and price is stored as-is.
- Generate random price inputs outside `[minAllowed, maxAllowed]`; verify clamped price is
  always within bounds.

### Integration Tests

- Full flow: open wholesale shop → verify product prices default to `wholesalePrice` → enter
  out-of-range price → verify clamped → save order → verify `shop_price_history` row written
  → re-open summary → verify order total correct → verify grand total updated.
- Edit flow: save order → tap pending card in summary → verify booking screen pre-populated →
  modify quantity → re-save → verify same `localId` in DB (replace semantics).
- Filter flow: book one shop → return to shop list → verify green border on booked shop, red
  on others → select "Remaining" filter → verify booked shop hidden → select "Order Booked" →
  verify only booked shop shown.
