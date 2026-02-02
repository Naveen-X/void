import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../../app/void_route.dart'; // 🔥 REMOVE THIS IMPORT
import '../profile/profile_screen.dart';

class VoidHeader extends StatelessWidget {
  final double blurOpacity;

  const VoidHeader({super.key, this.blurOpacity = 0.0});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double contentAreaHeight = 56.0;
    final double totalHeaderHeight = statusBarHeight + contentAreaHeight;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15 * blurOpacity,
          sigmaY: 15 * blurOpacity,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: totalHeaderHeight,
          padding: EdgeInsets.fromLTRB(24, statusBarHeight, 24, 0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4 * blurOpacity),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.05 * blurOpacity),
                width: 1,
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    // 🔥 Changed to MaterialPageRoute for full-screen
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                  child: Hero( // 🔥 Hero source tag
                    tag: 'profile_icon_hero',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}