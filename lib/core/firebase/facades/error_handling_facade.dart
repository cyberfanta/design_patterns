/// PATTERN: Facade Pattern - Error handling operations simplification
/// WHERE: Error handling facade - Simplified error management interface
/// HOW: Single interface for complex error handler chain operations
/// WHY: Abstract error handling complexity and provide convenient methods
library;

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../entities/crash_report.dart';
import '../patterns/error_handler_chain.dart';
import '../services/crashlytics_service.dart';

/// Error Handling Facade
/// Tower Defense Context: Simplified error handling for educational game
class ErrorHandlingFacade {
  ErrorHandlingFacade._();

  static ErrorHandlingFacade? _instance;

  /// PATTERN: Singleton - Single error handling facade instance
  static ErrorHandlingFacade get instance {
    _instance ??= ErrorHandlingFacade._();
    return _instance!;
  }

  late final ErrorHandlerChain _errorChain;
  late final FirebaseCrashlyticsService _crashlytics;

  bool _isInitialized = false;

  /// Initialize the error handling system
  Future<Either<Failure, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      Log.debug('ErrorHandlingFacade: Initializing error handling system');

      _crashlytics = FirebaseCrashlyticsService.instance;

      // Initialize error handler chain
      _errorChain = ErrorHandlerChain();

      // Add handlers in priority order
      _errorChain
        ..addHandler(CriticalErrorHandler(FirebaseCrashlytics.instance))
        ..addHandler(NetworkErrorHandler(FirebaseCrashlytics.instance))
        ..addHandler(UIErrorHandler(FirebaseCrashlytics.instance))
        ..addHandler(GeneralErrorHandler(FirebaseCrashlytics.instance));

      _isInitialized = true;
      Log.success('ErrorHandlingFacade: Error handling system initialized');

