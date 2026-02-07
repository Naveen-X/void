// lib/ui/home/components/skeleton_grid.dart
// Shimmer loading grid for home screen

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:void_space/ui/theme/void_design.dart';
import 'package:void_space/ui/theme/void_theme.dart';

class SkeletonGrid extends StatelessWidget {
  final List<String> availableTags;

  const SkeletonGrid({super.key, required this.availableTags});

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 56 + (availableTags.isNotEmpty ? 52 : 0);
    
    return Shimmer.fromColors(
      baseColor: theme.textPrimary.withValues(alpha: 0.05),
      highlightColor: theme.textPrimary.withValues(alpha: 0.1),
      child: MasonryGridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: VoidDesign.spaceMD,
        crossAxisSpacing: VoidDesign.spaceMD,
        padding: EdgeInsets.fromLTRB(
          VoidDesign.pageHorizontal, 
          headerHeight + VoidDesign.spaceMD, 
          VoidDesign.pageHorizontal, 
          220,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          final heights = [280.0, 340.0, 300.0, 380.0, 320.0, 290.0];
          final height = heights[index % heights.length];
          return Container(
            height: height,
            decoration: BoxDecoration(
              color: theme.bgCard,
              borderRadius: BorderRadius.circular(VoidDesign.radiusXL),
              border: Border.all(color: theme.textPrimary.withValues(alpha: 0.05)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image area
                Container(
                  height: height * 0.6,
                  color: theme.textPrimary.withValues(alpha: 0.05),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Container(
                          width: double.infinity,
                          height: 12,
                          decoration: BoxDecoration(
                            color: theme.textPrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tags row
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 10,
                              decoration: BoxDecoration(
                                color: theme.textPrimary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 30,
                              height: 10,
                              decoration: BoxDecoration(
                                color: theme.textPrimary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Metadata area
                        Container(
                          width: 60,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.textPrimary.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
