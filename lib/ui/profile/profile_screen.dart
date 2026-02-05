import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_screen.dart';
import '../../data/stores/void_store.dart';
import '../../services/security_service.dart';
import '../../services/haptic_service.dart';
import '../theme/void_design.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  bool _isLockEnabled = false;
  int _itemCount = 0;
  int _linkCount = 0;
  int _noteCount = 0;
  String _storageSize = "0 KB";
  final String _displayName = "XD";

  late AnimationController _dataStreamController;
  late AnimationController _statsAnimController;

  @override
  void initState() {
    super.initState();
    _dataStreamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _statsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _loadData();
  }

  @override
  void dispose() {
    _dataStreamController.dispose();
    _statsAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final enabled = await SecurityService.isLockEnabled();
    final items = await VoidStore.all();
    final links = items.where((i) => i.type == 'link').length;
    final notes = items.where((i) => i.type == 'note').length;
    final size = (items.length * 0.45).toStringAsFixed(1);

    if (!mounted) return;
    setState(() {
      _isLockEnabled = enabled;
      _itemCount = items.length;
      _linkCount = links;
      _noteCount = notes;
      _storageSize = "$size KB";
    });
    
    _statsAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: VoidDesign.bgPrimary,
      body: Stack(
        children: [
          // 1. Animated Data Stream Background
          AnimatedBuilder(
            animation: _dataStreamController,
            builder: (context, child) {
              return CustomPaint(
                painter: DataStreamPainter(_dataStreamController.value),
                size: Size.infinite,
              );
            },
          ),

          // 2. Main Content with scroll
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                VoidDesign.pageHorizontal, 
                statusBarHeight + VoidDesign.spaceMD, 
                VoidDesign.pageHorizontal, 
                VoidDesign.space3XL
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ─────────────────────────────
                  _buildHeader(context),

                  const SizedBox(height: 24),

                  // ─── Account ────────────────────────────
                  _buildSectionTitle("ACCOUNT"),
                  const SizedBox(height: 12),
                  _buildAccountSection(),

                  const SizedBox(height: 32),

                  // ─── Stats Overview ─────────────────────
                  _buildSectionTitle("VAULT METRICS"),
                  const SizedBox(height: 12),
                  _buildStatsSection(),

                  const SizedBox(height: 32),

                  // ─── Security ───────────────────────────
                  _buildSectionTitle("SECURITY"),
                  const SizedBox(height: 12),
                  _GlassCard(
                    child: _ToggleTile(
                      icon: Icons.fingerprint_rounded,
                      title: "Biometric Lock",
                      subtitle: "Require authentication on startup",
                      value: _isLockEnabled,
                      onChanged: (val) async {
                        HapticService.medium();
                        await SecurityService.setLockEnabled(val);
                        setState(() => _isLockEnabled = val);
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─── Data Management ────────────────────
                  _buildSectionTitle("DATA"),
                  const SizedBox(height: 12),
                  _GlassCard(
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: Icons.upload_rounded,
                          title: 'Export Vault',
                          subtitle: 'Save fragments to file',
                          onTap: () {
                            HapticService.light();
                            // TODO: Implement export
                          },
                        ),
                        Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                        _ActionTile(
                          icon: Icons.download_rounded,
                          title: 'Import Vault',
                          subtitle: 'Restore from backup',
                          onTap: () {
                            HapticService.light();
                            // TODO: Implement import
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─── Danger Zone ────────────────────────
                  _buildSectionTitle("DANGER ZONE"),
                  const SizedBox(height: 12),
                  _GlassCard(
                    borderColor: Colors.redAccent.withValues(alpha: 0.2),
                    child: _ActionTile(
                      icon: Icons.delete_forever_rounded,
                      iconColor: Colors.redAccent,
                      title: 'Purge Vault',
                      subtitle: 'Permanently erase all data',
                      onTap: () {
                        HapticService.heavy();
                        // TODO: Implement purge with confirmation
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─── About ──────────────────────────────
                  _buildSectionTitle("SYSTEM"),
                  const SizedBox(height: 12),
                  _buildAboutSection(),

                  const SizedBox(height: 48),

                  // ─── Version ────────────────────────────
                  Center(
                    child: Text(
                      'void v1.0.0',
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.1),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return _GlassCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'profile_icon_hero',
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Icon(Icons.person_rounded, size: 32, color: Colors.white70),
                      ),
                    ),

                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _displayName,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: PX-509-ALPHA',
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 10,
                          color: VoidDesign.textTertiary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          _ActionTile(
            icon: Icons.logout_rounded,
            iconColor: Colors.orangeAccent,
            title: 'Logout',
            subtitle: 'Terminate active session',
            onTap: () {
              HapticService.medium();
              // TODO: Implement logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return _GlassCard(
      child: _ActionTile(
        icon: Icons.info_outline_rounded,
        title: 'About Void',
        subtitle: 'System info and developer',
        onTap: () {
          HapticService.light();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutScreen()),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_itemCount == 0) {
      return _buildEmptyStatsPlaceholder();
    }

    return AnimatedBuilder(
      animation: _statsAnimController,
      builder: (context, _) {
        return Column(
          children: [
            // Use IntrinsicHeight to make the Row children share equal heights
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Main Data Core (Left)
                  Expanded(
                    flex: 6,
                    child: _GlassCard(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                      ),
                      padding: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          // Background Radar Animation
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _TechRingPainter(_dataStreamController.value),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.cyanAccent.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.hub_rounded, color: Colors.cyanAccent, size: 14),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.cyanAccent.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.cyanAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "ACTIVE",
                                            style: GoogleFonts.ibmPlexMono(
                                              fontSize: 9,
                                              color: Colors.cyanAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TweenAnimationBuilder<int>(
                                      tween: IntTween(begin: 0, end: _itemCount),
                                      duration: const Duration(seconds: 1),
                                      builder: (context, val, _) => Text(
                                        val.toString(),
                                        style: GoogleFonts.ibmPlexSans(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Total Items",
                                      style: GoogleFonts.ibmPlexMono(
                                        fontSize: 11,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 2. Right Modules (Links & Notes)
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildStatModule(
                            "Links",
                            _linkCount.toString(),
                            Icons.link_rounded,
                            Colors.cyanAccent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _buildStatModule(
                            "Notes",
                            _noteCount.toString(),
                            Icons.sticky_note_2_outlined,
                            Colors.purpleAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // 3. Storage Bar
            _GlassCard(
              gradient: LinearGradient(
                colors: [Colors.white.withValues(alpha: 0.05), Colors.transparent],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.storage_rounded, size: 16, color: Colors.greenAccent),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Storage",
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 11, 
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        _storageSize,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Segmented Progress Bar with rounded ends
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 8,
                      width: 80,
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Container(color: Colors.blueAccent)),
                          const SizedBox(width: 2),
                          Expanded(flex: 2, child: Container(color: Colors.cyanAccent)),
                          const SizedBox(width: 2),
                          Expanded(flex: 5, child: Container(color: Colors.white10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatModule(String label, String value, IconData icon, Color color) {
    return _GlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStatsPlaceholder() {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            const _Glitchy404(),
            const SizedBox(height: 32),
            Text(
              "SIGNAL_LOST",
              style: GoogleFonts.ibmPlexMono(
                fontSize: 14,
                letterSpacing: 6,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "METRICS_UNAVAILABLE // RECOVERY_FAILED",
              style: GoogleFonts.ibmPlexMono(
                fontSize: 9,
                letterSpacing: 1,
                color: VoidDesign.textTertiary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: VoidDesign.spaceXS),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: VoidDesign.textMuted,
              borderRadius: BorderRadius.circular(VoidDesign.spaceXS),
            ),
          ),
          const SizedBox(width: VoidDesign.spaceMD),
          Text(
            title,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 11,
              letterSpacing: 3,
              color: VoidDesign.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final Gradient? gradient;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(0),
    this.borderColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(VoidDesign.radiusXL),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? Colors.white.withValues(alpha: 0.03) : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(VoidDesign.radiusXL),
            border: Border.all(
              color: borderColor ?? VoidDesign.borderSubtle,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}



class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value 
                ? Colors.greenAccent.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon, 
              size: 20, 
              color: value ? Colors.greenAccent : Colors.white38,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: GoogleFonts.ibmPlexSans(
                    color: Colors.white, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle, 
                  style: GoogleFonts.ibmPlexSans(
                    color: Colors.white24, 
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.greenAccent,
            activeTrackColor: Colors.greenAccent.withValues(alpha: 0.3),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            inactiveThumbColor: Colors.white38,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.white).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor ?? Colors.white54),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        color: iconColor ?? Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 11,
                        color: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded, 
                size: 20, 
                color: Colors.white12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

class DataStreamPainter extends CustomPainter {
  final double progress;
  final List<DataLine> _lines = List.generate(25, (index) => DataLine());

  DataStreamPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.02);

    for (var line in _lines) {
      double currentY = (line.startY * size.height) + (progress * size.height * line.speed);
      if (currentY > size.height) {
        currentY -= size.height;
      }

      canvas.drawLine(
        Offset(line.startX * size.width, currentY),
        Offset(line.startX * size.width + line.length, currentY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DataStreamPainter oldDelegate) => true;
}

class _TechRingPainter extends CustomPainter {
  final double progress;
  _TechRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Outer Ring
    final rect = Rect.fromCenter(center: center, width: size.width * 0.8, height: size.height * 0.8);
    canvas.drawArc(rect, progress * 6.28, 1.5, false, paint);
    canvas.drawArc(rect, progress * 6.28 + 3.14, 1.5, false, paint);

    // Inner Dots
    final paintDots = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.2);
    for (int i = 0; i < 8; i++) {
        final angle = (i * 3.14 / 4) + (progress * 2);
        final dx = center.dx + (size.width * 0.25) * math.cos(angle);
        final dy = center.dy + (size.height * 0.25) * math.sin(angle);
        canvas.drawCircle(Offset(dx, dy), 2, paintDots);
    }
  }

  @override
  bool shouldRepaint(covariant _TechRingPainter oldDelegate) => true;
}

class DataLine {
  double startX = math.Random().nextDouble();
  double startY = math.Random().nextDouble();
  double length = 30 + (math.Random().nextDouble() * 100);
  double speed = 0.5 + (math.Random().nextDouble() * 1.5);
}

class _Glitchy404 extends StatefulWidget {
  const _Glitchy404();
  @override
  State<_Glitchy404> createState() => _Glitchy404State();
}

class _Glitchy404State extends State<_Glitchy404> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final bool shouldGlitch = _random.nextDouble() > 0.92;
        final double offset = shouldGlitch ? _random.nextDouble() * 4 - 2 : 0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Red Offset
            if (shouldGlitch)
              Transform.translate(
                offset: Offset(offset, 0),
                child: Text(
                  "404",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.redAccent.withValues(alpha: 0.5),
                  ),
                ),
              ),
            // Cyan Offset
            if (shouldGlitch)
              Transform.translate(
                offset: Offset(-offset, 0),
                child: Text(
                  "404",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.cyanAccent.withValues(alpha: 0.5),
                  ),
                ),
              ),
            // Primary Text
            Text(
              "404",
              style: GoogleFonts.ibmPlexMono(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}