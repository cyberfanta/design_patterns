/// PATTERN: Facade Pattern - Tower Defense specific Firebase operations
/// WHERE: Educational Firebase facade - Game-specific coordination
/// HOW: Simplified interface for Tower Defense educational analytics & monitoring
/// WHY: Abstract complex Firebase operations into game-specific methods
library;

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../entities/analytics_event.dart';
import '../services/firebase_manager.dart';
import 'firebase_services_facade.dart';

/// Tower Defense Firebase Facade
/// Educational Context: Convenience methods for common Tower Defense Firebase operations
class TowerDefenseFirebaseFacade {
  TowerDefenseFirebaseFacade._();

  static TowerDefenseFirebaseFacade? _instance;

  /// PATTERN: Singleton - Single Tower Defense Firebase facade
  static TowerDefenseFirebaseFacade get instance {
    _instance ??= TowerDefenseFirebaseFacade._();
    return _instance!;
  }

  final FirebaseServicesFacade _firebaseFacade =
      FirebaseServicesFacade.instance;
  final FirebaseManager _manager = FirebaseManager.instance;

  /// Track pattern learning progress
  Future<Either<Failure, void>> trackPatternLearning({
    required String patternName,
    required String category,
    required bool completed,
    int? timeSpent,
    double? accuracyScore,
  }) async {
    try {
      Log.debug(
        'TowerDefenseFirebaseFacade: Tracking pattern learning: $patternName',
      );

      final event = AnalyticsEvent.customEducational(
        eventName: 'pattern_learning',
        customParameters: {
          'pattern_name': patternName,
          'pattern_category': category,
          'completed': completed,
          if (timeSpent != null) 'time_spent_seconds': timeSpent,
          if (accuracyScore != null) 'accuracy_score': accuracyScore,
          'tower_defense_context': 'educational_gameplay',
        },
      );

      return await _firebaseFacade.trackEvent(event);
    } catch (e) {
      Log.error(
        'TowerDefenseFirebaseFacade: Failed to track pattern learning: $e',
      );
      return Left(
        TechnicalFailure(message: 'Pattern learning tracking failed: $e'),
      );
    }
  }

  /// Track game session metrics
  Future<Either<Failure, void>> trackGameSession({
    required String sessionType,
    required Duration sessionDuration,
    required int patternsExplored,
    required Map<String, int> categoriesVisited,
  }) async {
    try {
      Log.debug(
        'TowerDefenseFirebaseFacade: Tracking game session: $sessionType',
      );

      final event = AnalyticsEvent.customEducational(
        eventName: 'tower_defense_session_completed',
        customParameters: {
          'session_type': sessionType,
          'session_duration_minutes': sessionDuration.inMinutes,
          'patterns_explored': patternsExplored,
          'categories_visited': categoriesVisited,
          'educational_value': 'high',
        },
      );

      return await _firebaseFacade.trackEvent(event);
    } catch (e) {
      Log.error('TowerDefenseFirebaseFacade: Failed to track game session: $e');
      return Left(
        TechnicalFailure(message: 'Game session tracking failed: $e'),
      );
    }
  }

