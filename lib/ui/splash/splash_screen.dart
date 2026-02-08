import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/security_service.dart';
import '../../data/stores/void_store.dart';
import '../home/home_screen.dart';
import '../theme/void_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _showLogo = false;
  bool _showProgress = false;
  bool _needsRetry = false;
  double _lineProgress = 0.0;
  String _statusText = "INITIALIZING";
  
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _glowController;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    
    _runSequence();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _runSequence() async {
    if (!mounted) return;
    setState(() { 
      _needsRetry = false;
      _showLogo = false;
      _showProgress = false;
      _lineProgress = 0.0;
      _statusText = "INITIALIZING";
    });

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _showLogo = true);
    
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _showProgress = true);
    
    // Initialize and animate progress
    try {
      // Initialize database
      await VoidStore.init();
      
      for (int i = 0; i <= 90; i += 10) {
        if (!mounted) return;
        setState(() => _lineProgress = i / 100);
        await Future.delayed(const Duration(milliseconds: 20));
      }
      
      setState(() => _statusText = "VAULT ONLINE");
      
      // Give it a tiny bit of time for progress bar aesthetic, then move on
      await Future.delayed(const Duration(milliseconds: 500));

      for (int i = 90; i <= 100; i += 2) {
        if (!mounted) return;
        setState(() => _lineProgress = i / 100);
        await Future.delayed(const Duration(milliseconds: 10));
      }
    } catch (e) {
      setState(() {
        _statusText = "INIT FAILED";
        _needsRetry = true;
      });
      return;
    }

    await Future.delayed(const Duration(milliseconds: 400));

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

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
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
    final theme = VoidTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.bgPrimary,
      body: Stack(
        children: [
          // Subtle rotating grid background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GridPainter(
                    rotation: _rotateController.value * 2 * math.pi * 0.02,
                    opacity: isDark ? 0.03 : 0.05,
                    color: theme.textPrimary,
                  ),
                );
              },
            ),
          ),
          
          // Center glow
          Center(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final glow = Curves.easeInOut.transform(_glowController.value);
                return Container(
                  width: 300 + (50 * glow),
                  height: 300 + (50 * glow),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.textPrimary.withValues(alpha: (isDark ? 0.03 : 0.05) + (0.02 * glow)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated ring with logo
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: _showLogo ? 1.0 : 0.0,
                  child: AnimatedScale(
                    scale: _showLogo ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer rotating ring
                          AnimatedBuilder(
                            animation: _rotateController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotateController.value * 2 * math.pi,
                                child: CustomPaint(
                                  size: const Size(120, 120),
                                  painter: _RingPainter(
                                    progress: _lineProgress,
                                    color: theme.textPrimary,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Inner pulsing circle
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final pulse = Curves.easeInOut.transform(_pulseController.value);
                              return Container(
                                width: 60 + (8 * pulse),
                                height: 60 + (8 * pulse),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.bgCard,
                                  border: Border.all(
                                    color: theme.textPrimary.withValues(alpha: 0.1 + (0.1 * pulse)),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.textPrimary.withValues(alpha: 0.8 + (0.2 * pulse)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.textPrimary.withValues(alpha: 0.3 * pulse),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Brand text
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: _showLogo ? 1.0 : 0.0,
                  child: AnimatedSlide(
                    offset: _showLogo ? Offset.zero : const Offset(0, 0.2),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    child: Hero(
                      tag: 'void_brand',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          "VOID",
                          style: GoogleFonts.ibmPlexMono(
                            color: theme.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Tagline
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: _showLogo ? 1.0 : 0.0,
                  child: Text(
                    "SPACE",
                    style: GoogleFonts.ibmPlexMono(
                      color: theme.textSecondary.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 8,
                    ),
                  ),
                ),
                
                const SizedBox(height: 80),
                
                // Progress section
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _showProgress ? 1.0 : 0.0,
                  child: Column(
                    children: [
                      // Progress bar
                      Container(
                        width: 160,
                        height: 2,
                        decoration: BoxDecoration(
                          color: theme.textPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(1),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 80),
                            width: 160 * _lineProgress,
                            height: 2,
                            decoration: BoxDecoration(
                              color: theme.textPrimary.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(1),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.textPrimary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Status text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _statusText,
                          key: ValueKey(_statusText),
                          style: GoogleFonts.ibmPlexMono(
                            color: _statusText.contains("FAILED") 
                                ? Colors.redAccent.withValues(alpha: 0.7)
                                : theme.textPrimary.withValues(alpha: 0.3),
                            fontSize: 9,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Retry button
                if (_needsRetry)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: GestureDetector(
                      onTap: _runSequence,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.textPrimary.withValues(alpha: 0.15)),
                          color: theme.textPrimary.withValues(alpha: 0.03),
                        ),
                        child: Text(
                          "RETRY",
                          style: GoogleFonts.ibmPlexMono(
                            color: theme.textSecondary,
                            fontSize: 11,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Rotating ring painter
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  _RingPainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    
    // Background ring
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, bgPaint);
    
    // Accent dots
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
    
    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => 
      oldDelegate.progress != progress;
}

// Subtle grid background painter
class _GridPainter extends CustomPainter {
  final double rotation;
  final double opacity;
  final Color color;
  
  _GridPainter({required this.rotation, required this.opacity, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);
    
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.5;
    
    const spacing = 60.0;
    for (double i = -spacing; i < size.width + spacing; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = -spacing; i < size.height + spacing; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => 
      oldDelegate.rotation != rotation || oldDelegate.opacity != opacity;
}