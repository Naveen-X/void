import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/void_theme.dart';
import '../theme/void_design.dart';
import '../../services/haptic_service.dart';
import '../trash/trash_screen.dart';

class VoidDrawer extends StatelessWidget {
  final VoidCallback onReturnFromTrash;

  const VoidDrawer({
    super.key,
    required this.onReturnFromTrash,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);

    return Drawer(
      backgroundColor: theme.bgCard,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Text(
                'void',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -1.0,
                  color: theme.textPrimary,
                ),
              ),
            ),

            _buildDrawerItem(
              context,
              icon: Icons.all_inbox_rounded,
              title: "All Items",
              isSelected: true,
              theme: theme,
              onTap: () {
                HapticService.light();
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 12),
            _buildSectionHeader("ORGANIZATION", theme),

            _buildDrawerItem(
              context,
              icon: Icons.folder_outlined,
              title: "Folders",
              isSelected: false,
              theme: theme,
              onTap: () {
                HapticService.light();
                // TODO: Folders implementation
                Navigator.pop(context);
              },
            ),

            _buildDrawerItem(
              context,
              icon: Icons.star_border_rounded,
              title: "Favorites",
              isSelected: false,
              theme: theme,
              onTap: () {
                HapticService.light();
                // TODO: Favorites implementation
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            _buildDrawerItem(
              context,
              icon: Icons.delete_outline_rounded,
              title: "Trash",
              isSelected: false,
              theme: theme,
              onTap: () async {
                HapticService.light();
                Navigator.pop(context); // Close drawer
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrashScreen()),
                );
                // Trigger refresh on the home screen when returning from Trash
                if (context.mounted) {
                   onReturnFromTrash();
                }
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8, top: 12),
      child: Text(
        title,
        style: GoogleFonts.ibmPlexMono(
          color: theme.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidTheme theme,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(VoidDesign.radiusMD),
          highlightColor: theme.textPrimary.withValues(alpha: 0.05),
          splashColor: theme.textPrimary.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.textPrimary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(VoidDesign.radiusMD),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? theme.textPrimary : theme.textSecondary,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? theme.textPrimary : theme.textSecondary,
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
