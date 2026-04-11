import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/local_db_service.dart';

class SMIssuanceScreen extends StatefulWidget {
  final ValueNotifier<int>? reloadNotifier;
  const SMIssuanceScreen({super.key, this.reloadNotifier});
  @override
  State<SMIssuanceScreen> createState() => _SMIssuanceScreenPublicState();
}

class _SMIssuanceScreenPublicState extends State<SMIssuanceScreen> {
  List<LocalProduct> _allProducts = [];
  List<LocalProduct> _filtered = [];
  final Map<int, _IssuanceEntry> _entries = {};
  final _searchCtrl = TextEditingController();
  LocalIssuance? _existingIssuance;
  bool _loading = true;
  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
    widget.reloadNotifier?.addListener(_load);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    widget.reloadNotifier?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final products = await LocalDbService.getProducts();
    final existing = await LocalDbService.getTodayIssuance(_today);
    if (mounted) {
      setState(() {
        _allProducts = products;
        _filtered = products;
        _existingIssuance = existing;
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

  bool get _isReadOnly =>
      _existingIssuance != null && _existingIssuance!.status != 'pending_sync';

  Future<void> _submit() async {
    final activeEntries = _entries.entries
        .where((e) => e.value.cartons > 0 || e.value.loose > 0)
        .toList();

    if (activeEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product')),
      );
      return;
    }

    final localId = const Uuid().v4();
    final items = activeEntries.map((e) {
      final p = _allProducts.firstWhere((p) => p.id == e.key);
      return LocalIssuanceItem(
        issuanceLocalId: localId,
        productId: p.id,
        productName: p.name,
        skuCode: p.skuCode,
        cartons: e.value.cartons,
        looseUnits: e.value.loose,
      );
    }).toList();

    final issuance = LocalIssuance(
      localId: localId,
      issuanceDate: _today,
      status: 'pending_sync',
      items: items,
    );

    await LocalDbService.saveIssuance(issuance);
    if (mounted) {
      setState(() => _existingIssuance = issuance);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issuance saved — sync to send to server'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Stock Issuance'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : Column(
              children: [
                // Status banner
                if (_existingIssuance != null)
                  _StatusBanner(status: _existingIssuance!.status),

                // Search
                if (!_isReadOnly)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                // Product list or read-only view
                Expanded(
                  child: _isReadOnly
                      ? _ReadOnlyIssuance(
                          issuance: _existingIssuance!, products: _allProducts)
                      : _filtered.isEmpty
                          ? const Center(
                              child: Text('No products found',
                                  style: TextStyle(color: AppTheme.textMuted)))
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 0, 12, 100),
                              itemCount: _filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final p = _filtered[i];
                                final entry =
                                    _entries[p.id] ?? _IssuanceEntry();
                                return _IssuanceRow(
                                  product: p,
                                  entry: entry,
                                  onChanged: (e) =>
                                      setState(() => _entries[p.id] = e),
                                );
                              },
                            ),
                ),
              ],
            ),
      bottomNavigationBar: !_isReadOnly && _itemCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text('Submit Issuance ($_itemCount products)',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
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
}

class _IssuanceEntry {
  int cartons;
  int loose;
  _IssuanceEntry({this.cartons = 0, this.loose = 0});
  _IssuanceEntry copyWith({int? cartons, int? loose}) => _IssuanceEntry(
      cartons: cartons ?? this.cartons, loose: loose ?? this.loose);
}

class _IssuanceRow extends StatefulWidget {
  final LocalProduct product;
  final _IssuanceEntry entry;
  final ValueChanged<_IssuanceEntry> onChanged;
  const _IssuanceRow(
      {required this.product, required this.entry, required this.onChanged});

  @override
  State<_IssuanceRow> createState() => _IssuanceRowState();
}

class _IssuanceRowState extends State<_IssuanceRow> {
  late TextEditingController _cartonsCtrl;
  late TextEditingController _looseCtrl;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _cartonsCtrl = TextEditingController(
        text: widget.entry.cartons > 0 ? '${widget.entry.cartons}' : '');
    _looseCtrl = TextEditingController(
        text: widget.entry.loose > 0 ? '${widget.entry.loose}' : '');
  }

  @override
  void dispose() {
    _cartonsCtrl.dispose();
    _looseCtrl.dispose();
    super.dispose();
  }

  bool get _hasQty => widget.entry.cartons > 0 || widget.entry.loose > 0;

  void _update() {
    final c = int.tryParse(_cartonsCtrl.text) ?? 0;
    final l = int.tryParse(_looseCtrl.text) ?? 0;
    widget.onChanged(widget.entry.copyWith(cartons: c, loose: l));
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
                              'Stock: ${widget.product.currentStockCartons}C+${widget.product.currentStockLoose}L',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: widget.product.totalUnits > 0
                                      ? AppTheme.success
                                      : AppTheme.danger),
                            ),
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
                              color: AppTheme.accent)),
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
                        child: _QtyInput(
                          controller: _cartonsCtrl,
                          label: 'Cartons',
                          onChanged: (_) => _update(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QtyInput(
                          controller: _looseCtrl,
                          label: 'Loose Units',
                          onChanged: (_) => _update(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QtyInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  const _QtyInput(
      {required this.controller, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
        filled: true,
        fillColor: Colors.white,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case 'approved':
        color = AppTheme.success;
        label = 'Issuance Approved';
        icon = Icons.check_circle_rounded;
        break;
      case 'pending_approval':
        color = AppTheme.warning;
        label = 'Pending Admin Approval';
        icon = Icons.hourglass_top_rounded;
        break;
      default:
        color = AppTheme.accent;
        label = 'Saved — Not Synced Yet';
        icon = Icons.upload_rounded;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color.withAlpha(20),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _ReadOnlyIssuance extends StatelessWidget {
  final LocalIssuance issuance;
  final List<LocalProduct> products;
  const _ReadOnlyIssuance({required this.issuance, required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: issuance.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final item = issuance.items[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppTheme.textPrimary)),
                    Text(item.skuCode,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Text('${item.cartons}C + ${item.looseUnits}L',
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.accent)),
            ],
          ),
        );
      },
    );
  }
}
