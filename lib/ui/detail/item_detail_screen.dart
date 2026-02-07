// lib/ui/detail/item_detail_screen.dart
// Refactored Item Detail Screen

import 'dart:async';
import 'dart:io';
import 'dart:ui'; // For ImageFilter
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart'; // For sharing

import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/haptic_service.dart';
import 'package:void_space/services/ai_service.dart';
import 'package:void_space/ui/theme/void_design.dart';
import 'package:void_space/ui/theme/void_theme.dart';
import 'package:void_space/ui/utils/type_helpers.dart';
import 'package:void_space/ui/widgets/void_dialog.dart';

// Components

import 'components/detail_metadata.dart';
import 'components/edit_item_form.dart';
import 'components/link_card.dart';
import 'components/summary_section.dart';
import 'components/detail_actions.dart';

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

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late VoidItem _editedItem;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditMode = false;
  bool _isNoteType = false;
  
  // AI & Similar Items State
  bool _isGeneratingAI = false;

  // Tags State
  late List<String> _editedTags;

  @override
  void initState() {
    super.initState();
    _editedItem = widget.item;
    _isNoteType = _editedItem.type == 'note';
    _editedTags = List.from(_editedItem.tags);
    
    _titleController = TextEditingController(text: _editedItem.title);
    _contentController = TextEditingController(text: _editedItem.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    if (_isEditMode) {
      _saveChanges();
    } else {
      setState(() => _isEditMode = true);
      HapticService.light();
    }
  }

  Future<void> _saveChanges() async {
    final newTitle = _titleController.text.trim();
    final newContent = _contentController.text.trim();

    if (newTitle.isEmpty) return;

    final updatedItem = _editedItem.copyWith(
      title: newTitle,
      content: newContent,
    );

    await VoidStore.update(updatedItem);
    
    if (mounted) {
      setState(() {
        _editedItem = updatedItem;
        _isEditMode = false;
      });
      HapticService.success();
    }
  }

  Future<void> _addTag(String tag) async {
    if (!_editedTags.contains(tag)) {
      setState(() => _editedTags.add(tag));
      HapticService.light();
    }
  }

  Future<void> _removeTag(String tag) async {
    setState(() => _editedTags.remove(tag));
  }

  Future<void> _saveTagsOnly(List<String> tags) async {
      // Updates state and persists to store immediately
      // This is used for direct tag manipulation outside full edit mode
      final updatedItem = _editedItem.copyWith(tags: tags);
      await VoidStore.update(updatedItem);
      setState(() {
          _editedItem = updatedItem;
          _editedTags = tags;
      });
      widget.onDelete(); // Trigger refresh on parent
  }

  void _openFile(String path) {
    // Basic implementation for now, or just placeholder if platform logic is elsewhere
    // In previous code it was just a placeholder or used platform channels
  }

  Future<void> _confirmDelete(BuildContext context) async {
    HapticService.warning();
    final confirmed = await VoidDialog.show(
      context: context,
      title: 'Delete Item?',
      message: 'This action cannot be undone. The item will be lost in the void forever.',
      confirmText: 'Delete',
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed == true) {
      await VoidStore.delete(widget.item.id);
      HapticService.heavy();
      
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      widget.onDelete();
    }
  }



  void _showShareMenu() {
    final theme = VoidTheme.of(context);
    HapticService.medium();
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.textPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SHARE AS',
              style: GoogleFonts.ibmPlexMono(
                color: theme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            _buildShareOption(
              icon: Icons.picture_as_pdf_rounded,
              label: 'PDF Document',
              onTap: () {
                Navigator.pop(context);
                _shareAsPdf();
              },
            ),
            const SizedBox(height: 12),
            _buildShareOption(
              icon: Icons.html_rounded,
              label: 'HTML File',
              onTap: () {
                Navigator.pop(context);
                _shareAsHtml();
              },
            ),
            const SizedBox(height: 12),
            _buildShareOption(
              icon: Icons.text_fields_rounded,
              label: 'Plain Text',
              onTap: () {
                Navigator.pop(context);
                _shareAsText();
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = VoidTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.textPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.textPrimary, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: theme.textPrimary.withValues(alpha: 0.24), size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _shareAsPdf() async {
    // TODO: Implement PDF generation
    HapticService.light();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting as PDF... (Coming Soon)')),
    );
  }

  Future<void> _shareAsHtml() async {
    // TODO: Implement HTML generation
    HapticService.light();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting as HTML... (Coming Soon)')),
    );
  }

  Future<void> _shareAsText() async {
    final String shareText = '${_editedItem.title}\n\n${_editedItem.content}';
    if (_editedItem.type == 'link') {
       // ignore: deprecated_member_use
       await Share.share('${_editedItem.title}\n${_editedItem.content}');
    } else {
       // ignore: deprecated_member_use
       await Share.share(shareText);
    }
  }

  Future<void> _generateAIContext() async {
    setState(() => _isGeneratingAI = true);
    HapticService.medium();

    try {
      final context = await AIService.analyze(_editedItem.title, _editedItem.content);
      
      final updatedItem = _editedItem.copyWith(
        summary: context.summary,
        tldr: context.tldr,
      );
      
      await VoidStore.update(updatedItem);
      
      if (mounted) {
        setState(() {
          _editedItem = updatedItem;
          _isGeneratingAI = false;
        });
        HapticService.success();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingAI = false);
        HapticService.heavy();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'AI Generation Failed: ${e.toString()}',
              style: GoogleFonts.ibmPlexMono(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    return Scaffold(
      backgroundColor: theme.bgPrimary,
      body: Stack(
        children: [
          // 1. Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24, 
                    right: 24, 
                    bottom: 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Image (if exists)
                      _buildHeaderImage(),
                      
                      // Spacer if no image, to prevent text overlapping buttons
                      if (_editedItem.imageUrl == null || _editedItem.imageUrl!.isEmpty)
                         SizedBox(height: MediaQuery.of(context).padding.top + 64),

                      // Title Section
                      if (_isEditMode)
                        EditItemForm(
                          titleController: _titleController,
                          contentController: _contentController,
                          isNoteType: _isNoteType,
                        )
                      else
                        Text(
                          _editedItem.title,
                          style: GoogleFonts.ibmPlexSans(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),

                      const SizedBox(height: VoidDesign.spaceLG),
                      
                      // Metadata & Tags
                      DetailMetadata(
                        item: _editedItem,
                        tags: _editedTags,
                        onAddTag: (tag) async {
                            await _addTag(tag);
                            await _saveTagsOnly(_editedTags);
                        },
                        onRemoveTag: _removeTag,
                        onSaveTags: _saveTagsOnly,
                      ),

                      const SizedBox(height: VoidDesign.space2XL),

                      // Dynamic Content Area
                      if (_isEditMode && _isNoteType)
                         // Content handled in EditItemForm above
                         const SizedBox.shrink()
                         
                      else if (_editedItem.type == 'link') ...[
                        LinkCard(item: _editedItem),
                        if ((_editedItem.summary?.isNotEmpty ?? false) || (_editedItem.tldr?.isNotEmpty ?? false)) ...[
                          const SizedBox(height: VoidDesign.spaceXL),
                          SummarySection(
                            item: _editedItem,
                            isGenerating: _isGeneratingAI,
                            onGenerate: _generateAIContext,
                          ),
                        ]
                      ] else ...[
                         _buildContentSection(),
                      ],

                      if (isFileType(_editedItem.type)) ...[
                         const SizedBox(height: VoidDesign.spaceXL),
                         DetailActions.buildOpenFileButton(
                           _editedItem, 
                           () => _openFile(_editedItem.content)
                         ),
                      ],

                      // Danger Zone (Only visible when not editing)
                      if (!_isEditMode) ...[
                        const SizedBox(height: 60),
                        _buildDeleteButton(context),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Floating Header Actions
          Positioned(
            top: 0, 
            left: 0, 
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticService.light();
                        Navigator.pop(context);
                        widget.onDelete(); // Trigger refresh on parent
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.bgCard.withValues(alpha: 0.3),
                              border: Border.all(color: theme.textPrimary.withValues(alpha: 0.1)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _toggleEditMode,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isEditMode 
                                  ? Colors.greenAccent.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.3),
                              border: Border.all(
                                color: _isEditMode ? Colors.greenAccent : Colors.white.withValues(alpha: 0.1)
                              ),
                            ),
                            child: Icon(
                              _isEditMode ? Icons.check_rounded : Icons.edit_rounded,
                              size: 20,
                              color: _isEditMode ? Colors.greenAccent : Colors.white,
                            ),
                          ),
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

  Widget _buildHeaderImage() {
    final theme = VoidTheme.of(context);
    if (_editedItem.imageUrl != null && _editedItem.imageUrl!.isNotEmpty) {
      return Container(
        height: 250,
        width: double.infinity,
        margin: EdgeInsets.only(
          bottom: 24,
          top: MediaQuery.of(context).padding.top + 54, // Increased clearance
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.textPrimary.withValues(alpha: 0.1)),
          color: theme.bgCard.withValues(alpha: 0.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: isLocalPath(_editedItem.imageUrl!)
            ? Image.file(File(_editedItem.imageUrl!), fit: BoxFit.cover)
            : CachedNetworkImage(
                imageUrl: _editedItem.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.white.withValues(alpha: 0.05)),
                errorWidget: (context, url, error) => Center(
                  child: Icon(Icons.image_not_supported_rounded, color: theme.textPrimary.withValues(alpha: 0.24), size: 40),
                ),
              ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildContentSection() {
    final theme = VoidTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: theme.textPrimary.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'CONTENT',
              style: GoogleFonts.ibmPlexMono(
                color: theme.textPrimary.withValues(alpha: 0.24),
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
            color: theme.textPrimary.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Text(
            _editedItem.content,
            style: GoogleFonts.ibmPlexSans(
              color: theme.textSecondary,
              fontSize: 15,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final theme = VoidTheme.of(context);
    return Column(
      children: [
        // Share Button (Top)
        GestureDetector(
          onTap: _showShareMenu,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: theme.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.textPrimary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ios_share_rounded, color: theme.textSecondary, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Share Item',
                  style: GoogleFonts.ibmPlexMono(
                    color: theme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Delete Button (Bottom)
        GestureDetector(
          onTap: () => _confirmDelete(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: theme.textPrimary.withValues(alpha: 0.02), // Slightly darker for delete
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.textPrimary.withValues(alpha: 0.2), // Subtle red border
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline_rounded, color: Colors.redAccent.withValues(alpha: 0.8), size: 20),
                const SizedBox(width: 12),
                Text(
                  'Delete Item',
                  style: GoogleFonts.ibmPlexMono(
                    color: Colors.redAccent.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Extra bottom padding for scrolling
        SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
      ],
    );
  }
}
