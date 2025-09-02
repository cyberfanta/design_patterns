/// Validation Result Entity - Security Domain Layer
///
/// PATTERN: Value Object - Immutable validation result representation
/// WHERE: Domain layer for input validation results
/// HOW: Encapsulates validation outcome with detailed feedback
/// WHY: Provides type-safe validation results with error context
library;

import 'package:equatable/equatable.dart';

/// Represents the result of an input validation operation
///
/// PATTERN: Value Object - Immutable validation representation
///
/// In the Tower Defense context, this validates user inputs for:
/// - User profile data (names, emails)
/// - Game configuration inputs
/// - Authentication credentials
/// - Search queries and filters
class ValidationResult extends Equatable {
  /// Whether the validation passed
  final bool isValid;

  /// The cleaned/sanitized value (if valid)
  final String? cleanedValue;

  /// Original input value for reference
  final String originalValue;

  /// List of validation errors (if any)
  final List<ValidationError> errors;

  /// Warnings that don't prevent validation but should be noted
  final List<ValidationWarning> warnings;

  /// Validation metadata (rules applied, processing time, etc.)
  final Map<String, dynamic> metadata;

  const ValidationResult({
    required this.isValid,
    required this.originalValue,
    this.cleanedValue,
    this.errors = const [],
    this.warnings = const [],
    this.metadata = const {},
  });

  /// Create a successful validation result
  factory ValidationResult.success({
    required String originalValue,
    String? cleanedValue,
    List<ValidationWarning> warnings = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    return ValidationResult(
      isValid: true,
      originalValue: originalValue,
      cleanedValue: cleanedValue ?? originalValue,
      warnings: warnings,
      metadata: metadata,
    );
  }

  /// Create a failed validation result
  factory ValidationResult.failure({
    required String originalValue,
    required List<ValidationError> errors,
    List<ValidationWarning> warnings = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    return ValidationResult(
      isValid: false,
      originalValue: originalValue,
      errors: errors,
      warnings: warnings,
      metadata: metadata,
    );
  }

  /// Get the value to use (cleaned if available, original otherwise)
  String get safeValue => cleanedValue ?? originalValue;

  /// Check if there are any warnings
  bool get hasWarnings => warnings.isNotEmpty;

  /// Get all error messages as a list
  List<String> get errorMessages => errors.map((e) => e.message).toList();

  /// Get all warning messages as a list
  List<String> get warningMessages => warnings.map((w) => w.message).toList();

  /// Get the primary error message (first error)
  String? get primaryError => errors.isNotEmpty ? errors.first.message : null;

  /// Get validation summary for logging/debugging
  Map<String, dynamic> getSummary() {
    return {
      'is_valid': isValid,
      'original_length': originalValue.length,
      'cleaned_length': cleanedValue?.length,
      'errors_count': errors.length,
      'warnings_count': warnings.length,
      'rules_applied': metadata['rules_applied'] ?? [],
      'processing_time_ms': metadata['processing_time_ms'],
    };
  }

  @override
  List<Object?> get props => [
    isValid,
    cleanedValue,
    originalValue,
    errors,
    warnings,
    metadata,
  ];

  @override
  String toString() =>
      'ValidationResult(isValid: $isValid, errors: ${errors.length}, '
      'warnings: ${warnings.length})';
}

/// Validation error details
class ValidationError extends Equatable {
  /// Error message
  final String message;

  /// Error code for programmatic handling
  final String code;

  /// Field or context where error occurred
  final String? field;

  /// Severity level
  final ValidationSeverity severity;

  /// Additional error context
  final Map<String, dynamic> context;

  const ValidationError({
    required this.message,
    required this.code,
    this.field,
    this.severity = ValidationSeverity.error,
    this.context = const {},
  });

  @override
  List<Object?> get props => [message, code, field, severity, context];

  @override
  String toString() => 'ValidationError($code: $message)';
}

/// Validation warning details
class ValidationWarning extends Equatable {
  /// Warning message
  final String message;

  /// Warning code for programmatic handling
  final String code;

  /// Field or context where warning occurred
  final String? field;

  /// Additional warning context
  final Map<String, dynamic> context;

  const ValidationWarning({
    required this.message,
    required this.code,
    this.field,
    this.context = const {},
  });

  @override
  List<Object?> get props => [message, code, field, context];

  @override
  String toString() => 'ValidationWarning($code: $message)';
}

/// Validation severity levels
enum ValidationSeverity { info, warning, error, critical }

/// Validation rule types
enum ValidationRuleType {
  required,
  length,
  format,
  content,
  security,
  business,
}
