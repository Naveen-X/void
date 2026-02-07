// lib/ui/home/components/home_bottom_controls.dart
// Bottom controls for search and actions

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/services/haptic_service.dart';
import '../../theme/void_theme.dart';

class HomeBottomControls extends StatelessWidget {
  final bool isKeyboardOpen;
  final bool isSelectionMode;
  final int selectedCount;
  final TextEditingController searchCtrl;
  final FocusNode searchFocusNode;
  final VoidCallback onClearSearch;
  final VoidCallback onCancelSelection;
  final VoidCallback onAdd;
  final VoidCallback onDelete;
  final bool isEmptyState;

  const HomeBottomControls({
    super.key,
    required this.isKeyboardOpen,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.searchCtrl,
    required this.searchFocusNode,
    required this.onClearSearch,
    required this.onCancelSelection,
    required this.onAdd,
    required this.onDelete,
    this.isEmptyState = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    if (isEmptyState && searchCtrl.text.isEmpty) {
      return Align(
        alignment: Alignment.centerRight,
        child: _buildRollingActionButton(theme),
      );
    }

    return Row(
      children: [
        Expanded(child: _buildRollingMainPill(theme)),
        if (!isKeyboardOpen) ...[
          const SizedBox(width: 12),
          _buildRollingActionButton(theme),
        ]
      ],
    );
  }

  Widget _buildRollingMainPill(VoidTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
      height: 52,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isSelectionMode ? theme.bgCard : theme.bgCard,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isSelectionMode ? theme.bgCard : theme.borderSubtle,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelectionMode
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.4 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutQuart,
            alignment: isSelectionMode ? const Alignment(0, -6.0) : Alignment.center,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelectionMode ? 0.0 : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        color: theme.textPrimary.withValues(alpha: 0.2), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        focusNode: searchFocusNode,
                        style:
                            TextStyle(color: theme.textPrimary, fontSize: 15),
                        cursorColor: theme.textPrimary,
                        decoration: InputDecoration(
                          hintText: "Search the void...",
                          hintStyle: TextStyle(color: theme.textPrimary.withValues(alpha: theme.brightness == Brightness.dark ? 0.1 : 0.25)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          HapticService.light();
                          onClearSearch();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.textPrimary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded,
                              color: theme.textSecondary, size: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutQuart,
            alignment: isSelectionMode ? Alignment.center : const Alignment(0, 6.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelectionMode ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "$selectedCount SELECTED",
                      style: GoogleFonts.ibmPlexMono(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticService.light();
                        onCancelSelection();
                      },
                      child: Text(
                        "CANCEL",
                        style: GoogleFonts.ibmPlexMono(
                          color: theme.textTertiary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRollingActionButton(VoidTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
      width: 52,
      height: 52,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isSelectionMode ? Colors.redAccent : theme.bgCard,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelectionMode
              ? Colors.redAccent
              : theme.textPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelectionMode
                ? Colors.redAccent.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.4 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
          // ADD ICON
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isSelectionMode ? 0.0 : 1.0,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutQuart,
              alignment: isSelectionMode ? const Alignment(0, -6.0) : Alignment.center,
              child: IgnorePointer(
                ignoring: isSelectionMode,
                child: IconButton(
                  icon: Icon(Icons.add, color: theme.textSecondary, size: 24),
                  onPressed: () {
                    searchFocusNode.unfocus();
                    HapticService.light();
                    onAdd();
                  },
                ),
              ),
            ),
          ),

          // DELETE ICON
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isSelectionMode ? 1.0 : 0.0,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutQuart,
              alignment: isSelectionMode ? Alignment.center : const Alignment(0, 6.0),
              child: IgnorePointer(
                ignoring: !isSelectionMode,
                child: IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: theme.textPrimary, size: 22),
                  onPressed: onDelete,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
