import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/void_design.dart';

class VoidEmptyState extends StatefulWidget {
  const VoidEmptyState({super.key});

  @override
  State<VoidEmptyState> createState() => _VoidEmptyStateState();
}

class _VoidEmptyStateState extends State<VoidEmptyState> with TickerProviderStateMixin {
  late AnimationController _scannerController;
  late AnimationController _ringsController;
  
  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    _ringsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _ringsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VoidDesign.bgPrimary,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            const Color(0xFF1A1A1A).withValues(alpha: 0.3),
            VoidDesign.bgPrimary,
          ],
        ),
      ),
      child: Stack(
        children: [
          // 1. GHOST MASONRY BACKGROUND
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: _GhostMasonryPainter(),
              ),
            ),
          ),
          
          // 2. MAIN CONTENT
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // THE SCANNING CORE
                AnimatedBuilder(
                  animation: Listenable.merge([_scannerController, _ringsController]),
                  builder: (context, _) {
                    return SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Concentric Pulse Rings
                          ...List.generate(3, (i) {
                            final double progress = (_scannerController.value + (i * 0.33)) % 1.0;
                            return Container(
                              width: 60 + (progress * 140),
                              height: 60 + (progress * 140),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: (1.0 - progress) * 0.1),
                                  width: 1,
                                ),
                              ),
                            );
                          }),
                          
                          // Rotating HUD Ring
                          Transform.rotate(
                            angle: _ringsController.value * 2 * math.pi,
                            child: CustomPaint(
                              size: const Size(120, 120),
                              painter: _HudRingPainter(),
                            ),
                          ),
                          
                          // Central Icon Glass
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: VoidDesign.bgCard.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: VoidDesign.borderMedium),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.all_inclusive_rounded,
                              color: VoidDesign.textPrimary,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // SCANNER STATUS
                Text(
                  "NO FRAGMENTS DETECTED",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 14,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w400,
                    color: VoidDesign.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  "VOID_SCAN_ACTIVE",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.withValues(alpha: 0.5),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // TECHNICAL READOUT BOX
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReadoutLine("SIGNAL", "STRETCHED"),
                      const SizedBox(height: 8),
                      _buildReadoutLine("INTENSITY", "0.00%"),
                      const SizedBox(height: 8),
                      _buildReadoutLine("ORIGIN", "LOCAL_VAULT"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadoutLine(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 9,
              color: VoidDesign.textTertiary.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 9,
            color: VoidDesign.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GhostMasonryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
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

class _HudRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const double gap = 0.4;
    for (int i = 0; i < 4; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
        (i * math.pi / 2) + gap,
        (math.pi / 2) - (gap * 2),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}