import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/void_design.dart';
import '../../services/haptic_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoidDesign.bgPrimary,
      body: Stack(
        children: [
          // Technical Background
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0], // Fade out starts at 60% down
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: CustomPaint(
                painter: _BentoBackgroundPainter(),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverSafeArea(
                  minimum: const EdgeInsets.only(top: 20),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Header Placeholder for spacing
                          const SizedBox(height: 60), 
                          _buildHeroSection(),
                          const SizedBox(height: 24),
                          _buildInfoGrid(),
                          const SizedBox(height: 16),
                          _buildConnectSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sticky Footer
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildFooter(),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Minimal Back Button (No blurred header)
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: Column(
        children: [
          // Avatar with Glitch Glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.1),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.purpleAccent.withValues(alpha: 0.05),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      "assets/images/dev.jpg",
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 60, color: Colors.white10),
                    ),
                  ],
                ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Name & Title
          Text(
            "Naveen xD",
            style: GoogleFonts.ibmPlexSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "A DEVELOPER",
            style: GoogleFonts.ibmPlexMono(
              fontSize: 11,
              color: Colors.cyanAccent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          
          // Bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Building intuitive experiences and scalable code.",
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CONNECT",
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 10, // Matching STACK title
                  color: Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.link_rounded, size: 14, color: Colors.white24),
            ],
          ),
          const SizedBox(height: 16), // Reduced from 24
          Row(
            children: [
              Expanded(child: _SocialButton(icon: Icons.code, label: "GitHub", url: "https://github.com/Naveen-X", centerContent: true)),
              const SizedBox(width: 12),
              Expanded(child: _SocialButton(icon: Icons.alternate_email, label: "Twitter", url: "https://x.com/Naveen__xD", centerContent: true)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SocialButton(icon: Icons.business, label: "LinkedIn", url: "https://linkedin.com", centerContent: true)),
              const SizedBox(width: 12),
              Expanded(child: _SocialButton(icon: Icons.email_outlined, label: "Email", url: "mailto:naveenxd@devh.in", centerContent: true)),
            ],
          ),
          const SizedBox(height: 12),
          _SocialButton(icon: Icons.language, label: "Portfolio", url: "https://naveenxd.eu.org", isFullWidth: true, centerContent: true),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App Info (Left)
        Expanded(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: Colors.cyanAccent, size: 20),
                ),
                const Spacer(),
                Text(
                  "VOID SPACE",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "v1.0.4",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "STABLE",
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "BUILD 2026.02",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    color: Colors.white38,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Tech Stack (Right)
        Expanded(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
             gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ">_ STACK",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        color: Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.layers_outlined, size: 14, color: Colors.white24),
                  ],
                ),
                const SizedBox(height: 20),
                _StackItem(label: "Flutter", version: "v3.19.0", progress: 0.95, isCompact: true),
                const SizedBox(height: 12),
                _StackItem(label: "Dart", version: "v3.10.7", progress: 0.90, isCompact: true),
                const SizedBox(height: 12),
                _StackItem(label: "Hive", version: "v2.2.3", progress: 0.85, isCompact: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Opacity(
        opacity: 0.8,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Made with ",
              style: GoogleFonts.ibmPlexMono(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFFF4D4D)),
            ),
            Text(
              " by ",
              style: GoogleFonts.ibmPlexMono(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            Text(
              "XD",
              style: GoogleFonts.ibmPlexMono(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final bool isFullWidth;
  final bool centerContent;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
    this.isFullWidth = false,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticService.light();
        final uri = Uri.parse(url);
        try {
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            debugPrint("Could not launch $url");
          }
        } catch (e) {
          debugPrint("Error launching URL: $e");
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: (isFullWidth || centerContent) ? Alignment.center : Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: (isFullWidth || centerContent) ? MainAxisAlignment.center : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(icon, size: 18, color: Colors.white70),
                if (!isFullWidth) const SizedBox(width: 12),
                if (isFullWidth) const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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

class _StackItem extends StatelessWidget {
  final String label;
  final String? version;
  final double progress;
  final bool isCompact;

  const _StackItem({
    required this.label,
    this.version,
    required this.progress,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
              if (version != null)
                Text(
                  version!,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    color: Colors.cyanAccent.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BentoBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1;

    const gridSize = 40.0;
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
