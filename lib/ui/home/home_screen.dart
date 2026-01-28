import 'package:flutter/material.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'empty_state.dart';
import 'messy_card.dart';
import 'void_header.dart';

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
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredItems = _allItems.where((item) {
        return item.title.toLowerCase().contains(query) || 
               item.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // CONTENT
          if (_loading)
            const SizedBox() // Wait for loading
          else if (_allItems.isEmpty)
            const Center(child: VoidEmptyState())
          else
            _buildGrid(),

          // HEADER
          const Positioned(top: 0, left: 0, right: 0, child: VoidHeader()),

          // SEARCH BAR (Only if items exist)
          if (_allItems.isNotEmpty)
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: _buildSearchBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final displayItems = _isSearching ? _filteredItems : _allItems;
    
    return GridView.builder(
      // 🔥 FIX: Increased Top Padding to prevent overlap with Header
      padding: const EdgeInsets.fromLTRB(16, 140, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75, // Taller cards for more data
      ),
      itemCount: displayItems.length,
      itemBuilder: (_, i) => MessyCard(
        key: ValueKey(displayItems[i].id),
        item: displayItems[i],
        onUpdate: _load,
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)],
      ),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "search the void...",
          hintStyle: TextStyle(color: Colors.white24),
          prefixIcon: Icon(Icons.search, color: Colors.white24),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}