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
    _loadPatterns();
  }

  /// Load behavioral patterns data
  void _loadPatterns() {
    _isLoading.value = true;
    _hasError.value = false;

    try {
      final patterns = _getBehavioralPatterns();
      _allPatterns.assignAll(patterns);
      _filteredPatterns.assignAll(patterns);
      _isLoading.value = false;
    } catch (e) {
      _hasError.value = true;
      _isLoading.value = false;
    }
  }

  /// Toggle between grid and list view
  void toggleView() {
    _isGridView.value = !_isGridView.value;
  }

  /// Toggle view mode (alias for toggleView)
  void toggleViewMode() {
    toggleView();
  }

  /// Load patterns (public method)
  void loadPatterns() {
    _loadPatterns();
  }

  /// Search patterns by query
  void searchPatterns(String query) {
    _searchQuery.value = query;
    _filterPatterns();
  }

  /// Filter patterns by difficulty
  void filterByDifficulty(String difficulty) {
    _selectedDifficulty.value = difficulty;
    _filterPatterns();
  }

  /// Apply filters to patterns
  void _filterPatterns() {
    var patterns = _allPatterns.toList();

    // Apply difficulty filter
    if (_selectedDifficulty.value != 'All') {
      patterns = patterns
          .where((pattern) => pattern.difficulty == _selectedDifficulty.value)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      patterns = patterns
          .where((pattern) =>
              pattern.name.toLowerCase().contains(query) ||
              pattern.description.toLowerCase().contains(query) ||
              pattern.useCases
                  .any((useCase) => useCase.toLowerCase().contains(query)) ||
              pattern.towerDefenseContext.toLowerCase().contains(query))
          .toList();
    }

    _filteredPatterns.assignAll(patterns);
  }

  /// Clear all filters
  void clearFilters() {
    _selectedDifficulty.value = 'All';
    _searchQuery.value = '';
    _filteredPatterns.assignAll(_allPatterns);
  }

  /// Toggle pattern as favorite
  void toggleFavorite(BehavioralPatternInfo pattern) {
    if (_favoritePatterns.contains(pattern)) {
      _favoritePatterns.remove(pattern);
    } else {
      _favoritePatterns.add(pattern);
    }
  }

  /// Navigate to pattern detail page
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
        category: 'Communication Pattern',
        keyBenefits: ['Loose coupling', 'Dynamic relationships', 'Event propagation'],
        useCases: ['Event handling', 'Model-View updates', 'Notifications'],
        relatedPatterns: ['Mediator', 'State', 'Command'],
        towerDefenseExample: 'Tower observes enemy movements to auto-target and adjust firing patterns',
        towerDefenseContext:
            'Tower observes enemy movements to auto-target and adjust firing patterns',
        communicationType: 'Event-driven',
        complexity: 6.0,
        isPopular: true,
      ),
      const BehavioralPatternInfo(
        name: 'Command',
        description: 'Encapsulate requests as objects',
        icon: Icons.play_arrow,
        difficulty: 'Intermediate',
        category: 'Action Pattern',
        keyBenefits: ['Undo/Redo support', 'Request queuing', 'Macro recording'],
        useCases: ['Undo/Redo', 'Macro recording', 'Queue operations'],
        relatedPatterns: ['Observer', 'Strategy', 'Composite'],
        towerDefenseExample: 'Tower attack commands, upgrade commands, and wave control actions',
        towerDefenseContext:
            'Tower attack commands, upgrade commands, and wave control actions',
        communicationType: 'Action-based',
        complexity: 5.5,
        isPopular: true,
      ),
      const BehavioralPatternInfo(
        name: 'Strategy',
        description: 'Define algorithms and make them interchangeable',
        icon: Icons.timeline,
        difficulty: 'Beginner',
        category: 'Algorithm Pattern',
        keyBenefits: ['Algorithm flexibility', 'Runtime switching', 'Open/Closed principle'],
        useCases: [
          'Algorithm switching',
          'Payment methods',
          'Sorting strategies',
        ],
        relatedPatterns: ['Command', 'State', 'Template Method'],
        towerDefenseExample: 'Different AI strategies for enemies (aggressive, defensive, sneaky)',
        towerDefenseContext:
            'Different AI strategies for enemies (aggressive, defensive, sneaky)',
        communicationType: 'Algorithm-based',
        complexity: 4.0,
        isPopular: true,
      ),
      const BehavioralPatternInfo(
        name: 'State',
        description:
            'Allow objects to alter behavior when internal state changes',
        icon: Icons.radio_button_checked,
        difficulty: 'Intermediate',
        category: 'State Pattern',
        keyBenefits: ['State encapsulation', 'Behavior changes', 'State transitions'],
        useCases: ['State machines', 'Game states', 'UI states'],
        relatedPatterns: ['Strategy', 'Observer', 'Flyweight'],
        towerDefenseExample: 'Tower states: idle, targeting, firing, reloading, upgrading',
        towerDefenseContext:
            'Tower states: idle, targeting, firing, reloading, upgrading',
        communicationType: 'State-driven',
        complexity: 6.5,
        isPopular: true,
      ),
      const BehavioralPatternInfo(
        name: 'Chain of Responsibility',
        description: 'Pass requests along a chain of handlers',
        icon: Icons.link,
        difficulty: 'Advanced',
        category: 'Handler Pattern',
        keyBenefits: ['Loose coupling', 'Handler flexibility', 'Runtime configuration'],
        useCases: ['Request processing', 'Event bubbling', 'Middleware'],
        relatedPatterns: ['Command', 'Composite', 'Decorator'],
        towerDefenseExample: 'Damage calculation chain: base damage → tower upgrades → enemy armor',
        towerDefenseContext:
            'Damage calculation chain: base damage → tower upgrades → enemy armor',
        communicationType: 'Chain-based',
        complexity: 7.5,
      ),
      const BehavioralPatternInfo(
        name: 'Mediator',
        description: 'Define how objects interact through a mediator',
        icon: Icons.hub,
        difficulty: 'Advanced',
        category: 'Coordination Pattern',
        keyBenefits: ['Centralized control', 'Reduced coupling', 'Reusable components'],
        useCases: [
          'Component communication',
          'Dialog management',
          'UI coordination',
        ],
        relatedPatterns: ['Observer', 'Facade', 'Command'],
        towerDefenseExample: 'Game mediator coordinates towers, enemies, UI, and scoring system',
        towerDefenseContext:
            'Game mediator coordinates towers, enemies, UI, and scoring system',
        communicationType: 'Mediated',
        complexity: 8.0,
        isPopular: true,
      ),
      const BehavioralPatternInfo(
        name: 'Template Method',
        description: 'Define algorithm skeleton, let subclasses override steps',
        icon: Icons.dashboard_customize,
        difficulty: 'Intermediate',
        category: 'Template Pattern',
        keyBenefits: ['Code reuse', 'Algorithm structure', 'Consistent interface'],
        useCases: ['Algorithm templates', 'Framework extension', 'Code reuse'],
        relatedPatterns: ['Strategy', 'Factory Method', 'Hook'],
        towerDefenseExample: 'Tower firing template: aim → charge → fire → cooldown with variations',
        towerDefenseContext:
            'Tower firing template: aim → charge → fire → cooldown with variations',
        communicationType: 'Template-based',
        complexity: 5.0,
      ),
      const BehavioralPatternInfo(
        name: 'Visitor',
        description: 'Separate algorithms from object structure',
        icon: Icons.tour,
        difficulty: 'Advanced',
        category: 'Operation Pattern',
        keyBenefits: ['Algorithm separation', 'Easy extension', 'Type-safe operations'],
        useCases: [
          'Object traversal',
          'Operations on hierarchies',
          'Reporting',
        ],
        relatedPatterns: ['Composite', 'Interpreter', 'Iterator'],
        towerDefenseExample: 'Different visitors for towers: upgrade calculator, range displayer, stats collector',
        towerDefenseContext:
            'Different visitors for towers: upgrade calculator, range displayer, stats collector',
        communicationType: 'Visitor-based',
        complexity: 8.5,
      ),
      const BehavioralPatternInfo(
        name: 'Iterator',
        description: 'Access elements sequentially without exposing structure',
        icon: Icons.repeat,
        difficulty: 'Beginner',
        category: 'Access Pattern',
        keyBenefits: ['Uniform access', 'Collection abstraction', 'Lazy evaluation'],
        useCases: ['Collection traversal', 'Data iteration', 'Streaming'],
        relatedPatterns: ['Visitor', 'Composite', 'Factory Method'],
        towerDefenseExample: 'Iterate through enemy waves, tower upgrade paths, and attack patterns',
        towerDefenseContext:
            'Iterate through enemy waves, tower upgrade paths, and attack patterns',
        communicationType: 'Sequential',
        complexity: 3.5,
        isPopular: true,
      ),
      const BehavioralPatternInfo(
        name: 'Memento',
        description:
            'Save and restore object state without violating encapsulation',
        icon: Icons.save,
        difficulty: 'Intermediate',
        category: 'State Management',
        keyBenefits: ['State preservation', 'Encapsulation', 'Undo functionality'],
        useCases: ['Undo functionality', 'Save/Load', 'Checkpoints'],
        relatedPatterns: ['Command', 'Observer', 'Caretaker'],
        towerDefenseExample: 'Save game state, tower configurations, and player progress checkpoints',
        towerDefenseContext:
            'Save game state, tower configurations, and player progress checkpoints',
        communicationType: 'State-preservation',
        complexity: 6.0,
      ),
      const BehavioralPatternInfo(
        name: 'Interpreter',
        description: 'Define language grammar and interpret sentences',
        icon: Icons.translate,
        difficulty: 'Advanced',
        category: 'Language Pattern',
        keyBenefits: ['Custom languages', 'Expression evaluation', 'Grammar definition'],
        useCases: [
          'Expression evaluation',
          'DSL implementation',
          'Rule engines',
        ],
        relatedPatterns: ['Visitor', 'Composite', 'Flyweight'],
        towerDefenseExample: 'Tower scripting language for custom behaviors and AI patterns',
        towerDefenseContext:
            'Tower scripting language for custom behaviors and AI patterns',
        communicationType: 'Language-based',
        complexity: 9.0,
      ),
    ];
  }
}