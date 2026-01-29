import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/haptic_service.dart';
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

  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
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
    super.dispose();
  }

  void _onScroll() {
    final double newBlur = (_scrollCtrl.offset / 60).clamp(0.0, 1.0);
    if (_headerBlurNotifier.value != newBlur) {
      _headerBlurNotifier.value = newBlur;
    }
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems.where((item) {
        return item.title.toLowerCase().contains(query) || 
               item.content.toLowerCase().contains(query) ||
               item.summary.toLowerCase().contains(query);
      }).toList();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Calculate keyboard height
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // 1. MAIN CONTENT
          _buildMainContent(),

          // 🔥 2. BOTTOM VIGNETTE (Immersive shadow behind search)
          if (_allItems.isNotEmpty)
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: 200,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
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

          // 3. THE HEADER
          ValueListenableBuilder<double>(
            valueListenable: _headerBlurNotifier,
            builder: (context, blurValue, _) {
              return Positioned(
                top: 0, left: 0, right: 0,
                child: VoidHeader(blurOpacity: blurValue),
              );
            },
          ),

          // 4. BOTTOM CONTROLS (Lifted by keyboard)
          if (!_loading && _allItems.isNotEmpty)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              // 🔥 Lift logic: base padding + keyboard height
              bottom: (keyboardHeight > 0 ? keyboardHeight + 10 : MediaQuery.of(context).padding.bottom + 24),
              left: 20,
              right: 20,
              child: _buildBottomBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_loading) return const Center(child: CircularProgressIndicator(strokeWidth: 1, color: Colors.white24));
    if (_allItems.isEmpty) return const VoidEmptyState();

    return MasonryGridView.count(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      padding: const EdgeInsets.fromLTRB(16, 140, 16, 180),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) => MessyCard(
        key: ValueKey(_filteredItems[index].id),
        item: _filteredItems[index],
        onUpdate: _load,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 12))
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white.withValues(alpha: 0.2), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: "Search the void...",
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.1)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            HapticService.light();
            _showManualEntry();
          },
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.white.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 8))
              ],
            ),
            child: const Icon(Icons.add, color: Colors.black, size: 28),
          ),
        ),
      ],
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