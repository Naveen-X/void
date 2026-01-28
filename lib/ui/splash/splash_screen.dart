import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _logs = [];
  final List<String> _rawLogs = [
    "INITIALIZING_VAULT...",
    "CHECKING_LOCAL_STORAGE... OK",
    "ENCRYPTING_SESSION... ACTIVE",
  ];

  String _brandText = "";
  final String _targetBrand = "void";
  bool _showCursor = true;
  bool _bootComplete = false;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startCursor();
    _runTerminalSequence();
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    super.dispose();
  }

  void _startCursor() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 450), (t) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  Future<void> _runTerminalSequence() async {
    // 1. Show Logs rapidly
    for (var log in _rawLogs) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) setState(() => _logs.add("> $log"));
    }

    await Future.delayed(const Duration(milliseconds: 600));

    // 2. Type Brand
    for (int i = 0; i <= _targetBrand.length; i++) {
      // 🔥 FIXED: Removed 'const' from Duration
      await Future.delayed(Duration(milliseconds: 1200 ~/ _targetBrand.length));
      if (mounted) {
        setState(() => _brandText = _targetBrand.substring(0, i));
      }
    }

    // 3. Finalize
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _bootComplete = true);

    // 4. Navigate
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TERMINAL LOGS (Dimmed)
            ..._logs.map((log) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                log,
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white.withValues(alpha: 0.15),
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            )),

            const SizedBox(height: 20),

            // THE BRAND LINE
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'void_brand',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      _brandText,
                      style: GoogleFonts.ibmPlexMono(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                ),
                // THE CURSOR
                if (!_bootComplete)
                  Opacity(
                    opacity: _showCursor ? 1.0 : 0.0,
                    child: Container(
                      width: 12,
                      height: 24,
                      margin: const EdgeInsets.only(left: 8),
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}