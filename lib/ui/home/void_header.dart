import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../profile/profile_screen.dart';
import '../theme/void_design.dart';
import '../theme/void_theme.dart';

class VoidHeader extends StatelessWidget {
  final double blurOpacity;
  final List<String> availableTags;
  final Set<String> selectedTags;
  final VoidCallback onClearFilters;
  final Function(String) onToggleTag;
  final Color Function(String) getTagColor;

  const VoidHeader({
    super.key, 
    this.blurOpacity = 0.0,
    this.availableTags = const [],
    this.selectedTags = const {},
    required this.onClearFilters,
    required this.onToggleTag,
    required this.getTagColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerContentHeight = 56.0;
    const double tagBarHeight = 52.0;
    final bool hasTags = availableTags.isNotEmpty;
    // Add 1.0 to totalHeight to account for the bottom border which adds padding to the container
    final double totalHeight = statusBarHeight + headerContentHeight + (hasTags ? tagBarHeight : 0) + 1.0;

    // Always have blur for frosted effect
    final effectiveBlur = 0.4 + (0.6 * blurOpacity);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15 * effectiveBlur,
          sigmaY: 15 * effectiveBlur,
        ),
        child: Container(
          height: totalHeight,
          decoration: BoxDecoration(
            color: theme.bgPrimary.withValues(alpha: 0.4 + (0.3 * blurOpacity)),
            border: Border(
              bottom: BorderSide(
                color: theme.borderSubtle,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Status bar space + header content
              Container(
                height: statusBarHeight + headerContentHeight,
                padding: EdgeInsets.fromLTRB(24, statusBarHeight, 24, 0),
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
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                      child: Hero(
                        tag: 'profile_icon_hero',
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.textPrimary.withValues(alpha: 0.1),
                            border: Border.all(color: theme.textPrimary.withValues(alpha: 0.1)),
                          ),
                          child: Icon(Icons.person, size: 18, color: theme.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tags bar (integrated) - uses remaining space
              if (hasTags)
                Expanded(
                  child: _buildTagsRow(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
  


  Widget _buildTagsRow(BuildContext context) {
    final theme = VoidTheme.of(context);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: availableTags.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final isAllSelected = selectedTags.isEmpty;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: onClearFilters,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isAllSelected 
                    ? theme.textPrimary.withValues(alpha: 0.15)
                    : theme.textPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(VoidDesign.radiusMD),
                  border: Border.all(
                    color: isAllSelected 
                      ? theme.textPrimary.withValues(alpha: 0.3)
                      : theme.borderSubtle,
                  ),
                ),
                child: Text(
                  "All",
                  style: GoogleFonts.ibmPlexSans(
                    color: isAllSelected ? theme.textPrimary : theme.textTertiary,
                    fontSize: 13,
                    fontWeight: isAllSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }
        
        final tag = availableTags[index - 1];
        final isSelected = selectedTags.contains(tag);
        final tagColor = getTagColor(tag);
        
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onToggleTag(tag),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              // Adjusted padding to accommodate icon
              padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected 
                  ? tagColor.withValues(alpha: 0.15)
                  : theme.textPrimary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected 
                    ? tagColor.withValues(alpha: 0.4)
                    : theme.textPrimary.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag,
                    style: GoogleFonts.ibmPlexSans(
                      color: isSelected ? tagColor : theme.textTertiary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: tagColor.withValues(alpha: 0.8),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}