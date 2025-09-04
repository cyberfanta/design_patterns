/// Behavioral Pattern Model - MVVM-C + GetX Data Model
///
/// PATTERN: Model Pattern - Data representation for behavioral design patterns
/// WHERE: Presentation layer model for behavioral design patterns (MVVM Model)
/// HOW: Immutable data class representing behavioral pattern information
/// WHY: MVVM architecture requires clean data models separated from business logic
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:equatable/equatable.dart';

/// Data model for Behavioral Patterns
///
/// PATTERN: Model Pattern - Represents behavioral pattern data
class BehavioralPatternModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String difficulty;
  final double complexity;
  final List<String> keyBenefits;
  final List<String> useCases;
  final List<String> relatedPatterns;
  final String towerDefenseExample;
  final String codeExample;
  final bool isPopular;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  BehavioralPatternModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.complexity,
    required this.keyBenefits,
    required this.useCases,
    required this.relatedPatterns,
    required this.towerDefenseExample,
    required this.codeExample,
    this.isPopular = false,
    DateTime? createdAt,
    this.metadata = const {},
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    difficulty,
    complexity,
    keyBenefits,
    useCases,
    relatedPatterns,
    towerDefenseExample,
    codeExample,
    isPopular,
    createdAt,
    metadata,
  ];

  /// Creates a copy of this model with modified properties
  BehavioralPatternModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? difficulty,
    double? complexity,
    List<String>? keyBenefits,
    List<String>? useCases,
    List<String>? relatedPatterns,
    String? towerDefenseExample,
    String? codeExample,
    bool? isPopular,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return BehavioralPatternModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      complexity: complexity ?? this.complexity,
      keyBenefits: keyBenefits ?? this.keyBenefits,
      useCases: useCases ?? this.useCases,
      relatedPatterns: relatedPatterns ?? this.relatedPatterns,
      towerDefenseExample: towerDefenseExample ?? this.towerDefenseExample,
      codeExample: codeExample ?? this.codeExample,
      isPopular: isPopular ?? this.isPopular,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'complexity': complexity,
      'keyBenefits': keyBenefits,
      'useCases': useCases,
      'relatedPatterns': relatedPatterns,
      'towerDefenseExample': towerDefenseExample,
      'codeExample': codeExample,
      'isPopular': isPopular,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory BehavioralPatternModel.fromJson(Map<String, dynamic> json) {
    try {
      return BehavioralPatternModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        difficulty: json['difficulty'] as String,
        complexity: (json['complexity'] as num).toDouble(),
        keyBenefits: List<String>.from(json['keyBenefits'] as List),
        useCases: List<String>.from(json['useCases'] as List),
        relatedPatterns: List<String>.from(json['relatedPatterns'] as List),
        towerDefenseExample: json['towerDefenseExample'] as String,
        codeExample: json['codeExample'] as String,
        isPopular: json['isPopular'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      );
    } catch (e) {
      Log.error('BehavioralPatternModel: Failed to parse from JSON - $e');
      rethrow;
    }
  }

  /// Convert to analytics data
  Map<String, dynamic> toAnalytics() {
    return {
      'pattern_id': id,
      'pattern_name': name,
      'category': category,
      'difficulty': difficulty,
      'complexity': complexity,
      'is_popular': isPopular,
      'benefits_count': keyBenefits.length,
      'use_cases_count': useCases.length,
      'related_patterns_count': relatedPatterns.length,
    };
  }

  /// Get display-friendly difficulty color
  String get difficultyColorHex {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return '#4CAF50'; // Green
      case 'intermediate':
        return '#FF9800'; // Orange
      case 'advanced':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get complexity level description
  String get complexityDescription {
    if (complexity <= 3.0) return 'Simple';
    if (complexity <= 5.0) return 'Easy';
    if (complexity <= 7.0) return 'Moderate';
    if (complexity <= 8.5) return 'Complex';
    return 'Very Complex';
  }

  /// Get formatted benefits string
  String get benefitsFormatted {
    return keyBenefits.join(' • ');
  }

  /// Get formatted use cases string
  String get useCasesFormatted {
    return useCases.join(' • ');
  }

  /// Get related patterns as formatted string
  String get relatedPatternsFormatted {
    return relatedPatterns.join(', ');
  }

  /// Check if pattern matches search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        category.toLowerCase().contains(lowerQuery) ||
        towerDefenseExample.toLowerCase().contains(lowerQuery) ||
        keyBenefits.any(
          (benefit) => benefit.toLowerCase().contains(lowerQuery),
        ) ||
        useCases.any((useCase) => useCase.toLowerCase().contains(lowerQuery)) ||
        relatedPatterns.any(
          (pattern) => pattern.toLowerCase().contains(lowerQuery),
        );
  }

  /// Get pattern summary for tooltips
  String get summary {
    return '$description. Used in: ${useCases.take(2).join(", ")}.';
  }

  /// Get code example preview (first 100 characters)
  String get codePreview {
    return codeExample.length > 100
        ? '${codeExample.substring(0, 100)}...'
        : codeExample;
  }

  @override
  String toString() {
    return 'BehavioralPatternModel(id: $id, name: $name, category: $category, difficulty: $difficulty)';
  }
}

