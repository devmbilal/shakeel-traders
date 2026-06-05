# Bugfix Requirements Document

## Introduction

The Order Booker Mobile App (Flutter) has eight interconnected UX, UI, and business logic defects that can cause financial loss. These span the shop browsing screen, the order booking screen, the summary screen, and the underlying SQLite data layer. The fixes must be applied together because several bugs compound each other — for example, the wrong price bug (Issue 3) and the missing price range validation bug (Issue 4) both depend on correctly identifying shop type, which is also affected by the missing shop type display bug (Issue 2).

---

## Bug Analysis

### Current Behavior (Defect)

**Issue 1 — Shop Filtration: No Visited/Unvisited Distinction**

1.1 WHEN an Order Booker views the shops list in `_ShopsScreen`, THEN the system shows all shops in a flat list with no filter controls and no visual distinction between shops that already have an order booked today and shops that have not yet been visited.

1.2 WHEN a shop has an order saved in `local_orders` for today, THEN the system renders its tile with the same neutral border as every other shop, giving no visual confirmation that the shop has been served.

**Issue 2 — Shop Type Tag Not Displayed**

2.1 WHEN an Order Booker views a shop tile in `_ShopsScreen`, THEN the system does not display the shop's type (Retail or Wholesale) anywhere on the tile, even though `LocalShop.shopType` is available.

2.2 WHEN an Order Booker opens `OBOrderBookingScreen` for a shop, THEN the system does not display the shop type in the app bar or anywhere on the screen header.

**Issue 3 — Wrong Price Used for Wholesale Shops**

3.1 WHEN `OBOrderBookingScreen` initialises a product entry for a wholesale shop, THEN the system always sets the default price to `p.retailPrice` regardless of `widget.shop.shopType`, causing wholesale shops to be booked at retail prices.

3.2 WHEN the product row subtitle is rendered in `_ProductRow`, THEN the system always displays `widget.product.retailPrice` regardless of shop type, so the price shown to the Order Booker is incorrect for wholesale shops.

**Issue 4 — Price Editing Range Not Enforced**

4.1 WHEN `shopPriceEditAllowed` is true and the Order Booker types a price in the price field, THEN the system calls `_update()` which parses the raw input with no min/max validation, allowing any arbitrary price to be saved to the order.

4.2 WHEN the entered price is below `basePrice * (1 + priceMinPct / 100)` or above `basePrice * (1 + priceMaxPct / 100)`, THEN the system silently accepts the out-of-range value and stores it in `_OrderEntry.price`.

**Issue 5 — Previous 3 Prices Not Shown for Price-Editable Shops**

5.1 WHEN `OBOrderBookingScreen` builds a `_ProductRow` for any product, THEN the system always passes `shopLastPrice: null` because the value is never loaded, so the "Last price" hint is never shown.

5.2 WHEN `LocalDbService.getLastPrice()` is called, THEN the system returns only a single historical price because `shop_last_prices` stores at most one row per `(shop_id, product_id)` pair, making it impossible to display the last three prices.

5.3 WHEN a new order is saved via `LocalDbService.saveOrder()`, THEN the system does not write any price history record, so the `shop_last_prices` table is never updated from locally booked orders.

**Issue 6 — Order Total Not Shown Per Shop in Summary**

6.1 WHEN `_OrdersTab` renders an order card in `ob_summary_screen.dart`, THEN the system does not display the monetary total for that order anywhere on the card.

6.2 WHEN `LocalOrder.total` is computed, THEN the system evaluates `cartons * unitPrice + loose * unitPrice` instead of `(cartons * unitsPerCarton + loose) * unitPrice`, producing an incorrect total that ignores the units-per-carton multiplier for carton quantities.

**Issue 7 — Grand Total Not Shown in Summary**

7.1 WHEN the Order Booker views the Orders tab in `OBSummaryScreen`, THEN the system shows no aggregate total for all orders booked during the day, making it impossible to know the day's total booking value at a glance.

**Issue 8 — Order Cannot Be Edited After Saving**

8.1 WHEN an order with status `pending_sync` is displayed in `_OrdersTab`, THEN the system renders it as a read-only card with no tap action and no edit affordance, so the Order Booker cannot correct a mistake.

8.2 WHEN the Order Booker taps a pending order card in the summary screen, THEN the system does nothing — `OBOrderBookingScreen` is never opened with the existing order items pre-populated.

---

### Expected Behavior (Correct)

**Issue 1 — Shop Filtration**

2.1 WHEN an Order Booker views `_ShopsScreen`, THEN the system SHALL display a filter toggle with three options: All, Remaining, and Order Booked, defaulting to All.

