/// Input Cleaning Commands - Security Domain Layer
///
/// PATTERN: Command Pattern - Encapsulated input cleaning operations
/// WHERE: Domain layer for input sanitization commands
/// HOW: Commands encapsulate different cleaning algorithms with undo support
/// WHY: Provides flexible, composable, and reversible input cleaning operations
library;

import 'package:design_patterns/core/logging/logging.dart';

/// Abstract base class for input cleaning commands
///
/// PATTERN: Command Pattern - Command interface
///
/// Defines the contract for input cleaning operations in the Tower Defense app.
/// Each command represents a specific cleaning strategy that can be executed,
/// undone, and combined with other commands.
abstract class InputCleaningCommand {
  /// Command name for logging and debugging
  String get name;

  /// Execute the cleaning command
  InputCleaningResult execute(String input);

  /// Undo the cleaning operation (if possible)
  String? undo(InputCleaningResult result);

  /// Check if this command can be undone
  bool get canUndo;

  /// Get command metadata
  Map<String, dynamic> get metadata => {'name': name, 'can_undo': canUndo};
}

/// HTML/Script cleaning command
///
/// PATTERN: Command Pattern - Concrete command for HTML sanitization
///
/// Removes potentially dangerous HTML, JavaScript, and other script content
/// from user input to prevent XSS attacks in the Tower Defense application.
class HtmlCleaningCommand implements InputCleaningCommand {
  @override
  String get name => 'html_cleaning';

  @override
  bool get canUndo => true;

  @override
  Map<String, dynamic> get metadata => {
    'name': name,
    'can_undo': canUndo,
    'type': 'html_cleaning',
    'dangerous_patterns_count': 10, // Total dangerous patterns
  };

