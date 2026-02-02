import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/stores/void_store.dart';
import '../../services/security_service.dart';
import '../../services/haptic_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLockEnabled = false;
  int _itemCount = 0;
  String _storageSize = "0 KB";

  late AnimationController _dataStreamController;

  @override
  void initState() {
    super.initState();
    _dataStreamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _loadData();
  }

  @override
  void dispose() {
    _dataStreamController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final enabled = await SecurityService.isLockEnabled();
    final items = await VoidStore.all();
    final size = (items.length * 0.45).toStringAsFixed(1);

    if (!mounted) return;
    setState(() {
      _isLockEnabled = enabled;
      _itemCount = items.length;
      _storageSize = "$size KB";
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black, // Full black background
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

          // 2. Main Content
          Padding(
            padding: EdgeInsets.fromLTRB(24, statusBarHeight + 16, 24, 24), // Adjust padding for status bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.white70,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Hero( // 🔥 Hero target for the profile icon
                      tag: 'profile_icon_hero',
                      child: Container(
                        width: 48, // Slightly larger for emphasis
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(Icons.person, size: 24, color: Colors.white54),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // ─── Title ───────────────────────────
                Text(
                  '// SYSTEM_DIAGNOSTICS',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 24,
                    letterSpacing: 1.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(width: 80, height: 2, color: Colors.white.withValues(alpha: 0.3)), // Underline

                const SizedBox(height: 48),

                // ─── Metrics ──────────────────────────────
                _buildSectionTitle("SYSTEM_METRICS"),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _StatBlock(label: 'ITEMS', value: _itemCount.toString()),
                    _StatBlock(label: 'STORAGE', value: _storageSize),
                    _StatBlock(label: 'MODE', value: 'LOCAL'),
                  ],
                ),

                const SizedBox(height: 40),

                // ─── Security ───────────────────────────
                _buildSectionTitle("SECURITY_PROTOCOLS"),
                _ToggleTile(
                  title: "BIOMETRIC_LOCK",
                  subtitle: "Require handshake on startup",
                  value: _isLockEnabled,
                  onChanged: (val) async {
                    HapticService.medium();
                    await SecurityService.setLockEnabled(val);
                    setState(() => _isLockEnabled = val);
                  },
                ),

                const SizedBox(height: 24),

                // ─── Actions ────────────────────────────
                _buildSectionTitle("DATA_MANAGEMENT"),
                _ActionTile(
                  title: 'EXPORT_VAULT',
                  subtitle: 'Save fragments to external file',
                  onTap: () {
                    HapticService.light();
                    // TODO: Implement export functionality
                  },
                ),
                const SizedBox(height: 12),
                _ActionTile(
                  title: 'IMPORT_VAULT',
                  subtitle: 'Restore from backup file',
                  onTap: () {
                    HapticService.light();
                    // TODO: Implement import functionality
                  },
                ),

                const Spacer(),

                // ─── Danger Zone ────────────────────────
                Center(
                  child: _ActionTile(
                    title: 'PURGE_VAULT',
                    subtitle: 'Permanently erase all data',
                    icon: Icons.warning_rounded,
                    iconColor: Colors.redAccent,
                    onTap: () {
                      HapticService.heavy();
                      // TODO: Implement reset vault functionality
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
      child: Text(
        '// $title',
        style: GoogleFonts.ibmPlexMono(
          fontSize: 10,
          letterSpacing: 2,
          color: Colors.white24,
        ),
      ),
    );
  }
}

/* ───────────────────────────────────────────── */
// Reusable Widgets (StatBlock, ToggleTile, ActionTile) - No changes needed here
// They are already designed for the terminal aesthetic.

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;

  const _StatBlock({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 16,
              letterSpacing: 1.2,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.ibmPlexMono(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                Text(subtitle, style: GoogleFonts.ibmPlexMono(color: Colors.white24, fontSize: 10)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.greenAccent.withValues(alpha: 0.4),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: iconColor ?? Colors.white70),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white10),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────────────────────────── */
// New CustomPainter for the background animation

class DataStreamPainter extends CustomPainter {
  final double progress;
  final List<DataLine> _lines = List.generate(20, (index) => DataLine());

  DataStreamPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.03);
    final random = math.Random();

    for (var line in _lines) {
      double currentY = (line.startY * size.height) + (progress * size.height * line.speed);
      if (currentY > size.height) {
        currentY -= size.height; // Wrap around
        line.startY = random.nextDouble(); // Reset start Y for new line
      }

      // Draw the main line
      canvas.drawLine(
        Offset(line.startX * size.width, currentY),
        Offset(line.startX * size.width + line.length, currentY),
        paint,
      );

      // Draw small "blips" on the line
      if (random.nextDouble() > 0.9) { // Occasional blips
        canvas.drawCircle(
          Offset(line.startX * size.width + random.nextDouble() * line.length, currentY),
          1.0,
          paint..color = Colors.white.withValues(alpha: 0.1),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DataStreamPainter oldDelegate) => true;
}

class DataLine {
  double startX = math.Random().nextDouble();
  double startY = math.Random().nextDouble();
  double length = 20 + (math.Random().nextDouble() * 80);
  double speed = 0.01 + (math.Random().nextDouble() * 0.02);
}