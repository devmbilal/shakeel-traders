import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/local_db_service.dart';

class OBOrderBookingScreen extends StatefulWidget {
  final LocalShop shop;
  final LocalOrder? existingOrder; // null = new order, non-null = edit mode
  const OBOrderBookingScreen(
      {super.key, required this.shop, this.existingOrder});

  @override
  State<OBOrderBookingScreen> createState() => _OBOrderBookingScreenState();
}

class _OBOrderBookingScreenState extends State<OBOrderBookingScreen> {
  List<LocalProduct> _allProducts = [];
  List<LocalProduct> _filtered = [];
  final Map<int, _OrderEntry> _entries = {};
  Map<int, List<double>> _priceHistory = {};
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  late String _localId;

  @override
  void initState() {
    super.initState();
    // Reuse existing localId in edit mode, generate new one for new orders
    _localId = widget.existingOrder?.localId ?? const Uuid().v4();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final products = await LocalDbService.getProducts();

    // Pre-populate entries from existing order (edit mode)
    if (widget.existingOrder != null) {
      for (final item in widget.existingOrder!.items) {
        _entries[item.productId] = _OrderEntry(
          cartons: item.cartons,
          loose: item.looseUnits,
          price: item.unitPrice,
        );
      }
    }

    // Load price history for price-editable shops
    final history = <int, List<double>>{};
    if (widget.shop.priceEditAllowed) {
      for (final p in products) {
        final prices =
            await LocalDbService.getLastThreePrices(widget.shop.id, p.id);
        if (prices.isNotEmpty) {
          history[p.id] = prices;
        }
      }
    }

    if (mounted) {
      setState(() {
        _allProducts = products;
        _filtered = products;
        _priceHistory = history;
        _loading = false;
      });
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allProducts
          : _allProducts
              .where((p) =>
                  p.name.toLowerCase().contains(q) ||
                  p.skuCode.toLowerCase().contains(q))
              .toList();
    });
  }

  int get _itemCount =>
      _entries.values.where((e) => e.cartons > 0 || e.loose > 0).length;

  /// Compute basePrice for a product based on shop type
  double _basePrice(LocalProduct p) =>
      widget.shop.shopType == 'wholesale' ? p.wholesalePrice : p.retailPrice;

  Future<void> _saveOrder() async {
    final activeEntries = _entries.entries
        .where((e) => e.value.cartons > 0 || e.value.loose > 0)
        .toList();

    if (activeEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product to the order')),
      );
      return;
    }

    final now = DateTime.now().toIso8601String();

    final items = activeEntries.map((e) {
      final product = _allProducts.firstWhere((p) => p.id == e.key);
      return LocalOrderItem(
        orderLocalId: _localId,
        productId: product.id,
        productName: product.name,
        skuCode: product.skuCode,
        cartons: e.value.cartons,
        looseUnits: e.value.loose,
        unitPrice: e.value.price,
        unitsPerCarton: product.unitsPerCarton,
      );
    }).toList();

    final order = LocalOrder(
      localId: _localId,
      shopId: widget.shop.id,
      routeId: widget.shop.routeId,
      shopName: widget.shop.name,
      createdAtDevice: widget.existingOrder?.createdAtDevice ?? now,
      items: items,
    );

    await LocalDbService.saveOrder(order);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingOrder != null
              ? 'Order updated — ${items.length} products'
              : 'Order saved — ${items.length} products'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWholesale = widget.shop.shopType == 'wholesale';
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.shop.name,
                style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            Row(
              children: [
                Text(
                  widget.existingOrder != null ? 'Edit Order' : 'Order Booking',
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isWholesale
                        ? Colors.amber.withAlpha(60)
                        : Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isWholesale ? 'Wholesale' : 'Retail',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color:
                          isWholesale ? Colors.amber.shade200 : Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_itemCount > 0)
            TextButton.icon(
              onPressed: _showOrderSummary,
              icon: const Icon(Icons.receipt_long_rounded,
                  color: Colors.white, size: 18),
              label: Text('$_itemCount items',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by SKU or product name...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Product list
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent))
                : _filtered.isEmpty
                    ? const Center(
                        child: Text('No products found',
                            style: TextStyle(color: AppTheme.textMuted)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final p = _filtered[i];
                          final basePrice = _basePrice(p);
                          final entry =
                              _entries[p.id] ?? _OrderEntry(price: basePrice);
                          return _ProductRow(
                            product: p,
                            entry: entry,
                            basePrice: basePrice,
                            priceHistory: _priceHistory[p.id] ?? [],
                            shopPriceEditAllowed: widget.shop.priceEditAllowed,
                            shopMaxDiscountPct: widget.shop.priceMaxDiscountPct,
                            onChanged: (e) {
                              setState(() => _entries[p.id] = e);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _itemCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _saveOrder,
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(
                    widget.existingOrder != null
                        ? 'Update Order ($_itemCount products)'
                        : 'Save Order ($_itemCount products)',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _showOrderSummary() {
    final activeEntries = _entries.entries
        .where((e) => e.value.cartons > 0 || e.value.loose > 0)
        .toList();

    double total = 0;
    for (final e in activeEntries) {
      final p = _allProducts.firstWhere((p) => p.id == e.key);
      total +=
          (e.value.cartons * p.unitsPerCarton + e.value.loose) * e.value.price;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text('Order Summary',
                      style: GoogleFonts.manrope(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const Spacer(),
                  Text('Rs ${total.toStringAsFixed(0)}',
                      style: GoogleFonts.manrope(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accent)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: activeEntries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final e = activeEntries[i];
                  final p = _allProducts.firstWhere((p) => p.id == e.key);
                  final lineTotal =
                      (e.value.cartons * p.unitsPerCarton + e.value.loose) *
                          e.value.price;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              Text(
                                '${e.value.cartons}C + ${e.value.loose}L × Rs ${e.value.price.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Text('Rs ${lineTotal.toStringAsFixed(0)}',
                            style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.textPrimary)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _saveOrder();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    widget.existingOrder != null
                        ? 'Confirm & Update Order'
                        : 'Confirm & Save Order',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderEntry {
  int cartons;
  int loose;
  double price;
  _OrderEntry({this.cartons = 0, this.loose = 0, required this.price});
  _OrderEntry copyWith({int? cartons, int? loose, double? price}) =>
      _OrderEntry(
          cartons: cartons ?? this.cartons,
          loose: loose ?? this.loose,
          price: price ?? this.price);
}

class _ProductRow extends StatefulWidget {
  final LocalProduct product;
  final _OrderEntry entry;
  final double basePrice;
  final List<double> priceHistory;
  final bool shopPriceEditAllowed;

  /// Maximum discount % allowed (0 to N). Price must be >= basePrice * (1 - maxDiscountPct/100).
  final double shopMaxDiscountPct;
  final ValueChanged<_OrderEntry> onChanged;

  const _ProductRow({
    required this.product,
    required this.entry,
    required this.basePrice,
    required this.priceHistory,
    required this.shopPriceEditAllowed,
    required this.shopMaxDiscountPct,
    required this.onChanged,
  });

  @override
  State<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<_ProductRow> {
  late TextEditingController _cartonsCtrl;
  late TextEditingController _looseCtrl;
  late TextEditingController _priceCtrl;
  bool _expanded = false;
  bool _priceError = false;
  bool _snackbarPending = false;

  @override
  void initState() {
    super.initState();
    _cartonsCtrl = TextEditingController(
        text: widget.entry.cartons > 0 ? '${widget.entry.cartons}' : '');
    _looseCtrl = TextEditingController(
        text: widget.entry.loose > 0 ? '${widget.entry.loose}' : '');
    _priceCtrl =
        TextEditingController(text: widget.entry.price.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _cartonsCtrl.dispose();
    _looseCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  bool get _hasQty => widget.entry.cartons > 0 || widget.entry.loose > 0;

  double get _minAllowed =>
      widget.basePrice * (1 - widget.shopMaxDiscountPct / 100);

  void _showSnackbar(String message, {Color? color}) {
    if (_snackbarPending) return;
    _snackbarPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _snackbarPending = false;
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: color,
            duration: const Duration(seconds: 3),
          ));
      }
    });
  }

  void _update() {
    final c = int.tryParse(_cartonsCtrl.text) ?? 0;
    final l = int.tryParse(_looseCtrl.text) ?? 0;
    double p = double.tryParse(_priceCtrl.text) ?? widget.basePrice;

    bool hasError = false;

    if (widget.shopPriceEditAllowed) {
      final minAllowed = _minAllowed;
      if (p < minAllowed) {
        hasError = true;
        _showSnackbar(
          'Price too low. Max discount is ${widget.shopMaxDiscountPct.toStringAsFixed(0)}% '
          '(min Rs ${minAllowed.toStringAsFixed(0)})',
          color: Colors.red.shade600,
        );
      } else if (p > widget.basePrice) {
        p = widget.basePrice;
        _priceCtrl.text = p.toStringAsFixed(0);
        _showSnackbar(
            'Price cannot exceed base price (Rs ${widget.basePrice.toStringAsFixed(0)})');
      }
    }

    setState(() => _priceError = hasError);

    if (!hasError) {
      widget.onChanged(widget.entry.copyWith(cartons: c, loose: l, price: p));
    } else {
      widget.onChanged(widget.entry
          .copyWith(cartons: c, loose: l, price: widget.entry.price));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _priceError
              ? Colors.red.shade400
              : _hasQty
                  ? AppTheme.accent
                  : AppTheme.border,
          width: (_priceError || _hasQty) ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.product.name,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(widget.product.skuCode,
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: AppTheme.textMuted)),
                            const SizedBox(width: 8),
                            Text('Rs ${widget.basePrice.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            Text(
                                'Stock: ${widget.product.currentStockCartons}C+${widget.product.currentStockLoose}L',
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: AppTheme.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_priceError)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Price error',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade600),
                      ),
                    )
                  else if (_hasQty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${widget.entry.cartons}C+${widget.entry.loose}L',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accent),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppTheme.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QtyField(
                          controller: _cartonsCtrl,
                          label: 'Cartons',
                          onChanged: (_) => _update(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QtyField(
                          controller: _looseCtrl,
                          label: 'Loose Units',
                          onChanged: (_) => _update(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QtyField(
                          controller: _priceCtrl,
                          label: 'Price (Rs)',
                          onChanged: (_) => _update(),
                          readOnly: !widget.shopPriceEditAllowed,
                          isDecimal: true,
                          hasError: _priceError,
                        ),
                      ),
                    ],
                  ),
                  // Price history — shown only for price-editable shops
                  if (widget.shopPriceEditAllowed &&
                      widget.priceHistory.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Prev prices: ',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: AppTheme.textMuted)),
                        ...widget.priceHistory.map((price) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withAlpha(15),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: AppTheme.accent.withAlpha(50)),
                                ),
                                child: Text(
                                  'Rs ${price.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.accent),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ],
                  // Discount hint for editable shops
                  if (widget.shopPriceEditAllowed) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Max discount: ${widget.shopMaxDiscountPct.toStringAsFixed(0)}% '
                      '(min Rs ${_minAllowed.toStringAsFixed(0)})',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _priceError
                              ? Colors.red.shade600
                              : AppTheme.textMuted),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QtyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final bool isDecimal;
  final bool hasError;

  const _QtyField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.readOnly = false,
    this.isDecimal = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      keyboardType: isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [
        if (!isDecimal) FilteringTextInputFormatter.digitsOnly,
      ],
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: hasError
              ? Colors.red.shade600
              : readOnly
                  ? AppTheme.textMuted
                  : AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        filled: true,
        fillColor: readOnly ? AppTheme.bg : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade400 : AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade400 : AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade600 : AppTheme.accent,
              width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
    );
  }
}
