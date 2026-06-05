import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/local_db_service.dart';

class SMSummaryScreen extends StatefulWidget {
  final ValueNotifier<int>? reloadNotifier;
  const SMSummaryScreen({super.key, this.reloadNotifier});
  @override
  State<SMSummaryScreen> createState() => _SMSummaryScreenState();
}

class _SMSummaryScreenState extends State<SMSummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  LocalIssuance? _issuance;
  LocalReturn? _ret;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
    widget.reloadNotifier?.addListener(_load);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    widget.reloadNotifier?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final issuance = await LocalDbService.getTodayIssuance(today);
    final ret = await LocalDbService.getTodayReturn(today);
    if (mounted) {
      setState(() {
        _issuance = issuance;
        _ret = ret;
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
          tabs: const [
            Tab(text: 'Issuance'),
            Tab(text: 'Return'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : TabBarView(
              controller: _tabs,
              children: [
                _IssuanceTab(issuance: _issuance),
                _ReturnTab(ret: _ret),
              ],
            ),
    );
  }
}

class _IssuanceTab extends StatelessWidget {
  final LocalIssuance? issuance;
  const _IssuanceTab({required this.issuance});

  @override
  Widget build(BuildContext context) {
    if (issuance == null) {
      return _Empty(
          icon: Icons.inventory_2_outlined,
          text: 'No issuance submitted today');
    }

    Color statusColor;
    String statusLabel;
    switch (issuance!.status) {
      case 'approved':
        statusColor = AppTheme.success;
        statusLabel = 'Approved';
        break;
      case 'pending_approval':
        statusColor = AppTheme.warning;
        statusLabel = 'Pending Approval';
        break;
      default:
        statusColor = AppTheme.accent;
        statusLabel = 'Not Synced';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withAlpha(60)),
          ),
          child: Row(
            children: [
              Icon(Icons.inventory_2_rounded, color: statusColor, size: 22),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Issuance Status',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppTheme.textMuted)),
                  Text(statusLabel,
                      style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: statusColor)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...issuance!.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
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
                                  fontWeight: FontWeight.w600, fontSize: 13)),
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
              ),
            )),
      ],
    );
  }
}

class _ReturnTab extends StatelessWidget {
  final LocalReturn? ret;
  const _ReturnTab({required this.ret});

  @override
  Widget build(BuildContext context) {
    if (ret == null) {
      return _Empty(
          icon: Icons.assignment_return_outlined,
          text: 'No return submitted today');
    }

    Color statusColor;
    String statusLabel;
    switch (ret!.status) {
      case 'approved':
        statusColor = AppTheme.success;
        statusLabel = 'Approved';
        break;
      case 'pending_approval':
        statusColor = AppTheme.warning;
        statusLabel = 'Pending Approval';
        break;
      default:
        statusColor = AppTheme.accent;
        statusLabel = 'Not Synced';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withAlpha(60)),
          ),
          child: Row(
            children: [
              Icon(Icons.assignment_return_rounded,
                  color: statusColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Return Status',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppTheme.textMuted)),
                    Text(statusLabel,
                        style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: statusColor)),
                    if (ret!.cashCollected != null && ret!.cashCollected! > 0)
                      Text('Cash: Rs ${ret!.cashCollected!.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.success,
                              fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...ret!.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
                        _Box(
                            label: 'Issued',
                            value:
                                '${item.issuedCartons}C+${item.issuedLoose}L',
                            color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        _Box(
                            label: 'Returned',
                            value:
                                '${item.returnedCartons}C+${item.returnedLoose}L',
                            color: AppTheme.warning),
                        const SizedBox(width: 6),
                        _Box(
                            label: 'Sold',
                            value: '${item.soldCartons}C+${item.soldLoose}L',
                            color: AppTheme.success),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Box({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
                    fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
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
