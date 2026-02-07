import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/void_theme.dart';

class VoidEmptyState extends StatefulWidget {
  const VoidEmptyState({super.key});

  @override
  State<VoidEmptyState> createState() => _VoidEmptyStateState();
}

class _VoidEmptyStateState extends State<VoidEmptyState> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.bgPrimary,
      ),
      child: Stack(
        children: [
          // 1. GHOST MASONRY BACKGROUND (Subtle)
          Positioned.fill(
            child: Opacity(
              opacity: 0.02,
              child: CustomPaint(
                painter: _GhostMasonryPainter(color: theme.textPrimary),
              ),
            ),
          ),
          
          // 2. MAIN CONTENT
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ANIMATED RING ORB (Target)
                SizedBox(
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
                              painter: _RingPainter(color: theme.textPrimary),
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
                              color: theme.textPrimary.withValues(alpha: 0.05),
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
                
                const SizedBox(height: 48),
                
                // MAIN TEXT
                Text(
                  "THE VOID IS SILENT",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 13,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w400,
                    color: theme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // SUBTEXT
                Text(
                  "Add a fragment to disturb the peace.",
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    color: theme.textSecondary,
                    letterSpacing: 0.5,
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

// Rotating ring painter (Ported from Splash Screen)
class _RingPainter extends CustomPainter {
  final Color color;
  
  _RingPainter({required this.color});

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
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GhostMasonryPainter extends CustomPainter {
  final Color color;
  
  _GhostMasonryPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Simulate some masonry card outlines
    final random = math.Random(42);
    double currentY = 20;
    while (currentY < size.height) {
      double h1 = 100 + random.nextDouble() * 200;
      double h2 = 100 + random.nextDouble() * 200;
      
      // Card 1
      canvas.drawRRect(
        RRect.fromLTRBR(20, currentY, size.width / 2 - 10, currentY + h1, const Radius.circular(12)),
        paint,
      );
      // Card 2
      canvas.drawRRect(
        RRect.fromLTRBR(size.width / 2 + 10, currentY, size.width - 20, currentY + h2, const Radius.circular(12)),
        paint,
      );
      
      currentY += math.max(h1, h2) + 20;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}