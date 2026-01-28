import 'package:flutter/material.dart';

class VoidSurfaceRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  VoidSurfaceRoute({required this.page})
    : super(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final t = curve.value;

          return FadeTransition(
            opacity: curve,

            child: AnimatedBuilder(
              animation: curve,
              builder: (context, _) {
                return Transform.scale(
                  scale: 0.98 + (t * 0.02),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.30 * curve.value,
                          ),
                          blurRadius: 48 * curve.value,
                          spreadRadius: 6 * curve.value,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                );
              },
            ),
          );
        },
      );
}
