/// Behavioral Patterns Controller - MVVM-C Architecture with GetX
///
/// PATTERN: Model-View-ViewModel-Coordinator (MVVM-C) with GetX
/// WHERE: Design Patterns feature - Behavioral patterns controller
/// HOW: Manages behavioral patterns state using GetX reactive programming
/// WHY: Provides reactive state management for complex behavioral pattern interactions
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/behavioral_patterns_page.dart';

/// GetX controller for behavioral patterns using MVVM-C architecture.
///
/// Manages state for behavioral patterns page with grid/list view toggles,
/// filtering, search, and favorites functionality.
class BehavioralPatternsController extends GetxController {
  // Reactive state variables
  final RxList<BehavioralPatternInfo> _allPatterns =
      <BehavioralPatternInfo>[].obs;
  final RxList<BehavioralPatternInfo> _filteredPatterns =
      <BehavioralPatternInfo>[].obs;
  final RxList<BehavioralPatternInfo> _favoritePatterns =
      <BehavioralPatternInfo>[].obs;

  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxBool _isGridView = true.obs;
  final RxString _selectedDifficulty = 'All'.obs;
  final RxString _searchQuery = ''.obs;

  // Getters
  List<BehavioralPatternInfo> get allPatterns => _allPatterns.toList();

  List<BehavioralPatternInfo> get filteredPatterns =>
      _filteredPatterns.toList();

  List<BehavioralPatternInfo> get favoritePatterns =>
      _favoritePatterns.toList();

  RxBool get isLoading => _isLoading;

  RxBool get hasError => _hasError;

  RxBool get isGridView => _isGridView;

  RxString get selectedDifficulty => _selectedDifficulty;

  RxBool get isFilterActive =>
      (_selectedDifficulty.value != 'All' || _searchQuery.value.isNotEmpty).obs;

  @override
  void onInit() {
    super.onInit();
    loadPatterns();
  }

