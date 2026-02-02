import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/haptic_service.dart';
import '../widgets/void_dialog.dart';
import 'empty_state.dart';
import 'messy_card.dart';
import 'void_header.dart';
import 'manual_entry_overlay.dart';

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
    _searchCtrl.addListener(_onSearch);
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

  Future<void> _onSearch() async {
    final query = _searchCtrl.text.toLowerCase();
    final items = await VoidStore.search(query);
    if (!mounted) return;
    setState(() {
      _filteredItems = items;
    });
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
      _load();
      _searchFocusNode.unfocus();
    }
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
        backgroundColor: Colors.black,
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
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black,
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
                  child: VoidHeader(blurOpacity: blurValue),
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
    if (_loading) return const Center(child: CircularProgressIndicator(strokeWidth: 1, color: Colors.white24));

    if (_allItems.isEmpty && _searchCtrl.text.isEmpty) {
      return VoidEmptyState();
    }
    if (_filteredItems.isEmpty && _searchCtrl.text.isNotEmpty) {
      return Center(
        child: Text(
          "NO MATCHES FOR '${_searchCtrl.text}'",
          style: GoogleFonts.ibmPlexMono(color: Colors.white24, fontSize: 12, letterSpacing: 1),
        ),
      );
    }

    return MasonryGridView.count(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      padding: const EdgeInsets.fromLTRB(16, 140, 16, 220),
      itemCount: _filteredItems.length,
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
        );
      },
    );
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
      height: 60, // 🔥 Adjusted height for squircle look
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _isSelectionMode ? Colors.white : const Color(0xFF161616),
        // 🔥 Adjusted borderRadius for squircle look
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
        // 🔥 Changed shape to BoxShape.circle for a perfect circle
        color: _isSelectionMode ? Colors.redAccent : const Color(0xFF161616),
        shape: BoxShape.circle, // Use BoxShape.circle for perfect circle
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

          // DELETE ICON
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isSelectionMode ? 1.0 : 0.0,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutQuart,
              alignment: _isSelectionMode ? Alignment.center : const Alignment(0, 6.0),
              child: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
                onPressed: _confirmDelete,
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