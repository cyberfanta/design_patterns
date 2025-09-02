/// Input Validation Strategies - Security Domain Layer
///
/// PATTERN: Strategy Pattern - Interchangeable validation algorithms
/// WHERE: Domain layer for different types of input validation
/// HOW: Abstract strategy with concrete implementations for each input type
/// WHY: Allows flexible validation rules based on input context
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/security/domain/entities/validation_result.dart';

/// Abstract validation strategy interface
///
/// PATTERN: Strategy Pattern - Validation algorithm interface
///
/// Defines the contract for different input validation strategies
/// in the Tower Defense application.
abstract class ValidationStrategy {
  /// Strategy name for logging and debugging
  String get name;

  /// Validation rules this strategy applies
  List<ValidationRuleType> get supportedRules;

  /// Validate input using this strategy
  ValidationResult validate(String input, {Map<String, dynamic>? context});

  /// Clean/sanitize input using this strategy
  String clean(String input);
}

/// Email validation strategy
///
/// PATTERN: Strategy Pattern - Email-specific validation
///
/// Validates email addresses for user registration and authentication
/// in the Tower Defense game system.
class EmailValidationStrategy implements ValidationStrategy {
  @override
  String get name => 'email_validation';

  @override
  List<ValidationRuleType> get supportedRules => [
    ValidationRuleType.required,
    ValidationRuleType.format,
    ValidationRuleType.length,
    ValidationRuleType.security,
  ];

  // Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Common malicious patterns
  static final List<RegExp> _maliciousPatterns = [
    RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'vbscript:', caseSensitive: false),
    RegExp(r'on\w+\s*=', caseSensitive: false),
  ];

  @override
  ValidationResult validate(String input, {Map<String, dynamic>? context}) {
    final stopwatch = Stopwatch()..start();
    final errors = <ValidationError>[];
    final warnings = <ValidationWarning>[];
    final appliedRules = <String>[];

    Log.debug(
      'EmailValidationStrategy: Validating input of length ${input.length}',
    );

    // Required validation
    if (input.trim().isEmpty) {
      errors.add(
        const ValidationError(
          message: 'Email address is required',
          code: 'email_required',
          severity: ValidationSeverity.error,
        ),
      );
      appliedRules.add('required');
    } else {
      // Length validation
      appliedRules.add('length');
      if (input.length > 254) {
        errors.add(
          const ValidationError(
            message: 'Email address is too long (maximum 254 characters)',
            code: 'email_too_long',
            severity: ValidationSeverity.error,
          ),
        );
      }

      if (input.length < 5) {
        errors.add(
          const ValidationError(
            message: 'Email address is too short (minimum 5 characters)',
            code: 'email_too_short',
            severity: ValidationSeverity.error,
          ),
        );
      }

      // Format validation
      appliedRules.add('format');
      if (!_emailRegex.hasMatch(input)) {
        errors.add(
          const ValidationError(
            message: 'Invalid email address format',
            code: 'email_invalid_format',
            severity: ValidationSeverity.error,
          ),
        );
      }

      // Security validation
      appliedRules.add('security');
      for (final pattern in _maliciousPatterns) {
        if (pattern.hasMatch(input)) {
          errors.add(
            const ValidationError(
              message: 'Email contains potentially malicious content',
              code: 'email_malicious_content',
              severity: ValidationSeverity.critical,
            ),
          );
          break;
        }
      }

      // Check for suspicious patterns
      if (input.contains('..')) {
        warnings.add(
          const ValidationWarning(
            message: 'Email contains consecutive dots',
            code: 'email_consecutive_dots',
          ),
        );
      }

      if (input.split('@').length > 2) {
        errors.add(
          const ValidationError(
            message: 'Email contains multiple @ symbols',
            code: 'email_multiple_at',
            severity: ValidationSeverity.error,
          ),
        );
      }
    }

    stopwatch.stop();
    final metadata = {
      'rules_applied': appliedRules,
      'processing_time_ms': stopwatch.elapsedMilliseconds,
      'strategy': name,
    };

    if (errors.isNotEmpty) {
      Log.warning(
        'EmailValidationStrategy: Validation failed with ${errors.length} errors',
      );
      return ValidationResult.failure(
        originalValue: input,
        errors: errors,
        warnings: warnings,
        metadata: metadata,
      );
    } else {
      final cleanedValue = clean(input);
      Log.debug('EmailValidationStrategy: Validation succeeded');
      return ValidationResult.success(
        originalValue: input,
        cleanedValue: cleanedValue,
        warnings: warnings,
        metadata: metadata,
      );
    }
  }

  @override
  String clean(String input) {
    if (input.trim().isEmpty) return input;

    // Convert to lowercase and trim
    return input.toLowerCase().trim();
  }
}

