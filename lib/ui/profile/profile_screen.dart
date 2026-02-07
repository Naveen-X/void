// lib/ui/profile/profile_screen.dart
// Main profile screen with extracted component imports

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_screen.dart';
import '../../data/stores/void_store.dart';
import '../../services/security_service.dart';
import '../../services/haptic_service.dart';
import '../../services/groq_service.dart';
import '../theme/void_design.dart';
import '../theme/void_theme.dart';
import '../theme/theme_provider.dart';
import 'package:provider/provider.dart';

// Extracted components
import 'components/profile_tiles.dart';
import 'components/api_key_sheet.dart';
import 'components/glitchy_404.dart';
import '../widgets/glass_card.dart';
import '../painters/custom_painters.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
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

  void _showApiKeySheet() {
    final controller =
        TextEditingController(text: GroqService.getApiKey() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApiKeySheetContent(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final theme = VoidTheme.of(context);
    return Scaffold(
      backgroundColor: theme.bgPrimary,
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
                  VoidDesign.space3XL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme),
                  const SizedBox(height: 24),
                  _buildSectionTitle("ACCOUNT", theme),
                  const SizedBox(height: 12),
                  _buildAccountSection(theme),
                  const SizedBox(height: 32),
                  _buildSectionTitle("VAULT METRICS", theme),
                  const SizedBox(height: 12),
                  _buildStatsSection(theme),
                  const SizedBox(height: 32),
                  _buildSectionTitle("SECURITY", theme),
                  const SizedBox(height: 12),
                  _buildSecuritySection(theme),
                  const SizedBox(height: 28),
                  _buildSectionTitle("AI SETTINGS", theme),
                  const SizedBox(height: 12),
                  _buildAISettingsSection(theme),
                  const SizedBox(height: 28),
                  _buildSectionTitle("DATA", theme),
                  const SizedBox(height: 12),
                  _buildDataSection(theme),
                  const SizedBox(height: 28),
                  _buildSectionTitle("DANGER ZONE", theme),
                  const SizedBox(height: 12),
                  _buildDangerSection(theme),
                  const SizedBox(height: 32),
                  _buildSectionTitle("SYSTEM", theme),
                  const SizedBox(height: 12),
                  _buildAboutSection(theme),
                  const SizedBox(height: 48),
                  _buildVersionFooter(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VoidTheme theme) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.textPrimary.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: theme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAccountSection(VoidTheme theme) {
    return GlassCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                          theme.textPrimary.withValues(alpha: 0.15),
                          theme.textPrimary.withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border.all(
                          color: theme.textPrimary.withValues(alpha: 0.1)),
                    ),
                    child: Icon(Icons.person_rounded,
                        size: 32, color: theme.textSecondary),
                  ),
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
                              color: theme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: PX-509-ALPHA',
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 10,
                          color: theme.textTertiary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: theme.textPrimary.withValues(alpha: 0.05), height: 1),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return ToggleTile(
                icon: themeProvider.isDarkMode 
                    ? Icons.dark_mode_rounded 
                    : Icons.light_mode_rounded,
                iconColor: themeProvider.isDarkMode ? Colors.purpleAccent : Colors.orangeAccent,
                title: 'Dark Mode',
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              );
            },
          ),
          Divider(color: theme.textPrimary.withValues(alpha: 0.05), height: 1),
          ActionTile(
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

  Widget _buildSecuritySection(VoidTheme theme) {
    return GlassCard(
      child: ToggleTile(
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
    );
  }

  Widget _buildAISettingsSection(VoidTheme theme) {
    return GlassCard(
      child: ActionTile(
        icon: Icons.auto_awesome,
        title: 'Groq API Key',
        subtitle: 'Enable AI tagging & summaries',
        onTap: () => _showApiKeySheet(),
      ),
    );
  }

  Widget _buildDataSection(VoidTheme theme) {
    return GlassCard(
      child: Column(
        children: [
          ActionTile(
            icon: Icons.upload_rounded,
            title: 'Export Vault',
            subtitle: 'Save fragments to file',
            onTap: () {
              HapticService.light();
              // TODO: Implement export
            },
          ),
          Divider(color: theme.textPrimary.withValues(alpha: 0.05), height: 1),
          ActionTile(
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
    );
  }

  Widget _buildDangerSection(VoidTheme theme) {
    return GlassCard(
      borderColor: Colors.redAccent.withValues(alpha: 0.2),
      child: ActionTile(
        icon: Icons.delete_forever_rounded,
        iconColor: Colors.redAccent,
        title: 'Purge Vault',
        subtitle: 'Permanently erase all data',
        onTap: () {
          HapticService.heavy();
          // TODO: Implement purge with confirmation
        },
      ),
    );
  }

  Widget _buildAboutSection(VoidTheme theme) {
    return GlassCard(
      child: ActionTile(
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

  Widget _buildStatsSection(VoidTheme theme) {
    if (_itemCount == 0) {
      return _buildEmptyStatsPlaceholder();
    }

    return AnimatedBuilder(
      animation: _statsAnimController,
      builder: (context, _) {
        return Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Data Core
                  Expanded(
                    flex: 6,
                    child: GlassCard(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.textPrimary.withValues(alpha: 0.08),
                          theme.textPrimary.withValues(alpha: 0.02),
                        ],
                      ),
                      padding: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: TechRingPainter(
                                  _dataStreamController.value),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDataCoreHeader(),
                                _buildItemCountDisplay(theme),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right Modules
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Expanded(
                            child: _buildStatModule("Links",
                                _linkCount.toString(), Icons.link_rounded, Colors.cyanAccent, theme)),
                        const SizedBox(height: 12),
                        Expanded(
                            child: _buildStatModule(
                                "Notes",
                                _noteCount.toString(),
                                Icons.sticky_note_2_outlined,
                                Colors.purpleAccent, theme)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildStorageBar(theme),
          ],
        );
      },
    );
  }

  Widget _buildDataCoreHeader() {
    return Row(
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
    );
  }

  Widget _buildItemCountDisplay(VoidTheme theme) {
    return Column(
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
              color: theme.textPrimary,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Total Items",
          style: GoogleFonts.ibmPlexMono(
            fontSize: 11,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatModule(
      String label, String value, IconData icon, Color color, VoidTheme theme) {
    return GlassCard(
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
                  color: theme.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 24,
                  color: theme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageBar(VoidTheme theme) {
    return GlassCard(
      gradient: LinearGradient(
        colors: [theme.textPrimary.withValues(alpha: 0.05), Colors.transparent],
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
                  color: theme.textSecondary,
                ),
              ),
              Text(
                _storageSize,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
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
                  Expanded(flex: 5, child: Container(color: theme.textPrimary.withValues(alpha: 0.1))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStatsPlaceholder() {
    // This widget doesn't strictly need theme since it's an error state using Glitchy404
    // But for consistency let's update colors if used
    // Actually it uses Colors.white.withValues, let's fix it if passed theme
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) {
         final theme = VoidTheme.of(context);
         return GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Center(
            child: Column(
              children: [
                const Glitchy404(),
                const SizedBox(height: 32),
                Text(
                  "SIGNAL_LOST",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 14,
                    letterSpacing: 6,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "METRICS_UNAVAILABLE // RECOVERY_FAILED",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: theme.textTertiary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildSectionTitle(String title, VoidTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(left: VoidDesign.spaceXS),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: theme.textTertiary,
              borderRadius: BorderRadius.circular(VoidDesign.spaceXS),
            ),
          ),
          const SizedBox(width: VoidDesign.spaceMD),
          Text(
            title,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 11,
              letterSpacing: 3,
              color: theme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionFooter(VoidTheme theme) {
    return Center(
      child: Text(
        'void v1.0.0',
        style: GoogleFonts.ibmPlexMono(
          fontSize: 10,
          color: theme.textPrimary.withValues(alpha: 0.1),
          letterSpacing: 2,
        ),
      ),
    );
  }
}