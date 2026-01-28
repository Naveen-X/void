import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                          colors: [
                            Color(0xFFF2F2F2),
                            Color(0xFFBDBDBD),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.white.withValues(alpha: 0.08),
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
                children: const [
                  _StatBlock(label: 'Items', value: '—'),
                  _StatBlock(label: 'Storage', value: '—'),
                  _StatBlock(label: 'Mode', value: 'Local'),
                ],
              ),

              const SizedBox(height: 40),

              // ─── Actions ────────────────────────────
              _ActionTile(
                title: 'Export data',
                subtitle: 'Save your vault as a file',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _ActionTile(
                title: 'Import data',
                subtitle: 'Restore from backup',
                onTap: () {},
              ),

              const Spacer(),

              // ─── Danger Zone ────────────────────────
              Center(
                child: TextButton(
                  onPressed: () {},
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
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
        ),
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
    );
  }
}
