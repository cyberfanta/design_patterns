/// Firebase Analytics Service
///
/// PATTERN: Observer + Strategy - Analytics event tracking with privacy
/// WHERE: Core Firebase services - Analytics implementation
/// HOW: Observer pattern for event tracking, Strategy for different event types
/// WHY: Privacy-compliant learning analytics with flexible event handling
library;

import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../contracts/analytics_contract.dart';
import '../entities/analytics_event.dart';
import '../patterns/analytics_observer_pattern.dart';
import '../patterns/analytics_strategy_pattern.dart';

/// Firebase Analytics Service Implementation
///
/// Tower Defense Context: Tracks player learning patterns, pattern usage,
/// difficulty preferences, and educational engagement metrics
class FirebaseAnalyticsService implements AnalyticsContract, AnalyticsSubject {
  FirebaseAnalyticsService._();

  static FirebaseAnalyticsService? _instance;

  /// PATTERN: Singleton - Single analytics service instance
  static FirebaseAnalyticsService get instance {
    _instance ??= FirebaseAnalyticsService._();
    return _instance!;
  }

  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver _observer;

  final List<AnalyticsEventObserver> _observers = [];
  final Map<AnalyticsEventType, AnalyticsEventStrategy> _strategies = {};

  bool _isInitialized = false;
  bool _analyticsEnabled = true;

  /// Initialize Analytics service
  @override
  Future<Either<Failure, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      Log.debug('FirebaseAnalyticsService: Initializing analytics service');

      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);

      // Register event strategies
      _registerEventStrategies();

      // Set default analytics properties
      await _setDefaultProperties();

      _isInitialized = true;
      Log.success('FirebaseAnalyticsService: Analytics service initialized');

      // Track initialization
      await trackEvent(AnalyticsEvent.appInitialized());

      return const Right(null);
    } catch (e) {
      Log.error('FirebaseAnalyticsService: Failed to initialize: $e');
      return Left(
        TechnicalFailure(message: 'Analytics initialization failed: $e'),
      );
    }
  }

  /// PATTERN: Strategy Pattern - Different strategies for different event types
  void _registerEventStrategies() {
    _strategies[AnalyticsEventType.patternLearning] =
        PatternLearningEventStrategy();
    _strategies[AnalyticsEventType.userInteraction] =
        UserInteractionEventStrategy();
    _strategies[AnalyticsEventType.gameProgress] = GameProgressEventStrategy();
    _strategies[AnalyticsEventType.performance] = PerformanceEventStrategy();
    _strategies[AnalyticsEventType.error] = ErrorEventStrategy();
    _strategies[AnalyticsEventType.customEducational] =
        CustomEducationalEventStrategy();
  }

  /// Set default analytics properties
  Future<void> _setDefaultProperties() async {
    try {
      await _analytics.setDefaultEventParameters({
        'app_version': '1.0.0',
        'app_name': 'Design Patterns Tower Defense',
        'educational_app': true,
        'privacy_compliant': true,
      });

      // Set user properties (privacy-safe)
      await _analytics.setUserProperty(name: 'user_type', value: 'learner');

      Log.debug('FirebaseAnalyticsService: Default properties set');
    } catch (e) {
      Log.warning(
        'FirebaseAnalyticsService: Failed to set default properties: $e',
      );
    }
  }

  /// Enable or disable analytics collection
  @override
  Future<Either<Failure, void>> setAnalyticsEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      _analyticsEnabled = enabled;

      Log.info(
        'FirebaseAnalyticsService: Analytics ${enabled ? 'enabled' : 'disabled'}',
      );
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseAnalyticsService: Failed to toggle analytics: $e');
      return Left(TechnicalFailure(message: 'Failed to toggle analytics: $e'));
    }
  }

  /// Track analytics event using Strategy pattern
  @override
  Future<Either<Failure, void>> trackEvent(AnalyticsEvent event) async {
    if (!_isInitialized || !_analyticsEnabled) {
      return const Right(null);
    }

    try {
      Log.debug('FirebaseAnalyticsService: Tracking event ${event.name}');

      // Use appropriate strategy for event type
      final strategy = _strategies[event.type];
      if (strategy != null) {
        final processedEvent = strategy.processEvent(event);
        await _analytics.logEvent(
          name: processedEvent.name,
          parameters: processedEvent.parameters.map(
            (key, value) => MapEntry(key, value as Object),
          ),
        );
      } else {
        // Default processing
        await _analytics.logEvent(
          name: event.name,
          parameters: event.parameters.map(
            (key, value) => MapEntry(key, value as Object),
          ),
        );
      }

      // Notify observers
      notifyObservers(event);

      Log.success(
        'FirebaseAnalyticsService: Event ${event.name} tracked successfully',
      );
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseAnalyticsService: Failed to track event: $e');
      return Left(TechnicalFailure(message: 'Failed to track event: $e'));
    }
  }

  /// Track screen view
  @override
  Future<Either<Failure, void>> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized || !_analyticsEnabled) {
      return const Right(null);
    }

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? 'Flutter',
        parameters: parameters?.map(
          (key, value) => MapEntry(key, value as Object),
        ),
      );

      Log.debug('FirebaseAnalyticsService: Screen view tracked: $screenName');
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseAnalyticsService: Failed to track screen view: $e');
      return Left(TechnicalFailure(message: 'Failed to track screen view: $e'));
    }
  }

  /// Set user ID for analytics (privacy-compliant)
  @override
  Future<Either<Failure, void>> setUserId(String? userId) async {
    if (!_isInitialized) {
      return Left(TechnicalFailure(message: 'Analytics not initialized'));
    }

    try {
      await _analytics.setUserId(id: userId);
      Log.debug('FirebaseAnalyticsService: User ID set');
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseAnalyticsService: Failed to set user ID: $e');
      return Left(TechnicalFailure(message: 'Failed to set user ID: $e'));
    }
  }

  /// Set user property
  @override
  Future<Either<Failure, void>> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!_isInitialized) {
      return Left(TechnicalFailure(message: 'Analytics not initialized'));
    }

    try {
      await _analytics.setUserProperty(name: name, value: value);
      Log.debug('FirebaseAnalyticsService: User property set: $name');
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseAnalyticsService: Failed to set user property: $e');
      return Left(TechnicalFailure(message: 'Failed to set user property: $e'));
    }
  }

  /// Reset analytics data
  @override
  Future<Either<Failure, void>> resetAnalyticsData() async {
    if (!_isInitialized) {
      return Left(TechnicalFailure(message: 'Analytics not initialized'));
    }

    try {
      await _analytics.resetAnalyticsData();
      Log.info('FirebaseAnalyticsService: Analytics data reset');
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseAnalyticsService: Failed to reset analytics data: $e');
      return Left(
        TechnicalFailure(message: 'Failed to reset analytics data: $e'),
      );
    }
  }

  /// Get Firebase Analytics Observer for navigation
  FirebaseAnalyticsObserver get navigationObserver => _observer;

  // PATTERN: Observer Pattern Implementation
  @override
  void addObserver(AnalyticsEventObserver observer) {
    _observers.add(observer);
  }

  @override
  void removeObserver(AnalyticsEventObserver observer) {
    _observers.remove(observer);
  }

  @override
  void notifyObservers(AnalyticsEvent event) {
    for (final observer in _observers) {
      observer.onAnalyticsEvent(event);
    }
  }

  /// Dispose service
  Future<void> dispose() async {
    _observers.clear();
    _strategies.clear();
    Log.debug('FirebaseAnalyticsService: Service disposed');
  }
}

