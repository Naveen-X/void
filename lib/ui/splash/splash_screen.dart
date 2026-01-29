import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/security_service.dart'; // 🔥 ADD THIS
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
  bool _needsRetry = false; // 🔥 For failed auth
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
    setState(() { _needsRetry = false; });

    // 1. Logs
    for (var log in _rawLogs) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) setState(() => _logs.add("> $log"));
    }

    // 2. Type Brand
    for (int i = 0; i <= _targetBrand.length; i++) {
      await Future.delayed(Duration(milliseconds: 1000 ~/ _targetBrand.length));
      if (mounted) setState(() => _brandText = _targetBrand.substring(0, i));
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _bootComplete = true);

    // 3. 🔥 SECURITY HANDSHAKE
    final bool isLocked = await SecurityService.isLockEnabled();
    if (isLocked) {
      if (mounted) setState(() => _logs.add("> CHALLENGE: BIOMETRIC_REQUIRED"));
      
      final bool authenticated = await SecurityService.authenticate();
      
      if (!authenticated) {
        if (mounted) {
          setState(() {
            _logs.add("> ERROR: HANDSHAKE_REJECTED");
            _needsRetry = true;
          });
        }
        return; // Stop here
      }
      if (mounted) setState(() => _logs.add("> HANDSHAKE_SUCCESS"));
    }

    // 4. Navigate
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, _, _) => const HomeScreen(),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
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
            ..._logs.map((log) => Text(
              log,
              style: GoogleFonts.ibmPlexMono(color: Colors.white.withValues(alpha: 0.15), fontSize: 10),
            )),

            const SizedBox(height: 20),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'void_brand',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      _brandText,
                      style: GoogleFonts.ibmPlexMono(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                if (!_bootComplete)
                  Opacity(
                    opacity: _showCursor ? 1.0 : 0.0,
                    child: Container(width: 12, height: 24, margin: const EdgeInsets.only(left: 8), color: Colors.white70),
                  ),
              ],
            ),

            // 🔥 RETRY BUTTON
            if (_needsRetry)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: TextButton(
                  onPressed: _runTerminalSequence,
                  child: Text("RETRY_HANDSHAKE", style: GoogleFonts.ibmPlexMono(color: Colors.white54, fontSize: 12, decoration: TextDecoration.underline)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}