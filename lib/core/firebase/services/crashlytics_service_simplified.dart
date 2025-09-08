/// Firebase Crashlytics Service - Compatibility Wrapper
///
/// PATTERN: Facade + Singleton - Compatibility delegation wrapper
/// WHERE: Legacy crashlytics service - Backward compatibility
/// HOW: Delegates to CrashlyticsCoreService for actual operations
/// WHY: Maintain compatibility while reducing complexity to under 400 lines
library;

import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../contracts/crashlytics_contract.dart';
import '../entities/crash_report.dart';
import '../patterns/error_handler_chain.dart';
import 'crashlytics_core_service.dart';

/// Firebase Crashlytics Service - Compatibility Wrapper
/// Tower Defense Context: Advanced crashlytics with error handler chain
class FirebaseCrashlyticsService implements CrashlyticsContract {
  FirebaseCrashlyticsService._();

  static FirebaseCrashlyticsService? _instance;

  /// PATTERN: Singleton - Single crashlytics service instance
  static FirebaseCrashlyticsService get instance {
    _instance ??= FirebaseCrashlyticsService._();
    return _instance!;
  }

  // Delegation to core service
  final CrashlyticsCoreService _coreService = CrashlyticsCoreService.instance;
  late final ErrorHandlerChain _errorChain;

  /// Initialize crashlytics service - delegate to core
  @override
  Future<Either<Failure, void>> initialize() async {
    Log.debug(
      'FirebaseCrashlyticsService: Delegating initialization to CrashlyticsCoreService',
    );

    // Initialize core service
    final result = await _coreService.initialize();

    if (result.isRight()) {
      // Set up error handlers chain for advanced error handling
      _setupErrorHandlerChain();
      Log.success(
        'FirebaseCrashlyticsService: Advanced error handling initialized',
      );
    }

    return result;
  }

  /// Set up error handlers chain for advanced processing
  void _setupErrorHandlerChain() {
    _errorChain = ErrorHandlerChain();
    Log.debug(
      'FirebaseCrashlyticsService: Advanced error handler chain configured',
    );
  }

  /// Enable or disable crashlytics - delegate to core
  @override
  Future<Either<Failure, void>> setCrashlyticsEnabled(bool enabled) async {
    Log.debug(
      'FirebaseCrashlyticsService: Delegating crashlytics toggle to core service',
    );
    return await _coreService.setCrashlyticsEnabled(enabled);
  }

  /// Record error with advanced processing
  @override
  Future<Either<Failure, void>> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? context,
  }) async {
    try {
      Log.debug(
        'FirebaseCrashlyticsService: Processing error with advanced chain',
      );

      // Create crash report for advanced processing
      final crashReport = CrashReport.custom(
        exception: exception,
        stackTrace: stackTrace,
        reason: reason ?? 'Unknown error',
        context: context ?? {},
      );

      // Process through error handler chain for advanced analysis
      _errorChain.handleError(crashReport);

      // Also record in core service
      return await _coreService.recordError(
        exception: exception,
        stackTrace: stackTrace,
        reason: reason,
        fatal: fatal,
        context: context,
      );
    } catch (e) {
      Log.error('FirebaseCrashlyticsService: Failed to process error: $e');
      return Left(TechnicalFailure(message: 'Error processing failed: $e'));
    }
  }

  /// Set user identifier - delegate to core
  @override
  Future<Either<Failure, void>> setUserIdentifier(String userId) async {
    return await _coreService.setUserIdentifier(userId);
  }

  /// Set custom key - delegate to core
  @override
  Future<Either<Failure, void>> setCustomKey({
    required String key,
    required dynamic value,
  }) async {
    return await _coreService.setCustomKey(key: key, value: value.toString());
  }

  /// Test crash - delegate to core
  @override
  Future<Either<Failure, void>> testCrash() async {
    return await _coreService.testCrash();
  }

  /// Check if collection is enabled - delegate to core
  @override
  Future<Either<Failure, bool>> isCrashlyticsCollectionEnabled() async {
    return await _coreService.isCrashlyticsCollectionEnabled();
  }

  /// Send unsent reports - delegate to core
  @override
  Future<Either<Failure, void>> sendUnsentReports() async {
    return await _coreService.sendUnsentReports();
  }

  /// Delete unsent reports - delegate to core
  @override
  Future<Either<Failure, void>> deleteUnsentReports() async {
    return await _coreService.deleteUnsentReports();
  }

  /// Log message - delegate to core
  @override
  Future<Either<Failure, void>> log(String message) async {
    return await _coreService.log(message);
  }

  /// Get service status
  Map<String, dynamic> getStatus() {
    return {
      'service_type': 'advanced_crashlytics_wrapper',
      'core_service_status': _coreService.getStatus(),
      'advanced_error_processing': 'enabled',
    };
  }

  /// Dispose service
  Future<void> dispose() async {
    Log.debug('FirebaseCrashlyticsService: Disposing advanced service wrapper');

    await _coreService.dispose();
    _instance = null;

    Log.info('FirebaseCrashlyticsService: Advanced wrapper disposed');
  }
}

/// Tower Defense Crashlytics Helper - Compatibility Methods
/// Educational Context: Legacy helper methods for backward compatibility
class TowerDefenseCrashlyticsHelper {
  static final FirebaseCrashlyticsService _crashlytics =
      FirebaseCrashlyticsService.instance;

  /// Record pattern learning error - simplified
  static Future<Either<Failure, void>> recordPatternLearningError({
    required dynamic exception,
    required String patternName,
    required String learningPhase,
    String? userInput,
    StackTrace? stackTrace,
  }) async {
    return await _crashlytics.recordError(
      exception: exception,
      stackTrace: stackTrace,
      reason: 'Pattern learning error: $patternName/$learningPhase',
      fatal: false,
      context: {
        'pattern_name': patternName,
        'learning_phase': learningPhase,
        'educational_context': 'pattern_learning',
        if (userInput != null) 'user_input': userInput,
      },
    );
  }

  /// Record game progress error - simplified
  static Future<Either<Failure, void>> recordGameProgressError({
    required dynamic exception,
    required String progressType,
    required Map<String, dynamic> gameState,
    StackTrace? stackTrace,
  }) async {
    return await _crashlytics.recordError(
      exception: exception,
      stackTrace: stackTrace,
      reason: 'Game progress error: $progressType',
      fatal: false,
      context: {
        'progress_type': progressType,
        'educational_context': 'game_progress',
        'game_state': gameState,
      },
    );
  }

  /// Set educational context - simplified
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

/// Migration Notice
///
/// DEPRECATED: This advanced FirebaseCrashlyticsService is maintained for backward compatibility.
///
/// NEW CODE SHOULD USE:
/// - CrashlyticsCoreService for basic crash reporting
/// - ErrorHandlingFacade for advanced error processing
/// - TowerDefenseCrashlyticsCoreHelper for game-specific operations
///
/// This wrapper will be removed in a future version.
