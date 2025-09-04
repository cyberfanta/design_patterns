/// Behavioral Patterns Base Controller - MVVM-C + GetX Architecture
///
/// PATTERN: MVVM Controller + Observer Pattern - Base controller for behavioral patterns
/// WHERE: Presentation layer controller base for behavioral design patterns
/// HOW: GetX controller manages reactive state with simplified implementation
/// WHY: MVVM-C architecture with GetX provides clean separation and reactive updates
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:get/get.dart';

import '../models/behavioral_pattern_model.dart';

/// Base MVVM-C Controller for Behavioral Patterns
class BehavioralPatternsController extends GetxController {
  // MARK: - Observable State Variables

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Pattern data
  final RxList<BehavioralPatternModel> allPatterns =
      <BehavioralPatternModel>[].obs;
  final RxList<BehavioralPatternModel> filteredPatterns =
      <BehavioralPatternModel>[].obs;

  /// Current selection
  final Rx<BehavioralPatternModel?> selectedPattern =
      Rx<BehavioralPatternModel?>(null);
  final RxInt selectedCategoryIndex = 0.obs;

  /// Filters
  final RxString searchQuery = ''.obs;
  final RxString difficultyFilter = 'All'.obs;

  /// UI state
  final RxSet<String> favoritePatternIds = <String>{}.obs;
  final RxBool isGridView = true.obs;

  /// Demo state
  final RxBool isDemoRunning = false.obs;
  final RxString demoStage = ''.obs;
  final RxDouble demoProgress = 0.0.obs;
  final RxList<String> demoLogs = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    Log.debug('BehavioralPatternsController: MVVM-C + GetX initialized');

    // Set up reactive listeners
    searchQuery.listen((_) => _updateFilteredPatterns());
    difficultyFilter.listen((_) => _updateFilteredPatterns());

