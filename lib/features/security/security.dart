/// Security Feature - Main Export File
///
/// PATTERN: Facade - Simplified interface to security subsystem
/// WHERE: Feature-level public API for security functionality
/// HOW: Exports all public security components while hiding internal complexity
/// WHY: Provides clean, organized access to security features
library;

// Domain Commands - Input Cleaning Operations
export 'domain/commands/input_cleaning_command.dart';
// Core Exports - Public API

// Domain Layer - Public Contracts
export 'domain/entities/validation_result.dart';
export 'domain/services/firebase_throttle_service.dart';
// Domain Services - Core Security Services
export 'domain/services/security_service.dart';
// Domain Strategies - Validation Algorithms
export 'domain/strategies/validation_strategy.dart';
// Helper Functions and Utilities
export 'security_helpers.dart';

/// Security Feature Information
class SecurityFeature {
  static const String name = 'Security';
  static const String version = '1.0.0';
  static const String description =
      'Comprehensive input validation, cleaning, and Firebase throttling system';

  /// List of design patterns implemented in this feature
  static const List<String> implementedPatterns = [
    'Strategy', // Different validation algorithms
    'Decorator', // Chainable validation enhancements
    'Command', // Input cleaning operations
    'Composite', // Combined cleaning commands
    'Singleton', // Security service and throttling service
    'Observer', // Throttle event notifications
    'Facade', // Simplified security interface
    'Chain of Responsibility', // Validation pipeline
  ];

  /// List of main features provided
  static const List<String> features = [
    'Input Validation (Email, Password, Display Name)',
    'Input Cleaning (HTML, SQL Injection, Whitespace)',
    'Firebase Request Throttling',
    'Rate Limiting with Circuit Breaker',
    'Security Monitoring and Logging',
    'Validation Result Caching',
    'Command History with Undo Support',
    'Composite Validation/Cleaning Operations',
    'Real-time Threat Detection',
    'Configurable Security Policies',
  ];

  /// Get feature information
  static Map<String, dynamic> getInfo() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'implemented_patterns': implementedPatterns,
      'features': features,
      'tower_defense_context': {
        'user_input_validation': 'Validate user profile data, game settings',
        'xss_prevention': 'Clean HTML/script content from user inputs',
        'sql_injection_protection': 'Sanitize database query inputs',
        'firebase_quota_protection':
            'Prevent Firebase service quota exhaustion',
        'abuse_prevention': 'Rate limiting and suspicious activity detection',
        'game_data_security': 'Validate and clean game configuration data',
      },
      'security_levels': {
        'input_validation': 'Multi-layer validation with strategy pattern',
        'cleaning_operations': 'Command-based cleaning with undo support',
        'throttling_protection': 'Firebase service-specific rate limiting',
        'monitoring': 'Real-time security event monitoring',
        'caching': 'Performance optimization with security considerations',
      },
    };
  }
}

// SecurityHelpers is implemented in security_helpers.dart
// This file only exports the main API

/// Security Constants
class SecurityConstants {
  // Validation Limits
  static const int maxEmailLength = 254;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxDisplayNameLength = 50;
  static const int minDisplayNameLength = 2;

  // Throttling Defaults
  static const int defaultAuthRequestsPerMinute = 300;
  static const int defaultFirestoreRequestsPerMinute = 200;
  static const int defaultStorageRequestsPerMinute = 150;
  static const int defaultAnalyticsRequestsPerMinute = 500;

  // Security Patterns
  static const List<String> dangerousHtmlTags = [
    'script',
    'iframe',
    'object',
    'embed',
    'applet',
    'form',
  ];

  static const List<String> sqlKeywords = [
    'union',
    'select',
    'insert',
    'update',
    'delete',
    'drop',
    'create',
    'alter',
    'exec',
    'execute',
  ];

  // Error Codes
  static const String emailRequiredCode = 'email_required';
  static const String emailInvalidFormatCode = 'email_invalid_format';
  static const String passwordTooShortCode = 'password_too_short';
  static const String nameRequiredCode = 'name_required';
  static const String nameInvalidCharsCode = 'name_invalid_chars';
  static const String requestThrottledCode = 'request_throttled';
  static const String rateLimitExceededCode = 'rate_limit_exceeded';
  static const String maliciousContentCode = 'malicious_content';

  // Warning Codes
  static const String approachingLimitCode = 'approaching_limit';
  static const String suspiciousPatternCode = 'suspicious_pattern';
  static const String weakPasswordCode = 'weak_password';

  // Context Keys
  static const String clientIdKey = 'client_id';
  static const String userAgentKey = 'user_agent';
  static const String ipAddressKey = 'ip_address';
  static const String operationTypeKey = 'operation_type';
  static const String inputTypeKey = 'input_type';
}
