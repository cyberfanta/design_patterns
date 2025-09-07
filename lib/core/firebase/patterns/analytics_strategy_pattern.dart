/// Analytics Strategy Pattern Implementation
///
/// PATTERN: Strategy Pattern - Different analytics processing strategies
/// WHERE: Core Firebase patterns - Strategy implementation for analytics
/// HOW: Different strategies for processing different types of analytics events
/// WHY: Flexible event processing based on event type and privacy requirements
library;

import '../entities/analytics_event.dart';
import '../../logging/logging.dart';

/// Abstract Analytics Event Processing Strategy
abstract class AnalyticsEventStrategy {
  /// Process the analytics event according to the strategy
  AnalyticsEvent processEvent(AnalyticsEvent event);

  /// Validate event parameters
  bool validateEvent(AnalyticsEvent event);

  /// Filter sensitive data if needed
  Map<String, dynamic> filterParameters(Map<String, dynamic> parameters);
}

/// Pattern Learning Event Strategy
/// Tower Defense Context: Processes educational pattern learning events
class PatternLearningEventStrategy implements AnalyticsEventStrategy {
  @override
  AnalyticsEvent processEvent(AnalyticsEvent event) {
    if (!validateEvent(event)) {
      Log.warning('PatternLearningEventStrategy: Invalid event parameters');
      return event;
    }

    final filteredParams = filterParameters(event.parameters);

    // Add educational metadata
    final enhancedParams = {
      ...filteredParams,
      'learning_context': 'design_patterns',
      'educational_framework': 'tower_defense',
      'learning_type': 'interactive',
      'processed_by': 'pattern_learning_strategy',
    };

    return AnalyticsEvent(
      name: event.name,
      type: event.type,
      parameters: enhancedParams,
      timestamp: event.timestamp,
    );
  }

  @override
  bool validateEvent(AnalyticsEvent event) {
    final params = event.parameters;
    return params.containsKey('pattern_name') &&
        params.containsKey('pattern_category') &&
        params.containsKey('completed');
  }

  @override
  Map<String, dynamic> filterParameters(Map<String, dynamic> parameters) {
    // Remove any potentially sensitive data
    final filtered = Map<String, dynamic>.from(parameters);

    // Ensure time spent is within reasonable bounds (0-3600 seconds)
    if (filtered.containsKey('time_spent_seconds')) {
      final timeSpent = filtered['time_spent_seconds'] as int? ?? 0;
      filtered['time_spent_seconds'] = timeSpent.clamp(0, 3600);
    }

    return filtered;
  }
}

/// User Interaction Event Strategy
/// Tower Defense Context: Processes UI interaction and navigation events
class UserInteractionEventStrategy implements AnalyticsEventStrategy {
  @override
  AnalyticsEvent processEvent(AnalyticsEvent event) {
    if (!validateEvent(event)) {
      Log.warning('UserInteractionEventStrategy: Invalid event parameters');
      return event;
    }

    final filteredParams = filterParameters(event.parameters);

    // Add interaction metadata
    final enhancedParams = {
      ...filteredParams,
      'interaction_category': 'user_engagement',
      'ui_framework': 'flutter',
      'processed_by': 'user_interaction_strategy',
    };

    return AnalyticsEvent(
      name: event.name,
      type: event.type,
      parameters: enhancedParams,
      timestamp: event.timestamp,
    );
  }

  @override
  bool validateEvent(AnalyticsEvent event) {
    // Basic validation for user interaction events
    return event.name.isNotEmpty;
  }

  @override
  Map<String, dynamic> filterParameters(Map<String, dynamic> parameters) {
    final filtered = Map<String, dynamic>.from(parameters);

    // Remove potentially sensitive screen content
    filtered.remove('screen_content');
    filtered.remove('user_input');

    return filtered;
  }
}

/// Game Progress Event Strategy
/// Tower Defense Context: Processes game mechanics and progress events
class GameProgressEventStrategy implements AnalyticsEventStrategy {
  @override
  AnalyticsEvent processEvent(AnalyticsEvent event) {
    if (!validateEvent(event)) {
      Log.warning('GameProgressEventStrategy: Invalid event parameters');
      return event;
    }

    final filteredParams = filterParameters(event.parameters);

    // Add game metadata
    final enhancedParams = {
      ...filteredParams,
      'game_type': 'educational_tower_defense',
      'game_category': 'strategy_learning',
      'difficulty_adaptive': true,
      'processed_by': 'game_progress_strategy',
    };

    return AnalyticsEvent(
      name: event.name,
      type: event.type,
      parameters: enhancedParams,
      timestamp: event.timestamp,
    );
  }

  @override
  bool validateEvent(AnalyticsEvent event) {
    final params = event.parameters;

    // Game progress events should have level or score information
    return params.containsKey('level') ||
        params.containsKey('score') ||
        params.containsKey('game_mechanic');
  }

  @override
  Map<String, dynamic> filterParameters(Map<String, dynamic> parameters) {
    final filtered = Map<String, dynamic>.from(parameters);

    // Normalize score values
    if (filtered.containsKey('score')) {
      final score = filtered['score'] as int? ?? 0;
      filtered['score'] = score.clamp(0, 1000000); // Reasonable score cap
    }

    // Validate patterns used
    if (filtered.containsKey('patterns_used') &&
        filtered['patterns_used'] is List) {
      final patterns = filtered['patterns_used'] as List;
      filtered['patterns_used'] = patterns
          .take(10)
          .toList(); // Limit patterns list
    }

    return filtered;
  }
}

