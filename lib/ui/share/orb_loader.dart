import 'package:flutter/material.dart';

class OrbLoader extends StatefulWidget {
  const OrbLoader({super.key});

  @override
  State<OrbLoader> createState() => _OrbLoaderState();
}

class _OrbLoaderState extends State<OrbLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.92, end: 1.05)
          .animate(CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeInOut,
      )),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Colors.white,
              Color(0xFF888888),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.25),
              blurRadius: 24,
            ),
          ],
        ),
      ),
    );
  }
}
