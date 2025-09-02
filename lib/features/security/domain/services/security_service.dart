/// Security Service - Main Facade for Security Operations
///
/// PATTERN: Facade + Singleton - Simplified interface to security subsystem
/// WHERE: Domain layer main service for security operations
/// HOW: Combines validation, cleaning, and throttling in a unified interface
/// WHY: Provides simple access to complex security functionality
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/patterns/behavioral/observer.dart';
import 'package:design_patterns/features/security/domain/commands/input_cleaning_command.dart';
import 'package:design_patterns/features/security/domain/decorators/validation_decorator.dart';
import 'package:design_patterns/features/security/domain/entities/validation_result.dart';
import 'package:design_patterns/features/security/domain/services/firebase_throttle_service.dart';
import 'package:design_patterns/features/security/domain/strategies/validation_strategy.dart';

/// Main security service providing unified access to all security features
///
/// PATTERN: Facade + Singleton - Centralized security operations
///
/// This service combines input validation, cleaning, and Firebase throttling
/// into a single, easy-to-use interface for the Tower Defense application.
class SecurityService implements Observer<ThrottleEvent> {
  // PATTERN: Singleton implementation
  static final SecurityService _instance = SecurityService._internal();

  factory SecurityService() => _instance;

  SecurityService._internal() {
    _initializeService();
    Log.debug('SecurityService initialized as Singleton');
  }

  // Core security components
  late final FirebaseThrottleService _throttleService;
  late final InputCleaningInvoker _cleaningInvoker;

  // Validation strategies by input type
  final Map<String, ValidationStrategy> _validationStrategies = {};

  // Pre-configured cleaning commands
  late final Map<String, InputCleaningCommand> _cleaningCommands;

  // Configuration
  bool _isInitialized = false;
  SecurityConfiguration _config = SecurityConfiguration.defaultConfig();

  /// Initialize the security service
  void _initializeService() {
    if (_isInitialized) return;

    Log.info('SecurityService: Initializing security components');

    // Initialize throttling service
    _throttleService = FirebaseThrottleService();
    _throttleService.addObserver(this);

    // Initialize cleaning invoker
    _cleaningInvoker = InputCleaningInvoker(maxHistorySize: 200);

    // Setup validation strategies
    _setupValidationStrategies();

    // Setup cleaning commands
    _setupCleaningCommands();

    _isInitialized = true;
    Log.success('SecurityService: Initialization completed');
  }

  /// Validate and clean input using the appropriate strategy
  Future<SecurityProcessingResult> processInput(
    String input,
    InputType inputType, {
    bool enableCleaning = true,
    bool enableThrottling = true,
    String? clientId,
    Map<String, dynamic>? context,
  }) async {
    Log.debug(
      'SecurityService: Processing ${inputType.name} input of length ${input.length}',
    );

    final stopwatch = Stopwatch()..start();
    final processingContext = {
      'client_id': clientId ?? 'anonymous',
      'input_type': inputType.name,
      'enable_cleaning': enableCleaning,
      'enable_throttling': enableThrottling,
      ...?context,
    };

    try {
      // 1. Check throttling first (if enabled)
      if (enableThrottling) {
        final throttleDecision = await _checkThrottling(
          inputType,
          processingContext,
        );
        if (throttleDecision == ThrottleDecision.denied) {
          return SecurityProcessingResult.throttled(
            originalInput: input,
            inputType: inputType,
            processingTimeMs: stopwatch.elapsedMilliseconds,
            context: processingContext,
          );
        }
      }

      // 2. Validate input
      final validationResult = await _validateInput(
        input,
        inputType,
        processingContext,
      );

      // 3. Clean input (if validation passed and cleaning is enabled)
      InputCleaningResult? cleaningResult;
      String finalInput = input;

      if (validationResult.isValid && enableCleaning) {
        cleaningResult = await _cleanInput(input, inputType, processingContext);
        finalInput = cleaningResult.cleanedInput;
      }

      stopwatch.stop();

      final result = SecurityProcessingResult(
        isValid: validationResult.isValid,
        originalInput: input,
        processedInput: finalInput,
        inputType: inputType,
        validationResult: validationResult,
        cleaningResult: cleaningResult,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        context: processingContext,
      );

      Log.info(
        'SecurityService: Processing completed - '
        'Valid: ${result.isValid}, Cleaned: ${cleaningResult != null}',
      );

      return result;
    } catch (e) {
      Log.error('SecurityService: Error processing input - $e');
      stopwatch.stop();

      return SecurityProcessingResult.error(
        originalInput: input,
        inputType: inputType,
        error: e.toString(),
        processingTimeMs: stopwatch.elapsedMilliseconds,
        context: processingContext,
      );
    }
  }

