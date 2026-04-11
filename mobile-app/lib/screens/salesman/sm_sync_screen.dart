import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/sync_provider.dart';
import '../../services/local_db_service.dart';

enum SMSyncType { morning, issuance, checkApproval, returnUpload }

class SMSyncScreen extends StatefulWidget {
  final SMSyncType type;
  const SMSyncScreen({super.key, required this.type});

  @override
  State<SMSyncScreen> createState() => _SMSyncScreenState();
}

class _SMSyncScreenState extends State<SMSyncScreen> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SyncProvider>().reset();
    });
  }

  String get _title {
    switch (widget.type) {
      case SMSyncType.morning:
        return 'Morning Sync';
      case SMSyncType.issuance:
        return 'Upload Issuance';
      case SMSyncType.checkApproval:
        return 'Check Approval Status';
      case SMSyncType.returnUpload:
        return 'Upload Return';
    }
  }

  String get _description {
    switch (widget.type) {
      case SMSyncType.morning:
        return 'Downloads current stock levels and product information.';
      case SMSyncType.issuance:
        return 'Sends your morning issuance request to the server for admin approval.';
      case SMSyncType.checkApproval:
        return 'Checks if admin has approved your issuance or return request.';
      case SMSyncType.returnUpload:
        return 'Sends your evening return quantities to the server.';
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case SMSyncType.morning:
        return Icons.wb_sunny_rounded;
      case SMSyncType.issuance:
        return Icons.upload_rounded;
      case SMSyncType.checkApproval:
        return Icons.refresh_rounded;
      case SMSyncType.returnUpload:
        return Icons.assignment_return_rounded;
    }
  }

  Color get _color {
    switch (widget.type) {
      case SMSyncType.morning:
        return AppTheme.warning;
      case SMSyncType.issuance:
        return AppTheme.accent;
      case SMSyncType.checkApproval:
        return AppTheme.success;
      case SMSyncType.returnUpload:
        return AppTheme.primary;
    }
  }

  Future<void> _startSync() async {
    setState(() => _started = true);
    final sync = context.read<SyncProvider>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    switch (widget.type) {
      case SMSyncType.morning:
        await sync.morningSyncSalesman();
        break;
      case SMSyncType.issuance:
        final issuance = await LocalDbService.getTodayIssuance(today);
        if (issuance != null) {
          await sync.uploadIssuance(issuance);
        } else {
          sync.reset();
        }
        break;
      case SMSyncType.checkApproval:
        await sync.checkIssuanceStatus(today);
        break;
      case SMSyncType.returnUpload:
        final ret = await LocalDbService.getTodayReturn(today);
        if (ret != null) {
          await sync.uploadReturn(ret);
        } else {
          sync.reset();
        }
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
        builder: (_, sync, __) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
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
              if (_started)
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
                          else
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
                                      color: line.startsWith('✓')
                                          ? AppTheme.success
                                          : AppTheme.textSecondary)),
                            )),
                      ],
                    ],
                  ),
                ),
              const Spacer(),
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
                    icon:
                        const Icon(Icons.refresh_rounded, color: Colors.white),
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
                    icon:
                        const Icon(Icons.refresh_rounded, color: Colors.white),
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
                    icon: Icon(_icon, color: Colors.white),
                    label: Text(
                      sync.status == SyncStatus.syncing
                          ? 'Processing...'
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
        ),
      ),
    );
  }
}
