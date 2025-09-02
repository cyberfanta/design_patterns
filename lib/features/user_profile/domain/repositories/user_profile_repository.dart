/// User Profile Repository Contract - Clean Architecture Domain Layer
///
/// PATTERN: Repository - Abstract interface for user profile data access
/// WHERE: Domain layer defining contracts for profile operations
/// HOW: Abstract class with async methods for profile CRUD operations
/// WHY: Decouples profile logic from data sources, enables testing
library;

import 'dart:typed_data';

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/features/user_profile/domain/entities/user_profile.dart';
import 'package:fpdart/fpdart.dart';

/// Abstract repository for managing user profile data
///
/// This contract defines how the domain layer interacts with user profile
/// data sources, supporting the Tower Defense app's Firestore and Storage
/// integration for comprehensive user management.
abstract class UserProfileRepository {
  /// Create new user profile
  ///
  /// Creates a new user profile in persistent storage.
  /// Usually called after successful user registration.
  Future<Either<Failure, UserProfile>> createProfile(UserProfile profile);

  /// Load user profile by ID
  ///
  /// Retrieves user profile data from storage using user ID.
  /// Returns null if profile doesn't exist.
  Future<Either<Failure, UserProfile?>> getProfile(String uid);

  /// Update existing user profile
  ///
  /// Updates user profile data in persistent storage.
  /// Performs partial or complete profile updates.
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);

  /// Delete user profile
  ///
  /// Permanently removes user profile from storage.
  /// Used for account deletion and GDPR compliance.
  Future<Either<Failure, void>> deleteProfile(String uid);

  /// Check if user profile exists
  ///
  /// Returns true if a profile exists for the given user ID.
  /// Useful for determining if profile needs to be created.
  Future<Either<Failure, bool>> profileExists(String uid);

  /// Upload profile photo
  ///
  /// Uploads user's profile photo to cloud storage.
  /// Returns URL of the uploaded image for profile reference.
  Future<Either<Failure, String>> uploadProfilePhoto(
    String uid,
    Uint8List imageData,
    String fileName,
  );

  /// Delete profile photo
  ///
  /// Removes user's profile photo from cloud storage.
  /// Used when user removes photo or deletes account.
  Future<Either<Failure, void>> deleteProfilePhoto(String uid);

  /// Get profile photo URL
  ///
  /// Retrieves direct URL to user's profile photo.
  /// Returns null if no photo is set.
  Future<Either<Failure, String?>> getProfilePhotoUrl(String uid);

  /// Search profiles by criteria
  ///
  /// Searches user profiles based on specified criteria.
  /// Used for admin functions and user discovery features.
  Future<Either<Failure, List<UserProfile>>> searchProfiles(
    Map<String, dynamic> criteria, {
    int limit = 20,
    String? startAfter,
  });

  /// Get profiles by IDs
  ///
  /// Retrieves multiple user profiles by their IDs.
  /// Useful for loading friend lists, leaderboards, etc.
  Future<Either<Failure, List<UserProfile>>> getProfilesByIds(
    List<String> uids,
  );

  /// Update profile field
  ///
  /// Updates a single field in the user profile.
  /// More efficient than updating entire profile for small changes.
  Future<Either<Failure, void>> updateProfileField(
    String uid,
    String field,
    dynamic value,
  );

  /// Increment numeric profile field
  ///
  /// Atomically increments numeric fields like game scores, experience.
  /// Ensures consistency in high-concurrency scenarios.
  Future<Either<Failure, void>> incrementProfileField(
    String uid,
    String field,
    num increment,
  );

  /// Batch update profiles
  ///
  /// Updates multiple user profiles in a single atomic operation.
  /// Used for bulk operations and consistency requirements.
  Future<Either<Failure, void>> batchUpdateProfiles(
    Map<String, UserProfile> profiles,
  );

  /// Export user profile data
  ///
  /// Exports user profile data for GDPR data portability.
  /// Returns complete user data in portable format.
  Future<Either<Failure, Map<String, dynamic>>> exportUserData(String uid);

  /// Anonymize user profile
  ///
  /// Anonymizes user profile data for GDPR right to be forgotten.
  /// Replaces personal data with anonymous values.
  Future<Either<Failure, UserProfile>> anonymizeProfile(String uid);

  /// Get profile analytics data
  ///
  /// Retrieves analytics data for user profile.
  /// Includes engagement metrics, activity patterns, etc.
  Future<Either<Failure, Map<String, dynamic>>> getProfileAnalytics(String uid);

  /// Update privacy settings
  ///
  /// Updates user's privacy and consent settings.
  /// Handles GDPR compliance and marketing preferences.
  Future<Either<Failure, void>> updatePrivacySettings(
    String uid,
    Map<String, bool> settings,
  );

  /// Get user activity log
  ///
  /// Retrieves log of user activities for audit trail.
  /// Used for security monitoring and user insights.
  Future<Either<Failure, List<Map<String, dynamic>>>> getActivityLog(
    String uid, {
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Log user activity
  ///
  /// Records user activity for audit and analytics purposes.
  /// Captures user interactions and important events.
  Future<Either<Failure, void>> logActivity(
    String uid,
    String activity,
    Map<String, dynamic> metadata,
  );

  /// Stream profile changes
  ///
  /// Returns stream that emits profile changes in real-time.
  /// Used for reactive UI updates and synchronization.
  Stream<Either<Failure, UserProfile?>> streamProfile(String uid);

  /// Validate profile data
  ///
  /// Validates profile data against business rules.
  /// Returns validation errors if any rules are violated.
  Future<Either<Failure, List<String>>> validateProfileData(
    UserProfile profile,
  );

  /// Get profile completion status
  ///
  /// Returns detailed profile completion analysis.
  /// Helps users understand what information is missing.
  Future<Either<Failure, Map<String, dynamic>>> getProfileCompletion(
    String uid,
  );

  /// Merge profile data
  ///
  /// Merges data from multiple sources into single profile.
  /// Used when linking OAuth providers or importing data.
  Future<Either<Failure, UserProfile>> mergeProfileData(
    String uid,
    Map<String, dynamic> additionalData,
  );

  /// Backup profile data
  ///
  /// Creates backup of user profile data.
  /// Returns backup identifier for restoration purposes.
  Future<Either<Failure, String>> backupProfile(String uid);

  /// Restore profile from backup
  ///
  /// Restores user profile from previously created backup.
  /// Used for data recovery and account restoration.
  Future<Either<Failure, UserProfile>> restoreProfile(
    String uid,
    String backupId,
  );
}
