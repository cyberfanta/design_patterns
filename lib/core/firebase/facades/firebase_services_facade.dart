/// PATTERN: Facade Pattern - Simplified interface for Firebase services
/// WHERE: Core Firebase facades - Central coordination
/// HOW: Single simplified interface hiding multiple service complexities
/// WHY: Reduce coupling and provide clean API for Firebase operations
library;

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../contracts/analytics_contract.dart';
import '../entities/analytics_event.dart';
import '../services/firebase_manager.dart';

/// Firebase Services Facade
/// Tower Defense Context: Simplified interface for all game Firebase operations
class FirebaseServicesFacade {
  FirebaseServicesFacade._();

  static FirebaseServicesFacade? _instance;

  /// PATTERN: Singleton - Single facade instance
  static FirebaseServicesFacade get instance {
    _instance ??= FirebaseServicesFacade._();
    return _instance!;
  }

  late final FirebaseManager _manager;

  bool _isInitialized = false;

  /// Initialize all Firebase services through facade
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
      Log.info('FirebaseServicesFacade: Starting Firebase initialization...');

      _manager = FirebaseManager.instance;
      final result = await _manager.initialize(
        enableAnalytics: enableAnalytics,
        enablePerformance: enablePerformance,
        enableCrashlytics: enableCrashlytics,
        enableAppCheck: enableAppCheck,
      );

      if (result.isRight()) {
        _isInitialized = true;
        Log.success(
          'FirebaseServicesFacade: All services initialized successfully',
        );
      }

      return result;
    } catch (e) {
      Log.error('FirebaseServicesFacade: Initialization failed: $e');
      return Left(
        TechnicalFailure(message: 'Facade initialization failed: $e'),
      );
    }
  }

  /// Analytics Operations
  Future<Either<Failure, void>> trackEvent(AnalyticsEvent event) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Firebase services not initialized'),
      );
    }

    return _manager.analytics?.trackEvent(event) ??
        Left(ValidationFailure(message: 'Analytics service not available'));
  }

  Future<Either<Failure, void>> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Firebase services not initialized'),
      );
    }

    return _manager.analytics?.trackScreenView(
          screenName: screenName,
          screenClass: screenClass,
          parameters: parameters,
        ) ??
        Left(ValidationFailure(message: 'Analytics service not available'));
  }

  void addAnalyticsObserver(AnalyticsEventObserver observer) {
    _manager.analytics?.addObserver(observer);
  }

  /// Performance Operations
  Future<Either<Failure, String>> startTrace(String traceName) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Firebase services not initialized'),
      );
    }

    return _manager.performance?.startTrace(traceName) ??
        Left(ValidationFailure(message: 'Performance service not available'));
  }

  Future<Either<Failure, void>> stopTrace(String traceName) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Firebase services not initialized'),
      );
    }

    return _manager.performance?.stopTrace(traceName) ??
        Left(ValidationFailure(message: 'Performance service not available'));
  }

  /// Crashlytics Operations
  Future<Either<Failure, void>> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Firebase services not initialized'),
      );
    }

    return _manager.crashlytics?.recordError(
          exception: exception,
          stackTrace: stackTrace,
          reason: reason,
          fatal: fatal,
        ) ??
        Left(ValidationFailure(message: 'Crashlytics service not available'));
  }

  Future<Either<Failure, void>> setCustomKey({
    required String key,
    required String value,
  }) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Firebase services not initialized'),
      );
    }

    return _manager.crashlytics?.setCustomKey(key: key, value: value) ??
        Left(ValidationFailure(message: 'Crashlytics service not available'));
  }

  /// App Check Operations
  Future<Either<Failure, String>> getAppCheckToken({
    bool forceRefresh = false,
  }) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Firebase services not initialized'),
      );
    }

    return _manager.appCheck?.getToken(forceRefresh: forceRefresh) ??
        Left(ValidationFailure(message: 'App Check service not available'));
  }

  /// Service Management
  Future<Either<Failure, void>> setServicesEnabled(bool enabled) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Firebase services not initialized'),
      );
    }

    return _manager.setServicesEnabled(enabled);
  }

  /// Health Check
  Map<String, dynamic> getServicesStatus() {
    if (!_isInitialized) {
      return {'initialized': false, 'error': 'Services not initialized'};
    }

    return {
      'initialized': true,
      'analytics_available': _manager.analytics != null,
      'performance_available': _manager.performance != null,
      'crashlytics_available': _manager.crashlytics != null,
      'app_check_available': _manager.appCheck != null,
    };
  }

  /// Dispose all services
  Future<void> dispose() async {
    if (_isInitialized) {
      await _manager.dispose();
      _isInitialized = false;
      _instance = null;

      Log.info('FirebaseServicesFacade: All services disposed');
    }
  }
}
