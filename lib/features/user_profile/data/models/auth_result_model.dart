/// Authentication Result Data Model
///
/// PATTERN: Data Transfer Object (DTO) - Represents authentication result data
/// WHERE: Data layer model extending domain entity
/// HOW: Adds Firebase-specific authentication result handling
/// WHY: Handles platform-specific authentication responses and errors
library;

import 'package:design_patterns/features/user_profile/data/models/user_profile_model.dart';
import 'package:design_patterns/features/user_profile/domain/entities/auth_result.dart';
import 'package:design_patterns/features/user_profile/domain/entities/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Data model for AuthResult with Firebase-specific extensions
///
/// PATTERN: Data Transfer Object - Firebase authentication result mapping
///
/// In Tower Defense context, this model handles authentication
/// results from Firebase Auth, including user profile creation
/// and error handling for various authentication scenarios.
class AuthResultModel extends AuthResult {
  /// Firebase user credential for additional operations
  final UserCredential? firebaseCredential;

  /// Firebase auth exception details
  final FirebaseAuthException? firebaseException;

  /// Authentication metadata
  final Map<String, dynamic>? metadata;

  AuthResultModel({
    required super.isSuccess,
    super.userProfile,
    super.errorMessage,
    super.errorCode,
    super.isNewUser,
    super.timestamp,
    super.additionalData,
    this.firebaseCredential,
    this.firebaseException,
    this.metadata,
  });

  /// Create from domain entity
  factory AuthResultModel.fromEntity(AuthResult entity) {
    if (entity is AuthResultModel) {
      return entity;
    }

    return AuthResultModel(
      isSuccess: entity.isSuccess,
      userProfile: entity.userProfile,
      errorMessage: entity.errorMessage,
      errorCode: entity.errorCode,
    );
  }

  /// Create successful result from Firebase UserCredential
  factory AuthResultModel.success({
    required UserCredential credential,
    UserProfile? userProfile,
    Map<String, dynamic>? metadata,
  }) {
    return AuthResultModel(
      isSuccess: true,
      userProfile: userProfile,
      firebaseCredential: credential,
      metadata: metadata,
    );
  }

  /// Create failure result from Firebase exception
  factory AuthResultModel.failure({
    required FirebaseAuthException exception,
    String? customMessage,
    Map<String, dynamic>? metadata,
  }) {
    return AuthResultModel(
      isSuccess: false,
      errorMessage: customMessage ?? _getErrorMessage(exception),
      errorCode: exception.code,
      firebaseException: exception,
      metadata: metadata,
    );
  }

  /// Create failure result from general error
  factory AuthResultModel.error({
    required String message,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    return AuthResultModel(
      isSuccess: false,
      errorMessage: message,
      errorCode: errorCode ?? 'unknown-error',
      metadata: metadata,
    );
  }

  /// Create from Firebase UserCredential with profile data
  factory AuthResultModel.fromFirebaseUser({
    required UserCredential credential,
    required String authProvider,
    String? deviceModel,
    DateTime? acceptedTermsAt,
    DateTime? privacyConsentAt,
    String preferredLanguage = 'en',
    Map<String, dynamic>? metadata,
  }) {
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      return AuthResultModel.error(
        message: 'Firebase user is null after authentication',
        errorCode: 'null-user',
        metadata: metadata,
      );
    }

    final profile = UserProfileModel.forRegistration(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'User',
      authProvider: authProvider,
      firstName: firebaseUser.displayName?.split(' ').first,
      lastName: (firebaseUser.displayName?.split(' ').length ?? 0) > 1
          ? firebaseUser.displayName!.split(' ').skip(1).join(' ')
          : null,
      photoUrl: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      deviceModel: deviceModel,
      acceptedTermsAt: acceptedTermsAt ?? DateTime.now(),
      privacyConsentAt: privacyConsentAt ?? DateTime.now(),
      preferredLanguage: preferredLanguage,
    );

    return AuthResultModel.success(
      credential: credential,
      userProfile: profile.toEntity(),
      metadata: metadata,
    );
  }

