/// Crash Report Entity
///
/// PATTERN: Builder Pattern - Complex crash report construction
/// WHERE: Core Firebase entities - Crash report structure
/// HOW: Builder pattern for constructing detailed crash reports
/// WHY: Comprehensive crash information for Tower Defense debugging
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Crash Report Entity
///
/// Tower Defense Context: Represents crash and error information
/// for educational game stability and debugging
class CrashReport extends Equatable {
  const CrashReport({
    required this.exception,
    required this.stackTrace,
    required this.timestamp,
    required this.severity,
    required this.category,
    this.reason,
    this.context = const {},
    this.userActions = const [],
    this.deviceInfo = const {},
    this.appState = const {},
  });

  final dynamic exception;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final CrashSeverity severity;
  final CrashCategory category;
  final String? reason;
  final Map<String, dynamic> context;
  final List<String> userActions;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> appState;

  /// Factory: Create from Flutter error
  factory CrashReport.fromFlutterError(FlutterErrorDetails details) {
    return CrashReport(
      exception: details.exception,
      stackTrace: details.stack,
      timestamp: DateTime.now(),
      severity: _determineSeverityFromError(details.exception),
      category: _categorizePlatformError(details.exception),
      reason: details.context?.toString(),
      context: {
        'error_type': 'flutter_error',
        'library': details.library ?? 'unknown',
        'information_collector': details.informationCollector != null,
        'platform_error': true,
      },
    );
  }

  /// Factory: Create from Dart isolate error
  factory CrashReport.fromIsolateError(dynamic error, dynamic stackTrace) {
    return CrashReport(
      exception: error,
      stackTrace: stackTrace is StackTrace ? stackTrace : null,
      timestamp: DateTime.now(),
      severity: CrashSeverity.critical,
      category: CrashCategory.runtime,
      reason: 'Isolate error occurred',
      context: {'error_type': 'isolate_error', 'platform_error': true},
    );
  }

  /// Factory: Create custom error report
  factory CrashReport.custom({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
    Map<String, dynamic> context = const {},
  }) {
    return CrashReport(
      exception: exception,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      severity: fatal
          ? CrashSeverity.critical
          : _determineSeverityFromException(exception),
      category: _categorizeCustomError(exception, context),
      reason: reason,
      context: {'error_type': 'custom_error', 'fatal': fatal, ...context},
    );
  }

  /// Factory: Tower Defense specific - Pattern learning error
  factory CrashReport.patternLearningError({
    required String patternName,
    required dynamic exception,
    StackTrace? stackTrace,
    String? learningPhase,
  }) {
    return CrashReport(
      exception: exception,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      severity: CrashSeverity.moderate,
      category: CrashCategory.educational,
      reason: 'Error during pattern learning: $patternName',
      context: {
        'pattern_name': patternName,
        'learning_phase': learningPhase ?? 'unknown',
        'educational_error': true,
        'error_type': 'pattern_learning',
      },
    );
  }

  /// Factory: Tower Defense specific - Game logic error
  factory CrashReport.gameLogicError({
    required String operation,
    required dynamic exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? gameState,
  }) {
    return CrashReport(
      exception: exception,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      severity: CrashSeverity.high,
      category: CrashCategory.gameLogic,
      reason: 'Game logic error: $operation',
      context: {
        'operation': operation,
        'game_logic_error': true,
        'error_type': 'game_logic',
      },
      appState: gameState ?? {},
    );
  }

  /// Factory: UI rendering error
  factory CrashReport.uiRenderingError({
    required String widget,
    required dynamic exception,
    StackTrace? stackTrace,
    String? userAction,
  }) {
    return CrashReport(
      exception: exception,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      severity: CrashSeverity.moderate,
      category: CrashCategory.ui,
      reason: 'UI rendering error in: $widget',
      context: {
        'widget_name': widget,
        'user_action': userAction ?? 'unknown',
        'ui_error': true,
        'error_type': 'ui_rendering',
      },
      userActions: userAction != null ? [userAction] : [],
    );
  }

  /// Factory: Network error
  factory CrashReport.networkError({
    required String endpoint,
    required dynamic exception,
    StackTrace? stackTrace,
    int? statusCode,
    String? method,
  }) {
    return CrashReport(
      exception: exception,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      severity: CrashSeverity.low,
      category: CrashCategory.network,
      reason: 'Network error: $endpoint',
      context: {
        'endpoint': endpoint,
        'status_code': statusCode ?? 0,
        'method': method ?? 'unknown',
        'network_error': true,
        'error_type': 'network',
      },
    );
  }

  /// Determine severity from exception type
  static CrashSeverity _determineSeverityFromException(dynamic exception) {
    if (exception is OutOfMemoryError) return CrashSeverity.critical;
    if (exception is StackOverflowError) return CrashSeverity.critical;
    if (exception is AssertionError) return CrashSeverity.high;
    if (exception is ArgumentError) return CrashSeverity.moderate;
    if (exception is StateError) return CrashSeverity.moderate;
    if (exception is FormatException) return CrashSeverity.low;
    return CrashSeverity.moderate;
  }

