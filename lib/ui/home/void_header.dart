import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/void_route.dart';
import '../profile/profile_screen.dart';

class VoidHeader extends StatelessWidget {
  const VoidHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔥 TERMINAL BRAND HERO
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
            
            // Profile Button
            GestureDetector(
              onTap: () => Navigator.of(context).push(VoidSurfaceRoute(page: const ProfileScreen())),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.person, size: 18, color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}