2.2 WHEN a shop has an order saved in `local_orders` for today, THEN the system SHALL render its tile with a green border to indicate it has been served.

2.3 WHEN a shop has no order saved in `local_orders` for today, THEN the system SHALL render its tile with a red border to indicate it is still remaining.

2.4 WHEN the Order Booker selects the "Remaining" filter, THEN the system SHALL show only shops with no order booked today; WHEN "Order Booked" is selected, THEN the system SHALL show only shops that have an order today.

**Issue 2 — Shop Type Tag**

2.5 WHEN an Order Booker views a shop tile in `_ShopsScreen`, THEN the system SHALL display a "Retail" or "Wholesale" badge on the tile based on `LocalShop.shopType`.

2.6 WHEN an Order Booker opens `OBOrderBookingScreen`, THEN the system SHALL display the shop type tag in the app bar subtitle area alongside the "Order Booking" label.

**Issue 3 — Correct Price for Shop Type**

3.1 WHEN `OBOrderBookingScreen` initialises a product entry, THEN the system SHALL set the default price to `p.wholesalePrice` if `widget.shop.shopType == 'wholesale'`, and to `p.retailPrice` otherwise.

3.2 WHEN the product row subtitle is rendered in `_ProductRow`, THEN the system SHALL display the price that matches the shop type passed to the row widget.

**Issue 4 — Price Range Validation**

4.1 WHEN `shopPriceEditAllowed` is true and `_update()` is called, THEN the system SHALL compute `basePrice * (1 + shopMinPct / 100)` as `minAllowed` and `basePrice * (1 + shopMaxPct / 100)` as `maxAllowed`, where `basePrice` is the correct price for the shop type.

4.2 WHEN the entered price is outside `[minAllowed, maxAllowed]`, THEN the system SHALL clamp the price to the nearest boundary and display a validation message informing the Order Booker of the allowed range.

**Issue 5 — Last Three Prices**

5.1 WHEN `OBOrderBookingScreen` loads products for a shop where `priceEditAllowed` is true, THEN the system SHALL query the last three historical prices per product for that shop and pass them to each `_ProductRow`.

5.2 WHEN `_ProductRow` is expanded for a price-editable shop and historical prices exist, THEN the system SHALL display up to three previous prices in the expanded section.

5.3 WHEN a new order is saved, THEN the system SHALL insert a row into `shop_price_history` for each order item, recording `shop_id`, `product_id`, `price`, and `order_date`, retaining only the three most recent rows per `(shop_id, product_id)`.

5.4 WHEN `LocalDbService` is called to retrieve price history, THEN the system SHALL expose a `getLastThreePrices(shopId, productId)` method that returns up to three prices ordered by `order_date DESC`.

**Issue 6 — Order Total on Summary Card**

6.1 WHEN `_OrdersTab` renders an order card, THEN the system SHALL display the order total as `Rs [amount]` on the card.

6.2 WHEN `LocalOrder.total` is computed, THEN the system SHALL evaluate `(i.cartons * unitsPerCarton + i.looseUnits) * i.unitPrice` per item, requiring `unitsPerCarton` to be stored on `LocalOrderItem` so the correct formula can be applied.

**Issue 7 — Grand Total**

7.1 WHEN the Order Booker views the Orders tab, THEN the system SHALL display the sum of all order totals for the day as a grand total, prominently shown as a sticky footer or in the app bar.

**Issue 8 — Order Edit**

8.1 WHEN the Order Booker taps a `pending_sync` order card in `_OrdersTab`, THEN the system SHALL navigate to `OBOrderBookingScreen` with the existing order items pre-populated in `_entries` so the Order Booker can modify and re-save.

8.2 WHEN a pre-populated order is re-saved, THEN the system SHALL overwrite the existing `local_orders` and `local_order_items` records using the same `localId` (via `ConflictAlgorithm.replace`), preserving the original order identity.

---

### Unchanged Behavior (Regression Prevention)

3.1 WHEN an Order Booker views a retail shop, THEN the system SHALL CONTINUE TO default all product prices to `retailPrice` as before.

3.2 WHEN `shopPriceEditAllowed` is false, THEN the system SHALL CONTINUE TO render the price field as read-only with no range validation applied.

3.3 WHEN the Order Booker saves an order with valid quantities and prices, THEN the system SHALL CONTINUE TO save the order locally via `LocalDbService.saveOrder()` and pop the screen.

3.4 WHEN the Order Booker searches for products by SKU or name in `OBOrderBookingScreen`, THEN the system SHALL CONTINUE TO filter the product list correctly.

