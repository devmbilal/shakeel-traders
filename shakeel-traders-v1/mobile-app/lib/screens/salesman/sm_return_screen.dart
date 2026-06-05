import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/local_db_service.dart';

class SMReturnScreen extends StatefulWidget {
  final ValueNotifier<int>? reloadNotifier;
  const SMReturnScreen({super.key, this.reloadNotifier});
  @override
  State<SMReturnScreen> createState() => _SMReturnScreenState();
}

class _SMReturnScreenState extends State<SMReturnScreen> {
  LocalIssuance? _issuance;
  LocalReturn? _existingReturn;
  final Map<int, _ReturnEntry> _entries = {};
  final _cashCtrl = TextEditingController();
  bool _loading = true;
  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
    widget.reloadNotifier?.addListener(_load);
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    widget.reloadNotifier?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final issuance = await LocalDbService.getTodayIssuance(_today);
    final ret = await LocalDbService.getTodayReturn(_today);
    if (!mounted) return;
    setState(() {
      _issuance = issuance;
      _existingReturn = ret;
      _loading = false;
      // Only populate entries if no return exists yet and entries are empty
      if (issuance != null && ret == null && _entries.isEmpty) {
        for (final item in issuance.items) {
          _entries[item.productId] = _ReturnEntry(
            issuedCartons: item.cartons,
            issuedLoose: item.looseUnits,
          );
        }
      }
    });
  }

  bool get _isReadOnly =>
      _existingReturn != null &&
      (_existingReturn!.status == 'approved' ||
          _existingReturn!.status == 'pending_approval');

  Future<void> _submit() async {
    if (_issuance == null) return;

    final localId = const Uuid().v4();
    final items = _entries.entries.map((e) {
      final issuanceItem =
          _issuance!.items.firstWhere((i) => i.productId == e.key);
      return LocalReturnItem(
        returnLocalId: localId,
        productId: e.key,
        productName: issuanceItem.productName,
        skuCode: issuanceItem.skuCode,
        issuedCartons: e.value.issuedCartons,
        issuedLoose: e.value.issuedLoose,
        returnedCartons: e.value.returnedCartons,
        returnedLoose: e.value.returnedLoose,
      );
    }).toList();

    final cash = double.tryParse(_cashCtrl.text) ?? 0;
    final ret = LocalReturn(
      localId: localId,
      issuanceLocalId: _issuance!.localId,
      returnDate: _today,
      status: 'pending_sync',
      cashCollected: cash > 0 ? cash : null,
      items: items,
    );

    await LocalDbService.saveReturn(ret);
    if (mounted) {
      setState(() => _existingReturn = ret);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Return saved — sync to send to server'),
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
        title: const Text('Stock Return'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : _issuance == null
              ? _NoIssuance()
              : _issuance!.status != 'approved'
                  ? _IssuancePending()
                  : Column(
                      children: [
                        if (_existingReturn != null)
                          _StatusBanner(status: _existingReturn!.status),
                        Expanded(
                          child: _isReadOnly
                              ? _ReadOnlyReturn(
                                  ret: _existingReturn!, issuance: _issuance!)
                              : _ReturnForm(
                                  issuance: _issuance!,
                                  entries: _entries,
                                  cashCtrl: _cashCtrl,
                                  onEntryChanged: (id, e) =>
                                      setState(() => _entries[id] = e),
                                ),
                        ),
                      ],
                    ),
      bottomNavigationBar: !_isReadOnly &&
              _issuance != null &&
              _issuance!.status == 'approved' &&
              _existingReturn == null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text('Submit Return',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
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

class _ReturnEntry {
  final int issuedCartons;
  final int issuedLoose;
  int returnedCartons;
  int returnedLoose;

  _ReturnEntry({
    required this.issuedCartons,
    required this.issuedLoose,
    this.returnedCartons = 0,
    this.returnedLoose = 0,
  });

  int get soldCartons => issuedCartons - returnedCartons;
  int get soldLoose => issuedLoose - returnedLoose;

  _ReturnEntry copyWith({int? returnedCartons, int? returnedLoose}) =>
      _ReturnEntry(
        issuedCartons: issuedCartons,
        issuedLoose: issuedLoose,
        returnedCartons: returnedCartons ?? this.returnedCartons,
        returnedLoose: returnedLoose ?? this.returnedLoose,
      );
}

class _ReturnForm extends StatelessWidget {
  final LocalIssuance issuance;
  final Map<int, _ReturnEntry> entries;
  final TextEditingController cashCtrl;
  final void Function(int, _ReturnEntry) onEntryChanged;

  const _ReturnForm({
    required this.issuance,
    required this.entries,
    required this.cashCtrl,
    required this.onEntryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        ...issuance.items.map((item) {
          final entry = entries[item.productId] ??
              _ReturnEntry(
                  issuedCartons: item.cartons, issuedLoose: item.looseUnits);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ReturnItemCard(
              item: item,
              entry: entry,
              onChanged: (e) => onEntryChanged(item.productId, e),
            ),
          );
        }),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cash Collected (Optional)',
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              TextField(
                controller: cashCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                ],
                decoration: InputDecoration(
                  labelText: 'Amount (Rs)',
                  prefixIcon: const Icon(Icons.payments_outlined, size: 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReturnItemCard extends StatefulWidget {
  final LocalIssuanceItem item;
  final _ReturnEntry entry;
  final ValueChanged<_ReturnEntry> onChanged;
  const _ReturnItemCard(
      {required this.item, required this.entry, required this.onChanged});

  @override
  State<_ReturnItemCard> createState() => _ReturnItemCardState();
}

class _ReturnItemCardState extends State<_ReturnItemCard> {
  late TextEditingController _cartonsCtrl;
  late TextEditingController _looseCtrl;

  @override
  void initState() {
    super.initState();
    _cartonsCtrl = TextEditingController(
        text: widget.entry.returnedCartons > 0
            ? '${widget.entry.returnedCartons}'
            : '');
    _looseCtrl = TextEditingController(
        text: widget.entry.returnedLoose > 0
            ? '${widget.entry.returnedLoose}'
            : '');
  }

  @override
  void dispose() {
    _cartonsCtrl.dispose();
    _looseCtrl.dispose();
    super.dispose();
  }

  void _update() {
    final rc = int.tryParse(_cartonsCtrl.text) ?? 0;
    final rl = int.tryParse(_looseCtrl.text) ?? 0;
    widget.onChanged(
        widget.entry.copyWith(returnedCartons: rc, returnedLoose: rl));
  }

  @override
  Widget build(BuildContext context) {
    final soldC =
        widget.entry.issuedCartons - (int.tryParse(_cartonsCtrl.text) ?? 0);
    final soldL =
        widget.entry.issuedLoose - (int.tryParse(_looseCtrl.text) ?? 0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.item.productName,
              style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('Issued: ${widget.item.cartons}C + ${widget.item.looseUnits}L',
              style:
                  GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ReturnInput(
                  controller: _cartonsCtrl,
                  label: 'Return Cartons',
                  onChanged: (_) => setState(_update),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReturnInput(
                  controller: _looseCtrl,
                  label: 'Return Loose',
                  onChanged: (_) => setState(_update),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.success.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_rounded,
                    size: 14, color: AppTheme.success),
                const SizedBox(width: 6),
                Text('Sold: ${soldC.clamp(0, 999)}C + ${soldL.clamp(0, 999)}L',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReturnInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  const _ReturnInput(
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
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
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

class _ReadOnlyReturn extends StatelessWidget {
  final LocalReturn ret;
  final LocalIssuance issuance;
  const _ReadOnlyReturn({required this.ret, required this.issuance});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...ret.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _InfoBox(
                            label: 'Issued',
                            value:
                                '${item.issuedCartons}C+${item.issuedLoose}L',
                            color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        _InfoBox(
                            label: 'Returned',
                            value:
                                '${item.returnedCartons}C+${item.returnedLoose}L',
                            color: AppTheme.warning),
                        const SizedBox(width: 8),
                        _InfoBox(
                            label: 'Sold',
                            value: '${item.soldCartons}C+${item.soldLoose}L',
                            color: AppTheme.success),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        if (ret.cashCollected != null && ret.cashCollected! > 0)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.success.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.success.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_rounded,
                    color: AppTheme.success, size: 20),
                const SizedBox(width: 10),
                Text(
                    'Cash Collected: Rs ${ret.cashCollected!.toStringAsFixed(0)}',
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.success)),
              ],
            ),
          ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(label,
                style:
                    GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
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
    switch (status) {
      case 'approved':
        color = AppTheme.success;
        label = 'Return Approved';
        break;
      case 'pending_approval':
        color = AppTheme.warning;
        label = 'Pending Admin Approval';
        break;
      default:
        color = AppTheme.accent;
        label = 'Saved — Not Synced Yet';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color.withAlpha(20),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _NoIssuance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 56, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text('No Issuance Today',
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text('Submit a stock issuance request first.',
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _IssuancePending extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top_rounded,
                size: 56, color: AppTheme.warning),
            const SizedBox(height: 16),
            Text('Waiting for Approval',
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(
                'Your issuance request is pending admin approval. Check approval status from the Home screen.',
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
