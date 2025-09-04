/// Creational Patterns State Management - MVVM Architecture with Cubits
///
/// PATTERN: Observer Pattern - Notifies UI of state changes
/// WHERE: Design Patterns feature - Creational patterns state management
/// HOW: Uses Cubit to emit different states based on user interactions
/// WHY: Provides reactive state management for complex pattern interactions
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base state for CreationalPatternsPage
abstract class CreationalPatternsState extends Equatable {
  const CreationalPatternsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when page loads
class CreationalPatternsInitial extends CreationalPatternsState {}

/// Loading state while patterns are being loaded
class CreationalPatternsLoading extends CreationalPatternsState {
  final String? message;
  
  const CreationalPatternsLoading({this.message});
  
  @override
  List<Object?> get props => [message];
}

/// Loaded state with all pattern information
class CreationalPatternsLoaded extends CreationalPatternsState {
  final List<PatternInfo> allPatterns;
  final List<PatternInfo> objectCreationPatterns;
  final List<PatternInfo> instanceManagementPatterns;
  final int selectedTabIndex;
  final PatternInfo? selectedPattern;
  final Map<String, bool> expandedStates;
  final Set<String> favoritePatterns;
  final String searchQuery;
  final String selectedDifficulty;
  final List<PatternInfo> filteredPatterns;
  
  const CreationalPatternsLoaded({
    required this.allPatterns,
    required this.objectCreationPatterns,
    required this.instanceManagementPatterns,
    this.selectedTabIndex = 0,
    this.selectedPattern,
    this.expandedStates = const {},
    this.favoritePatterns = const {},
    this.searchQuery = '',
    this.selectedDifficulty = 'All',
    required this.filteredPatterns,
  });
  
  @override
  List<Object?> get props => [
    allPatterns,
    objectCreationPatterns,
    instanceManagementPatterns,
    selectedTabIndex,
    selectedPattern,
    expandedStates,
    favoritePatterns,
    searchQuery,
    selectedDifficulty,
    filteredPatterns,
  ];
  
  /// Copy with method for state updates
  CreationalPatternsLoaded copyWith({
    List<PatternInfo>? allPatterns,
    List<PatternInfo>? objectCreationPatterns,
    List<PatternInfo>? instanceManagementPatterns,
    int? selectedTabIndex,
    PatternInfo? selectedPattern,
    Map<String, bool>? expandedStates,
    Set<String>? favoritePatterns,
    String? searchQuery,
    String? selectedDifficulty,
    List<PatternInfo>? filteredPatterns,
  }) {
    return CreationalPatternsLoaded(
      allPatterns: allPatterns ?? this.allPatterns,
      objectCreationPatterns: objectCreationPatterns ?? this.objectCreationPatterns,
      instanceManagementPatterns: instanceManagementPatterns ?? this.instanceManagementPatterns,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedPattern: selectedPattern ?? this.selectedPattern,
      expandedStates: expandedStates ?? this.expandedStates,
      favoritePatterns: favoritePatterns ?? this.favoritePatterns,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      filteredPatterns: filteredPatterns ?? this.filteredPatterns,
    );
  }
}

/// Error state when pattern loading fails
class CreationalPatternsError extends CreationalPatternsState {
  final String message;
  final String error; // Added for compatibility
  final String? stackTrace;

  const CreationalPatternsError({
    required this.message,
    String? error,
    this.stackTrace,
  }) : error = error ?? message;

  @override
  List<Object?> get props => [message, error, stackTrace];
}

/// State when pattern is being executed/demonstrated
class CreationalPatternExecuting extends CreationalPatternsState {
  final PatternInfo pattern;
  final String executionLog;
  final List<String> results;

  const CreationalPatternExecuting({
    required this.pattern,
    required this.executionLog,
    required this.results,
  });

  @override
  List<Object> get props => [pattern, executionLog, results];
}

/// State when pattern execution is completed
class CreationalPatternExecuted extends CreationalPatternsState {
  final PatternInfo pattern;
  final String executionLog;
  final List<String> results;
  final Duration executionTime;

  const CreationalPatternExecuted({
    required this.pattern,
    required this.executionLog,
    required this.results,
    required this.executionTime,
  });
  
  @override
  List<Object?> get props => [pattern, executionLog, results, executionTime];
}

/// Pattern information model for Creational Patterns
class PatternInfo extends Equatable {
  final String name;
  final String description;
  final String difficulty;
  final String category;
  final List<String> keyBenefits;
  final List<String> useCases;
  final List<String> relatedPatterns;
  final String towerDefenseExample;
  final String towerDefenseContext; // Added for compatibility
  final IconData? icon; // Added for compatibility
  final bool isPopular;
  final double complexity;
  final Map<String, dynamic> metadata;

  const PatternInfo({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.keyBenefits,
    required this.useCases,
    required this.relatedPatterns,
    required this.towerDefenseExample,
    String? towerDefenseContext,
    this.icon,
    this.isPopular = false,
    required this.complexity,
    this.metadata = const {},
  }) : towerDefenseContext = towerDefenseContext ?? towerDefenseExample;

  @override
  List<Object?> get props => [
    name,
    description,
    difficulty,
    category,
    keyBenefits,
    useCases,
    relatedPatterns,
    towerDefenseExample,
    towerDefenseContext,
    icon,
    isPopular,
    complexity,
    metadata,
  ];

  /// Copy with method for immutable updates
  PatternInfo copyWith({
    String? name,
    String? description,
    String? difficulty,
    String? category,
    List<String>? keyBenefits,
    List<String>? useCases,
    List<String>? relatedPatterns,
    String? towerDefenseExample,
    String? towerDefenseContext,
    IconData? icon,
    bool? isPopular,
    double? complexity,
    Map<String, dynamic>? metadata,
  }) {
    return PatternInfo(
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      keyBenefits: keyBenefits ?? this.keyBenefits,
      useCases: useCases ?? this.useCases,
      relatedPatterns: relatedPatterns ?? this.relatedPatterns,
      towerDefenseExample: towerDefenseExample ?? this.towerDefenseExample,
      towerDefenseContext: towerDefenseContext ?? this.towerDefenseContext,
      icon: icon ?? this.icon,
      isPopular: isPopular ?? this.isPopular,
      complexity: complexity ?? this.complexity,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Create pattern info from map (for serialization)
  factory PatternInfo.fromMap(Map<String, dynamic> map) {
    return PatternInfo(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'Beginner',
      category: map['category'] ?? 'Unknown',
      keyBenefits: List<String>.from(map['keyBenefits'] ?? []),
      useCases: List<String>.from(map['useCases'] ?? []),
      relatedPatterns: List<String>.from(map['relatedPatterns'] ?? []),
      towerDefenseExample: map['towerDefenseExample'] ?? '',
      towerDefenseContext: map['towerDefenseContext'] ?? map['towerDefenseExample'] ?? '',
      icon: map['icon'], // This would need custom handling for IconData
      isPopular: map['isPopular'] ?? false,
      complexity: (map['complexity'] ?? 0).toDouble(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  /// Convert to map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'category': category,
      'keyBenefits': keyBenefits,
      'useCases': useCases,
      'relatedPatterns': relatedPatterns,
      'towerDefenseExample': towerDefenseExample,
      'towerDefenseContext': towerDefenseContext,
      'icon': icon?.codePoint, // Store codePoint for IconData
      'isPopular': isPopular,
      'complexity': complexity,
      'metadata': metadata,
    };
  }
}