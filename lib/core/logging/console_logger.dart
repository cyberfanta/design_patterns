/// Console logging system implementing multiple design patterns
///
/// PATTERN: Singleton + Strategy + Command + Observer
/// WHERE: Used throughout the app to replace print statements
/// HOW: Single instance with different logging strategies and commands
/// WHY: Centralized logging, eliminates warnings, supports multiple output types
library;

import 'package:flutter/foundation.dart';

/// PATTERN: Strategy - Different logging strategies
/// WHERE: Defines contract for different output methods
/// HOW: Abstract class with execute method
/// WHY: Allows switching between console, file, network logging
abstract class LoggingStrategy {
  void execute(String message, LogLevel level);
}

/// PATTERN: Command - Encapsulates logging operations
/// WHERE: Wraps logging commands for execution
/// HOW: Contains strategy, message, and level
/// WHY: Allows queuing, batching, and replaying log commands
class LogCommand {
  final LoggingStrategy strategy;
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  LogCommand({
    required this.strategy,
    required this.message,
    required this.level,
  }) : timestamp = DateTime.now();

  void execute() => strategy.execute(message, level);
}

/// PATTERN: Observer - Notifies about logging events
/// WHERE: Interface for log event listeners
/// HOW: Abstract method to handle log events
/// WHY: Allows multiple components to react to logging events
abstract class LogObserver {
  void onLogEvent(String message, LogLevel level, DateTime timestamp);
}

/// Log levels for different types of messages
enum LogLevel {
  debug('🐛', 'DEBUG'),
  info('ℹ️', 'INFO'),
  warning('⚠️', 'WARNING'),
  error('❌', 'ERROR'),
  success('✅', 'SUCCESS');

  const LogLevel(this.icon, this.name);

  final String icon;
  final String name;
}

/// PATTERN: Strategy Implementation - Console output strategy
/// WHERE: Concrete implementation for console output
/// HOW: Uses debugPrint and kDebugMode to avoid warnings
/// WHY: Safe console output that respects Flutter's debug mode
class ConsoleLoggingStrategy implements LoggingStrategy {
  @override
  void execute(String message, LogLevel level) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      final formattedMessage =
          '[$timestamp] ${level.icon} ${level.name}: $message';
      debugPrint(formattedMessage);
    }
  }
}

/// PATTERN: Strategy Implementation - Silent strategy for production
/// WHERE: Used in release builds to suppress all output
/// HOW: Empty execute method
/// WHY: Complete silence in production builds
class SilentLoggingStrategy implements LoggingStrategy {
  @override
  void execute(String message, LogLevel level) {
    // Silent - no output in production
  }
}

/// PATTERN: Singleton + Observer + Command - Main console logger
/// WHERE: Global logging system used throughout the app
/// HOW: Single instance with multiple strategies and observer pattern
/// WHY: Centralized, configurable logging with event notification
class ConsoleLogger {
  static ConsoleLogger? _instance;

  // PATTERN: Singleton - Private constructor and instance control
  ConsoleLogger._internal() {
    _strategy = kDebugMode ? ConsoleLoggingStrategy() : SilentLoggingStrategy();
  }

  /// PATTERN: Singleton - Factory constructor returns single instance
  factory ConsoleLogger() {
    return _instance ??= ConsoleLogger._internal();
  }

  /// Get singleton instance
  static ConsoleLogger get instance => ConsoleLogger();

  // PATTERN: Strategy - Current logging strategy
  late LoggingStrategy _strategy;

  // PATTERN: Observer - List of observers
  final List<LogObserver> _observers = [];

  // PATTERN: Command - Command history for debugging
  final List<LogCommand> _commandHistory = [];
  static const int _maxHistorySize = 100;

  /// PATTERN: Strategy - Change logging strategy at runtime
  /// WHERE: Used to switch between console, file, or network logging
  /// HOW: Accepts any LoggingStrategy implementation
  /// WHY: Flexible logging output configuration
  void setStrategy(LoggingStrategy strategy) {
    _strategy = strategy;
  }

  /// PATTERN: Observer - Add log event observer
  /// WHERE: Used by components that need to react to log events
  /// HOW: Adds observer to internal list
  /// WHY: Allows multiple listeners for log events
  void addObserver(LogObserver observer) {
    _observers.add(observer);
  }

  /// PATTERN: Observer - Remove log event observer
  void removeObserver(LogObserver observer) {
    _observers.remove(observer);
  }

  /// PATTERN: Observer - Notify all observers of log events
  void _notifyObservers(String message, LogLevel level, DateTime timestamp) {
    for (final observer in _observers) {
      observer.onLogEvent(message, level, timestamp);
    }
  }

  /// PATTERN: Command - Execute logging command
  /// WHERE: Core logging method that executes commands
  /// HOW: Creates command, executes it, stores in history, notifies observers
  /// WHY: Encapsulates logging operation with full traceability
  void _executeLogCommand(String message, LogLevel level) {
    final command = LogCommand(
      strategy: _strategy,
      message: message,
      level: level,
    );

    // Execute the command
    command.execute();

    // Store in history (with size limit)
    _commandHistory.add(command);
    if (_commandHistory.length > _maxHistorySize) {
      _commandHistory.removeAt(0);
    }

    // Notify observers
    _notifyObservers(message, level, command.timestamp);
  }

  /// Log debug message - Replace print() calls with this
  /// Usage: ConsoleLogger.instance.debug('Debug message');
  void debug(String message) {
    _executeLogCommand(message, LogLevel.debug);
  }

  /// Log info message - For general information
  /// Usage: ConsoleLogger.instance.info('Info message');
  void info(String message) {
    _executeLogCommand(message, LogLevel.info);
  }

  /// Log warning message - For warnings
  /// Usage: ConsoleLogger.instance.warning('Warning message');
  void warning(String message) {
    _executeLogCommand(message, LogLevel.warning);
  }

  /// Log error message - For errors
  /// Usage: ConsoleLogger.instance.error('Error message');
  void error(String message) {
    _executeLogCommand(message, LogLevel.error);
  }

  /// Log success message - For successful operations
  /// Usage: ConsoleLogger.instance.success('Success message');
  void success(String message) {
    _executeLogCommand(message, LogLevel.success);
  }

  /// Convenience method for pattern demos
  /// Usage: ConsoleLogger.instance.patternDemo('Pattern Name', 'Demo description');
  void patternDemo(String patternName, String description) {
    final separator = '=' * 50;
    debug('\n$separator');
    info('Running $patternName Demo');
    debug(separator);
    info(description);
  }

  /// Get command history (for debugging)
  List<LogCommand> get commandHistory => List.unmodifiable(_commandHistory);

  /// Clear command history
  void clearHistory() {
    _commandHistory.clear();
  }
}

/// PATTERN: Facade - Simplified interface for common operations
/// WHERE: Global functions for easy access to logging
/// HOW: Static methods that delegate to ConsoleLogger instance
/// WHY: Even simpler usage without accessing instance explicitly
class Log {
  static final ConsoleLogger _logger = ConsoleLogger.instance;

  static void debug(String message) => _logger.debug(message);

  static void info(String message) => _logger.info(message);

  static void warning(String message) => _logger.warning(message);

  static void error(String message) => _logger.error(message);

  static void success(String message) => _logger.success(message);

  static void patternDemo(String patternName, String description) =>
      _logger.patternDemo(patternName, description);
}
