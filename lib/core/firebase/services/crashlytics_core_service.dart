/// Crashlytics Core Service - Simplified Core Operations
///
/// PATTERN: Facade + Singleton - Core crashlytics operations only
/// WHERE: Core Firebase services - Essential crashlytics management
/// HOW: Simplified service focused on core crashlytics functionality
/// WHY: Reduced complexity with essential operations under 400 lines
library;

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../contracts/crashlytics_contract.dart';

/// Crashlytics Core Service - Essential Operations
/// Tower Defense Context: Core crash reporting for educational game
class CrashlyticsCoreService implements CrashlyticsContract {
  CrashlyticsCoreService._();

  static CrashlyticsCoreService? _instance;

  /// PATTERN: Singleton - Single crashlytics core service instance
  static CrashlyticsCoreService get instance {
    _instance ??= CrashlyticsCoreService._();
    return _instance!;
  }

  late final FirebaseCrashlytics _crashlytics;

  bool _isInitialized = false;
  bool _crashlyticsEnabled = true;

  /// Initialize core crashlytics service
  @override
  Future<Either<Failure, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      Log.debug(
        'CrashlyticsCoreService: Initializing crashlytics core service',
      );

      _crashlytics = FirebaseCrashlytics.instance;

      // Enable crashlytics collection
      await _crashlytics.setCrashlyticsCollectionEnabled(_crashlyticsEnabled);

      // Setup basic error handling
      _setupBasicErrorHandling();

      _isInitialized = true;
      Log.success(
        'CrashlyticsCoreService: Crashlytics core service initialized',
      );

