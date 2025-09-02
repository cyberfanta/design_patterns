/// Validation Decorator - Security Domain Layer
///
/// PATTERN: Decorator Pattern - Chainable validation enhancements
/// WHERE: Domain layer for composing validation behaviors
/// HOW: Decorators wrap base validators to add additional validation rules
/// WHY: Allows flexible composition of validation rules without inheritance
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/security/domain/entities/validation_result.dart';
import 'package:design_patterns/features/security/domain/strategies/validation_strategy.dart';

/// Base decorator for validation strategies
///
/// PATTERN: Decorator Pattern - Base decorator implementation
///
/// Allows wrapping validation strategies with additional behavior
/// while maintaining the same interface.
abstract class ValidationDecorator implements ValidationStrategy {
  final ValidationStrategy _wrapped;

  ValidationDecorator(this._wrapped);

  @override
  String get name => '${_wrapped.name}_decorated';

  @override
  List<ValidationRuleType> get supportedRules => _wrapped.supportedRules;

  @override
  ValidationResult validate(String input, {Map<String, dynamic>? context}) {
    return _wrapped.validate(input, context: context);
  }

  @override
  String clean(String input) {
    return _wrapped.clean(input);
  }
}

/// Rate limiting validation decorator
///
/// PATTERN: Decorator Pattern - Rate limiting enhancement
///
/// Prevents excessive validation requests from the same source
/// to protect against DoS attacks in the Tower Defense app.
class RateLimitingValidationDecorator extends ValidationDecorator {
  final Map<String, List<DateTime>> _requestHistory = {};
  final int maxRequestsPerMinute;
  final Duration timeWindow;

  RateLimitingValidationDecorator(
    super.wrapped, {
    this.maxRequestsPerMinute = 100,
    this.timeWindow = const Duration(minutes: 1),
  });

  @override
  String get name => '${super.name}_rate_limited';

  @override
  ValidationResult validate(String input, {Map<String, dynamic>? context}) {
    final clientId = context?['client_id'] as String? ?? 'anonymous';

    if (_isRateLimited(clientId)) {
      Log.warning('ValidationRateLimit: Client $clientId rate limited');
      return ValidationResult.failure(
        originalValue: input,
        errors: [
          const ValidationError(
            message:
                'Too many validation requests. Please wait before trying again.',
            code: 'validation_rate_limited',
            severity: ValidationSeverity.error,
          ),
        ],
        metadata: {
          'rate_limited': true,
          'client_id': clientId,
          'decorator': name,
        },
      );
    }

    _recordRequest(clientId);
    return super.validate(input, context: context);
  }

  bool _isRateLimited(String clientId) {
    final now = DateTime.now();
    final history = _requestHistory[clientId] ?? [];

    // Remove old requests outside time window
    history.removeWhere((time) => now.difference(time) > timeWindow);
    _requestHistory[clientId] = history;

    return history.length >= maxRequestsPerMinute;
  }

  void _recordRequest(String clientId) {
    final history = _requestHistory[clientId] ?? [];
    history.add(DateTime.now());
    _requestHistory[clientId] = history;
  }

  /// Get rate limiting stats for monitoring
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final activeClients = <String, int>{};

    for (final entry in _requestHistory.entries) {
      final recentRequests = entry.value
          .where((time) => now.difference(time) <= timeWindow)
          .length;
      if (recentRequests > 0) {
        activeClients[entry.key] = recentRequests;
      }
    }

    return {
      'active_clients': activeClients.length,
      'client_requests': activeClients,
      'total_clients_seen': _requestHistory.length,
      'max_requests_per_minute': maxRequestsPerMinute,
    };
  }
}

/// Logging validation decorator
///
/// PATTERN: Decorator Pattern - Logging enhancement
///
/// Adds comprehensive logging to validation operations
/// for security monitoring and debugging.
class LoggingValidationDecorator extends ValidationDecorator {
  final bool logSuccesses;
  final bool logFailures;
  final bool logWarnings;

  LoggingValidationDecorator(
    super.wrapped, {
    this.logSuccesses = true,
    this.logFailures = true,
    this.logWarnings = true,
  });

