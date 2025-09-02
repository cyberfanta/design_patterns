/// User Profile Repository Implementation
///
/// PATTERN: Repository - Data access abstraction
/// WHERE: Data layer implementing domain repository contract
/// HOW: Coordinates profile operations between use cases and data sources
/// WHY: Isolates data access implementation from domain logic
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:design_patterns/core/error/failures.dart' as core_failures;
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/utils/result.dart';
import 'package:design_patterns/features/user_profile/data/data_sources/firestore_profile_datasource.dart';
import 'package:design_patterns/features/user_profile/data/models/user_profile_model.dart';
import 'package:design_patterns/features/user_profile/domain/entities/user_profile.dart';
import 'package:design_patterns/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Repository implementation for user profile operations
///
/// PATTERN: Repository - Profile data access coordination
///
/// In Tower Defense context, this repository handles user profile
/// operations by coordinating between domain use cases and Firestore
/// datasource, providing a clean interface for profile management.
class UserProfileRepositoryImpl implements UserProfileRepository {
  final ProfileDataSource _profileDataSource;

  UserProfileRepositoryImpl({required ProfileDataSource profileDataSource})
    : _profileDataSource = profileDataSource {
    Log.debug('UserProfileRepositoryImpl initialized');
  }

  @override
  Future<Either<core_failures.Failure, UserProfile?>> getProfile(
    String uid,
  ) async {
    try {
      Log.debug('ProfileRepository: Getting profile for user $uid');

      if (uid.isEmpty) {
        Log.warning('ProfileRepository: Empty UID provided');
        return Left(
          core_failures.ValidationFailure(message: 'User ID cannot be empty'),
        );
      }

      final result = await _profileDataSource.getProfile(uid);

      // Convert Result to Either and map UserProfileModel to UserProfile
      return result.fold(
        (exception) =>
            Left(core_failures.ServerFailure(message: exception.toString())),
        (profileModel) => Right(profileModel.toEntity()),
      );
    } catch (e) {
      Log.error('ProfileRepository: Unexpected error getting profile - $e');
      return Left(
        core_failures.ServerFailure(message: 'Failed to get profile: $e'),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, UserProfile>> createProfile(
    UserProfile profile,
  ) async {
    try {
      Log.debug('ProfileRepository: Creating profile for user ${profile.uid}');

      if (profile.uid.isEmpty) {
        Log.warning('ProfileRepository: Empty UID in profile');
        return Left(
          core_failures.ValidationFailure(
            message: 'Profile UID cannot be empty',
          ),
        );
      }

      // Convert domain entity to data model
      final profileModel = UserProfileModel.fromEntity(profile);

      // Validate required fields
      if (profileModel.email.isEmpty) {
        Log.warning('ProfileRepository: Empty email in profile');
        return Left(
          core_failures.ValidationFailure(
            message: 'Profile email cannot be empty',
          ),
        );
      }

      final result = await _profileDataSource.createProfile(profileModel);

      // Convert Result to Either and map UserProfileModel to UserProfile
      return result.fold(
        (exception) =>
            Left(core_failures.ServerFailure(message: exception.toString())),
        (createdProfile) => Right(createdProfile.toEntity()),
      );
    } catch (e) {
      Log.error('ProfileRepository: Unexpected error creating profile - $e');
      return Left(
        core_failures.ServerFailure(message: 'Failed to create profile: $e'),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, UserProfile>> updateProfile(
    UserProfile profile,
  ) async {
    try {
      Log.debug('ProfileRepository: Updating profile for user ${profile.uid}');

      if (profile.uid.isEmpty) {
        Log.warning('ProfileRepository: Empty UID in profile');
        return Left(
          core_failures.ValidationFailure(
            message: 'Profile UID cannot be empty',
          ),
        );
      }

      // Convert domain entity to data model
      final profileModel = UserProfileModel.fromEntity(profile);

      // Ensure last updated timestamp is current
      final updatedModel = profileModel.copyWith(lastUpdated: DateTime.now());

      final result = await _profileDataSource.updateProfile(updatedModel);

      // Convert Result to Either and map UserProfileModel to UserProfile
      return result.fold(
        (exception) =>
            Left(core_failures.ServerFailure(message: exception.toString())),
        (updatedProfile) => Right(updatedProfile.toEntity()),
      );
    } catch (e) {
      Log.error('ProfileRepository: Unexpected error updating profile - $e');
      return Left(
        core_failures.ServerFailure(message: 'Failed to update profile: $e'),
      );
    }
  }

  Future<Result<void, Exception>> updateField(
    String uid,
    String field,
    dynamic value,
  ) async {
    try {
      Log.debug('ProfileRepository: Updating field $field for user $uid');

      if (uid.isEmpty) {
        Log.warning('ProfileRepository: Empty UID provided');
        return Result.failure(Exception('User ID cannot be empty'));
      }

      if (field.isEmpty) {
        Log.warning('ProfileRepository: Empty field name provided');
        return Result.failure(Exception('Field name cannot be empty'));
      }

      // Validate field updates
      if (!_isValidFieldUpdate(field, value)) {
        Log.warning('ProfileRepository: Invalid field update: $field = $value');
        return Result.failure(
          Exception('Invalid field update: $field cannot be set to $value'),
        );
      }

      final result = await _profileDataSource.updateField(uid, field, value);

      return result.fold(
        (failure) {
          Log.error('ProfileRepository: Update field failed - $failure');
          return Result.failure(failure);
        },
        (_) {
          Log.success('ProfileRepository: Field updated successfully');
          return Result.success(null);
        },
      );
    } catch (e) {
      Log.error('ProfileRepository: Unexpected error updating field - $e');
      return Result.failure(Exception('Failed to update field: $e'));
    }
  }

  @override
  Future<Either<core_failures.Failure, void>> deleteProfile(String uid) async {
    try {
      Log.warning('ProfileRepository: Deleting profile for user $uid');

      if (uid.isEmpty) {
        Log.warning('ProfileRepository: Empty UID provided');
        return Left(
          core_failures.ValidationFailure(message: 'User ID cannot be empty'),
        );
      }

      final result = await _profileDataSource.deleteProfile(uid);

      // Convert Result to Either
      return result.fold(
        (exception) =>
            Left(core_failures.ServerFailure(message: exception.toString())),
        (_) => const Right(null),
      );
    } catch (e) {
      Log.error('ProfileRepository: Unexpected error deleting profile - $e');
      return Left(
        core_failures.ServerFailure(message: 'Failed to delete profile: $e'),
      );
    }
  }

  Future<Result<String, Exception>> uploadProfileImage(
    String uid,
    String imagePath,
  ) async {
    try {
      Log.debug('ProfileRepository: Uploading profile image for user $uid');

      if (uid.isEmpty) {
        Log.warning('ProfileRepository: Empty UID provided');
        return Result.failure(Exception('User ID cannot be empty'));
      }

      if (imagePath.isEmpty) {
        Log.warning('ProfileRepository: Empty image path provided');
        return Result.failure(Exception('Image path cannot be empty'));
      }

      final imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        Log.warning('ProfileRepository: Image file does not exist: $imagePath');
        return Result.failure(Exception('Image file does not exist'));
      }

      final result = await _profileDataSource.uploadProfileImage(
        uid,
        imageFile,
      );

      return result.fold(
        (failure) {
          Log.error('ProfileRepository: Upload image failed - $failure');
          return Result.failure(failure);
        },
        (downloadUrl) {
          Log.success('ProfileRepository: Profile image uploaded successfully');
          return Result.success(downloadUrl);
        },
      );
    } catch (e) {
      Log.error('ProfileRepository: Unexpected error uploading image - $e');
      return Result.failure(Exception('Failed to upload image: $e'));
    }
  }

  Future<Result<void, Exception>> deleteProfileImage(String uid) async {
    try {
      Log.debug('ProfileRepository: Deleting profile image for user $uid');

      if (uid.isEmpty) {
        Log.warning('ProfileRepository: Empty UID provided');
        return Result.failure(Exception('User ID cannot be empty'));
      }

      final result = await _profileDataSource.deleteProfileImage(uid);

      return result.fold(
        (failure) {
          Log.error('ProfileRepository: Delete image failed - $failure');
          return Result.failure(failure);
        },
        (_) {
          Log.success('ProfileRepository: Profile image deleted successfully');
          return Result.success(null);
        },
      );
    } catch (e) {
      Log.error('ProfileRepository: Unexpected error deleting image - $e');
      return Result.failure(Exception('Failed to delete image: $e'));
    }
  }

  Future<Result<UserProfile, Exception>> markProfileForDeletion(
    String uid,
  ) async {
    try {
      Log.warning('ProfileRepository: Marking profile for deletion - $uid');

      if (uid.isEmpty) {
        Log.warning('ProfileRepository: Empty UID provided');
        return Result.failure(Exception('User ID cannot be empty'));
      }

      // Get current profile
      final getCurrentResult = await getProfile(uid);

      return getCurrentResult.fold(
        (failure) => Result.failure(Exception(failure.toString())),
        (profile) async {
          // Check if profile exists
          if (profile == null) {
            Log.error(
              'ProfileRepository: Profile not found for deletion marking',
            );
            return Result.failure(Exception('Profile not found'));
          }

          // Mark profile for deletion
          final profileModel = UserProfileModel.fromEntity(profile);
          final markedProfile = profileModel.markForDeletion();

          final updateResult = await _profileDataSource.updateProfile(
            markedProfile,
          );

          return updateResult.fold(
            (failure) {
              Log.error(
                'ProfileRepository: Mark for deletion failed - $failure',
              );
              return Result.failure(Exception(failure.toString()));
            },
            (updatedProfile) {
              Log.success('ProfileRepository: Profile marked for deletion');
              return Result.success(updatedProfile.toEntity());
            },
          );
        },
      );
    } catch (e) {
      Log.error(
        'ProfileRepository: Unexpected error marking for deletion - $e',
      );
      return Result.failure(
        Exception('Failed to mark profile for deletion: $e'),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, UserProfile>> anonymizeProfile(
    String uid,
  ) async {
    try {
      Log.warning('ProfileRepository: Anonymizing profile - $uid');

      if (uid.isEmpty) {
        Log.warning('ProfileRepository: Empty UID provided');
        return Left(
          core_failures.ValidationFailure(message: 'User ID cannot be empty'),
        );
      }

      // Get current profile
      final getCurrentResult = await getProfile(uid);

      return getCurrentResult.fold((failure) => Left(failure), (profile) async {
        // Check if profile exists
        if (profile == null) {
          Log.error('ProfileRepository: Profile not found for anonymization');
          return Left(
            core_failures.ServerFailure(message: 'Profile not found'),
          );
        }

        // Anonymize profile data
        final profileModel = UserProfileModel.fromEntity(profile);

        // Delete profile image first
        try {
          await deleteProfileImage(uid);
        } catch (e) {
          Log.warning(
            'ProfileRepository: Failed to delete profile image during anonymization: $e',
          );
          // Continue with anonymization even if image deletion fails
        }

        final anonymizedProfile = profileModel.anonymize();

        final updateResult = await _profileDataSource.updateProfile(
          anonymizedProfile,
        );

        // Convert Result to Either and map to UserProfile
        return updateResult.fold(
          (exception) =>
              Left(core_failures.ServerFailure(message: exception.toString())),
          (updatedProfile) => Right(updatedProfile.toEntity()),
        );
      });
    } catch (e) {
      Log.error('ProfileRepository: Unexpected error anonymizing profile - $e');
      return Left(
        core_failures.ServerFailure(message: 'Failed to anonymize profile: $e'),
      );
    }
  }

  Stream<UserProfile?> profileStream(String uid) {
    try {
      Log.debug('ProfileRepository: Setting up profile stream for user $uid');

      if (uid.isEmpty) {
        Log.warning('ProfileRepository: Empty UID provided for stream');
        return Stream.error(Exception('User ID cannot be empty'));
      }

      return _profileDataSource
          .profileStream(uid)
          .map((profileModel) => profileModel?.toEntity());
    } catch (e) {
      Log.error('ProfileRepository: Error setting up profile stream - $e');
      return Stream.error(e);
    }
  }

  @override
  Future<Either<core_failures.Failure, List<UserProfile>>> searchProfiles(
    Map<String, dynamic> searchCriteria, {
    int limit = 10,
    String? startAfter,
  }) async {
    try {
      Log.debug('ProfileRepository: Searching profiles');

      // Extract search criteria
      final email = searchCriteria['email'] as String?;
      final displayName = searchCriteria['displayName'] as String?;

      final result = await _profileDataSource.searchProfiles(
        email: email,
        displayName: displayName,
        limit: limit,
      );

      // Convert Result to Either and map UserProfileModel list to UserProfile list
      return result.fold(
        (exception) =>
            Left(core_failures.ServerFailure(message: exception.toString())),
        (profiles) {
          final userProfiles = profiles
              .map((profileModel) => profileModel.toEntity())
              .toList();
          Log.success(
            'ProfileRepository: Found ${userProfiles.length} profiles',
          );
          return Right(userProfiles);
        },
      );
    } catch (e) {
      Log.error('ProfileRepository: Unexpected error searching profiles - $e');
      return Left(
        core_failures.ServerFailure(message: 'Failed to search profiles: $e'),
      );
    }
  }

  /// Update game progress for a user
  Future<Result<UserProfile, Exception>> updateGameProgress({
    required String uid,
    required int gamesPlayed,
    required int gamesWon,
    int? gameLevel,
  }) async {
    try {
      Log.debug('ProfileRepository: Updating game progress for user $uid');

      // Get current profile
      final getCurrentResult = await getProfile(uid);

      return getCurrentResult.fold(
        (failure) => Result.failure(Exception(failure.toString())),
        (profile) async {
          // Check if profile exists
          if (profile == null) {
            Log.error(
              'ProfileRepository: Profile not found for game progress update',
            );
            return Result.failure(Exception('Profile not found'));
          }

          // Update game progress
          final updatedProfile = profile.updateGameProgress(
            gamesPlayed: gamesPlayed,
            gamesWon: gamesWon,
            gameLevel: gameLevel,
          );

          final updateResult = await updateProfile(updatedProfile);
          return updateResult.fold(
            (failure) => Result.failure(Exception(failure.toString())),
            (profile) => Result.success(profile),
          );
        },
      );
    } catch (e) {
      Log.error(
        'ProfileRepository: Unexpected error updating game progress - $e',
      );
      return Result.failure(Exception('Failed to update game progress: $e'));
    }
  }

  /// Get profile statistics
  Future<Result<Map<String, dynamic>, Exception>> getProfileStats() async {
    try {
      Log.debug('ProfileRepository: Getting profile statistics');

      if (_profileDataSource is FirestoreProfileDataSource) {
        final firestoreSource = _profileDataSource;
        final result = await firestoreSource.getProfileStats();

        return result.fold(
          (failure) {
            Log.error('ProfileRepository: Get stats failed - $failure');
            return Result.failure(failure);
          },
          (stats) {
            Log.success('ProfileRepository: Profile statistics retrieved');
            return Result.success(stats);
          },
        );
      } else {
        Log.warning(
          'ProfileRepository: Stats not supported by current data source',
        );
        return Result.failure(Exception('Profile statistics not supported'));
      }
    } catch (e) {
      Log.error('ProfileRepository: Unexpected error getting stats - $e');
      return Result.failure(Exception('Failed to get profile stats: $e'));
    }
  }

  /// Validate field update
  bool _isValidFieldUpdate(String field, dynamic value) {
    // Prevent updating critical system fields
    const protectedFields = [
      'uid',
      'account_created_at',
      'accepted_terms_at',
      'privacy_consent_at',
    ];

    if (protectedFields.contains(field)) {
      return false;
    }

    // Validate specific field types
    switch (field) {
      case 'email':
        return value is String && value.isNotEmpty && value.contains('@');

      case 'display_name':
      case 'full_name':
        return value is String && value.isNotEmpty;

      case 'games_played':
      case 'games_won':
      case 'game_level':
        return value is int && value >= 0;

      case 'is_email_verified':
        return value is bool;

      case 'profile_visibility':
        return value is String &&
            ProfileVisibility.values.any((v) => v.name == value);

      case 'account_status':
        return value is String &&
            AccountStatus.values.any((v) => v.name == value);

      default:
        return true; // Allow other fields
    }
  }

  /// Get repository status information
  Map<String, dynamic> getRepositoryStatus() {
    try {
      return {
        'datasource_type': _profileDataSource.runtimeType.toString(),
        'initialized': true,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      Log.error('ProfileRepository: Error getting repository status - $e');
      return {'error': e.toString()};
    }
  }

  // STUB IMPLEMENTATIONS - Basic implementations to satisfy interface
  // These can be expanded with full functionality as needed

  @override
  Future<Either<core_failures.Failure, String>> backupProfile(
    String uid,
  ) async {
    Log.warning('backupProfile not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, void>> batchUpdateProfiles(
    Map<String, UserProfile> profiles,
  ) async {
    Log.warning('batchUpdateProfiles not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, void>> deleteProfilePhoto(
    String uid,
  ) async {
    try {
      final result = await _profileDataSource.deleteProfileImage(uid);
      return result.fold(
        (exception) =>
            Left(core_failures.ServerFailure(message: exception.toString())),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(
        core_failures.ServerFailure(
          message: 'Failed to delete profile photo: $e',
        ),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, Map<String, dynamic>>> exportUserData(
    String uid,
  ) async {
    try {
      final profileResult = await getProfile(uid);
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) => Right({
          'uid': profile?.uid,
          'email': profile?.email,
          'displayName': profile?.displayName,
          'firstName': profile?.firstName,
          'lastName': profile?.lastName,
          'photoUrl': profile?.photoUrl,
          'createdAt': profile?.createdAt.toIso8601String(),
          'lastUpdated': profile?.lastUpdated.toIso8601String(),
        }),
      );
    } catch (e) {
      return Left(
        core_failures.ServerFailure(message: 'Failed to export user data: $e'),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, UserProfile>> restoreProfile(
    String uid,
    String backupId,
  ) async {
    Log.warning('restoreProfile not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, List<String>>> validateProfileData(
    UserProfile profile,
  ) async {
    try {
      final errors = <String>[];

      if (profile.uid.isEmpty) {
        errors.add('UID is required');
      }
      if (profile.email.isEmpty) {
        errors.add('Email is required');
      }
      if (profile.displayName == null || profile.displayName!.isEmpty) {
        errors.add('Display name is recommended');
      }

      return Right(errors);
    } catch (e) {
      return Left(
        core_failures.ValidationFailure(message: 'Validation failed: $e'),
      );
    }
  }

  Future<Either<core_failures.Failure, void>> updateProfileVisibility(
    String uid,
    Map<String, bool> visibilitySettings,
  ) async {
    Log.warning('updateProfileVisibility not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  Future<Either<core_failures.Failure, void>> blockUser(
    String currentUid,
    String blockedUid,
  ) async {
    Log.warning('blockUser not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  Future<Either<core_failures.Failure, void>> unblockUser(
    String currentUid,
    String blockedUid,
  ) async {
    Log.warning('unblockUser not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  Future<Either<core_failures.Failure, List<String>>> getBlockedUsers(
    String uid,
  ) async {
    Log.warning('getBlockedUsers not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  Future<Either<core_failures.Failure, void>> reportUser(
    String reporterUid,
    String reportedUid,
    String reason,
  ) async {
    Log.warning('reportUser not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, Map<String, dynamic>>>
  getProfileAnalytics(String uid) async {
    try {
      final profileResult = await getProfile(uid);
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) => Right({
          'profile_completeness': profile?.profileCompleteness ?? 0.0,
          'games_played': profile?.gamesPlayed ?? 0,
          'win_rate': profile?.winRate ?? 0.0,
          'days_since_created': profile != null
              ? DateTime.now().difference(profile.createdAt).inDays
              : 0,
        }),
      );
    } catch (e) {
      return Left(
        core_failures.ServerFailure(
          message: 'Failed to get profile analytics: $e',
        ),
      );
    }
  }

  Future<Either<core_failures.Failure, void>> syncProfile(String uid) async {
    Log.warning('syncProfile not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  Future<Either<core_failures.Failure, void>> clearProfileCache(
    String uid,
  ) async {
    Log.warning('clearProfileCache not implemented yet');
    return const Right(null); // Cache clearing is optional
  }

  Future<Either<core_failures.Failure, void>> updateProfileMetadata(
    String uid,
    Map<String, dynamic> metadata,
  ) async {
    Log.warning('updateProfileMetadata not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  Future<Either<core_failures.Failure, void>> archiveProfile(String uid) async {
    Log.warning('archiveProfile not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  Future<Either<core_failures.Failure, void>> unarchiveProfile(
    String uid,
  ) async {
    Log.warning('unarchiveProfile not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  Future<Either<core_failures.Failure, List<UserProfile>>> getArchivedProfiles(
    String uid,
  ) async {
    Log.warning('getArchivedProfiles not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  Future<Either<core_failures.Failure, void>> updateLastActiveTime(
    String uid,
  ) async {
    try {
      final result = await _profileDataSource.updateField(
        uid,
        'last_login',
        DateTime.now(),
      );
      return result.fold(
        (exception) =>
            Left(core_failures.ServerFailure(message: exception.toString())),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(
        core_failures.ServerFailure(
          message: 'Failed to update last active time: $e',
        ),
      );
    }
  }

  // Additional interface methods implementation

  @override
  Future<Either<core_failures.Failure, bool>> profileExists(String uid) async {
    try {
      final result = await getProfile(uid);
      return result.fold(
        (_) => const Right(false),
        (profile) => Right(profile != null),
      );
    } catch (e) {
      return Left(
        core_failures.ServerFailure(
          message: 'Failed to check profile existence: $e',
        ),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, String>> uploadProfilePhoto(
    String uid,
    Uint8List imageData,
    String fileName,
  ) async {
    Log.warning('uploadProfilePhoto not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, String?>> getProfilePhotoUrl(
    String uid,
  ) async {
    try {
      final profileResult = await getProfile(uid);
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) => Right(profile?.photoUrl),
      );
    } catch (e) {
      return Left(
        core_failures.ServerFailure(
          message: 'Failed to get profile photo URL: $e',
        ),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, List<UserProfile>>> getProfilesByIds(
    List<String> uids,
  ) async {
    Log.warning('getProfilesByIds not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, void>> updateProfileField(
    String uid,
    String field,
    dynamic value,
  ) async {
    try {
      final result = await _profileDataSource.updateField(uid, field, value);
      return result.fold(
        (exception) =>
            Left(core_failures.ServerFailure(message: exception.toString())),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(
        core_failures.ServerFailure(
          message: 'Failed to update profile field: $e',
        ),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, void>> incrementProfileField(
    String uid,
    String field,
    num increment,
  ) async {
    Log.warning('incrementProfileField not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, void>> updatePrivacySettings(
    String uid,
    Map<String, bool> settings,
  ) async {
    Log.warning('updatePrivacySettings not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, List<Map<String, dynamic>>>>
  getActivityLog(
    String uid, {
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Log.warning('getActivityLog not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, void>> logActivity(
    String uid,
    String activity,
    Map<String, dynamic> metadata,
  ) async {
    Log.warning('logActivity not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Stream<Either<core_failures.Failure, UserProfile?>> streamProfile(
    String uid,
  ) {
    try {
      return _profileDataSource
          .profileStream(uid)
          .map(
            (profileModel) => Right<core_failures.Failure, UserProfile?>(
              profileModel?.toEntity(),
            ),
          );
    } catch (e) {
      return Stream.value(
        Left(
          core_failures.ServerFailure(message: 'Failed to stream profile: $e'),
        ),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, Map<String, dynamic>>>
  getProfileCompletion(String uid) async {
    try {
      final profileResult = await getProfile(uid);
      return profileResult.fold(
        (failure) => Left(failure),
        (profile) => Right({
          'completion_percentage': profile?.profileCompleteness ?? 0.0,
          'missing_fields': profile == null ? ['profile'] : [],
          'completed_fields': profile != null ? ['uid', 'email'] : [],
        }),
      );
    } catch (e) {
      return Left(
        core_failures.ServerFailure(
          message: 'Failed to get profile completion: $e',
        ),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, UserProfile>> mergeProfileData(
    String uid,
    Map<String, dynamic> additionalData,
  ) async {
    Log.warning('mergeProfileData not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }
}