  /// Determine severity from Flutter error
  static CrashSeverity _determineSeverityFromError(dynamic exception) {
    final exceptionStr = exception.toString().toLowerCase();

    if (exceptionStr.contains('overflow') || exceptionStr.contains('memory')) {
      return CrashSeverity.critical;
    }
    if (exceptionStr.contains('assertion') ||
        exceptionStr.contains('null check')) {
      return CrashSeverity.high;
    }
    if (exceptionStr.contains('render') || exceptionStr.contains('widget')) {
      return CrashSeverity.moderate;
    }

    return CrashSeverity.moderate;
  }

  /// Categorize platform error
  static CrashCategory _categorizePlatformError(dynamic exception) {
    final exceptionStr = exception.toString().toLowerCase();

    if (exceptionStr.contains('render') || exceptionStr.contains('widget')) {
      return CrashCategory.ui;
    }
    if (exceptionStr.contains('http') || exceptionStr.contains('socket')) {
      return CrashCategory.network;
    }
    if (exceptionStr.contains('database') || exceptionStr.contains('storage')) {
      return CrashCategory.storage;
    }

    return CrashCategory.runtime;
  }

  /// Categorize custom error
  static CrashCategory _categorizeCustomError(
    dynamic exception,
    Map<String, dynamic> context,
  ) {
    if (context.containsKey('educational_error') &&
        context['educational_error'] == true) {
      return CrashCategory.educational;
    }
    if (context.containsKey('game_logic_error') &&
        context['game_logic_error'] == true) {
      return CrashCategory.gameLogic;
    }
    if (context.containsKey('ui_error') && context['ui_error'] == true) {
      return CrashCategory.ui;
    }
    if (context.containsKey('network_error') &&
        context['network_error'] == true) {
      return CrashCategory.network;
    }

    return _categorizePlatformError(exception);
  }

  /// Convert to Firebase Crashlytics format
  Map<String, dynamic> toCrashlyticsMap() {
    return {
      'exception_type': exception.runtimeType.toString(),
      'exception_message': exception.toString(),
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
      'category': category.name,
      'reason': reason,
      'has_stack_trace': stackTrace != null,
      'user_actions_count': userActions.length,
      'context_keys': context.keys.toList(),
      ...context,
    };
  }

  /// Get short description
  String get shortDescription {
    final exceptionName = exception.runtimeType.toString();
    final categoryName = category.displayName;
    return '$categoryName: $exceptionName';
  }

  /// Get detailed description
  String get detailedDescription {
    final buffer = StringBuffer();
    buffer.writeln('Crash Report - ${severity.displayName}');
    buffer.writeln('Category: ${category.displayName}');
    buffer.writeln('Time: ${timestamp.toLocal()}');
    buffer.writeln(
      'Exception: ${exception.runtimeType} - ${exception.toString()}',
    );

    if (reason != null) {
      buffer.writeln('Reason: $reason');
    }

    if (context.isNotEmpty) {
      buffer.writeln('Context: $context');
    }

    if (userActions.isNotEmpty) {
      buffer.writeln('User Actions: ${userActions.join(', ')}');
    }

    return buffer.toString();
  }

  /// Check if this is a critical crash that needs immediate attention
  bool get isCritical {
    return severity == CrashSeverity.critical ||
        (category == CrashCategory.gameLogic &&
            severity == CrashSeverity.high) ||
        (category == CrashCategory.educational &&
            severity == CrashSeverity.high);
  }

  /// Check if this is related to educational content
  bool get isEducationalError {
    return category == CrashCategory.educational ||
        context.containsKey('educational_error') ||
        context.containsKey('pattern_name') ||
        context.containsKey('learning_phase');
  }

  /// Add user action to the report
  CrashReport addUserAction(String action) {
    return CrashReport(
      exception: exception,
      stackTrace: stackTrace,
      timestamp: timestamp,
      severity: severity,
      category: category,
      reason: reason,
      context: context,
      userActions: [...userActions, action],
      deviceInfo: deviceInfo,
      appState: appState,
    );
  }

  /// Add context information
  CrashReport addContext(Map<String, dynamic> additionalContext) {
    return CrashReport(
      exception: exception,
      stackTrace: stackTrace,
      timestamp: timestamp,
      severity: severity,
      category: category,
      reason: reason,
      context: {...context, ...additionalContext},
      userActions: userActions,
      deviceInfo: deviceInfo,
      appState: appState,
    );
  }

  @override
  List<Object?> get props => [
    exception,
    stackTrace,
    timestamp,
    severity,
    category,
    reason,
    context,
    userActions,
    deviceInfo,
    appState,
  ];

  @override
  String toString() {
    return 'CrashReport(${severity.name} ${category.name}: ${exception.runtimeType})';
  }
}

/// Crash severity levels
enum CrashSeverity {
  low('Low', 1),
  moderate('Moderate', 2),
  high('High', 3),
  critical('Critical', 4);

  const CrashSeverity(this.displayName, this.level);

  final String displayName;
  final int level;
}

/// Crash categories for Tower Defense educational app
enum CrashCategory {
  educational('Educational Content', '📚'),
  gameLogic('Game Logic', '🎮'),
  ui('User Interface', '🖼️'),
  network('Network', '🌐'),
  storage('Storage', '💾'),
  runtime('Runtime', '⚙️'),
  security('Security', '🔒'),
  performance('Performance', '📈');

  const CrashCategory(this.displayName, this.icon);

  final String displayName;
  final String icon;
}