  @override
  String get name => '${super.name}_logged';

  @override
  ValidationResult validate(String input, {Map<String, dynamic>? context}) {
    final stopwatch = Stopwatch()..start();
    final clientId = context?['client_id'] as String? ?? 'anonymous';

    Log.debug(
      'ValidationLogging: Starting validation with ${_wrapped.name} for client $clientId',
    );

    final result = super.validate(input, context: context);

    stopwatch.stop();
    final processingTime = stopwatch.elapsedMilliseconds;

    // Log based on result and configuration
    if (result.isValid && logSuccesses) {
      Log.info(
        'ValidationLogging: SUCCESS - ${_wrapped.name} validated input '
        'in ${processingTime}ms (warnings: ${result.warnings.length})',
      );
    } else if (!result.isValid && logFailures) {
      Log.warning(
        'ValidationLogging: FAILURE - ${_wrapped.name} rejected input '
        'with ${result.errors.length} errors in ${processingTime}ms',
      );

      for (final error in result.errors) {
        if (error.severity == ValidationSeverity.critical) {
          Log.error(
            'ValidationLogging: CRITICAL ERROR - ${error.code}: ${error.message}',
          );
        }
      }
    }

    if (result.hasWarnings && logWarnings) {
      Log.info(
        'ValidationLogging: WARNINGS - ${result.warnings.length} warnings detected:',
      );
      for (final warning in result.warnings) {
        Log.info(
          'ValidationLogging: WARNING - ${warning.code}: ${warning.message}',
        );
      }
    }

    // Add logging metadata to result
    final enhancedMetadata = Map<String, dynamic>.from(result.metadata);
    enhancedMetadata.addAll({
      'logged_at': DateTime.now().toIso8601String(),
      'processing_time_ms': processingTime,
      'client_id': clientId,
      'decorator': name,
    });

    return ValidationResult(
      isValid: result.isValid,
      originalValue: result.originalValue,
      cleanedValue: result.cleanedValue,
      errors: result.errors,
      warnings: result.warnings,
      metadata: enhancedMetadata,
    );
  }
}

/// Cache validation decorator
///
/// PATTERN: Decorator Pattern - Caching enhancement
///
/// Caches validation results for identical inputs to improve performance
/// and reduce computational overhead.
class CacheValidationDecorator extends ValidationDecorator {
  final Map<String, ValidationResult> _cache = {};
  final int maxCacheSize;
  final Duration cacheDuration;

  CacheValidationDecorator(
    super.wrapped, {
    this.maxCacheSize = 1000,
    this.cacheDuration = const Duration(minutes: 5),
  });

  @override
  String get name => '${super.name}_cached';

  @override
  ValidationResult validate(String input, {Map<String, dynamic>? context}) {
    final cacheKey = _generateCacheKey(input, context);

    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cachedResult = _cache[cacheKey]!;
      final cacheAge = DateTime.now().difference(
        DateTime.parse(cachedResult.metadata['cached_at'] as String),
      );

      if (cacheAge <= cacheDuration) {
        Log.debug(
          'ValidationCache: Cache HIT for key ${cacheKey.substring(0, 8)}...',
        );

        // Return cached result with updated metadata
        final enhancedMetadata = Map<String, dynamic>.from(
          cachedResult.metadata,
        );
        enhancedMetadata.addAll({
          'cache_hit': true,
          'cache_age_ms': cacheAge.inMilliseconds,
          'decorator': name,
        });

        return ValidationResult(
          isValid: cachedResult.isValid,
          originalValue: cachedResult.originalValue,
          cleanedValue: cachedResult.cleanedValue,
          errors: cachedResult.errors,
          warnings: cachedResult.warnings,
          metadata: enhancedMetadata,
        );
      } else {
        // Cache expired, remove entry
        _cache.remove(cacheKey);
      }
    }

    Log.debug(
      'ValidationCache: Cache MISS for key ${cacheKey.substring(0, 8)}...',
    );

    // Validate and cache result
    final result = super.validate(input, context: context);

