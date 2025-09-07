/// Firebase Manager - Central Firebase Services Coordinator
///
/// PATTERN: Facade + Singleton - Unified Firebase services interface
/// WHERE: Core Firebase services - Central manager for all Firebase services
/// HOW: Facade pattern simplifies access to Firebase services with coordinated initialization
/// WHY: Single point of control for Tower Defense Firebase integration
library;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:fpdart/fpdart.dart';

import '../../../firebase_options.dart';
import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../contracts/analytics_contract.dart';
import '../entities/analytics_event.dart';
import '../patterns/analytics_observer_pattern.dart';
import 'analytics_service.dart';
import 'app_check_service.dart';
import 'crashlytics_service.dart';
import 'performance_service.dart';

/// Firebase Manager - Central Coordinator
///
/// Tower Defense Context: Manages all Firebase services for the educational
/// game including analytics, performance, crashlytics, and security
class FirebaseManager {
  FirebaseManager._();

  static FirebaseManager? _instance;

  /// PATTERN: Singleton - Single Firebase manager instance
  static FirebaseManager get instance {
    _instance ??= FirebaseManager._();
    return _instance!;
  }

  // Service instances
  FirebaseAnalyticsService? _analytics;
  FirebasePerformanceService? _performance;
  FirebaseCrashlyticsService? _crashlytics;
  FirebaseAppCheckService? _appCheck;

  // Observers
  final List<AnalyticsEventObserver> _analyticsObservers = [];

  bool _isInitialized = false;
  bool _servicesEnabled = true;

  /// Initialize all Firebase services
  Future<Either<Failure, void>> initialize({
    bool enableAnalytics = true,
    bool enablePerformance = true,
    bool enableCrashlytics = true,
    bool enableAppCheck = true,
  }) async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      Log.info('FirebaseManager: Initializing Firebase services...');

      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      Log.success('FirebaseManager: Firebase Core initialized');

      // Initialize individual services
      await _initializeServices(
        enableAnalytics: enableAnalytics,
        enablePerformance: enablePerformance,
        enableCrashlytics: enableCrashlytics,
        enableAppCheck: enableAppCheck,
      );

      // Setup service coordination
      _setupServiceCoordination();

      // Setup analytics observers
      _setupAnalyticsObservers();

      _isInitialized = true;
      Log.success(
        'FirebaseManager: All Firebase services initialized successfully',
      );

      // Track initialization event
      if (_analytics != null) {
        await _analytics!.trackEvent(
          AnalyticsEvent.customEducational(
            eventName: 'firebase_services_initialized',
            customParameters: {
              'analytics_enabled': enableAnalytics,
              'performance_enabled': enablePerformance,
              'crashlytics_enabled': enableCrashlytics,
              'app_check_enabled': enableAppCheck,
            },
          ),
        );
      }

