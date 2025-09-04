/// Creational Patterns Cubit - MVC Architecture with Flutter Bloc
///
/// PATTERN: MVC Controller + Observer Pattern + State Pattern
/// WHERE: Design Patterns feature - Creational patterns business logic
/// HOW: Manages state transitions and business logic for creational patterns
/// WHY: Provides clean separation between UI and business logic with reactive state management
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/logging.dart';
import 'creational_patterns_state.dart';

/// MVC Controller - Cubit for managing Creational Patterns page state
/// 
/// PATTERN: MVC Controller + State Pattern - Manages business logic and state transitions
class CreationalPatternsCubit extends Cubit<CreationalPatternsState> {
  CreationalPatternsCubit() : super(CreationalPatternsInitial()) {
    Log.debug('CreationalPatternsCubit: MVC Controller initialized');
    loadPatterns();
  }

  /// Load all creational patterns (Controller action)
  Future<void> loadPatterns() async {
    emit(const CreationalPatternsLoading(message: 'Loading creational patterns...'));
    Log.debug('Loading creational patterns...');
    
    try {
      // Simulate data loading from Model layer
      await Future.delayed(const Duration(milliseconds: 500));
      
      final allPatterns = _getAllCreationalPatterns();
      final objectCreationPatterns = _getObjectCreationPatterns();  
      final instanceManagementPatterns = _getInstanceManagementPatterns();

      final loadedState = CreationalPatternsLoaded(
        allPatterns: allPatterns,
        objectCreationPatterns: objectCreationPatterns,
        instanceManagementPatterns: instanceManagementPatterns,
        filteredPatterns: allPatterns,
      );

      emit(loadedState);
      Log.debug('Patterns loaded successfully with ${loadedState.allPatterns.length} patterns');
      
    } catch (e) {
      final errorState = CreationalPatternsError(message: 'Failed to load patterns: $e');
      emit(errorState);
      Log.debug('Error in loadPatterns: $e');
    }
  }

  /// Select a specific pattern for detailed view
  void selectPattern(PatternInfo pattern) {
    final currentState = state;
    if (currentState is CreationalPatternsLoaded) {
      emit(currentState.copyWith(selectedPattern: pattern));
      Log.debug('CreationalPatternsCubit: Pattern selected: ${pattern.name}');
    }
  }

  /// Clear selected pattern
  void clearSelection() {
    final currentState = state;
    if (currentState is CreationalPatternsLoaded) {
      final newState = currentState.copyWith(selectedPattern: null);
      emit(newState);
      Log.debug('CreationalPatternsCubit: Selection cleared');
    }
  }

  /// Switch between different tabs (Object Creation, Instance Management)
  void switchTab(int tabIndex) {
    final currentState = state;
    if (currentState is CreationalPatternsLoaded) {
      emit(currentState.copyWith(selectedTabIndex: tabIndex));
      Log.debug('CreationalPatternsCubit: Switched to tab $tabIndex');
    }
  }

  /// Toggle expand/collapse for a pattern card
  void toggleExpanded(String patternId) {
    final currentState = state;
    if (currentState is CreationalPatternsLoaded) {
      final expandedStates = Map<String, bool>.from(currentState.expandedStates);
      expandedStates[patternId] = !(expandedStates[patternId] ?? false);
      
      emit(currentState.copyWith(expandedStates: expandedStates));
      Log.debug('CreationalPatternsCubit: Toggled expand for $patternId');
    }
  }

  /// Toggle favorite status for a pattern
  void toggleFavorite(String patternId) {
    final currentState = state;
    if (currentState is CreationalPatternsLoaded) {
      final favoritePatterns = Set<String>.from(currentState.favoritePatterns);
      
      if (favoritePatterns.contains(patternId)) {
        favoritePatterns.remove(patternId);
        Log.debug('CreationalPatternsCubit: Removed $patternId from favorites');
      } else {
        favoritePatterns.add(patternId);
        Log.debug('CreationalPatternsCubit: Added $patternId to favorites');
      }
      
      emit(currentState.copyWith(favoritePatterns: favoritePatterns));
    }
  }

  /// Search patterns by query
  void searchPatterns(String query) {
    final currentState = state;
    if (currentState is CreationalPatternsLoaded) {
      final filteredPatterns = query.isEmpty
          ? currentState.allPatterns
          : currentState.allPatterns.where((pattern) {
              return pattern.name.toLowerCase().contains(query.toLowerCase()) ||
                     pattern.description.toLowerCase().contains(query.toLowerCase()) ||
                     pattern.useCases.any((useCase) => 
                       useCase.toLowerCase().contains(query.toLowerCase()));
            }).toList();

      emit(currentState.copyWith(
        searchQuery: query,
        filteredPatterns: filteredPatterns,
      ));
      Log.debug('CreationalPatternsCubit: Search query: "$query", found ${filteredPatterns.length} patterns');
    }
  }

  /// Filter patterns by difficulty
  void filterByDifficulty(String difficulty) {
    final currentState = state;
    if (currentState is CreationalPatternsLoaded) {
      final filteredPatterns = difficulty == 'All'
          ? currentState.allPatterns
          : currentState.allPatterns.where((pattern) =>
              pattern.difficulty == difficulty).toList();

      emit(currentState.copyWith(
        selectedDifficulty: difficulty,
        filteredPatterns: filteredPatterns,
      ));
      Log.debug('CreationalPatternsCubit: Filtered by difficulty: $difficulty, found ${filteredPatterns.length} patterns');
    }
  }

