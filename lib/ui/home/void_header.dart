import '../../app/void_route.dart';
import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class VoidHeader extends StatelessWidget {
  const VoidHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Text(
              'void',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 26,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.8,
                color: Colors.white70,
              ),
            ),

            // Profile orb (flat + soft like reference)
            GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(VoidSurfaceRoute(page: const ProfileScreen()));
              },

              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.3, -0.3),
                    radius: 1.2,
                    colors: [Color(0xFFF2F2F2), Color(0xFFBDBDBD)],
                  ),
                  boxShadow: [
                    // ambient glow
                    BoxShadow(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.12),
                      blurRadius: 36,
                      spreadRadius: 10,
                    ),

                    // soft depth (keeps it grounded)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
