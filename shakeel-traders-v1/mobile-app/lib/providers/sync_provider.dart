import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncResult {
  final bool success;
  final String message;
  final List<String> details;
  SyncResult(
      {required this.success, required this.message, this.details = const []});
}

class SyncProvider extends ChangeNotifier {
  SyncStatus _status = SyncStatus.idle;
  String _statusMessage = '';
  List<String> _log = [];
  String? _lastSync;

  SyncStatus get status => _status;
  String get statusMessage => _statusMessage;
  List<String> get log => _log;
  String? get lastSync => _lastSync;

  Future<void> loadLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSync = prefs.getString(AppConstants.keyLastSync);
    notifyListeners();
  }

  Future<SyncResult> morningSyncOrderBooker() async {
    _start('Downloading morning data...');
    try {
      final data = await ApiService.get(AppConstants.apiSyncMorning);

      // Save routes
      final routes = (data['routes'] as List)
          .map((r) => LocalRoute.fromMap(r as Map<String, dynamic>))
          .toList();
      await LocalDbService.saveRoutes(routes);
      _log.add('✓ ${routes.length} routes downloaded');

      // Save shops
      final shops = (data['shops'] as List)
          .map((s) => LocalShop.fromMap(s as Map<String, dynamic>))
          .toList();
      await LocalDbService.saveShops(shops);
      _log.add('✓ ${shops.length} shops downloaded');

      // Save products
      final products = (data['products'] as List)
          .map((p) => LocalProduct.fromMap(p as Map<String, dynamic>))
          .toList();
      await LocalDbService.saveProducts(products);
      _log.add('✓ ${products.length} products downloaded');

      // Save last prices
      final prices = (data['lastPrices'] as List? ?? [])
          .map((p) => ShopLastPrice.fromMap(p as Map<String, dynamic>))
          .toList();
      await LocalDbService.saveLastPrices(prices);
      _log.add('✓ ${prices.length} last prices downloaded');

      // Save recovery assignments
      final recoveries = (data['recoveryAssignments'] as List? ?? [])
          .map(
              (r) => LocalRecoveryAssignment.fromMap(r as Map<String, dynamic>))
          .toList();
      await LocalDbService.clearRecoveries();
      await LocalDbService.saveRecoveryAssignments(recoveries);
      _log.add('✓ ${recoveries.length} recovery bills downloaded');

      await _saveLastSync();
      _done('Morning sync complete!');
      return SyncResult(
          success: true,
          message: 'Morning sync complete',
          details: List.from(_log));
    } catch (e) {
      final msg = ApiService.friendlyError(e);
      _error(msg);
      return SyncResult(success: false, message: msg);
    }
  }

  Future<SyncResult> middaySyncOrderBooker() async {
    _start('Downloading new recovery assignments...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString(AppConstants.keyLastSync) ?? '';
      final data = await ApiService.get(
          '${AppConstants.apiSyncMidday}?lastSync=$lastSync');

      final recoveries = (data['recoveryAssignments'] as List? ?? [])
          .map(
              (r) => LocalRecoveryAssignment.fromMap(r as Map<String, dynamic>))
          .toList();
      await LocalDbService.saveRecoveryAssignments(recoveries);
      _log.add('✓ ${recoveries.length} new recovery bills downloaded');

      await _saveLastSync();
      _done('Mid-day sync complete!');
      return SyncResult(
          success: true,
          message: 'Mid-day sync complete',
          details: List.from(_log));
    } catch (e) {
      final msg = ApiService.friendlyError(e);
      _error(msg);
      return SyncResult(success: false, message: msg);
    }
  }

  Future<SyncResult> eveningSyncOrderBooker() async {
    _start('Uploading orders and recoveries...');
    try {
      // Gather pending orders
      final orders = await LocalDbService.getPendingSyncOrders();
      final ordersPayload = orders
          .map((o) => {
                'local_id': o.localId,
                'shop_id': o.shopId,
                'route_id': o.routeId,
                'created_at_device': o.createdAtDevice,
                'items': o.items
                    .map((i) => {
                          'product_id': i.productId,
                          'cartons': i.cartons,
                          'loose_units': i.looseUnits,
                          'unit_price': i.unitPrice,
                        })
                    .toList(),
              })
          .toList();

      // Gather pending recoveries
      final recoveries = await LocalDbService.getPendingSyncRecoveries();
      final recoveriesPayload = recoveries
          .map((r) => {
                'assignment_id': r.assignmentId,
                'bill_id': r.billId,
                'amount_collected': r.collectedAmount ?? 0,
                'payment_method': r.paymentMethod ?? 'cash',
              })
          .toList();

      final result = await ApiService.post(AppConstants.apiSyncEvening, {
        'orders': ordersPayload,
        'collections': recoveriesPayload,
      });

      // Update local statuses
      for (final o in orders) {
        await LocalDbService.updateOrderStatus(o.localId, 'synced');
      }
      for (final r in recoveries) {
        r.status = 'synced';
        await LocalDbService.updateRecovery(r);
      }

      _log.add('✓ ${orders.length} orders uploaded');
      _log.add('✓ ${recoveries.length} recovery entries uploaded');

      // Stock adjustment notifications
      final adjustments = result['stockAdjustments'] as List? ?? [];
      for (final adj in adjustments) {
        _log.add('⚠ ${adj['product_name']}: ${adj['note']}');
      }

      await _saveLastSync();
      _done('Evening sync complete!');
      return SyncResult(
          success: true,
          message: 'Evening sync complete',
          details: List.from(_log));
    } catch (e) {
      final msg = ApiService.friendlyError(e);
      _error(msg);
      return SyncResult(success: false, message: msg);
    }
  }

  // ─── Order Booker: Upload Orders Only ───────────────────────────────────────
  Future<SyncResult> uploadOrdersOnly() async {
    _start('Uploading orders...');
    try {
      final orders = await LocalDbService.getPendingSyncOrders();
      if (orders.isEmpty) {
        _done('No pending orders to upload.');
        return SyncResult(success: true, message: 'No pending orders');
      }
      final payload = orders
          .map((o) => {
                'local_id': o.localId,
                'shop_id': o.shopId,
                'route_id': o.routeId,
                'created_at_device': o.createdAtDevice,
                'items': o.items
                    .map((i) => {
                          'product_id': i.productId,
                          'cartons': i.cartons,
                          'loose_units': i.looseUnits,
                          'unit_price': i.unitPrice,
                        })
                    .toList(),
              })
          .toList();

      final result = await ApiService.post(
          AppConstants.apiSyncOrders, {'orders': payload});

      for (final o in orders) {
        await LocalDbService.updateOrderStatus(o.localId, 'synced');
      }
      _log.add('✓ ${orders.length} orders uploaded');

      final adjustments = result['stockAdjustments'] as List? ?? [];
      for (final adj in adjustments) {
        _log.add('⚠ ${adj['product_name']}: ${adj['note']}');
      }

      await _saveLastSync();
      _done('Orders uploaded successfully!');
      return SyncResult(
          success: true, message: 'Orders uploaded', details: List.from(_log));
    } catch (e) {
      final msg = ApiService.friendlyError(e);
      _error(msg);
      return SyncResult(success: false, message: msg);
    }
  }

  // ─── Order Booker: Upload Recoveries Only ────────────────────────────────────
  Future<SyncResult> uploadRecoveriesOnly() async {
    _start('Uploading recovery collections...');
    try {
      final recoveries = await LocalDbService.getPendingSyncRecoveries();
      if (recoveries.isEmpty) {
        _done('No pending recoveries to upload.');
        return SyncResult(success: true, message: 'No pending recoveries');
      }
      final payload = recoveries
          .map((r) => {
                'assignment_id': r.assignmentId,
                'bill_id': r.billId,
                'amount_collected': r.collectedAmount ?? 0,
                'payment_method': r.paymentMethod ?? 'cash',
              })
          .toList();

      await ApiService.post(
          AppConstants.apiSyncRecoveries, {'collections': payload});

      for (final r in recoveries) {
        r.status = 'synced';
        await LocalDbService.updateRecovery(r);
      }
      _log.add('✓ ${recoveries.length} recovery entries uploaded');

      await _saveLastSync();
      _done('Recoveries uploaded successfully!');
      return SyncResult(
          success: true,
          message: 'Recoveries uploaded',
          details: List.from(_log));
    } catch (e) {
      final msg = ApiService.friendlyError(e);
      _error(msg);
      return SyncResult(success: false, message: msg);
    }
  }

  Future<SyncResult> morningSyncSalesman() async {
    _start('Downloading stock data...');
    try {
      final data = await ApiService.get(AppConstants.apiSalesmanMorning);

      final products = (data['products'] as List)
          .map((p) => LocalProduct.fromMap(p as Map<String, dynamic>))
          .toList();
      await LocalDbService.saveProducts(products);
      _log.add('✓ ${products.length} products downloaded');

      // Sync issuance status and items from server
      final issuanceStatus = data['issuanceStatus'] as String? ?? 'none';
      final issuanceId = data['issuanceId'];
      final issuanceItems = data['issuanceItems'] as List? ?? [];

      if (issuanceStatus != 'none' && issuanceId != null) {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        // Update local issuance status to match server
        final existing = await LocalDbService.getTodayIssuance(today);
        if (existing != null) {
          await LocalDbService.updateIssuanceStatus(
              existing.localId, issuanceStatus);
        } else if (issuanceItems.isNotEmpty) {
          // Server has an issuance we don't have locally — create it
          final items = issuanceItems.map((i) {
            final m = i as Map<String, dynamic>;
            return LocalIssuanceItem(
              issuanceLocalId: 'server_$issuanceId',
              productId: _toInt(m['product_id']),
              productName: (m['product_name'] ?? '') as String,
              skuCode: (m['sku_code'] ?? '') as String,
              cartons: _toInt(m['cartons']),
              looseUnits: _toInt(m['loose_units']),
            );
          }).toList();
          final issuance = LocalIssuance(
            localId: 'server_$issuanceId',
            issuanceDate: today,
            status: issuanceStatus,
            items: items,
          );
          await LocalDbService.saveIssuance(issuance);
        }
        _log.add('ℹ Issuance status: $issuanceStatus');
      }

      // Sync return status
      final returnStatus = data['returnStatus'] as String? ?? 'none';
      if (returnStatus != 'none') {
        _log.add('ℹ Return status: $returnStatus');
      }

      await _saveLastSync();
      _done('Morning sync complete!');
      return SyncResult(
          success: true,
          message: 'Morning sync complete',
          details: List.from(_log));
    } catch (e) {
      final msg = ApiService.friendlyError(e);
      _error(msg);
      return SyncResult(success: false, message: msg);
    }
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Future<SyncResult> uploadIssuance(LocalIssuance issuance) async {
    _start('Uploading issuance request...');
    try {
      await ApiService.post(AppConstants.apiSalesmanIssuance, {
        'issuance_date': issuance.issuanceDate,
        'items': issuance.items
            .map((i) => {
                  'product_id': i.productId,
                  'cartons': i.cartons,
                  'loose_units': i.looseUnits,
                })
            .toList(),
      });
      await LocalDbService.updateIssuanceStatus(
          issuance.localId, 'pending_approval');
      _log.add('✓ Issuance request uploaded');
      _done('Issuance uploaded!');
      return SyncResult(
          success: true, message: 'Issuance uploaded successfully');
    } catch (e) {
      final msg = ApiService.friendlyError(e);
      _error(msg);
      return SyncResult(success: false, message: msg);
    }
  }

  Future<SyncResult> checkIssuanceStatus(String today) async {
    _start('Checking approval status...');
    try {
      final data = await ApiService.get(AppConstants.apiSalesmanIssuanceStatus);

      // Update issuance status
      final status = data['status'] as String? ?? 'pending';
      final issuance = await LocalDbService.getTodayIssuance(today);
      if (issuance != null) {
        await LocalDbService.updateIssuanceStatus(issuance.localId, status);
        _log.add('ℹ Issuance: $status');
      }

      // Update return status
      final returnStatus = data['returnStatus'] as String? ?? 'none';
      if (returnStatus != 'none') {
        final ret = await LocalDbService.getTodayReturn(today);
        if (ret != null) {
          await LocalDbService.updateReturnStatus(ret.localId, returnStatus);
          _log.add('ℹ Return: $returnStatus');
        }
      }

      _done('Status updated');
      return SyncResult(success: true, message: status);
    } catch (e) {
      final msg = ApiService.friendlyError(e);
      _error(msg);
      return SyncResult(success: false, message: msg);
    }
  }

  Future<SyncResult> uploadReturn(LocalReturn ret) async {
    _start('Uploading return...');
    try {
      await ApiService.post(AppConstants.apiSalesmanReturn, {
        'return_date': ret.returnDate,
        'cash_collected': ret.cashCollected ?? 0,
        'items': ret.items
            .map((i) => {
                  'product_id': i.productId,
                  'returned_cartons': i.returnedCartons,
                  'returned_loose': i.returnedLoose,
                })
            .toList(),
      });
      await LocalDbService.updateReturnStatus(ret.localId, 'pending_approval');
      _log.add('✓ Return uploaded');
      _done('Return uploaded!');
      return SyncResult(success: true, message: 'Return uploaded successfully');
    } catch (e) {
      final msg = ApiService.friendlyError(e);
      _error(msg);
      return SyncResult(success: false, message: msg);
    }
  }

  void _start(String msg) {
    _status = SyncStatus.syncing;
    _statusMessage = msg;
    _log = [];
    notifyListeners();
  }

  void _done(String msg) {
    _status = SyncStatus.success;
    _statusMessage = msg;
    notifyListeners();
  }

  void _error(String msg) {
    _status = SyncStatus.error;
    _statusMessage = msg;
    notifyListeners();
  }

  Future<void> _saveLastSync() async {
    final now = DateTime.now().toIso8601String();
    _lastSync = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLastSync, now);
  }

  void reset() {
    _status = SyncStatus.idle;
    _statusMessage = '';
    _log = [];
    notifyListeners();
  }
}
