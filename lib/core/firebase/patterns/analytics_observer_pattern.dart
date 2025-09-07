/// Analytics Observer Pattern Implementation
///
/// PATTERN: Observer Pattern - Analytics event notification system
/// WHERE: Core Firebase patterns - Observer implementation for analytics
/// HOW: Subject-observer pattern for analytics event broadcasting
/// WHY: Decouple analytics event generation from event handling/processing
library;

import '../../logging/logging.dart';
import '../contracts/analytics_contract.dart';
import '../entities/analytics_event.dart';

/// Analytics Subject (Observable) for event broadcasting
abstract class AnalyticsSubject {
  void addObserver(AnalyticsEventObserver observer);

  void removeObserver(AnalyticsEventObserver observer);

  void notifyObservers(AnalyticsEvent event);
}

/// Concrete Analytics Event Observers

/// Learning Progress Observer
/// Tower Defense Context: Tracks educational progress and learning patterns
class LearningProgressObserver implements AnalyticsEventObserver {
  final Map<String, int> _patternProgress = {};
  final Map<String, Duration> _timeSpentPerPattern = {};

  @override
  void onAnalyticsEvent(AnalyticsEvent event) {
    if (event.type == AnalyticsEventType.patternLearning) {
      _trackLearningProgress(event);
    }
  }

  void _trackLearningProgress(AnalyticsEvent event) {
    final patternName = event.parameters['pattern_name'] as String?;
    final timeSpent = event.parameters['time_spent_seconds'] as int?;
    final completed = event.parameters['completed'] as bool? ?? false;

    if (patternName != null) {
      // Update progress count
      _patternProgress[patternName] = (_patternProgress[patternName] ?? 0) + 1;

      // Update time spent
      if (timeSpent != null) {
        _timeSpentPerPattern[patternName] =
            (_timeSpentPerPattern[patternName] ?? Duration.zero) +
            Duration(seconds: timeSpent);
      }

      // Log learning milestone
      if (completed && _patternProgress[patternName]! >= 3) {
        // Student has successfully completed this pattern 3+ times
        Log.info('🎓 Learning milestone: $patternName mastered!');
      }
    }
  }

  /// Get learning statistics
  Map<String, dynamic> getLearningStats() {
    return {
      'patterns_attempted': _patternProgress.keys.length,
      'total_attempts': _patternProgress.values.fold(
        0,
        (sum, count) => sum + count,
      ),
      'total_learning_time': _timeSpentPerPattern.values
          .fold(Duration.zero, (sum, duration) => sum + duration)
          .inMinutes,
      'pattern_progress': _patternProgress,
      'mastered_patterns': _patternProgress.entries
          .where((entry) => entry.value >= 3)
          .map((entry) => entry.key)
          .toList(),
    };
  }
}

/// Game Performance Observer
/// Tower Defense Context: Monitors game performance and difficulty adjustment
class GamePerformanceObserver implements AnalyticsEventObserver {
  final List<int> _recentScores = [];
  final Map<String, int> _patternUsageCount = {};

  static const int maxScoreHistory = 10;

  @override
  void onAnalyticsEvent(AnalyticsEvent event) {
    if (event.type == AnalyticsEventType.gameProgress) {
      _trackGamePerformance(event);
    }
  }

  void _trackGamePerformance(AnalyticsEvent event) {
    final score = event.parameters['score'] as int?;
    final patternsUsed = event.parameters['patterns_used'] as List<dynamic>?;

    if (score != null) {
      _recentScores.add(score);
      if (_recentScores.length > maxScoreHistory) {
        _recentScores.removeAt(0);
      }
    }

    if (patternsUsed != null) {
      for (final pattern in patternsUsed.cast<String>()) {
        _patternUsageCount[pattern] = (_patternUsageCount[pattern] ?? 0) + 1;
      }
    }
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final averageScore = _recentScores.isEmpty
        ? 0.0
        : _recentScores.reduce((a, b) => a + b) / _recentScores.length;

    return {
      'average_score': averageScore,
      'recent_scores': _recentScores,
      'most_used_patterns': _patternUsageCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
      'performance_trend': _calculatePerformanceTrend(),
    };
  }

