/// Security Proxy Pattern Implementation
///
/// PATTERN: Proxy Pattern - Security validation proxy
/// WHERE: Core Firebase patterns - Proxy implementation for security
/// HOW: Proxy intercepts requests to validate security and authorization
/// WHY: Protect Tower Defense educational resources from unauthorized access
library;

import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../services/app_check_service.dart';

/// Base interface for protected resources
abstract class ProtectedResource<T> {
  Future<Either<Failure, T>> accessResource();
}

/// Security validation interface
abstract class SecurityValidator {
  Future<Either<Failure, bool>> validateAccess();

  Future<Either<Failure, void>> logAccess(String operation);
}

/// Base Security Proxy
abstract class SecurityProxy<T> implements ProtectedResource<T> {
  const SecurityProxy({required this.realResource, required this.validator});

  final ProtectedResource<T> realResource;
  final SecurityValidator validator;

  @override
  Future<Either<Failure, T>> accessResource() async {
    // Validate access before allowing resource access
    final validationResult = await validator.validateAccess();

    if (validationResult.isLeft()) {
      return Left(validationResult.fold((l) => l, (r) => throw 'Unreachable'));
    }

    final isValid = validationResult.fold((l) => false, (r) => r);
    if (!isValid) {
      return Left(
        SecurityFailure(message: 'Access denied - security validation failed'),
      );
    }

    // Log the access attempt
    await validator.logAccess(runtimeType.toString());

    // Access the real resource
    return realResource.accessResource();
  }
}

/// App Check Security Validator
/// Tower Defense Context: Validates requests using Firebase App Check tokens
class AppCheckSecurityValidator implements SecurityValidator {
  AppCheckSecurityValidator({
    required this.appCheckService,
    this.requireValidToken = true,
    this.logAccessAttempts = true,
  });

  final FirebaseAppCheckService appCheckService;
  final bool requireValidToken;
  final bool logAccessAttempts;

  @override
  Future<Either<Failure, bool>> validateAccess() async {
    try {
      Log.debug('AppCheckSecurityValidator: Validating access');

      // Check if App Check is required and available
      if (requireValidToken) {
        final tokenStatusResult = await appCheckService.getTokenStatus();

        if (tokenStatusResult.isLeft()) {
          Log.warning('AppCheckSecurityValidator: Failed to get token status');
          return const Right(false);
        }

        final tokenStatus = tokenStatusResult.fold((l) => null, (r) => r)!;

        if (!tokenStatus.isHealthy) {
          Log.warning(
            'AppCheckSecurityValidator: Token not healthy - ${tokenStatus.statusDescription}',
          );

          // Try to get a new token
          final tokenResult = await appCheckService.getToken(
            forceRefresh: true,
          );
          if (tokenResult.isLeft()) {
            Log.error('AppCheckSecurityValidator: Failed to refresh token');
            return const Right(false);
          }
        }
      }

      Log.success('AppCheckSecurityValidator: Access validated successfully');
      return const Right(true);
    } catch (e) {
      Log.error('AppCheckSecurityValidator: Validation error: $e');
      return Left(SecurityFailure(message: 'Security validation error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logAccess(String operation) async {
    if (!logAccessAttempts) return const Right(null);

    try {
      Log.info('Security: Authorized access to $operation');

      // Could extend this to log to Firebase Analytics
      // AnalyticsService.trackEvent(SecurityAccessEvent(operation: operation));

      return const Right(null);
    } catch (e) {
      Log.error('AppCheckSecurityValidator: Failed to log access: $e');
      return Left(TechnicalFailure(message: 'Failed to log access: $e'));
    }
  }
}

/// Educational Content Security Proxy
/// Tower Defense Context: Protects access to educational pattern content
class EducationalContentSecurityProxy<T> extends SecurityProxy<T> {
  const EducationalContentSecurityProxy({
    required super.realResource,
    required super.validator,
    required this.contentType,
    required this.patternName,
    this.requiredSubscriptionLevel,
  });

  final String contentType;
  final String patternName;
  final String? requiredSubscriptionLevel;

  @override
  Future<Either<Failure, T>> accessResource() async {
    Log.debug(
      'EducationalContentSecurityProxy: Accessing $contentType for pattern $patternName',
    );

    // Additional educational content validation
    final educationalValidation = await _validateEducationalAccess();
    if (educationalValidation.isLeft()) {
      return Left(
        educationalValidation.fold((l) => l, (r) => throw 'Unreachable'),
      );
    }

    // Proceed with base security validation
    return super.accessResource();
  }

  Future<Either<Failure, bool>> _validateEducationalAccess() async {
    // In a real app, this would check user subscription, progress, prerequisites, etc.
    Log.debug(
      'EducationalContentSecurityProxy: Validating educational access requirements',
    );

    // Mock validation logic
    if (requiredSubscriptionLevel != null) {
      // Check subscription level
      Log.debug(
        'EducationalContentSecurityProxy: Checking subscription level: $requiredSubscriptionLevel',
      );
    }

    // Validate pattern prerequisites
    if (patternName.contains('Advanced') && !await _hasPrerequisites()) {
      return Left(
        ValidationFailure(
          message: 'Prerequisites not met for advanced pattern: $patternName',
        ),
      );
    }

    return const Right(true);
  }

  Future<bool> _hasPrerequisites() async {
    // Mock prerequisite check
    // In real app, check user's completed patterns
    return true;
  }
}

/// Game Progress Security Proxy
/// Tower Defense Context: Protects game progress save/load operations
class GameProgressSecurityProxy<T> extends SecurityProxy<T> {
  const GameProgressSecurityProxy({
    required super.realResource,
    required super.validator,
    required this.userId,
    required this.operation,
  });

  final String userId;
  final String operation;

  @override
  Future<Either<Failure, T>> accessResource() async {
    Log.debug('GameProgressSecurityProxy: $operation for user $userId');

    // Validate user ownership
    final ownershipValidation = await _validateUserOwnership();
    if (ownershipValidation.isLeft()) {
      return Left(
        ownershipValidation.fold((l) => l, (r) => throw 'Unreachable'),
      );
    }

    // Rate limiting for save operations
    if (operation.contains('save')) {
      final rateLimitValidation = await _checkRateLimit();
      if (rateLimitValidation.isLeft()) {
        return Left(
          rateLimitValidation.fold((l) => l, (r) => throw 'Unreachable'),
        );
      }
    }

    return super.accessResource();
  }

  Future<Either<Failure, bool>> _validateUserOwnership() async {
    // In real app, validate that the user owns this game progress
    Log.debug(
      'GameProgressSecurityProxy: Validating user ownership for $userId',
    );

    // Mock validation
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'Invalid user ID'));
    }

    return const Right(true);
  }

