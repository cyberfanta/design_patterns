/// Security Helper Functions - Convenience utilities
///
/// PATTERN: Facade - Simplified access to security functionality
/// WHERE: Feature-level helper functions for common security operations
/// HOW: Static functions providing convenient access to security services
/// WHY: Reduces boilerplate code and provides consistent security usage patterns
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/security/domain/entities/validation_result.dart';
import 'package:design_patterns/features/security/domain/services/firebase_throttle_service.dart';
import 'package:design_patterns/features/security/domain/services/security_service.dart';
// InputCleaningResult is imported via security_service.dart

/// Static helper class providing convenient access to security functionality
///
/// PATTERN: Facade - Simplified security operations interface
///
/// These helpers provide easy-to-use methods for common security operations
/// in the Tower Defense application, abstracting away the complexity of
/// the underlying security services.
class SecurityHelpers {
  // Private constructor to prevent instantiation
  SecurityHelpers._();

  static final SecurityService _securityService = SecurityService();

  /// Quick email validation with common use cases
  static Future<EmailValidationResult> validateEmail(
    String email, {
    String? clientId,
    bool strict = false,
  }) async {
    try {
      Log.debug('SecurityHelpers: Validating email (strict: $strict)');

      final result = await _securityService.validateOnly(
        email,
        InputType.email,
        clientId: clientId,
        context: {'strict_mode': strict},
      );

      return EmailValidationResult(
        isValid: result.isValid,
        email: email,
        cleanedEmail: result.cleanedValue ?? email,
        errors: result.errorMessages,
        warnings: result.warningMessages,
        isDeliverable: result.isValid && !_isDisposableEmail(email),
      );
    } catch (e) {
      Log.error('SecurityHelpers: Email validation error - $e');
      return EmailValidationResult(
        isValid: false,
        email: email,
        cleanedEmail: email,
        errors: ['Email validation failed: $e'],
        warnings: [],
        isDeliverable: false,
      );
    }
  }

  /// Quick password strength validation
  static Future<PasswordValidationResult> validatePassword(
    String password, {
    String? clientId,
    PasswordStrengthLevel requiredStrength = PasswordStrengthLevel.medium,
  }) async {
    try {
      Log.debug(
        'SecurityHelpers: Validating password (required: ${requiredStrength.name})',
      );

      final result = await _securityService.validateOnly(
        password,
        InputType.password,
        clientId: clientId,
        context: {'required_strength': requiredStrength.name},
      );

      final strengthScore = result.metadata['strength_score'] as int? ?? 0;
      final actualStrength = _getPasswordStrengthLevel(strengthScore);

      return PasswordValidationResult(
        isValid: result.isValid,
        strengthScore: strengthScore,
        strengthLevel: actualStrength,
        meetsRequirement: actualStrength.index >= requiredStrength.index,
        errors: result.errorMessages,
        warnings: result.warningMessages,
        suggestions: _getPasswordSuggestions(result),
      );
    } catch (e) {
      Log.error('SecurityHelpers: Password validation error - $e');
      return PasswordValidationResult(
        isValid: false,
        strengthScore: 0,
        strengthLevel: PasswordStrengthLevel.veryWeak,
        meetsRequirement: false,
        errors: ['Password validation failed: $e'],
        warnings: [],
        suggestions: ['Please try again with a valid password'],
      );
    }
  }

  /// Quick display name validation and cleaning
  static Future<DisplayNameResult> processDisplayName(
    String displayName, {
    String? clientId,
    bool allowEmojis = false,
  }) async {
    try {
      Log.debug(
        'SecurityHelpers: Processing display name (emojis: $allowEmojis)',
      );

      final result = await _securityService.processInput(
        displayName,
        InputType.displayName,
        clientId: clientId,
        context: {'allow_emojis': allowEmojis},
      );

      return DisplayNameResult(
        isValid: result.isValid,
        originalName: displayName,
        cleanedName: result.processedInput,
        wasModified: displayName != result.processedInput,
        errors: result.validationResult.errorMessages,
        warnings: result.validationResult.warningMessages,
        suggestions: _getDisplayNameSuggestions(result.validationResult),
      );
    } catch (e) {
      Log.error('SecurityHelpers: Display name processing error - $e');
      return DisplayNameResult(
        isValid: false,
        originalName: displayName,
        cleanedName: displayName,
        wasModified: false,
        errors: ['Display name processing failed: $e'],
        warnings: [],
        suggestions: [],
      );
    }
  }

