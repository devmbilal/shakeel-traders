// ─── Parsing helpers (handle String/num/int from JSON or sqflite) ────────────
double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

bool _toBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}

// ─── Local Models for sqflite ────────────────────────────────────────────────

class LocalRoute {
  final int id;
  final String name;

  const LocalRoute({required this.id, required this.name});

  factory LocalRoute.fromMap(Map<String, dynamic> m) =>
      LocalRoute(id: _toInt(m['id']), name: (m['name'] ?? '') as String);

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
}

// ─────────────────────────────────────────────────────────────────────────────

class LocalShop {
  final int id;
  final int routeId;
  final String name;
  final String? ownerName;
  final String? phone;
  final String? address;
  final String shopType;
  final bool priceEditAllowed;

  /// Maximum discount percentage allowed (0 to N%). Price must be >= basePrice * (1 - maxDiscountPct/100).
  final double priceMaxDiscountPct;
  final double outstandingBalance;
  bool hasRecoveryBill;

  LocalShop({
    required this.id,
    required this.routeId,
    required this.name,
    this.ownerName,
    this.phone,
    this.address,
    this.shopType = 'retail',
    this.priceEditAllowed = false,
    this.priceMaxDiscountPct = 0,
    this.outstandingBalance = 0,
    this.hasRecoveryBill = false,
  });

