/// Firebase Manager - Simplified Compatibility Wrapper
///
/// PATTERN: Facade + Singleton - Compatibility delegation wrapper
/// WHERE: Legacy Firebase manager - Backward compatibility
/// HOW: Delegates to FirebaseCoreManager for actual operations
/// WHY: Maintain compatibility while reducing complexity to under 400 lines
library;

import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../patterns/analytics_observer_pattern.dart';
import 'analytics_service.dart';
import 'app_check_service.dart';
import 'crashlytics_service.dart';
import 'firebase_core_manager.dart';
import 'performance_service.dart';

/// Firebase Manager - Compatibility Wrapper
/// Tower Defense Context: Simplified manager delegating to core services
class FirebaseManager {
  FirebaseManager._();

  static FirebaseManager? _instance;

  /// PATTERN: Singleton - Single Firebase manager instance
  static FirebaseManager get instance {
    _instance ??= FirebaseManager._();
    return _instance!;
  }

  // Delegation to core manager
  final FirebaseCoreManager _coreManager = FirebaseCoreManager.instance;

  // Compatibility getters - delegate to core manager
  FirebaseAnalyticsService? get analytics => _coreManager.analytics;

  FirebasePerformanceService? get performance => _coreManager.performance;

  FirebaseCrashlyticsService? get crashlytics => _coreManager.crashlytics;

  FirebaseAppCheckService? get appCheck => _coreManager.appCheck;

  bool get isInitialized => _coreManager.isInitialized;

  /// Initialize all Firebase services - delegate to core manager
  Future<Either<Failure, void>> initialize({
    bool enableAnalytics = true,
    bool enablePerformance = true,
    bool enableCrashlytics = true,
    bool enableAppCheck = true,
  }) async {
    Log.debug(
        'FirebaseManager: Delegating initialization to FirebaseCoreManager');

    return await _coreManager.initialize(
      enableAnalytics: enableAnalytics,
      enablePerformance: enablePerformance,
      enableCrashlytics: enableCrashlytics,
      enableAppCheck: enableAppCheck,
    );
  }

  /// Enable or disable all services - delegate to core manager
  Future<Either<Failure, void>> setServicesEnabled(bool enabled) async {
    Log.debug(
        'FirebaseManager: Delegating service toggle to FirebaseCoreManager');

    return await _coreManager.setServicesEnabled(enabled);
  }

  /// Get basic status - delegate to core manager
  Map<String, dynamic> getStatus() {
    return {
      'manager_type': 'compatibility_wrapper',
      'core_manager_status': _coreManager.getStatus(),
    };
  }

  /// Dispose all services - delegate to core manager
  Future<void> dispose() async {
    Log.debug('FirebaseManager: Delegating disposal to FirebaseCoreManager');

    await _coreManager.dispose();
    _instance = null;

    Log.info('FirebaseManager: Compatibility wrapper disposed');
  }
}

/// Tower Defense Firebase Helper - Compatibility Methods
/// Educational Context: Legacy helper methods for backward compatibility
class TowerDefenseFirebaseHelper {
  static final FirebaseManager _manager = FirebaseManager.instance;

  /// Execute secure operation - simplified version
  static Future<Either<Failure, T>> executeSecureOperation<T>({
    required Future<Either<Failure, T>> Function() operation,
  }) async {
    Log.debug('TowerDefenseFirebaseHelper: Executing secure operation');

    if (_manager.appCheck == null) {
      Log.warning(
          'TowerDefenseFirebaseHelper: App Check not available, executing without validation');
      return await operation();
    }

    return await _manager.appCheck!.validateRequest<T>(
      request: () async {
        final result = await operation();
        return result.fold((l) => throw Exception(l.message), (r) => r);
      },
    );
  }

  /// Measure operation performance - simplified version
  static Future<Either<Failure, T>> measureOperation<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String operationName,
    Map<String, String>? attributes,
  }) async {
    Log.debug(
        'TowerDefenseFirebaseHelper: Measuring operation: $operationName');

    if (_manager.performance == null) {
      Log.warning(
          'TowerDefenseFirebaseHelper: Performance monitoring not available');
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

  /// Get simplified health status
  static Future<Map<String, dynamic>> getHealthStatus() async {
    final health = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'compatibility_layer': 'active',
    };

    try {
      // Get status from core manager
      final coreStatus = _manager.getStatus();
      health.addAll(coreStatus);

      // Basic service availability
      health['services'] = {
        'analytics': _manager.analytics != null,
        'performance': _manager.performance != null,
        'crashlytics': _manager.crashlytics != null,
        'app_check': _manager.appCheck != null,
      };

      return health;
    } catch (e) {
      health['health_check_error'] = e.toString();
      return health;
    }
  }

  /// Emergency shutdown - simplified version
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

/// Compatibility Observer Setup
/// Provides backward compatibility for analytics observers
class FirebaseManagerObserverSetup {
  static void setupDefaultObservers(FirebaseManager manager) {
    if (manager.analytics == null) return;

    try {
      Log.debug('FirebaseManagerObserverSetup: Setting up default observers');

      // Add basic observers for compatibility
      final observers = [
        LearningProgressObserver(),
        GamePerformanceObserver(),
        UserEngagementObserver(),
        ErrorTrackingObserver(),
      ];

      for (final observer in observers) {
        manager.analytics!.addObserver(observer);
      }

      Log.success('FirebaseManagerObserverSetup: Default observers configured');
    } catch (e) {
      Log.error('FirebaseManagerObserverSetup: Failed to setup observers: $e');
    }
  }
}

/// Migration Notice
/// 
/// DEPRECATED: This FirebaseManager is maintained for backward compatibility.
/// 
/// NEW CODE SHOULD USE:
/// - FirebaseCoreManager for basic service management
/// - FirebaseServicesFacade for simplified operations  
/// - TowerDefenseFirebaseFacade for game-specific operations
/// - Individual facades for specialized operations
/// 
/// This wrapper will be removed in a future version.