  /// Secure content cleaning for user-generated content
  static Future<ContentCleaningResult> cleanUserContent(
    String content, {
    String? clientId,
    ContentType contentType = ContentType.general,
  }) async {
    try {
      Log.debug(
        'SecurityHelpers: Cleaning user content (type: ${contentType.name})',
      );

      final inputType = _mapContentTypeToInputType(contentType);
      final result = await _securityService.cleanOnly(
        content,
        inputType,
        clientId: clientId,
        context: {'content_type': contentType.name},
      );

      return ContentCleaningResult(
        originalContent: content,
        cleanedContent: result.cleanedInput,
        wasModified: content != result.cleanedInput,
        removedElements: result.removedContent,
        processingTimeMs: result.processingTimeMs,
        securityThreatsFound: result.removedContent.length,
        cleaningOperations:
            result.metadata['operations_performed'] as List<String>? ?? [],
      );
    } catch (e) {
      Log.error('SecurityHelpers: Content cleaning error - $e');
      return ContentCleaningResult(
        originalContent: content,
        cleanedContent: content,
        wasModified: false,
        removedElements: [],
        processingTimeMs: 0,
        securityThreatsFound: 0,
        cleaningOperations: [],
      );
    }
  }

  /// Check Firebase operation quota before making requests
  static Future<FirebaseOperationResult> checkFirebaseQuota(
    FirebaseServiceType serviceType, {
    String? operationType,
    String? clientId,
  }) async {
    try {
      Log.debug(
        'SecurityHelpers: Checking Firebase quota for ${serviceType.name}',
      );

      final decision = await _securityService.checkFirebaseThrottling(
        serviceType,
        operationType: operationType,
        context: {'client_id': clientId},
      );

      final isAllowed =
          decision == ThrottleDecision.allowed ||
          decision == ThrottleDecision.allowedWithWarning;

      return FirebaseOperationResult(
        isAllowed: isAllowed,
        serviceType: serviceType,
        decision: decision,
        reason: _getThrottleReasonMessage(decision),
        retryAfterSeconds: isAllowed ? null : 60,
        // Suggest retry after 1 minute
        quotaUtilization: _getQuotaUtilization(serviceType),
      );
    } catch (e) {
      Log.error('SecurityHelpers: Firebase quota check error - $e');
      return FirebaseOperationResult(
        isAllowed: false,
        serviceType: serviceType,
        decision: ThrottleDecision.denied,
        reason: 'Quota check failed: $e',
        retryAfterSeconds: 300,
        // 5 minutes on error
        quotaUtilization: null,
      );
    }
  }

  /// Validate and clean form data in one operation
  static Future<FormValidationResult> validateForm(
    Map<String, String> formData, {
    String? clientId,
    Map<String, InputType>? fieldTypes,
  }) async {
    try {
      Log.debug(
        'SecurityHelpers: Validating form with ${formData.length} fields',
      );

      final results = <String, SecurityProcessingResult>{};
      final errors = <String, List<String>>{};
      final warnings = <String, List<String>>{};
      final cleanedData = <String, String>{};

      bool isFormValid = true;

      for (final entry in formData.entries) {
        final fieldName = entry.key;
        final fieldValue = entry.value;
        final inputType = fieldTypes?[fieldName] ?? InputType.generic;

        final result = await _securityService.processInput(
          fieldValue,
          inputType,
          clientId: clientId,
          context: {'field_name': fieldName},
        );

        results[fieldName] = result;
        cleanedData[fieldName] = result.processedInput;

        if (!result.isValid) {
          isFormValid = false;
          errors[fieldName] = result.validationResult.errorMessages;
        }

        if (result.validationResult.hasWarnings) {
          warnings[fieldName] = result.validationResult.warningMessages;
        }
      }

      return FormValidationResult(
        isValid: isFormValid,
        originalData: formData,
        cleanedData: cleanedData,
        fieldResults: results,
        errors: errors,
        warnings: warnings,
        processingStats: _calculateFormProcessingStats(results.values.toList()),
      );
    } catch (e) {
      Log.error('SecurityHelpers: Form validation error - $e');
      return FormValidationResult(
        isValid: false,
        originalData: formData,
        cleanedData: formData,
        fieldResults: {},
        errors: {
          'form': ['Form validation failed: $e'],
        },
        warnings: {},
        processingStats: {},
      );
    }
  }

