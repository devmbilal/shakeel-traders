import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import '../../services/local_db_service.dart';
import '../shared/connection_screen.dart';
import 'ob_routes_screen.dart';
import 'ob_recovery_screen.dart';
import 'ob_sync_screen.dart';
import 'ob_summary_screen.dart';

class OBHomeScreen extends StatefulWidget {
  const OBHomeScreen({super.key});
  @override
  State<OBHomeScreen> createState() => _OBHomeScreenState();
}

class _OBHomeScreenState extends State<OBHomeScreen> {
  int _tab = 0;
  int _routeCount = 0;
  int _orderCount = 0;
  int _recoveryCount = 0;
  int _pendingSyncCount = 0;

  final _reloadRoutes = ValueNotifier<int>(0);
  final _reloadRecovery = ValueNotifier<int>(0);
  final _reloadSummary = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  @override
  void dispose() {
    _reloadRoutes.dispose();
    _reloadRecovery.dispose();
    _reloadSummary.dispose();
    super.dispose();
  }

  Future<void> _loadCounts() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final routes = await LocalDbService.getRoutes();
    final orders = await LocalDbService.getTodayOrders(today);
    final recoveries = await LocalDbService.getTodayRecoveries();
    final pending = orders.where((o) => o.status == 'pending_sync').length;
    final pendingRec = recoveries.where((r) => r.status == 'collected').length;
    if (mounted) {
      setState(() {
        _routeCount = routes.length;
        _orderCount = orders.length;
        _recoveryCount = recoveries.length;
        _pendingSyncCount = pending + pendingRec;
      });
    }
  }

  void _onTabSelected(int i) {
    setState(() => _tab = i);
    _loadCounts();
    switch (i) {
      case 1:
        _reloadRoutes.value++;
        break;
      case 2:
        _reloadRecovery.value++;
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
            routeCount: _routeCount,
            orderCount: _orderCount,
            recoveryCount: _recoveryCount,
            pendingSyncCount: _pendingSyncCount,
            userName: auth.userName ?? 'Order Booker',
            onRefresh: _loadCounts,
          ),
          OBRoutesScreen(reloadNotifier: _reloadRoutes),
          OBRecoveryScreen(reloadNotifier: _reloadRecovery),
          OBSummaryScreen(reloadNotifier: _reloadSummary),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _onTabSelected,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.accent.withAlpha(30),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon:
                const Icon(Icons.home_rounded, color: AppTheme.accent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map_rounded, color: AppTheme.accent),
            label: 'Routes',
          ),
          NavigationDestination(
            icon: Stack(
              children: [
                const Icon(Icons.payments_outlined),
                if (_recoveryCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppTheme.danger, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            selectedIcon:
                const Icon(Icons.payments_rounded, color: AppTheme.accent),
            label: 'Recovery',
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon:
                const Icon(Icons.list_alt_rounded, color: AppTheme.accent),
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String today;
  final int routeCount;
  final int orderCount;
  final int recoveryCount;
  final int pendingSyncCount;
  final String userName;
  final VoidCallback onRefresh;

  const _HomeTab({
    required this.today,
    required this.routeCount,
    required this.orderCount,
    required this.recoveryCount,
    required this.pendingSyncCount,
    required this.userName,
    required this.onRefresh,
  });

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
                  _AvatarWidget(name: userName),
                ],
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                      label: 'Routes Today',
                      value: '$routeCount',
                      icon: Icons.map_rounded,
                      color: AppTheme.accent),
                  _StatCard(
                      label: 'Orders Booked',
                      value: '$orderCount',
                      icon: Icons.receipt_long_rounded,
                      color: AppTheme.success),
                  _StatCard(
                      label: 'Recovery Bills',
                      value: '$recoveryCount',
                      icon: Icons.payments_rounded,
                      color: AppTheme.warning),
                  _StatCard(
                    label: 'Pending Sync',
                    value: '$pendingSyncCount',
                    icon: Icons.sync_rounded,
                    color: pendingSyncCount > 0
                        ? AppTheme.danger
                        : AppTheme.textMuted,
                  ),
                ],
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
              Text('Sync',
                  style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              _SyncButton(
                label: 'Morning Sync',
                subtitle: 'Download routes, shops, products & recovery bills',
                icon: Icons.wb_sunny_rounded,
                color: AppTheme.warning,
                onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const OBSyncScreen(type: SyncType.morning)))
                    .then((_) => onRefresh()),
              ),
              const SizedBox(height: 10),
              _SyncButton(
                label: 'Recovery Bills Sync',
                subtitle: 'Download new recovery assignments',
                icon: Icons.wb_cloudy_rounded,
                color: AppTheme.accent,
                onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const OBSyncScreen(type: SyncType.midday)))
                    .then((_) => onRefresh()),
              ),
              const SizedBox(height: 10),
              _SyncButton(
                label: 'Upload Orders',
                subtitle: 'Upload only today\'s booked orders',
                icon: Icons.receipt_long_rounded,
                color: AppTheme.success,
                onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const OBSyncScreen(type: SyncType.ordersOnly)))
                    .then((_) => onRefresh()),
              ),
              const SizedBox(height: 10),
              _SyncButton(
                label: 'Upload Recoveries',
                subtitle: 'Upload only today\'s recovery collections',
                icon: Icons.payments_rounded,
                color: AppTheme.warning,
                onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OBSyncScreen(
                                type: SyncType.recoveriesOnly)))
                    .then((_) => onRefresh()),
              ),
              const SizedBox(height: 10),
              _SyncButton(
                label: 'Evening Sync',
                subtitle: 'Upload all orders and recoveries together',
                icon: Icons.nights_stay_rounded,
                color: AppTheme.primary,
                onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const OBSyncScreen(type: SyncType.evening)))
                    .then((_) => onRefresh()),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ConnectionScreen()),
                          (_) => false);
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SyncButton(
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
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
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
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  final String name;
  const _AvatarWidget({required this.name});

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
          color: AppTheme.accent, borderRadius: BorderRadius.circular(12)),
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