  /// Quick validation without cleaning
  Future<ValidationResult> validateOnly(
    String input,
    InputType inputType, {
    String? clientId,
    Map<String, dynamic>? context,
  }) async {
    final processingContext = {
      'client_id': clientId ?? 'anonymous',
      'validation_only': true,
      ...?context,
    };

    return _validateInput(input, inputType, processingContext);
  }

  /// Quick cleaning without validation
  Future<InputCleaningResult> cleanOnly(
    String input,
    InputType inputType, {
    String? clientId,
    Map<String, dynamic>? context,
  }) async {
    final processingContext = {
      'client_id': clientId ?? 'anonymous',
      'cleaning_only': true,
      ...?context,
    };

    return _cleanInput(input, inputType, processingContext);
  }

  /// Check Firebase service throttling
  Future<ThrottleDecision> checkFirebaseThrottling(
    FirebaseServiceType serviceType, {
    String? operationType,
    Map<String, dynamic>? context,
  }) async {
    Log.debug(
      'SecurityService: Checking Firebase throttling for ${serviceType.name}',
    );
    return _throttleService.checkRequest(
      serviceType,
      operationType: operationType,
      context: context,
    );
  }

  /// Get comprehensive security statistics
  Map<String, dynamic> getSecurityStats() {
    return {
      'service_initialized': _isInitialized,
      'configuration': _config.toMap(),
      'throttling_stats': _throttleService.getThrottleStats(),
      'cleaning_stats': _cleaningInvoker.getStats(),
      'validation_strategies': _validationStrategies.keys.toList(),
      'cleaning_commands': _cleaningCommands.keys.toList(),
      'uptime': DateTime.now().toIso8601String(),
    };
  }

  /// Update security configuration
  void updateConfiguration(SecurityConfiguration newConfig) {
    Log.info('SecurityService: Updating security configuration');
    _config = newConfig;

    // Apply new configuration to components
    if (newConfig.customRateLimits != null) {
      for (final entry in newConfig.customRateLimits!.entries) {
        _throttleService.updateRateLimit(entry.key, entry.value);
      }
    }

    Log.success('SecurityService: Configuration updated');
  }

  // Private implementation methods

  void _setupValidationStrategies() {
    // Email validation with decorators
    final emailStrategy = EmailValidationStrategy();
    final decoratedEmailStrategy = LoggingValidationDecorator(
      RateLimitingValidationDecorator(
        CacheValidationDecorator(
          SecurityMonitoringValidationDecorator(emailStrategy),
        ),
      ),
    );
    _validationStrategies['email'] = decoratedEmailStrategy;

    // Display name validation with decorators
    final nameStrategy = DisplayNameValidationStrategy();
    final decoratedNameStrategy = LoggingValidationDecorator(
      RateLimitingValidationDecorator(CacheValidationDecorator(nameStrategy)),
    );
    _validationStrategies['display_name'] = decoratedNameStrategy;

    // Password validation (no caching for security)
    final passwordStrategy = PasswordValidationStrategy();
    final decoratedPasswordStrategy = LoggingValidationDecorator(
      RateLimitingValidationDecorator(
        SecurityMonitoringValidationDecorator(passwordStrategy),
      ),
    );
    _validationStrategies['password'] = decoratedPasswordStrategy;

    Log.debug('SecurityService: Validation strategies configured');
  }

  void _setupCleaningCommands() {
    _cleaningCommands = {
      'html': HtmlCleaningCommand(),
      'sql': SqlInjectionCleaningCommand(),
      'whitespace': WhitespaceCleaningCommand(),
      'comprehensive': CompositeCleaningCommand([
        HtmlCleaningCommand(),
        SqlInjectionCleaningCommand(),
        WhitespaceCleaningCommand(),
      ], name: 'comprehensive_cleaning'),
    };

    Log.debug('SecurityService: Cleaning commands configured');
  }