  /// Get comprehensive security status
  static SecuritySystemStatus getSecuritySystemStatus() {
    try {
      final stats = _securityService.getSecurityStats();

      return SecuritySystemStatus(
        isHealthy: true,
        uptime: DateTime.now(),
        totalValidationsToday: _getTotalValidationsToday(stats),
        securityThreatsBlocked: _getTotalThreatsBlocked(stats),
        averageProcessingTime: _getAverageProcessingTime(stats),
        throttlingStats: _getThrottlingStats(stats),
        systemLoad: _calculateSystemLoad(stats),
        lastIncident: null, // Would be populated from monitoring data
      );
    } catch (e) {
      Log.error('SecurityHelpers: System status error - $e');
      return SecuritySystemStatus(
        isHealthy: false,
        uptime: DateTime.now(),
        totalValidationsToday: 0,
        securityThreatsBlocked: 0,
        averageProcessingTime: 0,
        throttlingStats: {},
        systemLoad: SystemLoad.unknown,
        lastIncident: DateTime.now(),
      );
    }
  }

  // Private helper methods

  static bool _isDisposableEmail(String email) {
    const disposableDomains = [
      '10minutemail.com',
      'tempmail.org',
      'guerrillamail.com',
      'mailinator.com',
      'temp-mail.org',
    ];

    final domain = email.split('@').last.toLowerCase();
    return disposableDomains.contains(domain);
  }

  static PasswordStrengthLevel _getPasswordStrengthLevel(int score) {
    if (score >= 80) return PasswordStrengthLevel.veryStrong;
    if (score >= 60) return PasswordStrengthLevel.strong;
    if (score >= 40) return PasswordStrengthLevel.medium;
    if (score >= 20) return PasswordStrengthLevel.weak;
    return PasswordStrengthLevel.veryWeak;
  }

  static List<String> _getPasswordSuggestions(ValidationResult result) {
    final suggestions = <String>[];

    for (final error in result.errors) {
      switch (error.code) {
        case 'password_too_short':
          suggestions.add('Use at least 8 characters');
          break;
        case 'password_no_uppercase':
          suggestions.add('Add uppercase letters');
          break;
        case 'password_no_lowercase':
          suggestions.add('Add lowercase letters');
          break;
        case 'password_no_numbers':
          suggestions.add('Add numbers');
          break;
        case 'password_no_special':
          suggestions.add('Add special characters (!@#\$%^&*)');
          break;
        case 'password_weak':
          suggestions.add('Avoid common passwords');
          break;
      }
    }

    return suggestions;
  }

  static List<String> _getDisplayNameSuggestions(ValidationResult result) {
    final suggestions = <String>[];

    for (final error in result.errors) {
      switch (error.code) {
        case 'name_too_short':
          suggestions.add('Use at least 2 characters');
          break;
        case 'name_too_long':
          suggestions.add('Use 50 characters or less');
          break;
        case 'name_invalid_chars':
          suggestions.add(
            'Use only letters, numbers, spaces, and basic symbols',
          );
          break;
        case 'name_inappropriate':
          suggestions.add('Choose a more appropriate name');
          break;
      }
    }

    return suggestions;
  }

  static InputType _mapContentTypeToInputType(ContentType contentType) {
    switch (contentType) {
      case ContentType.general:
        return InputType.generic;
      case ContentType.userProfile:
        return InputType.displayName;
      case ContentType.gameData:
        return InputType.gameData;
      case ContentType.search:
        return InputType.searchQuery;
    }
  }

  static String _getThrottleReasonMessage(ThrottleDecision decision) {
    switch (decision) {
      case ThrottleDecision.allowed:
        return 'Operation allowed';
      case ThrottleDecision.allowedWithWarning:
        return 'Operation allowed but approaching limits';
      case ThrottleDecision.denied:
        return 'Operation denied due to rate limiting';
      case ThrottleDecision.configurationChanged:
        return 'Configuration changed';
    }
  }

