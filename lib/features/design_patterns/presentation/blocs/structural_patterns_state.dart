/// Structural Patterns State - MVP + Bloc Architecture
///
/// PATTERN: State Pattern + MVP - Immutable states for structural patterns
/// WHERE: Presentation layer state management for structural design patterns (MVP View state)
/// HOW: Immutable state classes represent different UI states
/// WHY: MVP architecture with BLoC provides predictable state management and UI updates
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:equatable/equatable.dart';

import 'structural_patterns_event.dart';

/// Base state for Structural Patterns BLoC
///
/// PATTERN: State Pattern - Represents different states of the structural patterns page
abstract class StructuralPatternsState extends Equatable {
  const StructuralPatternsState();

  @override
  List<Object?> get props => [];

  /// Log state for debugging and analytics
  void logState() {
    Log.debug('StructuralPatternsState: $runtimeType');
  }
}

/// Initial state when the BLoC is created
class StructuralPatternsInitial extends StructuralPatternsState {
  const StructuralPatternsInitial();

  @override
  void logState() {
    Log.debug('StructuralPatternsState: Initial state - MVP ready');
  }
}

/// Loading state when fetching patterns data
class StructuralPatternsLoading extends StructuralPatternsState {
  final String message;
  final double? progress;

  const StructuralPatternsLoading({
    this.message = 'Loading structural patterns...',
    this.progress,
  });

  @override
  List<Object?> get props => [message, progress];

  @override
  void logState() {
    Log.debug(
      'StructuralPatternsState: Loading - $message ${progress != null ? '(${(progress! * 100).toInt()}%)' : ''}',
    );
  }
}

/// Success state with loaded patterns data
class StructuralPatternsLoaded extends StructuralPatternsState {
  final List<StructuralPatternInfo> allPatterns;
  final List<StructuralPatternInfo> compositionPatterns;
  final List<StructuralPatternInfo> behaviorPatterns;
  final List<StructuralPatternInfo> filteredPatterns;
  final int currentPageIndex;
  final StructuralPatternInfo? selectedPattern;
  final Set<String> favoritePatternIds;
  final Map<String, bool> codeVisibility;
  final String searchQuery;
  final String complexityFilter;
  final StructuralPatternSortCriteria sortCriteria;
  final bool sortAscending;
  final StructuralPatternLayoutMode layoutMode;
  final List<StructuralPatternInfo> comparisonPatterns;
  final bool isComparisonVisible;
  final DateTime lastUpdated;

