import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/local_db_service.dart';

class OBOrderBookingScreen extends StatefulWidget {
  final LocalShop shop;
  const OBOrderBookingScreen({super.key, required this.shop});

  @override
  State<OBOrderBookingScreen> createState() => _OBOrderBookingScreenState();
}

class _OBOrderBookingScreenState extends State<OBOrderBookingScreen> {
  List<LocalProduct> _allProducts = [];
  List<LocalProduct> _filtered = [];
  final Map<int, _OrderEntry> _entries = {};
  final _searchCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
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
    if (mounted) {
      setState(() {
        _allProducts = products;
        _filtered = products;
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

    final localId = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    final items = activeEntries.map((e) {
      final product = _allProducts.firstWhere((p) => p.id == e.key);
      return LocalOrderItem(
        orderLocalId: localId,
        productId: product.id,
        productName: product.name,
        skuCode: product.skuCode,
        cartons: e.value.cartons,
        looseUnits: e.value.loose,
        unitPrice: e.value.price,
      );
    }).toList();

    final order = LocalOrder(
      localId: localId,
      shopId: widget.shop.id,
      routeId: widget.shop.routeId,
      shopName: widget.shop.name,
      createdAtDevice: now,
      items: items,
    );

    await LocalDbService.saveOrder(order);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order saved — ${items.length} products'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Order Booking',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
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
                          final entry = _entries[p.id] ??
                              _OrderEntry(price: p.retailPrice);
                          return _ProductRow(
                            product: p,
                            entry: entry,
                            shopLastPrice: null, // loaded lazily
                            shopPriceEditAllowed: widget.shop.priceEditAllowed,
                            shopMinPct: widget.shop.priceMinPct,
                            shopMaxPct: widget.shop.priceMaxPct,
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
                  label: Text('Save Order ($_itemCount products)',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white)),
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
                  child: Text('Confirm & Save Order',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white)),
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
  final double? shopLastPrice;
  final bool shopPriceEditAllowed;
  final double shopMinPct;
  final double shopMaxPct;
  final ValueChanged<_OrderEntry> onChanged;

  const _ProductRow({
    required this.product,
    required this.entry,
    required this.shopLastPrice,
    required this.shopPriceEditAllowed,
    required this.shopMinPct,
    required this.shopMaxPct,
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

  void _update() {
    final c = int.tryParse(_cartonsCtrl.text) ?? 0;
    final l = int.tryParse(_looseCtrl.text) ?? 0;
    final p = double.tryParse(_priceCtrl.text) ?? widget.product.retailPrice;
    widget.onChanged(widget.entry.copyWith(cartons: c, loose: l, price: p));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _hasQty ? AppTheme.accent : AppTheme.border,
          width: _hasQty ? 1.5 : 1,
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
                            Text(
                                'Rs ${widget.product.retailPrice.toStringAsFixed(0)}',
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
                  if (_hasQty)
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
                        ),
                      ),
                    ],
                  ),
                  if (widget.shopLastPrice != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Last price: Rs ${widget.shopLastPrice!.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppTheme.textMuted),
                      ),
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

  const _QtyField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.readOnly = false,
    this.isDecimal = false,
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
          color: readOnly ? AppTheme.textMuted : AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
        filled: true,
        fillColor: readOnly ? AppTheme.bg : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
    );
  }
}
