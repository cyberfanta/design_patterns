/// Update User Profile Use Case - Clean Architecture Domain Layer
///
/// PATTERN: Command - Encapsulates profile update operations
/// WHERE: Domain layer use cases for profile management
/// HOW: Single responsibility class handling profile updates with validation
/// WHY: Centralizes profile update logic with business rules enforcement
library;

import 'dart:typed_data';

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/core/logging/logging.dart';
// Observer import removed - GameEventManager is used from game_events namespace
import 'package:design_patterns/features/user_profile/domain/entities/user_profile.dart';
import 'package:design_patterns/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:design_patterns/features/user_profile/domain/services/game_event_manager.dart'
    as game_events;
import 'package:fpdart/fpdart.dart';

/// Use case for updating user profile information
///
/// In the Tower Defense context, this manages player profile updates
/// including personal information, game progress, privacy settings,
/// and profile photo management.
class UpdateUserProfile {
  final UserProfileRepository _profileRepository;
  final game_events.GameEventManager _eventManager;

  const UpdateUserProfile(this._profileRepository, this._eventManager);

  /// Execute profile update operation
  ///
  /// Parameters:
  /// - [profile]: Updated user profile data
  /// - [validateChanges]: Whether to validate changes before updating
  ///
  /// Returns updated [UserProfile] or error information
  Future<Either<Failure, UserProfile>> execute(
    UserProfile profile, {
    bool validateChanges = true,
  }) async {
    try {
      Log.debug('Updating user profile for user: ${profile.uid}');

      // Validate profile changes if requested
      if (validateChanges) {
        final validationResult = await _validateProfileUpdate(profile);
        if (validationResult.isLeft()) {
          return validationResult.fold(
            (failure) => Left(failure),
            (_) => throw UnimplementedError(), // This should never happen
          );
        }
      }

      // Load current profile for comparison
      final currentProfileResult = await _profileRepository.getProfile(
        profile.uid,
      );

      return currentProfileResult.fold(
        (failure) async {
          Log.error('Could not load current profile: ${failure.toString()}');
          return Left(failure);
        },
        (currentProfile) async {
          if (currentProfile == null) {
            Log.error('User profile not found: ${profile.uid}');
            return Left(NotFoundFailure(message: 'User profile not found'));
          }

          // Create updated profile with proper timestamp and completeness
          final updatedProfile = profile.copyWith(
            lastUpdated: DateTime.now(),
            profileCompleteness: profile.calculateCompleteness(),
          );

          // Perform the update
          final updateResult = await _profileRepository.updateProfile(
            updatedProfile,
          );

          return updateResult.fold(
            (failure) {
              Log.error('Profile update failed: ${failure.toString()}');
              return Left(failure);
            },
            (finalProfile) {
              Log.success(
                'Profile updated successfully for user: ${profile.uid}',
              );

              // Log the update activity
              _logUpdateActivity(currentProfile, finalProfile);

              // Notify observers of profile changes
              _notifyProfileUpdate(currentProfile, finalProfile);

              return Right(finalProfile);
            },
          );
        },
      );
    } catch (e) {
      Log.error('Unexpected error updating profile: $e');
      return Left(
        ServerFailure(message: 'Profile update failed: ${e.toString()}'),
      );
    }
  }

  /// Update specific profile field
  ///
  /// More efficient for single field updates
  Future<Either<Failure, void>> updateField(
    String uid,
    String field,
    dynamic value,
  ) async {
    try {
      Log.debug('Updating profile field $field for user: $uid');

      // Validate field update
      final validationResult = _validateFieldUpdate(field, value);
      if (validationResult.isLeft()) {
        return validationResult;
      }

      final updateResult = await _profileRepository.updateProfileField(
        uid,
        field,
        value,
      );

      return updateResult.fold(
        (failure) {
          Log.error('Field update failed: ${failure.toString()}');
          return Left(failure);
        },
        (_) {
          Log.success('Field $field updated successfully for user: $uid');

          // Log field update
          _profileRepository.logActivity(uid, 'field_updated', {
            'field': field,
            'timestamp': DateTime.now().toIso8601String(),
          });

          return const Right(null);
        },
      );
    } catch (e) {
      Log.error('Error updating profile field: $e');
      return Left(
        ServerFailure(message: 'Field update failed: ${e.toString()}'),
      );
    }
  }