  /// Get Firebase user if available
  User? get firebaseUser => firebaseCredential?.user;

  /// Get Firebase user ID if available
  String? get firebaseUserId => firebaseUser?.uid;

  /// Check if this is a new user registration
  @override
  bool get isNewUser {
    return firebaseCredential?.additionalUserInfo?.isNewUser ?? false;
  }

  /// Get authentication provider ID
  String? get providerId {
    return firebaseCredential?.additionalUserInfo?.providerId;
  }

  /// Get additional user info from Firebase
  Map<String, dynamic>? get additionalUserInfo {
    final info = firebaseCredential?.additionalUserInfo;
    if (info == null) return null;

    return {
      'is_new_user': info.isNewUser,
      'provider_id': info.providerId,
      'username': info.username,
      'profile': info.profile,
    };
  }

  /// Convert to JSON for logging or debugging
  Map<String, dynamic> toJson({bool includeUserProfile = false}) {
    final json = <String, dynamic>{
      'is_success': isSuccess,
      'error_message': errorMessage,
      'error_code': errorCode,
      'is_new_user': isNewUser,
      'provider_id': providerId,
      'firebase_user_id': firebaseUserId,
      'metadata': metadata,
    };

    if (includeUserProfile && userProfile != null) {
      json['user_profile'] = (userProfile as UserProfileModel?)?.toJson();
    }

    if (firebaseException != null) {
      json['firebase_exception'] = {
        'code': firebaseException!.code,
        'message': firebaseException!.message,
        'plugin': firebaseException!.plugin,
      };
    }

    return json;
  }

  /// Create a copy with updated values
  @override
  AuthResultModel copyWith({
    bool? isSuccess,
    UserProfile? userProfile,
    String? errorMessage,
    String? errorCode,
    bool? isNewUser,
    DateTime? timestamp,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthResultModel(
      isSuccess: isSuccess ?? this.isSuccess,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      isNewUser: isNewUser ?? this.isNewUser,
      timestamp: timestamp ?? this.timestamp,
      additionalData: additionalData ?? this.additionalData,
      firebaseCredential: firebaseCredential,
      firebaseException: firebaseException,
      metadata: metadata,
    );
  }

  /// Get user-friendly error message from Firebase exception
  static String _getErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for this email address.';
      case 'wrong-password':
        return 'Wrong password provided for this user.';
      case 'invalid-credential':
        return 'The authentication credential is invalid.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication.';
      default:
        return exception.message ?? 'An authentication error occurred.';
    }
  }

  /// Check if error is recoverable
  @override
  bool get isRecoverableError {
    if (firebaseException == null) return false;

    const recoverableCodes = [
      'network-request-failed',
      'too-many-requests',
      'requires-recent-login',
    ];

    return recoverableCodes.contains(firebaseException!.code);
  }

  /// Check if error requires user action
  bool get requiresUserAction {
    if (firebaseException == null) return false;

    const actionRequiredCodes = [
      'weak-password',
      'invalid-email',
      'wrong-password',
      'invalid-verification-code',
      'account-exists-with-different-credential',
    ];

    return actionRequiredCodes.contains(firebaseException!.code);
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'AuthResultModel.success(userId: $firebaseUserId, '
          'isNewUser: $isNewUser, providerId: $providerId)';
    } else {
      return 'AuthResultModel.failure(code: $errorCode, '
          'message: $errorMessage)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthResultModel &&
        other.isSuccess == isSuccess &&
        other.errorMessage == errorMessage &&
        other.errorCode == errorCode &&
        other.firebaseUserId == firebaseUserId;
  }

  @override
  int get hashCode {
    return Object.hash(isSuccess, errorMessage, errorCode, firebaseUserId);
  }
}
