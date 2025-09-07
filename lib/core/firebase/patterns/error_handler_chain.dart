/// Error Handler Chain of Responsibility Pattern
///
/// PATTERN: Chain of Responsibility - Error handling chain
/// WHERE: Core Firebase patterns - Chain implementation for error handling
/// HOW: Chain of handlers processes different types of errors appropriately
/// WHY: Flexible error handling based on error type and context for Tower Defense
library;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../logging/logging.dart';
import '../entities/crash_report.dart';

/// Abstract Error Handler
abstract class ErrorHandler {
  ErrorHandler? _nextHandler;

  /// Set the next handler in the chain
  ErrorHandler setNext(ErrorHandler handler) {
    _nextHandler = handler;
    return handler;
  }

  /// Handle the error or pass it to the next handler
  Future<void> handle(CrashReport crashReport) async {
    if (await canHandle(crashReport)) {
      await handleError(crashReport);
    } else if (_nextHandler != null) {
      await _nextHandler!.handle(crashReport);
    } else {
      await _handleUnknownError(crashReport);
    }
  }

  /// Check if this handler can handle the error
  Future<bool> canHandle(CrashReport crashReport);

  /// Handle the specific error type
  Future<void> handleError(CrashReport crashReport);

  /// Default handler for unknown errors
  Future<void> _handleUnknownError(CrashReport crashReport) async {
    Log.warning(
      'Unknown error type, using default handler: ${crashReport.shortDescription}',
    );
    await _reportToCrashlytics(crashReport);
  }

  /// Report to Firebase Crashlytics
  Future<void> _reportToCrashlytics(CrashReport crashReport) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        crashReport.exception,
        crashReport.stackTrace,
        reason: crashReport.reason,
        fatal: crashReport.severity == CrashSeverity.critical,
        information: [crashReport.toCrashlyticsMap()],
      );
    } catch (e) {
      Log.error('Failed to report to Crashlytics: $e');
    }
  }
}

/// Critical Error Handler
/// Tower Defense Context: Handles critical errors that require immediate attention
class CriticalErrorHandler extends ErrorHandler {
  CriticalErrorHandler(this.crashlytics);

  final FirebaseCrashlytics crashlytics;

  @override
  Future<bool> canHandle(CrashReport crashReport) async {
    return crashReport.severity == CrashSeverity.critical;
  }

  @override
  Future<void> handleError(CrashReport crashReport) async {
    Log.error('🚨 CRITICAL ERROR: ${crashReport.shortDescription}');

    // Set critical error custom keys
    await crashlytics.setCustomKey('error_severity', 'critical');
    await crashlytics.setCustomKey('immediate_attention', true);
    await crashlytics.setCustomKey(
      'error_timestamp',
      crashReport.timestamp.toIso8601String(),
    );

    // Log detailed information
    await crashlytics.log(
      'CRITICAL ERROR DETAILS: ${crashReport.detailedDescription}',
    );

    // Record the error as fatal
    await crashlytics.recordError(
      crashReport.exception,
      crashReport.stackTrace,
      reason: 'CRITICAL: ${crashReport.reason}',
      fatal: true,
      information: [
        crashReport.toCrashlyticsMap(),
        {'handler': 'CriticalErrorHandler'},
        {'urgency': 'immediate'},
      ],
    );

    // Force send report immediately
    await crashlytics.sendUnsentReports();

    Log.error('Critical error reported and sent immediately');
  }
}

/// Game Logic Error Handler
/// Tower Defense Context: Handles errors specific to game mechanics
class GameLogicErrorHandler extends ErrorHandler {
  GameLogicErrorHandler(this.crashlytics);

  final FirebaseCrashlytics crashlytics;

  @override
  Future<bool> canHandle(CrashReport crashReport) async {
    return crashReport.category == CrashCategory.gameLogic;
  }

  @override
  Future<void> handleError(CrashReport crashReport) async {
    Log.warning('🎮 GAME LOGIC ERROR: ${crashReport.shortDescription}');

    // Set game-specific custom keys
    await crashlytics.setCustomKey('error_category', 'game_logic');
    await crashlytics.setCustomKey(
      'game_operation',
      crashReport.context['operation'] ?? 'unknown',
    );
    await crashlytics.setCustomKey('affects_gameplay', true);

    // Extract game state if available
    if (crashReport.appState.isNotEmpty) {
      await crashlytics.setCustomKey('game_state_available', true);
      for (final entry in crashReport.appState.entries.take(5)) {
        // Limit to 5 entries
        await crashlytics.setCustomKey(
          'game_${entry.key}',
          entry.value.toString(),
        );
      }
    }

    // Log game context
    await crashlytics.log(
      'GAME LOGIC ERROR: Operation=${crashReport.context['operation']}, State=${crashReport.appState}',
    );

    // Record with game-specific context
    await crashlytics.recordError(
      crashReport.exception,
      crashReport.stackTrace,
      reason: 'GAME LOGIC: ${crashReport.reason}',
      fatal: crashReport.severity == CrashSeverity.critical,
      information: [
        crashReport.toCrashlyticsMap(),
        {'handler': 'GameLogicErrorHandler'},
        {'category': 'game_mechanics'},
        {'debug_priority': 'high'},
      ],
    );

    Log.info('Game logic error reported with full context');
  }
}

