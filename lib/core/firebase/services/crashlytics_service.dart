/// Firebase Crashlytics Service
///
/// PATTERN: Chain of Responsibility - Error handling chain
/// WHERE: Core Firebase services - Crashlytics implementation
/// HOW: Chain of handlers for different error types and severities
/// WHY: Comprehensive error reporting with contextual information for debugging
library;

import 'dart:async';
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../contracts/crashlytics_contract.dart';
import '../entities/crash_report.dart';
import '../patterns/error_handler_chain.dart';

/// Firebase Crashlytics Service Implementation
///
/// Tower Defense Context: Tracks crashes, errors, and issues during
/// educational gameplay to ensure smooth learning experience
class FirebaseCrashlyticsService implements CrashlyticsContract {
  FirebaseCrashlyticsService._();

  static FirebaseCrashlyticsService? _instance;

  /// PATTERN: Singleton - Single crashlytics service instance
  static FirebaseCrashlyticsService get instance {
    _instance ??= FirebaseCrashlyticsService._();
    return _instance!;
  }

  late final FirebaseCrashlytics _crashlytics;
  late final ErrorHandlerChain _errorChain;
  bool _isInitialized = false;
  bool _crashlyticsEnabled = true;

  /// Initialize Crashlytics service
  @override
  Future<Either<Failure, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      Log.debug('FirebaseCrashlyticsService: Initializing crashlytics service');

      _crashlytics = FirebaseCrashlytics.instance;

      // Enable crashlytics collection
      await _crashlytics.setCrashlyticsCollectionEnabled(_crashlyticsEnabled);

      // Set up error handlers chain
      _setupErrorHandlerChain();

      // Setup Flutter error handling
      _setupFlutterErrorHandling();

      // Setup isolate error handling
      _setupIsolateErrorHandling();

      _isInitialized = true;
      Log.success(
        'FirebaseCrashlyticsService: Crashlytics service initialized',
      );

      return const Right(null);
    } catch (e) {
      Log.error('FirebaseCrashlyticsService: Failed to initialize: $e');
      return Left(
        TechnicalFailure(message: 'Crashlytics initialization failed: $e'),
      );
    }
  }

  /// PATTERN: Chain of Responsibility - Setup error handling chain
  void _setupErrorHandlerChain() {
    _errorChain = ErrorHandlerChain();

    // Add handlers in order of priority
    _errorChain
        .addHandler(CriticalErrorHandler(_crashlytics))
        .addHandler(GameLogicErrorHandler(_crashlytics))
        .addHandler(UIErrorHandler(_crashlytics))
        .addHandler(NetworkErrorHandler(_crashlytics))
        .addHandler(EducationalContentErrorHandler(_crashlytics))
        .addHandler(GeneralErrorHandler(_crashlytics));
  }

  /// Setup Flutter framework error handling
  void _setupFlutterErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      Log.error('Flutter Error: ${details.exception}');

      final crashReport = CrashReport.fromFlutterError(details);
      _errorChain.handleError(crashReport);
    };
  }

  /// Setup Dart isolate error handling
  void _setupIsolateErrorHandling() {
    Isolate.current.addErrorListener(
      RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        final error = errorAndStacktrace[0];
        final stackTrace = errorAndStacktrace[1];

        Log.error('Isolate Error: $error');

        final crashReport = CrashReport.fromIsolateError(error, stackTrace);
        _errorChain.handleError(crashReport);
      }).sendPort,
    );
  }

  /// Enable or disable crashlytics collection
  @override
  Future<Either<Failure, void>> setCrashlyticsEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      _crashlyticsEnabled = enabled;

      Log.info(
        'FirebaseCrashlyticsService: Crashlytics ${enabled ? 'enabled' : 'disabled'}',
      );
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseCrashlyticsService: Failed to toggle crashlytics: $e');
      return Left(
        TechnicalFailure(message: 'Failed to toggle crashlytics: $e'),
      );
    }
  }

  /// Record custom error
  @override
  Future<Either<Failure, void>> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized || !_crashlyticsEnabled) {
      return const Right(null);
    }

    try {
      Log.debug(
        'FirebaseCrashlyticsService: Recording error: ${exception.toString()}',
      );

      // Create crash report
      final crashReport = CrashReport.custom(
        exception: exception,
        stackTrace: stackTrace,
        reason: reason,
        fatal: fatal,
        context: context ?? {},
      );

      // Process through error handler chain
      _errorChain.handleError(crashReport);

      Log.success('FirebaseCrashlyticsService: Error recorded successfully');
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseCrashlyticsService: Failed to record error: $e');
      return Left(TechnicalFailure(message: 'Failed to record error: $e'));
    }
  }

  /// Log custom message
  @override
  Future<Either<Failure, void>> log(String message) async {
    if (!_isInitialized || !_crashlyticsEnabled) {
      return const Right(null);
    }

    try {
      await _crashlytics.log(message);
      Log.debug('FirebaseCrashlyticsService: Message logged');
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseCrashlyticsService: Failed to log message: $e');
      return Left(TechnicalFailure(message: 'Failed to log message: $e'));
    }
  }

  /// Set user identifier
  @override
  Future<Either<Failure, void>> setUserIdentifier(String identifier) async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Crashlytics not initialized'));
    }

    try {
      await _crashlytics.setUserIdentifier(identifier);
      Log.debug('FirebaseCrashlyticsService: User identifier set');
      return const Right(null);
    } catch (e) {
      Log.error(
        'FirebaseCrashlyticsService: Failed to set user identifier: $e',
      );
      return Left(
        TechnicalFailure(message: 'Failed to set user identifier: $e'),
      );
    }
  }

  /// Set custom key-value pair
  @override
  Future<Either<Failure, void>> setCustomKey({
    required String key,
    required dynamic value,
  }) async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Crashlytics not initialized'));
    }

    try {
      await _crashlytics.setCustomKey(key, value);
      Log.debug('FirebaseCrashlyticsService: Custom key set: $key');
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseCrashlyticsService: Failed to set custom key: $e');
      return Left(TechnicalFailure(message: 'Failed to set custom key: $e'));
    }
  }

  /// Force a crash (for testing purposes only)
  @override
  Future<Either<Failure, void>> testCrash() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Crashlytics not initialized'));
    }

    try {
      Log.warning('FirebaseCrashlyticsService: Forcing test crash');
      _crashlytics.crash();
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseCrashlyticsService: Test crash failed: $e');
      return Left(TechnicalFailure(message: 'Test crash failed: $e'));
    }
  }

  /// Check if crash collection is enabled
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
        'FirebaseCrashlyticsService: Failed to check collection status: $e',
      );
      return Left(
        TechnicalFailure(message: 'Failed to check collection status: $e'),
      );
    }
  }

  /// Send unsent crash reports
  @override
  Future<Either<Failure, void>> sendUnsentReports() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Crashlytics not initialized'));
    }

    try {
      await _crashlytics.sendUnsentReports();
      Log.info('FirebaseCrashlyticsService: Unsent reports sent');
      return const Right(null);
    } catch (e) {
      Log.error(
        'FirebaseCrashlyticsService: Failed to send unsent reports: $e',
      );
      return Left(
        TechnicalFailure(message: 'Failed to send unsent reports: $e'),
      );
    }
  }

  /// Delete unsent crash reports
  @override
  Future<Either<Failure, void>> deleteUnsentReports() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Crashlytics not initialized'));
    }

    try {
      await _crashlytics.deleteUnsentReports();
      Log.info('FirebaseCrashlyticsService: Unsent reports deleted');
      return const Right(null);
    } catch (e) {
      Log.error(
        'FirebaseCrashlyticsService: Failed to delete unsent reports: $e',
      );
      return Left(
        TechnicalFailure(message: 'Failed to delete unsent reports: $e'),
      );
    }
  }

  /// Dispose service
  Future<void> dispose() async {
    _errorChain.dispose();
    Log.debug('FirebaseCrashlyticsService: Service disposed');
  }
}

