/// Structural Patterns BLoC - MVP + Bloc Architecture
///
/// PATTERN: Command Pattern + Observer Pattern + MVP - BLoC manages business logic
/// WHERE: Presentation layer business logic for structural design patterns (MVP Presenter)
/// HOW: Processes events and emits states, coordinates between Model and View
/// WHY: MVP architecture with BLoC provides separation of concerns and testable business logic
library;

import 'dart:async';

import 'package:design_patterns/core/logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'structural_patterns_event.dart';
import 'structural_patterns_state.dart';

/// MVP Presenter - BLoC for managing Structural Patterns business logic
/// 
/// PATTERN: MVP Presenter + Command Pattern - Processes events and manages state
class StructuralPatternsBloc
    extends Bloc<StructuralPatternsEvent, StructuralPatternsState> {
  StructuralPatternsBloc() : super(const StructuralPatternsInitial()) {
    Log.debug('StructuralPatternsBloc: MVP Presenter initialized');

    // Register event handlers
    on<LoadStructuralPatterns>(_onLoadStructuralPatterns);
    on<ChangeStructuralPatternsPage>(_onChangeStructuralPatternsPage);
    on<SelectStructuralPattern>(_onSelectStructuralPattern);
    on<ClearStructuralPatternSelection>(_onClearStructuralPatternSelection);
    on<ToggleStructuralPatternFavorite>(_onToggleStructuralPatternFavorite);
    on<SearchStructuralPatterns>(_onSearchStructuralPatterns);
    on<FilterStructuralPatternsByComplexity>(
        _onFilterStructuralPatternsByComplexity);
    on<StartStructuralPatternDemo>(_onStartStructuralPatternDemo);
    on<StopStructuralPatternDemo>(_onStopStructuralPatternDemo);
    on<UpdateStructuralPatternDemoProgress>(
        _onUpdateStructuralPatternDemoProgress);
    on<ToggleStructuralPatternCode>(_onToggleStructuralPatternCode);
    on<SortStructuralPatterns>(_onSortStructuralPatterns);
    on<RefreshStructuralPatterns>(_onRefreshStructuralPatterns);
    on<ShowStructuralPatternsComparison>(_onShowStructuralPatternsComparison);
    on<HideStructuralPatternsComparison>(_onHideStructuralPatternsComparison);
    on<SetStructuralPatternsLayoutMode>(_onSetStructuralPatternsLayoutMode);

    // Auto-load patterns on initialization
    add(const LoadStructuralPatterns());
  }

  /// Load all structural patterns (Presenter action)
  Future<void> _onLoadStructuralPatterns(
    LoadStructuralPatterns event,
    Emitter<StructuralPatternsState> emit,
  ) async {
    event.logEvent();

    if (event.forceRefresh || state is! StructuralPatternsLoaded) {
      emit(const StructuralPatternsLoading(
          message: 'Loading structural patterns...'));

      try {
        // Simulate data loading from Model layer
        await Future.delayed(const Duration(milliseconds: 600));

        final allPatterns = _getAllStructuralPatterns();
        final compositionPatterns = _getCompositionPatterns();
        final behaviorPatterns = _getBehaviorPatterns();

        final loadedState = StructuralPatternsLoaded(
          allPatterns: allPatterns,
          compositionPatterns: compositionPatterns,
          behaviorPatterns: behaviorPatterns,
          filteredPatterns: allPatterns,
        );

        emit(loadedState);
        loadedState.logState();

        Log.debug('StructuralPatternsBloc: MVP - Loaded ${allPatterns
            .length} patterns');
      } catch (e, stackTrace) {
        Log.error('StructuralPatternsBloc: MVP - Failed to load patterns - $e');
        final errorState = StructuralPatternsError(
          error: 'Failed to load patterns: $e',
          stackTrace: stackTrace.toString(),
        );
        emit(errorState);
        errorState.logState();
      }
    }
  }

  /// Change current page in PageView (Presenter action)
  void _onChangeStructuralPatternsPage(ChangeStructuralPatternsPage event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();

    if (state is StructuralPatternsLoaded) {
      final currentState = state as StructuralPatternsLoaded;
      final newState = currentState.copyWith(currentPageIndex: event.pageIndex);
      emit(newState);
      Log.debug(
          'StructuralPatternsBloc: MVP - Changed to page ${event.pageIndex}');
    }
  }

  /// Select a specific pattern (Presenter action)
  void _onSelectStructuralPattern(SelectStructuralPattern event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();

    if (state is StructuralPatternsLoaded) {
      final currentState = state as StructuralPatternsLoaded;
      final newState = currentState.copyWith(selectedPattern: event.pattern);
      emit(newState);
      Log.debug('StructuralPatternsBloc: MVP - Selected pattern ${event.pattern
          .name}');
    }
  }

  /// Clear pattern selection (Presenter action)
  void _onClearStructuralPatternSelection(ClearStructuralPatternSelection event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();

    if (state is StructuralPatternsLoaded) {
      final currentState = state as StructuralPatternsLoaded;
      final newState = currentState.copyWith(clearSelectedPattern: true);
      emit(newState);
      Log.debug('StructuralPatternsBloc: MVP - Cleared pattern selection');
    }
  }

  /// Toggle pattern as favorite (Presenter action)
  void _onToggleStructuralPatternFavorite(
    ToggleStructuralPatternFavorite event,
    Emitter<StructuralPatternsState> emit,
  ) {
    event.logEvent();

    if (state is StructuralPatternsLoaded) {
      final currentState = state as StructuralPatternsLoaded;
      final newFavorites = Set<String>.from(currentState.favoritePatternIds);

      if (newFavorites.contains(event.patternId)) {
        newFavorites.remove(event.patternId);
      } else {
        newFavorites.add(event.patternId);
      }

      final newState = currentState.copyWith(favoritePatternIds: newFavorites);
      emit(newState);
      Log.debug('StructuralPatternsBloc: MVP - Toggled favorite for ${event
          .patternId}');
    }
  }

  /// Search patterns by query (Presenter action)
  void _onSearchStructuralPatterns(SearchStructuralPatterns event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();

    if (state is StructuralPatternsLoaded) {
      final currentState = state as StructuralPatternsLoaded;
      final filteredPatterns = _filterPatterns(
          currentState.allPatterns, event.query);

      final newState = currentState.copyWith(
        searchQuery: event.query,
        filteredPatterns: filteredPatterns,
      );

      emit(newState);
      Log.debug('StructuralPatternsBloc: MVP - Searched for "${event
          .query}", found ${filteredPatterns.length} results');
    }
  }

  /// Filter patterns by complexity (Presenter action)
  void _onFilterStructuralPatternsByComplexity(
      FilterStructuralPatternsByComplexity event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();

    if (state is StructuralPatternsLoaded) {
      final currentState = state as StructuralPatternsLoaded;
      final newState = currentState.copyWith(
          complexityFilter: event.complexityLevel);
      emit(newState);
      Log.debug('StructuralPatternsBloc: MVP - Filtered by complexity "${event
          .complexityLevel}"');
    }
  }

  /// Start pattern demonstration (Presenter action)
  Future<void> _onStartStructuralPatternDemo(StartStructuralPatternDemo event,
      Emitter<StructuralPatternsState> emit,) async {
    event.logEvent();

    final demoRunningState = StructuralPatternDemoRunning(
      pattern: event.pattern,
      currentStage: 'Initializing',
      progress: 0.0,
      executionLog: ['Starting ${event.pattern.name} demonstration...'],
    );
    emit(demoRunningState);
    demoRunningState.logState();

    try {
      final startTime = DateTime.now();
      final log = <String>[];
      final results = <String, dynamic>{};

      // Simulate demo execution
      await _executePatternDemo(event.pattern, log, results, emit);

      final endTime = DateTime.now();
      final executionTime = endTime.difference(startTime);

      final completedState = StructuralPatternDemoCompleted(
        pattern: event.pattern,
        executionLog: log,
        results: results,
        executionTime: executionTime,
        wasSuccessful: true,
      );
      emit(completedState);
      completedState.logState();

      Log.debug(
          'StructuralPatternsBloc: MVP - Demo completed for ${event.pattern
              .name} in ${executionTime.inMilliseconds}ms');
    } catch (e, stackTrace) {
      Log.error('StructuralPatternsBloc: MVP - Demo failed for ${event.pattern
          .name} - $e');
      final errorState = StructuralPatternsError(
        error: 'Demo failed: $e',
        stackTrace: stackTrace.toString(),
      );
      emit(errorState);
    }
  }

  /// Stop pattern demonstration (Presenter action)
  void _onStopStructuralPatternDemo(StopStructuralPatternDemo event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();

    if (state is StructuralPatternDemoRunning) {
      // Return to loaded state
      add(const LoadStructuralPatterns());
      Log.debug('StructuralPatternsBloc: MVP - Demo stopped');
    }
  }

  /// Update demo progress (Presenter action)
  void _onUpdateStructuralPatternDemoProgress(
      UpdateStructuralPatternDemoProgress event,
      Emitter<StructuralPatternsState> emit,) {
    if (state is StructuralPatternDemoRunning) {
      final currentDemo = state as StructuralPatternDemoRunning;
      final updatedDemo = StructuralPatternDemoRunning(
        pattern: currentDemo.pattern,
        currentStage: event.stage,
        progress: event.progress,
        executionLog: [...currentDemo.executionLog, ...event.logs],
        demoData: currentDemo.demoData,
        startTime: currentDemo.startTime,
      );
      emit(updatedDemo);
    }
  }

  /// Toggle pattern code visibility (Presenter action)
  void _onToggleStructuralPatternCode(ToggleStructuralPatternCode event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();

    if (state is StructuralPatternsLoaded) {
      final currentState = state as StructuralPatternsLoaded;
      final newCodeVisibility = Map<String, bool>.from(
          currentState.codeVisibility);
      newCodeVisibility[event.patternId] =
      !(newCodeVisibility[event.patternId] ?? false);

      final newState = currentState.copyWith(codeVisibility: newCodeVisibility);
      emit(newState);
      Log.debug(
          'StructuralPatternsBloc: MVP - Toggled code visibility for ${event
              .patternId}');
    }
  }

  /// Sort patterns by criteria (Presenter action)
  void _onSortStructuralPatterns(SortStructuralPatterns event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();
    
    if (state is StructuralPatternsLoaded) {
      final currentState = state as StructuralPatternsLoaded;
      final newState = currentState.copyWith(
        sortCriteria: event.criteria,
        sortAscending: event.ascending,
      );
      emit(newState);
      Log.debug('StructuralPatternsBloc: MVP - Sorted by ${event.criteria
          .name} (${event.ascending ? 'asc' : 'desc'})');
    }
  }

  /// Refresh patterns data (Presenter action)
  void _onRefreshStructuralPatterns(RefreshStructuralPatterns event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();
    add(const LoadStructuralPatterns(forceRefresh: true));
  }

  /// Show patterns comparison (Presenter action)
  void _onShowStructuralPatternsComparison(
      ShowStructuralPatternsComparison event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();

    if (state is StructuralPatternsLoaded) {
      final currentState = state as StructuralPatternsLoaded;
      final newState = currentState.copyWith(
        comparisonPatterns: event.patterns,
        isComparisonVisible: true,
      );
      emit(newState);
      Log.debug(
          'StructuralPatternsBloc: MVP - Showing comparison of ${event.patterns
              .length} patterns');
    }
  }

  /// Hide patterns comparison (Presenter action)
  void _onHideStructuralPatternsComparison(
      HideStructuralPatternsComparison event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();

    if (state is StructuralPatternsLoaded) {
      final currentState = state as StructuralPatternsLoaded;
      final newState = currentState.copyWith(
        comparisonPatterns: [],
        isComparisonVisible: false,
      );
      emit(newState);
      Log.debug('StructuralPatternsBloc: MVP - Hidden patterns comparison');
    }
  }

  /// Set layout mode (Presenter action)
  void _onSetStructuralPatternsLayoutMode(SetStructuralPatternsLayoutMode event,
      Emitter<StructuralPatternsState> emit,) {
    event.logEvent();

    if (state is StructuralPatternsLoaded) {
      final currentState = state as StructuralPatternsLoaded;
      final newState = currentState.copyWith(layoutMode: event.layoutMode);
      emit(newState);
      Log.debug(
          'StructuralPatternsBloc: MVP - Set layout mode to ${event.layoutMode
              .name}');
    }
  }

  // MARK: - Private Helper Methods (Model Layer interactions)

  /// Execute pattern demonstration with progress updates
  Future<void> _executePatternDemo(StructuralPatternInfo pattern,
      List<String> log,
      Map<String, dynamic> results,
      Emitter<StructuralPatternsState> emit,) async {
    switch (pattern.name.toLowerCase()) {
      case 'adapter':
        await _executeAdapterDemo(log, results, emit);
        break;
      case 'bridge':
        await _executeBridgeDemo(log, results, emit);
        break;
      case 'composite':
        await _executeCompositeDemo(log, results, emit);
        break;
      case 'decorator':
        await _executeDecoratorDemo(log, results, emit);
        break;
      case 'facade':
        await _executeFacadeDemo(log, results, emit);
        break;
      case 'flyweight':
        await _executeFlyweightDemo(log, results, emit);
        break;
      case 'proxy':
        await _executeProxyDemo(log, results, emit);
        break;
      default:
        await _executeGenericDemo(pattern, log, results, emit);
    }
  }

  Future<void> _executeAdapterDemo(List<String> log,
      Map<String, dynamic> results,
      Emitter<StructuralPatternsState> emit,) async {
    log.add('Creating legacy tower system...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Setup', progress: 0.2, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Creating modern tower interface...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Interface', progress: 0.4, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Implementing tower adapter...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Adaptation', progress: 0.7, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 400));

    log.add('Testing compatibility between legacy and modern systems...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Testing', progress: 0.9, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 200));

    results['legacy_towers_adapted'] = 5;
    results['compatibility_success'] = '100%';
    results['performance_impact'] = '~5% overhead';
    results['tower_defense_benefit'] =
    'Legacy towers work with new game engine';

    log.add('✓ Adapter demonstration completed - Legacy towers integrated');
  }

  Future<void> _executeGenericDemo(StructuralPatternInfo pattern,
      List<String> log,
      Map<String, dynamic> results,
      Emitter<StructuralPatternsState> emit,) async {
    log.add('Initializing ${pattern.name} pattern in Tower Defense context...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Initialize', progress: 0.3, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 400));

    log.add('Applying structural pattern benefits...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Apply', progress: 0.7, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Integrating with Tower Defense architecture...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Integrate', progress: 0.95, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 200));

    results['pattern_name'] = pattern.name;
    results['complexity'] = pattern.complexity;
    results['demo_status'] = 'completed';
    results['tower_defense_integration'] = 'Successfully applied';

    log.add('✓ ${pattern
        .name} demonstration completed - Tower Defense integration');
  }

  /// Filter patterns by search query
  List<StructuralPatternInfo> _filterPatterns(
      List<StructuralPatternInfo> patterns, String query) {
    if (query.isEmpty) return patterns;

    final lowerQuery = query.toLowerCase();
    return patterns.where((pattern) =>
    pattern.name.toLowerCase().contains(lowerQuery) ||
        pattern.description.toLowerCase().contains(lowerQuery) ||
        pattern.category.toLowerCase().contains(lowerQuery) ||
        pattern.keyBenefits.any((benefit) =>
            benefit.toLowerCase().contains(lowerQuery)) ||
        pattern.useCases.any((useCase) =>
            useCase.toLowerCase().contains(lowerQuery)) ||
        pattern.towerDefenseExample.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Get all structural patterns (Model data)
  List<StructuralPatternInfo> _getAllStructuralPatterns() {
    return [
      ..._getCompositionPatterns(),
      ..._getBehaviorPatterns(),
    ];
  }

  /// Get composition patterns (Model data)
  List<StructuralPatternInfo> _getCompositionPatterns() {
    return [
      StructuralPatternInfo(
        id: 'adapter',
        name: 'Adapter',
        description: 'Allows incompatible interfaces to work together',
        category: 'Object Composition',
        difficulty: 'Beginner',
        complexity: 5.0,
        keyBenefits: [
          'Interface compatibility',
          'Legacy integration',
          'Third-party compatibility'
        ],
        useCases: [
          'Legacy system integration',
          'Third-party APIs',
          'Interface mismatches'
        ],
        relatedPatterns: ['Bridge', 'Decorator', 'Facade'],
        towerDefenseExample: 'Legacy tower types work with new game engine through adapter, maintaining compatibility without code changes.',
        codeExample: 'class LegacyTowerAdapter implements ModernTowerInterface { ... }',
        isPopular: true,
        icon: Icons.cable,
        compositionType: 'Interface Adaptation',
      ),
      StructuralPatternInfo(
        id: 'bridge',
        name: 'Bridge',
        description: 'Separates abstraction from implementation',
        category: 'Object Composition',
        difficulty: 'Intermediate',
        complexity: 7.5,
        keyBenefits: [
          'Platform independence',
          'Runtime switching',
          'Separate hierarchies'
        ],
        useCases: [
          'Cross-platform development',
          'Multiple implementations',
          'Runtime switching'
        ],
        relatedPatterns: ['Adapter', 'State', 'Strategy'],
        towerDefenseExample: 'Tower abstraction separated from platform-specific rendering (Mobile/Desktop/Web) allowing same towers on all platforms.',
        codeExample: 'abstract class Tower { protected PlatformRenderer renderer; ... }',
        icon: Icons.dns,
        compositionType: 'Abstraction Bridge',
      ),
      StructuralPatternInfo(
        id: 'composite',
        name: 'Composite',
        description: 'Composes objects into tree structures',
        category: 'Object Composition',
        difficulty: 'Intermediate',
        complexity: 6.5,
        keyBenefits: [
          'Uniform interface',
          'Hierarchical structures',
          'Recursive operations'
        ],
        useCases: [
          'Tree structures',
          'Part-whole hierarchies',
          'Recursive algorithms'
        ],
        relatedPatterns: ['Decorator', 'Iterator', 'Visitor'],
        towerDefenseExample: 'Tower groups and formations managed uniformly - single towers and tower groups use same interface for commands.',
        codeExample: 'class TowerGroup implements TowerComponent { List<TowerComponent> children; ... }',
        isPopular: true,
        icon: Icons.account_tree,
        compositionType: 'Tree Structure',
      ),
      StructuralPatternInfo(
        id: 'decorator',
        name: 'Decorator',
        description: 'Adds behavior to objects dynamically',
        category: 'Object Composition',
        difficulty: 'Intermediate',
        complexity: 6.0,
        keyBenefits: [
          'Runtime enhancement',
          'Flexible combinations',
          'Open-closed principle'
        ],
        useCases: ['Feature additions', 'Behavior stacking', 'UI enhancements'],
        relatedPatterns: ['Adapter', 'Composite', 'Strategy'],
        towerDefenseExample: 'Tower enhancements stack dynamically - fire damage + freeze + double shot without creating subclasses for every combination.',
        codeExample: 'class FireDamageDecorator extends TowerDecorator { ... }',
        isPopular: true,
        icon: Icons.layers,
        compositionType: 'Wrapper Enhancement',
      ),
    ];
  }

  /// Get behavior patterns (Model data)
  List<StructuralPatternInfo> _getBehaviorPatterns() {
    return [
      StructuralPatternInfo(
        id: 'facade',
        name: 'Facade',
        description: 'Provides simplified interface to complex subsystem',
        category: 'Interface Simplification',
        difficulty: 'Beginner',
        complexity: 4.5,
        keyBenefits: [
          'Simplified interface',
          'Subsystem isolation',
          'Ease of use'
        ],
        useCases: [
          'Complex API simplification',
          'Subsystem coordination',
          'Legacy wrapping'
        ],
        relatedPatterns: ['Adapter', 'Mediator', 'Singleton'],
        towerDefenseExample: 'Game facade coordinates wave start - enemy spawning, tower activation, UI updates, sound effects in one simple call.',
        codeExample: 'class GameFacade { public void startWave(int waveNumber) { ... } }',
        isPopular: true,
        icon: Icons.dashboard,
        compositionType: 'Interface Simplification',
      ),
      StructuralPatternInfo(
        id: 'flyweight',
        name: 'Flyweight',
        description: 'Minimizes memory usage by sharing common data',
        category: 'Resource Optimization',
        difficulty: 'Advanced',
        complexity: 8.0,
        keyBenefits: [
          'Memory optimization',
          'Performance improvement',
          'Object sharing'
        ],
        useCases: [
          'Large numbers of objects',
          'Memory constraints',
          'Shared resources'
        ],
        relatedPatterns: ['Factory Method', 'Composite', 'State'],
        towerDefenseExample: 'Bullet flyweights share sprite, sound, and particle data - thousands of bullets with minimal memory usage.',
        codeExample: 'class BulletFlyweight { private static Map<String, BulletFlyweight> flyweights; ... }',
        icon: Icons.memory,
        compositionType: 'Resource Sharing',
      ),
      StructuralPatternInfo(
        id: 'proxy',
        name: 'Proxy',
        description: 'Provides placeholder/surrogate for another object',
        category: 'Access Control',
        difficulty: 'Intermediate',
        complexity: 6.0,
        keyBenefits: [
          'Lazy loading',
          'Access control',
          'Caching',
          'Remote access'
        ],
        useCases: [
          'Resource-intensive objects',
          'Security',
          'Caching',
          'Remote objects'
        ],
        relatedPatterns: ['Adapter', 'Decorator', 'Facade'],
        towerDefenseExample: 'Tower proxies enable lazy asset loading - game starts fast, tower graphics/sounds load only when towers are placed.',
        codeExample: 'class TowerProxy implements Tower { private Tower realTower; ... }',
        icon: Icons.shield,
        compositionType: 'Access Control',
      ),
    ];
  }

  /// Bridge pattern demo execution
  Future<void> _executeBridgeDemo(List<String> log,
      Map<String, dynamic> results,
      Emitter<StructuralPatternsState> emit,) async {
    log.add('Creating tower abstraction layer...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Abstraction', progress: 0.2, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Implementing platform-specific renderers (Mobile/Desktop/Web)...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Implementation', progress: 0.5, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 400));

    log.add('Bridging towers to platform renderers...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Bridging', progress: 0.8, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    results['platforms_supported'] = ['Mobile', 'Desktop', 'Web'];
    results['performance_consistency'] = '95%';
    results['tower_defense_benefit'] = 'Same towers work across all platforms';

    log.add('✓ Bridge demonstration completed - Multi-platform tower support');
  }

  /// Composite pattern demo execution
  Future<void> _executeCompositeDemo(List<String> log,
      Map<String, dynamic> results,
      Emitter<StructuralPatternsState> emit,) async {
    log.add('Creating individual towers...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Individual', progress: 0.2, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Organizing towers into groups and formations...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Groups', progress: 0.6, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 400));

    log.add('Testing uniform command interface...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Commands', progress: 0.9, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 200));

    results['towers_created'] = 12;
    results['groups_formed'] = 3;
    results['command_uniformity'] = 'Single interface for all operations';
    results['tower_defense_benefit'] =
    'Manage individual towers and groups identically';

    log.add('✓ Composite demonstration completed - Unified tower management');
  }

  /// Decorator pattern demo execution
  Future<void> _executeDecoratorDemo(List<String> log,
      Map<String, dynamic> results,
      Emitter<StructuralPatternsState> emit,) async {
    log.add('Creating base tower...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Base', progress: 0.15, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 250));

    log.add('Adding fire damage enhancement...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Fire', progress: 0.35, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Adding freeze effect...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Freeze', progress: 0.55, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Adding double shot capability...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Double Shot', progress: 0.75, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Testing stacked enhancements...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Testing', progress: 0.95, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 200));

    results['base_damage'] = 100;
    results['enhanced_damage'] = 250;
    results['effects_applied'] = ['Fire', 'Freeze', 'Double Shot'];
    results['enhancement_stack'] = '3 layers deep';
    results['tower_defense_benefit'] =
    'Mix and match enhancements without subclass explosion';

    log.add('✓ Decorator demonstration completed - Dynamic tower enhancement');
  }

  /// Facade pattern demo execution
  Future<void> _executeFacadeDemo(List<String> log,
      Map<String, dynamic> results,
      Emitter<StructuralPatternsState> emit,) async {
    log.add('Initializing game subsystems...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Initialize', progress: 0.2, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Creating game facade interface...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Facade', progress: 0.4, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Starting wave through facade...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Wave Start', progress: 0.7, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 400));

    log.add('Coordinating all subsystems...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Coordination', progress: 0.9, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 200));

    results['subsystems_coordinated'] =
    ['Enemy Spawning', 'Tower Activation', 'UI Updates', 'Sound Effects'];
    results['complexity_hidden'] = '15 internal calls simplified to 1';
    results['client_interface'] = 'gameStart(), nextWave(), gamePause()';
    results['tower_defense_benefit'] =
    'Simple game control despite complex internal systems';

    log.add('✓ Facade demonstration completed - Simplified game interface');
  }

  /// Flyweight pattern demo execution
  Future<void> _executeFlyweightDemo(List<String> log,
      Map<String, dynamic> results,
      Emitter<StructuralPatternsState> emit,) async {
    log.add('Creating bullet types (flyweights)...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Types', progress: 0.2, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Spawning 1000 bullets with shared flyweights...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Spawning', progress: 0.6, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 500));

    log.add('Measuring memory usage...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Memory', progress: 0.9, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 200));

    results['bullet_instances'] = 1000;
    results['flyweight_types'] = 5;
    results['memory_saved'] = '95%';
    results['memory_usage'] = '50KB vs 1MB without flyweight';
    results['shared_data'] = ['Sprite', 'Sound', 'Particle Effects'];
    results['tower_defense_benefit'] =
    'Thousands of bullets with minimal memory impact';

    log.add('✓ Flyweight demonstration completed - Optimized bullet system');
  }

  /// Proxy pattern demo execution
  Future<void> _executeProxyDemo(List<String> log,
      Map<String, dynamic> results,
      Emitter<StructuralPatternsState> emit,) async {
    log.add('Setting up tower proxies for lazy loading...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Proxies', progress: 0.2, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Game starts - towers not yet loaded...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Game Start', progress: 0.4, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 300));

    log.add('Player places first tower - loading assets on demand...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Lazy Load', progress: 0.7, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 400));

    log.add('Subsequent towers use cached real objects...');
    add(UpdateStructuralPatternDemoProgress(
        stage: 'Cache Hit', progress: 0.95, logs: [log.last]));
    await Future.delayed(const Duration(milliseconds: 200));

    results['towers_proxied'] = 8;
    results['startup_time'] = '2.1s vs 8.5s without proxy';
    results['assets_loaded'] = 'On-demand (60% reduction in initial loading)';
    results['cache_hits'] = '85%';
    results['tower_defense_benefit'] =
    'Fast game startup with lazy asset loading';

    log.add('✓ Proxy demonstration completed - Lazy-loaded tower system');
  }
}