  /// Update user's personal information
  Future<Either<Failure, UserProfile>> updatePersonalInfo(
    String uid, {
    String? displayName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? timezone,
  }) async {
    try {
      Log.debug('Updating personal information for user: $uid');

      // Load current profile
      final profileResult = await _profileRepository.getProfile(uid);

      return profileResult.fold((failure) => Left(failure), (
        currentProfile,
      ) async {
        if (currentProfile == null) {
          return Left(NotFoundFailure(message: 'User profile not found'));
        }

        final updatedProfile = currentProfile.updatePersonalInfo(
          displayName: displayName,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          timezone: timezone,
        );

        return execute(updatedProfile);
      });
    } catch (e) {
      Log.error('Error updating personal info: $e');
      return Left(
        ServerFailure(message: 'Personal info update failed: ${e.toString()}'),
      );
    }
  }

  /// Update user's game progress
  Future<Either<Failure, UserProfile>> updateGameProgress(
    String uid, {
    int? gameLevel,
    int? experiencePoints,
    int? gamesPlayed,
    int? gamesWon,
  }) async {
    try {
      Log.debug('Updating game progress for user: $uid');

      final profileResult = await _profileRepository.getProfile(uid);

      return profileResult.fold((failure) => Left(failure), (
        currentProfile,
      ) async {
        if (currentProfile == null) {
          return Left(NotFoundFailure(message: 'User profile not found'));
        }

        final updatedProfile = currentProfile.updateGameProgress(
          gameLevel: gameLevel,
          experiencePoints: experiencePoints,
          gamesPlayed: gamesPlayed,
          gamesWon: gamesWon,
        );

        return execute(updatedProfile);
      });
    } catch (e) {
      Log.error('Error updating game progress: $e');
      return Left(
        ServerFailure(message: 'Game progress update failed: ${e.toString()}'),
      );
    }
  }