/// Display name validation strategy
///
/// PATTERN: Strategy Pattern - Name-specific validation
///
/// Validates display names for user profiles and game characters
/// in the Tower Defense system.
class DisplayNameValidationStrategy implements ValidationStrategy {
  @override
  String get name => 'display_name_validation';

  @override
  List<ValidationRuleType> get supportedRules => [
    ValidationRuleType.required,
    ValidationRuleType.length,
    ValidationRuleType.content,
    ValidationRuleType.security,
  ];

  // Allowed characters for display names
  static final RegExp _allowedCharsRegex = RegExp(r'^[a-zA-Z0-9\s\-_.]+$');

  // Profanity filter (basic implementation)
  static final List<String> _profanityList = [
    'spam',
    'test123',
    'admin',
    'administrator',
    'root',
    'system',
  ];

  // HTML/Script patterns
  static final List<RegExp> _htmlPatterns = [
    RegExp(r'<[^>]+>', caseSensitive: false),
    RegExp(r'&[a-zA-Z0-9]+;'),
    RegExp(r'javascript:', caseSensitive: false),
  ];

  @override
  ValidationResult validate(String input, {Map<String, dynamic>? context}) {
    final stopwatch = Stopwatch()..start();
    final errors = <ValidationError>[];
    final warnings = <ValidationWarning>[];
    final appliedRules = <String>[];

    Log.debug(
      'DisplayNameValidationStrategy: Validating input "${input.substring(0, input.length.clamp(0, 20))}..."',
    );

    // Required validation
    if (input.trim().isEmpty) {
      errors.add(
        const ValidationError(
          message: 'Display name is required',
          code: 'name_required',
          severity: ValidationSeverity.error,
        ),
      );
      appliedRules.add('required');
    } else {
      // Length validation
      appliedRules.add('length');
      if (input.length > 50) {
        errors.add(
          const ValidationError(
            message: 'Display name is too long (maximum 50 characters)',
            code: 'name_too_long',
            severity: ValidationSeverity.error,
          ),
        );
      }

      if (input.trim().length < 2) {
        errors.add(
          const ValidationError(
            message: 'Display name is too short (minimum 2 characters)',
            code: 'name_too_short',
            severity: ValidationSeverity.error,
          ),
        );
      }

      // Content validation
      appliedRules.add('content');
      if (!_allowedCharsRegex.hasMatch(input)) {
        errors.add(
          const ValidationError(
            message:
                'Display name contains invalid characters. Only letters, numbers, spaces, hyphens, underscores, and dots are allowed.',
            code: 'name_invalid_chars',
            severity: ValidationSeverity.error,
          ),
        );
      }

      // Check for excessive whitespace
      if (input.contains(RegExp(r'\s{3,}'))) {
        warnings.add(
          const ValidationWarning(
            message: 'Display name contains excessive whitespace',
            code: 'name_excessive_whitespace',
          ),
        );
      }

      // Profanity check (basic)
      final lowerInput = input.toLowerCase();
      for (final word in _profanityList) {
        if (lowerInput.contains(word)) {
          errors.add(
            ValidationError(
              message: 'Display name contains inappropriate content: $word',
              code: 'name_inappropriate',
              severity: ValidationSeverity.error,
            ),
          );
        }
      }

      // Security validation
      appliedRules.add('security');
      for (final pattern in _htmlPatterns) {
        if (pattern.hasMatch(input)) {
          errors.add(
            const ValidationError(
              message: 'Display name contains HTML or script content',
              code: 'name_html_content',
              severity: ValidationSeverity.critical,
            ),
          );
          break;
        }
      }

      // Check for numeric-only names
      if (RegExp(r'^\d+$').hasMatch(input.trim())) {
        warnings.add(
          const ValidationWarning(
            message: 'Display name is numeric-only, consider adding letters',
            code: 'name_numeric_only',
          ),
        );
      }
    }

    stopwatch.stop();
    final metadata = {
      'rules_applied': appliedRules,
      'processing_time_ms': stopwatch.elapsedMilliseconds,
      'strategy': name,
    };

    if (errors.isNotEmpty) {
      Log.warning(
        'DisplayNameValidationStrategy: Validation failed with ${errors.length} errors',
      );
      return ValidationResult.failure(
        originalValue: input,
        errors: errors,
        warnings: warnings,
        metadata: metadata,
      );
    } else {
      final cleanedValue = clean(input);
      Log.debug('DisplayNameValidationStrategy: Validation succeeded');
      return ValidationResult.success(
        originalValue: input,
        cleanedValue: cleanedValue,
        warnings: warnings,
        metadata: metadata,
      );
    }
  }