  factory LocalShop.fromMap(Map<String, dynamic> m) => LocalShop(
        id: (m['id'] as num).toInt(),
        routeId: (m['route_id'] as num).toInt(),
        name: (m['shop_name'] ?? m['name'] ?? '') as String,
        ownerName: m['owner_name'] as String?,
        phone: m['phone'] as String?,
        address: m['address'] as String?,
        shopType: (m['shop_type'] as String?) ?? 'retail',
        priceEditAllowed: _toBool(m['price_edit_allowed']),
        priceMaxDiscountPct: _toDouble(m['price_max_discount_pct'] ??
            // backward-compat: if old min/max fields exist, derive from them
            m['price_max_pct']),
        outstandingBalance: _toDouble(m['outstanding_balance']),
        hasRecoveryBill: _toBool(m['has_recovery_bill']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'route_id': routeId,
        'name': name,
        'owner_name': ownerName,
        'phone': phone,
        'address': address,
        'shop_type': shopType,
        'price_edit_allowed': priceEditAllowed ? 1 : 0,
        'price_max_discount_pct': priceMaxDiscountPct,
        'outstanding_balance': outstandingBalance,
        'has_recovery_bill': hasRecoveryBill ? 1 : 0,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class LocalProduct {
  final int id;
  final String skuCode;
  final String name;
  final String? brand;
  final int unitsPerCarton;
  final double retailPrice;
  final double wholesalePrice;
  final int currentStockCartons;
  final int currentStockLoose;

  LocalProduct({
    required this.id,
    required this.skuCode,
    required this.name,
    this.brand,
    required this.unitsPerCarton,
    required this.retailPrice,
    required this.wholesalePrice,
    this.currentStockCartons = 0,
    this.currentStockLoose = 0,
  });

  /// Total loose units in stock (cartons converted + loose)
  int get totalUnits =>
      currentStockCartons * unitsPerCarton + currentStockLoose;

  factory LocalProduct.fromMap(Map<String, dynamic> m) => LocalProduct(
        id: _toInt(m['id']),
        skuCode: (m['sku_code'] ?? m['skuCode'] ?? '') as String,
        name: (m['product_name'] ?? m['name'] ?? '') as String,
        brand: m['brand'] as String?,
        unitsPerCarton: _toInt(m['units_per_carton']),
        retailPrice: _toDouble(m['retail_price']),
        wholesalePrice: _toDouble(m['wholesale_price']),
        currentStockCartons: _toInt(m['current_stock_cartons']),
        currentStockLoose: _toInt(m['current_stock_loose']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'sku_code': skuCode,
        'name': name,
        'brand': brand,
        'units_per_carton': unitsPerCarton,
        'retail_price': retailPrice,
        'wholesale_price': wholesalePrice,
        'current_stock_cartons': currentStockCartons,
        'current_stock_loose': currentStockLoose,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class ShopLastPrice {
  final int shopId;
  final int productId;
  final double lastPrice;

  const ShopLastPrice({
    required this.shopId,
    required this.productId,
    required this.lastPrice,
  });

  factory ShopLastPrice.fromMap(Map<String, dynamic> m) => ShopLastPrice(
        shopId: _toInt(m['shop_id']),
        productId: _toInt(m['product_id']),
        lastPrice: _toDouble(m['last_price']),
      );

  Map<String, dynamic> toMap() =>
      {'shop_id': shopId, 'product_id': productId, 'last_price': lastPrice};
}

// ─────────────────────────────────────────────────────────────────────────────

class ShopPriceHistory {
  final int shopId;
  final int productId;
  final double unitPrice;
  final String orderDate;

  const ShopPriceHistory({
    required this.shopId,
    required this.productId,
    required this.unitPrice,
    required this.orderDate,
  });

  factory ShopPriceHistory.fromMap(Map<String, dynamic> m) => ShopPriceHistory(
        shopId: _toInt(m['shop_id']),
        productId: _toInt(m['product_id']),
        unitPrice: _toDouble(m['unit_price']),
        orderDate: (m['order_date'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        'shop_id': shopId,
        'product_id': productId,
        'unit_price': unitPrice,
        'order_date': orderDate,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class LocalOrderItem {
  final String orderLocalId;
  final int productId;
  final String productName;
  final String skuCode;
  int cartons;
  int looseUnits;
  double unitPrice;
  final int unitsPerCarton;

  LocalOrderItem({
    required this.orderLocalId,
    required this.productId,
    required this.productName,
    required this.skuCode,
    this.cartons = 0,
    this.looseUnits = 0,
    required this.unitPrice,
    this.unitsPerCarton = 1,
  });

  factory LocalOrderItem.fromMap(Map<String, dynamic> m) => LocalOrderItem(
        orderLocalId: m['order_local_id'] as String,
        productId: _toInt(m['product_id']),
        productName: m['product_name'] as String,
        skuCode: m['sku_code'] as String,
        cartons: _toInt(m['cartons']),
        looseUnits: _toInt(m['loose_units']),
        unitPrice: _toDouble(m['unit_price']),
        unitsPerCarton: _toInt(m['units_per_carton']) == 0
            ? 1
            : _toInt(m['units_per_carton']),
      );

  Map<String, dynamic> toMap() => {
        'order_local_id': orderLocalId,
        'product_id': productId,
        'product_name': productName,
        'sku_code': skuCode,
        'cartons': cartons,
        'loose_units': looseUnits,
        'unit_price': unitPrice,
        'units_per_carton': unitsPerCarton,
      };
}

class LocalOrder {
  final String localId;
  final int shopId;
  final int routeId;
  final String shopName;
  final String createdAtDevice;
  String status;
  String? stockCheckNote;
  final List<LocalOrderItem> items;

  LocalOrder({
    required this.localId,
    required this.shopId,
    required this.routeId,
    required this.shopName,
    required this.createdAtDevice,
    this.status = 'pending_sync',
    this.stockCheckNote,
    required this.items,
  });

  factory LocalOrder.fromMap(
          Map<String, dynamic> m, List<LocalOrderItem> items) =>
      LocalOrder(
        localId: m['local_id'] as String,
        shopId: m['shop_id'] as int,
        routeId: m['route_id'] as int,
        shopName: m['shop_name'] as String,
        createdAtDevice: m['created_at_device'] as String,
        status: (m['status'] as String?) ?? 'pending_sync',
        stockCheckNote: m['stock_check_note'] as String?,
        items: items,
      );

  Map<String, dynamic> toMap() => {
        'local_id': localId,
        'shop_id': shopId,
        'route_id': routeId,
        'shop_name': shopName,
        'created_at_device': createdAtDevice,
        'status': status,
        'stock_check_note': stockCheckNote,
      };

  double get total => items.fold(
      0,
      (sum, i) =>
          sum + (i.cartons * i.unitsPerCarton + i.looseUnits) * i.unitPrice);
}

// ─────────────────────────────────────────────────────────────────────────────

class LocalRecoveryAssignment {
  final int assignmentId;
  final int billId;
  final String billNumber;
  final int shopId;
  final String shopName;
  final String billDate;
  final double netAmount;
  final double outstandingAmount;
  double? collectedAmount;
  String? paymentMethod;
  String status;

  LocalRecoveryAssignment({
    required this.assignmentId,
    required this.billId,
    required this.billNumber,
    required this.shopId,
    required this.shopName,
    required this.billDate,
    required this.netAmount,
    required this.outstandingAmount,
    this.collectedAmount,
    this.paymentMethod,
    this.status = 'assigned',
  });

  factory LocalRecoveryAssignment.fromMap(Map<String, dynamic> m) =>
      LocalRecoveryAssignment(
        assignmentId: _toInt(m['id'] ?? m['assignment_id']),
        billId: _toInt(m['bill_id']),
        billNumber: (m['bill_number'] ?? '') as String,
        shopId: _toInt(m['shop_id'] ?? 0),
        shopName: (m['shop_name'] ?? '') as String,
        billDate: (m['bill_date'] ?? '').toString(),
        netAmount: _toDouble(m['net_amount'] ?? m['gross_amount']),
        outstandingAmount: _toDouble(m['outstanding_amount']),
        collectedAmount: m['collected_amount'] != null
            ? _toDouble(m['collected_amount'])
            : null,
        paymentMethod: m['payment_method'] as String?,
        status: (m['status'] as String?) ?? 'assigned',
      );

  Map<String, dynamic> toMap() => {
        'assignment_id': assignmentId,
        'bill_id': billId,
        'bill_number': billNumber,
        'shop_id': shopId,
        'shop_name': shopName,
        'bill_date': billDate,
        'net_amount': netAmount,
        'outstanding_amount': outstandingAmount,
        'collected_amount': collectedAmount,
        'payment_method': paymentMethod,
        'status': status,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class LocalIssuanceItem {
  final String issuanceLocalId;
  final int productId;
  final String productName;
  final String skuCode;
  final int cartons;
  final int looseUnits;

  const LocalIssuanceItem({
    required this.issuanceLocalId,
    required this.productId,
    required this.productName,
    required this.skuCode,
    this.cartons = 0,
    this.looseUnits = 0,
  });

  factory LocalIssuanceItem.fromMap(Map<String, dynamic> m) =>
      LocalIssuanceItem(
        issuanceLocalId: m['issuance_local_id'] as String,
        productId: m['product_id'] as int,
        productName: m['product_name'] as String,
        skuCode: m['sku_code'] as String,
        cartons: m['cartons'] as int? ?? 0,
        looseUnits: m['loose_units'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'issuance_local_id': issuanceLocalId,
        'product_id': productId,
        'product_name': productName,
        'sku_code': skuCode,
        'cartons': cartons,
        'loose_units': looseUnits,
      };
}

class LocalIssuance {
  final String localId;
  final String issuanceDate;
  String status;
  final List<LocalIssuanceItem> items;

  LocalIssuance({
    required this.localId,
    required this.issuanceDate,
    this.status = 'pending_sync',
    required this.items,
  });

  factory LocalIssuance.fromMap(
          Map<String, dynamic> m, List<LocalIssuanceItem> items) =>
      LocalIssuance(
        localId: m['local_id'] as String,
        issuanceDate: m['issuance_date'] as String,
        status: (m['status'] as String?) ?? 'pending_sync',
        items: items,
      );

  Map<String, dynamic> toMap() => {
        'local_id': localId,
        'issuance_date': issuanceDate,
        'status': status,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class LocalReturnItem {
  final String returnLocalId;
  final int productId;
  final String productName;
  final String skuCode;
  final int issuedCartons;
  final int issuedLoose;
  int returnedCartons;
  int returnedLoose;

  LocalReturnItem({
    required this.returnLocalId,
    required this.productId,
    required this.productName,
    required this.skuCode,
    this.issuedCartons = 0,
    this.issuedLoose = 0,
    this.returnedCartons = 0,
    this.returnedLoose = 0,
  });

  int get soldCartons => issuedCartons - returnedCartons;
  int get soldLoose => issuedLoose - returnedLoose;

  factory LocalReturnItem.fromMap(Map<String, dynamic> m) => LocalReturnItem(
        returnLocalId: m['return_local_id'] as String,
        productId: _toInt(m['product_id']),
        productName: m['product_name'] as String,
        skuCode: m['sku_code'] as String,
        issuedCartons: _toInt(m['issued_cartons']),
        issuedLoose: _toInt(m['issued_loose']),
        returnedCartons: _toInt(m['returned_cartons']),
        returnedLoose: _toInt(m['returned_loose']),
      );

  Map<String, dynamic> toMap() => {
        'return_local_id': returnLocalId,
        'product_id': productId,
        'product_name': productName,
        'sku_code': skuCode,
        'issued_cartons': issuedCartons,
        'issued_loose': issuedLoose,
        'returned_cartons': returnedCartons,
        'returned_loose': returnedLoose,
      };
}

class LocalReturn {
  final String localId;
  final String issuanceLocalId;
  final String returnDate;
  String status;
  double? cashCollected;
  final List<LocalReturnItem> items;

  LocalReturn({
    required this.localId,
    required this.issuanceLocalId,
    required this.returnDate,
    this.status = 'pending_sync',
    this.cashCollected,
    required this.items,
  });

  factory LocalReturn.fromMap(
          Map<String, dynamic> m, List<LocalReturnItem> items) =>
      LocalReturn(
        localId: m['local_id'] as String,
        issuanceLocalId: m['issuance_local_id'] as String,
        returnDate: m['return_date'] as String,
        status: (m['status'] as String?) ?? 'pending_sync',
        cashCollected: (m['cash_collected'] as num?)?.toDouble(),
        items: items,
      );

  Map<String, dynamic> toMap() => {
        'local_id': localId,
        'issuance_local_id': issuanceLocalId,
        'return_date': returnDate,
        'status': status,
        'cash_collected': cashCollected,
      };
}
