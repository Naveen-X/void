import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/haptic_service.dart';
import 'package:void_space/services/rag_service.dart';
import '../widgets/void_dialog.dart';
import 'empty_state.dart';
import 'messy_card.dart';
import 'void_header.dart';
import 'manual_entry_overlay.dart';
import '../theme/void_design.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<VoidItem> _allItems = [];
  List<VoidItem> _filteredItems = [];
  bool _loading = true;

  // SELECTION STATE
  final Set<String> _selectedIds = {};
  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  // TAG FILTERING STATE
  final Set<String> _selectedTags = {};
  List<String> _availableTags = [];

  // CONTROLLERS & NODES
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final ValueNotifier<double> _headerBlurNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _searchCtrl.addListener(_applyFilters);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _headerBlurNotifier.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double newBlur = (_scrollCtrl.offset / 60).clamp(0.0, 1.0);
    if (_headerBlurNotifier.value != newBlur) {
      _headerBlurNotifier.value = newBlur;
    }
  }

  void _extractAvailableTags() {
    final Set<String> tags = {};
    for (final item in _allItems) {
      tags.addAll(item.tags);
    }
    _availableTags = tags.toList()..sort();
  }

  Future<void> _applyFilters() async {
    final query = _searchCtrl.text.trim();
    
    // 1. Always get text search results (fast & reliable)
    final textResults = _textSearch(query);
    
    // 2. Try to get semantic results if ready
    if (query.length >= 3 && RagService.isInitialized) {
      final semanticItems = await VoidStore.semanticSearch(query);
      
      setState(() {
        // Use a Set to merge unique items, preserving semantic order where possible
        final mergedSet = <String>{};
        final mergedList = <VoidItem>[];
        
        // Add semantic results first (usually more relevant)
        for (var item in semanticItems) {
          if (mergedSet.add(item.id)) {
            // Apply tag filter if active
            final matchesTags = _selectedTags.isEmpty ||
                item.tags.any((tag) => _selectedTags.contains(tag));
            if (matchesTags) mergedList.add(item);
          }
        }
        
        // Add text results that weren't captured by semantic search
        for (var item in textResults) {
          if (mergedSet.add(item.id)) {
            mergedList.add(item);
          }
        }
        
        _filteredItems = mergedList;
      });
    } else {
      setState(() {
        _filteredItems = textResults;
      });
    }
  }

  List<VoidItem> _textSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return _allItems.where((item) {
      final matchesSearch = query.isEmpty ||
          item.title.toLowerCase().contains(lowerQuery) ||
          (item.summary?.toLowerCase().contains(lowerQuery) ?? false) ||
          item.content.toLowerCase().contains(lowerQuery) ||
          item.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      
      final matchesTags = _selectedTags.isEmpty ||
          item.tags.any((tag) => _selectedTags.contains(tag));
      
      return matchesSearch && matchesTags;
    }).toList();
  }

  void _toggleTag(String tag) {
    HapticService.light();
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
    _applyFilters();
  }

  void _clearTagFilters() {
    HapticService.light();
    setState(() => _selectedTags.clear());
    _applyFilters();
  }

  Widget _buildSkeletonGrid() {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 56 + (_availableTags.isNotEmpty ? 52 : 0);
    
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
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
              color: Colors.black,
              borderRadius: BorderRadius.circular(VoidDesign.radiusXL),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image area
                Container(
                  height: height * 0.6,
                  color: Colors.white.withValues(alpha: 0.05),
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
                            color: Colors.white.withValues(alpha: 0.08),
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
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 30,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
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
                            color: Colors.white.withValues(alpha: 0.03),
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

  void _toggleSelection(String id) {
    _searchFocusNode.unfocus();
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _load() async {
    final items = await VoidStore.all();
    if (!mounted) return;
    setState(() {
      _allItems = items;
      _filteredItems = items;
      _loading = false;
    });
    _extractAvailableTags();
  }

  Future<void> _confirmDelete() async {
    HapticService.warning();
    final bool? confirm = await VoidDialog.show(
      context: context,
      title: "PURGE ${_selectedIds.length} FRAGMENTS?",
      message: "This action will permanently erase these items from your local vault.",
      confirmText: "PURGE",
    );

    if (confirm == true) {
      HapticService.heavy();
      await VoidStore.deleteMany(_selectedIds);
      setState(() => _selectedIds.clear());
      _load();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAndLoad();
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _refreshAndLoad() async {
    await VoidStore.refresh();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0;

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isSelectionMode) {
          HapticService.light();
          setState(() => _selectedIds.clear());
        }
      },
      child: Scaffold(
        backgroundColor: VoidDesign.bgPrimary,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            _buildMainContent(),

            Positioned(
              bottom: 0, left: 0, right: 0, height: 240,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        VoidDesign.bgPrimary.withValues(alpha: 0.8),
                        VoidDesign.bgPrimary,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            ValueListenableBuilder<double>(
              valueListenable: _headerBlurNotifier,
              builder: (context, blurValue, _) {
                return Positioned(
                  top: 0, left: 0, right: 0,
                  child: VoidHeader(
                    blurOpacity: blurValue,
                    availableTags: _availableTags.toList(),
                    selectedTags: _selectedTags,
                    onClearFilters: _clearTagFilters,
                    onToggleTag: _toggleTag,
                    getTagColor: _getTagColor,
                  ),
                );
              },
            ),

            if (!_loading)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutQuart,
                bottom: (isKeyboardOpen ? keyboardHeight + 16 : MediaQuery.of(context).padding.bottom + 24),
                left: 20,
                right: 20,
                child: _buildBottomControls(isKeyboardOpen),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_loading) return _buildSkeletonGrid();

    if (_allItems.isEmpty && _searchCtrl.text.isEmpty) {
      return const VoidEmptyState();
    }
    if (_filteredItems.isEmpty && (_searchCtrl.text.isNotEmpty || _selectedTags.isNotEmpty)) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.white10),
            const SizedBox(height: 16),
            Text(
              _searchCtrl.text.isNotEmpty 
                ? "NO MATCHES FOR '${_searchCtrl.text}'"
                : "NO ITEMS WITH SELECTED TAGS",
              style: GoogleFonts.ibmPlexMono(color: Colors.white24, fontSize: 11, letterSpacing: 1),
            ),
            if (_selectedTags.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _clearTagFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    "CLEAR FILTERS",
                    style: GoogleFonts.ibmPlexMono(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Main scrollable content - tags are now in header
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 56 + (_availableTags.isNotEmpty ? 52 : 0);
    
    return RefreshIndicator(
      onRefresh: _load,
      color: Colors.white,
      backgroundColor: VoidDesign.bgCard,
      strokeWidth: 2,
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              VoidDesign.pageHorizontal, 
              headerHeight + VoidDesign.spaceMD, 
              VoidDesign.pageHorizontal, 
              VoidDesign.spaceMD,
            ),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: VoidDesign.spaceMD,
              crossAxisSpacing: VoidDesign.spaceMD,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return MessyCard(
                  key: ValueKey(item.id),
                  item: item,
                  onUpdate: _load,
                  isSelected: _selectedIds.contains(item.id),
                  isSelectionMode: _isSelectionMode,
                  onSelect: _toggleSelection,
                  searchFocusNode: _searchFocusNode,
                  index: index,
                );
              },
              childCount: _filteredItems.length,
            ),
          ),
          
          // Abyss Footer
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                HapticService.light();
                _refreshAndLoad();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 160),
                child: Column(
                  children: [
                    Container(
                      width: 2,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "VOID SPACE",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 6.0,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
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





  Color _getTagColor(String tag) {
    final hash = tag.hashCode.abs();
    final colors = [
      Colors.blueAccent,
      Colors.tealAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.cyanAccent,
      Colors.greenAccent,
      Colors.amberAccent,
    ];
    return colors[hash % colors.length];
  }


  Widget _buildBottomControls(bool isKeyboardOpen) {
    if (_allItems.isEmpty && _searchCtrl.text.isEmpty) {
      return Align(
        alignment: Alignment.centerRight,
        child: _buildRollingActionButton(isKeyboardOpen),
      );
    }

    return Row(
      children: [
        Expanded(child: _buildRollingMainPill(isKeyboardOpen)),
        if (!isKeyboardOpen) ...[
          const SizedBox(width: 12),
          _buildRollingActionButton(isKeyboardOpen),
        ]
      ],
    );
  }

  Widget _buildRollingMainPill(bool isKeyboardOpen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
      height: 60,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _isSelectionMode ? Colors.white : const Color(0xFF161616),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _isSelectionMode ? Colors.white : Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: _isSelectionMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.4),
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
            alignment: _isSelectionMode ? const Alignment(0, -6.0) : Alignment.center,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isSelectionMode ? 0.0 : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.white.withValues(alpha: 0.2), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        focusNode: _searchFocusNode,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          hintText: "Search the void...",
                          hintStyle: TextStyle(color: Colors.white10),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          HapticService.light();
                          _searchCtrl.clear();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white70, size: 14),
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
            alignment: _isSelectionMode ? Alignment.center : const Alignment(0, 6.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isSelectionMode ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "${_selectedIds.length} SELECTED",
                      style: GoogleFonts.ibmPlexMono(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticService.light();
                        setState(() => _selectedIds.clear());
                      },
                      child: Text("CANCEL", style: GoogleFonts.ibmPlexMono(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _buildRollingActionButton(bool isKeyboardOpen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
      width: 60, height: 60,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _isSelectionMode ? Colors.redAccent : const Color(0xFF161616),
        shape: BoxShape.circle,
        border: Border.all(
          color: _isSelectionMode ? Colors.redAccent : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isSelectionMode ? Colors.redAccent.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.4),
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
            opacity: _isSelectionMode ? 0.0 : 1.0,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutQuart,
              alignment: _isSelectionMode ? const Alignment(0, -6.0) : Alignment.center,
              child: IgnorePointer(
                ignoring: _isSelectionMode,
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white70, size: 28),
                  onPressed: () {
                    _searchFocusNode.unfocus();
                    HapticService.light();
                    _showManualEntry();
                  },
                ),
              ),
            ),
          ),

          // DELETE ICON
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isSelectionMode ? 1.0 : 0.0,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutQuart,
              alignment: _isSelectionMode ? Alignment.center : const Alignment(0, 6.0),
              child: IgnorePointer(
                ignoring: !_isSelectionMode,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
                  onPressed: _confirmDelete,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManualEntryOverlay(onSave: _load),
    );
  }
}
