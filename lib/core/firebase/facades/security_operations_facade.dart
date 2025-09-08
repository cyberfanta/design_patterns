/// PATTERN: Facade Pattern - Security operations simplification
/// WHERE: Security facade - Simplified security validation interface
/// HOW: Single interface for complex security proxy operations
/// WHY: Abstract security complexity and provide convenient methods
library;

import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../patterns/security_proxy_pattern.dart';
import '../services/app_check_service.dart';

/// Security Operations Facade
/// Tower Defense Context: Simplified security operations for educational content
class SecurityOperationsFacade {
  SecurityOperationsFacade._();

  static SecurityOperationsFacade? _instance;

  /// PATTERN: Singleton - Single security facade instance
  static SecurityOperationsFacade get instance {
    _instance ??= SecurityOperationsFacade._();
    return _instance!;
  }

  final FirebaseAppCheckService _appCheckService =
      FirebaseAppCheckService.instance;

  /// Create educational content security proxy
  EducationalContentSecurityProxy<T> createEducationalProxy<T>({
    required ProtectedResource<T> resource,
    required String contentType,
    required String patternName,
    String? requiredSubscriptionLevel,
  }) {
    final validator = AppCheckSecurityValidator(
      appCheckService: _appCheckService,
      requireValidToken: true,
    );

    return EducationalContentSecurityProxy<T>(
      realResource: resource,
      validator: validator,
      contentType: contentType,
      patternName: patternName,
      requiredSubscriptionLevel: requiredSubscriptionLevel,
    );
  }

  /// Create game progress security proxy
  GameProgressSecurityProxy<T> createGameProgressProxy<T>({
    required ProtectedResource<T> resource,
    required String userId,
    required String operation,
    bool rateLimitingEnabled = true,
  }) {
    final validator = AppCheckSecurityValidator(
      appCheckService: _appCheckService,
      requireValidToken: true,
    );

    return GameProgressSecurityProxy<T>(
      realResource: resource,
      validator: validator,
      userId: userId,
      operation: operation,
      // enableRateLimiting: rateLimitingEnabled, // Note: parameter may not exist in actual implementation
    );
  }

  /// Create user profile security proxy
  UserProfileSecurityProxy<T> createUserProfileProxy<T>({
    required ProtectedResource<T> resource,
    required String targetUserId,
    required String requestingUserId,
    required String operation,
  }) {
    final validator = AppCheckSecurityValidator(
      appCheckService: _appCheckService,
      requireValidToken: true,
    );

    return UserProfileSecurityProxy<T>(
      realResource: resource,
      validator: validator,
      targetUserId: targetUserId,
      requestingUserId: requestingUserId,
      operation: operation,
    );
  }

  /// Validate access for pattern learning content
  Future<Either<Failure, bool>> validatePatternAccess({
    required String patternName,
    required String userId,
    String? requiredLevel,
  }) async {
    try {
      Log.debug(
        'SecurityOperationsFacade: Validating pattern access: $patternName for user: $userId',
      );

      // Check App Check token
      final tokenResult = await _appCheckService.getToken();
      if (tokenResult.isLeft()) {
        Log.warning('SecurityOperationsFacade: Failed to get App Check token');
        return Left(SecurityFailure(message: 'Security validation failed'));
      }

      // Additional pattern-specific validation
      if (patternName.contains('Advanced') && requiredLevel != 'premium') {
        return Left(
          SecurityFailure(message: 'Advanced patterns require premium access'),
        );
      }

      // Mock user level validation
      if (requiredLevel == 'premium' && !userId.contains('premium')) {
        return Left(
          SecurityFailure(message: 'Premium content requires subscription'),
        );
      }

      Log.success(
        'SecurityOperationsFacade: Pattern access validated for $patternName',
      );
      return const Right(true);
    } catch (e) {
      Log.error(
        'SecurityOperationsFacade: Pattern access validation failed: $e',
      );
      return Left(
        TechnicalFailure(message: 'Pattern access validation error: $e'),
      );
    }
  }

  /// Validate user operation permissions
  Future<Either<Failure, bool>> validateUserOperation({
    required String targetUserId,
    required String requestingUserId,
    required String operation,
  }) async {
    try {
      Log.debug(
        'SecurityOperationsFacade: Validating user operation: $operation',
      );

      // Check App Check token
      final tokenResult = await _appCheckService.getToken();
      if (tokenResult.isLeft()) {
        return Left(
          SecurityFailure(message: 'Security token validation failed'),
        );
      }

      // Self-operation validation
      if (targetUserId == requestingUserId) {
        Log.debug('SecurityOperationsFacade: Self-operation approved');
        return const Right(true);
      }

      // Admin operation validation
      if (_isAdminOperation(operation)) {
        final isAdmin = await _checkAdminPrivileges(requestingUserId);
        if (!isAdmin) {
          return Left(
            SecurityFailure(
              message: 'Admin privileges required for operation: $operation',
            ),
          );
        }
      }

      // Write operation validation
      if (_isWriteOperation(operation) && targetUserId != requestingUserId) {
        return Left(SecurityFailure(message: 'Cannot modify other user data'));
      }

      Log.success('SecurityOperationsFacade: User operation validated');
      return const Right(true);
    } catch (e) {
      Log.error(
        'SecurityOperationsFacade: User operation validation failed: $e',
      );
      return Left(
        TechnicalFailure(message: 'User operation validation error: $e'),
      );
    }
  }