/// Enumeration for behavioral pattern categories
enum BehavioralPatternCategory {
  communication('Communication', 'Object interaction and messaging'),
  algorithm('Algorithm', 'Algorithmic behavior and processing'),
  state('State Management', 'State-related behavioral patterns');

  const BehavioralPatternCategory(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Enumeration for behavioral pattern difficulty levels
enum BehavioralPatternDifficulty {
  beginner('Beginner', 1, '#4CAF50'),
  intermediate('Intermediate', 2, '#FF9800'),
  advanced('Advanced', 3, '#F44336');

  const BehavioralPatternDifficulty(
    this.displayName,
    this.level,
    this.colorHex,
  );

  final String displayName;
  final int level;
  final String colorHex;
}

/// Extensions for behavioral pattern utilities
extension BehavioralPatternModelExtensions on BehavioralPatternModel {
  /// Get category enum from string
  BehavioralPatternCategory? get categoryEnum {
    switch (category.toLowerCase()) {
      case 'communication':
        return BehavioralPatternCategory.communication;
      case 'algorithm':
        return BehavioralPatternCategory.algorithm;
      case 'state management':
        return BehavioralPatternCategory.state;
      default:
        return null;
    }
  }

  /// Get difficulty enum from string
  BehavioralPatternDifficulty? get difficultyEnum {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return BehavioralPatternDifficulty.beginner;
      case 'intermediate':
        return BehavioralPatternDifficulty.intermediate;
      case 'advanced':
        return BehavioralPatternDifficulty.advanced;
      default:
        return null;
    }
  }

  /// Check if pattern is communication-related
  bool get isCommunicationPattern {
    return category.toLowerCase() == 'communication';
  }

  /// Check if pattern is algorithm-related
  bool get isAlgorithmPattern {
    return category.toLowerCase() == 'algorithm';
  }

  /// Get estimated learning time in hours
  int get estimatedLearningHours {
    final baseHours = complexity.round();
    final difficultyMultiplier = difficultyEnum?.level ?? 2;
    return (baseHours * difficultyMultiplier / 2).round().clamp(1, 20);
  }

  /// Get Tower Defense relevance score (0-100)
  int get towerDefenseRelevanceScore {
    final exampleLength = towerDefenseExample.length;
    final useCaseRelevance = useCases
        .where(
          (useCase) =>
              useCase.toLowerCase().contains('tower') ||
              useCase.toLowerCase().contains('game') ||
              useCase.toLowerCase().contains('enemy'),
        )
        .length;

    final baseScore = ((exampleLength / 10) + (useCaseRelevance * 20))
        .clamp(0, 80)
        .round();
    return isPopular ? (baseScore + 20).clamp(0, 100) : baseScore;
  }
}
