/// User Profile Entity - Clean Architecture Domain Layer
///
/// PATTERN: Value Object - Immutable user profile representation
/// WHERE: Domain layer for user profile management
/// HOW: Immutable class with validation and business rules
/// WHY: Ensures user profile integrity and encapsulates business logic
library;

import 'package:equatable/equatable.dart';

/// Profile visibility options
enum ProfileVisibility { public, friendsOnly, private }

/// Account status options
enum AccountStatus { active, suspended, pendingDeletion, anonymized }

/// Represents a complete user profile in the Tower Defense app
///
/// This entity encapsulates all user-related data including personal
/// information, preferences, authentication details, and game progress.
/// Follows GDPR compliance requirements for data management.
class UserProfile extends Equatable {
  /// Unique user identifier from Firebase Auth
  final String uid;

  /// User's email address (required for authentication)
  final String email;

  /// Display name (full name)
  final String? displayName;

  /// First name
  final String? firstName;

  /// Last name
  final String? lastName;

  /// Profile photo URL (from Firebase Storage)
  final String? photoUrl;

  /// Phone number (optional)
  final String? phoneNumber;

  /// Device information for analytics
  final String? deviceModel;

  /// Authentication provider used (email, google, apple)
  final String authProvider;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Last profile update timestamp
  final DateTime lastUpdated;

  /// Last login timestamp
  final DateTime? lastLogin;

  /// Keep user logged in preference
  final bool keepLoggedIn;

  /// Terms and conditions acceptance
  final bool acceptedTerms;

  /// Privacy policy acceptance
  final DateTime? privacyPolicyAcceptedAt;

  /// Marketing emails consent
  final bool marketingConsent;

  /// Analytics data collection consent
  final bool analyticsConsent;

  /// Account status (active, suspended, deleted)
  final String accountStatus;

  /// User's language preference
  final String preferredLanguage;

  /// User's timezone
  final String? timezone;

  /// Game-related data
  final int gameLevel;
  final int experiencePoints;
  final int gamesPlayed;
  final int gamesWon;
  final double winRate;

  /// Profile completion percentage
  final double profileCompleteness;

  const UserProfile._private({
    required this.uid,
    required this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.photoUrl,
    this.phoneNumber,
    this.deviceModel,
    this.authProvider = 'email',
    required this.createdAt,
    required this.lastUpdated,
    this.lastLogin,
    this.keepLoggedIn = false,
    this.acceptedTerms = false,
    this.privacyPolicyAcceptedAt,
    this.marketingConsent = false,
    this.analyticsConsent = false,
    this.accountStatus = 'active',
    this.preferredLanguage = 'en',
    this.timezone,
    this.gameLevel = 1,
    this.experiencePoints = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.winRate = 0.0,
    this.profileCompleteness = 0.0,
  });

  factory UserProfile({
    required String uid,
    required String email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phoneNumber,
    String? deviceModel,
    String authProvider = 'email',
    DateTime? createdAt,
    DateTime? lastUpdated,
    DateTime? lastLogin,
    bool keepLoggedIn = false,
    bool acceptedTerms = false,
    DateTime? privacyPolicyAcceptedAt,
    bool marketingConsent = false,
    bool analyticsConsent = false,
    String accountStatus = 'active',
    String preferredLanguage = 'en',
    String? timezone,
    int gameLevel = 1,
    int experiencePoints = 0,
    int gamesPlayed = 0,
    int gamesWon = 0,
    double winRate = 0.0,
    double profileCompleteness = 0.0,
  }) {
    return UserProfile._private(
      uid: uid,
      email: email,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      deviceModel: deviceModel,
      authProvider: authProvider,
      createdAt: createdAt ?? DateTime.now(),
      lastUpdated: lastUpdated ?? DateTime.now(),
      lastLogin: lastLogin,
      keepLoggedIn: keepLoggedIn,
      acceptedTerms: acceptedTerms,
      privacyPolicyAcceptedAt: privacyPolicyAcceptedAt,
      marketingConsent: marketingConsent,
      analyticsConsent: analyticsConsent,
      accountStatus: accountStatus,
      preferredLanguage: preferredLanguage,
      timezone: timezone,
      gameLevel: gameLevel,
      experiencePoints: experiencePoints,
      gamesPlayed: gamesPlayed,
      gamesWon: gamesWon,
      winRate: winRate,
      profileCompleteness: profileCompleteness,
    );
  }

