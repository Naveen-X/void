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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _showBrand = false;
  bool _showLine = false;
  bool _needsRetry = false;
  double _lineProgress = 0.0;
  String _statusText = "INITIALIZING";
  
  late AnimationController _breatheController;
  
  @override
  void initState() {
    super.initState();
    
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    
    _runSequence();
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  Future<void> _runSequence() async {
    if (!mounted) return;
    setState(() { 
      _needsRetry = false;
      _showBrand = false;
      _showLine = false;
      _lineProgress = 0.0;
      _statusText = "INITIALIZING";
    });

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _showBrand = true);
    
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _showLine = true);
    
    // Animate progress line
    try {
      await VoidStore.init();
      for (int i = 0; i <= 100; i += 5) {
        if (!mounted) return;
        setState(() => _lineProgress = i / 100);
        await Future.delayed(const Duration(milliseconds: 20));
      }
      setState(() => _statusText = "VAULT ONLINE");
    } catch (e) {
      setState(() {
        _statusText = "INIT FAILED";
        _needsRetry = true;
      });
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Security check
    final bool isLocked = await SecurityService.isLockEnabled();
    if (isLocked) {
      setState(() => _statusText = "AUTHENTICATE");
      final bool authenticated = await SecurityService.authenticate();
      if (!authenticated) {
        if (mounted) {
          setState(() {
            _statusText = "AUTH FAILED";
            _needsRetry = true;
          });
        }
        return;
      }
      setState(() => _statusText = "ACCESS GRANTED");
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, anim, secondaryAnim, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated breathing dot
            AnimatedBuilder(
              animation: _breatheController,
              builder: (context, child) {
                final breathe = Curves.easeInOut.transform(_breatheController.value);
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _showBrand ? 1.0 : 0.0,
                  child: Container(
                    width: 8 + (4 * breathe),
                    height: 8 + (4 * breathe),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.6 + (0.4 * breathe)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2 * breathe),
                          blurRadius: 20 * breathe,
                          spreadRadius: 5 * breathe,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // Brand text with cursor
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: _showBrand ? 1.0 : 0.0,
              child: Hero(
                tag: 'void_brand',
                child: Material(
                  type: MaterialType.transparency,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "void",
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Progress line
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _showLine ? 1.0 : 0.0,
              child: Column(
                children: [
                  // Progress bar
                  Container(
                    width: 200,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.1),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 200 * _lineProgress,
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status text
                  Text(
                    _statusText,
                    style: GoogleFonts.ibmPlexMono(
                      color: Colors.white24,
                      fontSize: 10,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Retry button
            if (_needsRetry)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: GestureDetector(
                  onTap: _runSequence,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      "RETRY",
                      style: GoogleFonts.ibmPlexMono(
                        color: Colors.white38,
                        fontSize: 11,
                        letterSpacing: 3,
                      ),
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