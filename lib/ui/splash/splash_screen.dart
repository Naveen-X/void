import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/security_service.dart';
import '../../data/stores/void_store.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _logs = [];
  final List<String> _rawLogs = [
    "CHECKING_LOCAL_STORAGE... OK",
    "ENCRYPTING_SESSION... ACTIVE",
    "LOADING_UI_RESOURCES... OK",
  ];

  String _brandText = "";
  final String _targetBrand = "void";
  bool _showCursor = true;
  bool _bootComplete = false;
  bool _needsRetry = false;
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

  // Pixel-perfect blinking cursor logic
  void _startCursor() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 450), (t) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  Future<void> _runTerminalSequence() async {
    if (!mounted) return;
    setState(() { 
      _needsRetry = false; 
      _logs.clear(); 
      _brandText = "";
      _bootComplete = false;
    });

    // --- PHASE 0: ASYNC DB INITIALIZATION ---
    _addLog("INITIALIZING_VAULT...");
    await Future.delayed(const Duration(milliseconds: 400));
    
    try {
      // This is the heavy lifting. UI thread stays smooth because 
      // main() already returned the VoidApp widget.
      await VoidStore.init(); 
      _addLog("DATABASE_READY: FTS5_DRIVER_LOADED");
    } catch (e) {
      _addLog("CRITICAL_ERROR: DB_INIT_FAILED");
      _addLog("$e");
      setState(() => _needsRetry = true);
      return;
    }

    // --- PHASE 1: SEQUENTIAL TERMINAL LOGS ---
    for (var log in _rawLogs) {
      await Future.delayed(const Duration(milliseconds: 300));
      _addLog(log);
    }

    // --- PHASE 2: TYPING ANIMATION ---
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i <= _targetBrand.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) setState(() => _brandText = _targetBrand.substring(0, i));
    }

    if (mounted) setState(() => _bootComplete = true);

    // --- PHASE 3: SECURITY CHALLENGE ---
    final bool isLocked = await SecurityService.isLockEnabled();
    if (isLocked) {
      _addLog("CHALLENGE: BIOMETRIC_REQUIRED");
      final bool authenticated = await SecurityService.authenticate();
      
      if (!authenticated) {
        _addLog("ERROR: HANDSHAKE_REJECTED");
        if (mounted) setState(() => _needsRetry = true);
        return;
      }
      _addLog("HANDSHAKE_SUCCESS");
    }

    // --- PHASE 4: CUSTOM PAGE TRANSITION ---
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim, 
            child: child
          ),
        ),
      );
    }
  }

  void _addLog(String msg) {
    if (mounted) setState(() => _logs.add("> $msg"));
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
            // Terminal Logs
            SizedBox(
              height: 120, // Constrain height to prevent overflow
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _logs.length,
                itemBuilder: (context, index) => Text(
                  _logs[index],
                  style: GoogleFonts.ibmPlexMono(
                    color: Colors.white.withOpacity(0.15),
                    fontSize: 10,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Brand Text + Blinking Cursor
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
                      ),
                    ),
                  ),
                ),
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

            // Retry UI
            if (_needsRetry)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: GestureDetector(
                  onTap: _runTerminalSequence,
                  child: Text(
                    "RETRY_HANDSHAKE",
                    style: GoogleFonts.ibmPlexMono(
                      color: Colors.white54,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}