      return const Right(null);
    } catch (e) {
      Log.error('FirebaseManager: Failed to initialize Firebase services: $e');

      // Record initialization failure
      if (_crashlytics != null) {
        await _crashlytics!.recordError(
          exception: e,
          reason: 'Firebase Manager initialization failed',
          context: {'initialization_error': true},
        );
      }

      return Left(
        TechnicalFailure(message: 'Firebase initialization failed: $e'),
      );
    }
  }

  /// Initialize individual services
  Future<void> _initializeServices({
    required bool enableAnalytics,
    required bool enablePerformance,
    required bool enableCrashlytics,
    required bool enableAppCheck,
  }) async {
    final List<Future<Either<Failure, void>>> initTasks = [];

    // Initialize Analytics
    if (enableAnalytics) {
      _analytics = FirebaseAnalyticsService.instance;
      initTasks.add(_analytics!.initialize());
    }

    // Initialize Performance
    if (enablePerformance) {
      _performance = FirebasePerformanceService.instance;
      initTasks.add(_performance!.initialize());
    }

    // Initialize Crashlytics
    if (enableCrashlytics) {
      _crashlytics = FirebaseCrashlyticsService.instance;
      initTasks.add(_crashlytics!.initialize());
    }

    // Initialize App Check
    if (enableAppCheck) {
      _appCheck = FirebaseAppCheckService.instance;
      initTasks.add(_appCheck!.initialize());
    }

    // Wait for all services to initialize
    final results = await Future.wait(initTasks);

    // Check for any initialization failures
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      if (result.isLeft()) {
        final error = result.fold((l) => l.message, (r) => 'Unknown error');
        throw Exception('Service initialization failed: $error');
      }
    }

    Log.info('FirebaseManager: All enabled services initialized successfully');
  }

  /// Setup coordination between services
  void _setupServiceCoordination() {
    // Performance monitoring for analytics events
    if (_performance != null && _analytics != null) {
      Log.debug(
        'FirebaseManager: Setting up Analytics-Performance coordination',
      );
      // Could add automatic performance tracking for analytics events
    }

    // Crashlytics for service errors
    if (_crashlytics != null) {
      Log.debug(
        'FirebaseManager: Setting up error coordination with Crashlytics',
      );
      // All services already use crashlytics for error reporting
    }

    // App Check for service security
    if (_appCheck != null) {
      Log.debug(
        'FirebaseManager: Setting up security coordination with App Check',
      );
      // All services can use App Check validation when needed
    }
  }

  /// Setup analytics observers for coordinated tracking
  void _setupAnalyticsObservers() {
    if (_analytics == null) return;

    // Add default observers
    final learningObserver = LearningProgressObserver();
    final performanceObserver = GamePerformanceObserver();
    final engagementObserver = UserEngagementObserver();
    final errorObserver = ErrorTrackingObserver();

    _analytics!.addObserver(learningObserver);
    _analytics!.addObserver(performanceObserver);
    _analytics!.addObserver(engagementObserver);
    _analytics!.addObserver(errorObserver);

    _analyticsObservers.addAll([
      learningObserver,
      performanceObserver,
      engagementObserver,
      errorObserver,
    ]);

    Log.info('FirebaseManager: Analytics observers configured');
  }

  /// Enable or disable all Firebase services
  Future<Either<Failure, void>> setServicesEnabled(bool enabled) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Firebase Manager not initialized'),
      );
    }

    try {
      _servicesEnabled = enabled;

      final List<Future<Either<Failure, void>>> tasks = [];

      if (_analytics != null) {
        tasks.add(_analytics!.setAnalyticsEnabled(enabled));
      }

      if (_performance != null) {
        tasks.add(_performance!.setPerformanceEnabled(enabled));
      }

      if (_crashlytics != null) {
        tasks.add(_crashlytics!.setCrashlyticsEnabled(enabled));
      }

      if (_appCheck != null) {
        tasks.add(_appCheck!.setAppCheckEnabled(enabled));
      }

      // Wait for all services to update
      final results = await Future.wait(tasks);

      // Check for failures
      for (final result in results) {
        if (result.isLeft()) {
          final error = result.fold((l) => l.message, (r) => 'Unknown error');
          Log.warning(
            'FirebaseManager: Failed to update service state: $error',
          );
        }
      }

      Log.info(
        'FirebaseManager: All services ${enabled ? 'enabled' : 'disabled'}',
      );
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseManager: Failed to update services state: $e');
      return Left(
        TechnicalFailure(message: 'Failed to update services state: $e'),
      );
    }
  }

  // Getters for individual services
  /// Get Analytics service
  FirebaseAnalyticsService? get analytics => _analytics;

  /// Get Performance service
  FirebasePerformanceService? get performance => _performance;

  /// Get Crashlytics service
  FirebaseCrashlyticsService? get crashlytics => _crashlytics;

  /// Get App Check service
  FirebaseAppCheckService? get appCheck => _appCheck;

  /// Check if Firebase Manager is initialized
  bool get isInitialized => _isInitialized;

  /// Check if services are enabled
  bool get servicesEnabled => _servicesEnabled;

  /// Get service status
  Map<String, bool> get serviceStatus => {
    'initialized': _isInitialized,
    'enabled': _servicesEnabled,
    'analytics_available': _analytics != null,
    'performance_available': _performance != null,
    'crashlytics_available': _crashlytics != null,
    'app_check_available': _appCheck != null,
  };

  /// Dispose all services
  Future<void> dispose() async {
    Log.info('FirebaseManager: Disposing Firebase services');

    try {
      // Dispose individual services
      if (_analytics != null) {
        await _analytics!.dispose();
      }

      if (_performance != null) {
        await _performance!.dispose();
      }

      if (_crashlytics != null) {
        await _crashlytics!.dispose();
      }

      if (_appCheck != null) {
        await _appCheck!.dispose();
      }

      // Clear observers
      _analyticsObservers.clear();

      _isInitialized = false;
      _servicesEnabled = false;

      Log.success('FirebaseManager: All services disposed');
    } catch (e) {
      Log.error('FirebaseManager: Error during disposal: $e');
    }
  }
}

