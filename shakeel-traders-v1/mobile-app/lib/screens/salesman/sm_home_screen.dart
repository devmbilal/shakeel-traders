import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import '../../services/local_db_service.dart';
import '../shared/connection_screen.dart';
import 'sm_issuance_screen.dart';
import 'sm_return_screen.dart';
import 'sm_summary_screen.dart';
import 'sm_sync_screen.dart';

class SMHomeScreen extends StatefulWidget {
  const SMHomeScreen({super.key});
  @override
  State<SMHomeScreen> createState() => _SMHomeScreenState();
}

class _SMHomeScreenState extends State<SMHomeScreen> {
  int _tab = 0;
  String _issuanceStatus = 'none';
  String _returnStatus = 'none';
  double _cashCollected = 0;

  // ValueNotifiers to trigger reload in child screens
  final _reloadIssuance = ValueNotifier<int>(0);
  final _reloadReturn = ValueNotifier<int>(0);
  final _reloadSummary = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _reloadIssuance.dispose();
    _reloadReturn.dispose();
    _reloadSummary.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final issuance = await LocalDbService.getTodayIssuance(today);
    final ret = await LocalDbService.getTodayReturn(today);
    if (mounted) {
      setState(() {
        _issuanceStatus = issuance?.status ?? 'none';
        _returnStatus = ret?.status ?? 'none';
        _cashCollected = ret?.cashCollected ?? 0;
      });
    }
  }

  void _onTabSelected(int i) {
    setState(() => _tab = i);
    _loadStatus();
    switch (i) {
      case 1:
        _reloadIssuance.value++;
        break;
      case 2:
        _reloadReturn.value++;
        break;
      case 3:
        _reloadSummary.value++;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(
        index: _tab,
        children: [
          _HomeTab(
            today: today,
            userName: auth.userName ?? 'Salesman',
            issuanceStatus: _issuanceStatus,
            returnStatus: _returnStatus,
            cashCollected: _cashCollected,
            onRefresh: _loadStatus,
          ),
          SMIssuanceScreen(reloadNotifier: _reloadIssuance),
          SMReturnScreen(reloadNotifier: _reloadReturn),
          SMSummaryScreen(reloadNotifier: _reloadSummary),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _onTabSelected,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.accent.withAlpha(30),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.accent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon:
                Icon(Icons.inventory_2_rounded, color: AppTheme.accent),
            label: 'Issuance',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_return_outlined),
            selectedIcon:
                Icon(Icons.assignment_return_rounded, color: AppTheme.accent),
            label: 'Return',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded, color: AppTheme.accent),
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String today;
  final String userName;
  final String issuanceStatus;
  final String returnStatus;
  final double cashCollected;
  final VoidCallback onRefresh;

  const _HomeTab({
    required this.today,
    required this.userName,
    required this.issuanceStatus,
    required this.returnStatus,
    required this.cashCollected,
    required this.onRefresh,
  });

  Color _statusColor(String s) {
    switch (s) {
      case 'approved':
        return AppTheme.success;
      case 'pending_approval':
        return AppTheme.warning;
      case 'pending_sync':
        return AppTheme.accent;
      default:
        return AppTheme.textMuted;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'approved':
        return 'Approved';
      case 'pending_approval':
        return 'Pending Approval';
      case 'pending_sync':
        return 'Not Synced';
      case 'none':
        return 'Not Submitted';
      default:
        return s;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'pending_approval':
        return Icons.hourglass_top_rounded;
      case 'pending_sync':
        return Icons.upload_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncProvider>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning,',
                            style: GoogleFonts.inter(
                                color: AppTheme.textMuted, fontSize: 13)),
                        Text(userName,
                            style: GoogleFonts.manrope(
                                color: AppTheme.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(today,
                            style: GoogleFonts.inter(
                                color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  _Avatar(name: userName),
                ],
              ),
              const SizedBox(height: 24),

              // Status cards
              Text('Today\'s Status',
                  style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              _StatusCard(
                title: 'Stock Issuance',
                subtitle: 'Morning stock request',
                status: _statusLabel(issuanceStatus),
                statusColor: _statusColor(issuanceStatus),
                icon: Icons.inventory_2_rounded,
                statusIcon: _statusIcon(issuanceStatus),
              ),
              const SizedBox(height: 10),
              _StatusCard(
                title: 'Stock Return',
                subtitle: 'Evening return submission',
                status: _statusLabel(returnStatus),
                statusColor: _statusColor(returnStatus),
                icon: Icons.assignment_return_rounded,
                statusIcon: _statusIcon(returnStatus),
              ),
              if (cashCollected > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.success.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_rounded,
                          color: AppTheme.success, size: 22),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cash Collected Today',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: AppTheme.textSecondary)),
                          Text('Rs ${cashCollected.toStringAsFixed(0)}',
                              style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.success)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Sync
              Text('Sync',
                  style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              _SyncTile(
                label: 'Morning Sync',
                subtitle: 'Download products and stock levels',
                icon: Icons.wb_sunny_rounded,
                color: AppTheme.warning,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const SMSyncScreen(type: SMSyncType.morning)),
                ).then((_) => onRefresh()),
              ),
              const SizedBox(height: 10),
              _SyncTile(
                label: 'Upload Issuance',
                subtitle: 'Send issuance request to server',
                icon: Icons.upload_rounded,
                color: AppTheme.accent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const SMSyncScreen(type: SMSyncType.issuance)),
                ).then((_) => onRefresh()),
              ),
              const SizedBox(height: 10),
              _SyncTile(
                label: 'Check Approval Status',
                subtitle: 'Check if issuance or return was approved',
                icon: Icons.refresh_rounded,
                color: AppTheme.success,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const SMSyncScreen(type: SMSyncType.checkApproval)),
                ).then((_) => onRefresh()),
              ),
              const SizedBox(height: 10),
              _SyncTile(
                label: 'Upload Return',
                subtitle: 'Send evening return to server',
                icon: Icons.assignment_return_rounded,
                color: AppTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const SMSyncScreen(type: SMSyncType.returnUpload)),
                ).then((_) => onRefresh()),
              ),
              const SizedBox(height: 24),

              if (sync.lastSync != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 8),
                      Text('Last sync: ',
                          style: GoogleFonts.inter(
                              color: AppTheme.textMuted, fontSize: 12)),
                      Text(_formatSync(sync.lastSync!),
                          style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ConnectionScreen()),
                        (_) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded,
                      size: 16, color: AppTheme.textMuted),
                  label: Text('Logout',
                      style: GoogleFonts.inter(
                          color: AppTheme.textMuted, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSync(String iso) {
    try {
      return DateFormat('d MMM, h:mm a').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final IconData icon;
  final IconData statusIcon;

  const _StatusCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textPrimary)),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 16),
              const SizedBox(width: 4),
              Text(status,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SyncTile(
      {required this.label,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.textPrimary)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.success,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(initials,
            style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
      ),
    );
  }
}