      return const Right(null);
    } catch (e) {
      Log.error('CrashlyticsCoreService: Failed to initialize: $e');
      return Left(
        TechnicalFailure(message: 'Crashlytics core initialization failed: $e'),
      );
    }
  }

  /// Setup basic Flutter error handling
  void _setupBasicErrorHandling() {
    // Setup Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      Log.error('Flutter Error: ${details.exception}');

      _crashlytics.recordFlutterFatalError(details);
    };

    // Setup platform error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      Log.error('Platform Error: $error');

      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    Log.debug('CrashlyticsCoreService: Basic error handlers configured');
  }

  /// Enable or disable crashlytics
  @override
  Future<Either<Failure, void>> setCrashlyticsEnabled(bool enabled) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Crashlytics core service not initialized'),
      );
    }

    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      _crashlyticsEnabled = enabled;

      Log.info(
        'CrashlyticsCoreService: Crashlytics ${enabled ? 'enabled' : 'disabled'}',
      );
      return const Right(null);
    } catch (e) {
      Log.error('CrashlyticsCoreService: Failed to toggle crashlytics: $e');
      return Left(
        TechnicalFailure(message: 'Failed to toggle crashlytics: $e'),
      );
    }
  }

  /// Record error with context
  @override
  Future<Either<Failure, void>> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized || !_crashlyticsEnabled) {
      return Left(
        ValidationFailure(message: 'Crashlytics core service not available'),
      );
    }

    try {
      Log.debug(
        'CrashlyticsCoreService: Recording error: ${exception.toString()}',
      );

      // Add context as custom keys
      if (context != null) {
        for (final entry in context.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }

      // Record the error
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      Log.success('CrashlyticsCoreService: Error recorded successfully');
      return const Right(null);
    } catch (e) {
      Log.error('CrashlyticsCoreService: Failed to record error: $e');
      return Left(TechnicalFailure(message: 'Error recording failed: $e'));
    }
  }

  /// Set user identifier
  @override
  Future<Either<Failure, void>> setUserIdentifier(String userId) async {
    if (!_isInitialized || !_crashlyticsEnabled) {
      return const Right(null);
    }

    try {
      await _crashlytics.setUserIdentifier(userId);
      Log.debug('CrashlyticsCoreService: User identifier set: $userId');
      return const Right(null);
    } catch (e) {
      Log.error('CrashlyticsCoreService: Failed to set user identifier: $e');
      return Left(
        TechnicalFailure(message: 'Failed to set user identifier: $e'),
      );
    }
  }

  /// Set custom key
  @override
  Future<Either<Failure, void>> setCustomKey({
    required String key,
    required dynamic value,
  }) async {
    if (!_isInitialized || !_crashlyticsEnabled) {
      return const Right(null);
    }

    try {
      await _crashlytics.setCustomKey(key, value);
      Log.debug('CrashlyticsCoreService: Custom key set: $key = $value');
      return const Right(null);
    } catch (e) {
      Log.error('CrashlyticsCoreService: Failed to set custom key: $e');
      return Left(TechnicalFailure(message: 'Failed to set custom key: $e'));
    }
  }

  /// Log message
  @override
  Future<Either<Failure, void>> log(String message) async {
    if (!_isInitialized || !_crashlyticsEnabled) {
      return const Right(null);
    }

    try {
      _crashlytics.log(message);
      Log.debug('CrashlyticsCoreService: Message logged: $message');
      return const Right(null);
    } catch (e) {
      Log.error('CrashlyticsCoreService: Failed to log message: $e');
      return Left(TechnicalFailure(message: 'Failed to log message: $e'));
    }
  }

  /// Test crash (debug only)
  @override
  Future<Either<Failure, void>> testCrash() async {
    if (!_isInitialized || !_crashlyticsEnabled) {
      return Left(
        ValidationFailure(message: 'Crashlytics core service not available'),
      );
    }

    try {
      if (kDebugMode) {
        Log.warning('CrashlyticsCoreService: Triggering test crash');
        _crashlytics.crash();
      } else {
        Log.warning(
          'CrashlyticsCoreService: Test crash skipped in release mode',
        );
      }
      return const Right(null);
    } catch (e) {
      Log.error('CrashlyticsCoreService: Test crash failed: $e');
      return Left(TechnicalFailure(message: 'Test crash failed: $e'));
    }
  }

  /// Check if collection is enabled
  @override
  Future<Either<Failure, bool>> isCrashlyticsCollectionEnabled() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Crashlytics not initialized'));
    }

    try {
      final isEnabled = _crashlytics.isCrashlyticsCollectionEnabled;
      return Right(isEnabled);
    } catch (e) {
      Log.error(
        'CrashlyticsCoreService: Failed to check collection status: $e',
      );
      return Left(
        TechnicalFailure(message: 'Failed to check collection status: $e'),
      );
    }
  }

  /// Send unsent reports
  @override
  Future<Either<Failure, void>> sendUnsentReports() async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Crashlytics core service not initialized'),
      );
    }

    try {
      await _crashlytics.sendUnsentReports();
      Log.info('CrashlyticsCoreService: Unsent reports sent');
      return const Right(null);
    } catch (e) {
      Log.error('CrashlyticsCoreService: Failed to send unsent reports: $e');
      return Left(
        TechnicalFailure(message: 'Failed to send unsent reports: $e'),
      );
    }
  }

  /// Delete unsent reports
  @override
  Future<Either<Failure, void>> deleteUnsentReports() async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Crashlytics core service not initialized'),
      );
    }

    try {
      await _crashlytics.deleteUnsentReports();
      Log.info('CrashlyticsCoreService: Unsent reports deleted');
      return const Right(null);
    } catch (e) {
      Log.error('CrashlyticsCoreService: Failed to delete unsent reports: $e');
      return Left(
        TechnicalFailure(message: 'Failed to delete unsent reports: $e'),
      );
    }
  }

  /// Get core service status
  Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'collection_enabled': _crashlyticsEnabled,
      'service_type': 'core_crashlytics',
    };
  }

  /// Dispose core service
  Future<void> dispose() async {
    if (_isInitialized) {
      Log.info('CrashlyticsCoreService: Disposing core service');

      _isInitialized = false;
      _crashlyticsEnabled = true;
      _instance = null;

      Log.debug('CrashlyticsCoreService: Core service disposed');
    }
  }
}

/// Tower Defense Crashlytics Core Helper
/// Educational Context: Essential crash reporting for educational game
class TowerDefenseCrashlyticsCoreHelper {
  static final CrashlyticsCoreService _crashlytics =
      CrashlyticsCoreService.instance;

  /// Record educational error with minimal context
  static Future<Either<Failure, void>> recordEducationalError({
    required dynamic exception,
    required String context,
    String? patternName,
    StackTrace? stackTrace,
  }) async {
    return await _crashlytics.recordError(
      exception: exception,
      stackTrace: stackTrace,
      reason: 'Educational error: $context',
      fatal: false,
      context: {
        'educational_context': context,
        if (patternName != null) 'pattern_name': patternName,
        'tower_defense': true,
      },
    );
  }

  /// Set educational context
  static Future<void> setEducationalContext({
    String? currentPattern,
    String? learningPhase,
  }) async {
    if (currentPattern != null) {
      await _crashlytics.setCustomKey(
        key: 'current_pattern',
        value: currentPattern,
      );
    }
    if (learningPhase != null) {
      await _crashlytics.setCustomKey(
        key: 'learning_phase',
        value: learningPhase,
      );
    }
  }
}