/// UI Error Handler
/// Tower Defense Context: Handles UI rendering and interaction errors
class UIErrorHandler extends ErrorHandler {
  UIErrorHandler(this.crashlytics);

  final FirebaseCrashlytics crashlytics;

  @override
  Future<bool> canHandle(CrashReport crashReport) async {
    return crashReport.category == CrashCategory.ui;
  }

  @override
  Future<void> handleError(CrashReport crashReport) async {
    Log.warning('🖼️ UI ERROR: ${crashReport.shortDescription}');

    // Set UI-specific custom keys
    await crashlytics.setCustomKey('error_category', 'ui_rendering');
    await crashlytics.setCustomKey(
      'widget_name',
      crashReport.context['widget_name'] ?? 'unknown',
    );
    await crashlytics.setCustomKey(
      'user_action',
      crashReport.context['user_action'] ?? 'none',
    );

    // Track user actions if available
    if (crashReport.userActions.isNotEmpty) {
      await crashlytics.setCustomKey(
        'user_actions_count',
        crashReport.userActions.length,
      );
      await crashlytics.setCustomKey(
        'last_user_action',
        crashReport.userActions.last,
      );
    }

    // Log UI context
    await crashlytics.log(
      'UI ERROR: Widget=${crashReport.context['widget_name']}, Action=${crashReport.context['user_action']}',
    );

    // Record with UI-specific context
    await crashlytics.recordError(
      crashReport.exception,
      crashReport.stackTrace,
      reason: 'UI ERROR: ${crashReport.reason}',
      fatal: false, // UI errors are typically not fatal
      information: [
        crashReport.toCrashlyticsMap(),
        {'handler': 'UIErrorHandler'},
        {'category': 'ui_interaction'},
        {'affects_user_experience': true},
      ],
    );

    Log.info('UI error reported with interaction context');
  }
}

/// Network Error Handler
/// Tower Defense Context: Handles network and connectivity errors
class NetworkErrorHandler extends ErrorHandler {
  NetworkErrorHandler(this.crashlytics);

  final FirebaseCrashlytics crashlytics;

  @override
  Future<bool> canHandle(CrashReport crashReport) async {
    return crashReport.category == CrashCategory.network;
  }

  @override
  Future<void> handleError(CrashReport crashReport) async {
    Log.warning('🌐 NETWORK ERROR: ${crashReport.shortDescription}');

    // Set network-specific custom keys
    await crashlytics.setCustomKey('error_category', 'network');
    await crashlytics.setCustomKey(
      'endpoint',
      crashReport.context['endpoint'] ?? 'unknown',
    );
    await crashlytics.setCustomKey(
      'status_code',
      crashReport.context['status_code'] ?? 0,
    );
    await crashlytics.setCustomKey(
      'method',
      crashReport.context['method'] ?? 'unknown',
    );

    // Determine if it's a connectivity issue
    final statusCode = crashReport.context['status_code'] as int? ?? 0;
    final isConnectivityIssue = statusCode == 0 || statusCode >= 500;
    await crashlytics.setCustomKey('connectivity_issue', isConnectivityIssue);

    // Log network context
    await crashlytics.log(
      'NETWORK ERROR: ${crashReport.context['endpoint']} [${crashReport.context['status_code']}]',
    );

    // Record with network-specific context
    await crashlytics.recordError(
      crashReport.exception,
      crashReport.stackTrace,
      reason: 'NETWORK: ${crashReport.reason}',
      fatal: false, // Network errors are typically not fatal
      information: [
        crashReport.toCrashlyticsMap(),
        {'handler': 'NetworkErrorHandler'},
        {'category': 'connectivity'},
        {'retry_recommended': isConnectivityIssue},
      ],
    );

    Log.info('Network error reported with connectivity context');
  }
}

/// Educational Content Error Handler
/// Tower Defense Context: Handles errors specific to educational content
class EducationalContentErrorHandler extends ErrorHandler {
  EducationalContentErrorHandler(this.crashlytics);

  final FirebaseCrashlytics crashlytics;

  @override
  Future<bool> canHandle(CrashReport crashReport) async {
    return crashReport.category == CrashCategory.educational ||
        crashReport.isEducationalError;
  }