  /// Supported authentication providers
  static const List<String> supportedAuthProviders = [
    'email',
    'google.com',
    'apple.com',
  ];

  /// Valid account statuses
  static const List<String> validAccountStatuses = [
    'active',
    'suspended',
    'pending_deletion',
    'deleted',
  ];

  /// Check if profile is valid
  bool get isValid {
    return uid.isNotEmpty &&
        email.isNotEmpty &&
        email.contains('@') &&
        supportedAuthProviders.contains(authProvider) &&
        validAccountStatuses.contains(accountStatus) &&
        acceptedTerms &&
        privacyPolicyAcceptedAt != null &&
        winRate >= 0.0 &&
        winRate <= 1.0 &&
        profileCompleteness >= 0.0 &&
        profileCompleteness <= 1.0;
  }

  /// Check if profile is complete
  bool get isComplete => profileCompleteness >= 0.8;

  /// Check if user is active
  bool get isActive => accountStatus == 'active';

  /// Get full name
  String get fullName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }

    final first = firstName ?? '';
    final last = lastName ?? '';

    if (first.isNotEmpty && last.isNotEmpty) {
      return '$first $last';
    } else if (first.isNotEmpty) {
      return first;
    } else if (last.isNotEmpty) {
      return last;
    }

    return email.split('@').first; // Use email username as fallback
  }

  /// Get user initials for avatar
  String get initials {
    final name = fullName;
    final parts = name.split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }

    return 'U'; // Default
  }

  // Compatibility getters for models

  /// Alias for lastLogin (compatibility)
  DateTime? get lastSignInAt => lastLogin;

  /// Alias for createdAt (compatibility)
  DateTime get accountCreatedAt => createdAt;

  /// Alias for lastUpdated (compatibility)
  DateTime get lastUpdatedAt => lastUpdated;

  /// Email verification status (assumed verified if has login)
  bool get isEmailVerified => lastLogin != null;

  /// Alias for privacyPolicyAcceptedAt (compatibility)
  DateTime? get acceptedTermsAt => privacyPolicyAcceptedAt;

  /// Alias for privacyPolicyAcceptedAt (compatibility)
  DateTime? get privacyConsentAt => privacyPolicyAcceptedAt;

  /// Check if account is marked for deletion
  DateTime? get markedForDeletionAt =>
      accountStatus == 'pending_deletion' ? lastUpdated : null;

  /// Full name as field for compatibility
  String? get fullNameField => displayName;

  /// Get profile visibility as enum
  ProfileVisibility get profileVisibility {
    // Default to private for privacy
    return ProfileVisibility.private;
  }

  /// Get account status as enum
  AccountStatus get accountStatusEnum {
    switch (accountStatus) {
      case 'active':
        return AccountStatus.active;
      case 'suspended':
        return AccountStatus.suspended;
      case 'pending_deletion':
        return AccountStatus.pendingDeletion;
      case 'deleted':
        return AccountStatus.anonymized;
      default:
        return AccountStatus.active;
    }
  }

  /// Calculate win rate
  double calculateWinRate() {
    if (gamesPlayed == 0) return 0.0;
    return gamesWon / gamesPlayed;
  }

  /// Calculate profile completeness
  double calculateCompleteness() {
    int completedFields = 0;
    const totalFields = 10;

    if (email.isNotEmpty) completedFields++;
    if (displayName != null && displayName!.isNotEmpty) completedFields++;
    if (firstName != null && firstName!.isNotEmpty) completedFields++;
    if (lastName != null && lastName!.isNotEmpty) completedFields++;
    if (photoUrl != null && photoUrl!.isNotEmpty) completedFields++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) completedFields++;
    if (deviceModel != null && deviceModel!.isNotEmpty) completedFields++;
    if (timezone != null && timezone!.isNotEmpty) completedFields++;
    if (acceptedTerms) completedFields++;
    if (privacyPolicyAcceptedAt != null) completedFields++;

    return completedFields / totalFields;
  }

  /// Create copy with modified properties
  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phoneNumber,
    String? deviceModel,
    String? authProvider,
    DateTime? createdAt,
    DateTime? lastUpdated,
    DateTime? lastLogin,
    bool? keepLoggedIn,
    bool? acceptedTerms,
    DateTime? privacyPolicyAcceptedAt,
    bool? marketingConsent,
    bool? analyticsConsent,
    String? accountStatus,
    String? preferredLanguage,
    String? timezone,
    int? gameLevel,
    int? experiencePoints,
    int? gamesPlayed,
    int? gamesWon,
    double? winRate,
    double? profileCompleteness,
  }) {
    final updated = UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deviceModel: deviceModel ?? this.deviceModel,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
      lastLogin: lastLogin ?? this.lastLogin,
      keepLoggedIn: keepLoggedIn ?? this.keepLoggedIn,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      privacyPolicyAcceptedAt:
          privacyPolicyAcceptedAt ?? this.privacyPolicyAcceptedAt,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      analyticsConsent: analyticsConsent ?? this.analyticsConsent,
      accountStatus: accountStatus ?? this.accountStatus,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
      gameLevel: gameLevel ?? this.gameLevel,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      winRate: winRate ?? this.winRate,
      profileCompleteness: profileCompleteness ?? this.profileCompleteness,
    );

    // Recalculate completeness if not explicitly provided
    if (profileCompleteness == null) {
      return updated.copyWith(
        profileCompleteness: updated.calculateCompleteness(),
      );
    }

    return updated;
  }

  /// Update personal information
  UserProfile updatePersonalInfo({
    String? displayName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? timezone,
  }) {
    return copyWith(
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      timezone: timezone,
      lastUpdated: DateTime.now(),
    );
  }

  /// Update game progress
  UserProfile updateGameProgress({
    int? gameLevel,
    int? experiencePoints,
    int? gamesPlayed,
    int? gamesWon,
  }) {
    final newGamesPlayed = gamesPlayed ?? this.gamesPlayed;
    final newGamesWon = gamesWon ?? this.gamesWon;
    final newWinRate = newGamesPlayed > 0 ? newGamesWon / newGamesPlayed : 0.0;

    return copyWith(
      gameLevel: gameLevel,
      experiencePoints: experiencePoints,
      gamesPlayed: newGamesPlayed,
      gamesWon: newGamesWon,
      winRate: newWinRate,
      lastUpdated: DateTime.now(),
    );
  }

  /// Update consent preferences
  UserProfile updateConsents({
    bool? marketingConsent,
    bool? analyticsConsent,
    DateTime? privacyPolicyAcceptedAt,
  }) {
    return copyWith(
      marketingConsent: marketingConsent,
      analyticsConsent: analyticsConsent,
      privacyPolicyAcceptedAt: privacyPolicyAcceptedAt,
      lastUpdated: DateTime.now(),
    );
  }

  /// Mark profile for deletion (GDPR compliance)
  UserProfile markForDeletion() {
    return copyWith(
      accountStatus: 'pending_deletion',
      lastUpdated: DateTime.now(),
    );
  }

  /// Anonymize profile data (GDPR compliance)
  UserProfile anonymize() {
    return copyWith(
      displayName: 'Anonymous User',
      firstName: null,
      lastName: null,
      phoneNumber: null,
      photoUrl: null,
      deviceModel: null,
      timezone: null,
      accountStatus: 'deleted',
      lastUpdated: DateTime.now(),
    );
  }

  /// Get privacy-safe profile data for export
  Map<String, dynamic> getExportData() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'auth_provider': authProvider,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'preferred_language': preferredLanguage,
      'timezone': timezone,
      'game_level': gameLevel,
      'experience_points': experiencePoints,
      'games_played': gamesPlayed,
      'games_won': gamesWon,
      'win_rate': winRate,
      'marketing_consent': marketingConsent,
      'analytics_consent': analyticsConsent,
      'privacy_policy_accepted_at': privacyPolicyAcceptedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    firstName,
    lastName,
    photoUrl,
    phoneNumber,
    deviceModel,
    authProvider,
    createdAt,
    lastUpdated,
    lastLogin,
    keepLoggedIn,
    acceptedTerms,
    privacyPolicyAcceptedAt,
    marketingConsent,
    analyticsConsent,
    accountStatus,
    preferredLanguage,
    timezone,
    gameLevel,
    experiencePoints,
    gamesPlayed,
    gamesWon,
    winRate,
    profileCompleteness,
  ];

  @override
  String toString() =>
      'UserProfile(uid: $uid, email: $email, '
      'displayName: $displayName, status: $accountStatus)';
}