/// Tower Defense Crashlytics Helper
///
/// Educational Context: Specific error tracking for game mechanics
class TowerDefenseCrashlyticsHelper {
  static final FirebaseCrashlyticsService _crashlytics =
      FirebaseCrashlyticsService.instance;

  /// Record pattern learning error
  static Future<void> recordPatternError({
    required String patternName,
    required String errorType,
    required dynamic exception,
    StackTrace? stackTrace,
  }) async {
    await _crashlytics.recordError(
      exception: exception,
      stackTrace: stackTrace,
      reason: 'Pattern learning error: $patternName',
      context: {
        'pattern_name': patternName,
        'error_category': 'educational_content',
        'error_type': errorType,
      },
    );
  }

  /// Record game logic error
  static Future<void> recordGameLogicError({
    required String operation,
    required dynamic exception,
    Map<String, dynamic>? gameState,
  }) async {
    await _crashlytics.recordError(
      exception: exception,
      reason: 'Game logic error: $operation',
      context: {
        'operation': operation,
        'error_category': 'game_logic',
        'game_state': gameState ?? {},
      },
    );
  }

  /// Record UI rendering error
  static Future<void> recordUIError({
    required String widget,
    required dynamic exception,
    String? userAction,
  }) async {
    await _crashlytics.recordError(
      exception: exception,
      reason: 'UI error in widget: $widget',
      context: {
        'widget_name': widget,
        'error_category': 'ui_rendering',
        'user_action': userAction ?? 'unknown',
      },
    );
  }

  /// Record network error
  static Future<void> recordNetworkError({
    required String endpoint,
    required dynamic exception,
    int? statusCode,
  }) async {
    await _crashlytics.recordError(
      exception: exception,
      reason: 'Network error: $endpoint',
      context: {
        'endpoint': endpoint,
        'error_category': 'network',
        'status_code': statusCode ?? 0,
      },
    );
  }

  /// Set educational context for crashes
  static Future<void> setEducationalContext({
    required String currentPattern,
    required String learningPhase,
    String? difficulty,
  }) async {
    await _crashlytics.setCustomKey(
      key: 'current_pattern',
      value: currentPattern,
    );
    await _crashlytics.setCustomKey(
      key: 'learning_phase',
      value: learningPhase,
    );
    if (difficulty != null) {
      await _crashlytics.setCustomKey(
        key: 'difficulty_level',
        value: difficulty,
      );
    }
  }
}