/// Educational Analytics Helper
///
/// Tower Defense Context: Specific analytics for educational game mechanics
class EducationalAnalyticsHelper {
  static final FirebaseAnalyticsService _analytics =
      FirebaseAnalyticsService.instance;

  /// Track pattern learning event
  static Future<void> trackPatternLearned({
    required String patternName,
    required String patternCategory,
    required String difficulty,
    required int timeSpentSeconds,
    required bool completedSuccessfully,
  }) async {
    await _analytics.trackEvent(
      AnalyticsEvent.patternLearned(
        patternName: patternName,
        patternCategory: patternCategory,
        difficulty: difficulty,
        timeSpent: Duration(seconds: timeSpentSeconds),
        completed: completedSuccessfully,
      ),
    );
  }

  /// Track tower defense game progress
  static Future<void> trackGameProgress({
    required String level,
    required int score,
    required String patternUsed,
    required bool levelCompleted,
  }) async {
    await _analytics.trackEvent(
      AnalyticsEvent.gameProgressMade(
        level: level,
        score: score,
        patternsUsed: [patternUsed],
        completed: levelCompleted,
      ),
    );
  }

  /// Track user engagement with code examples
  static Future<void> trackCodeInteraction({
    required String patternName,
    required String language,
    required String action, // 'view', 'copy', 'expand'
  }) async {
    await _analytics.trackEvent(
      AnalyticsEvent.codeInteraction(
        patternName: patternName,
        language: language,
        action: action,
      ),
    );
  }
}
