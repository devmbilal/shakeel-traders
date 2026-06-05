import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/local_db_service.dart';

class OBRecoveryScreen extends StatefulWidget {
  final ValueNotifier<int>? reloadNotifier;
  const OBRecoveryScreen({super.key, this.reloadNotifier});
  @override
  State<OBRecoveryScreen> createState() => _OBRecoveryScreenState();
}

class _OBRecoveryScreenState extends State<OBRecoveryScreen> {
  List<LocalRecoveryAssignment> _assignments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    widget.reloadNotifier?.addListener(_load);
  }

  @override
  void dispose() {
    widget.reloadNotifier?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final list = await LocalDbService.getTodayRecoveries();
    if (mounted)
      setState(() {
        _assignments = list;
        _loading = false;
      });
  }

  double get _totalCollected => _assignments
      .where((a) => a.collectedAmount != null && a.collectedAmount! > 0)
      .fold(0, (sum, a) => sum + a.collectedAmount!);

  double get _totalOutstanding =>
      _assignments.fold(0, (sum, a) => sum + a.outstandingAmount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Cash Recovery'),
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
                // Summary bar
                if (_assignments.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            label: 'Total Outstanding',
                            value: 'Rs ${_totalOutstanding.toStringAsFixed(0)}',
                            color: AppTheme.warning,
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.white12),
                        Expanded(
                          child: _SummaryItem(
                            label: 'Collected Today',
                            value: 'Rs ${_totalCollected.toStringAsFixed(0)}',
                            color: AppTheme.success,
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.white12),
                        Expanded(
                          child: _SummaryItem(
                            label: 'Bills',
                            value: '${_assignments.length}',
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                  ),

                // List
                Expanded(
                  child: _assignments.isEmpty
                      ? _EmptyRecovery()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _assignments.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) => _RecoveryCard(
                              assignment: _assignments[i],
                              onUpdated: (updated) async {
                                await LocalDbService.updateRecovery(updated);
                                _load();
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.manrope(
                color: color, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  final LocalRecoveryAssignment assignment;
  final ValueChanged<LocalRecoveryAssignment> onUpdated;
  const _RecoveryCard({required this.assignment, required this.onUpdated});

  @override
  Widget build(BuildContext context) {
    final isCollected =
        assignment.collectedAmount != null && assignment.collectedAmount! > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCollected ? AppTheme.success : AppTheme.border,
          width: isCollected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(assignment.shopName,
                          style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppTheme.textPrimary)),
                    ),
                    if (isCollected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Collected',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.success)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _InfoChip(
                        label: assignment.billNumber,
                        icon: Icons.receipt_outlined),
                    const SizedBox(width: 8),
                    _InfoChip(
                        label: assignment.billDate,
                        icon: Icons.calendar_today_outlined),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _AmountBox(
                        label: 'Bill Amount',
                        value: 'Rs ${assignment.netAmount.toStringAsFixed(0)}',
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AmountBox(
                        label: 'Outstanding',
                        value:
                            'Rs ${assignment.outstandingAmount.toStringAsFixed(0)}',
                        color: AppTheme.warning,
                      ),
                    ),
                    if (isCollected) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AmountBox(
                          label: 'Collected',
                          value:
                              'Rs ${assignment.collectedAmount!.toStringAsFixed(0)}',
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCollectionDialog(context),
                icon: Icon(
                  isCollected ? Icons.edit_rounded : Icons.payments_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  isCollected ? 'Edit Collection' : 'Record Collection',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCollected ? AppTheme.textSecondary : AppTheme.accent,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCollectionDialog(BuildContext context) {
    final amountCtrl = TextEditingController(
        text: assignment.collectedAmount?.toStringAsFixed(0) ?? '');
    String method = assignment.paymentMethod ?? 'cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Record Collection',
                    style: GoogleFonts.manrope(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(assignment.shopName,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.textMuted)),
                const SizedBox(height: 20),
                Text(
                    'Outstanding: Rs ${assignment.outstandingAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.warning,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                  ],
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Amount Collected (Rs)',
                    prefixIcon: const Icon(Icons.payments_outlined, size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Payment Method',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _MethodButton(
                        label: 'Cash',
                        icon: Icons.money_rounded,
                        selected: method == 'cash',
                        onTap: () => setModalState(() => method = 'cash'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MethodButton(
                        label: 'Bank Transfer',
                        icon: Icons.account_balance_rounded,
                        selected: method == 'bank_transfer',
                        onTap: () =>
                            setModalState(() => method = 'bank_transfer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(amountCtrl.text) ?? 0;
                      if (amount <= 0) return;
                      assignment.collectedAmount = amount;
                      assignment.paymentMethod = method;
                      assignment.status = 'collected';
                      onUpdated(assignment);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Save Collection',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _MethodButton(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withAlpha(20) : AppTheme.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? AppTheme.accent : AppTheme.textMuted,
                size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        selected ? AppTheme.accent : AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }
}

class _AmountBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AmountBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _EmptyRecovery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payments_outlined,
                size: 56, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text('No Recovery Bills',
                style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(
              'Admin hasn\'t assigned any recovery bills to you today. Do a mid-day sync to check for new assignments.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
