/// Firebase Core Manager - Simplified Core Coordinator
///
/// PATTERN: Facade + Singleton - Core Firebase services management
/// WHERE: Core Firebase services - Essential service coordination only
/// HOW: Simplified manager focused on service lifecycle and coordination
/// WHY: Reduced complexity with delegation to specialized facades
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

/// Firebase Core Manager - Essential Services Coordinator
/// Tower Defense Context: Core Firebase service lifecycle management
class FirebaseCoreManager {
  FirebaseCoreManager._();

  static FirebaseCoreManager? _instance;

  /// PATTERN: Singleton - Single core manager instance
  static FirebaseCoreManager get instance {
    _instance ??= FirebaseCoreManager._();
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

  // Service getters
  FirebaseAnalyticsService? get analytics => _analytics;

  FirebasePerformanceService? get performance => _performance;

  FirebaseCrashlyticsService? get crashlytics => _crashlytics;

  FirebaseAppCheckService? get appCheck => _appCheck;

  bool get isInitialized => _isInitialized;

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
      Log.info('FirebaseCoreManager: Initializing Firebase services...');

      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      Log.success('FirebaseCoreManager: Firebase Core initialized');

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
        'FirebaseCoreManager: All Firebase services initialized successfully',
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
      Log.error(
        'FirebaseCoreManager: Failed to initialize Firebase services: $e',
      );

      // Record initialization failure
      if (_crashlytics != null) {
        await _crashlytics!.recordError(
          exception: e,
          reason: 'Firebase services initialization failure',
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
        final serviceName = _getServiceName(
          i,
          enableAnalytics,
          enablePerformance,
          enableCrashlytics,
          enableAppCheck,
        );
        final error = result.fold((l) => l.message, (r) => 'Unknown error');
        Log.warning(
          'FirebaseCoreManager: Failed to initialize $serviceName: $error',
        );
      }
    }
  }

  /// Get service name by index for error reporting
  String _getServiceName(
    int index,
    bool analytics,
    bool performance,
    bool crashlytics,
    bool appCheck,
  ) {
    int serviceIndex = 0;
    if (analytics && serviceIndex++ == index) return 'Analytics';
    if (performance && serviceIndex++ == index) return 'Performance';
    if (crashlytics && serviceIndex++ == index) return 'Crashlytics';
    if (appCheck && serviceIndex == index) return 'AppCheck';
    return 'Unknown Service';
  }

  /// Setup coordination between services
  void _setupServiceCoordination() {
    // Performance monitoring for analytics events
    if (_performance != null && _analytics != null) {
      Log.debug(
        'FirebaseCoreManager: Setting up Analytics-Performance coordination',
      );
    }

    // Crashlytics for service errors
    if (_crashlytics != null) {
      Log.debug(
        'FirebaseCoreManager: Setting up error coordination with Crashlytics',
      );
    }

    // App Check for service security
    if (_appCheck != null) {
      Log.debug(
        'FirebaseCoreManager: Setting up security coordination with App Check',
      );
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

    Log.debug('FirebaseCoreManager: Analytics observers configured');
  }

  /// Enable or disable all services
  Future<Either<Failure, void>> setServicesEnabled(bool enabled) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Firebase Core Manager not initialized'),
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
            'FirebaseCoreManager: Failed to update service state: $error',
          );
        }
      }

      Log.info(
        'FirebaseCoreManager: All services ${enabled ? 'enabled' : 'disabled'}',
      );
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseCoreManager: Failed to update services state: $e');
      return Left(
        TechnicalFailure(message: 'Failed to update services state: $e'),
      );
    }
  }

  /// Get basic status of all services
  Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'services_enabled': _servicesEnabled,
      'analytics_available': _analytics != null,
      'performance_available': _performance != null,
      'crashlytics_available': _crashlytics != null,
      'app_check_available': _appCheck != null,
      'observers_count': _analyticsObservers.length,
    };
  }

  /// Dispose all services
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      Log.info('FirebaseCoreManager: Disposing all services...');

      // Dispose individual services
      if (_performance != null) {
        await _performance!.dispose();
      }

      // Clear observers
      _analyticsObservers.clear();

      // Reset state
      _analytics = null;
      _performance = null;
      _crashlytics = null;
      _appCheck = null;
      _isInitialized = false;
      _servicesEnabled = true;
      _instance = null;

      Log.success('FirebaseCoreManager: All services disposed');
    } catch (e) {
      Log.error('FirebaseCoreManager: Error during disposal: $e');
    }
  }
}