3.5 WHEN the Order Booker searches for shops by name or owner in `_ShopsScreen`, THEN the system SHALL CONTINUE TO filter the shop list correctly regardless of the active filter tab.

3.6 WHEN a shop has a recovery bill, THEN the system SHALL CONTINUE TO display the "Recovery" badge on the shop tile.

3.7 WHEN the Order Booker views the Recovery tab in `OBSummaryScreen`, THEN the system SHALL CONTINUE TO display recovery assignments unchanged.

3.8 WHEN `LocalDbService.saveOrder()` is called for a new order, THEN the system SHALL CONTINUE TO insert into `local_orders` and `local_order_items` as before.

3.9 WHEN the morning Sync downloads `shop_last_prices`, THEN the system SHALL CONTINUE TO populate the existing `shop_last_prices` table without disruption to the new `shop_price_history` table.

3.10 WHEN `LocalOrder.total` is fixed, THEN the system SHALL CONTINUE TO compute the correct total in the existing order summary bottom sheet inside `OBOrderBookingScreen` (which already uses the correct formula inline).

---

## Bug Condition Pseudocode

### Bug Condition Functions

```pascal
FUNCTION isBugCondition_Issue1(shop, todayOrders)
  INPUT: shop of type LocalShop, todayOrders of type List<LocalOrder>
  OUTPUT: boolean
  // Bug triggers when shop list is rendered — always true (filter UI is always missing)
  RETURN true
END FUNCTION

FUNCTION isBugCondition_Issue3(shop, product)
  INPUT: shop of type LocalShop, product of type LocalProduct
  OUTPUT: boolean
  RETURN shop.shopType = 'wholesale'
END FUNCTION

FUNCTION isBugCondition_Issue4(entry, shop, product)
  INPUT: entry of type _OrderEntry, shop of type LocalShop, product of type LocalProduct
  OUTPUT: boolean
  basePrice ← IF shop.shopType = 'wholesale' THEN product.wholesalePrice ELSE product.retailPrice
  minAllowed ← basePrice * (1 + shop.priceMinPct / 100)
  maxAllowed ← basePrice * (1 + shop.priceMaxPct / 100)
  RETURN shop.priceEditAllowed AND (entry.price < minAllowed OR entry.price > maxAllowed)
END FUNCTION

FUNCTION isBugCondition_Issue6(order)
  INPUT: order of type LocalOrder
  OUTPUT: boolean
  // Bug triggers when any order item has cartons > 0 (unitsPerCarton multiplier is skipped)
  RETURN order.items.any(i => i.cartons > 0)
END FUNCTION
```

### Fix-Checking Properties

```pascal
// Property: Fix Checking — Issue 3 (Wholesale Price Default)
FOR ALL shop WHERE isBugCondition_Issue3(shop, product) DO
  entry ← initialiseEntry'(shop, product)
  ASSERT entry.price = product.wholesalePrice
END FOR

// Property: Fix Checking — Issue 4 (Price Range Clamping)
FOR ALL (entry, shop, product) WHERE isBugCondition_Issue4(entry, shop, product) DO
  result ← update'(entry, shop, product)
  basePrice ← IF shop.shopType = 'wholesale' THEN product.wholesalePrice ELSE product.retailPrice
  ASSERT result.price >= basePrice * (1 + shop.priceMinPct / 100)
  ASSERT result.price <= basePrice * (1 + shop.priceMaxPct / 100)
END FOR

// Property: Fix Checking — Issue 6 (Correct Order Total)
FOR ALL order WHERE isBugCondition_Issue6(order) DO
  result ← total'(order)
  expected ← SUM over items of (item.cartons * item.unitsPerCarton + item.looseUnits) * item.unitPrice
  ASSERT result = expected
END FOR
```

### Preservation Properties

```pascal
// Property: Preservation — Retail shops unaffected by Issue 3 fix
FOR ALL (shop, product) WHERE shop.shopType = 'retail' DO
  ASSERT initialiseEntry'(shop, product).price = initialiseEntry(shop, product).price
END FOR

// Property: Preservation — Read-only price field unaffected by Issue 4 fix
FOR ALL shop WHERE NOT shop.priceEditAllowed DO
  ASSERT update'(entry, shop, product).price = entry.price  // no clamping applied
END FOR

// Property: Preservation — Order save behaviour unchanged
FOR ALL order WHERE order.items.all(i => i.cartons = 0 OR i.looseUnits > 0) DO
  ASSERT saveOrder'(order) produces same DB state as saveOrder(order)
END FOR
```