  Future<Either<Failure, bool>> _checkRateLimit() async {
    // Mock rate limiting - in real app, check against time-based limits
    Log.debug(
      'GameProgressSecurityProxy: Checking rate limits for save operations',
    );

    // Allow for now, but could implement sophisticated rate limiting
    return const Right(true);
  }
}

/// User Profile Security Proxy
/// Tower Defense Context: Protects user profile operations
class UserProfileSecurityProxy<T> extends SecurityProxy<T> {
  const UserProfileSecurityProxy({
    required super.realResource,
    required super.validator,
    required this.targetUserId,
    required this.requestingUserId,
    required this.operation,
  });

  final String targetUserId;
  final String requestingUserId;
  final String operation;

  @override
  Future<Either<Failure, T>> accessResource() async {
    Log.debug(
      'UserProfileSecurityProxy: $operation on profile $targetUserId by user $requestingUserId',
    );

    // Validate permissions
    final permissionValidation = await _validateUserPermissions();
    if (permissionValidation.isLeft()) {
      return Left(
        permissionValidation.fold((l) => l, (r) => throw 'Unreachable'),
      );
    }

    return super.accessResource();
  }

  Future<Either<Failure, bool>> _validateUserPermissions() async {
    Log.debug('UserProfileSecurityProxy: Validating permissions');

    // Users can only access their own profiles for write operations
    if (_isWriteOperation() && targetUserId != requestingUserId) {
      return Left(
        SecurityFailure(
          message: 'Access denied - cannot modify other user profiles',
        ),
      );
    }

    // Read operations might be more permissive (e.g., public profiles)
    if (_isReadOperation()) {
      // In real app, check privacy settings
      return const Right(true);
    }

    // Admin operations would require admin privileges
    if (_isAdminOperation()) {
      // Check admin permissions
      return await _checkAdminPrivileges();
    }

    return const Right(true);
  }

  bool _isWriteOperation() {
    return operation.contains('update') ||
        operation.contains('delete') ||
        operation.contains('create');
  }

