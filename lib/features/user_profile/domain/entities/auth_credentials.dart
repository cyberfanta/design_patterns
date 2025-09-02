/// Authentication Credentials Entity - Clean Architecture Domain Layer
///
/// PATTERN: Value Object - Immutable authentication credentials
/// WHERE: Domain layer for authentication data management
/// HOW: Secure credential handling with validation
/// WHY: Encapsulates authentication logic and ensures security
library;

import 'package:equatable/equatable.dart';

/// Represents authentication credentials for different login methods
///
/// Used in the Tower Defense app for handling various authentication
/// providers like email/password, Google, and Apple sign-in.
class AuthCredentials extends Equatable {
  /// Authentication provider type
  final AuthProviderType providerType;

  /// Email address (for email/password and OAuth)
  final String? email;

  /// Password (only for email/password authentication)
  final String? password;

  /// OAuth access token (for Google/Apple)
  final String? accessToken;

  /// OAuth ID token (for Google/Apple)
  final String? idToken;

  /// Provider-specific user ID
  final String? providerId;

  /// Display name from OAuth provider
  final String? displayName;

  /// Photo URL from OAuth provider
  final String? photoUrl;

  /// Keep user logged in preference
  final bool keepLoggedIn;

  /// Additional provider-specific data
  final Map<String, dynamic>? additionalData;

  const AuthCredentials({
    required this.providerType,
    this.email,
    this.password,
    this.accessToken,
    this.idToken,
    this.providerId,
    this.displayName,
    this.photoUrl,
    this.keepLoggedIn = false,
    this.additionalData,
  });

  /// Create email/password credentials
  factory AuthCredentials.emailPassword({
    required String email,
    required String password,
    bool keepLoggedIn = false,
  }) {
    return AuthCredentials(
      providerType: AuthProviderType.email,
      email: email,
      password: password,
      keepLoggedIn: keepLoggedIn,
    );
  }

  /// Create Google OAuth credentials
  factory AuthCredentials.google({
    required String accessToken,
    required String idToken,
    String? email,
    String? displayName,
    String? photoUrl,
    bool keepLoggedIn = false,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthCredentials(
      providerType: AuthProviderType.google,
      accessToken: accessToken,
      idToken: idToken,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      keepLoggedIn: keepLoggedIn,
      additionalData: additionalData,
    );
  }

  /// Create Apple OAuth credentials
  factory AuthCredentials.apple({
    required String idToken,
    String? email,
    String? displayName,
    bool keepLoggedIn = false,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthCredentials(
      providerType: AuthProviderType.apple,
      idToken: idToken,
      email: email,
      displayName: displayName,
      keepLoggedIn: keepLoggedIn,
      additionalData: additionalData,
    );
  }

  /// Validate credentials based on provider type
  bool get isValid {
    switch (providerType) {
      case AuthProviderType.email:
        return email != null &&
            email!.isNotEmpty &&
            email!.contains('@') &&
            password != null &&
            password!.length >= 6;

      case AuthProviderType.google:
        return accessToken != null &&
            accessToken!.isNotEmpty &&
            idToken != null &&
            idToken!.isNotEmpty;

      case AuthProviderType.apple:
        return idToken != null && idToken!.isNotEmpty;
    }
  }

  /// Check if this is a password-based authentication
  bool get isPasswordAuth => providerType == AuthProviderType.email;

  /// Check if this is OAuth-based authentication
  bool get isOAuthAuth =>
      providerType == AuthProviderType.google ||
      providerType == AuthProviderType.apple;

  /// Get provider identifier string
  String get providerIdentifier {
    switch (providerType) {
      case AuthProviderType.email:
        return 'password';
      case AuthProviderType.google:
        return 'google.com';
      case AuthProviderType.apple:
        return 'apple.com';
    }
  }

  /// Get display name for the authentication method
  String get providerDisplayName {
    switch (providerType) {
      case AuthProviderType.email:
        return 'Email & Password';
      case AuthProviderType.google:
        return 'Google';
      case AuthProviderType.apple:
        return 'Apple';
    }
  }

  /// Sanitize credentials for logging (remove sensitive data)
  AuthCredentials sanitizeForLogging() {
    return AuthCredentials(
      providerType: providerType,
      email: email,
      password: password != null ? '***REDACTED***' : null,
      accessToken: accessToken != null ? '***REDACTED***' : null,
      idToken: idToken != null ? '***REDACTED***' : null,
      providerId: providerId,
      displayName: displayName,
      photoUrl: photoUrl,
      keepLoggedIn: keepLoggedIn,
      additionalData: additionalData != null
          ? {'keys': additionalData!.keys.toList()}
          : null,
    );
  }

  /// Create copy with modified properties
  AuthCredentials copyWith({
    AuthProviderType? providerType,
    String? email,
    String? password,
    String? accessToken,
    String? idToken,
    String? providerId,
    String? displayName,
    String? photoUrl,
    bool? keepLoggedIn,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthCredentials(
      providerType: providerType ?? this.providerType,
      email: email ?? this.email,
      password: password ?? this.password,
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
      providerId: providerId ?? this.providerId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      keepLoggedIn: keepLoggedIn ?? this.keepLoggedIn,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  List<Object?> get props => [
    providerType,
    email,
    password,
    accessToken,
    idToken,
    providerId,
    displayName,
    photoUrl,
    keepLoggedIn,
    additionalData,
  ];

  @override
  String toString() =>
      'AuthCredentials(provider: $providerDisplayName, '
      'email: $email, keepLoggedIn: $keepLoggedIn)';
}

/// Authentication provider types supported by the app
enum AuthProviderType {
  /// Email and password authentication
  email,

  /// Google OAuth authentication
  google,

  /// Apple OAuth authentication
  apple,
}

/// Extension for AuthProviderType enum
extension AuthProviderTypeExtension on AuthProviderType {
  /// Get the provider identifier string
  String get identifier {
    switch (this) {
      case AuthProviderType.email:
        return 'password';
      case AuthProviderType.google:
        return 'google.com';
      case AuthProviderType.apple:
        return 'apple.com';
    }
  }

  /// Get the display name
  String get displayName {
    switch (this) {
      case AuthProviderType.email:
        return 'Email & Password';
      case AuthProviderType.google:
        return 'Google';
      case AuthProviderType.apple:
        return 'Apple';
    }
  }

  /// Check if provider requires password
  bool get requiresPassword => this == AuthProviderType.email;

  /// Check if provider uses OAuth
  bool get isOAuth =>
      this == AuthProviderType.google || this == AuthProviderType.apple;
}