  Future<ThrottleDecision> _checkThrottling(
    InputType inputType,
    Map<String, dynamic> context,
  ) async {
    // Map input types to Firebase services for throttling
    FirebaseServiceType? serviceType;

    switch (inputType) {
      case InputType.email:
      case InputType.password:
        serviceType = FirebaseServiceType.authentication;
        break;
      case InputType.displayName:
      case InputType.gameData:
        serviceType = FirebaseServiceType.firestore;
        break;
      case InputType.searchQuery:
        serviceType = FirebaseServiceType.firestore;
        break;
      case InputType.imageUpload:
        serviceType = FirebaseServiceType.storage;
        break;
      default:
        serviceType = FirebaseServiceType.firestore; // Default
    }

    return _throttleService.checkRequest(
      serviceType,
      operationType: 'input_validation',
      context: context,
    );
  }

  Future<ValidationResult> _validateInput(
    String input,
    InputType inputType,
    Map<String, dynamic> context,
  ) async {
    final strategyKey = _getValidationStrategyKey(inputType);
    final strategy = _validationStrategies[strategyKey];

    if (strategy == null) {
      Log.warning(
        'SecurityService: No validation strategy for ${inputType.name}',
      );
      return ValidationResult.success(
        originalValue: input,
        metadata: {'no_strategy': true},
      );
    }

    return strategy.validate(input, context: context);
  }

  Future<InputCleaningResult> _cleanInput(
    String input,
    InputType inputType,
    Map<String, dynamic> context,
  ) async {
    final commandKey = _getCleaningCommandKey(inputType);
    final command = _cleaningCommands[commandKey];

    if (command == null) {
      Log.warning('SecurityService: No cleaning command for ${inputType.name}');
      // Return a basic whitespace cleaning as fallback
      final fallbackCommand = WhitespaceCleaningCommand();
      return _cleaningInvoker.execute(fallbackCommand, input);
    }

    return _cleaningInvoker.execute(command, input);
  }

  String _getValidationStrategyKey(InputType inputType) {
    switch (inputType) {
      case InputType.email:
        return 'email';
      case InputType.password:
        return 'password';
      case InputType.displayName:
      case InputType.userName:
        return 'display_name';
      default:
        return 'display_name'; // Default strategy
    }
  }

  String _getCleaningCommandKey(InputType inputType) {
    switch (inputType) {
      case InputType.email:
        return 'whitespace';
      case InputType.password:
        return 'whitespace'; // Minimal cleaning for passwords
      case InputType.displayName:
      case InputType.userName:
      case InputType.searchQuery:
        return 'comprehensive';
      case InputType.gameData:
        return 'html'; // Game data might contain HTML
      default:
        return 'comprehensive';
    }
  }

  // PATTERN: Observer - Implementation for throttle events
  @override
  void update(ThrottleEvent event) {
    // Log throttling events for security monitoring
    if (event.isDenial) {
      Log.warning(
        'SecurityService: Throttle DENIAL for ${event.serviceType.name} '
        '(${event.currentCount}/${event.limit})',
      );
    } else if (event.isWarning) {
      Log.info(
        'SecurityService: Throttle WARNING for ${event.serviceType.name} '
        '(${event.utilizationPercentage.toStringAsFixed(1)}% utilization)',
      );
    } else if (event.isCritical) {
      Log.error(
        'SecurityService: CRITICAL throttle event for ${event.serviceType.name}',
      );
    }
  }

  /// Dispose resources (mainly for testing)
  void dispose() {
    _throttleService.removeObserver(this);
    _throttleService.dispose();
    _cleaningInvoker.clearHistory();
    _validationStrategies.clear();
    Log.debug('SecurityService: Disposed');
  }
}

/// Input types supported by the security system
enum InputType {
  email,
  password,
  displayName,
  userName,
  searchQuery,
  gameData,
  imageUpload,
  generic,
}

/// Security processing result containing all operation results
class SecurityProcessingResult {
  final bool isValid;
  final String originalInput;
  final String processedInput;
  final InputType inputType;
  final ValidationResult validationResult;
  final InputCleaningResult? cleaningResult;
  final int processingTimeMs;
  final Map<String, dynamic> context;
  final String? error;

  const SecurityProcessingResult({
    required this.isValid,
    required this.originalInput,
    required this.processedInput,
    required this.inputType,
    required this.validationResult,
    this.cleaningResult,
    required this.processingTimeMs,
    required this.context,
    this.error,
  });

