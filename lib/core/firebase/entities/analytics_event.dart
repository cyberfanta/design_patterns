/// Analytics Event Entity
///
/// PATTERN: Factory Method + Builder - Event creation with validation
/// WHERE: Core Firebase entities - Analytics event structure
/// HOW: Factory methods for different event types with required parameters
/// WHY: Type-safe event creation for Tower Defense educational analytics
library;

import 'package:equatable/equatable.dart';

/// Analytics event types for Tower Defense educational app
enum AnalyticsEventType {
  /// Pattern learning events
  patternLearning,

  /// User interaction events
  userInteraction,

  /// Game progress events
  gameProgress,

  /// Performance tracking
  performance,

  /// Error tracking
  error,

  /// Custom educational events
  customEducational,
}

/// Analytics Event Entity
///
/// Tower Defense Context: Represents trackable events in the educational
/// game including pattern learning, tower placement, enemy defeats, etc.
class AnalyticsEvent extends Equatable {
  const AnalyticsEvent({
    required this.name,
    required this.type,
    required this.parameters,
    this.timestamp,
  });

  final String name;
  final AnalyticsEventType type;
  final Map<String, dynamic> parameters;
  final DateTime? timestamp;

  /// Factory: App initialized
  factory AnalyticsEvent.appInitialized() {
    return AnalyticsEvent(
      name: 'app_initialized',
      type: AnalyticsEventType.userInteraction,
      parameters: {
        'platform': 'flutter',
        'event_time': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now(),
    );
  }

  /// Factory: Pattern learned
  factory AnalyticsEvent.patternLearned({
    required String patternName,
    required String patternCategory,
    required String difficulty,
    required Duration timeSpent,
    required bool completed,
  }) {
    return AnalyticsEvent(
      name: 'pattern_learned',
      type: AnalyticsEventType.patternLearning,
      parameters: {
        'pattern_name': patternName,
        'pattern_category': patternCategory,
        'difficulty': difficulty,
        'time_spent_seconds': timeSpent.inSeconds,
        'completed': completed,
        'educational_value': 'high',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Factory: Game progress made
  factory AnalyticsEvent.gameProgressMade({
    required String level,
    required int score,
    required List<String> patternsUsed,
    required bool completed,
  }) {
    return AnalyticsEvent(
      name: 'game_progress',
      type: AnalyticsEventType.gameProgress,
      parameters: {
        'level': level,
        'score': score,
        'patterns_used': patternsUsed,
        'patterns_count': patternsUsed.length,
        'level_completed': completed,
        'game_type': 'tower_defense',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Factory: Code interaction
  factory AnalyticsEvent.codeInteraction({
    required String patternName,
    required String language,
    required String action,
  }) {
    return AnalyticsEvent(
      name: 'code_interaction',
      type: AnalyticsEventType.userInteraction,
      parameters: {
        'pattern_name': patternName,
        'code_language': language,
        'action': action,
        'interaction_type': 'educational',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Factory: User engagement
  factory AnalyticsEvent.userEngagement({
    required String screenName,
    required Duration timeSpent,
    required int interactionCount,
  }) {
    return AnalyticsEvent(
      name: 'user_engagement',
      type: AnalyticsEventType.userInteraction,
      parameters: {
        'screen_name': screenName,
        'time_spent_seconds': timeSpent.inSeconds,
        'interaction_count': interactionCount,
        'engagement_level': timeSpent.inMinutes > 2 ? 'high' : 'low',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Factory: Performance measurement
  factory AnalyticsEvent.performanceMeasurement({
    required String operation,
    required Duration duration,
    required bool success,
  }) {
    return AnalyticsEvent(
      name: 'performance_measurement',
      type: AnalyticsEventType.performance,
      parameters: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        'success': success,
        'performance_category': 'app_performance',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Factory: Error occurred
  factory AnalyticsEvent.errorOccurred({
    required String errorType,
    required String errorMessage,
    required String? stackTrace,
    String? context,
  }) {
    return AnalyticsEvent(
      name: 'error_occurred',
      type: AnalyticsEventType.error,
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'has_stack_trace': stackTrace != null,
        'context': context ?? 'unknown',
        'severity': 'error',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Factory: Custom educational event
  factory AnalyticsEvent.customEducational({
    required String eventName,
    required Map<String, dynamic> customParameters,
  }) {
    return AnalyticsEvent(
      name: eventName,
      type: AnalyticsEventType.customEducational,
      parameters: {
        ...customParameters,
        'is_educational': true,
        'custom_event': true,
      },
      timestamp: DateTime.now(),
    );
  }

  /// Factory: Tower placed (Tower Defense specific)
  factory AnalyticsEvent.towerPlaced({
    required String towerType,
    required String patternImplemented,
    required Map<String, int> position,
    required int cost,
  }) {
    return AnalyticsEvent(
      name: 'tower_placed',
      type: AnalyticsEventType.gameProgress,
      parameters: {
        'tower_type': towerType,
        'pattern_implemented': patternImplemented,
        'position_x': position['x'],
        'position_y': position['y'],
        'cost': cost,
        'game_mechanic': 'tower_placement',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Factory: Enemy defeated (Tower Defense specific)
  factory AnalyticsEvent.enemyDefeated({
    required String enemyType,
    required String defeatMethod,
    required List<String> patternsInvolved,
    required int pointsEarned,
  }) {
    return AnalyticsEvent(
      name: 'enemy_defeated',
      type: AnalyticsEventType.gameProgress,
      parameters: {
        'enemy_type': enemyType,
        'defeat_method': defeatMethod,
        'patterns_involved': patternsInvolved,
        'patterns_count': patternsInvolved.length,
        'points_earned': pointsEarned,
        'game_mechanic': 'combat',
      },
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [name, type, parameters, timestamp];

  @override
  String toString() {
    return 'AnalyticsEvent(name: $name, type: $type, timestamp: $timestamp)';
  }
}
