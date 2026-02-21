// lib/ui/home/controllers/home_controller.dart
// Controller for Home Screen logic

import 'package:flutter/material.dart';
import 'package:void_space/app/feature_flags.dart';
import 'package:void_space/data/models/void_item.dart';
import 'package:void_space/data/stores/void_store.dart';
import 'package:void_space/services/haptic_service.dart';
import 'package:void_space/services/rag_service.dart';
import 'package:void_space/ui/widgets/void_dialog.dart';

class HomeController extends ChangeNotifier {
  // DATA STATE
  List<VoidItem> _allItems = [];
  List<VoidItem> _filteredItems = [];
  bool _loading = true;
  
  List<VoidItem> get filteredItems => _filteredItems;
  bool get loading => _loading;
  bool get isEmpty => _allItems.isEmpty;

  // SELECTION STATE
  final Set<String> _selectedIds = {};
  bool get isSelectionMode => _selectedIds.isNotEmpty;
  Set<String> get selectedIds => _selectedIds;
  int get selectedCount => _selectedIds.length;

  // TAG FILTERING STATE
  final Set<String> _selectedTags = {};
  List<String> _availableTags = [];
  
  Set<String> get selectedTags => _selectedTags;
  List<String> get availableTags => _availableTags;

  // SEARCH STATE
  String _currentQuery = '';

  HomeController() {
    _load();
  }

  Future<void> _load() async {
    final items = await VoidStore.all();
    _allItems = items;
    _filteredItems = items;
    _loading = false;
    _extractAvailableTags();
    notifyListeners();
    // Re-apply filters if query exists
    if (_currentQuery.isNotEmpty || _selectedTags.isNotEmpty) {
      applyFilters(_currentQuery);
    }
  }

  Future<void> refresh() async {
    await VoidStore.refresh();
    await _load();
  }

  void _extractAvailableTags() {
    final Set<String> tags = {};
    for (final item in _allItems) {
      tags.addAll(item.tags);
    }
    _availableTags = tags.toList()..sort();
  }

  Future<void> applyFilters(String query) async {
    _currentQuery = query.trim();
    
    // 1. Always get text search results (fast & reliable)
    final textResults = _textSearch(_currentQuery);
    
    // 2. Try to get semantic results if AI is enabled and ready
    if (isAiEnabled && _currentQuery.length >= 3 && RagService.isInitialized) {
      final semanticItems = await VoidStore.semanticSearch(_currentQuery);
      
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
    } else {
      _filteredItems = textResults;
    }
    notifyListeners();
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

  void toggleTag(String tag) {
    HapticService.light();
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    applyFilters(_currentQuery);
    notifyListeners();
  }

  void clearTagFilters() {
    HapticService.light();
    _selectedTags.clear();
    applyFilters(_currentQuery);
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }
  
  void clearSelection() {
    HapticService.light();
    _selectedIds.clear();
    notifyListeners();
  }

  Future<void> deleteSelected(BuildContext context) async {
    HapticService.warning();
    final bool? confirm = await VoidDialog.show(
      context: context,
      title: "TRASH ${_selectedIds.length} ITEMS?",
      message: "These items will be moved to the Trash bin.",
      confirmText: "TRASH",
    );

    if (confirm == true) {
      HapticService.heavy();
      await VoidStore.deleteMany(_selectedIds);
      _selectedIds.clear();
      await _load(); // Reload to update list
    }
  }
}