  bool _isReadOperation() {
    return operation.contains('read') ||
        operation.contains('get') ||
        operation.contains('fetch');
  }

  bool _isAdminOperation() {
    return operation.contains('admin') ||
        operation.contains('moderate') ||
        operation.contains('ban');
  }

  Future<Either<Failure, bool>> _checkAdminPrivileges() async {
    // Mock admin check
    Log.debug(
      'UserProfileSecurityProxy: Checking admin privileges for $requestingUserId',
    );

    // In real app, check against admin role/permissions
    return const Right(false); // Default to no admin access
  }
}

/// Security Proxy Factory
/// Tower Defense Context: Factory for creating preconfigured security proxies
class SecurityProxyFactory {
  static final FirebaseAppCheckService _appCheckService =
      FirebaseAppCheckService.instance;

  /// Create educational content proxy
  static EducationalContentSecurityProxy<T> createEducationalProxy<T>({
    required ProtectedResource<T> resource,
    required String patternName,
    required String contentType,
    String? subscriptionLevel,
    bool requireValidToken = true,
  }) {
    final validator = AppCheckSecurityValidator(
      appCheckService: _appCheckService,
      requireValidToken: requireValidToken,
    );

    return EducationalContentSecurityProxy<T>(
      realResource: resource,
      validator: validator,
      patternName: patternName,
      contentType: contentType,
      requiredSubscriptionLevel: subscriptionLevel,
    );
  }

  /// Create game progress proxy
  static GameProgressSecurityProxy<T> createGameProgressProxy<T>({
    required ProtectedResource<T> resource,
    required String userId,
    required String operation,
    bool requireValidToken = true,
  }) {
    final validator = AppCheckSecurityValidator(
      appCheckService: _appCheckService,
      requireValidToken: requireValidToken,
    );

    return GameProgressSecurityProxy<T>(
      realResource: resource,
      validator: validator,
      userId: userId,
      operation: operation,
    );
  }

  /// Create user profile proxy
  static UserProfileSecurityProxy<T> createUserProfileProxy<T>({
    required ProtectedResource<T> resource,
    required String targetUserId,
    required String requestingUserId,
    required String operation,
    bool requireValidToken = true,
  }) {
    final validator = AppCheckSecurityValidator(
      appCheckService: _appCheckService,
      requireValidToken: requireValidToken,
    );

    return UserProfileSecurityProxy<T>(
      realResource: resource,
      validator: validator,
      targetUserId: targetUserId,
      requestingUserId: requestingUserId,
      operation: operation,
    );
  }
}

/// Concrete Resource Implementation
/// Helper for wrapping any operation as a ProtectedResource
class ResourceWrapper<T> implements ProtectedResource<T> {
  const ResourceWrapper(this.operation);

  final Future<Either<Failure, T>> Function() operation;

  @override
  Future<Either<Failure, T>> accessResource() => operation();
}

/// Tower Defense Security Helper
/// Convenience methods for common Tower Defense security scenarios
class TowerDefenseSecurityHelper {
  /// Secure pattern content access
  static Future<Either<Failure, T>> securePatternAccess<T>({
    required String patternName,
    required Future<Either<Failure, T>> Function() contentLoader,
  }) async {
    final resource = ResourceWrapper<T>(contentLoader);
    final secureProxy = SecurityProxyFactory.createEducationalProxy<T>(
      resource: resource,
      patternName: patternName,
      contentType: 'pattern_content',
    );

    return secureProxy.accessResource();
  }

  /// Secure game progress save
  static Future<Either<Failure, void>> secureProgressSave({
    required String userId,
    required Future<Either<Failure, void>> Function() saveOperation,
  }) async {
    final resource = ResourceWrapper<void>(saveOperation);
    final secureProxy = SecurityProxyFactory.createGameProgressProxy<void>(
      resource: resource,
      userId: userId,
      operation: 'save_progress',
    );

    return secureProxy.accessResource();
  }

  /// Secure profile update
  static Future<Either<Failure, T>> secureProfileUpdate<T>({
    required String userId,
    required Future<Either<Failure, T>> Function() updateOperation,
  }) async {
    final resource = ResourceWrapper<T>(updateOperation);
    final secureProxy = SecurityProxyFactory.createUserProfileProxy<T>(
      resource: resource,
      targetUserId: userId,
      requestingUserId: userId, // Self-update
      operation: 'update_profile',
    );

    return secureProxy.accessResource();
  }
}
