/// Structural Patterns Events - MVP + Bloc Architecture
///
/// PATTERN: Command Pattern + Event-driven Architecture - Events for structural patterns
/// WHERE: Presentation layer events for structural design patterns (MVP Model communication)
/// HOW: Immutable event classes trigger state changes through BLoC
/// WHY: MVP architecture with BLoC provides clean separation between UI and business logic
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base event for Structural Patterns BLoC
///
/// PATTERN: Command Pattern - Encapsulates requests as objects
abstract class StructuralPatternsEvent extends Equatable {
  const StructuralPatternsEvent();

  @override
  List<Object?> get props => [];

  /// Log event for debugging and analytics
  void logEvent() {
    Log.debug('StructuralPatternsEvent: $runtimeType');
  }
}

/// Event to load all structural patterns
class LoadStructuralPatterns extends StructuralPatternsEvent {
  final bool forceRefresh;

  const LoadStructuralPatterns({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  void logEvent() {
    Log.debug(
      'StructuralPatternsEvent: LoadStructuralPatterns (forceRefresh: $forceRefresh)',
    );
  }
}

/// Event to change current page in PageView
class ChangeStructuralPatternsPage extends StructuralPatternsEvent {
  final int pageIndex;

  const ChangeStructuralPatternsPage(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];

  @override
  void logEvent() {
    Log.debug(
      'StructuralPatternsEvent: ChangeStructuralPatternsPage to $pageIndex',
    );
  }
}

/// Event to select a specific pattern for detailed view
class SelectStructuralPattern extends StructuralPatternsEvent {
  final StructuralPatternInfo pattern;

  const SelectStructuralPattern(this.pattern);

  @override
  List<Object?> get props => [pattern];

  @override
  void logEvent() {
    Log.debug(
      'StructuralPatternsEvent: SelectStructuralPattern - ${pattern.name}',
    );
  }
}

/// Event to clear current pattern selection
class ClearStructuralPatternSelection extends StructuralPatternsEvent {
  const ClearStructuralPatternSelection();

  @override
  void logEvent() {
    Log.debug('StructuralPatternsEvent: ClearStructuralPatternSelection');
  }
}

/// Event to toggle pattern as favorite
class ToggleStructuralPatternFavorite extends StructuralPatternsEvent {
  final String patternId;

  const ToggleStructuralPatternFavorite(this.patternId);

  @override
  List<Object?> get props => [patternId];

  @override
  void logEvent() {
    Log.debug(
      'StructuralPatternsEvent: ToggleStructuralPatternFavorite - $patternId',
    );
  }
}

/// Event to search patterns by query
class SearchStructuralPatterns extends StructuralPatternsEvent {
  final String query;

  const SearchStructuralPatterns(this.query);

  @override
  List<Object?> get props => [query];

  @override
  void logEvent() {
    Log.debug('StructuralPatternsEvent: SearchStructuralPatterns - "$query"');
  }
}

/// Event to filter patterns by complexity level
class FilterStructuralPatternsByComplexity extends StructuralPatternsEvent {
  final String complexityLevel;

  const FilterStructuralPatternsByComplexity(this.complexityLevel);

  @override
  List<Object?> get props => [complexityLevel];

  @override
  void logEvent() {
    Log.debug(
      'StructuralPatternsEvent: FilterStructuralPatternsByComplexity - $complexityLevel',
    );
  }
}

/// Event to start pattern demonstration
class StartStructuralPatternDemo extends StructuralPatternsEvent {
  final StructuralPatternInfo pattern;
  final Map<String, dynamic> demoParams;

  const StartStructuralPatternDemo(this.pattern, {this.demoParams = const {}});

  @override
  List<Object?> get props => [pattern, demoParams];

  @override
  void logEvent() {
    Log.debug(
      'StructuralPatternsEvent: StartStructuralPatternDemo - ${pattern.name}',
    );
  }
}

/// Event to stop current pattern demonstration
class StopStructuralPatternDemo extends StructuralPatternsEvent {
  const StopStructuralPatternDemo();

  @override
  void logEvent() {
    Log.debug('StructuralPatternsEvent: StopStructuralPatternDemo');
  }
}

/// Event to update demo progress
class UpdateStructuralPatternDemoProgress extends StructuralPatternsEvent {
  final String stage;
  final double progress;
  final List<String> logs;

  const UpdateStructuralPatternDemoProgress({
    required this.stage,
    required this.progress,
    required this.logs,
  });

  @override
  List<Object?> get props => [stage, progress, logs];

  @override
  void logEvent() {
    Log.debug(
      'StructuralPatternsEvent: UpdateStructuralPatternDemoProgress - $stage ($progress%)',
    );
  }
}

/// Event to toggle pattern code visibility
class ToggleStructuralPatternCode extends StructuralPatternsEvent {
  final String patternId;

  const ToggleStructuralPatternCode(this.patternId);

  @override
  List<Object?> get props => [patternId];

  @override
  void logEvent() {
    Log.debug(
      'StructuralPatternsEvent: ToggleStructuralPatternCode - $patternId',
    );
  }
}

/// Event to sort patterns by criteria
class SortStructuralPatterns extends StructuralPatternsEvent {
  final StructuralPatternSortCriteria criteria;
  final bool ascending;

  const SortStructuralPatterns(this.criteria, {this.ascending = true});

  @override
  List<Object?> get props => [criteria, ascending];

  @override
  void logEvent() {
    Log.debug(
      'StructuralPatternsEvent: SortStructuralPatterns by $criteria (${ascending ? 'asc' : 'desc'})',
    );
  }
}

/// Event to refresh pattern data
class RefreshStructuralPatterns extends StructuralPatternsEvent {
  const RefreshStructuralPatterns();

  @override
  void logEvent() {
    Log.debug('StructuralPatternsEvent: RefreshStructuralPatterns');
  }
}

/// Event to show pattern comparison
class ShowStructuralPatternsComparison extends StructuralPatternsEvent {
  final List<StructuralPatternInfo> patterns;

  const ShowStructuralPatternsComparison(this.patterns);

  @override
  List<Object?> get props => [patterns];

  @override
  void logEvent() {
    Log.debug(
      'StructuralPatternsEvent: ShowStructuralPatternsComparison - ${patterns.length} patterns',
    );
  }
}

/// Event to hide pattern comparison
class HideStructuralPatternsComparison extends StructuralPatternsEvent {
  const HideStructuralPatternsComparison();

  @override
  void logEvent() {
    Log.debug('StructuralPatternsEvent: HideStructuralPatternsComparison');
  }
}

/// Event to set layout mode (grid, list, card)
class SetStructuralPatternsLayoutMode extends StructuralPatternsEvent {
  final StructuralPatternLayoutMode layoutMode;

  const SetStructuralPatternsLayoutMode(this.layoutMode);

  @override
  List<Object?> get props => [layoutMode];

  @override
  void logEvent() {
    Log.debug(
      'StructuralPatternsEvent: SetStructuralPatternsLayoutMode - $layoutMode',
    );
  }
}

/// Sorting criteria enumeration
enum StructuralPatternSortCriteria {
  name,
  complexity,
  popularity,
  category,
  difficulty;

  String get displayName {
    switch (this) {
      case StructuralPatternSortCriteria.name:
        return 'Name';
      case StructuralPatternSortCriteria.complexity:
        return 'Complexity';
      case StructuralPatternSortCriteria.popularity:
        return 'Popularity';
      case StructuralPatternSortCriteria.category:
        return 'Category';
      case StructuralPatternSortCriteria.difficulty:
        return 'Difficulty';
    }
  }
}

/// Layout mode enumeration for displaying patterns
enum StructuralPatternLayoutMode {
  grid,
  list,
  card;

  String get displayName {
    switch (this) {
      case StructuralPatternLayoutMode.grid:
        return 'Grid View';
      case StructuralPatternLayoutMode.list:
        return 'List View';
      case StructuralPatternLayoutMode.card:
        return 'Card View';
    }
  }
}

/// Pattern information model for Structural Patterns
class StructuralPatternInfo extends Equatable {
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
  final Map<String, dynamic> metadata;

  // Additional fields for UI compatibility
  final IconData? icon;
  final String? compositionType;

  const StructuralPatternInfo({
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
    this.metadata = const {},
    this.icon,
    this.compositionType,
  });

  /// Getter for UI compatibility
  String get towerDefenseContext => towerDefenseExample;

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
    metadata,
    icon,
    compositionType,
  ];

  /// Creates a copy of this pattern with modified properties
  StructuralPatternInfo copyWith({
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
    Map<String, dynamic>? metadata,
    IconData? icon,
    String? compositionType,
  }) {
    return StructuralPatternInfo(
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
      metadata: metadata ?? this.metadata,
      icon: icon ?? this.icon,
      compositionType: compositionType ?? this.compositionType,
    );
  }

  /// Convert to analytics data for tracking
  Map<String, dynamic> toAnalytics() {
    return {
      'pattern_id': id,
      'pattern_name': name,
      'category': category,
      'difficulty': difficulty,
      'complexity': complexity,
      'is_popular': isPopular,
    };
  }
}

/// Extension for event analytics
extension StructuralPatternsEventAnalytics on StructuralPatternsEvent {
  Map<String, dynamic> toAnalytics() {
    final baseData = {
      'event_type': runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    switch (this) {
      case LoadStructuralPatterns event:
        return {...baseData, 'force_refresh': event.forceRefresh};
      case ChangeStructuralPatternsPage event:
        return {...baseData, 'page_index': event.pageIndex};
      case SelectStructuralPattern event:
        return {...baseData, ...event.pattern.toAnalytics()};
      case ToggleStructuralPatternFavorite event:
        return {...baseData, 'pattern_id': event.patternId};
      case SearchStructuralPatterns event:
        return {
          ...baseData,
          'query': event.query,
          'query_length': event.query.length,
        };
      case FilterStructuralPatternsByComplexity event:
        return {...baseData, 'complexity_level': event.complexityLevel};
      case StartStructuralPatternDemo event:
        return {
          ...baseData,
          ...event.pattern.toAnalytics(),
          'demo_params_count': event.demoParams.length,
        };
      case SortStructuralPatterns event:
        return {
          ...baseData,
          'sort_criteria': event.criteria.name,
          'ascending': event.ascending,
        };
      case SetStructuralPatternsLayoutMode event:
        return {...baseData, 'layout_mode': event.layoutMode.name};
      default:
        return baseData;
    }
  }
}
