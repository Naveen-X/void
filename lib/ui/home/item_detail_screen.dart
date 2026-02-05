// ui/home/item_detail_screen.dart
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/haptic_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/void_dialog.dart';
import '../theme/void_design.dart';

class ItemDetailScreen extends StatefulWidget {
  final VoidItem item;
  final VoidCallback onDelete;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Edit mode
  bool _isEditMode = false;
  bool get _isNoteType => widget.item.type == 'note';
  late VoidItem _editedItem;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagInputController;
  late List<String> _editedTags;

  @override
  void initState() {
    super.initState();
    _editedItem = widget.item;
    _titleController = TextEditingController(text: widget.item.title);
    _contentController = TextEditingController(text: widget.item.content);
    _tagInputController = TextEditingController();
    _editedTags = List.from(widget.item.tags);
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    HapticService.light();
    setState(() {
      if (_isEditMode) {
        // Cancel edit - reset to original
        _titleController.text = widget.item.title;
        _contentController.text = widget.item.content;
        _editedTags = List.from(widget.item.tags);
      }
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _saveChanges() async {
    HapticService.medium();
    final updatedItem = widget.item.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      tags: _editedTags,
    );
    
    await VoidStore.update(updatedItem);
    _editedItem = updatedItem;
    
    setState(() {
      _isEditMode = false;
    });
    
    widget.onDelete(); // Refresh home screen
    HapticService.success();
  }

  void _addTag(String tag) {
    final trimmed = tag.trim().toLowerCase();
    if (trimmed.isNotEmpty && !_editedTags.contains(trimmed)) {
      setState(() {
        _editedTags.add(trimmed);
      });
      _tagInputController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _editedTags.remove(tag);
    });
  }

  bool _isLocalPath(String path) {
    return path.startsWith('/') || path.startsWith('file://');
  }

  bool _isFileType(String type) {
    return type == 'image' || type == 'pdf' || type == 'document' || type == 'file' || type == 'video';
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
      case 'note':
        return Colors.greenAccent;
      default:
        return Colors.white54;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'link':
        return Icons.link_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'document':
        return Icons.description_rounded;
      case 'video':
        return Icons.video_file_rounded;
      case 'note':
        return Icons.notes_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Future<void> _openFile(String path) async {
    HapticService.light();
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done) {
      debugPrint('Failed to open file: ${result.message}');
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    HapticService.warning();
    final bool? confirm = await VoidDialog.show(
      context: context,
      title: "ERASE FRAGMENT?",
      message: "This fragment will be permanently lost to the void.",
      confirmText: "ERASE",
      icon: Icons.delete_forever_rounded,
    );

    if (confirm == true) {
      HapticService.heavy();
      await VoidStore.delete(widget.item.id);
      widget.onDelete();
      if (context.mounted) Navigator.pop(context);
    }
  }


  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getColorForType(widget.item.type);
    
    return Scaffold(
      backgroundColor: VoidDesign.bgPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with image/icon
          SliverAppBar(
            expandedHeight: widget.item.imageUrl != null || _isFileType(widget.item.type) ? 300 : 120,
            backgroundColor: VoidDesign.bgPrimary,
            elevation: 0,
            pinned: true,
            stretch: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              // Edit button (only for notes)
              if (_isNoteType)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: IconButton(
                          icon: Icon(
                            _isEditMode ? Icons.check_rounded : Icons.edit_rounded,
                            color: _isEditMode ? Colors.greenAccent : Colors.white,
                            size: 20,
                          ),
                          onPressed: _isEditMode ? _saveChanges : _toggleEditMode,
                        ),
                      ),
                    ),
                  ),
                ),
              // Cancel (in edit mode) or Delete button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: IconButton(
                        icon: Icon(
                          _isEditMode ? Icons.close_rounded : Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: _isEditMode ? _toggleEditMode : () => _confirmDelete(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: _buildHeaderBackground(typeColor),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VoidDesign.pageHorizontal, 
                    vertical: VoidDesign.spaceXL
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge and date
                      _buildMetadataRow(typeColor),
                      
                      const SizedBox(height: VoidDesign.spaceXL),

                      // Title (editable only for notes)
                      (_isEditMode && _isNoteType)
                          ? _buildEditableTitle()
                          : Text(
                              _editedItem.title,
                              style: GoogleFonts.ibmPlexSans(
                                color: VoidDesign.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),

                      // Tags with inline add button (always visible)
                      const SizedBox(height: VoidDesign.spaceLG),
                      _buildInlineTagsWithAdd(typeColor),

                      const SizedBox(height: VoidDesign.space2XL),

                      // Content section (editable for notes in edit mode)
                      if (_isNoteType && _isEditMode)
                        _buildEditableContent()
                      else if (_editedItem.type == 'link') ...[
                        _buildLinkCard(),
                        if (!_isEditMode && _editedItem.summary.isNotEmpty) ...[
                          const SizedBox(height: VoidDesign.spaceXL),
                          _buildSummarySection(),
                        ],
                      ] else ...[
                        _buildContentSection(),
                      ],

                      // Open file button for file types
                      if (_isFileType(_editedItem.type)) ...[
                        const SizedBox(height: VoidDesign.spaceXL),
                        _buildOpenFileButton(typeColor),
                      ],

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(Color typeColor) {
    return Row(
      children: [
        // Type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: typeColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getIconForType(widget.item.type), size: 14, color: typeColor),
              const SizedBox(width: 6),
              Text(
                widget.item.type.toUpperCase(),
                style: GoogleFonts.ibmPlexMono(
                  color: typeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Date info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time_rounded, size: 12, color: Colors.white30),
              const SizedBox(width: 6),
              Text(
                _getTimeAgo(widget.item.createdAt),
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(Color typeColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _editedItem.tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              typeColor.withValues(alpha: 0.12),
              typeColor.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: typeColor.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: typeColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '#$tag',
          style: GoogleFonts.ibmPlexMono(
            color: typeColor.withValues(alpha: 0.9),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildInlineTagsWithAdd(Color typeColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Existing tags with remove on long press
        ..._editedTags.map((tag) => GestureDetector(
          onLongPress: () async {
            HapticService.warning();
            _removeTag(tag);
            await _saveTagsOnly();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  typeColor.withValues(alpha: 0.12),
                  typeColor.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: typeColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              '#$tag',
              style: GoogleFonts.ibmPlexMono(
                color: typeColor.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )),
        // Add tag button
        GestureDetector(
          onTap: () => _showAddTagDialog(typeColor),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  'tag',
                  style: GoogleFonts.ibmPlexMono(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveTagsOnly() async {
    final updatedItem = widget.item.copyWith(tags: _editedTags);
    await VoidStore.update(updatedItem);
    _editedItem = updatedItem;
    widget.onDelete(); // Refresh home screen
  }

  void _showAddTagDialog(Color typeColor) {
    _tagInputController.clear();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Tag',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.local_offer_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Add Tag',
                          style: GoogleFonts.ibmPlexSans(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Input field
                    TextField(
                      controller: _tagInputController,
                      autofocus: true,
                      style: GoogleFonts.ibmPlexMono(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Enter tag name...',
                        hintStyle: GoogleFonts.ibmPlexMono(
                          color: Colors.white24,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.tag_rounded,
                          color: Colors.white30,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onSubmitted: (value) async {
                        Navigator.pop(context);
                        if (value.trim().isNotEmpty) {
                          _addTag(value);
                          await _saveTagsOnly();
                        }
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.ibmPlexMono(
                                    color: Colors.white38,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              final value = _tagInputController.text;
                              if (value.trim().isNotEmpty) {
                                _addTag(value);
                                await _saveTagsOnly();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Add',
                                  style: GoogleFonts.ibmPlexMono(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLinkCard() {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        launchUrl(Uri.parse(widget.item.content));
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent.withValues(alpha: 0.08),
              Colors.blueAccent.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.open_in_new_rounded, color: Colors.blueAccent, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OPEN LINK',
                    style: GoogleFonts.ibmPlexMono(
                      color: Colors.blueAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexMono(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.blueAccent.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AI SUMMARY',
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.item.summary,
          style: GoogleFonts.ibmPlexSans(
            color: Colors.white70,
            fontSize: 15,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'CONTENT',
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Text(
            widget.item.content,
            style: GoogleFonts.ibmPlexSans(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildHeaderBackground(Color typeColor) {
    if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty) {
      if (_isLocalPath(widget.item.imageUrl!)) {
        final file = File(widget.item.imageUrl!);
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFileTypeHeader(typeColor),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ],
        );
      } else {
        return Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.item.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.white.withValues(alpha: 0.05),
              ),
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ],
        );
      }
    } else if (_isFileType(widget.item.type)) {
      return _buildFileTypeHeader(typeColor);
    }
    return null;
  }

  Widget _buildFileTypeHeader(Color typeColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            typeColor.withValues(alpha: 0.15),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForType(widget.item.type),
            size: 60,
            color: typeColor.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildOpenFileButton(Color typeColor) {
    String label;
    switch (widget.item.type) {
      case 'image':
        label = 'VIEW IMAGE';
        break;
      case 'pdf':
        label = 'OPEN PDF';
        break;
      case 'document':
        label = 'OPEN DOCUMENT';
        break;
      case 'video':
        label = 'PLAY VIDEO';
        break;
      default:
        label = 'OPEN FILE';
    }

    return GestureDetector(
      onTap: () => _openFile(widget.item.content),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              typeColor.withValues(alpha: 0.15),
              typeColor.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: typeColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconForType(widget.item.type), color: typeColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.ibmPlexMono(
                color: typeColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== EDIT MODE WIDGETS ======

  Widget _buildEditableTitle() {
    return TextField(
      controller: _titleController,
      style: GoogleFonts.ibmPlexSans(
        color: VoidDesign.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      maxLines: null,
      decoration: InputDecoration(
        hintText: 'Enter title...',
        hintStyle: GoogleFonts.ibmPlexSans(
          color: Colors.white24,
          fontSize: 24,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildEditableContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'CONTENT',
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contentController,
          style: GoogleFonts.ibmPlexSans(
            color: Colors.white70,
            fontSize: 15,
            height: 1.7,
          ),
          maxLines: null,
          minLines: 5,
          decoration: InputDecoration(
            hintText: 'Write your note...',
            hintStyle: GoogleFonts.ibmPlexSans(
              color: Colors.white24,
              fontSize: 15,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableTags(Color typeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._editedTags.map((tag) => GestureDetector(
                  onTap: () => _removeTag(tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#$tag',
                          style: GoogleFonts.ibmPlexMono(
                            color: typeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.close, size: 14, color: typeColor.withValues(alpha: 0.7)),
                      ],
                    ),
                  ),
                )),
            // Add tag input
            SizedBox(
              width: 120,
              child: TextField(
                controller: _tagInputController,
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white70,
                  fontSize: 11,
                ),
                decoration: InputDecoration(
                  hintText: '+ add tag',
                  hintStyle: GoogleFonts.ibmPlexMono(
                    color: Colors.white24,
                    fontSize: 11,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _addTag,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
