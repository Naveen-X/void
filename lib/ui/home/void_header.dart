import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../profile/profile_screen.dart';
import '../theme/void_design.dart';

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
            color: VoidDesign.bgPrimary.withValues(alpha: 0.4 + (0.3 * blurOpacity)),
            border: Border(
              bottom: BorderSide(
                color: VoidDesign.borderSubtle,
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
                            color: VoidDesign.textPrimary,
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
                            color: Colors.white.withValues(alpha: 0.1),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: const Icon(Icons.person, size: 18, color: Colors.white54),
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
    final hasActiveFilters = selectedTags.isNotEmpty;
    
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
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
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(VoidDesign.radiusMD),
                        border: Border.all(
                          color: isAllSelected 
                            ? Colors.white.withValues(alpha: 0.3)
                            : VoidDesign.borderSubtle,
                        ),
                      ),
                      child: Text(
                        "All",
                        style: GoogleFonts.ibmPlexSans(
                          color: isAllSelected ? Colors.white : Colors.white38,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? tagColor.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected 
                          ? tagColor.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.ibmPlexSans(
                        color: isSelected ? tagColor : Colors.white38,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Clear button
        if (hasActiveFilters)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: onClearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close_rounded, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      "Clear",
                      style: GoogleFonts.ibmPlexSans(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}