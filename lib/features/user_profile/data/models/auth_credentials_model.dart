/// Authentication Credentials Data Model
///
/// PATTERN: Data Transfer Object (DTO) - Represents authentication data
/// WHERE: Data layer model extending domain entity
/// HOW: Adds Firebase-specific authentication data handling
/// WHY: Handles platform-specific authentication details
library;

import 'package:design_patterns/features/user_profile/domain/entities/auth_credentials.dart';

/// Data model for AuthCredentials with platform-specific extensions
///
/// PATTERN: Data Transfer Object - Platform authentication mapping
///
/// In Tower Defense context, this model handles authentication
/// credentials for different providers (email/password, Google, Apple)
/// with platform-specific data and validation.
class AuthCredentialsModel extends AuthCredentials {
  /// Device information for security tracking
  final String? deviceId;
  final String? deviceModel;
  final String? deviceOS;

  /// Authorization code (for Apple sign-in)
  final String? authorizationCode;

  const AuthCredentialsModel({
    required super.providerType,
    super.email,
    super.password,
    super.accessToken,
    super.idToken,
    super.providerId,
    super.displayName,
    super.photoUrl,
    super.keepLoggedIn,
    super.additionalData,
    this.deviceId,
    this.deviceModel,
    this.deviceOS,
    this.authorizationCode,
  });

  /// Create from domain entity
  factory AuthCredentialsModel.fromEntity(AuthCredentials entity) {
    if (entity is AuthCredentialsModel) {
      return entity;
    }

    return AuthCredentialsModel(
      providerType: entity.providerType,
      email: entity.email,
      password: entity.password,
      accessToken: entity.accessToken,
      idToken: entity.idToken,
      providerId: entity.providerId,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      keepLoggedIn: entity.keepLoggedIn,
      additionalData: entity.additionalData,
    );
  }

  /// Create from JSON data
  factory AuthCredentialsModel.fromJson(Map<String, dynamic> json) {
    return AuthCredentialsModel(
      providerType: AuthProviderType.values.firstWhere(
        (p) => p.name == (json['provider'] as String? ?? 'email'),
        orElse: () => AuthProviderType.email,
      ),
      email: json['email'] as String?,
      password: json['password'] as String?,
      accessToken: json['access_token'] as String?,
      idToken: json['id_token'] as String?,
      providerId: json['provider_id'] as String?,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      keepLoggedIn: json['keep_logged_in'] as bool? ?? false,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
      deviceId: json['device_id'] as String?,
      deviceModel: json['device_model'] as String?,
      deviceOS: json['device_os'] as String?,
      authorizationCode: json['authorization_code'] as String?,
    );
  }

  /// Convert to JSON (excluding sensitive data)
  Map<String, dynamic> toJson({bool includeSensitive = false}) {
    final json = <String, dynamic>{
      'provider': providerType.name,
      'email': email,
      'provider_id': providerId,
      'display_name': displayName,
      'photo_url': photoUrl,
      'keep_logged_in': keepLoggedIn,
      'device_id': deviceId,
      'device_model': deviceModel,
      'device_os': deviceOS,
    };

    // Only include sensitive data if explicitly requested
    if (includeSensitive) {
      json.addAll({
        'id_token': idToken,
        'access_token': accessToken,
        'authorization_code': authorizationCode,
        'additional_data': additionalData,
        // Never include password in JSON
      });
    }

    return json;
  }

  /// Create email/password credentials
  factory AuthCredentialsModel.emailPassword({
    required String email,
    required String password,
    String? displayName,
    String? deviceId,
    String? deviceModel,
    String? deviceOS,
  }) {
    return AuthCredentialsModel(
      providerType: AuthProviderType.email,
      email: email,
      password: password,
      displayName: displayName,
      deviceId: deviceId,
      deviceModel: deviceModel,
      deviceOS: deviceOS,
    );
  }

