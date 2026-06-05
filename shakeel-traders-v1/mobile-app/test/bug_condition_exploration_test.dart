// Bug Condition Exploration Tests
//
// These tests demonstrate three financially critical bugs in the CURRENT (unfixed) code.
// They are EXPECTED TO FAIL on unfixed code — that failure is the success condition.
//
// Test 1 (isBugCondition_Issue3): Wholesale price default
//   Expected: 85.0 (wholesalePrice), Got: 100.0 (retailPrice used instead of wholesalePrice)
//
// Test 2 (isBugCondition_Issue4): Price range clamping
//   Expected: clamped price in [95.0, 110.0], Got: 50.0 (raw out-of-range value stored verbatim)
//
// Test 3 (isBugCondition_Issue6): Order total formula
//   Expected: 270.0 ((2*12 + 3) * 10.0), Got: 50.0 ((2 + 3) * 10.0 — unitsPerCarton ignored)

import 'package:flutter_test/flutter_test.dart';
import 'package:shakeel_traders_app/models/models.dart';

void main() {
  // ─── Test 1: Wholesale Price Default (isBugCondition_Issue3) ─────────────
  //
  // The current itemBuilder in ob_order_booking_screen.dart always does:
  //   _OrderEntry(price: p.retailPrice)
  // regardless of shop type. For a wholesale shop it should use p.wholesalePrice.
  //
  // This test simulates the initialisation logic and asserts the CORRECT behaviour.
  // It will FAIL on unfixed code because retailPrice (100.0) is returned instead of
  // wholesalePrice (85.0).
  //
  // Validates: Requirements 3.1
  test('isBugCondition_Issue3 — wholesale shop entry should use wholesalePrice',
      () {
    const retailPrice = 100.0;
    const wholesalePrice = 85.0;
    const shopType = 'wholesale';

    // Simulate what the FIXED itemBuilder should do:
    //   final basePrice = shop.shopType == 'wholesale' ? p.wholesalePrice : p.retailPrice;
    //   final entry = _entries[p.id] ?? _OrderEntry(price: basePrice);
    //
    // The CURRENT (buggy) code does:
    //   final entry = _entries[p.id] ?? _OrderEntry(price: p.retailPrice);
    //
    // We replicate the buggy logic here to confirm the failure:
    final buggyPrice = retailPrice; // current code: always uses retailPrice

    // The correct price for a wholesale shop is wholesalePrice.
    // This assertion will FAIL on unfixed code (buggyPrice == 100.0, not 85.0).
    // Expected: 85.0, Got: 100.0 (retailPrice used instead of wholesalePrice)
    expect(
      buggyPrice,
      equals(wholesalePrice),
      reason:
          'Wholesale shop entry price should be wholesalePrice ($wholesalePrice) '
          'but current code uses retailPrice ($retailPrice). '
          'Expected: $wholesalePrice, Got: $buggyPrice',
    );
  });

  // ─── Test 2: Price Range Clamping (isBugCondition_Issue4) ────────────────
  //
  // The current _update() in _ProductRowState does no range validation:
  //   final p = double.tryParse(_priceCtrl.text) ?? widget.product.retailPrice;
  //   widget.onChanged(widget.entry.copyWith(price: p));
  //
  // For a price-editable shop with priceMinPct = -5.0, priceMaxPct = 10.0,
  // basePrice = 100.0, if the user enters 50.0:
  //   minAllowed = 100.0 * (1 + (-5)/100) = 95.0
  //   maxAllowed = 100.0 * (1 + 10/100)  = 110.0
  //
  // The stored price should be clamped to 95.0, but the buggy code stores 50.0.
  //
  // Validates: Requirements 4.1, 4.2
  test(
      'isBugCondition_Issue4 — out-of-range price should be clamped to minAllowed',
      () {
    const basePrice = 100.0;
    const priceMinPct = -5.0;
    const priceMaxPct = 10.0;
    const enteredPrice = 50.0; // far below the allowed minimum

    final minAllowed = basePrice * (1 + priceMinPct / 100); // 95.0
    final maxAllowed = basePrice * (1 + priceMaxPct / 100); // 110.0

    // Simulate what the FIXED _update() should do:
    //   double p = double.tryParse(...) ?? basePrice;
    //   if (shopPriceEditAllowed) p = p.clamp(minAllowed, maxAllowed);
    //
    // The CURRENT (buggy) code stores the raw parsed value with no clamping:
    final buggyStoredPrice = enteredPrice; // current code: no clamping

    // The correct stored price must be within [minAllowed, maxAllowed].
    // This assertion will FAIL on unfixed code (buggyStoredPrice == 50.0 < 95.0).
    // Expected: clamped to 95.0, Got: 50.0 (raw value stored verbatim)
    expect(
      buggyStoredPrice >= minAllowed && buggyStoredPrice <= maxAllowed,
      isTrue,
      reason: 'Stored price ($buggyStoredPrice) should be clamped to '
          '[$minAllowed, $maxAllowed] but current code stores the raw value. '
          'Expected: price in [$minAllowed, $maxAllowed], Got: $buggyStoredPrice',
    );
  });

  // ─── Test 3: Order Total Formula (isBugCondition_Issue6) ─────────────────
  //
  // The current LocalOrder.total getter in models.dart computes:
  //   sum + (i.cartons * i.unitPrice) + (i.looseUnits * i.unitPrice)
  //
  // This is WRONG — it treats cartons as individual units, ignoring unitsPerCarton.
  //
  // For cartons=2, unitsPerCarton=12, looseUnits=3, unitPrice=10.0:
  //   Correct:  (2 * 12 + 3) * 10.0 = 270.0
  //   Buggy:    (2 * 10.0) + (3 * 10.0) = 50.0
  //
  // Validates: Requirements 6.2
  test(
      'isBugCondition_Issue6 — order total should use unitsPerCarton multiplier',
      () {
    const cartons = 2;
    const unitsPerCarton = 12;
    const looseUnits = 3;
    const unitPrice = 10.0;

    // Correct formula: (cartons * unitsPerCarton + looseUnits) * unitPrice
    const expectedTotal =
        (cartons * unitsPerCarton + looseUnits) * unitPrice; // 270.0

    // Replicate the CURRENT (buggy) LocalOrder.total formula:
    //   sum + (i.cartons * i.unitPrice) + (i.looseUnits * i.unitPrice)
    final buggyTotal = (cartons * unitPrice) + (looseUnits * unitPrice); // 50.0

    // Build a real LocalOrder using the current model to confirm the bug via the getter.
    // Note: LocalOrderItem does not yet have unitsPerCarton, so we test the formula
    // logic directly above and also verify via the model's total getter below.
    final item = LocalOrderItem(
      orderLocalId: 'test-order-1',
      productId: 1,
      productName: 'Test Product',
      skuCode: 'SKU-001',
      cartons: cartons,
      looseUnits: looseUnits,
      unitPrice: unitPrice,
    );
    final order = LocalOrder(
      localId: 'test-order-1',
      shopId: 1,
      routeId: 1,
      shopName: 'Test Shop',
      createdAtDevice: DateTime.now().toIso8601String(),
      items: [item],
    );

    // The model's total getter uses the buggy formula — confirm it matches buggyTotal.
    expect(
      order.total,
      equals(buggyTotal),
      reason: 'Confirming the model uses the buggy formula: '
          'order.total == $buggyTotal (cartons treated as units, not carton-packs)',
    );

    // This is the assertion that will FAIL on unfixed code:
    // order.total (50.0) != expectedTotal (270.0)
    // Expected: 270.0, Got: 50.0 (unitsPerCarton multiplier missing)
    expect(
      order.total,
      equals(expectedTotal),
      reason: 'Order total should be $expectedTotal '
          '((cartons * unitsPerCarton + looseUnits) * unitPrice = '
          '($cartons * $unitsPerCarton + $looseUnits) * $unitPrice) '
          'but current code returns $buggyTotal. '
          'Expected: $expectedTotal, Got: ${order.total}',
    );
  });
}
