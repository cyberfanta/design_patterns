/// Creational Patterns Cubit - State Management for Creational Category
///
/// PATTERN: Command Pattern + State Pattern - Manages pattern loading and favorites
/// WHERE: Design Patterns feature - Creational patterns state management
/// HOW: Uses Cubit for simple state management with immutable states
/// WHY: Implements MVC architecture with Cubits as specified for Creational category
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../pages/creational_patterns_page.dart';

/// Cubit for managing creational patterns state
class CreationalPatternsCubit extends Cubit<CreationalPatternsState> {
  CreationalPatternsCubit() : super(CreationalPatternsInitial());

  List<PatternInfo> _allPatterns = [];
  List<PatternInfo> _favoritePatterns = [];

  /// Load all creational patterns
  Future<void> loadPatterns() async {
    emit(CreationalPatternsLoading());

    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Load patterns (in real app, this would come from repository)
      _allPatterns = _getAllCreationalPatterns();

      // Load favorites from local storage (simplified)
      _favoritePatterns = await _loadFavorites();

      emit(
        CreationalPatternsLoaded(
          patterns: _allPatterns,
          favoritePatterns: _favoritePatterns,
        ),
      );
    } catch (e) {
      emit(CreationalPatternsError(message: e.toString()));
    }
  }

  /// Toggle favorite status for a pattern
  void toggleFavorite(PatternInfo pattern) {
    if (state is CreationalPatternsLoaded) {
      final currentState = state as CreationalPatternsLoaded;
      List<PatternInfo> updatedFavorites;

      if (_favoritePatterns.contains(pattern)) {
        updatedFavorites = List.from(_favoritePatterns)..remove(pattern);
      } else {
        updatedFavorites = List.from(_favoritePatterns)..add(pattern);
      }

      _favoritePatterns = updatedFavorites;

      // Save to local storage (simplified)
      _saveFavorites(updatedFavorites);

      emit(
        CreationalPatternsLoaded(
          patterns: currentState.patterns,
          favoritePatterns: updatedFavorites,
        ),
      );
    }
  }

  /// Filter patterns by difficulty
  void filterByDifficulty(String difficulty) {
    if (state is CreationalPatternsLoaded) {
      final filteredPatterns = _allPatterns
          .where(
            (pattern) => difficulty.isEmpty || pattern.difficulty == difficulty,
          )
          .toList();

      emit(
        CreationalPatternsLoaded(
          patterns: filteredPatterns,
          favoritePatterns: _favoritePatterns,
        ),
      );
    }
  }

  /// Search patterns by name or description
  void searchPatterns(String query) {
    if (state is CreationalPatternsLoaded) {
      if (query.isEmpty) {
        emit(
          CreationalPatternsLoaded(
            patterns: _allPatterns,
            favoritePatterns: _favoritePatterns,
          ),
        );
        return;
      }

      final filteredPatterns = _allPatterns
          .where(
            (pattern) =>
                pattern.name.toLowerCase().contains(query.toLowerCase()) ||
                pattern.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      emit(
        CreationalPatternsLoaded(
          patterns: filteredPatterns,
          favoritePatterns: _favoritePatterns,
        ),
      );
    }
  }

  /// Mark pattern as completed
  void markPatternCompleted(PatternInfo pattern) {
    // In real app, this would update user progress
    // For now, just emit a success state
    if (state is CreationalPatternsLoaded) {
      final currentState = state as CreationalPatternsLoaded;
      emit(
        CreationalPatternsLoaded(
          patterns: currentState.patterns,
          favoritePatterns: currentState.favoritePatterns,
        ),
      );
    }
  }

  /// Get all creational patterns
  List<PatternInfo> _getAllCreationalPatterns() {
    return [
      PatternInfo(
        name: 'Factory Method',
        description: 'Create objects without specifying their concrete classes',
        icon: Icons.build,
        difficulty: 'Beginner',
        useCases: const [
          'Tower creation',
          'Enemy spawning',
          'Projectile generation',
        ],
        towerDefenseContext:
            'Different tower types (Archer, Cannon, Magic) created through factory methods',
      ),
      PatternInfo(
        name: 'Abstract Factory',
        description: 'Create families of related objects',
        icon: Icons.factory,
        difficulty: 'Intermediate',
        useCases: const [
          'Theme systems',
          'Platform-specific UI',
          'Game difficulty levels',
        ],
        towerDefenseContext:
            'Medieval, Futuristic, and Fantasy tower families with matching environments',
      ),
      PatternInfo(
        name: 'Builder',
        description: 'Construct complex objects step by step',
        icon: Icons.handyman,
        difficulty: 'Intermediate',
        useCases: const [
          'Tower customization',
          'Level generation',
          'Player configuration',
        ],
        towerDefenseContext:
            'Building customized towers with different upgrades, weapons, and special abilities',
      ),
      PatternInfo(
        name: 'Singleton',
        description: 'Ensure a class has only one instance',
        icon: Icons.looks_one,
        difficulty: 'Beginner',
        useCases: const [
          'Game manager',
          'Audio controller',
          'Settings manager',
        ],
        towerDefenseContext:
            'Game state manager controlling wave progression and global game rules',
      ),
      PatternInfo(
        name: 'Prototype',
        description: 'Create objects by cloning existing instances',
        icon: Icons.content_copy,
        difficulty: 'Intermediate',
        useCases: const ['Enemy templates', 'Tower presets', 'Level copying'],
        towerDefenseContext:
            'Cloning enemy units with variations and pre-configured tower setups',
      ),
    ];
  }

  /// Load favorites from local storage
  Future<List<PatternInfo>> _loadFavorites() async {
    // Simulate loading from local storage
    await Future.delayed(const Duration(milliseconds: 200));

    // In real app, would load from SharedPreferences or SQLite
    return [];
  }

  /// Save favorites to local storage
  Future<void> _saveFavorites(List<PatternInfo> favorites) async {
    // Simulate saving to local storage
    await Future.delayed(const Duration(milliseconds: 100));

    // In real app, would save to SharedPreferences or SQLite
    // Could also sync with user profile in Firebase
  }
}

/// Base state for creational patterns
abstract class CreationalPatternsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class CreationalPatternsInitial extends CreationalPatternsState {}

/// Loading state
class CreationalPatternsLoading extends CreationalPatternsState {}

/// Loaded state with patterns data
class CreationalPatternsLoaded extends CreationalPatternsState {
  final List<PatternInfo> patterns;
  final List<PatternInfo> favoritePatterns;

  CreationalPatternsLoaded({
    required this.patterns,
    required this.favoritePatterns,
  });

  @override
  List<Object?> get props => [patterns, favoritePatterns];
}

/// Error state
class CreationalPatternsError extends CreationalPatternsState {
  final String message;

  CreationalPatternsError({required this.message});

  @override
  List<Object?> get props => [message];
}