    // Load patterns
    loadPatterns();
  }

  /// Load all behavioral patterns
  Future<void> loadPatterns() async {
    try {
      isLoading.value = true;

      // Simulate data loading
      await Future.delayed(const Duration(milliseconds: 500));

      final patterns = _generateBehavioralPatterns();
      allPatterns.assignAll(patterns);
      _updateFilteredPatterns();

      Log.debug(
        'BehavioralPatternsController: Loaded ${patterns.length} patterns',
      );
    } catch (e) {
      Log.error('BehavioralPatternsController: Failed to load patterns - $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Select a pattern
  void selectPattern(BehavioralPatternModel pattern) {
    selectedPattern.value = pattern;
    Log.debug('BehavioralPatternsController: Selected pattern ${pattern.name}');
  }

  /// Toggle favorite
  void toggleFavorite(String patternId) {
    if (favoritePatternIds.contains(patternId)) {
      favoritePatternIds.remove(patternId);
    } else {
      favoritePatternIds.add(patternId);
    }
    Log.debug('BehavioralPatternsController: Toggled favorite for $patternId');
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Update difficulty filter
  void updateDifficultyFilter(String difficulty) {
    difficultyFilter.value = difficulty;
  }

  /// Start pattern demo
  Future<void> startPatternDemo(BehavioralPatternModel pattern) async {
    if (isDemoRunning.value) return;

    try {
      isDemoRunning.value = true;
      demoProgress.value = 0.0;
      demoStage.value = 'Initializing';
      demoLogs.clear();

      demoLogs.add('Starting ${pattern.name} demonstration...');

      await _executeDemo(pattern);

      Log.debug(
        'BehavioralPatternsController: Demo completed for ${pattern.name}',
      );
    } catch (e) {
      Log.error('BehavioralPatternsController: Demo failed - $e');
    } finally {
      isDemoRunning.value = false;
    }
  }

  /// Execute pattern demo
  Future<void> _executeDemo(BehavioralPatternModel pattern) async {
    // Simulate demo stages
    demoStage.value = 'Setting up';
    demoProgress.value = 0.3;
    demoLogs.add('Setting up ${pattern.name} pattern...');
    await Future.delayed(const Duration(milliseconds: 300));

    demoStage.value = 'Executing';
    demoProgress.value = 0.7;
    demoLogs.add('Executing pattern in Tower Defense context...');
    await Future.delayed(const Duration(milliseconds: 400));

    demoStage.value = 'Completed';
    demoProgress.value = 1.0;
    demoLogs.add('✓ ${pattern.name} demonstration completed successfully');
  }

  /// Update filtered patterns
  void _updateFilteredPatterns() {
    var patterns = List<BehavioralPatternModel>.from(allPatterns);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      patterns = patterns
          .where(
            (pattern) =>
                pattern.name.toLowerCase().contains(query) ||
                pattern.description.toLowerCase().contains(query),
          )
          .toList();
    }

    // Apply difficulty filter
    if (difficultyFilter.value != 'All') {
      patterns = patterns
          .where((pattern) => pattern.difficulty == difficultyFilter.value)
          .toList();
    }

    filteredPatterns.assignAll(patterns);
  }

  /// Generate sample behavioral patterns
  List<BehavioralPatternModel> _generateBehavioralPatterns() {
    return [
      BehavioralPatternModel(
        id: 'observer',
        name: 'Observer',
        description:
            'Defines subscription mechanism for notifying multiple objects',
        category: 'Communication',
        difficulty: 'Intermediate',
        complexity: 6.5,
        keyBenefits: [
          'Loose coupling',
          'Dynamic relationships',
          'Event-driven',
        ],
        useCases: ['Game events', 'UI updates', 'Achievement system'],
        relatedPatterns: ['Mediator', 'Command'],
        towerDefenseExample:
            'Event system notifies UI, sound, achievements when enemies are destroyed',
        codeExample:
            'class GameEventManager { List<Observer> observers; void notify(GameEvent event) {...} }',
        isPopular: true,
      ),
      BehavioralPatternModel(
        id: 'command',
        name: 'Command',
        description:
            'Encapsulates requests as objects for queuing and undo operations',
        category: 'Algorithm',
        difficulty: 'Advanced',
        complexity: 7.5,
        keyBenefits: [
          'Undo/Redo support',
          'Operation queuing',
          'Macro commands',
        ],
        useCases: ['Tower placement', 'Undo/Redo system', 'Action queuing'],
        relatedPatterns: ['Observer', 'Memento'],
        towerDefenseExample:
            'Tower operations (place, upgrade, sell) as commands with undo/redo support',
        codeExample: 'interface Command { void execute(); void undo(); }',
        isPopular: true,
      ),
      BehavioralPatternModel(
        id: 'strategy',
        name: 'Strategy',
        description:
            'Defines family of algorithms and makes them interchangeable',
        category: 'Algorithm',
        difficulty: 'Intermediate',
        complexity: 6.0,
        keyBenefits: [
          'Runtime switching',
          'Easy extension',
          'Clean separation',
        ],
        useCases: ['Tower targeting', 'Enemy movement', 'AI behavior'],
        relatedPatterns: ['State', 'Bridge'],
        towerDefenseExample:
            'Tower targeting strategies (nearest, strongest, weakest) switchable at runtime',
        codeExample:
            'interface TargetingStrategy { Enemy selectTarget(List<Enemy> enemies); }',
        isPopular: true,
      ),
      BehavioralPatternModel(
        id: 'state',
        name: 'State',
        description:
            'Allows object to alter behavior when internal state changes',
        category: 'Algorithm',
        difficulty: 'Intermediate',
        complexity: 6.5,
        keyBenefits: [
          'Clean transitions',
          'Eliminates conditionals',
          'Extensible',
        ],
        useCases: ['Game states', 'Tower states', 'Enemy behavior'],
        relatedPatterns: ['Strategy', 'Command'],
        towerDefenseExample:
            'Tower states (Idle, Targeting, Attacking) with automatic transitions',
        codeExample: 'abstract class TowerState { void update(Tower tower); }',
      ),
    ];
  }

  /// Computed properties
  bool isPatternFavorite(String patternId) =>
      favoritePatternIds.contains(patternId);

  int get favoritesCount => favoritePatternIds.length;

  int get filteredPatternsCount => filteredPatterns.length;

  String get demoProgressPercentage => '${(demoProgress.value * 100).toInt()}%';
}
