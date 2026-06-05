import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_theme.dart';
import 'config/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/sync_provider.dart';
import 'screens/shared/connection_screen.dart';
import 'screens/shared/login_screen.dart';
import 'screens/order_booker/ob_home_screen.dart';
import 'screens/salesman/sm_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ShakeelTradersApp());
}

class ShakeelTradersApp extends StatelessWidget {
  const ShakeelTradersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const _Splash(),
      ),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash();
  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    await auth.loadFromStorage();
    await context.read<SyncProvider>().loadLastSync();

    if (!mounted) return;

    if (auth.isLoggedIn) {
      if (auth.isOrderBooker) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const OBHomeScreen()));
      } else if (auth.isSalesman) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const SMHomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } else {
      // Check if server is configured
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString(AppConstants.keyServerIp);
      if (!mounted) return;
      if (ip != null && ip.isNotEmpty) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const ConnectionScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.local_shipping_rounded,
                  color: Colors.white, size: 38),
            ),
            const SizedBox(height: 20),
            const Text('Shakeel Traders',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
                color: AppTheme.accent, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
