/// Structural Patterns Bloc - MVP Architecture with BLoC
///
/// PATTERN: Business Logic Component (BLoC) for MVP architecture
/// WHERE: Design Patterns feature - Structural patterns state management
/// HOW: Manages complex state transitions and business logic for structural patterns
/// WHY: Implements MVP architecture with BLoCs as specified for Structural category
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc for managing structural patterns state in MVP architecture
class StructuralPatternsBloc
    extends Bloc<StructuralPatternsEvent, StructuralPatternsState> {
  StructuralPatternsBloc() : super(StructuralPatternsInitial()) {
    on<LoadStructuralPatterns>(_onLoadPatterns);
    on<ToggleStructuralPatternFavorite>(_onToggleFavorite);
  }

  List<StructuralPatternInfo> _allPatterns = [];
  final List<StructuralPatternInfo> _favoritePatterns = [];

  /// Handle loading structural patterns
  Future<void> _onLoadPatterns(
    LoadStructuralPatterns event,
    Emitter<StructuralPatternsState> emit,
  ) async {
    emit(StructuralPatternsLoading());

    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 1200));

      _allPatterns = _getStructuralPatterns();

      emit(
        StructuralPatternsLoaded(
          patterns: _allPatterns,
          favoritePatterns: _favoritePatterns,
        ),
      );
    } catch (e) {
      emit(StructuralPatternsError(message: e.toString()));
    }
  }

  /// Handle toggling favorite status
  void _onToggleFavorite(
    ToggleStructuralPatternFavorite event,
    Emitter<StructuralPatternsState> emit,
  ) {
    if (_favoritePatterns.contains(event.pattern)) {
      _favoritePatterns.remove(event.pattern);
    } else {
      _favoritePatterns.add(event.pattern);
    }

    if (state is StructuralPatternsLoaded) {
      emit(
        StructuralPatternsLoaded(
          patterns: _allPatterns,
          favoritePatterns: _favoritePatterns,
        ),
      );
    }
  }

  /// Get structural patterns data
  List<StructuralPatternInfo> _getStructuralPatterns() {
    return [
      StructuralPatternInfo(
        name: 'Adapter',
        description: 'Allow incompatible interfaces to work together',
        icon: Icons.electrical_services,
        difficulty: 'Beginner',
        useCases: const [
          'API integration',
          'Legacy system integration',
          'Third-party libraries',
        ],
        towerDefenseContext:
            'Adapt different enemy types to work with common damage calculation system',
        compositionType: 'Interface adaptation',
      ),
      StructuralPatternInfo(
        name: 'Decorator',
        description: 'Add behavior to objects without altering structure',
        icon: Icons.layers,
        difficulty: 'Intermediate',
        useCases: const ['Feature enhancement', 'UI theming', 'Middleware'],
        towerDefenseContext:
            'Add weapon upgrades, armor, and special abilities to base tower classes',
        compositionType: 'Behavioral enhancement',
      ),
      StructuralPatternInfo(
        name: 'Facade',
        description: 'Provide unified interface to subsystem',
        icon: Icons.dashboard,
        difficulty: 'Beginner',
        useCases: const [
          'API simplification',
          'Complex system abstraction',
          'Library wrapping',
        ],
        towerDefenseContext:
            'Game controller facade managing towers, enemies, UI, and scoring',
        compositionType: 'Interface simplification',
      ),
      StructuralPatternInfo(
        name: 'Composite',
        description: 'Compose objects into tree structures',
        icon: Icons.account_tree,
        difficulty: 'Intermediate',
        useCases: const [
          'UI hierarchies',
          'File systems',
          'Organization charts',
        ],
        towerDefenseContext:
            'Tower upgrade trees and enemy group hierarchies with nested structures',
        compositionType: 'Tree composition',
      ),
      StructuralPatternInfo(
        name: 'Bridge',
        description: 'Separate abstraction from implementation',
        icon: Icons.connect_without_contact,
        difficulty: 'Advanced',
        useCases: const [
          'Platform abstraction',
          'Driver interfaces',
          'Multi-platform support',
        ],
        towerDefenseContext:
            'Separate tower behavior from platform-specific rendering and input',
        compositionType: 'Abstraction separation',
      ),
      StructuralPatternInfo(
        name: 'Proxy',
        description: 'Provide placeholder or surrogate for another object',
        icon: Icons.security,
        difficulty: 'Intermediate',
        useCases: const ['Lazy loading', 'Access control', 'Caching'],
        towerDefenseContext:
            'Lazy-loaded tower assets and cached enemy behavior patterns',
        compositionType: 'Object surrogate',
      ),
      StructuralPatternInfo(
        name: 'Flyweight',
        description: 'Share common data efficiently among many objects',
        icon: Icons.memory,
        difficulty: 'Advanced',
        useCases: const [
          'Memory optimization',
          'Object pooling',
          'Shared resources',
        ],
        towerDefenseContext:
            'Share common enemy sprites and tower components across many instances',
        compositionType: 'Resource sharing',
      ),
    ];
  }
}

/// Base event class for structural patterns
abstract class StructuralPatternsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to load structural patterns
class LoadStructuralPatterns extends StructuralPatternsEvent {}

/// Event to toggle pattern favorite status
class ToggleStructuralPatternFavorite extends StructuralPatternsEvent {
  final StructuralPatternInfo pattern;

  ToggleStructuralPatternFavorite(this.pattern);

  @override
  List<Object?> get props => [pattern];
}

/// Base state class for structural patterns
abstract class StructuralPatternsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class StructuralPatternsInitial extends StructuralPatternsState {}

/// Loading state
class StructuralPatternsLoading extends StructuralPatternsState {}

/// Loaded state with patterns data
class StructuralPatternsLoaded extends StructuralPatternsState {
  final List<StructuralPatternInfo> patterns;
  final List<StructuralPatternInfo> favoritePatterns;

  StructuralPatternsLoaded({
    required this.patterns,
    required this.favoritePatterns,
  });

  @override
  List<Object?> get props => [patterns, favoritePatterns];
}

/// Error state
class StructuralPatternsError extends StructuralPatternsState {
  final String message;

  StructuralPatternsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Data model for structural pattern information
class StructuralPatternInfo {
  final String name;
  final String description;
  final IconData icon;
  final String difficulty;
  final List<String> useCases;
  final String towerDefenseContext;
  final String compositionType; // Unique to structural patterns

  StructuralPatternInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.difficulty,
    required this.useCases,
    required this.towerDefenseContext,
    required this.compositionType,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StructuralPatternInfo && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
