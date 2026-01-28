import 'package:flutter/material.dart';

enum OrbState { idle, processing, success }

class OrbLoader extends StatefulWidget {
  final OrbState state;
  const OrbLoader({super.key, this.state = OrbState.idle});

  @override
  State<OrbLoader> createState() => _OrbLoaderState();
}

class _OrbLoaderState extends State<OrbLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Speed up if processing
    if (widget.state == OrbState.processing) {
      if (!_ctrl.isAnimating || _ctrl.duration != const Duration(milliseconds: 600)) {
        _ctrl.duration = const Duration(milliseconds: 600);
        _ctrl.repeat(reverse: true);
      }
    } else if (widget.state == OrbState.idle) {
      if (_ctrl.duration != const Duration(seconds: 4)) {
        _ctrl.duration = const Duration(seconds: 4);
        _ctrl.repeat(reverse: true);
      }
    }

    // If success, we expand out
    if (widget.state == OrbState.success) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 4.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInExpo,
        builder: (_, val, __) => Opacity(
          opacity: (1 - (val - 1) / 3).clamp(0.0, 1.0),
          child: Transform.scale(scale: val, child: _buildOrb()),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (_ctrl.value * 0.1), // Breathe
          child: _buildOrb(),
        );
      },
    );
  }

  Widget _buildOrb() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Colors.white, Color(0xFFAAAAAA)],
          stops: [0.2, 1.0],
          center: Alignment(-0.2, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 32,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 64,
            spreadRadius: 24,
          ),
        ],
      ),
    );
  }
}