/// Tower Defense Firebase Helper
///
/// Educational Context: Convenience methods for common Tower Defense Firebase operations
class TowerDefenseFirebaseHelper {
  static final FirebaseManager _manager = FirebaseManager.instance;

  /// Initialize Firebase for Tower Defense
  static Future<Either<Failure, void>> initializeTowerDefenseFirebase() async {
    return _manager.initialize(
      enableAnalytics: true,
      enablePerformance: true,
      enableCrashlytics: true,
      enableAppCheck: true,
    );
  }

  /// Track pattern learning with coordinated services
  static Future<void> trackPatternLearning({
    required String patternName,
    required String patternCategory,
    required Duration timeSpent,
    required bool completed,
  }) async {
    if (_manager.analytics != null) {
      await _manager.analytics!.trackEvent(
        AnalyticsEvent.patternLearned(
          patternName: patternName,
          patternCategory: patternCategory,
          difficulty: 'medium',
          timeSpent: timeSpent,
          completed: completed,
        ),
      );
    }

    // Could also trigger performance measurements, etc.
  }

  /// Report educational error with full context
  static Future<void> reportEducationalError({
    required String patternName,
    required dynamic exception,
    StackTrace? stackTrace,
    String? phase,
  }) async {
    if (_manager.crashlytics != null) {
      await TowerDefenseCrashlyticsHelper.recordPatternError(
        patternName: patternName,
        errorType: 'educational_content',
        exception: exception,
        stackTrace: stackTrace,
      );
    }

    if (_manager.analytics != null) {
      await _manager.analytics!.trackEvent(
        AnalyticsEvent.errorOccurred(
          errorType: 'educational_error',
          errorMessage: exception.toString(),
          stackTrace: stackTrace?.toString(),
          context: 'pattern_learning_$patternName',
        ),
      );
    }
  }

  /// Measure operation with performance and security
  static Future<Either<Failure, T>> measureSecureOperation<T>({
    required String operationName,
    required Future<Either<Failure, T>> Function() operation,
    Map<String, String>? attributes,
    bool requireSecurity = false,
  }) async {
    // Wrap with security if required
    if (requireSecurity && _manager.appCheck != null) {
      return _manager.appCheck!.validateRequest(
        request: () async {
          final result = await operation();
          return result.fold((l) => throw Exception(l.message), (r) => r);
        },
      );
    }

    // Wrap with performance monitoring
    if (_manager.performance != null) {
      return _manager.performance!.measureExecution(
        traceName: operationName,
        operation: () async {
          final result = await operation();
          return result.fold((l) => throw Exception(l.message), (r) => r);
        },
        attributes: attributes,
      );
    }

    return operation();
  }

  /// Get comprehensive service health
  static Future<Map<String, dynamic>> getServiceHealth() async {
    final health = <String, dynamic>{
      'firebase_manager': _manager.serviceStatus,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Analytics health
    if (_manager.analytics != null) {
      health['analytics'] = {
        'available': true,
        'observers_count': _manager._analyticsObservers.length,
      };
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
  }

  /// Emergency shutdown of all services
  static Future<void> emergencyShutdown() async {
    Log.warning('TowerDefenseFirebaseHelper: Emergency shutdown initiated');

    try {
      await _manager.setServicesEnabled(false);
      await _manager.dispose();

      Log.info('TowerDefenseFirebaseHelper: Emergency shutdown completed');
    } catch (e) {
      Log.error(
        'TowerDefenseFirebaseHelper: Error during emergency shutdown: $e',
      );
    }
  }
}