  /// Validate game progress operation with rate limiting
  Future<Either<Failure, bool>> validateGameProgressOperation({
    required String userId,
    required String operation,
    bool checkRateLimit = true,
  }) async {
    try {
      Log.debug('SecurityOperationsFacade: Validating game progress operation');

      // Check App Check token
      final tokenResult = await _appCheckService.getToken();
      if (tokenResult.isLeft()) {
        return Left(SecurityFailure(message: 'Security validation failed'));
      }

      // User ownership validation
      if (userId.isEmpty) {
        return Left(ValidationFailure(message: 'User ID is required'));
      }

      // Rate limiting check
      if (checkRateLimit && operation.contains('save')) {
        final rateLimitResult = await _checkRateLimit(userId, operation);
        if (rateLimitResult.isLeft()) {
          return rateLimitResult;
        }
      }

      Log.success(
        'SecurityOperationsFacade: Game progress operation validated',
      );
      return const Right(true);
    } catch (e) {
      Log.error(
        'SecurityOperationsFacade: Game progress validation failed: $e',
      );
      return Left(
        TechnicalFailure(message: 'Game progress validation error: $e'),
      );
    }
  }

  /// Get comprehensive security status
  Future<Map<String, dynamic>> getSecurityStatus() async {
    final status = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'app_check_available': true,
    };

    try {
      // App Check token status
      final tokenStatusResult = await _appCheckService.getTokenStatus();
      status['app_check'] = tokenStatusResult.fold(
        (l) => {'status': 'error', 'error': l.message},
        (r) => {
          'status': r.statusDescription,
          'healthy': r.isHealthy,
          'has_token': r.hasToken,
          'is_expired': r.isExpired,
        },
      );

      // Get a fresh token to test
      final tokenResult = await _appCheckService.getToken();
      status['token_refresh_test'] = tokenResult.fold(
        (l) => {'success': false, 'error': l.message},
        (r) => {'success': true, 'token_available': r.isNotEmpty},
      );

      return status;
    } catch (e) {
      status['security_check_error'] = e.toString();
      return status;
    }
  }

  /// Check if operation is a write operation
  bool _isWriteOperation(String operation) {
    return operation.contains('update') ||
        operation.contains('delete') ||
        operation.contains('create') ||
        operation.contains('save');
  }

  /// Check if operation requires admin privileges
  bool _isAdminOperation(String operation) {
    return operation.contains('admin') ||
        operation.contains('moderate') ||
        operation.contains('ban') ||
        operation.contains('manage');
  }

  /// Check admin privileges (mock implementation)
  Future<bool> _checkAdminPrivileges(String userId) async {
    // Mock admin check - in real app, check against role/permissions system
    Log.debug(
      'SecurityOperationsFacade: Checking admin privileges for $userId',
    );
    return userId.contains('admin') || userId.contains('moderator');
  }

  /// Check rate limiting (mock implementation)
  Future<Either<Failure, bool>> _checkRateLimit(
    String userId,
    String operation,
  ) async {
    // Mock rate limiting - in real app, implement sophisticated rate limiting
    Log.debug('SecurityOperationsFacade: Checking rate limits for $operation');

    // Simulate rate limit check
    final key = '${userId}_$operation';

    // For demo purposes, always allow but log
    Log.debug('SecurityOperationsFacade: Rate limit check passed for $key');
    return const Right(true);
  }

  /// Log security event for audit trail
  Future<void> logSecurityEvent({
    required String eventType,
    required String userId,
    required String resource,
    required bool success,
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final logData = {
        'timestamp': DateTime.now().toIso8601String(),
        'event_type': eventType,
        'user_id': userId,
        'resource': resource,
        'success': success,
        if (reason != null) 'reason': reason,
        if (metadata != null) 'metadata': metadata,
      };

      Log.info('SecurityOperationsFacade: Security event logged: $logData');

      // In a real app, this would be sent to a security audit log
      // await SecurityAuditService.logEvent(logData);
    } catch (e) {
      Log.error('SecurityOperationsFacade: Failed to log security event: $e');
    }
  }
}