  /// Update user's privacy and consent settings
  Future<Either<Failure, UserProfile>> updatePrivacySettings(
    String uid, {
    bool? marketingConsent,
    bool? analyticsConsent,
    DateTime? privacyPolicyAcceptedAt,
  }) async {
    try {
      Log.debug('Updating privacy settings for user: $uid');

      final profileResult = await _profileRepository.getProfile(uid);

      return profileResult.fold((failure) => Left(failure), (
        currentProfile,
      ) async {
        if (currentProfile == null) {
          return Left(NotFoundFailure(message: 'User profile not found'));
        }

        final updatedProfile = currentProfile.updateConsents(
          marketingConsent: marketingConsent,
          analyticsConsent: analyticsConsent,
          privacyPolicyAcceptedAt: privacyPolicyAcceptedAt,
        );

        // Also update privacy settings in repository
        final privacySettings = <String, bool>{};
        if (marketingConsent != null) {
          privacySettings['marketing'] = marketingConsent;
        }
        if (analyticsConsent != null) {
          privacySettings['analytics'] = analyticsConsent;
        }

        if (privacySettings.isNotEmpty) {
          await _profileRepository.updatePrivacySettings(uid, privacySettings);
        }

        return execute(updatedProfile);
      });
    } catch (e) {
      Log.error('Error updating privacy settings: $e');
      return Left(
        ServerFailure(
          message: 'Privacy settings update failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Upload and update profile photo
  Future<Either<Failure, UserProfile>> updateProfilePhoto(
    String uid,
    Uint8List imageData,
    String fileName,
  ) async {
    try {
      Log.debug('Uploading profile photo for user: $uid');

      // Upload photo to cloud storage
      final uploadResult = await _profileRepository.uploadProfilePhoto(
        uid,
        imageData,
        fileName,
      );

      return await uploadResult
          .fold(
            (failure) async {
              Log.error('Photo upload failed: ${failure.toString()}');
              return Left(failure);
            },
            (photoUrl) async {
              // Update profile with new photo URL
              return await updateField(uid, 'photoUrl', photoUrl);
            },
          )
          .then((result) async {
            if (result.isRight()) {
              // Reload updated profile to return
              final profileResult = await _profileRepository.getProfile(uid);
              return profileResult.fold(
                (failure) => Left(failure),
                (profile) => profile != null
                    ? Right(profile)
                    : Left(
                        NotFoundFailure(
                          message: 'Profile not found after photo update',
                        ),
                      ),
              );
            }
            return Left(
              result.fold(
                (l) => l,
                (r) => ServerFailure(message: 'Unexpected success result'),
              ),
            );
          });
    } catch (e) {
      Log.error('Error updating profile photo: $e');
      return Left(
        ServerFailure(message: 'Profile photo update failed: ${e.toString()}'),
      );
    }
  }

  /// Remove profile photo
  Future<Either<Failure, UserProfile>> removeProfilePhoto(String uid) async {
    try {
      Log.debug('Removing profile photo for user: $uid');

      // Delete photo from cloud storage
      await _profileRepository.deleteProfilePhoto(uid);

      // Update profile to remove photo URL
      return await updateField(uid, 'photoUrl', null).then((result) async {
        if (result.isRight()) {
          // Reload updated profile to return
          final profileResult = await _profileRepository.getProfile(uid);
          return profileResult.fold(
            (failure) => Left(failure),
            (profile) => profile != null
                ? Right(profile)
                : Left(
                    NotFoundFailure(
                      message: 'Profile not found after photo removal',
                    ),
                  ),
          );
        }
        return Left(
          result.fold(
            (l) => l,
            (r) => ServerFailure(message: 'Unexpected success result'),
          ),
        );
      });
    } catch (e) {
      Log.error('Error removing profile photo: $e');
      return Left(
        ServerFailure(message: 'Profile photo removal failed: ${e.toString()}'),
      );
    }
  }

  /// Validate profile update
  Future<Either<Failure, void>> _validateProfileUpdate(
    UserProfile profile,
  ) async {
    try {
      // Basic validation
      if (!profile.isValid) {
        return Left(
          ValidationFailure(message: 'Profile data contains invalid values'),
        );
      }

      // Advanced validation with repository
      final validationResult = await _profileRepository.validateProfileData(
        profile,
      );

      return validationResult.fold((failure) => Left(failure), (
        validationErrors,
      ) {
        if (validationErrors.isNotEmpty) {
          return Left(
            ValidationFailure(
              message:
                  'Profile validation failed: ${validationErrors.join(', ')}',
            ),
          );
        }
        return const Right(null);
      });
    } catch (e) {
      Log.error('Error during profile validation: $e');
      return Left(
        ValidationFailure(message: 'Profile validation error: ${e.toString()}'),
      );
    }
  }

  /// Validate single field update
  Either<Failure, void> _validateFieldUpdate(String field, dynamic value) {
    try {
      // Field-specific validation
      switch (field) {
        case 'email':
          if (value != null && !_isValidEmail(value as String)) {
            return Left(ValidationFailure(message: 'Invalid email format'));
          }
          break;
        case 'phoneNumber':
          if (value != null && !_isValidPhoneNumber(value as String)) {
            return Left(
              ValidationFailure(message: 'Invalid phone number format'),
            );
          }
          break;
        case 'gameLevel':
          if (value != null && (value as int) < 1) {
            return Left(
              ValidationFailure(message: 'Game level must be positive'),
            );
          }
          break;
        case 'experiencePoints':
          if (value != null && (value as int) < 0) {
            return Left(
              ValidationFailure(
                message: 'Experience points cannot be negative',
              ),
            );
          }
          break;
        case 'winRate':
          if (value != null) {
            final rate = value as double;
            if (rate < 0.0 || rate > 1.0) {
              return Left(
                ValidationFailure(message: 'Win rate must be between 0 and 1'),
              );
            }
          }
          break;
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ValidationFailure(message: 'Field validation error: ${e.toString()}'),
      );
    }
  }

  /// Log profile update activity
  void _logUpdateActivity(UserProfile before, UserProfile after) {
    try {
      final changes = <String>[];

      if (before.displayName != after.displayName) changes.add('displayName');
      if (before.firstName != after.firstName) changes.add('firstName');
      if (before.lastName != after.lastName) changes.add('lastName');
      if (before.phoneNumber != after.phoneNumber) changes.add('phoneNumber');
      if (before.photoUrl != after.photoUrl) changes.add('photoUrl');
      if (before.timezone != after.timezone) changes.add('timezone');
      if (before.marketingConsent != after.marketingConsent) {
        changes.add('marketingConsent');
      }
      if (before.analyticsConsent != after.analyticsConsent) {
        changes.add('analyticsConsent');
      }

      if (changes.isNotEmpty) {
        _profileRepository.logActivity(after.uid, 'profile_updated', {
          'changed_fields': changes,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      Log.warning('Failed to log update activity: $e');
    }
  }

  /// Notify observers of profile update
  void _notifyProfileUpdate(UserProfile before, UserProfile after) {
    try {
      _eventManager.profileUpdated(after.uid, {
        'before': before.getExportData(),
        'after': after.getExportData(),
      });
    } catch (e) {
      Log.warning('Failed to notify profile update: $e');
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  /// Validate phone number format (basic validation)
  bool _isValidPhoneNumber(String phone) {
    return phone.length >= 10 && RegExp(r'^[+\d\s()-]+$').hasMatch(phone);
  }
}
