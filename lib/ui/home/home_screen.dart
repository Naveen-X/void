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

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  List<VoidItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 🔄 Reload when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  /// 📖 Always read from disk (JSON is truth)
  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final items = await VoidStore.all();

    if (!mounted) return;

    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── CONTENT ─────────────────────────────
          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.2,
                color: Colors.white70,
              ),
            )
          else if (_items.isEmpty)
            const Center(
              child: VoidEmptyState(),
            )
          else
            GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                96, // header space
                16,
                120, // bottom space
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  child: MessyCard(
                    key: ValueKey(item.id),
                    item: item,
                  ),
                );
              },
            ),

          // ─── HEADER ──────────────────────────────
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: VoidHeader(),
          ),
        ],
      ),
    );
  }
}