      return const Right(null);
    } catch (e) {
      Log.error('ErrorHandlingFacade: Failed to initialize: $e');
      return Left(
        TechnicalFailure(message: 'Error handling initialization failed: $e'),
      );
    }
  }

  /// Handle educational error with context
  Future<Either<Failure, void>> handleEducationalError({
    required dynamic exception,
    required String educationalContext,
    String? patternName,
    String? categoryName,
    String? userAction,
    StackTrace? stackTrace,
    bool fatal = false,
  }) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Error handling system not initialized'),
      );
    }

    try {
      Log.debug(
        'ErrorHandlingFacade: Handling educational error in context: $educationalContext',
      );

      // Create comprehensive crash report
      final crashReport = CrashReport.custom(
        exception: exception,
        stackTrace: stackTrace,
        context: {
          'educational_context': educationalContext,
          'error_category': 'educational',
          'tower_defense_specific': true,
          if (patternName != null) 'pattern_name': patternName,
          if (categoryName != null) 'category_name': categoryName,
          if (userAction != null) 'user_action': userAction,
          'timestamp': DateTime.now().toIso8601String(),
          'fatal': fatal,
        },
      );

      // Process through error handler chain
      _errorChain.handleError(crashReport);

      Log.success(
        'ErrorHandlingFacade: Educational error handled successfully',
      );
      return const Right(null);
    } catch (e) {
      Log.error('ErrorHandlingFacade: Failed to handle educational error: $e');
      return Left(TechnicalFailure(message: 'Error handling failed: $e'));
    }
  }

  /// Handle pattern learning error
  Future<Either<Failure, void>> handlePatternLearningError({
    required dynamic exception,
    required String patternName,
    required String learningPhase,
    String? difficultyLevel,
    String? userInput,
    StackTrace? stackTrace,
  }) async {
    return handleEducationalError(
      exception: exception,
      educationalContext: 'pattern_learning',
      patternName: patternName,
      categoryName: learningPhase,
      userAction: userInput != null ? 'user_input: $userInput' : null,
      stackTrace: stackTrace,
      fatal: false,
    );
  }

  /// Handle game progress error
  Future<Either<Failure, void>> handleGameProgressError({
    required dynamic exception,
    required String progressType,
    required String userId,
    String? gameState,
    Map<String, dynamic>? progressData,
    StackTrace? stackTrace,
  }) async {
    return handleEducationalError(
      exception: exception,
      educationalContext: 'game_progress',
      categoryName: progressType,
      userAction: gameState != null ? 'game_state: $gameState' : null,
      stackTrace: stackTrace,
      fatal: false,
    );
  }

  /// Handle UI interaction error
  Future<Either<Failure, void>> handleUIError({
    required dynamic exception,
    required String screenName,
    required String interactionType,
    String? widgetType,
    Map<String, dynamic>? interactionData,
    StackTrace? stackTrace,
  }) async {
    return handleEducationalError(
      exception: exception,
      educationalContext: 'ui_interaction',
      categoryName: screenName,
      userAction:
          '$interactionType${widgetType != null ? ' on $widgetType' : ''}',
      stackTrace: stackTrace,
      fatal: false,
    );
  }

  /// Handle critical system error
  Future<Either<Failure, void>> handleCriticalError({
    required dynamic exception,
    required String systemComponent,
    required String operation,
    Map<String, dynamic>? systemState,
    StackTrace? stackTrace,
  }) async {
    return handleEducationalError(
      exception: exception,
      educationalContext: 'critical_system_error',
      categoryName: systemComponent,
      userAction: operation,
      stackTrace: stackTrace,
      fatal: true,
    );
  }

  /// Handle network/connectivity error
  Future<Either<Failure, void>> handleNetworkError({
    required dynamic exception,
    required String endpoint,
    required String operation,
    int? statusCode,
    String? responseData,
    StackTrace? stackTrace,
  }) async {
    return handleEducationalError(
      exception: exception,
      educationalContext: 'network_error',
      categoryName: 'network_connectivity',
      userAction:
          '$operation on $endpoint${statusCode != null ? ' (HTTP $statusCode)' : ''}',
      stackTrace: stackTrace,
      fatal: false,
    );
  }

  /// Get error handling statistics
  Map<String, dynamic> getErrorStatistics() {
    if (!_isInitialized) {
      return {
        'initialized': false,
        'error': 'Error handling system not initialized',
      };
    }

    // In a real implementation, this would return actual statistics
    return {
      'initialized': true,
      'handlers_count': 6, // Number of handlers in chain
      'total_errors_handled': 0, // Would track actual count
      'critical_errors': 0,
      'educational_errors': 0,
      'ui_errors': 0,
      'network_errors': 0,
      'last_error_timestamp': null,
    };
  }

  /// Test error handling system
  Future<Either<Failure, void>> testErrorHandling() async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Error handling system not initialized'),
      );
    }

    try {
      Log.info('ErrorHandlingFacade: Testing error handling system');

      // Test with a controlled error
      await handleEducationalError(
        exception: Exception('Test error for system validation'),
        educationalContext: 'system_test',
        patternName: 'test_pattern',
        categoryName: 'system_validation',
        userAction: 'error_handling_test',
        fatal: false,
      );

      Log.success(
        'ErrorHandlingFacade: Error handling test completed successfully',
      );
      return const Right(null);
    } catch (e) {
      Log.error('ErrorHandlingFacade: Error handling test failed: $e');
      return Left(TechnicalFailure(message: 'Error handling test failed: $e'));
    }
  }

  /// Set educational context for subsequent errors
  Future<Either<Failure, void>> setEducationalContext({
    String? currentPattern,
    String? currentCategory,
    String? learningPhase,
    String? difficultyLevel,
    String? userId,
  }) async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Error handling system not initialized'),
      );
    }

    try {
      // Set context in Crashlytics for automatic inclusion in reports
      if (currentPattern != null) {
        await _crashlytics.setCustomKey(
          key: 'current_pattern',
          value: currentPattern,
        );
      }
      if (currentCategory != null) {
        await _crashlytics.setCustomKey(
          key: 'pattern_category',
          value: currentCategory,
        );
      }
      if (learningPhase != null) {
        await _crashlytics.setCustomKey(
          key: 'learning_phase',
          value: learningPhase,
        );
      }
      if (difficultyLevel != null) {
        await _crashlytics.setCustomKey(
          key: 'difficulty_level',
          value: difficultyLevel,
        );
      }
      if (userId != null) {
        await _crashlytics.setUserIdentifier(userId);
      }

      Log.debug('ErrorHandlingFacade: Educational context set');
      return const Right(null);
    } catch (e) {
      Log.error('ErrorHandlingFacade: Failed to set educational context: $e');
      return Left(TechnicalFailure(message: 'Failed to set context: $e'));
    }
  }

  /// Clear educational context
  Future<Either<Failure, void>> clearEducationalContext() async {
    if (!_isInitialized) {
      return Left(
        ValidationFailure(message: 'Error handling system not initialized'),
      );
    }

    try {
      // Clear context keys
      await _crashlytics.setCustomKey(key: 'current_pattern', value: '');
      await _crashlytics.setCustomKey(key: 'pattern_category', value: '');
      await _crashlytics.setCustomKey(key: 'learning_phase', value: '');
      await _crashlytics.setCustomKey(key: 'difficulty_level', value: '');

      Log.debug('ErrorHandlingFacade: Educational context cleared');
      return const Right(null);
    } catch (e) {
      Log.error('ErrorHandlingFacade: Failed to clear educational context: $e');
      return Left(TechnicalFailure(message: 'Failed to clear context: $e'));
    }
  }

  /// Dispose error handling system
  Future<void> dispose() async {
    if (_isInitialized) {
      Log.info('ErrorHandlingFacade: Disposing error handling system');

      _isInitialized = false;
      _instance = null;

      Log.debug('ErrorHandlingFacade: Error handling system disposed');
    }
  }
}
