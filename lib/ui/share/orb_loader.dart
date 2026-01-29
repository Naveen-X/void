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
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state == OrbState.processing) {
      if (_ctrl.duration != const Duration(milliseconds: 400)) {
        _ctrl.duration = const Duration(milliseconds: 400);
        _ctrl.repeat(reverse: true);
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // 🔥 THE SHOCKWAVE (Sharp, fast ripple)
        if (widget.state == OrbState.success)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutExpo,
            builder: (context, val, child) => Container(
              width: 60 + (val * 300), // Massive expansion
              height: 60 + (val * 300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: (1.0 - val) * 0.4),
                  width: 0.8, // Hairline thin
                ),
              ),
            ),
          ),

        // THE ORB
        if (widget.state == OrbState.success)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 4.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutQuart,
            builder: (_, val, child) => Opacity(
              opacity: (1.0 - (val - 1.0) / 3.0).clamp(0.0, 1.0),
              child: Transform.scale(scale: val, child: child),
            ),
            child: _buildOrbBody(isSuccess: true),
          )
        else
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) => Transform.scale(
              scale: 0.94 + (_ctrl.value * 0.08),
              child: _buildOrbBody(),
            ),
          ),
      ],
    );
  }

  Widget _buildOrbBody({bool isSuccess = false}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white,
            isSuccess ? Colors.white.withValues(alpha: 0.2) : const Color(0xFF777777)
          ],
          stops: const [0.1, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: isSuccess ? 0.1 : 0.2),
            blurRadius: isSuccess ? 80 : 30,
            spreadRadius: isSuccess ? 30 : 5,
          ),
        ],
      ),
    );
  }
}