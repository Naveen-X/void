import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/void_route.dart';
import '../profile/profile_screen.dart';

class VoidHeader extends StatelessWidget {
  final double blurOpacity;

  const VoidHeader({super.key, this.blurOpacity = 0.0});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15 * blurOpacity,
          sigmaY: 15 * blurOpacity,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4 * blurOpacity),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.05 * blurOpacity),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Hero(
                tag: 'void_brand',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    'void',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  VoidSurfaceRoute(page: const ProfileScreen()),
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.person, size: 18, color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}