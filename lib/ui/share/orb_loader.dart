import 'dart:math' as math;
import 'package:flutter/material.dart';

enum OrbState { idle, processing, success }

class OrbLoader extends StatefulWidget {
  final OrbState state;
  const OrbLoader({super.key, this.state = OrbState.idle});

  @override
  State<OrbLoader> createState() => _OrbLoaderState();
}

class _OrbLoaderState extends State<OrbLoader> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _successController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(OrbLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.state == OrbState.processing && oldWidget.state != OrbState.processing) {
      _pulseController.duration = const Duration(milliseconds: 400);
      _pulseController.repeat(reverse: true);
    } else if (widget.state == OrbState.success && oldWidget.state != OrbState.success) {
      _successController.forward();
    } else if (widget.state == OrbState.idle && oldWidget.state != OrbState.idle) {
      _pulseController.duration = const Duration(milliseconds: 1500);
      _pulseController.repeat(reverse: true);
      _successController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController, _successController]),
      builder: (context, child) {
        final isSuccess = widget.state == OrbState.success;
        final isProcessing = widget.state == OrbState.processing;
        final successValue = _successController.value;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating ring
            if (!isSuccess)
              Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: isProcessing ? 0.15 : 0.08),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Orbiting dot
                      Positioned(
                        top: 0,
                        left: 34,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: isProcessing ? 0.6 : 0.3),
                            boxShadow: isProcessing ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ] : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Success shockwave rings
            if (isSuccess) ...[
              // First ring
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) => Container(
                  width: 60 + (val * 200),
                  height: 60 + (val * 200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: (1.0 - val) * 0.5),
                      width: 2 * (1.0 - val),
                    ),
                  ),
                ),
              ),
              // Second ring (delayed)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) => Container(
                  width: 60 + (val * 250),
                  height: 60 + (val * 250),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: (1.0 - val) * 0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
            
            // Main orb
            Transform.scale(
              scale: isSuccess 
                ? 1.0 + (successValue * 3.0)
                : _pulseAnimation.value,
              child: Opacity(
                opacity: isSuccess ? (1.0 - successValue).clamp(0.0, 1.0) : 1.0,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.8),
                        isProcessing 
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.grey.withValues(alpha: 0.6),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: _glowAnimation.value * (isProcessing ? 0.6 : 0.3)),
                        blurRadius: isProcessing ? 40 : 25,
                        spreadRadius: isProcessing ? 15 : 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Success checkmark
            if (isSuccess)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, val, child) => Transform.scale(
                  scale: val,
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}