  // Patterns to remove
  static final List<RegExp> _dangerousPatterns = [
    RegExp(
      r'<script[^>]*>.*?</script>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    ),
    RegExp(
      r'<iframe[^>]*>.*?</iframe>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    ),
    RegExp(
      r'<object[^>]*>.*?</object>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    ),
    RegExp(r'<embed[^>]*/?>', caseSensitive: false),
    RegExp(
      r'<applet[^>]*>.*?</applet>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    ),
    RegExp(
      r'<form[^>]*>.*?</form>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    ),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'vbscript:', caseSensitive: false),
    RegExp(r'data:text/html', caseSensitive: false),
    RegExp(r'on\w+\s*=', caseSensitive: false), // Event handlers
  ];

  // Safe HTML tags to preserve (basic formatting)
  static final RegExp _safeTags = RegExp(
    r'<(/?)(?:b|i|u|strong|em|br|p|div|span|h[1-6]|ul|ol|li|blockquote)(\s[^>]*?)?>',
    caseSensitive: false,
  );

  @override
  InputCleaningResult execute(String input) {
    Log.debug(
      'HtmlCleaningCommand: Executing on input of length ${input.length}',
    );

    final stopwatch = Stopwatch()..start();
    final removedContent = <String>[];
    String cleaned = input;

    // Remove dangerous patterns
    for (final pattern in _dangerousPatterns) {
      final matches = pattern
          .allMatches(cleaned)
          .map((m) => m.group(0)!)
          .toList();
      removedContent.addAll(matches);
      cleaned = cleaned.replaceAll(pattern, '');
    }

    // Remove all HTML tags except safe ones
    final htmlTags = RegExp(r'<[^>]+>');
    final unsafeTags = <String>[];

    for (final match in htmlTags.allMatches(cleaned)) {
      final tag = match.group(0)!;
      if (!_safeTags.hasMatch(tag)) {
        unsafeTags.add(tag);
      }
    }

    for (final unsafeTag in unsafeTags) {
      cleaned = cleaned.replaceAll(unsafeTag, '');
    }

    // Decode HTML entities
    cleaned = _decodeHtmlEntities(cleaned);

    // Normalize whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    stopwatch.stop();

    final result = InputCleaningResult(
      command: this,
      originalInput: input,
      cleanedInput: cleaned,
      removedContent: removedContent + unsafeTags,
      processingTimeMs: stopwatch.elapsedMilliseconds,
      metadata: {
        'dangerous_patterns_found': removedContent.length,
        'unsafe_tags_found': unsafeTags.length,
        'size_reduction': input.length - cleaned.length,
      },
    );

    Log.info(
      'HtmlCleaningCommand: Removed ${result.removedContent.length} dangerous elements',
    );
    return result;
  }

  @override
  String? undo(InputCleaningResult result) {
    // For HTML cleaning, we can't perfectly restore, but we can return original
    Log.debug('HtmlCleaningCommand: Undoing cleaning operation');
    return result.originalInput;
  }

  String _decodeHtmlEntities(String input) {
    return input
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/')
        .replaceAll('&#39;', "'");
  }
}

/// SQL injection cleaning command
///
/// PATTERN: Command Pattern - Concrete command for SQL sanitization
///
/// Removes or escapes potential SQL injection patterns from user input
/// to protect database queries in the Tower Defense application.
class SqlInjectionCleaningCommand implements InputCleaningCommand {
  @override
  String get name => 'sql_injection_cleaning';

  @override
  bool get canUndo => true;

  @override
  Map<String, dynamic> get metadata => {
    'name': name,
    'can_undo': canUndo,
    'type': 'sql_injection_cleaning',
    'sql_patterns_count': 6, // Total SQL patterns
  };

  // Common SQL injection patterns
  static final List<RegExp> _sqlPatterns = [
    RegExp(
      r'\b(union|select|insert|update|delete|drop|create|alter|exec|execute)\b',
      caseSensitive: false,
    ),
    RegExp(r'(--)', caseSensitive: false), // SQL comments
    RegExp(r';', caseSensitive: false), // Semicolon
    RegExp(r'or\s+1\s*=\s*1', caseSensitive: false), // 1=1 patterns
    RegExp(r'and\s+1\s*=\s*1', caseSensitive: false), // 1=1 patterns
    RegExp(r'0x[0-9a-f]+', caseSensitive: false), // Hex values
  ];

  @override
  InputCleaningResult execute(String input) {
    Log.debug(
      'SqlInjectionCleaningCommand: Executing on input of length ${input.length}',
    );

    final stopwatch = Stopwatch()..start();
    final removedContent = <String>[];
    String cleaned = input;

    // Remove or escape SQL injection patterns
    for (final pattern in _sqlPatterns) {
      final matches = pattern
          .allMatches(cleaned)
          .map((m) => m.group(0)!)
          .toList();
      removedContent.addAll(matches);

      // Replace with safe alternatives or remove entirely
      cleaned = cleaned.replaceAllMapped(pattern, (match) {
        final matchText = match.group(0)!;

        // For SQL keywords, replace with safe alternatives
        final lowerMatch = matchText.toLowerCase();
        if (lowerMatch.contains('union') ||
            lowerMatch.contains('select') ||
            lowerMatch.contains('insert') ||
            lowerMatch.contains('update') ||
            lowerMatch.contains('delete') ||
            lowerMatch.contains('drop')) {
          return '[SQL_KEYWORD_REMOVED]';
        }

        // For operators and comments, remove entirely
        return '';
      });
    }

    // Escape single quotes (basic protection)
    cleaned = cleaned.replaceAll("'", "''");

    // Remove excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    stopwatch.stop();

    final result = InputCleaningResult(
      command: this,
      originalInput: input,
      cleanedInput: cleaned,
      removedContent: removedContent,
      processingTimeMs: stopwatch.elapsedMilliseconds,
      metadata: {
        'sql_patterns_found': removedContent.length,
        'size_reduction': input.length - cleaned.length,
        'quotes_escaped': cleaned.split("''").length - 1,
      },
    );

    Log.info(
      'SqlInjectionCleaningCommand: Removed ${result.removedContent.length} SQL injection patterns',
    );
    return result;
  }

  @override
  String? undo(InputCleaningResult result) {
    Log.debug('SqlInjectionCleaningCommand: Undoing cleaning operation');
    return result.originalInput;
  }
}

/// Whitespace normalization command
///
/// PATTERN: Command Pattern - Concrete command for whitespace cleanup
///
/// Normalizes and cleans up whitespace in user input while preserving
/// readability for the Tower Defense application.
class WhitespaceCleaningCommand implements InputCleaningCommand {
  final bool trimLeadingTrailing;
  final bool normalizeSpaces;
  final bool removeEmptyLines;

  WhitespaceCleaningCommand({
    this.trimLeadingTrailing = true,
    this.normalizeSpaces = true,
    this.removeEmptyLines = false,
  });

  @override
  String get name => 'whitespace_cleaning';

  @override
  bool get canUndo => true;

  @override
  Map<String, dynamic> get metadata => {
    'name': name,
    'can_undo': canUndo,
    'type': 'whitespace_cleaning',
    'trim_leading_trailing': trimLeadingTrailing,
    'normalize_spaces': normalizeSpaces,
    'remove_empty_lines': removeEmptyLines,
  };

  @override
  InputCleaningResult execute(String input) {
    Log.debug(
      'WhitespaceCleaningCommand: Executing on input of length ${input.length}',
    );

    final stopwatch = Stopwatch()..start();
    final operations = <String>[];
    String cleaned = input;

    final originalSpaces = _countSpaces(input);

    if (trimLeadingTrailing) {
      final beforeTrim = cleaned;
      cleaned = cleaned.trim();
      if (beforeTrim != cleaned) {
        operations.add('trimmed_leading_trailing');
      }
    }

    if (normalizeSpaces) {
      final beforeNormalize = cleaned;
      // Replace multiple spaces/tabs with single space
      cleaned = cleaned.replaceAll(RegExp(r'[ \t]+'), ' ');
      if (beforeNormalize != cleaned) {
        operations.add('normalized_spaces');
      }
    }

    if (removeEmptyLines) {
      final beforeLines = cleaned;
      // Remove empty lines but preserve single line breaks
      cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n'), '\n');
      if (beforeLines != cleaned) {
        operations.add('removed_empty_lines');
      }
    }

    // Remove invisible/non-printable characters except common ones
    final beforeInvisible = cleaned;
    cleaned = cleaned.replaceAll(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
      '',
    );
    if (beforeInvisible != cleaned) {
      operations.add('removed_invisible_chars');
    }

    stopwatch.stop();

    final finalSpaces = _countSpaces(cleaned);

    final result = InputCleaningResult(
      command: this,
      originalInput: input,
      cleanedInput: cleaned,
      removedContent: [],
      // Whitespace removal doesn't track specific content
      processingTimeMs: stopwatch.elapsedMilliseconds,
      metadata: {
        'operations_performed': operations,
        'original_spaces': originalSpaces,
        'final_spaces': finalSpaces,
        'spaces_removed': originalSpaces - finalSpaces,
        'size_reduction': input.length - cleaned.length,
      },
    );

    Log.debug(
      'WhitespaceCleaningCommand: Applied ${operations.length} operations',
    );
    return result;
  }

  @override
  String? undo(InputCleaningResult result) {
    Log.debug('WhitespaceCleaningCommand: Undoing cleaning operation');
    return result.originalInput;
  }

  int _countSpaces(String text) {
    return RegExp(r'\s').allMatches(text).length;
  }
}

/// Composite command for chaining multiple cleaning operations
///
/// PATTERN: Command Pattern + Composite Pattern - Command composition
///
/// Allows combining multiple cleaning commands into a single operation
/// for comprehensive input sanitization.
class CompositeCleaningCommand implements InputCleaningCommand {
  final List<InputCleaningCommand> _commands;
  final String _name;

  CompositeCleaningCommand(this._commands, {String? name})
    : _name = name ?? 'composite_cleaning';

  @override
  String get name => _name;

  @override
  bool get canUndo => _commands.every((cmd) => cmd.canUndo);

  @override
  InputCleaningResult execute(String input) {
    Log.debug(
      'CompositeCleaningCommand: Executing ${_commands.length} commands',
    );

    final stopwatch = Stopwatch()..start();
    String currentInput = input;
    final allRemovedContent = <String>[];
    final commandResults = <InputCleaningResult>[];
    final combinedMetadata = <String, dynamic>{};

    for (final command in _commands) {
      final result = command.execute(currentInput);
      commandResults.add(result);
      allRemovedContent.addAll(result.removedContent);
      currentInput = result.cleanedInput;

      // Merge metadata
      combinedMetadata['${command.name}_metadata'] = result.metadata;
    }

    stopwatch.stop();

    final result = InputCleaningResult(
      command: this,
      originalInput: input,
      cleanedInput: currentInput,
      removedContent: allRemovedContent,
      processingTimeMs: stopwatch.elapsedMilliseconds,
      metadata: {
        ...combinedMetadata,
        'commands_executed': _commands.map((c) => c.name).toList(),
        'total_commands': _commands.length,
        'composite_processing_time': stopwatch.elapsedMilliseconds,
        'individual_results': commandResults.length,
      },
    );

    Log.info(
      'CompositeCleaningCommand: Executed ${_commands.length} commands, '
      'removed ${allRemovedContent.length} items',
    );
    return result;
  }

  @override
  String? undo(InputCleaningResult result) {
    if (!canUndo) {
      Log.warning(
        'CompositeCleaningCommand: Cannot undo - some commands do not support undo',
      );
      return null;
    }

    Log.debug('CompositeCleaningCommand: Undoing composite operation');
    return result.originalInput;
  }

  @override
  Map<String, dynamic> get metadata => {
    'name': name,
    'can_undo': canUndo,
    'type': 'composite_cleaning',
    'commands': _commands.map((c) => c.metadata).toList(),
    'composite_can_undo': canUndo,
    'total_commands': _commands.length,
  };
}

/// Command invoker for managing and executing cleaning commands
///
/// PATTERN: Command Pattern - Invoker implementation
///
/// Manages the execution of input cleaning commands with history tracking
/// and batch operations for the Tower Defense security system.
class InputCleaningInvoker {
  final List<InputCleaningResult> _history = [];
  final int _maxHistorySize;

  InputCleaningInvoker({int maxHistorySize = 100})
    : _maxHistorySize = maxHistorySize;

  /// Execute a cleaning command
  InputCleaningResult execute(InputCleaningCommand command, String input) {
    Log.debug('InputCleaningInvoker: Executing ${command.name}');

    final result = command.execute(input);

    // Add to history
    _history.add(result);

    // Maintain history size limit
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }

    Log.info(
      'InputCleaningInvoker: Command ${command.name} executed successfully',
    );
    return result;
  }

  /// Undo the last command (if possible)
  String? undoLast() {
    if (_history.isEmpty) {
      Log.warning('InputCleaningInvoker: No commands to undo');
      return null;
    }

    final lastResult = _history.last;
    final undoResult = lastResult.command.undo(lastResult);

    if (undoResult != null) {
      _history.removeLast();
      Log.info(
        'InputCleaningInvoker: Undid last command: ${lastResult.command.name}',
      );
    } else {
      Log.warning(
        'InputCleaningInvoker: Cannot undo command: ${lastResult.command.name}',
      );
    }

    return undoResult;
  }

  /// Get command execution history
  List<InputCleaningResult> get history => List.unmodifiable(_history);

  /// Clear command history
  void clearHistory() {
    _history.clear();
    Log.debug('InputCleaningInvoker: Command history cleared');
  }

  /// Get invoker statistics
  Map<String, dynamic> getStats() {
    final commandCounts = <String, int>{};
    int totalProcessingTime = 0;

    for (final result in _history) {
      final commandName = result.command.name;
      commandCounts[commandName] = (commandCounts[commandName] ?? 0) + 1;
      totalProcessingTime += result.processingTimeMs;
    }

    return {
      'total_commands_executed': _history.length,
      'command_counts': commandCounts,
      'total_processing_time_ms': totalProcessingTime,
      'average_processing_time_ms': _history.isNotEmpty
          ? (totalProcessingTime / _history.length).round()
          : 0,
      'history_size': _history.length,
      'max_history_size': _maxHistorySize,
    };
  }
}

/// Result of an input cleaning command execution
class InputCleaningResult {
  final InputCleaningCommand command;
  final String originalInput;
  final String cleanedInput;
  final List<String> removedContent;
  final int processingTimeMs;
  final Map<String, dynamic> metadata;

  const InputCleaningResult({
    required this.command,
    required this.originalInput,
    required this.cleanedInput,
    required this.removedContent,
    required this.processingTimeMs,
    required this.metadata,
  });

  /// Check if any content was removed
  bool get hasRemovedContent => removedContent.isNotEmpty;

  /// Get the amount of content reduced
  int get sizeReduction => originalInput.length - cleanedInput.length;

  /// Get reduction percentage
  double get reductionPercentage => originalInput.isNotEmpty
      ? (sizeReduction / originalInput.length * 100)
      : 0.0;

  /// Get summary for logging
  Map<String, dynamic> getSummary() {
    return {
      'command': command.name,
      'original_length': originalInput.length,
      'cleaned_length': cleanedInput.length,
      'size_reduction': sizeReduction,
      'reduction_percentage': reductionPercentage.toStringAsFixed(1),
      'removed_items': removedContent.length,
      'processing_time_ms': processingTimeMs,
      'metadata': metadata,
    };
  }

  @override
  String toString() =>
      'InputCleaningResult(${command.name}: ${originalInput.length} → '
      '${cleanedInput.length} chars, ${removedContent.length} items removed)';
}