    // Add to cache if space available
    if (_cache.length < maxCacheSize) {
      final enhancedMetadata = Map<String, dynamic>.from(result.metadata);
      enhancedMetadata.addAll({
        'cached_at': DateTime.now().toIso8601String(),
        'cache_hit': false,
        'decorator': name,
      });

      final cachedResult = ValidationResult(
        isValid: result.isValid,
        originalValue: result.originalValue,
        cleanedValue: result.cleanedValue,
        errors: result.errors,
        warnings: result.warnings,
        metadata: enhancedMetadata,
      );

      _cache[cacheKey] = cachedResult;
    } else {
      // Cache is full, remove oldest entry (simple FIFO)
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
      Log.debug('ValidationCache: Cache full, evicted oldest entry');
    }

    return result;
  }

  String _generateCacheKey(String input, Map<String, dynamic>? context) {
    final buffer = StringBuffer();
    buffer.write(_wrapped.name);
    buffer.write('|');
    buffer.write(input.hashCode);

    if (context != null) {
      buffer.write('|');
      buffer.write(context.hashCode);
    }

    return buffer.toString();
  }

  /// Clear validation cache
  void clearCache() {
    _cache.clear();
    Log.info('ValidationCache: Cache cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    int expiredEntries = 0;

    for (final result in _cache.values) {
      final cachedAt = DateTime.parse(result.metadata['cached_at'] as String);
      if (now.difference(cachedAt) > cacheDuration) {
        expiredEntries++;
      }
    }

    return {
      'cache_size': _cache.length,
      'max_cache_size': maxCacheSize,
      'expired_entries': expiredEntries,
      'cache_duration_minutes': cacheDuration.inMinutes,
      'hit_rate': _cache.isNotEmpty ? 'Not tracked' : 'N/A',
    };
  }
}

/// Security monitoring validation decorator
///
/// PATTERN: Decorator Pattern - Security monitoring enhancement
///
/// Monitors validation attempts for suspicious patterns and
/// potential security threats in the Tower Defense application.
class SecurityMonitoringValidationDecorator extends ValidationDecorator {
  final Map<String, SecurityMetrics> _clientMetrics = {};
  final int suspiciousThreshold;

  SecurityMonitoringValidationDecorator(
    super.wrapped, {
    this.suspiciousThreshold = 10,
  });

  @override
  String get name => '${super.name}_security_monitored';

  @override
  ValidationResult validate(String input, {Map<String, dynamic>? context}) {
    final clientId = context?['client_id'] as String? ?? 'anonymous';
    final userAgent = context?['user_agent'] as String?;
    final ipAddress = context?['ip_address'] as String?;

    // Update client metrics
    _updateClientMetrics(clientId, input, userAgent, ipAddress);

    final result = super.validate(input, context: context);

    // Analyze result for suspicious patterns
    final securityAnalysis = _analyzeSecurityThreats(clientId, input, result);

    // Add security metadata to result
    final enhancedMetadata = Map<String, dynamic>.from(result.metadata);
    enhancedMetadata.addAll({
      'security_analysis': securityAnalysis,
      'client_metrics': _clientMetrics[clientId]?.toMap(),
      'decorator': name,
    });

    return ValidationResult(
      isValid: result.isValid,
      originalValue: result.originalValue,
      cleanedValue: result.cleanedValue,
      errors: result.errors,
      warnings: result.warnings,
      metadata: enhancedMetadata,
    );
  }

  void _updateClientMetrics(
    String clientId,
    String input,
    String? userAgent,
    String? ipAddress,
  ) {
    final metrics = _clientMetrics[clientId] ??= SecurityMetrics(clientId);

    metrics.totalAttempts++;
    metrics.lastAttemptAt = DateTime.now();

    if (userAgent != null && metrics.userAgent != userAgent) {
      metrics.userAgentChanges++;
      metrics.userAgent = userAgent;
    }

    if (ipAddress != null && metrics.ipAddress != ipAddress) {
      metrics.ipChanges++;
      metrics.ipAddress = ipAddress;
    }

    // Track suspicious patterns
    if (input.length > 1000) {
      metrics.longInputs++;
    }

    if (RegExp(
      r'<script|javascript|vbscript',
      caseSensitive: false,
    ).hasMatch(input)) {
      metrics.scriptAttempts++;
    }

    if (RegExp(
      r'(union|select|insert|update|delete|drop)',
      caseSensitive: false,
    ).hasMatch(input)) {
      metrics.sqlAttempts++;
    }
  }

