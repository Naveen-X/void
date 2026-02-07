// lib/ui/widgets/glass_card.dart
// Reusable glass morphism card widget

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/void_design.dart';
import '../theme/void_theme.dart';

/// A reusable glass-morphism styled card with blur effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final Gradient? gradient;
  final double blurAmount;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(0),
    this.borderColor,
    this.gradient,
    this.blurAmount = 10,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(VoidDesign.radiusXL);
    
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? theme.textPrimary.withValues(alpha: 0.03) : null,
            gradient: gradient,
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? theme.borderSubtle,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
