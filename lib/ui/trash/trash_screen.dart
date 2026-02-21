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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.restore_rounded, color: Colors.black87, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Item restored to home', 
                  style: GoogleFonts.ibmPlexSans(color: Colors.black87, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00F2AD),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          duration: const Duration(seconds: 2),
          elevation: 0,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Item permanently deleted', 
                    style: GoogleFonts.ibmPlexSans(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            duration: const Duration(seconds: 2),
            elevation: 0,
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

    return Scaffold(
      backgroundColor: theme.bgPrimary,
      appBar: AppBar(
        backgroundColor: theme.bgPrimary,
        scrolledUnderElevation: 0,
        title: Text(
          'Trash',
          style: GoogleFonts.ibmPlexMono(
            fontSize: 18,
            color: theme.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: theme.textPrimary),
        actions: [
          if (_trashItems.isNotEmpty)
            TextButton(
              onPressed: _emptyTrash,
              child: Text(
                'Empty',
                style: GoogleFonts.ibmPlexMono(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.textSecondary))
          : _trashItems.isEmpty
          ? _buildEmptyState(theme)
          : _buildTrashGrid(theme),
    );
  }

  Widget _buildEmptyState(VoidTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, size: 64, color: theme.textMuted),
          const SizedBox(height: 16),
          Text(
            "TRASH IS EMPTY",
            style: GoogleFonts.ibmPlexMono(
              color: theme.textTertiary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrashGrid(VoidTheme theme) {
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
          return Stack(
            children: [
              // Use MessyCard but disable its default tap interactions
              IgnorePointer(
                child: Opacity(
                  opacity: 0.6,
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
              // Overlay actions
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(VoidDesign.radiusMD),
                    onTap: () {
                      _showActionMenu(context, item, theme);
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

  void _showActionMenu(BuildContext context, VoidItem item, VoidTheme theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.restore_rounded,
                  color: Color(0xFF00F2AD),
                ),
                title: Text(
                  'Restore',
                  style: GoogleFonts.ibmPlexSans(color: theme.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _restoreItem(item);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.redAccent,
                ),
                title: Text(
                  'Delete Permanently',
                  style: GoogleFonts.ibmPlexSans(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deletePermanently(item);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
