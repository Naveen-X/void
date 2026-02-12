import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONCENTRIC RINGS — Welcome page visual
// ─────────────────────────────────────────────────────────────────────────────

class ConcentricRingsPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final Color color;

  ConcentricRingsPainter({
    required this.progress,
    required this.pulse,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.44;

    // Deep inner glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.12 + 0.08 * pulse),
          color.withValues(alpha: 0.03),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.55));
    canvas.drawCircle(center, maxRadius * 0.55, glowPaint);

    // 6 concentric rings with alternating rotation
    for (int i = 0; i < 6; i++) {
      final fraction = (i + 1) / 6;
      final radius = maxRadius * fraction;
      final opacity = (0.06 + 0.08 * (1 - fraction)) + 0.03 * pulse;
      final strokeWidth = 1.2 - fraction * 0.4;

      final ringPaint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final rotation = progress * 2 * math.pi * (i.isEven ? 1 : -1) * (0.2 + i * 0.05);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.translate(-center.dx, -center.dy);

      // Draw segmented arcs with varying gap sizes
      final segments = 6 + i * 3;
      final gap = math.pi * (0.06 + i * 0.01);
      final arcLength = (2 * math.pi / segments) - gap;
      for (int s = 0; s < segments; s++) {
        final startAngle = s * (2 * math.pi / segments);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          arcLength,
          false,
          ringPaint,
        );
      }

      canvas.restore();
    }

    // Inner pulsing ring
    final innerRingPaint = Paint()
      ..color = color.withValues(alpha: 0.08 + 0.06 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, maxRadius * 0.12 + 4 * pulse, innerRingPaint);

    // Center dot with layered glow
    final dotRadius = 5.0 + 2.5 * pulse;

    // Outer halo
    final haloPaint = Paint()
      ..color = color.withValues(alpha: 0.06 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, dotRadius + 16, haloPaint);

    // Mid glow
    final dotGlow = Paint()
      ..color = color.withValues(alpha: 0.15 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, dotRadius + 6, dotGlow);

    // Core dot
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.85 + 0.15 * pulse)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, dotRadius, dotPaint);

    // Orbiting accent dots at varying distances
    for (int i = 0; i < 4; i++) {
      final orbitRadius = maxRadius * (0.7 + i * 0.1);
      final speed = 1.0 - i * 0.15;
      final angle = progress * 2 * math.pi * speed + (i * math.pi * 0.5);
      final x = center.dx + orbitRadius * math.cos(angle);
      final y = center.dy + orbitRadius * math.sin(angle);
      final orbitDotSize = 2.5 - i * 0.3;

      final orbitPaint = Paint()
        ..color = color.withValues(alpha: 0.4 + 0.25 * pulse - i * 0.05)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), orbitDotSize, orbitPaint);

      // Tiny trail behind each dot
      final trailAngle = angle - 0.15;
      final trailX = center.dx + orbitRadius * math.cos(trailAngle);
      final trailY = center.dy + orbitRadius * math.sin(trailAngle);
      final trailPaint = Paint()
        ..color = color.withValues(alpha: 0.15 * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(trailX, trailY), orbitDotSize * 0.6, trailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConcentricRingsPainter old) =>
      old.progress != progress || old.pulse != pulse;
}

// ─────────────────────────────────────────────────────────────────────────────
// ORBIT GRID — Organize page visual
// ─────────────────────────────────────────────────────────────────────────────

class OrbitGridPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final Color color;

  OrbitGridPainter({
    required this.progress,
    required this.pulse,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // 3 sparse orbital layers — fewer dots, calmer motion
    final layers = [
      _OrbitLayer(count: 3, radius: radius * 0.40, speed: 0.5, dotSize: 3.0),
      _OrbitLayer(count: 5, radius: radius * 0.70, speed: -0.3, dotSize: 2.5),
      _OrbitLayer(count: 8, radius: radius, speed: 0.18, dotSize: 2.0),
    ];

    // Faint orbital paths
    for (final layer in layers) {
      final pathPaint = Paint()
        ..color = color.withValues(alpha: 0.025 + 0.01 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawCircle(center, layer.radius, pathPaint);
    }

    // Draw orbiting dots (no connecting lines)
    for (final layer in layers) {
      for (int i = 0; i < layer.count; i++) {
        final angle = (i * 2 * math.pi / layer.count) +
            progress * 2 * math.pi * layer.speed;
        final x = center.dx + layer.radius * math.cos(angle);
        final y = center.dy + layer.radius * math.sin(angle);

        final dotOpacity = 0.2 + 0.15 * pulse;
        final dotPaint = Paint()
          ..color = color.withValues(alpha: dotOpacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), layer.dotSize, dotPaint);
      }
    }

    // ── CENTER ICON — large 2x2 grid (dominant element) ──

    // Glow behind center icon
    final centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.08 + 0.05 * pulse),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.30));
    canvas.drawCircle(center, radius * 0.30, centerGlow);

    // ── CENTER — 2x2 grid squares (dominant element) ──
    final iconPaint = Paint()
      ..color = color.withValues(alpha: 0.45 + 0.25 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final iconSize = 28.0 + 3.0 * pulse;
    final gap = 6.0;
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 2; c++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            center.dx - iconSize - gap / 2 + c * (iconSize + gap),
            center.dy - iconSize - gap / 2 + r * (iconSize + gap),
            iconSize,
            iconSize,
          ),
          const Radius.circular(6),
        );
        canvas.drawRRect(rect, iconPaint);
      }
    }

    // Subtle inner dots in each grid cell
    final innerDotPaint = Paint()
      ..color = color.withValues(alpha: 0.15 + 0.1 * pulse)
      ..style = PaintingStyle.fill;
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 2; c++) {
        final cx = center.dx - iconSize / 2 - gap / 2 + c * (iconSize + gap);
        final cy = center.dy - iconSize / 2 - gap / 2 + r * (iconSize + gap);
        canvas.drawCircle(Offset(cx, cy), 2.0, innerDotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant OrbitGridPainter old) =>
      old.progress != progress || old.pulse != pulse;
}