  Map<String, dynamic> _analyzeSecurityThreats(
    String clientId,
    String input,
    ValidationResult result,
  ) {
    final metrics = _clientMetrics[clientId];
    if (metrics == null) return {};

    final threats = <String>[];
    int riskScore = 0;

    // High frequency attempts
    if (metrics.totalAttempts > suspiciousThreshold) {
      threats.add('high_frequency_attempts');
      riskScore += 3;
    }

    // Multiple user agent changes
    if (metrics.userAgentChanges > 2) {
      threats.add('multiple_user_agents');
      riskScore += 2;
    }

    // Multiple IP changes
    if (metrics.ipChanges > 1) {
      threats.add('multiple_ip_addresses');
      riskScore += 2;
    }

    // Script injection attempts
    if (metrics.scriptAttempts > 0) {
      threats.add('script_injection_attempts');
      riskScore += 5;
    }

    // SQL injection attempts
    if (metrics.sqlAttempts > 0) {
      threats.add('sql_injection_attempts');
      riskScore += 5;
    }

    // Critical validation errors
    final criticalErrors = result.errors
        .where((e) => e.severity == ValidationSeverity.critical)
        .length;
    if (criticalErrors > 0) {
      threats.add('critical_validation_errors');
      riskScore += criticalErrors * 2;
    }

    String threatLevel = 'low';
    if (riskScore >= 10) {
      threatLevel = 'critical';
      Log.error(
        'SecurityMonitoring: CRITICAL threat level for client $clientId (score: $riskScore)',
      );
    } else if (riskScore >= 5) {
      threatLevel = 'high';
      Log.warning(
        'SecurityMonitoring: HIGH threat level for client $clientId (score: $riskScore)',
      );
    } else if (riskScore >= 2) {
      threatLevel = 'medium';
      Log.info(
        'SecurityMonitoring: MEDIUM threat level for client $clientId (score: $riskScore)',
      );
    }

    return {
      'threats_detected': threats,
      'risk_score': riskScore,
      'threat_level': threatLevel,
      'analysis_timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get security monitoring report
  Map<String, dynamic> getSecurityReport() {
    final totalClients = _clientMetrics.length;
    final highRiskClients = _clientMetrics.values
        .where(
          (m) =>
              m.scriptAttempts > 0 ||
              m.sqlAttempts > 0 ||
              m.totalAttempts > suspiciousThreshold,
        )
        .length;

    return {
      'total_clients_monitored': totalClients,
      'high_risk_clients': highRiskClients,
      'total_script_attempts': _clientMetrics.values.fold(
        0,
        (sum, m) => sum + m.scriptAttempts,
      ),
      'total_sql_attempts': _clientMetrics.values.fold(
        0,
        (sum, m) => sum + m.sqlAttempts,
      ),
      'suspicious_threshold': suspiciousThreshold,
      'report_generated_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Security metrics for monitoring client behavior
class SecurityMetrics {
  final String clientId;
  int totalAttempts = 0;
  int userAgentChanges = 0;
  int ipChanges = 0;
  int longInputs = 0;
  int scriptAttempts = 0;
  int sqlAttempts = 0;
  DateTime? lastAttemptAt;
  String? userAgent;
  String? ipAddress;

  SecurityMetrics(this.clientId);

  Map<String, dynamic> toMap() {
    return {
      'client_id': clientId,
      'total_attempts': totalAttempts,
      'user_agent_changes': userAgentChanges,
      'ip_changes': ipChanges,
      'long_inputs': longInputs,
      'script_attempts': scriptAttempts,
      'sql_attempts': sqlAttempts,
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
    };
  }
}