/// Performance Event Strategy
/// Tower Defense Context: Processes app performance monitoring events
class PerformanceEventStrategy implements AnalyticsEventStrategy {
  @override
  AnalyticsEvent processEvent(AnalyticsEvent event) {
    if (!validateEvent(event)) {
      Log.warning('PerformanceEventStrategy: Invalid event parameters');
      return event;
    }

    final filteredParams = filterParameters(event.parameters);

    // Add performance metadata
    final enhancedParams = {
      ...filteredParams,
      'performance_tracking': true,
      'optimization_target': 'user_experience',
      'processed_by': 'performance_strategy',
    };

    return AnalyticsEvent(
      name: event.name,
      type: event.type,
      parameters: enhancedParams,
      timestamp: event.timestamp,
    );
  }

  @override
  bool validateEvent(AnalyticsEvent event) {
    final params = event.parameters;
    return params.containsKey('operation') && params.containsKey('duration_ms');
  }

  @override
  Map<String, dynamic> filterParameters(Map<String, dynamic> parameters) {
    final filtered = Map<String, dynamic>.from(parameters);

    // Ensure reasonable duration bounds (0-60000ms = 1 minute max)
    if (filtered.containsKey('duration_ms')) {
      final duration = filtered['duration_ms'] as int? ?? 0;
      filtered['duration_ms'] = duration.clamp(0, 60000);
    }

    return filtered;
  }
}

/// Error Event Strategy
/// Tower Defense Context: Processes error and crash reporting events
class ErrorEventStrategy implements AnalyticsEventStrategy {
  @override
  AnalyticsEvent processEvent(AnalyticsEvent event) {
    if (!validateEvent(event)) {
      Log.warning('ErrorEventStrategy: Invalid event parameters');
      return event;
    }

    final filteredParams = filterParameters(event.parameters);

    // Add error metadata
    final enhancedParams = {
      ...filteredParams,
      'error_tracking': true,
      'debug_info_included': true,
      'processed_by': 'error_strategy',
    };

    return AnalyticsEvent(
      name: event.name,
      type: event.type,
      parameters: enhancedParams,
      timestamp: event.timestamp,
    );
  }

  @override
  bool validateEvent(AnalyticsEvent event) {
    final params = event.parameters;
    return params.containsKey('error_type') &&
        params.containsKey('error_message');
  }

  @override
  Map<String, dynamic> filterParameters(Map<String, dynamic> parameters) {
    final filtered = Map<String, dynamic>.from(parameters);

    // Truncate error messages to prevent overly long analytics events
    if (filtered.containsKey('error_message')) {
      final message = filtered['error_message'] as String? ?? '';
      filtered['error_message'] = message.length > 500
          ? '${message.substring(0, 500)}...[truncated]'
          : message;
    }

    // Remove full stack traces for privacy
    filtered.remove('full_stack_trace');

    return filtered;
  }
}

/// Custom Educational Event Strategy
/// Tower Defense Context: Processes custom educational game events
class CustomEducationalEventStrategy implements AnalyticsEventStrategy {
  @override
  AnalyticsEvent processEvent(AnalyticsEvent event) {
    if (!validateEvent(event)) {
      Log.warning('CustomEducationalEventStrategy: Invalid event parameters');
      return event;
    }

    final filteredParams = filterParameters(event.parameters);

    // Add educational metadata
    final enhancedParams = {
      ...filteredParams,
      'custom_educational_event': true,
      'learning_analytics': true,
      'educational_value': 'custom',
      'processed_by': 'custom_educational_strategy',
    };

    return AnalyticsEvent(
      name: event.name,
      type: event.type,
      parameters: enhancedParams,
      timestamp: event.timestamp,
    );
  }

  @override
  bool validateEvent(AnalyticsEvent event) {
    // Custom events just need to have the educational flag
    return event.parameters.containsKey('is_educational') &&
        event.parameters['is_educational'] == true;
  }

  @override
  Map<String, dynamic> filterParameters(Map<String, dynamic> parameters) {
    final filtered = Map<String, dynamic>.from(parameters);

    // Ensure reasonable parameter count (max 20 parameters)
    if (filtered.length > 20) {
      Log.warning(
        'CustomEducationalEventStrategy: Too many parameters, truncating',
      );
      final entries = filtered.entries.take(20).toList();
      filtered.clear();
      filtered.addEntries(entries);
    }

    return filtered;
  }
}

/// Strategy Factory for creating appropriate strategies
class AnalyticsStrategyFactory {
  static final Map<AnalyticsEventType, AnalyticsEventStrategy> _strategies = {
    AnalyticsEventType.patternLearning: PatternLearningEventStrategy(),
    AnalyticsEventType.userInteraction: UserInteractionEventStrategy(),
    AnalyticsEventType.gameProgress: GameProgressEventStrategy(),
    AnalyticsEventType.performance: PerformanceEventStrategy(),
    AnalyticsEventType.error: ErrorEventStrategy(),
    AnalyticsEventType.customEducational: CustomEducationalEventStrategy(),
  };

  /// PATTERN: Factory Method - Create strategy based on event type
  static AnalyticsEventStrategy? getStrategy(AnalyticsEventType eventType) {
    return _strategies[eventType];
  }

  /// Get all available strategies
  static Map<AnalyticsEventType, AnalyticsEventStrategy> getAllStrategies() {
    return Map.unmodifiable(_strategies);
  }
}