class _OrbitLayer {
  final int count;
  final double radius;
  final double speed;
  final double dotSize;
  _OrbitLayer({
    required this.count,
    required this.radius,
    required this.speed,
    required this.dotSize,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// NEURAL NET — AI page visual
// ─────────────────────────────────────────────────────────────────────────────

class NeuralNetPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final Color color;

  NeuralNetPainter({
    required this.progress,
    required this.pulse,
    required this.color,
  });

  static const _nodePositions = <List<Offset>>[
    [Offset(-0.32, -0.32), Offset(-0.32, 0.0), Offset(-0.32, 0.32)],
    [Offset(0.0, -0.38), Offset(0.0, -0.12), Offset(0.0, 0.12), Offset(0.0, 0.38)],
    [Offset(0.32, -0.22), Offset(0.32, 0.12)],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width * 0.82;

    final layers = _nodePositions
        .map((layer) => layer
            .map((p) => Offset(
                center.dx + p.dx * scale, center.dy + p.dy * scale))
            .toList())
        .toList();

    // Draw connections
    for (int l = 0; l < layers.length - 1; l++) {
      for (int i = 0; i < layers[l].length; i++) {
        for (int j = 0; j < layers[l + 1].length; j++) {
          final connectionId = l * 100 + i * 10 + j;
          final signalPos = ((progress * 1.8 + connectionId * 0.13) % 1.0);

          final from = layers[l][i];
          final to = layers[l + 1][j];

          // Connection line
          final linePaint = Paint()
            ..color = color.withValues(alpha: 0.05 + 0.025 * pulse)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7;
          canvas.drawLine(from, to, linePaint);

          // Traveling signal with trail
          for (int t = 0; t < 3; t++) {
            final trailPos = (signalPos - t * 0.03).clamp(0.0, 1.0);
            final trailAlpha = (0.35 + 0.2 * pulse) * (1 - t * 0.35);
            final signalPoint = Offset(
              from.dx + (to.dx - from.dx) * trailPos,
              from.dy + (to.dy - from.dy) * trailPos,
            );
            final signalPaint = Paint()
              ..color = color.withValues(alpha: trailAlpha)
              ..style = PaintingStyle.fill;
            canvas.drawCircle(signalPoint, 1.5 - t * 0.3, signalPaint);
          }
        }
      }
    }

    // Draw nodes
    for (int l = 0; l < layers.length; l++) {
      for (int i = 0; i < layers[l].length; i++) {
        final pos = layers[l][i];
        final nodeRadius = 6.0 + (l == 1 ? 2.0 : 0.0);

        // Glow on alternating nodes
        if ((l + i) % 2 == 0) {
          final glowPaint = Paint()
            ..color = color.withValues(alpha: 0.07 * pulse)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
          canvas.drawCircle(pos, nodeRadius + 8, glowPaint);
        }

        // Node fill
        final fillPaint = Paint()
          ..color = color.withValues(alpha: 0.04 + 0.04 * pulse)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, nodeRadius, fillPaint);

        // Node ring
        final ringPaint = Paint()
          ..color = color.withValues(alpha: 0.18 + 0.12 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(pos, nodeRadius, ringPaint);

        // Center dot
        final dotPaint = Paint()
          ..color = color.withValues(alpha: 0.5 + 0.35 * pulse)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 2.2, dotPaint);
      }
    }

    // Center sparkle — 4-pointed star
    final sparkleSize = 7.0 + 4.0 * pulse;
    final sparklePaint = Paint()
      ..color = color.withValues(alpha: 0.35 + 0.3 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - sparkleSize, center.dy),
      Offset(center.dx + sparkleSize, center.dy),
      sparklePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - sparkleSize),
      Offset(center.dx, center.dy + sparkleSize),
      sparklePaint,
    );
    final diagSize = sparkleSize * 0.55;
    canvas.drawLine(
      Offset(center.dx - diagSize, center.dy - diagSize),
      Offset(center.dx + diagSize, center.dy + diagSize),
      sparklePaint,
    );
    canvas.drawLine(
      Offset(center.dx + diagSize, center.dy - diagSize),
      Offset(center.dx - diagSize, center.dy + diagSize),
      sparklePaint,
    );
  }

  @override
  bool shouldRepaint(covariant NeuralNetPainter old) =>
      old.progress != progress || old.pulse != pulse;
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOATING PARTICLES — Background layer
// ─────────────────────────────────────────────────────────────────────────────

class FloatingParticlesPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int count;

  FloatingParticlesPainter({
    required this.progress,
    required this.color,
    this.count = 22,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);

    for (int i = 0; i < count; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.2 + rng.nextDouble() * 0.6;
      final phase = rng.nextDouble();
      final dotSize = 0.8 + rng.nextDouble() * 1.8;

      final t = (progress * speed + phase) % 1.0;
      final dx = math.sin(t * 2 * math.pi) * 25;
      final dy = math.cos(t * 2 * math.pi * 0.6 + phase * math.pi) * 18;

      final x = baseX + dx;
      final y = baseY + dy;

      // Soft fade in and out
      final fadeCycle = math.sin(t * math.pi);
      final opacity = 0.06 + 0.18 * fadeCycle;
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), dotSize, paint);

      // Occasional glow on larger particles
      if (dotSize > 2.0) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.04 * fadeCycle)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(x, y), dotSize + 3, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FloatingParticlesPainter old) =>
      old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBTLE GRID — Background rotating grid
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingGridPainter extends CustomPainter {
  final double rotation;
  final double opacity;
  final Color color;

  OnboardingGridPainter({
    required this.rotation,
    required this.opacity,
    required this.color,
  });

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

    // Intersection dots for extra detail
    final dotPaint = Paint()
      ..color = color.withValues(alpha: opacity * 1.5)
      ..style = PaintingStyle.fill;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OnboardingGridPainter old) =>
      old.rotation != rotation || old.opacity != opacity;
}
