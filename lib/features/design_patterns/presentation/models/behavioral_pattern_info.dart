/// Behavioral Pattern Info Model - Data model for behavioral patterns
///
/// PATTERN: Value Object Pattern + Data Transfer Object
/// WHERE: Behavioral Patterns feature - Pattern information model
/// HOW: Encapsulates all behavioral pattern data with Tower Defense context
/// WHY: Provides strongly-typed data structure for behavioral pattern information
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Information model for behavioral patterns.
///
/// Contains comprehensive pattern data including Tower Defense context,
/// metrics, and relationships for educational purposes.
class BehavioralPatternInfo extends Equatable {
  final String name;
  final String description;
  final String difficulty;
  final String category;
  final List<String> keyBenefits;
  final List<String> useCases;
  final List<String> relatedPatterns;
  final String towerDefenseExample;
  final String towerDefenseContext;
  final String communicationType;
  final IconData? icon;
  final double complexity;
  final bool isPopular;

  const BehavioralPatternInfo({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.keyBenefits,
    required this.useCases,
    required this.relatedPatterns,
    required this.towerDefenseExample,
    required this.towerDefenseContext,
    required this.communicationType,
    this.icon,
    required this.complexity,
    this.isPopular = false,
  });

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
    communicationType,
    icon,
    complexity,
    isPopular,
  ];

  /// Copy with method for creating modified instances
  BehavioralPatternInfo copyWith({
    String? name,
    String? description,
    String? difficulty,
    String? category,
    List<String>? keyBenefits,
    List<String>? useCases,
    List<String>? relatedPatterns,
    String? towerDefenseExample,
    String? towerDefenseContext,
    String? communicationType,
    IconData? icon,
    double? complexity,
    bool? isPopular,
  }) {
    return BehavioralPatternInfo(
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      keyBenefits: keyBenefits ?? this.keyBenefits,
      useCases: useCases ?? this.useCases,
      relatedPatterns: relatedPatterns ?? this.relatedPatterns,
      towerDefenseExample: towerDefenseExample ?? this.towerDefenseExample,
      towerDefenseContext: towerDefenseContext ?? this.towerDefenseContext,
      communicationType: communicationType ?? this.communicationType,
      icon: icon ?? this.icon,
      complexity: complexity ?? this.complexity,
      isPopular: isPopular ?? this.isPopular,
    );
  }

  /// Create from map (useful for serialization)
  factory BehavioralPatternInfo.fromMap(Map<String, dynamic> map) {
    return BehavioralPatternInfo(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'Beginner',
      category: map['category'] ?? 'Unknown',
      keyBenefits: List<String>.from(map['keyBenefits'] ?? []),
      useCases: List<String>.from(map['useCases'] ?? []),
      relatedPatterns: List<String>.from(map['relatedPatterns'] ?? []),
      towerDefenseExample: map['towerDefenseExample'] ?? '',
      towerDefenseContext: map['towerDefenseContext'] ?? '',
      communicationType: map['communicationType'] ?? '',
      icon: map['icon'],
      // IconData serialization would need custom handling
      complexity: (map['complexity'] ?? 0.0).toDouble(),
      isPopular: map['isPopular'] ?? false,
    );
  }

  /// Convert to map (useful for serialization)
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
      'communicationType': communicationType,
      'icon': icon?.codePoint, // Store icon as codePoint
      'complexity': complexity,
      'isPopular': isPopular,
    };
  }
}

/// Enum for different view modes in behavioral patterns page
enum ViewMode { dashboard, constellation, list }
