import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/local_db_service.dart';

class OBSummaryScreen extends StatefulWidget {
  final ValueNotifier<int>? reloadNotifier;
  const OBSummaryScreen({super.key, this.reloadNotifier});
  @override
  State<OBSummaryScreen> createState() => _OBSummaryScreenState();
}

class _OBSummaryScreenState extends State<OBSummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<LocalOrder> _orders = [];
  List<LocalRecoveryAssignment> _recoveries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
    widget.reloadNotifier?.addListener(_load);
  }

  @override
  void dispose() {
    _tabs.dispose();
    widget.reloadNotifier?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final orders = await LocalDbService.getTodayOrders(today);
    final recoveries = await LocalDbService.getTodayRecoveries();
    if (mounted) {
      setState(() {
        _orders = orders;
        _recoveries = recoveries;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text("Today's Summary"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Orders (${_orders.length})'),
            Tab(text: 'Recovery (${_recoveries.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : TabBarView(
              controller: _tabs,
              children: [
                _OrdersTab(orders: _orders),
                _RecoveryTab(recoveries: _recoveries),
              ],
            ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final List<LocalOrder> orders;
  const _OrdersTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _Empty(
          icon: Icons.receipt_long_outlined, text: 'No orders booked today');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final o = orders[i];
        final isSynced = o.status == 'synced';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSynced
                      ? AppTheme.success.withAlpha(20)
                      : AppTheme.warning.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSynced ? Icons.check_circle_rounded : Icons.pending_rounded,
                  color: isSynced ? AppTheme.success : AppTheme.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.shopName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppTheme.textPrimary)),
                    Text(
                        '${o.items.length} products · ${_formatTime(o.createdAtDevice)}',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppTheme.textMuted)),
                    if (o.stockCheckNote != null)
                      Text('⚠ ${o.stockCheckNote}',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppTheme.warning)),
                  ],
                ),
              ),
              _StatusBadge(
                label: isSynced ? 'Synced' : 'Pending',
                color: isSynced ? AppTheme.success : AppTheme.warning,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(String iso) {
    try {
      return DateFormat('h:mm a').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return '';
    }
  }
}

class _RecoveryTab extends StatelessWidget {
  final List<LocalRecoveryAssignment> recoveries;
  const _RecoveryTab({required this.recoveries});

  @override
  Widget build(BuildContext context) {
    if (recoveries.isEmpty) {
      return _Empty(
          icon: Icons.payments_outlined, text: 'No recovery bills today');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: recoveries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = recoveries[i];
        final isCollected = r.collectedAmount != null && r.collectedAmount! > 0;
        final isSynced = r.status == 'synced';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSynced
                      ? AppTheme.success.withAlpha(20)
                      : isCollected
                          ? AppTheme.accent.withAlpha(20)
                          : AppTheme.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSynced
                      ? Icons.check_circle_rounded
                      : isCollected
                          ? Icons.payments_rounded
                          : Icons.pending_rounded,
                  color: isSynced
                      ? AppTheme.success
                      : isCollected
                          ? AppTheme.accent
                          : AppTheme.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.shopName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppTheme.textPrimary)),
                    Text(
                        '${r.billNumber} · Rs ${r.outstandingAmount.toStringAsFixed(0)} outstanding',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppTheme.textMuted)),
                    if (isCollected)
                      Text(
                          'Collected: Rs ${r.collectedAmount!.toStringAsFixed(0)} (${r.paymentMethod})',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.success,
                              fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              _StatusBadge(
                label: isSynced
                    ? 'Synced'
                    : isCollected
                        ? 'Collected'
                        : 'Pending',
                color: isSynced
                    ? AppTheme.success
                    : isCollected
                        ? AppTheme.accent
                        : AppTheme.textMuted,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Empty({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(text,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
