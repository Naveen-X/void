// lib/ui/painters/custom_painters.dart
// Shared custom painters for visual effects

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Data structure for animated data stream lines
class DataLine {
  double startX = math.Random().nextDouble();
  double startY = math.Random().nextDouble();
  double length = 30 + (math.Random().nextDouble() * 100);
  double speed = 0.5 + (math.Random().nextDouble() * 1.5);
}

/// Paints animated data stream lines in the background
class DataStreamPainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<DataLine> _lines = List.generate(25, (index) => DataLine());

  DataStreamPainter(this.progress, {this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.02);

    for (var line in _lines) {
      double currentY =
          (line.startY * size.height) + (progress * size.height * line.speed);
      if (currentY > size.height) {
        currentY -= size.height;
      }

      canvas.drawLine(
        Offset(line.startX * size.width, currentY),
        Offset(line.startX * size.width + line.length, currentY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DataStreamPainter oldDelegate) => true;
}

/// Paints tech-style rotating ring effect
class TechRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  TechRingPainter(this.progress, {this.color = Colors.cyanAccent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Outer Ring
    final rect = Rect.fromCenter(
        center: center, width: size.width * 0.8, height: size.height * 0.8);
    canvas.drawArc(rect, progress * 6.28, 1.5, false, paint);
    canvas.drawArc(rect, progress * 6.28 + 3.14, 1.5, false, paint);

    // Inner Dots
    final paintDots = Paint()..color = color.withValues(alpha: 0.2);
    for (int i = 0; i < 8; i++) {
      final angle = (i * 3.14 / 4) + (progress * 2);
      final dx = center.dx + (size.width * 0.25) * math.cos(angle);
      final dy = center.dy + (size.height * 0.25) * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 2, paintDots);
    }
  }

  @override
  bool shouldRepaint(covariant TechRingPainter oldDelegate) => true;
}

/// Paints a bento grid-style background pattern
class BentoBackgroundPainter extends CustomPainter {
  final Color color;
  BentoBackgroundPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke;

    const gridSize = 30.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints subtle animated circuit-like lines for cards
class CardDataPainter extends CustomPainter {
  final double progress;
  final Color color;

  CardDataPainter(this.progress, {this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final accentPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    // Top-left bracket
    path.moveTo(10, 0);
    path.lineTo(0, 0);
    path.lineTo(0, 10);
    
    // Top-right bracket
    path.moveTo(size.width - 10, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, 10);
    
    // Bottom-left bracket
    path.moveTo(0, size.height - 10);
    path.lineTo(0, size.height);
    path.lineTo(10, size.height);
    
    // Bottom-right bracket
    path.moveTo(size.width - 10, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height - 10);

    canvas.drawPath(path, accentPaint);

    // Subtle internal grid lines
    final gridPath = Path();
    gridPath.moveTo(size.width * 0.2, 0);
    gridPath.lineTo(size.width * 0.2, size.height);
    gridPath.moveTo(size.width * 0.8, 0);
    gridPath.lineTo(size.width * 0.8, size.height);
    
    canvas.drawPath(gridPath, paint..color = color.withValues(alpha: 0.02));

    // Animated diagonal scanning line
    final scanY = (progress * size.height * 2) - size.height;
    if (scanY > 0 && scanY < size.height) {
      canvas.drawLine(
        Offset(0, scanY),
        Offset(size.width, scanY),
        Paint()..color = color.withValues(alpha: 0.03 * (1.0 - (scanY / size.height).abs())),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CardDataPainter oldDelegate) => true;
}
