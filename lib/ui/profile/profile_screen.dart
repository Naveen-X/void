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

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLockEnabled = false;
  int _itemCount = 0;
  String _storageSize = "0 KB";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load Security Setting
    final enabled = await SecurityService.isLockEnabled();
    
    // Load Stats from Store
    final items = await VoidStore.all();
    
    // Estimate storage (very rough estimation for UI)
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 40,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ─────────────────────────────
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Colors.white70,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'profile',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 18,
                      letterSpacing: 1.2,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // ─── Identity ───────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          center: Alignment(-0.3, -0.3),
                          radius: 1.2,
                          colors: [Color(0xFFF2F2F2), Color(0xFFBDBDBD)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.08),
                            blurRadius: 32,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Local Identity',
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 14,
                        letterSpacing: 1.1,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'stored only on this device',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ─── Stats ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatBlock(label: 'Items', value: _itemCount.toString()),
                  _StatBlock(label: 'Storage', value: _storageSize),
                  const _StatBlock(label: 'Mode', value: 'Local'),
                ],
              ),

              const SizedBox(height: 40),

              // ─── Security ───────────────────────────
              _buildSectionTitle("SECURITY"),
              _buildToggleTile(
                title: "Biometric Lock",
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
              _buildSectionTitle("DATA"),
              _ActionTile(
                title: 'Export vault',
                subtitle: 'Save your fragments as a file',
                onTap: () {
                  HapticService.light();
                },
              ),
              const SizedBox(height: 12),
              _ActionTile(
                title: 'Import vault',
                subtitle: 'Restore from backup',
                onTap: () {
                  HapticService.light();
                },
              ),

              const Spacer(),

              // ─── Danger Zone ────────────────────────
              Center(
                child: TextButton(
                  onPressed: () {
                    HapticService.heavy();
                  },
                  child: Text(
                    'Reset vault',
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.ibmPlexMono(
          fontSize: 10,
          letterSpacing: 2,
          color: Colors.white24,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: Colors.white24, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.white24,
            inactiveTrackColor: Colors.black,
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────────────────────────── */

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;

  const _StatBlock({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 16,
            letterSpacing: 1.2,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

/* ───────────────────────────────────────────── */

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
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
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.4),
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