  @override
  String clean(String input) {
    if (input.trim().isEmpty) return input;

    // Trim and normalize whitespace
    String cleaned = input.trim();
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned;
  }
}

/// Password validation strategy
///
/// PATTERN: Strategy Pattern - Password-specific validation
///
/// Validates passwords for user authentication with security requirements
/// for the Tower Defense game.
class PasswordValidationStrategy implements ValidationStrategy {
  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumbers;
  final bool requireSpecialChars;

  PasswordValidationStrategy({
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireNumbers = true,
    this.requireSpecialChars = true,
  });

  @override
  String get name => 'password_validation';

  @override
  List<ValidationRuleType> get supportedRules => [
    ValidationRuleType.required,
    ValidationRuleType.length,
    ValidationRuleType.format,
    ValidationRuleType.security,
  ];

  // Common weak passwords
  static final List<String> _weakPasswords = [
    'password',
    '123456',
    'password123',
    'admin',
    'qwerty',
    'letmein',
    'welcome',
    'monkey',
    '1234567890',
    'abc123',
  ];

  @override
  ValidationResult validate(String input, {Map<String, dynamic>? context}) {
    final stopwatch = Stopwatch()..start();
    final errors = <ValidationError>[];
    final warnings = <ValidationWarning>[];
    final appliedRules = <String>[];

    Log.debug('PasswordValidationStrategy: Validating password');

    // Required validation
    if (input.isEmpty) {
      errors.add(
        const ValidationError(
          message: 'Password is required',
          code: 'password_required',
          severity: ValidationSeverity.error,
        ),
      );
      appliedRules.add('required');
    } else {
      // Length validation
      appliedRules.add('length');
      if (input.length < minLength) {
        errors.add(
          ValidationError(
            message: 'Password must be at least $minLength characters long',
            code: 'password_too_short',
            severity: ValidationSeverity.error,
          ),
        );
      }

      if (input.length > 128) {
        errors.add(
          const ValidationError(
            message: 'Password is too long (maximum 128 characters)',
            code: 'password_too_long',
            severity: ValidationSeverity.error,
          ),
        );
      }

      // Format validation
      appliedRules.add('format');
      if (requireUppercase && !input.contains(RegExp(r'[A-Z]'))) {
        errors.add(
          const ValidationError(
            message: 'Password must contain at least one uppercase letter',
            code: 'password_no_uppercase',
            severity: ValidationSeverity.error,
          ),
        );
      }

      if (requireLowercase && !input.contains(RegExp(r'[a-z]'))) {
        errors.add(
          const ValidationError(
            message: 'Password must contain at least one lowercase letter',
            code: 'password_no_lowercase',
            severity: ValidationSeverity.error,
          ),
        );
      }

      if (requireNumbers && !input.contains(RegExp(r'[0-9]'))) {
        errors.add(
          const ValidationError(
            message: 'Password must contain at least one number',
            code: 'password_no_numbers',
            severity: ValidationSeverity.error,
          ),
        );
      }

      if (requireSpecialChars &&
          !input.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        errors.add(
          const ValidationError(
            message: 'Password must contain at least one special character',
            code: 'password_no_special',
            severity: ValidationSeverity.error,
          ),
        );
      }

      // Security validation
      appliedRules.add('security');
      final lowerInput = input.toLowerCase();
      for (final weakPassword in _weakPasswords) {
        if (lowerInput == weakPassword || lowerInput.contains(weakPassword)) {
          errors.add(
            ValidationError(
              message: 'Password is too common or weak',
              code: 'password_weak',
              severity: ValidationSeverity.error,
              context: {'detected_pattern': weakPassword},
            ),
          );
          break;
        }
      }

      // Check for repeated characters
      if (RegExp(r'(.)\1{2,}').hasMatch(input)) {
        warnings.add(
          const ValidationWarning(
            message: 'Password contains repeated characters',
            code: 'password_repeated_chars',
          ),
        );
      }

      // Check for sequential characters
      if (_hasSequentialChars(input)) {
        warnings.add(
          const ValidationWarning(
            message: 'Password contains sequential characters',
            code: 'password_sequential_chars',
          ),
        );
      }
    }

    stopwatch.stop();
    final metadata = {
      'rules_applied': appliedRules,
      'processing_time_ms': stopwatch.elapsedMilliseconds,
      'strategy': name,
      'strength_score': _calculateStrengthScore(input),
    };

    if (errors.isNotEmpty) {
      Log.warning(
        'PasswordValidationStrategy: Validation failed with ${errors.length} errors',
      );
      return ValidationResult.failure(
        originalValue: input,
        errors: errors,
        warnings: warnings,
        metadata: metadata,
      );
    } else {
      Log.debug('PasswordValidationStrategy: Validation succeeded');
      return ValidationResult.success(
        originalValue: input,
        cleanedValue: input, // Passwords are not cleaned/modified
        warnings: warnings,
        metadata: metadata,
      );
    }
  }

  @override
  String clean(String input) {
    // Passwords should not be cleaned/modified
    return input;
  }

  /// Check for sequential characters in password
  bool _hasSequentialChars(String password) {
    const sequences = [
      'abcdefghijklmnopqrstuvwxyz',
      '0123456789',
      'qwertyuiop',
      'asdfghjkl',
      'zxcvbnm',
    ];

    for (final sequence in sequences) {
      for (int i = 0; i <= sequence.length - 3; i++) {
        final subseq = sequence.substring(i, i + 3);
        if (password.toLowerCase().contains(subseq)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Calculate password strength score (0-100)
  int _calculateStrengthScore(String password) {
    int score = 0;

    // Length points
    score += (password.length * 2);

    // Character variety points
    if (password.contains(RegExp(r'[a-z]'))) score += 10;
    if (password.contains(RegExp(r'[A-Z]'))) score += 10;
    if (password.contains(RegExp(r'[0-9]'))) score += 10;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 15;

    // Uniqueness bonus
    final uniqueChars = password.split('').toSet().length;
    score += (uniqueChars * 2);

    return score.clamp(0, 100);
  }
}
