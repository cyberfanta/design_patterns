/// User Profile Data Model
///
/// PATTERN: Data Transfer Object (DTO) - Represents user data from Firebase
/// WHERE: Data layer model extending domain entity
/// HOW: Adds serialization/deserialization methods for Firebase integration
/// WHY: Separates data representation from domain logic
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_patterns/features/user_profile/domain/entities/user_profile.dart';

/// Data model for UserProfile with Firebase serialization
///
/// PATTERN: Data Transfer Object - Firebase data mapping
///
/// In Tower Defense context, this model handles all Firebase
/// serialization for user profile data including game progress,
/// authentication details, and user preferences.
class UserProfileModel {
  // UserProfile fields mirrored for Firebase serialization
  final String uid;
  final String email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? photoUrl;
  final String? phoneNumber;
  final String? deviceModel;
  final String authProvider;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final DateTime? lastLogin;
  final bool keepLoggedIn;
  final bool acceptedTerms;
  final DateTime? privacyPolicyAcceptedAt;
  final bool marketingConsent;
  final bool analyticsConsent;
  final String accountStatus;
  final String preferredLanguage;
  final String? timezone;
  final int gameLevel;
  final int experiencePoints;
  final int gamesPlayed;
  final int gamesWon;
  final double winRate;
  final double profileCompleteness;