  /// Load behavioral patterns data
  Future<void> loadPatterns() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 1000));

      // Load patterns data
      _allPatterns.value = _getBehavioralPatterns();
      _applyFilters();

      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      _hasError.value = true;
    }
  }

  /// Toggle between grid and list view
  void toggleViewMode() {
    _isGridView.value = !_isGridView.value;
  }

  /// Filter patterns by difficulty
  void filterByDifficulty(String difficulty) {
    _selectedDifficulty.value = difficulty;
    _applyFilters();
  }

  /// Search patterns by name or description
  void searchPatterns(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  /// Apply current filters and search
  void _applyFilters() {
    var filtered = _allPatterns.toList();

    // Apply difficulty filter
    if (_selectedDifficulty.value != 'All') {
      filtered = filtered
          .where((pattern) => pattern.difficulty == _selectedDifficulty.value)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered
          .where(
            (pattern) =>
                pattern.name.toLowerCase().contains(query) ||
                pattern.description.toLowerCase().contains(query),
          )
          .toList();
    }

    _filteredPatterns.value = filtered;
  }

  /// Clear all filters
  void clearFilters() {
    _selectedDifficulty.value = 'All';
    _searchQuery.value = '';
    _applyFilters();
  }

  /// Toggle pattern favorite status
  void toggleFavorite(BehavioralPatternInfo pattern) {
    if (_favoritePatterns.contains(pattern)) {
      _favoritePatterns.remove(pattern);
    } else {
      _favoritePatterns.add(pattern);
    }
  }

  /// Navigate to pattern detail
  void navigateToPattern(BehavioralPatternInfo pattern) {
    Get.toNamed(
      '/patterns/detail',
      arguments: {'patternType': pattern.name, 'category': 'behavioral'},
    );
  }

  /// Show filter dialog
  void showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter by difficulty:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['All', 'Beginner', 'Intermediate', 'Advanced']
                  .map(
                    (difficulty) => FilterChip(
                      label: Text(difficulty),
                      selected: _selectedDifficulty.value == difficulty,
                      onSelected: (selected) {
                        if (selected) {
                          filterByDifficulty(difficulty);
                        }
                        Get.back();
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              clearFilters();
              Get.back();
            },
            child: const Text('Clear All'),
          ),
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  /// Get behavioral patterns data
  List<BehavioralPatternInfo> _getBehavioralPatterns() {
    return [
      const BehavioralPatternInfo(
        name: 'Observer',
        description: 'Define a one-to-many dependency between objects',
        icon: Icons.visibility,
        difficulty: 'Intermediate',
        useCases: ['Event handling', 'Model-View updates', 'Notifications'],
        towerDefenseContext:
            'Tower observes enemy movements to auto-target and adjust firing patterns',
        communicationType: 'Event-driven',
      ),
      const BehavioralPatternInfo(
        name: 'Command',
        description: 'Encapsulate requests as objects',
        icon: Icons.play_arrow,
        difficulty: 'Intermediate',
        useCases: ['Undo/Redo', 'Macro recording', 'Queue operations'],
        towerDefenseContext:
            'Tower attack commands, upgrade commands, and wave control actions',
        communicationType: 'Action-based',
      ),
      const BehavioralPatternInfo(
        name: 'Strategy',
        description: 'Define algorithms and make them interchangeable',
        icon: Icons.timeline,
        difficulty: 'Beginner',
        useCases: [
          'Algorithm switching',
          'Payment methods',
          'Sorting strategies',
        ],
        towerDefenseContext:
            'Different AI strategies for enemies (aggressive, defensive, sneaky)',
        communicationType: 'Algorithm-based',
      ),
      const BehavioralPatternInfo(
        name: 'State',
        description:
            'Allow objects to alter behavior when internal state changes',
        icon: Icons.radio_button_checked,
        difficulty: 'Intermediate',
        useCases: ['State machines', 'Game states', 'UI states'],
        towerDefenseContext:
            'Tower states: idle, targeting, firing, reloading, upgrading',
        communicationType: 'State-driven',
      ),
      const BehavioralPatternInfo(
        name: 'Chain of Responsibility',
        description: 'Pass requests along a chain of handlers',
        icon: Icons.link,
        difficulty: 'Advanced',
        useCases: ['Request processing', 'Event bubbling', 'Middleware'],
        towerDefenseContext:
            'Damage calculation chain: base damage → tower upgrades → enemy armor',
        communicationType: 'Chain-based',
      ),
      const BehavioralPatternInfo(
        name: 'Mediator',
        description: 'Define how objects interact through a mediator',
        icon: Icons.hub,
        difficulty: 'Advanced',
        useCases: [
          'Component communication',
          'Dialog management',
          'UI coordination',
        ],
        towerDefenseContext:
            'Game mediator coordinates towers, enemies, UI, and scoring system',
        communicationType: 'Mediated',
      ),
      const BehavioralPatternInfo(
        name: 'Template Method',
        description: 'Define algorithm skeleton, let subclasses override steps',
        icon: Icons.dashboard_customize,
        difficulty: 'Intermediate',
        useCases: ['Algorithm templates', 'Framework extension', 'Code reuse'],
        towerDefenseContext:
            'Tower firing template: aim → charge → fire → cooldown with variations',
        communicationType: 'Template-based',
      ),
      const BehavioralPatternInfo(
        name: 'Visitor',
        description: 'Separate algorithms from object structure',
        icon: Icons.tour,
        difficulty: 'Advanced',
        useCases: [
          'Object traversal',
          'Operations on hierarchies',
          'Reporting',
        ],
        towerDefenseContext:
            'Different visitors for towers: upgrade calculator, range displayer, stats collector',
        communicationType: 'Visitor-based',
      ),
      const BehavioralPatternInfo(
        name: 'Iterator',
        description: 'Access elements sequentially without exposing structure',
        icon: Icons.repeat,
        difficulty: 'Beginner',
        useCases: ['Collection traversal', 'Data iteration', 'Streaming'],
        towerDefenseContext:
            'Iterate through enemy waves, tower upgrade paths, and attack patterns',
        communicationType: 'Sequential',
      ),
      const BehavioralPatternInfo(
        name: 'Memento',
        description:
            'Save and restore object state without violating encapsulation',
        icon: Icons.save,
        difficulty: 'Intermediate',
        useCases: ['Undo functionality', 'Save/Load', 'Checkpoints'],
        towerDefenseContext:
            'Save game state, tower configurations, and player progress checkpoints',
        communicationType: 'State-preservation',
      ),
      const BehavioralPatternInfo(
        name: 'Interpreter',
        description: 'Define language grammar and interpret sentences',
        icon: Icons.translate,
        difficulty: 'Advanced',
        useCases: [
          'Expression evaluation',
          'DSL implementation',
          'Rule engines',
        ],
        towerDefenseContext:
            'Tower scripting language for custom behaviors and AI patterns',
        communicationType: 'Language-based',
      ),
    ];
  }
}