  String _calculatePerformanceTrend() {
    if (_recentScores.length < 3) return 'insufficient_data';

    final recent = _recentScores.skip(_recentScores.length - 3).toList();
    final earlier = _recentScores.take(_recentScores.length - 3).toList();

    if (earlier.isEmpty) return 'insufficient_data';

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final earlierAvg = earlier.reduce((a, b) => a + b) / earlier.length;

    if (recentAvg > earlierAvg * 1.1) return 'improving';
    if (recentAvg < earlierAvg * 0.9) return 'declining';
    return 'stable';
  }
}

/// User Engagement Observer
/// Tower Defense Context: Tracks engagement patterns for adaptive learning
class UserEngagementObserver implements AnalyticsEventObserver {
  final Map<String, Duration> _screenTimeTracking = {};
  final Map<String, int> _interactionCounts = {};
  DateTime? _sessionStartTime;

  @override
  void onAnalyticsEvent(AnalyticsEvent event) {
    switch (event.type) {
      case AnalyticsEventType.userInteraction:
        _trackUserInteraction(event);
        break;
      case AnalyticsEventType.patternLearning:
      case AnalyticsEventType.gameProgress:
        _trackEngagementEvent(event);
        break;
      default:
        break;
    }
  }

  void _trackUserInteraction(AnalyticsEvent event) {
    final screenName = event.parameters['screen_name'] as String?;
    if (screenName != null) {
      _interactionCounts[screenName] =
          (_interactionCounts[screenName] ?? 0) + 1;
    }

    // Track session start
    _sessionStartTime ??= DateTime.now();
  }

  void _trackEngagementEvent(AnalyticsEvent event) {
    final timeSpent = event.parameters['time_spent_seconds'] as int?;
    final eventName = event.name;

    if (timeSpent != null) {
      _screenTimeTracking[eventName] =
          (_screenTimeTracking[eventName] ?? Duration.zero) +
          Duration(seconds: timeSpent);
    }
  }

  /// Get engagement statistics
  Map<String, dynamic> getEngagementStats() {
    final currentSessionDuration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!)
        : Duration.zero;

    return {
      'session_duration_minutes': currentSessionDuration.inMinutes,
      'total_interactions': _interactionCounts.values.fold(
        0,
        (sum, count) => sum + count,
      ),
      'most_engaged_screens': _interactionCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
      'activity_time_distribution': _screenTimeTracking,
      'engagement_level': _calculateEngagementLevel(currentSessionDuration),
    };
  }

  String _calculateEngagementLevel(Duration sessionDuration) {
    final minutes = sessionDuration.inMinutes;
    final totalInteractions = _interactionCounts.values.fold(
      0,
      (sum, count) => sum + count,
    );

    if (minutes > 15 && totalInteractions > 20) return 'high';
    if (minutes > 5 && totalInteractions > 10) return 'medium';
    return 'low';
  }
}

/// Error Tracking Observer
/// Tower Defense Context: Monitors errors for debugging and user experience
class ErrorTrackingObserver implements AnalyticsEventObserver {
  final List<Map<String, dynamic>> _recentErrors = [];
  final Map<String, int> _errorTypeCounts = {};

  static const int maxErrorHistory = 50;

  @override
  void onAnalyticsEvent(AnalyticsEvent event) {
    if (event.type == AnalyticsEventType.error) {
      _trackError(event);
    }
  }

  void _trackError(AnalyticsEvent event) {
    final errorType = event.parameters['error_type'] as String?;
    final errorMessage = event.parameters['error_message'] as String?;
    final context = event.parameters['context'] as String?;

    if (errorType != null) {
      _errorTypeCounts[errorType] = (_errorTypeCounts[errorType] ?? 0) + 1;
    }

    _recentErrors.add({
      'timestamp': event.timestamp ?? DateTime.now(),
      'type': errorType,
      'message': errorMessage,
      'context': context,
    });

    if (_recentErrors.length > maxErrorHistory) {
      _recentErrors.removeAt(0);
    }
  }

  /// Get error statistics
  Map<String, dynamic> getErrorStats() {
    return {
      'total_errors': _recentErrors.length,
      'error_types': _errorTypeCounts,
      'recent_errors': _recentErrors.take(10).toList(),
      'most_common_error': _errorTypeCounts.entries
          .fold<MapEntry<String, int>?>(
            null,
            (prev, curr) =>
                prev == null || curr.value > prev.value ? curr : prev,
          )
          ?.key,
    };
  }
}
