// ui/home/messy_card.dart
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/void_item.dart';
import '../../services/haptic_service.dart';
import 'item_detail_screen.dart';

class MessyCard extends StatefulWidget {
  final VoidItem item;
  final VoidCallback onUpdate;
  final bool isSelected;
  final bool isSelectionMode;
  final Function(String) onSelect;
  final FocusNode searchFocusNode;
  final int index;

  const MessyCard({
    super.key,
    required this.item,
    required this.onUpdate,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onSelect,
    required this.searchFocusNode,
    this.index = 0,
  });

  @override
  State<MessyCard> createState() => _MessyCardState();
}

class _MessyCardState extends State<MessyCard> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    
    // Staggered entrance delay based on index
    Future.delayed(Duration(milliseconds: 50 * widget.index.clamp(0, 10)), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  bool _isLocalPath(String path) {
    return path.startsWith('/') || path.startsWith('file://');
  }

  bool _isFileType(String type) {
    return type == 'image' || type == 'pdf' || type == 'document' || type == 'file' || type == 'video';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'link':
        return Icons.link;
      case 'image':
        return Icons.image_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'document':
        return Icons.description_rounded;
      case 'file':
        return Icons.insert_drive_file_rounded;
      case 'video':
        return Icons.video_file_rounded;
      case 'social':
        return Icons.share_rounded;
      default:
        return Icons.notes_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'link':
        return Colors.blueAccent;
      case 'image':
        return Colors.tealAccent;
      case 'pdf':
        return Colors.redAccent;
      case 'document':
        return Colors.orangeAccent;
      case 'video':
        return Colors.purpleAccent;
      case 'social':
        return Colors.pinkAccent;
      default:
        return Colors.white54;
    }
  }

  Widget _buildImagePreview(String imageUrl) {
    if (widget.item.type == 'link') {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildActualImage(imageUrl, BoxFit.cover),
      );
    }
    // For images/screenshots, we allow flexible height to prevent cropping
    return _buildActualImage(imageUrl, BoxFit.fitWidth);
  }

  Widget _buildActualImage(String imageUrl, BoxFit fit) {
    if (_isLocalPath(imageUrl)) {
      final file = File(imageUrl);
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFileTypePreview(widget.item.type),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 300),
        // Use higher disk cache limits for screenshots
        maxWidthDiskCache: 1000,
        maxHeightDiskCache: 2000,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            // If it's a link, AspectRatio handles height. 
            // If it's an image, we provide a tall "average" placeholder to reduce jump.
            height: widget.item.type == 'link' ? null : 280,
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => _buildFileTypePreview(widget.item.type),
      );
    }
  }

  Widget _buildFileTypePreview(String type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'image':
        icon = Icons.image_rounded;
        color = Colors.tealAccent;
        break;
      case 'pdf':
        icon = Icons.picture_as_pdf_rounded;
        color = Colors.redAccent;
        break;
      case 'document':
        icon = Icons.description_rounded;
        color = Colors.orangeAccent;
        break;
      case 'video':
        icon = Icons.video_file_rounded;
        color = Colors.purpleAccent;
        break;
      case 'social':
        icon = Icons.share_rounded;
        color = Colors.pinkAccent;
        break;
      default:
        icon = Icons.insert_drive_file_rounded;
        color = Colors.grey;
    }
    
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 40,
          color: color.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rnd = Random(widget.item.id.hashCode);
    final double bottomStagger = 4.0 + rnd.nextInt(8);
    final typeColor = _getColorForType(widget.item.type);

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () {
          widget.searchFocusNode.unfocus();
          HapticService.medium();
          widget.onSelect(widget.item.id);
        },
        onTap: () {
          widget.searchFocusNode.unfocus();
          if (widget.isSelectionMode) {
            HapticService.light();
            widget.onSelect(widget.item.id);
          } else {
            HapticService.light();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => 
                  ItemDetailScreen(item: widget.item, onDelete: widget.onUpdate),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                      ),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        },
        child: AnimatedScale(
          scale: widget.isSelected ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 100),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected
                    ? typeColor.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.06),
                width: widget.isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                if (widget.isSelected)
                  BoxShadow(
                    color: typeColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Stack(
              children: [
                Opacity(
                  opacity: widget.isSelected ? 0.5 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image preview with gradient overlay
                      if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: _buildImagePreview(widget.item.imageUrl!),
                            ),
                            // Gradient overlay at bottom of image
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF141414),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Type badge on image
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getIconForType(widget.item.type),
                                      size: 10,
                                      color: typeColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.item.type.toUpperCase(),
                                      style: GoogleFonts.ibmPlexMono(
                                        color: typeColor,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (_isFileType(widget.item.type))
                        _buildFileTypePreview(widget.item.type),
                      
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          14, 
                          widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty ? 8 : 14, 
                          14, 
                          0
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // URL host for links (only when no image)
                            if (widget.item.type == 'link' && (widget.item.imageUrl == null || widget.item.imageUrl!.isEmpty))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      Uri.parse(widget.item.content).host.replaceFirst('www.', '').toLowerCase(),
                                      style: GoogleFonts.ibmPlexMono(
                                        color: Colors.blueAccent.withValues(alpha: 0.7),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Title
                            Text(
                              widget.item.title.isEmpty ? "Untitled Fragment" : widget.item.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.ibmPlexSans(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                            


                            // Tags
                            if (widget.item.tags.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: widget.item.tags.take(3).map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: typeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: GoogleFonts.ibmPlexMono(
                                        color: typeColor.withValues(alpha: 0.8),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Footer with date (type badge moved to image)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                        child: Row(
                          children: [
                            // Show type icon only if no image
                            if (widget.item.imageUrl == null || widget.item.imageUrl!.isEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _getIconForType(widget.item.type),
                                  size: 10,
                                  color: typeColor.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _formatDate(widget.item.createdAt),
                              style: GoogleFonts.ibmPlexMono(
                                color: Colors.white.withValues(alpha: 0.25),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: bottomStagger),
                    ],
                  ),
                ),
                
                // Selection checkmark
                if (widget.isSelected)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: typeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: typeColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }
}