  static double? _getQuotaUtilization(FirebaseServiceType serviceType) {
    try {
      final stats = _securityService.getSecurityStats();
      final serviceStats =
          stats['throttling_stats']['services'][serviceType.name];
      return serviceStats?['rate_utilization']?.toDouble();
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic> _calculateFormProcessingStats(
    List<SecurityProcessingResult> results,
  ) {
    if (results.isEmpty) return {};

    final totalTime = results.fold(0, (sum, r) => sum + r.processingTimeMs);
    final validResults = results.where((r) => r.isValid).length;
    final cleanedResults = results.where((r) => r.wasCleaned).length;

    return {
      'total_fields': results.length,
      'valid_fields': validResults,
      'cleaned_fields': cleanedResults,
      'total_processing_time_ms': totalTime,
      'average_processing_time_ms': (totalTime / results.length).round(),
      'validation_success_rate': (validResults / results.length * 100)
          .toStringAsFixed(1),
    };
  }

  static int _getTotalValidationsToday(Map<String, dynamic> stats) {
    // This would typically come from persistent storage/analytics
    return stats['cleaning_stats']?['total_commands_executed'] ?? 0;
  }

  static int _getTotalThreatsBlocked(Map<String, dynamic> stats) {
    // This would aggregate threat detection across all components
    return 0; // Placeholder
  }

  static double _getAverageProcessingTime(Map<String, dynamic> stats) {
    return stats['cleaning_stats']?['average_processing_time_ms']?.toDouble() ??
        0.0;
  }

  static Map<String, dynamic> _getThrottlingStats(Map<String, dynamic> stats) {
    return stats['throttling_stats'] ?? {};
  }

  static SystemLoad _calculateSystemLoad(Map<String, dynamic> stats) {
    // This would calculate based on various metrics
    return SystemLoad.normal; // Placeholder
  }
}

// Result classes for helper methods

class EmailValidationResult {
  final bool isValid;
  final String email;
  final String cleanedEmail;
  final List<String> errors;
  final List<String> warnings;
  final bool isDeliverable;

  const EmailValidationResult({
    required this.isValid,
    required this.email,
    required this.cleanedEmail,
    required this.errors,
    required this.warnings,
    required this.isDeliverable,
  });
}

class PasswordValidationResult {
  final bool isValid;
  final int strengthScore;
  final PasswordStrengthLevel strengthLevel;
  final bool meetsRequirement;
  final List<String> errors;
  final List<String> warnings;
  final List<String> suggestions;

  const PasswordValidationResult({
    required this.isValid,
    required this.strengthScore,
    required this.strengthLevel,
    required this.meetsRequirement,
    required this.errors,
    required this.warnings,
    required this.suggestions,
  });
}

class DisplayNameResult {
  final bool isValid;
  final String originalName;
  final String cleanedName;
  final bool wasModified;
  final List<String> errors;
  final List<String> warnings;
  final List<String> suggestions;

  const DisplayNameResult({
    required this.isValid,
    required this.originalName,
    required this.cleanedName,
    required this.wasModified,
    required this.errors,
    required this.warnings,
    required this.suggestions,
  });
}

class ContentCleaningResult {
  final String originalContent;
  final String cleanedContent;
  final bool wasModified;
  final List<String> removedElements;
  final int processingTimeMs;
  final int securityThreatsFound;
  final List<String> cleaningOperations;

  const ContentCleaningResult({
    required this.originalContent,
    required this.cleanedContent,
    required this.wasModified,
    required this.removedElements,
    required this.processingTimeMs,
    required this.securityThreatsFound,
    required this.cleaningOperations,
  });
}

class FirebaseOperationResult {
  final bool isAllowed;
  final FirebaseServiceType serviceType;
  final ThrottleDecision decision;
  final String reason;
  final int? retryAfterSeconds;
  final double? quotaUtilization;

  const FirebaseOperationResult({
    required this.isAllowed,
    required this.serviceType,
    required this.decision,
    required this.reason,
    this.retryAfterSeconds,
    this.quotaUtilization,
  });
}

class FormValidationResult {
  final bool isValid;
  final Map<String, String> originalData;
  final Map<String, String> cleanedData;
  final Map<String, SecurityProcessingResult> fieldResults;
  final Map<String, List<String>> errors;
  final Map<String, List<String>> warnings;
  final Map<String, dynamic> processingStats;

  const FormValidationResult({
    required this.isValid,
    required this.originalData,
    required this.cleanedData,
    required this.fieldResults,
    required this.errors,
    required this.warnings,
    required this.processingStats,
  });
}

class SecuritySystemStatus {
  final bool isHealthy;
  final DateTime uptime;
  final int totalValidationsToday;
  final int securityThreatsBlocked;
  final double averageProcessingTime;
  final Map<String, dynamic> throttlingStats;
  final SystemLoad systemLoad;
  final DateTime? lastIncident;

  const SecuritySystemStatus({
    required this.isHealthy,
    required this.uptime,
    required this.totalValidationsToday,
    required this.securityThreatsBlocked,
    required this.averageProcessingTime,
    required this.throttlingStats,
    required this.systemLoad,
    this.lastIncident,
  });
}

// Enums for helper classes

enum PasswordStrengthLevel { veryWeak, weak, medium, strong, veryStrong }

enum ContentType { general, userProfile, gameData, search }

enum SystemLoad { low, normal, high, critical, unknown }