  /// Secure operation with App Check validation
  Future<Either<Failure, T>> executeSecureOperation<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String operationType,
    bool requireValidToken = true,
  }) async {
    if (_manager.appCheck == null) {
      Log.warning(
        'TowerDefenseFirebaseFacade: App Check not available, executing operation without validation',
      );
      return await operation();
    }

    return await _manager.appCheck!.validateRequest<T>(
      request: () async {
        final result = await operation();
        return result.fold((l) => throw Exception(l.message), (r) => r);
      },
      requireValidToken: requireValidToken,
    );
  }

  /// Measure operation performance
  Future<Either<Failure, T>> measureOperation<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String operationName,
    Map<String, String>? attributes,
  }) async {
    if (_manager.performance == null) {
      Log.warning(
        'TowerDefenseFirebaseFacade: Performance monitoring not available',
      );
      return await operation();
    }

    return await _manager.performance!.measureExecution<T>(
      traceName: 'tower_defense_$operationName',
      operation: () async {
        final result = await operation();
        return result.fold((l) => throw Exception(l.message), (r) => r);
      },
      attributes: attributes,
    );
  }

  /// Record educational error with context
  Future<Either<Failure, void>> recordEducationalError({
    required dynamic exception,
    required String educationalContext,
    String? patternName,
    String? categoryName,
    StackTrace? stackTrace,
  }) async {
    try {
      // Set educational context
      await _firebaseFacade.setCustomKey(
        key: 'educational_context',
        value: educationalContext,
      );

      if (patternName != null) {
        await _firebaseFacade.setCustomKey(
          key: 'current_pattern',
          value: patternName,
        );
      }

      if (categoryName != null) {
        await _firebaseFacade.setCustomKey(
          key: 'pattern_category',
          value: categoryName,
        );
      }

      return await _firebaseFacade.recordError(
        exception: exception,
        stackTrace: stackTrace,
        reason:
            'Educational error in Tower Defense context: $educationalContext',
        fatal: false,
      );
    } catch (e) {
      Log.error(
        'TowerDefenseFirebaseFacade: Failed to record educational error: $e',
      );
      return Left(
        TechnicalFailure(message: 'Educational error recording failed: $e'),
      );
    }
  }

  /// Track user engagement metrics
  Future<Either<Failure, void>> trackEngagement({
    required String engagementType,
    required Duration timeSpent,
    required Map<String, dynamic> engagementData,
  }) async {
    try {
      Log.debug(
        'TowerDefenseFirebaseFacade: Tracking engagement: $engagementType',
      );

      final event = AnalyticsEvent.customEducational(
        eventName: 'user_engagement',
        customParameters: {
          'interaction_type': engagementType,
          'screen_name': 'tower_defense_game',
          'engagement_duration_seconds': timeSpent.inSeconds,
          'engagement_quality': _calculateEngagementQuality(
            timeSpent,
            engagementData,
          ),
          ...engagementData,
        },
      );

      return await _firebaseFacade.trackEvent(event);
    } catch (e) {
      Log.error('TowerDefenseFirebaseFacade: Failed to track engagement: $e');
      return Left(TechnicalFailure(message: 'Engagement tracking failed: $e'));
    }
  }

  /// Track pattern mastery achievement
  Future<Either<Failure, void>> trackPatternMastery({
    required String patternName,
    required String category,
    required int attemptsCount,
    required double averageScore,
    required Duration totalLearningTime,
  }) async {
    try {
      Log.info(
        'TowerDefenseFirebaseFacade: Pattern mastery achieved: $patternName',
      );

      final event = AnalyticsEvent.customEducational(
        eventName: 'pattern_mastery_achieved',
        customParameters: {
          'pattern_name': patternName,
          'pattern_category': category,
          'total_attempts': attemptsCount,
          'average_score': averageScore,
          'learning_time_minutes': totalLearningTime.inMinutes,
          'educational_milestone': 'mastery',
          'tower_defense_achievement': 'pattern_expert',
        },
      );

      return await _firebaseFacade.trackEvent(event);
    } catch (e) {
      Log.error(
        'TowerDefenseFirebaseFacade: Failed to track pattern mastery: $e',
      );
      return Left(
        TechnicalFailure(message: 'Pattern mastery tracking failed: $e'),
      );
    }
  }

  /// Get comprehensive health status
  Future<Map<String, dynamic>> getHealthStatus() async {
    final health = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tower_defense_specific': true,
    };

    try {
      // Base services status
      final baseStatus = _firebaseFacade.getServicesStatus();
      health.addAll(baseStatus);

      // Analytics health
      if (_manager.analytics != null) {
        health['analytics'] = {'available': true, 'educational_tracking': true};
      }

      // Performance health
      if (_manager.performance != null) {
        health['performance'] = {'available': true, 'monitoring_active': true};
      }

      // Crashlytics health
      if (_manager.crashlytics != null) {
        final collectionEnabledResult = await _manager.crashlytics!
            .isCrashlyticsCollectionEnabled();
        health['crashlytics'] = {
          'available': true,
          'collection_enabled': collectionEnabledResult.fold(
            (l) => false,
            (r) => r,
          ),
        };
      }

      // App Check health
      if (_manager.appCheck != null) {
        final tokenStatusResult = await _manager.appCheck!.getTokenStatus();
        health['app_check'] = tokenStatusResult.fold(
          (l) => {'available': true, 'status': 'error', 'error': l.message},
          (r) => {
            'available': true,
            'status': r.statusDescription,
            'healthy': r.isHealthy,
          },
        );
      }

      return health;
    } catch (e) {
      health['health_check_error'] = e.toString();
      return health;
    }
  }

  /// Emergency shutdown for critical errors
  Future<void> emergencyShutdown() async {
    Log.warning('TowerDefenseFirebaseFacade: Emergency shutdown initiated');

    try {
      await _firebaseFacade.setServicesEnabled(false);
      await _firebaseFacade.dispose();

      Log.info('TowerDefenseFirebaseFacade: Emergency shutdown completed');
    } catch (e) {
      Log.error(
        'TowerDefenseFirebaseFacade: Error during emergency shutdown: $e',
      );
    }
  }

  /// Calculate engagement quality based on interaction data
  String _calculateEngagementQuality(
    Duration timeSpent,
    Map<String, dynamic> data,
  ) {
    final minutes = timeSpent.inMinutes;
    final interactions = data['interaction_count'] as int? ?? 0;

    if (minutes > 15 && interactions > 20) return 'high';
    if (minutes > 5 && interactions > 10) return 'medium';
    return 'low';
  }
}