  @override
  Future<void> handleError(CrashReport crashReport) async {
    Log.warning(
      '📚 EDUCATIONAL CONTENT ERROR: ${crashReport.shortDescription}',
    );

    // Set educational-specific custom keys
    await crashlytics.setCustomKey('error_category', 'educational');
    await crashlytics.setCustomKey(
      'pattern_name',
      crashReport.context['pattern_name'] ?? 'unknown',
    );
    await crashlytics.setCustomKey(
      'learning_phase',
      crashReport.context['learning_phase'] ?? 'unknown',
    );
    await crashlytics.setCustomKey('affects_learning', true);

    // Track educational context
    if (crashReport.context.containsKey('pattern_category')) {
      await crashlytics.setCustomKey(
        'pattern_category',
        crashReport.context['pattern_category'],
      );
    }

    // Log educational context
    await crashlytics.log(
      'EDUCATIONAL ERROR: Pattern=${crashReport.context['pattern_name']}, Phase=${crashReport.context['learning_phase']}',
    );

    // Record with educational-specific context
    await crashlytics.recordError(
      crashReport.exception,
      crashReport.stackTrace,
      reason: 'EDUCATIONAL: ${crashReport.reason}',
      fatal: false, // Educational errors shouldn't be fatal
      information: [
        crashReport.toCrashlyticsMap(),
        {'handler': 'EducationalContentErrorHandler'},
        {'category': 'learning_experience'},
        {'educational_impact': 'high'},
      ],
    );

    Log.info('Educational content error reported with learning context');
  }
}

/// General Error Handler (Default/Fallback)
/// Tower Defense Context: Handles any errors not caught by specific handlers
class GeneralErrorHandler extends ErrorHandler {
  GeneralErrorHandler(this.crashlytics);

  final FirebaseCrashlytics crashlytics;

  @override
  Future<bool> canHandle(CrashReport crashReport) async {
    return true; // This handler accepts any error as the fallback
  }

  @override
  Future<void> handleError(CrashReport crashReport) async {
    Log.info('⚙️ GENERAL ERROR: ${crashReport.shortDescription}');

    // Set general custom keys
    await crashlytics.setCustomKey('error_category', 'general');
    await crashlytics.setCustomKey('handler_type', 'fallback');
    await crashlytics.setCustomKey('needs_categorization', true);

    // Log general context
    await crashlytics.log(
      'GENERAL ERROR: ${crashReport.reason} [${crashReport.category.displayName}]',
    );

    // Record with general context
    await crashlytics.recordError(
      crashReport.exception,
      crashReport.stackTrace,
      reason: 'GENERAL: ${crashReport.reason}',
      fatal: crashReport.severity == CrashSeverity.critical,
      information: [
        crashReport.toCrashlyticsMap(),
        {'handler': 'GeneralErrorHandler'},
        {'category': 'uncategorized'},
        {'needs_review': true},
      ],
    );

    Log.info('General error reported for further categorization');
  }
}

/// Error Handler Chain
/// Tower Defense Context: Main chain coordinator for error processing
class ErrorHandlerChain {
  ErrorHandler? _firstHandler;

  /// Add a handler to the chain
  ErrorHandlerChain addHandler(ErrorHandler handler) {
    if (_firstHandler == null) {
      _firstHandler = handler;
    } else {
      _firstHandler!.setNext(handler);
    }
    return this;
  }

  /// Process an error through the chain
  Future<void> handleError(CrashReport crashReport) async {
    if (_firstHandler != null) {
      await _firstHandler!.handle(crashReport);
    } else {
      Log.error('No error handlers configured!');
    }
  }

  /// Dispose the chain
  void dispose() {
    _firstHandler = null;
  }
}

/// Error Handler Chain Factory
/// Tower Defense Context: Factory for creating preconfigured error chains
class ErrorHandlerChainFactory {
  /// Create a complete Tower Defense error handling chain
  static ErrorHandlerChain createTowerDefenseChain(
    FirebaseCrashlytics crashlytics,
  ) {
    return ErrorHandlerChain()
        .addHandler(CriticalErrorHandler(crashlytics))
        .addHandler(GameLogicErrorHandler(crashlytics))
        .addHandler(EducationalContentErrorHandler(crashlytics))
        .addHandler(UIErrorHandler(crashlytics))
        .addHandler(NetworkErrorHandler(crashlytics))
        .addHandler(GeneralErrorHandler(crashlytics));
  }

  /// Create a minimal error handling chain
  static ErrorHandlerChain createMinimalChain(FirebaseCrashlytics crashlytics) {
    return ErrorHandlerChain()
        .addHandler(CriticalErrorHandler(crashlytics))
        .addHandler(GeneralErrorHandler(crashlytics));
  }

  /// Create a development error handling chain (with extra logging)
  static ErrorHandlerChain createDevelopmentChain(
    FirebaseCrashlytics crashlytics,
  ) {
    return ErrorHandlerChain()
        .addHandler(CriticalErrorHandler(crashlytics))
        .addHandler(GameLogicErrorHandler(crashlytics))
        .addHandler(EducationalContentErrorHandler(crashlytics))
        .addHandler(UIErrorHandler(crashlytics))
        .addHandler(NetworkErrorHandler(crashlytics))
        .addHandler(GeneralErrorHandler(crashlytics));
  }
}
