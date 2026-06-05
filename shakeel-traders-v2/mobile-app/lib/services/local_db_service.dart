import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class LocalDbService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'shakeel_traders.db'),
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add units_per_carton to existing local_order_items rows
      await db.execute(
          'ALTER TABLE local_order_items ADD COLUMN units_per_carton INTEGER DEFAULT 1');
      // Create shop_price_history table for price history tracking
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shop_price_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          shop_id INTEGER NOT NULL, product_id INTEGER NOT NULL,
          unit_price REAL NOT NULL, order_date TEXT NOT NULL
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_sph ON shop_price_history (shop_id, product_id, order_date)');
    }
    if (oldVersion < 3) {
      // Replace price_min_pct + price_max_pct with single price_max_discount_pct
      // SQLite doesn't support DROP COLUMN, so we add the new column and keep old ones
      // (they will be ignored by the model). Fresh installs use the new schema.
      await db.execute(
          'ALTER TABLE local_shops ADD COLUMN price_max_discount_pct REAL DEFAULT 0');
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE local_routes (
        id INTEGER PRIMARY KEY, name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE local_shops (
        id INTEGER PRIMARY KEY, route_id INTEGER NOT NULL,
        name TEXT NOT NULL, owner_name TEXT, phone TEXT, address TEXT,
        shop_type TEXT DEFAULT 'retail',
        price_edit_allowed INTEGER DEFAULT 0,
        price_max_discount_pct REAL DEFAULT 0,
        outstanding_balance REAL DEFAULT 0,
        has_recovery_bill INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE local_products (
        id INTEGER PRIMARY KEY, sku_code TEXT NOT NULL, name TEXT NOT NULL,
        brand TEXT, units_per_carton INTEGER NOT NULL,
        retail_price REAL NOT NULL, wholesale_price REAL NOT NULL,
        current_stock_cartons INTEGER DEFAULT 0,
        current_stock_loose INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE shop_last_prices (
        shop_id INTEGER NOT NULL, product_id INTEGER NOT NULL,
        last_price REAL NOT NULL,
        PRIMARY KEY (shop_id, product_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE local_orders (
        local_id TEXT PRIMARY KEY, shop_id INTEGER NOT NULL,
        route_id INTEGER NOT NULL, shop_name TEXT NOT NULL,
        created_at_device TEXT NOT NULL,
        status TEXT DEFAULT 'pending_sync',
        stock_check_note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE local_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_local_id TEXT NOT NULL, product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL, sku_code TEXT NOT NULL,
        cartons INTEGER DEFAULT 0, loose_units INTEGER DEFAULT 0,
        unit_price REAL NOT NULL, units_per_carton INTEGER DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE local_recovery_assignments (
        assignment_id INTEGER PRIMARY KEY, bill_id INTEGER NOT NULL,
        bill_number TEXT NOT NULL, shop_id INTEGER NOT NULL,
        shop_name TEXT NOT NULL, bill_date TEXT NOT NULL,
        net_amount REAL NOT NULL, outstanding_amount REAL NOT NULL,
        collected_amount REAL, payment_method TEXT,
        status TEXT DEFAULT 'assigned'
      )
    ''');
    await db.execute('''
      CREATE TABLE local_issuances (
        local_id TEXT PRIMARY KEY, issuance_date TEXT NOT NULL,
        status TEXT DEFAULT 'pending_sync'
      )
    ''');
    await db.execute('''
      CREATE TABLE local_issuance_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        issuance_local_id TEXT NOT NULL, product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL, sku_code TEXT NOT NULL,
        cartons INTEGER DEFAULT 0, loose_units INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE local_returns (
        local_id TEXT PRIMARY KEY, issuance_local_id TEXT NOT NULL,
        return_date TEXT NOT NULL, status TEXT DEFAULT 'pending_sync',
        cash_collected REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE local_return_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        return_local_id TEXT NOT NULL, product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL, sku_code TEXT NOT NULL,
        issued_cartons INTEGER DEFAULT 0, issued_loose INTEGER DEFAULT 0,
        returned_cartons INTEGER DEFAULT 0, returned_loose INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE shop_price_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id INTEGER NOT NULL, product_id INTEGER NOT NULL,
        unit_price REAL NOT NULL, order_date TEXT NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_sph ON shop_price_history (shop_id, product_id, order_date)');
  }

  // ── Routes ──────────────────────────────────────────────────────────────────
  static Future<void> saveRoutes(List<LocalRoute> routes) async {
    final d = await db;
    final batch = d.batch();
    batch.delete('local_routes');
    for (final r in routes) {
      batch.insert('local_routes', r.toMap());
    }
    await batch.commit(noResult: true);
  }

  static Future<List<LocalRoute>> getRoutes() async {
    final d = await db;
    final rows = await d.query('local_routes', orderBy: 'name');
    return rows.map(LocalRoute.fromMap).toList();
  }

  // ── Shops ────────────────────────────────────────────────────────────────────
  static Future<void> saveShops(List<LocalShop> shops) async {
    final d = await db;
    final batch = d.batch();
    batch.delete('local_shops');
    for (final s in shops) {
      batch.insert('local_shops', s.toMap());
    }
    await batch.commit(noResult: true);
  }

  static Future<List<LocalShop>> getShopsByRoute(int routeId) async {
    final d = await db;
    final rows = await d.query('local_shops',
        where: 'route_id = ?', whereArgs: [routeId], orderBy: 'name');
    return rows.map(LocalShop.fromMap).toList();
  }

  static Future<LocalShop?> getShop(int shopId) async {
    final d = await db;
    final rows =
        await d.query('local_shops', where: 'id = ?', whereArgs: [shopId]);
    if (rows.isEmpty) return null;
    return LocalShop.fromMap(rows.first);
  }

  static Future<void> markShopHasRecovery(int shopId, bool has) async {
    final d = await db;
    await d.update('local_shops', {'has_recovery_bill': has ? 1 : 0},
        where: 'id = ?', whereArgs: [shopId]);
  }

  // ── Products ─────────────────────────────────────────────────────────────────
  static Future<void> saveProducts(List<LocalProduct> products) async {
    final d = await db;
    final batch = d.batch();
    batch.delete('local_products');
    for (final p in products) {
      batch.insert('local_products', p.toMap());
    }
    await batch.commit(noResult: true);
  }

  static Future<List<LocalProduct>> getProducts({String? query}) async {
    final d = await db;
    if (query != null && query.isNotEmpty) {
      final q = '%${query.toLowerCase()}%';
      final rows = await d.rawQuery(
        'SELECT * FROM local_products WHERE LOWER(name) LIKE ? OR LOWER(sku_code) LIKE ? ORDER BY name',
        [q, q],
      );
      return rows.map(LocalProduct.fromMap).toList();
    }
    final rows = await d.query('local_products', orderBy: 'name');
    return rows.map(LocalProduct.fromMap).toList();
  }

  // ── Shop Last Prices ─────────────────────────────────────────────────────────
  static Future<void> saveLastPrices(List<ShopLastPrice> prices) async {
    final d = await db;
    final batch = d.batch();
    batch.delete('shop_last_prices');
    for (final p in prices) {
      batch.insert('shop_last_prices', p.toMap());
    }
    await batch.commit(noResult: true);
  }

  static Future<double?> getLastPrice(int shopId, int productId) async {
    final d = await db;
    final rows = await d.query('shop_last_prices',
        where: 'shop_id = ? AND product_id = ?',
        whereArgs: [shopId, productId]);
    if (rows.isEmpty) return null;
    return (rows.first['last_price'] as num).toDouble();
  }

  static Future<List<double>> getLastThreePrices(
      int shopId, int productId) async {
    final d = await db;
    final rows = await d.rawQuery(
      'SELECT unit_price FROM shop_price_history '
      'WHERE shop_id = ? AND product_id = ? '
      'ORDER BY order_date DESC LIMIT 3',
      [shopId, productId],
    );
    return rows.map((r) => (r['unit_price'] as num).toDouble()).toList();
  }

  // ── Orders ───────────────────────────────────────────────────────────────────
  static Future<void> saveOrder(LocalOrder order) async {
    final d = await db;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await d.insert('local_orders', order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await d.delete('local_order_items',
        where: 'order_local_id = ?', whereArgs: [order.localId]);
    for (final item in order.items) {
      await d.insert('local_order_items', item.toMap());
      // Write price history row
      await d.insert('shop_price_history', {
        'shop_id': order.shopId,
        'product_id': item.productId,
        'unit_price': item.unitPrice,
        'order_date': today,
      });
      // Prune to keep only the 3 most recent rows per (shop_id, product_id)
      await d.rawDelete(
        'DELETE FROM shop_price_history '
        'WHERE shop_id = ? AND product_id = ? '
        'AND id NOT IN ('
        '  SELECT id FROM shop_price_history '
        '  WHERE shop_id = ? AND product_id = ? '
        '  ORDER BY order_date DESC LIMIT 3'
        ')',
        [order.shopId, item.productId, order.shopId, item.productId],
      );
    }
  }

  static Future<List<LocalOrder>> getPendingSyncOrders() async {
    final d = await db;
    final rows = await d.query('local_orders',
        where: 'status = ?',
        whereArgs: ['pending_sync'],
        orderBy: 'created_at_device DESC');
    final orders = <LocalOrder>[];
    for (final row in rows) {
      final items = await _getOrderItems(d, row['local_id'] as String);
      orders.add(LocalOrder.fromMap(row, items));
    }
    return orders;
  }

  static Future<List<LocalOrder>> getTodayOrders(String today) async {
    final d = await db;
    final rows = await d.query('local_orders',
        where: 'created_at_device LIKE ?',
        whereArgs: ['$today%'],
        orderBy: 'created_at_device DESC');
    final orders = <LocalOrder>[];
    for (final row in rows) {
      final items = await _getOrderItems(d, row['local_id'] as String);
      orders.add(LocalOrder.fromMap(row, items));
    }
    return orders;
  }

  static Future<List<LocalOrderItem>> _getOrderItems(
      Database d, String localId) async {
    final rows = await d.query('local_order_items',
        where: 'order_local_id = ?', whereArgs: [localId]);
    return rows.map(LocalOrderItem.fromMap).toList();
  }

  static Future<void> updateOrderStatus(String localId, String status) async {
    final d = await db;
    await d.update('local_orders', {'status': status},
        where: 'local_id = ?', whereArgs: [localId]);
  }

  static Future<Set<int>> getBookedShopIds(int routeId, String today) async {
    final d = await db;
    final rows = await d.rawQuery(
      'SELECT DISTINCT shop_id FROM local_orders '
      'WHERE route_id = ? AND created_at_device LIKE ?',
      [routeId, '$today%'],
    );
    return rows.map((r) => (r['shop_id'] as int)).toSet();
  }

  // ── Recovery Assignments ─────────────────────────────────────────────────────
  static Future<void> saveRecoveryAssignments(
      List<LocalRecoveryAssignment> assignments) async {
    final d = await db;
    // Only insert new ones, don't overwrite collected ones
    for (final a in assignments) {
      final existing = await d.query('local_recovery_assignments',
          where: 'assignment_id = ?', whereArgs: [a.assignmentId]);
      if (existing.isEmpty) {
        await d.insert('local_recovery_assignments', a.toMap());
      }
    }
    // Mark shops that have recovery bills
    final shopIds = assignments.map((a) => a.shopId).toSet();
    for (final sid in shopIds) {
      await markShopHasRecovery(sid, true);
    }
  }

  static Future<List<LocalRecoveryAssignment>> getTodayRecoveries() async {
    final d = await db;
    final rows = await d.query('local_recovery_assignments',
        where: 'status != ?', whereArgs: ['synced'], orderBy: 'shop_name');
    return rows.map(LocalRecoveryAssignment.fromMap).toList();
  }

  static Future<void> updateRecovery(LocalRecoveryAssignment a) async {
    final d = await db;
    await d.update('local_recovery_assignments', a.toMap(),
        where: 'assignment_id = ?', whereArgs: [a.assignmentId]);
  }

  static Future<List<LocalRecoveryAssignment>>
      getPendingSyncRecoveries() async {
    final d = await db;
    final rows = await d.query('local_recovery_assignments',
        where: 'status = ?', whereArgs: ['collected']);
    return rows.map(LocalRecoveryAssignment.fromMap).toList();
  }

  static Future<void> clearRecoveries() async {
    final d = await db;
    await d.delete('local_recovery_assignments');
  }

  // ── Issuances ────────────────────────────────────────────────────────────────
  static Future<void> saveIssuance(LocalIssuance issuance) async {
    final d = await db;
    await d.insert('local_issuances', issuance.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await d.delete('local_issuance_items',
        where: 'issuance_local_id = ?', whereArgs: [issuance.localId]);
    for (final item in issuance.items) {
      await d.insert('local_issuance_items', item.toMap());
    }
  }

  static Future<LocalIssuance?> getTodayIssuance(String today) async {
    final d = await db;
    final rows = await d.query('local_issuances',
        where: 'issuance_date = ?', whereArgs: [today]);
    if (rows.isEmpty) return null;
    final items = await _getIssuanceItems(d, rows.first['local_id'] as String);
    return LocalIssuance.fromMap(rows.first, items);
  }

  static Future<List<LocalIssuanceItem>> _getIssuanceItems(
      Database d, String localId) async {
    final rows = await d.query('local_issuance_items',
        where: 'issuance_local_id = ?', whereArgs: [localId]);
    return rows.map(LocalIssuanceItem.fromMap).toList();
  }

  static Future<void> updateIssuanceStatus(
      String localId, String status) async {
    final d = await db;
    await d.update('local_issuances', {'status': status},
        where: 'local_id = ?', whereArgs: [localId]);
  }

  // ── Returns ──────────────────────────────────────────────────────────────────
  static Future<void> saveReturn(LocalReturn ret) async {
    final d = await db;
    await d.insert('local_returns', ret.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await d.delete('local_return_items',
        where: 'return_local_id = ?', whereArgs: [ret.localId]);
    for (final item in ret.items) {
      await d.insert('local_return_items', item.toMap());
    }
  }

  static Future<LocalReturn?> getTodayReturn(String today) async {
    final d = await db;
    final rows = await d
        .query('local_returns', where: 'return_date = ?', whereArgs: [today]);
    if (rows.isEmpty) return null;
    final items = await _getReturnItems(d, rows.first['local_id'] as String);
    return LocalReturn.fromMap(rows.first, items);
  }

  static Future<List<LocalReturnItem>> _getReturnItems(
      Database d, String localId) async {
    final rows = await d.query('local_return_items',
        where: 'return_local_id = ?', whereArgs: [localId]);
    return rows.map(LocalReturnItem.fromMap).toList();
  }

  static Future<void> updateReturnStatus(String localId, String status) async {
    final d = await db;
    await d.update('local_returns', {'status': status},
        where: 'local_id = ?', whereArgs: [localId]);
  }

  // ── Clear all data (for fresh sync) ─────────────────────────────────────────
  static Future<void> clearMasterData() async {
    final d = await db;
    await d.delete('local_routes');
    await d.delete('local_shops');
    await d.delete('local_products');
    await d.delete('shop_last_prices');
  }
}