  StructuralPatternsLoaded({
    required this.allPatterns,
    required this.compositionPatterns,
    required this.behaviorPatterns,
    required this.filteredPatterns,
    this.currentPageIndex = 0,
    this.selectedPattern,
    this.favoritePatternIds = const {},
    this.codeVisibility = const {},
    this.searchQuery = '',
    this.complexityFilter = 'All',
    this.sortCriteria = StructuralPatternSortCriteria.name,
    this.sortAscending = true,
    this.layoutMode = StructuralPatternLayoutMode.card,
    this.comparisonPatterns = const [],
    this.isComparisonVisible = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  @override
  List<Object?> get props => [
    allPatterns,
    compositionPatterns,
    behaviorPatterns,
    filteredPatterns,
    currentPageIndex,
    selectedPattern,
    favoritePatternIds,
    codeVisibility,
    searchQuery,
    complexityFilter,
    sortCriteria,
    sortAscending,
    layoutMode,
    comparisonPatterns,
    isComparisonVisible,
    lastUpdated,
  ];

  /// Creates a copy of this state with modified properties
  StructuralPatternsLoaded copyWith({
    List<StructuralPatternInfo>? allPatterns,
    List<StructuralPatternInfo>? compositionPatterns,
    List<StructuralPatternInfo>? behaviorPatterns,
    List<StructuralPatternInfo>? filteredPatterns,
    int? currentPageIndex,
    StructuralPatternInfo? selectedPattern,
    bool clearSelectedPattern = false,
    Set<String>? favoritePatternIds,
    Map<String, bool>? codeVisibility,
    String? searchQuery,
    String? complexityFilter,
    StructuralPatternSortCriteria? sortCriteria,
    bool? sortAscending,
    StructuralPatternLayoutMode? layoutMode,
    List<StructuralPatternInfo>? comparisonPatterns,
    bool? isComparisonVisible,
    DateTime? lastUpdated,
  }) {
    return StructuralPatternsLoaded(
      allPatterns: allPatterns ?? this.allPatterns,
      compositionPatterns: compositionPatterns ?? this.compositionPatterns,
      behaviorPatterns: behaviorPatterns ?? this.behaviorPatterns,
      filteredPatterns: filteredPatterns ?? this.filteredPatterns,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      selectedPattern: clearSelectedPattern
          ? null
          : (selectedPattern ?? this.selectedPattern),
      favoritePatternIds: favoritePatternIds ?? this.favoritePatternIds,
      codeVisibility: codeVisibility ?? this.codeVisibility,
      searchQuery: searchQuery ?? this.searchQuery,
      complexityFilter: complexityFilter ?? this.complexityFilter,
      sortCriteria: sortCriteria ?? this.sortCriteria,
      sortAscending: sortAscending ?? this.sortAscending,
      layoutMode: layoutMode ?? this.layoutMode,
      comparisonPatterns: comparisonPatterns ?? this.comparisonPatterns,
      isComparisonVisible: isComparisonVisible ?? this.isComparisonVisible,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Get patterns for current page
  List<StructuralPatternInfo> get currentPagePatterns {
    switch (currentPageIndex) {
      case 0:
        return allPatterns;
      case 1:
        return compositionPatterns;
      case 2:
        return behaviorPatterns;
      default:
        return allPatterns;
    }
  }

  /// Check if pattern is favorite
  bool isPatternFavorite(String patternId) {
    return favoritePatternIds.contains(patternId);
  }

  /// Check if pattern code is visible
  bool isPatternCodeVisible(String patternId) {
    return codeVisibility[patternId] ?? false;
  }

  /// Get filtered and sorted patterns
  List<StructuralPatternInfo> getProcessedPatterns() {
    var patterns = searchQuery.isEmpty ? allPatterns : filteredPatterns;

    // Apply complexity filter
    if (complexityFilter != 'All') {
      patterns = patterns
          .where((p) => p.difficulty == complexityFilter)
          .toList();
    }

    // Sort patterns
    patterns.sort((a, b) {
      int comparison = 0;

      switch (sortCriteria) {
        case StructuralPatternSortCriteria.name:
          comparison = a.name.compareTo(b.name);
          break;
        case StructuralPatternSortCriteria.complexity:
          comparison = a.complexity.compareTo(b.complexity);
          break;
        case StructuralPatternSortCriteria.popularity:
          comparison = a.isPopular
              ? (b.isPopular ? 0 : -1)
              : (b.isPopular ? 1 : 0);
          break;
        case StructuralPatternSortCriteria.category:
          comparison = a.category.compareTo(b.category);
          break;
        case StructuralPatternSortCriteria.difficulty:
          comparison = a.difficulty.compareTo(b.difficulty);
          break;
      }

      return sortAscending ? comparison : -comparison;
    });

    return patterns;
  }

  @override
  void logState() {
    Log.debug(
      'StructuralPatternsState: Loaded - ${allPatterns.length} patterns, page $currentPageIndex, ${favoritePatternIds.length} favorites',
    );
  }
}

/// Error state when something goes wrong
class StructuralPatternsError extends StructuralPatternsState {
  final String error;
  final String? stackTrace;
  final DateTime timestamp;
  final bool isRecoverable;

  StructuralPatternsError({
    required this.error,
    this.stackTrace,
    DateTime? timestamp,
    this.isRecoverable = true,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [error, stackTrace, timestamp, isRecoverable];

  @override
  void logState() {
    Log.error('StructuralPatternsState: Error - $error');
  }
}

/// State for pattern demonstration running
class StructuralPatternDemoRunning extends StructuralPatternsState {
  final StructuralPatternInfo pattern;
  final String currentStage;
  final double progress;
  final List<String> executionLog;
  final Map<String, dynamic> demoData;
  final DateTime startTime;

  StructuralPatternDemoRunning({
    required this.pattern,
    required this.currentStage,
    required this.progress,
    this.executionLog = const [],
    this.demoData = const {},
    DateTime? startTime,
  }) : startTime = startTime ?? DateTime.now();

  @override
  List<Object?> get props => [
    pattern,
    currentStage,
    progress,
    executionLog,
    demoData,
    startTime,
  ];

  /// Get elapsed time since demo started
  Duration get elapsedTime => DateTime.now().difference(startTime);

  @override
  void logState() {
    Log.debug(
      'StructuralPatternsState: Demo running for ${pattern.name} - $currentStage (${(progress * 100).toInt()}%)',
    );
  }
}

/// State for pattern demonstration completed
class StructuralPatternDemoCompleted extends StructuralPatternsState {
  final StructuralPatternInfo pattern;
  final List<String> executionLog;
  final Map<String, dynamic> results;
  final Duration executionTime;
  final bool wasSuccessful;

  const StructuralPatternDemoCompleted({
    required this.pattern,
    required this.executionLog,
    required this.results,
    required this.executionTime,
    this.wasSuccessful = true,
  });

  @override
  List<Object?> get props => [
    pattern,
    executionLog,
    results,
    executionTime,
    wasSuccessful,
  ];

  @override
  void logState() {
    Log.debug(
      'StructuralPatternsState: Demo completed for ${pattern.name} in ${executionTime.inMilliseconds}ms (${wasSuccessful ? 'success' : 'failed'})',
    );
  }
}

/// State for pattern comparison view
class StructuralPatternsComparisonView extends StructuralPatternsState {
  final List<StructuralPatternInfo> comparedPatterns;
  final Map<String, List<String>> comparisonData;
  final String comparisonCriteria;

  const StructuralPatternsComparisonView({
    required this.comparedPatterns,
    required this.comparisonData,
    this.comparisonCriteria = 'general',
  });

  @override
  List<Object?> get props => [
    comparedPatterns,
    comparisonData,
    comparisonCriteria,
  ];

  @override
  void logState() {
    Log.debug(
      'StructuralPatternsState: Comparison view - ${comparedPatterns.length} patterns compared',
    );
  }
}

/// Extension for state analytics
extension StructuralPatternsStateAnalytics on StructuralPatternsState {
  Map<String, dynamic> toAnalytics() {
    final baseData = {
      'state_type': runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    switch (this) {
      case StructuralPatternsLoaded loaded:
        return {
          ...baseData,
          'patterns_total': loaded.allPatterns.length,
          'patterns_filtered': loaded.filteredPatterns.length,
          'current_page': loaded.currentPageIndex,
          'favorites_count': loaded.favoritePatternIds.length,
          'has_search': loaded.searchQuery.isNotEmpty,
          'complexity_filter': loaded.complexityFilter,
          'sort_criteria': loaded.sortCriteria.name,
          'sort_ascending': loaded.sortAscending,
          'layout_mode': loaded.layoutMode.name,
          'comparison_visible': loaded.isComparisonVisible,
          'comparison_count': loaded.comparisonPatterns.length,
        };
      case StructuralPatternsError error:
        return {
          ...baseData,
          'error_message': error.error,
          'has_stack_trace': error.stackTrace != null,
          'is_recoverable': error.isRecoverable,
        };
      case StructuralPatternDemoRunning demo:
        return {
          ...baseData,
          'pattern_name': demo.pattern.name,
          'demo_stage': demo.currentStage,
          'progress': demo.progress,
          'elapsed_time_ms': demo.elapsedTime.inMilliseconds,
        };
      case StructuralPatternDemoCompleted demo:
        return {
          ...baseData,
          'pattern_name': demo.pattern.name,
          'execution_time_ms': demo.executionTime.inMilliseconds,
          'was_successful': demo.wasSuccessful,
          'results_count': demo.results.length,
        };
      case StructuralPatternsComparisonView comparison:
        return {
          ...baseData,
          'compared_patterns': comparison.comparedPatterns.length,
          'comparison_criteria': comparison.comparisonCriteria,
        };
      default:
        return baseData;
    }
  }
}

/// State validation utilities
class StructuralPatternsStateValidator {
  /// Validate loaded state consistency
  static bool validateLoadedState(StructuralPatternsLoaded state) {
    try {
      // Check if filtered patterns are subset of all patterns
      final allPatternIds = state.allPatterns.map((p) => p.id).toSet();
      final filteredPatternIds = state.filteredPatterns
          .map((p) => p.id)
          .toSet();

      if (!allPatternIds.containsAll(filteredPatternIds)) {
        Log.warning(
          'StructuralPatternsState: Filtered patterns contain invalid IDs',
        );
        return false;
      }

      // Check if current page index is valid
      if (state.currentPageIndex < 0 || state.currentPageIndex > 2) {
        Log.warning(
          'StructuralPatternsState: Invalid current page index ${state.currentPageIndex}',
        );
        return false;
      }

      // Check if selected pattern exists in all patterns
      if (state.selectedPattern != null &&
          !allPatternIds.contains(state.selectedPattern!.id)) {
        Log.warning(
          'StructuralPatternsState: Selected pattern not found in all patterns',
        );
        return false;
      }

      return true;
    } catch (e) {
      Log.error('StructuralPatternsState: State validation error - $e');
      return false;
    }
  }
}

/// State performance metrics
class StructuralPatternsStateMetrics {
  static Map<String, dynamic> getPerformanceMetrics(
    StructuralPatternsState state,
  ) {
    switch (state) {
      case StructuralPatternsLoaded loaded:
        return {
          'patterns_count': loaded.allPatterns.length,
          'filtered_count': loaded.filteredPatterns.length,
          'filter_efficiency': loaded.allPatterns.isNotEmpty
              ? loaded.filteredPatterns.length / loaded.allPatterns.length
              : 0.0,
          'favorites_ratio': loaded.allPatterns.isNotEmpty
              ? loaded.favoritePatternIds.length / loaded.allPatterns.length
              : 0.0,
          'code_visibility_ratio': loaded.allPatterns.isNotEmpty
              ? loaded.codeVisibility.values.where((v) => v).length /
                    loaded.allPatterns.length
              : 0.0,
        };
      case StructuralPatternDemoRunning demo:
        return {
          'demo_progress': demo.progress,
          'elapsed_seconds': demo.elapsedTime.inSeconds,
          'log_entries': demo.executionLog.length,
        };
      case StructuralPatternDemoCompleted demo:
        return {
          'execution_seconds': demo.executionTime.inSeconds,
          'success': demo.wasSuccessful,
          'results_size': demo.results.length,
        };
      default:
        return {};
    }
  }
}
