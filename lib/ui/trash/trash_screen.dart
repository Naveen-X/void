import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/haptic_service.dart';
import 'package:void_space/ui/theme/void_design.dart';
import 'package:void_space/ui/theme/void_theme.dart';
import 'package:void_space/ui/widgets/void_dialog.dart';

import '../home/messy_card.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<VoidItem> _trashItems = [];
  bool _isLoading = true;
  final FocusNode _dummyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadTrash();
  }

  Future<void> _loadTrash() async {
    setState(() => _isLoading = true);
    final items = await VoidStore.getTrash();
    setState(() {
      _trashItems = items;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _dummyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _restoreItem(VoidItem item) async {
    HapticService.light();
    await VoidStore.restore(item.id);
    _loadTrash();
    if (mounted) {
      final isDark = VoidTheme.of(context).brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F2AD).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.restore_rounded, color: Color(0xFF00F2AD), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Item Restored',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Item returned to home view.',
                        style: GoogleFonts.inter(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _deletePermanently(VoidItem item) async {
    HapticService.warning();
    final bool? confirm = await VoidDialog.show(
      context: context,
      title: "PERMANENTLY DELETE?",
      message: "This item will be gone forever.",
      confirmText: "DELETE",
    );

    if (confirm == true) {
      HapticService.heavy();
      await VoidStore.permanentlyDelete(item.id);
      _loadTrash();
      if (mounted) {
        final isDark = VoidTheme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Permanently Deleted',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'The item was removed forever.',
                          style: GoogleFonts.inter(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _emptyTrash() async {
    if (_trashItems.isEmpty) return;

    HapticService.warning();
    final bool? confirm = await VoidDialog.show(
      context: context,
      title: "EMPTY TRASH?",
      message:
          "Are you sure? This will permanently delete ${_trashItems.length} items.",
      confirmText: "EMPTY",
    );

    if (confirm == true) {
      HapticService.heavy();
      final ids = _trashItems.map((e) => e.id).toSet();
      await VoidStore.permanentlyDeleteMany(ids);
      _loadTrash();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Let gradient show through
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: AppBar(
              backgroundColor: theme.bgPrimary.withValues(alpha: 0.6),
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TRASH',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
              iconTheme: IconThemeData(color: theme.textPrimary),
              actions: [
                if (_trashItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: TextButton(
                      onPressed: _emptyTrash,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                      ),
                      child: Text(
                        'Empty',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.5,
            colors: isDark 
                ? [const Color(0xFF1E1E1E), const Color(0xFF0A0A0A)]
                : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: theme.textSecondary, strokeWidth: 2))
              : _trashItems.isEmpty
              ? _buildEmptyState(theme, isDark)
              : _buildTrashGrid(theme, isDark),
        ),
      ),
    );
  }

  Widget _buildEmptyState(VoidTheme theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                    ? [theme.textMuted.withValues(alpha: 0.2), theme.textMuted.withValues(alpha: 0.05)]
                    : [theme.textMuted.withValues(alpha: 0.1), theme.textMuted.withValues(alpha: 0.02)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                 BoxShadow(
                   color: theme.textMuted.withValues(alpha: isDark ? 0.1 : 0.05),
                   blurRadius: 40,
                   spreadRadius: 10,
                 )
              ]
            ),
            child: Icon(
              Icons.auto_delete_outlined,
              size: 56,
              color: theme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "All clear.",
            style: GoogleFonts.ibmPlexSans(
              color: theme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Deleted items will rest here.",
            style: GoogleFonts.inter(
              color: theme.textTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrashGrid(VoidTheme theme, bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadTrash,
      color: const Color(0xFF00F2AD),
      backgroundColor: theme.bgCard,
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: VoidDesign.spaceMD,
        crossAxisSpacing: VoidDesign.spaceMD,
        padding: const EdgeInsets.all(VoidDesign.pageHorizontal),
        itemCount: _trashItems.length,
        itemBuilder: (context, index) {
          final item = _trashItems[index];
          
          // Grayscale/Desaturation Matrix
          const colorMatrix = <double>[
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ];

          return Stack(
            children: [
              // Disable tapping on messycard in trash view
              IgnorePointer(
                child: Container(
                  foregroundDecoration: BoxDecoration(
                    color: isDark 
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(VoidDesign.radiusMD),
                    border: Border.all(
                      color: theme.borderSubtle.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(colorMatrix),
                    child: MessyCard(
                      key: ValueKey(item.id),
                      item: item,
                      index: index,
                      onUpdate: () async {},
                      onSelect: (_) {},
                      searchFocusNode: _dummyFocusNode,
                    ),
                  ),
                ),
              ),
              // Overlay actions
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(VoidDesign.radiusMD),
                    onTap: () {
                      _showActionMenu(context, item, theme, isDark);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showActionMenu(BuildContext context, VoidItem item, VoidTheme theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: theme.bgCard.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(top: BorderSide(color: theme.borderSubtle.withValues(alpha: 0.5))),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.textMuted.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildActionCard(
                      context: context,
                      theme: theme,
                      isDark: isDark,
                      icon: Icons.restore_rounded,
                      iconColor: const Color(0xFF00F2AD),
                      title: 'Restore to Void',
                      subtitle: 'Move this item back to your main grid.',
                      onTap: () {
                        Navigator.pop(context);
                        _restoreItem(item);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context: context,
                      theme: theme,
                      isDark: isDark,
                      icon: Icons.delete_forever_rounded,
                      iconColor: Colors.redAccent,
                      title: 'Delete Permanently',
                      subtitle: 'This action cannot be undone.',
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(context);
                        _deletePermanently(item);
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required VoidTheme theme,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: isDark ? const Color(0xFF1E1E1E).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
             color: isDestructive 
                 ? Colors.redAccent.withValues(alpha: 0.2) 
                 : theme.borderSubtle.withValues(alpha: 0.3)
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: iconColor.withValues(alpha: 0.1),
          highlightColor: iconColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          color: isDestructive ? Colors.redAccent : theme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: theme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