  UserProfileModel._({
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

  factory UserProfileModel({
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
    return UserProfileModel._(
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

  /// Create from domain entity
  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      firstName: entity.firstName,
      lastName: entity.lastName,
      photoUrl: entity.photoUrl,
      phoneNumber: entity.phoneNumber,
      deviceModel: entity.deviceModel,
      authProvider: entity.authProvider,
      createdAt: entity.createdAt,
      lastUpdated: entity.lastUpdated,
      lastLogin: entity.lastLogin,
      keepLoggedIn: entity.keepLoggedIn,
      acceptedTerms: entity.acceptedTerms,
      privacyPolicyAcceptedAt: entity.privacyPolicyAcceptedAt,
      marketingConsent: entity.marketingConsent,
      analyticsConsent: entity.analyticsConsent,
      accountStatus: entity.accountStatus,
      preferredLanguage: entity.preferredLanguage,
      timezone: entity.timezone,
      gameLevel: entity.gameLevel,
      experiencePoints: entity.experiencePoints,
      gamesPlayed: entity.gamesPlayed,
      gamesWon: entity.gamesWon,
      winRate: entity.winRate,
      profileCompleteness: entity.profileCompleteness,
    );
  }

  /// Convert to domain entity
  UserProfile toEntity() {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      deviceModel: deviceModel,
      authProvider: authProvider,
      createdAt: createdAt,
      lastUpdated: lastUpdated,
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

  /// Create from Firebase document data
  factory UserProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Profile document data is null');
    }

    return UserProfileModel.fromJson(data..['uid'] = snapshot.id);
  }

  /// Create from JSON data
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      phoneNumber: json['phone_number'] as String?,
      deviceModel: json['device_model'] as String?,
      authProvider: json['auth_provider'] as String? ?? 'email',
      createdAt: _parseTimestamp(json['created_at']) ?? DateTime.now(),
      lastUpdated: _parseTimestamp(json['last_updated']) ?? DateTime.now(),
      lastLogin: _parseTimestamp(json['last_login']),
      keepLoggedIn: json['keep_logged_in'] as bool? ?? false,
      acceptedTerms: json['accepted_terms'] as bool? ?? false,
      privacyPolicyAcceptedAt: _parseTimestamp(
        json['privacy_policy_accepted_at'],
      ),
      marketingConsent: json['marketing_consent'] as bool? ?? false,
      analyticsConsent: json['analytics_consent'] as bool? ?? false,
      accountStatus: json['account_status'] as String? ?? 'active',
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      timezone: json['timezone'] as String?,
      gameLevel: (json['game_level'] as num?)?.toInt() ?? 1,
      experiencePoints: (json['experience_points'] as num?)?.toInt() ?? 0,
      gamesPlayed: (json['games_played'] as num?)?.toInt() ?? 0,
      gamesWon: (json['games_won'] as num?)?.toInt() ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0.0,
      profileCompleteness:
          (json['profile_completeness'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      // Don't include uid in document data - it's the document ID
      'email': email,
      'display_name': displayName,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
      'phone_number': phoneNumber,
      'device_model': deviceModel,
      'auth_provider': authProvider,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'keep_logged_in': keepLoggedIn,
      'accepted_terms': acceptedTerms,
      'privacy_policy_accepted_at': privacyPolicyAcceptedAt?.toIso8601String(),
      'marketing_consent': marketingConsent,
      'analytics_consent': analyticsConsent,
      'account_status': accountStatus,
      'preferred_language': preferredLanguage,
      'timezone': timezone,
      'game_level': gameLevel,
      'experience_points': experiencePoints,
      'games_played': gamesPlayed,
      'games_won': gamesWon,
      'win_rate': winRate,
      'profile_completeness': profileCompleteness,
    };
  }

  /// Convert to Firebase document data with server timestamp
  Map<String, dynamic> toFirestoreData({bool isUpdate = false}) {
    final data = toJson();

    // Use server timestamp for updates
    if (isUpdate) {
      data['last_updated'] = FieldValue.serverTimestamp();
    }

    return data;
  }

  /// Create minimal profile for registration
  factory UserProfileModel.forRegistration({
    required String uid,
    required String email,
    required String displayName,
    required String authProvider,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phoneNumber,
    String? deviceModel,
    required DateTime acceptedTermsAt,
    required DateTime privacyConsentAt,
    String preferredLanguage = 'en',
  }) {
    final now = DateTime.now();

    return UserProfileModel(
      uid: uid,
      email: email,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      deviceModel: deviceModel,
      authProvider: authProvider,
      createdAt: now,
      lastUpdated: now,
      lastLogin: now,
      keepLoggedIn: false,
      acceptedTerms: true,
      privacyPolicyAcceptedAt: privacyConsentAt,
      marketingConsent: false,
      analyticsConsent: false,
      accountStatus: 'active',
      preferredLanguage: preferredLanguage,
      gameLevel: 1,
      experiencePoints: 0,
      gamesPlayed: 0,
      gamesWon: 0,
      winRate: 0.0,
      profileCompleteness: 0.0,
    );
  }

  /// Update specific fields and return new model
  UserProfileModel updateFields(Map<String, dynamic> updates) {
    return UserProfileModel.fromJson({
      ...toJson(),
      ...updates,
      'uid': uid, // Ensure UID is preserved
      'last_updated': DateTime.now().toIso8601String(),
    });
  }

  /// Create a copy with modified fields
  UserProfileModel copyWith({
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
    return UserProfileModel._(
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
      lastUpdated: lastUpdated ?? this.lastUpdated,
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
  }

  /// Mark profile for deletion
  UserProfileModel markForDeletion() {
    return copyWith(
      accountStatus: 'pending_deletion',
      lastUpdated: DateTime.now(),
    );
  }

  /// Anonymize profile data (GDPR compliance)
  UserProfileModel anonymize() {
    return copyWith(
      email: 'anonymous@deleted.com',
      displayName: 'Deleted User',
      firstName: null,
      lastName: null,
      photoUrl: null,
      phoneNumber: null,
      deviceModel: null,
      timezone: null,
      lastUpdated: DateTime.now(),
      accountStatus: 'anonymized',
    );
  }

  /// Helper method to parse timestamps from various formats
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is Timestamp) return value.toDate();

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }

    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Check if profile is complete
  bool get isComplete {
    return displayName != null &&
        displayName!.isNotEmpty &&
        profileCompleteness >= 0.8;
  }

  /// Check if email is verified
  bool get isEmailVerified {
    // For now, return true. In a real app, this would be based on Firebase user.emailVerified
    return acceptedTerms; // Using acceptedTerms as proxy for email verification
  }

  /// Get account status as enum for type safety
  AccountStatus get accountStatusEnum {
    switch (accountStatus) {
      case 'active':
        return AccountStatus.active;
      case 'pending_deletion':
        return AccountStatus.pendingDeletion;
      case 'deleted':
        return AccountStatus.anonymized;
      case 'suspended':
        return AccountStatus.suspended;
      default:
        return AccountStatus.active;
    }
  }

  /// Get export data for debugging or analytics
  Map<String, dynamic> getExportData() {
    return {
      ...toJson(),
      'uid': uid,
      'win_rate': winRate,
      'days_since_created': DateTime.now().difference(createdAt).inDays,
      'days_since_last_sign_in': lastLogin != null
          ? DateTime.now().difference(lastLogin!).inDays
          : null,
      'is_complete': isComplete,
      'can_be_deleted': accountStatus == 'pending_deletion',
      'deletion_date': accountStatus == 'pending_deletion'
          ? lastUpdated.toIso8601String()
          : null,
    };
  }

  @override
  String toString() {
    return 'UserProfileModel(uid: $uid, email: $email, '
        'displayName: $displayName, authProvider: $authProvider)';
  }
}
