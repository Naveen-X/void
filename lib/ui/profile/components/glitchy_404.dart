// lib/ui/profile/components/glitchy_404.dart
// Animated glitch effect 404 widget

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// An animated "404" text with random glitch effect
class Glitchy404 extends StatefulWidget {
  const Glitchy404({super.key});

  @override
  State<Glitchy404> createState() => _Glitchy404State();
}

class _Glitchy404State extends State<Glitchy404>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final bool shouldGlitch = _random.nextDouble() > 0.92;
        final double offset = shouldGlitch ? _random.nextDouble() * 4 - 2 : 0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Red Offset
            if (shouldGlitch)
              Transform.translate(
                offset: Offset(offset, 0),
                child: Text(
                  "404",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.redAccent.withValues(alpha: 0.5),
                  ),
                ),
              ),
            // Cyan Offset
            if (shouldGlitch)
              Transform.translate(
                offset: Offset(-offset, 0),
                child: Text(
                  "404",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.cyanAccent.withValues(alpha: 0.5),
                  ),
                ),
              ),
            // Primary Text
            Text(
              "404",
              style: GoogleFonts.ibmPlexMono(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
