import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import 'login_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _ipCtrl = TextEditingController();
  final _portCtrl = TextEditingController(text: '3000');
  bool _testing = false;
  bool _connected = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(AppConstants.keyServerIp);
    final port = prefs.getInt(AppConstants.keyServerPort);
    if (ip != null) _ipCtrl.text = ip;
    if (port != null) _portCtrl.text = port.toString();
  }

  Future<void> _testConnection() async {
    final ip = _ipCtrl.text.trim();
    final port = int.tryParse(_portCtrl.text.trim()) ?? 3000;
    if (ip.isEmpty) {
      setState(() => _error = 'Please enter server IP address');
      return;
    }
    setState(() { _testing = true; _error = null; _connected = false; });
    final ok = await ApiService.testConnection(ip, port);
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyServerIp, ip);
      await prefs.setInt(AppConstants.keyServerPort, port);
      ApiService.clearCache();
    }
    setState(() {
      _testing = false;
      _connected = ok;
      _error = ok ? null : 'Cannot connect to server. Check IP and port.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo / Brand
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_shipping_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 20),
              Text('Shakeel Traders',
                  style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800)),
              Text('Distribution Order System',
                  style: GoogleFonts.inter(
                      color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 48),
              // Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connect to Server',
                        style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Enter the IP address of the office computer',
                        style: GoogleFonts.inter(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 20),
                    _field(
                      controller: _ipCtrl,
                      label: 'Server IP Address',
                      hint: 'e.g. 192.168.1.100',
                      icon: Icons.computer_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      controller: _portCtrl,
                      label: 'Port',
                      hint: '3000',
                      icon: Icons.settings_ethernet_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.danger.withOpacity(0.4)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.danger, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: GoogleFonts.inter(
                                    color: AppTheme.danger, fontSize: 12)),
                          ),
                        ]),
                      ),
                    ],
                    if (_connected) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.success.withOpacity(0.4)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.check_circle_outline,
                              color: AppTheme.success, size: 16),
                          const SizedBox(width: 8),
                          Text('Connected successfully!',
                              style: GoogleFonts.inter(
                                  color: AppTheme.success, fontSize: 12)),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _testing ? null : _testConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _testing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text('Test Connection',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.white)),
                      ),
                    ),
                    if (_connected) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Continue to Login',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.primary)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        labelStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
        hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.accent, width: 2),
        ),
      ),
    );
  }
}