  /// Create Google credentials
  factory AuthCredentialsModel.google({
    required String idToken,
    required String accessToken,
    String? email,
    String? displayName,
    String? photoUrl,
    String? deviceId,
    String? deviceModel,
    String? deviceOS,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthCredentialsModel(
      providerType: AuthProviderType.google,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      idToken: idToken,
      accessToken: accessToken,
      deviceId: deviceId,
      deviceModel: deviceModel,
      deviceOS: deviceOS,
      additionalData: additionalData,
    );
  }

  /// Create Apple credentials
  factory AuthCredentialsModel.apple({
    required String idToken,
    required String authorizationCode,
    String? email,
    String? displayName,
    String? deviceId,
    String? deviceModel,
    String? deviceOS,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthCredentialsModel(
      providerType: AuthProviderType.apple,
      email: email,
      displayName: displayName,
      idToken: idToken,
      authorizationCode: authorizationCode,
      deviceId: deviceId,
      deviceModel: deviceModel,
      deviceOS: deviceOS,
      additionalData: additionalData,
    );
  }

  /// Create anonymous credentials
  factory AuthCredentialsModel.anonymous({
    String? deviceId,
    String? deviceModel,
    String? deviceOS,
  }) {
    return AuthCredentialsModel(
      providerType: AuthProviderType.email,
      // Anonymous is handled as email type
      deviceId: deviceId,
      deviceModel: deviceModel,
      deviceOS: deviceOS,
    );
  }

  /// Validate credentials based on provider
  @override
  bool get isValid {
    switch (providerType) {
      case AuthProviderType.email:
        return email != null &&
            email!.isNotEmpty &&
            password != null &&
            password!.isNotEmpty &&
            email!.contains('@');

      case AuthProviderType.google:
        return idToken != null &&
            idToken!.isNotEmpty &&
            accessToken != null &&
            accessToken!.isNotEmpty;

      case AuthProviderType.apple:
        return idToken != null &&
            idToken!.isNotEmpty &&
            authorizationCode != null &&
            authorizationCode!.isNotEmpty;

      // Note: Anonymous is handled as email type
      // Anonymous authentication doesn't require credentials validation
    }
  }

  /// Get device information as a map
  Map<String, String?> get deviceInfo {
    return {
      'device_id': deviceId,
      'device_model': deviceModel,
      'device_os': deviceOS,
    };
  }

  /// Get safe display information (no sensitive data)
  Map<String, dynamic> get displayInfo {
    return {
      'provider': providerDisplayName,
      'email': email,
      'display_name': displayName,
      'has_photo': photoUrl != null && photoUrl!.isNotEmpty,
      'device_model': deviceModel,
      'device_os': deviceOS,
    };
  }

  /// Create a sanitized copy without sensitive data
  AuthCredentialsModel sanitized() {
    return AuthCredentialsModel(
      providerType: providerType,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      deviceId: deviceId,
      deviceModel: deviceModel,
      deviceOS: deviceOS,
      // Exclude sensitive tokens and passwords
    );
  }

  /// Copy with new values
  @override
  AuthCredentialsModel copyWith({
    AuthProviderType? providerType,
    String? email,
    String? password,
    String? displayName,
    String? photoUrl,
    String? idToken,
    String? accessToken,
    String? providerId,
    bool? keepLoggedIn,
    String? authorizationCode,
    Map<String, dynamic>? additionalData,
    String? deviceId,
    String? deviceModel,
    String? deviceOS,
  }) {
    return AuthCredentialsModel(
      providerType: providerType ?? this.providerType,
      email: email ?? this.email,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      idToken: idToken ?? this.idToken,
      accessToken: accessToken ?? this.accessToken,
      providerId: providerId ?? this.providerId,
      keepLoggedIn: keepLoggedIn ?? this.keepLoggedIn,
      authorizationCode: authorizationCode ?? this.authorizationCode,
      additionalData: additionalData ?? this.additionalData,
      deviceId: deviceId ?? this.deviceId,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceOS: deviceOS ?? this.deviceOS,
    );
  }

  @override
  String toString() {
    return 'AuthCredentialsModel(providerType: ${providerType.name}, '
        'email: $email, displayName: $displayName, '
        'deviceModel: $deviceModel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthCredentialsModel &&
        other.providerType == providerType &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.deviceId == deviceId &&
        other.deviceModel == deviceModel &&
        other.deviceOS == deviceOS;
  }

  @override
  int get hashCode {
    return Object.hash(
      providerType,
      email,
      displayName,
      photoUrl,
      deviceId,
      deviceModel,
      deviceOS,
    );
  }
}
