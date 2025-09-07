/// App Check Token Entity
///
/// PATTERN: Value Object - Immutable token data structure
/// WHERE: Core Firebase entities - App Check token structure
/// HOW: Immutable class representing App Check authentication tokens
/// WHY: Type-safe token management for Tower Defense security
library;

import 'package:equatable/equatable.dart';

/// App Check Token Value Object
///
/// Tower Defense Context: Represents security tokens for validating
/// authentic app access to Firebase resources
class AppCheckToken extends Equatable {
  const AppCheckToken({
    required this.token,
    required this.expirationTimestamp,
    this.issuedAt,
  });

  final String token;
  final DateTime expirationTimestamp;
  final DateTime? issuedAt;

  /// Check if token is expired
  bool get isExpired {
    return DateTime.now().isAfter(expirationTimestamp);
  }

  /// Check if token is valid (not expired and not empty)
  bool get isValid {
    return token.isNotEmpty && !isExpired;
  }

  /// Get remaining validity time
  Duration get remainingValidity {
    if (isExpired) return Duration.zero;
    return expirationTimestamp.difference(DateTime.now());
  }

  /// Get token age since issued
  Duration? get age {
    if (issuedAt == null) return null;
    return DateTime.now().difference(issuedAt!);
  }

  /// Check if token will expire soon (within the specified duration)
  bool willExpireSoon(Duration threshold) {
    return remainingValidity <= threshold;
  }

  /// Get human-readable expiration status
  String get expirationStatus {
    if (isExpired) return 'Expired';

    final remaining = remainingValidity;
    if (remaining.inMinutes < 5) return 'Expires very soon';
    if (remaining.inMinutes < 15) return 'Expires soon';
    if (remaining.inHours < 1) {
      return 'Expires in ${remaining.inMinutes} minutes';
    }
    return 'Valid for ${remaining.inHours} hours';
  }

  /// Convert to Map for storage or transmission
  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'expiration_timestamp': expirationTimestamp.toIso8601String(),
      'issued_at': issuedAt?.toIso8601String(),
      'is_expired': isExpired,
      'is_valid': isValid,
    };
  }

  /// Create from Map
  factory AppCheckToken.fromMap(Map<String, dynamic> map) {
    return AppCheckToken(
      token: map['token'] as String,
      expirationTimestamp: DateTime.parse(
        map['expiration_timestamp'] as String,
      ),
      issuedAt: map['issued_at'] != null
          ? DateTime.parse(map['issued_at'] as String)
          : null,
    );
  }

  /// Create a mock token for testing
  factory AppCheckToken.mock({String? customToken, Duration? validFor}) {
    final now = DateTime.now();
    return AppCheckToken(
      token:
          customToken ?? 'mock_app_check_token_${now.millisecondsSinceEpoch}',
      expirationTimestamp: now.add(validFor ?? const Duration(hours: 1)),
      issuedAt: now,
    );
  }

  /// Create an expired token for testing
  factory AppCheckToken.expired() {
    final now = DateTime.now();
    return AppCheckToken(
      token: 'expired_token_${now.millisecondsSinceEpoch}',
      expirationTimestamp: now.subtract(const Duration(hours: 1)),
      issuedAt: now.subtract(const Duration(hours: 2)),
    );
  }

  @override
  List<Object?> get props => [token, expirationTimestamp, issuedAt];

  @override
  String toString() {
    return 'AppCheckToken(isValid: $isValid, expiresIn: ${remainingValidity.inMinutes}min)';
  }
}

/// App Check Token Status
///
/// Tower Defense Context: Comprehensive status information about
/// the current App Check token state
class AppCheckTokenStatus extends Equatable {
  const AppCheckTokenStatus({
    required this.hasToken,
    required this.isExpired,
    required this.isAutoRefreshEnabled,
    this.expirationTime,
    this.lastRefreshTime,
    this.refreshAttempts = 0,
    this.lastError,
  });

  final bool hasToken;
  final bool isExpired;
  final bool isAutoRefreshEnabled;
  final DateTime? expirationTime;
  final DateTime? lastRefreshTime;
  final int refreshAttempts;
  final String? lastError;

  /// Check if token is in a healthy state
  bool get isHealthy {
    return hasToken && !isExpired && (lastError == null);
  }

  /// Check if token needs refresh
  bool get needsRefresh {
    if (!hasToken) return true;
    if (isExpired) return true;

    // Check if expiring within 15 minutes
    if (expirationTime != null) {
      final remaining = expirationTime!.difference(DateTime.now());
      return remaining <= const Duration(minutes: 15);
    }

    return false;
  }

  /// Get status description
  String get statusDescription {
    if (!hasToken) return 'No token available';
    if (isExpired) return 'Token expired';
    if (lastError != null) return 'Error: $lastError';
    if (needsRefresh) return 'Token needs refresh';
    return 'Token valid';
  }

