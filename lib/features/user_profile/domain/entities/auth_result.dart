/// Authentication Result Entity - Clean Architecture Domain Layer
///
/// PATTERN: Value Object - Immutable authentication result
/// WHERE: Domain layer for authentication response data
/// HOW: Encapsulates authentication operation results
/// WHY: Provides consistent authentication response structure
library;

import 'package:design_patterns/features/user_profile/domain/entities/user_profile.dart';
import 'package:equatable/equatable.dart';

/// Represents the result of an authentication operation
///
/// Used throughout the Tower Defense app to handle authentication
/// responses from various providers (email, Google, Apple).
class AuthResult extends Equatable {
  /// Whether the authentication was successful
  final bool isSuccess;

  /// User profile data (if authentication succeeded)
  final UserProfile? userProfile;

  /// Error message (if authentication failed)
  final String? errorMessage;

  /// Error code for programmatic handling
  final String? errorCode;

  /// Whether this is a new user (first time signing in)
  final bool isNewUser;

  /// Additional authentication data
  final Map<String, dynamic>? additionalData;

  /// Timestamp of the authentication attempt
  final DateTime timestamp;

  AuthResult({
    required this.isSuccess,
    this.userProfile,
    this.errorMessage,
    this.errorCode,
    this.isNewUser = false,
    this.additionalData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create successful authentication result
  factory AuthResult.success({
    required UserProfile userProfile,
    bool isNewUser = false,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthResult(
      isSuccess: true,
      userProfile: userProfile,
      isNewUser: isNewUser,
      additionalData: additionalData,
      timestamp: DateTime.now(),
    );
  }

  /// Create failed authentication result
  factory AuthResult.failure({
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
      additionalData: additionalData,
      timestamp: DateTime.now(),
    );
  }

  /// Common authentication error results
  static AuthResult get invalidCredentials => AuthResult.failure(
    errorMessage: 'Invalid email or password',
    errorCode: 'invalid-credentials',
  );

  static AuthResult get userNotFound => AuthResult.failure(
    errorMessage: 'No user found with this email',
    errorCode: 'user-not-found',
  );

  static AuthResult get userDisabled => AuthResult.failure(
    errorMessage: 'This account has been disabled',
    errorCode: 'user-disabled',
  );

  static AuthResult get emailAlreadyInUse => AuthResult.failure(
    errorMessage: 'An account already exists with this email',
    errorCode: 'email-already-in-use',
  );

  static AuthResult get weakPassword => AuthResult.failure(
    errorMessage: 'Password should be at least 6 characters',
    errorCode: 'weak-password',
  );

  static AuthResult get operationNotAllowed => AuthResult.failure(
    errorMessage: 'This sign-in method is not enabled',
    errorCode: 'operation-not-allowed',
  );

  static AuthResult get networkError => AuthResult.failure(
    errorMessage: 'Network error. Please check your connection',
    errorCode: 'network-error',
  );

  static AuthResult get unknownError => AuthResult.failure(
    errorMessage: 'An unknown error occurred',
    errorCode: 'unknown-error',
  );

  /// Check if the result indicates a specific error
  bool hasErrorCode(String code) => errorCode == code;

  /// Get user-friendly error message
  String get friendlyErrorMessage {
    if (isSuccess) return 'Authentication successful';

    switch (errorCode) {
      case 'invalid-credentials':
      case 'wrong-password':
        return 'Incorrect email or password. Please try again.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'user-disabled':
        return 'This account has been temporarily disabled.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters long.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'This sign-in method is currently disabled.';
      case 'network-error':
        return 'Please check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return errorMessage ?? 'An unexpected error occurred.';
    }
  }

  /// Check if error is recoverable by user action
  bool get isRecoverableError {
    if (isSuccess) return false;

    const recoverableErrors = [
      'invalid-credentials',
      'wrong-password',
      'weak-password',
      'invalid-email',
      'network-error',
    ];

    return errorCode != null && recoverableErrors.contains(errorCode);
  }

  /// Check if error requires user to contact support
  bool get requiresSupport {
    if (isSuccess) return false;

    const supportErrors = [
      'user-disabled',
      'operation-not-allowed',
      'internal-error',
    ];

    return errorCode != null && supportErrors.contains(errorCode);
  }

  /// Create copy with modified properties
  AuthResult copyWith({
    bool? isSuccess,
    UserProfile? userProfile,
    String? errorMessage,
    String? errorCode,
    bool? isNewUser,
    Map<String, dynamic>? additionalData,
    DateTime? timestamp,
  }) {
    return AuthResult(
      isSuccess: isSuccess ?? this.isSuccess,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      isNewUser: isNewUser ?? this.isNewUser,
      additionalData: additionalData ?? this.additionalData,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convert to analytics-safe data
  Map<String, dynamic> toAnalyticsData() {
    return {
      'is_success': isSuccess,
      'error_code': errorCode,
      'is_new_user': isNewUser,
      'provider': userProfile?.authProvider,
      'timestamp': timestamp.toIso8601String(),
      'has_additional_data': additionalData != null,
    };
  }

  @override
  List<Object?> get props => [
    isSuccess,
    userProfile,
    errorMessage,
    errorCode,
    isNewUser,
    additionalData,
    timestamp,
  ];

  @override
  String toString() {
    if (isSuccess) {
      return 'AuthResult.success(user: ${userProfile?.email}, newUser: $isNewUser)';
    } else {
      return 'AuthResult.failure(error: $errorCode, message: $errorMessage)';
    }
  }
}
