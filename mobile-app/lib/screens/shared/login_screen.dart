import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../order_booker/ob_home_screen.dart';
import '../salesman/sm_home_screen.dart';
import 'connection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_userCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      if (auth.isOrderBooker) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const OBHomeScreen()));
      } else if (auth.isSalesman) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const SMHomeScreen()));
      }
    }
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
              Text('Welcome back',
                  style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800)),
              Text('Sign in to your account',
                  style: GoogleFonts.inter(
                      color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Consumer<AuthProvider>(
                  builder: (_, auth, __) => Column(
                    children: [
                      _field(
                        controller: _userCtrl,
                        label: 'Username',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller: _passCtrl,
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscure,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white38,
                            size: 18,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      if (auth.error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.danger.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppTheme.danger.withOpacity(0.4)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline,
                                color: AppTheme.danger, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(auth.error!,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.danger, fontSize: 12)),
                            ),
                          ]),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('Sign In',
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
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ConnectionScreen()),
                  ),
                  child: Text('Change Server',
                      style: GoogleFonts.inter(
                          color: Colors.white38, fontSize: 12)),
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
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        suffixIcon: suffix,
        labelStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
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
