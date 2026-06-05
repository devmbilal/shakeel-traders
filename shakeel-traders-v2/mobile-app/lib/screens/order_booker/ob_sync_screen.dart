import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/sync_provider.dart';

enum SyncType { morning, midday, evening, ordersOnly, recoveriesOnly }

class OBSyncScreen extends StatefulWidget {
  final SyncType type;
  const OBSyncScreen({super.key, required this.type});

  @override
  State<OBSyncScreen> createState() => _OBSyncScreenState();
}

class _OBSyncScreenState extends State<OBSyncScreen> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // Reset any previous sync state when opening this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SyncProvider>().reset();
    });
  }

  String get _title {
    switch (widget.type) {
      case SyncType.morning:
        return 'Morning Sync';
      case SyncType.midday:
        return 'Recovery Bills Sync';
      case SyncType.evening:
        return 'Evening Sync';
      case SyncType.ordersOnly:
        return 'Upload Orders';
      case SyncType.recoveriesOnly:
        return 'Upload Recoveries';
    }
  }

  String get _description {
    switch (widget.type) {
      case SyncType.morning:
        return 'Downloads routes, shops, products, prices, and recovery assignments.';
      case SyncType.midday:
        return 'Downloads new recovery bill assignments made by admin.';
      case SyncType.evening:
        return 'Uploads all orders and all recovery entries together.';
      case SyncType.ordersOnly:
        return 'Uploads only the orders booked today. Recovery entries are not affected.';
      case SyncType.recoveriesOnly:
        return 'Uploads only the recovery collections recorded today. Orders are not affected.';
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case SyncType.morning:
        return Icons.wb_sunny_rounded;
      case SyncType.midday:
        return Icons.wb_cloudy_rounded;
      case SyncType.evening:
        return Icons.nights_stay_rounded;
      case SyncType.ordersOnly:
        return Icons.receipt_long_rounded;
      case SyncType.recoveriesOnly:
        return Icons.payments_rounded;
    }
  }

  Color get _color {
    switch (widget.type) {
      case SyncType.morning:
        return AppTheme.warning;
      case SyncType.midday:
        return AppTheme.accent;
      case SyncType.evening:
        return AppTheme.primary;
      case SyncType.ordersOnly:
        return AppTheme.success;
      case SyncType.recoveriesOnly:
        return AppTheme.warning;
    }
  }

  Future<void> _startSync() async {
    setState(() => _started = true);
    final sync = context.read<SyncProvider>();
    switch (widget.type) {
      case SyncType.morning:
        await sync.morningSyncOrderBooker();
        break;
      case SyncType.midday:
        await sync.middaySyncOrderBooker();
        break;
      case SyncType.evening:
        await sync.eveningSyncOrderBooker();
        break;
      case SyncType.ordersOnly:
        await sync.uploadOrdersOnly();
        break;
      case SyncType.recoveriesOnly:
        await sync.uploadRecoveriesOnly();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SyncProvider>(
        builder: (_, sync, __) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Icon + description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _color.withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(_icon, color: _color, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(_title,
                          style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Text(_description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Status / Log
                if (_started) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (sync.status == SyncStatus.syncing)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppTheme.accent),
                              )
                            else if (sync.status == SyncStatus.success)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppTheme.success, size: 18)
                            else if (sync.status == SyncStatus.error)
                              const Icon(Icons.error_rounded,
                                  color: AppTheme.danger, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(sync.statusMessage,
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: sync.status == SyncStatus.error
                                          ? AppTheme.danger
                                          : AppTheme.textPrimary)),
                            ),
                          ],
                        ),
                        if (sync.log.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          ...sync.log.map((line) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(line,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: line.startsWith('⚠')
                                            ? AppTheme.warning
                                            : line.startsWith('✓')
                                                ? AppTheme.success
                                                : AppTheme.textSecondary)),
                              )),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Spacer(),

                // Action button(s)
                if (sync.status == SyncStatus.error) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        sync.reset();
                        setState(() => _started = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.refresh_rounded,
                          color: Colors.white),
                      label: Text('Try Again',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppTheme.textSecondary),
                      label: Text('Go Back',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppTheme.textSecondary)),
                    ),
                  ),
                ] else if (sync.status == SyncStatus.success) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        sync.reset();
                        setState(() => _started = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.refresh_rounded,
                          color: Colors.white),
                      label: Text('Sync Again',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.success),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_rounded,
                          color: AppTheme.success),
                      label: Text('Done',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppTheme.success)),
                    ),
                  ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          sync.status == SyncStatus.syncing ? null : _startSync,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.sync_rounded, color: Colors.white),
                      label: Text(
                        sync.status == SyncStatus.syncing
                            ? 'Syncing...'
                            : 'Start $_title',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