  /// Run pattern demonstration
  Future<void> runPatternDemo(PatternInfo pattern) async {
    final demoRunningState = CreationalPatternExecuting(
      pattern: pattern,
      executionLog: 'Starting ${pattern.name} demonstration...\n',
      results: [],
    );

    emit(demoRunningState);
    Log.debug('CreationalPatternsCubit: Running demo for ${pattern.name}');

    try {
      // Simulate pattern execution
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final results = _executePatternDemo(pattern);
      
      final completedState = CreationalPatternExecuted(
        pattern: pattern,
        executionLog: '${demoRunningState.executionLog}Demo completed successfully!\n',
        results: results,
        executionTime: const Duration(milliseconds: 1500),
      );

      emit(completedState);
      Log.debug('CreationalPatternsCubit: Demo completed for ${pattern.name}');
      
    } catch (e) {
      final errorState = CreationalPatternsError(message: 'Demo execution failed: $e');
      emit(errorState);
      Log.debug('Error in runPatternDemo: $e');
    }
  }

  /// Execute pattern demonstration (simulated)
  List<String> _executePatternDemo(PatternInfo pattern) {
    switch (pattern.name) {
      case 'Singleton':
        return [
          'Creating first Tower instance: Tower@123',
          'Attempting to create second Tower instance...',
          'Returned existing instance: Tower@123',
          'Singleton pattern verified: Same instance returned!',
        ];
      case 'Factory Method':
        return [
          'TowerFactory.createTower(type: "Artillery")',
          'ArtilleryTowerFactory instantiated',
          'Created: ArtilleryTower (damage: 150, range: 8)',
          'Tower ready for deployment!',
        ];
      case 'Abstract Factory':
        return [
          'GameElementFactory.createFactory("Medieval")',
          'MedievalFactory instantiated',
          'Creating tower: CatapultTower',
          'Creating enemy: KnightEnemy',
          'Medieval game set ready!',
        ];
      case 'Builder':
        return [
          'TowerBuilder starting configuration...',
          'Setting damage: 200, range: 10',
          'Adding upgrade: "Double Shot"',
          'Building tower...',
          'SuperTower created successfully!',
        ];
      case 'Prototype':
        return [
          'TowerPrototype registry initialized',
          'Cloning ArcaneTower prototype',
          'Customizing cloned tower properties',
          'Tower clone deployed at position (5,7)',
          'Original prototype preserved for future use',
        ];
      default:
        return [
          'Pattern demonstration started',
          'Executing ${pattern.name} logic...',
          'Pattern completed successfully!',
        ];
    }
  }

  /// Get all creational patterns
  List<PatternInfo> _getAllCreationalPatterns() {
    return [
      ..._getObjectCreationPatterns(),
      ..._getInstanceManagementPatterns(),
    ];
  }

  /// Get object creation patterns
  List<PatternInfo> _getObjectCreationPatterns() {
    return [
      PatternInfo(
        name: 'Factory Method',
        description: 'Create objects through a common interface',
        difficulty: 'Intermediate',
        category: 'Object Creation',
        keyBenefits: ['Loose coupling', 'Easy extension', 'Single responsibility'],
        useCases: ['Object creation', 'Plugin systems', 'Framework extension'],
        relatedPatterns: ['Abstract Factory', 'Builder', 'Prototype'],
        towerDefenseExample: 'TowerFactory creates different tower types (Artillery, Magic, Sniper)',
        icon: Icons.factory,
        complexity: 6.0,
        isPopular: true,
      ),
      PatternInfo(
        name: 'Abstract Factory',
        description: 'Create families of related objects',
        difficulty: 'Advanced',
        category: 'Object Creation',
        keyBenefits: ['Consistent object families', 'Easy switching', 'Strong typing'],
        useCases: ['Theme systems', 'Cross-platform', 'Product families'],
        relatedPatterns: ['Factory Method', 'Singleton', 'Prototype'],
        towerDefenseExample: 'ElementalFactory creates fire/ice/earth tower+enemy combinations',
        icon: Icons.widgets,
        complexity: 8.0,
        isPopular: true,
      ),
      PatternInfo(
        name: 'Builder',
        description: 'Construct complex objects step by step',
        difficulty: 'Intermediate',
        category: 'Object Creation',
        keyBenefits: ['Flexible construction', 'Readable code', 'Immutable objects'],
        useCases: ['Complex configuration', 'Fluent APIs', 'Optional parameters'],
        relatedPatterns: ['Abstract Factory', 'Composite', 'Strategy'],
        towerDefenseExample: 'TowerBuilder configures damage, range, upgrades, and special abilities',
        icon: Icons.construction,
        complexity: 5.5,
        isPopular: true,
      ),
    ];
  }

  /// Get instance management patterns
  List<PatternInfo> _getInstanceManagementPatterns() {
    return [
      PatternInfo(
        name: 'Singleton',
        description: 'Ensure only one instance exists globally',
        difficulty: 'Beginner',
        category: 'Instance Management',
        keyBenefits: ['Global access', 'Resource control', 'State consistency'],
        useCases: ['Configuration', 'Logging', 'Caching'],
        relatedPatterns: ['Factory Method', 'Observer', 'State'],
        towerDefenseExample: 'GameManager singleton controls game state, score, and wave progression',
        icon: Icons.looks_one,
        complexity: 3.0,
        isPopular: true,
      ),
      PatternInfo(
        name: 'Prototype',
        description: 'Create objects by cloning existing instances',
        difficulty: 'Intermediate',
        category: 'Instance Management',
        keyBenefits: ['Performance optimization', 'Dynamic creation', 'State preservation'],
        useCases: ['Object cloning', 'Template systems', 'Performance optimization'],
        relatedPatterns: ['Factory Method', 'Memento', 'Command'],
        towerDefenseExample: 'TowerPrototype registry for quickly spawning pre-configured tower templates',
        icon: Icons.copy,
        complexity: 6.5,
      ),
    ];
  }
}