  factory SecurityProcessingResult.throttled({
    required String originalInput,
    required InputType inputType,
    required int processingTimeMs,
    required Map<String, dynamic> context,
  }) {
    return SecurityProcessingResult(
      isValid: false,
      originalInput: originalInput,
      processedInput: originalInput,
      inputType: inputType,
      validationResult: ValidationResult.failure(
        originalValue: originalInput,
        errors: [
          const ValidationError(
            message: 'Request throttled due to rate limiting',
            code: 'request_throttled',
            severity: ValidationSeverity.error,
          ),
        ],
      ),
      processingTimeMs: processingTimeMs,
      context: context,
      error: 'Request throttled',
    );
  }

  factory SecurityProcessingResult.error({
    required String originalInput,
    required InputType inputType,
    required String error,
    required int processingTimeMs,
    required Map<String, dynamic> context,
  }) {
    return SecurityProcessingResult(
      isValid: false,
      originalInput: originalInput,
      processedInput: originalInput,
      inputType: inputType,
      validationResult: ValidationResult.failure(
        originalValue: originalInput,
        errors: [
          ValidationError(
            message: 'Security processing error: $error',
            code: 'processing_error',
            severity: ValidationSeverity.critical,
          ),
        ],
      ),
      processingTimeMs: processingTimeMs,
      context: context,
      error: error,
    );
  }

  /// Check if input was cleaned
  bool get wasCleaned =>
      cleaningResult != null && cleaningResult!.hasRemovedContent;

  /// Check if this was a throttled request
  bool get wasThrottled => error?.contains('throttled') == true;

  /// Get summary for logging
  Map<String, dynamic> getSummary() {
    return {
      'is_valid': isValid,
      'input_type': inputType.name,
      'original_length': originalInput.length,
      'processed_length': processedInput.length,
      'was_cleaned': wasCleaned,
      'was_throttled': wasThrottled,
      'processing_time_ms': processingTimeMs,
      'validation_errors': validationResult.errors.length,
      'validation_warnings': validationResult.warnings.length,
      'cleaning_removed_items': cleaningResult?.removedContent.length ?? 0,
      'error': error,
    };
  }

  @override
  String toString() =>
      'SecurityProcessingResult(${inputType.name}: valid=$isValid, '
      'cleaned=$wasCleaned, time=${processingTimeMs}ms)';
}

/// Security service configuration
class SecurityConfiguration {
  final bool enableValidation;
  final bool enableCleaning;
  final bool enableThrottling;
  final bool enableLogging;
  final bool enableCaching;
  final bool enableSecurityMonitoring;
  final Map<FirebaseServiceType, int>? customRateLimits;
  final int maxHistorySize;

  const SecurityConfiguration({
    this.enableValidation = true,
    this.enableCleaning = true,
    this.enableThrottling = true,
    this.enableLogging = true,
    this.enableCaching = true,
    this.enableSecurityMonitoring = true,
    this.customRateLimits,
    this.maxHistorySize = 200,
  });

  factory SecurityConfiguration.defaultConfig() {
    return const SecurityConfiguration();
  }

  factory SecurityConfiguration.highSecurity() {
    return const SecurityConfiguration(
      enableValidation: true,
      enableCleaning: true,
      enableThrottling: true,
      enableLogging: true,
      enableCaching: false,
      // Disable caching for high security
      enableSecurityMonitoring: true,
      maxHistorySize: 500,
    );
  }

  factory SecurityConfiguration.performance() {
    return const SecurityConfiguration(
      enableValidation: true,
      enableCleaning: false,
      // Disable cleaning for performance
      enableThrottling: true,
      enableLogging: false,
      // Disable detailed logging
      enableCaching: true,
      enableSecurityMonitoring: false,
      maxHistorySize: 100,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enable_validation': enableValidation,
      'enable_cleaning': enableCleaning,
      'enable_throttling': enableThrottling,
      'enable_logging': enableLogging,
      'enable_caching': enableCaching,
      'enable_security_monitoring': enableSecurityMonitoring,
      'custom_rate_limits': customRateLimits?.map(
        (k, v) => MapEntry(k.name, v),
      ),
      'max_history_size': maxHistorySize,
    };
  }
}
