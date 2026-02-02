import 'package:flutter/material.dart';

class VoidEmptyState extends StatelessWidget {
  const VoidEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.10),
                    blurRadius: 80,
                    spreadRadius: 24,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Icon(
                    Icons.all_inclusive, // 🔥 Changed from auto_awesome to blur_on
                    color: Colors.white70,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Deep Silence',
              style: TextStyle(
                fontSize: 28,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              child: const Text(
                'CAPTURE YOUR FIRST FRAGMENT',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}