  /// Get security level assessment
  SecurityLevel get securityLevel {
    if (!hasToken || isExpired || lastError != null) {
      return SecurityLevel.insecure;
    }

    if (needsRefresh) {
      return SecurityLevel.degraded;
    }

    if (isAutoRefreshEnabled) {
      return SecurityLevel.secure;
    }

    return SecurityLevel.basic;
  }

  /// Convert to Map for logging
  Map<String, dynamic> toMap() {
    return {
      'has_token': hasToken,
      'is_expired': isExpired,
      'is_auto_refresh_enabled': isAutoRefreshEnabled,
      'expiration_time': expirationTime?.toIso8601String(),
      'last_refresh_time': lastRefreshTime?.toIso8601String(),
      'refresh_attempts': refreshAttempts,
      'last_error': lastError,
      'is_healthy': isHealthy,
      'needs_refresh': needsRefresh,
      'status_description': statusDescription,
      'security_level': securityLevel.name,
    };
  }

  /// Create a copy with updated fields
  AppCheckTokenStatus copyWith({
    bool? hasToken,
    bool? isExpired,
    bool? isAutoRefreshEnabled,
    DateTime? expirationTime,
    DateTime? lastRefreshTime,
    int? refreshAttempts,
    String? lastError,
  }) {
    return AppCheckTokenStatus(
      hasToken: hasToken ?? this.hasToken,
      isExpired: isExpired ?? this.isExpired,
      isAutoRefreshEnabled: isAutoRefreshEnabled ?? this.isAutoRefreshEnabled,
      expirationTime: expirationTime ?? this.expirationTime,
      lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
      refreshAttempts: refreshAttempts ?? this.refreshAttempts,
      lastError: lastError,
    );
  }

  @override
  List<Object?> get props => [
    hasToken,
    isExpired,
    isAutoRefreshEnabled,
    expirationTime,
    lastRefreshTime,
    refreshAttempts,
    lastError,
  ];

  @override
  String toString() {
    return 'AppCheckTokenStatus(${securityLevel.name}: $statusDescription)';
  }
}

/// Security levels for App Check token assessment
enum SecurityLevel {
  insecure('Insecure', '🔴'),
  degraded('Degraded', '🟡'),
  basic('Basic', '🟢'),
  secure('Secure', '🔒');

  const SecurityLevel(this.displayName, this.icon);

  final String displayName;
  final String icon;
}

/// App Check Token Manager Helper
///
/// Tower Defense Context: Helper utilities for token management
class AppCheckTokenHelper {
  /// Validate token format (basic check)
  static bool isValidTokenFormat(String token) {
    if (token.isEmpty) return false;
    if (token.length < 10) return false; // Tokens should be substantial

    // Basic format checks (adjust based on actual Firebase App Check token format)
    return token.contains('.') || token.startsWith('AEC') || token.length > 50;
  }

  /// Calculate optimal refresh time
  static DateTime calculateRefreshTime(DateTime expirationTime) {
    final timeUntilExpiry = expirationTime.difference(DateTime.now());

    // Refresh when 25% of the time remaining or at least 15 minutes before expiry
    final refreshBuffer = Duration(
      milliseconds: (timeUntilExpiry.inMilliseconds * 0.25).round(),
    );

    final minimumBuffer = const Duration(minutes: 15);
    final bufferToUse = refreshBuffer > minimumBuffer
        ? refreshBuffer
        : minimumBuffer;

    return expirationTime.subtract(bufferToUse);
  }

  /// Check if two tokens are different
  static bool tokensAreDifferent(AppCheckToken? token1, AppCheckToken? token2) {
    if (token1 == null && token2 == null) return false;
    if (token1 == null || token2 == null) return true;
    return token1.token != token2.token;
  }

  /// Get token urgency level
  static TokenUrgency getTokenUrgency(AppCheckToken? token) {
    if (token == null) return TokenUrgency.critical;
    if (token.isExpired) return TokenUrgency.critical;

    final remaining = token.remainingValidity;
    if (remaining <= const Duration(minutes: 5)) return TokenUrgency.high;
    if (remaining <= const Duration(minutes: 15)) return TokenUrgency.medium;
    if (remaining <= const Duration(hours: 1)) return TokenUrgency.low;

    return TokenUrgency.none;
  }
}

/// Token urgency levels
enum TokenUrgency {
  none('No Action Needed', '✅'),
  low('Low Priority', '🟡'),
  medium('Medium Priority', '🟠'),
  high('High Priority', '🔴'),
  critical('Critical - Immediate Action', '🚨');

  const TokenUrgency(this.description, this.icon);

  final String description;
  final String icon;
}
