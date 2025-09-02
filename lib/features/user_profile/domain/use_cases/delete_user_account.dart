/// Delete User Account Use Case - Clean Architecture Domain Layer
///
/// PATTERN: Command - Encapsulates account deletion operation
/// WHERE: Domain layer use cases for account management
/// HOW: Single responsibility class handling GDPR-compliant deletion
/// WHY: Centralizes account deletion logic with data protection compliance
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/user_profile/domain/entities/auth_credentials.dart';
import 'package:design_patterns/features/user_profile/domain/entities/user_profile.dart';
import 'package:design_patterns/features/user_profile/domain/repositories/auth_repository.dart';
import 'package:design_patterns/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:design_patterns/features/user_profile/domain/services/game_event_manager.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for deleting user accounts with GDPR compliance
///
/// In the Tower Defense context, this handles complete account deletion
/// including authentication, profile data, game progress, and all
/// associated data in compliance with data protection regulations.
class DeleteUserAccount {
  final AuthRepository _authRepository;
  final UserProfileRepository _profileRepository;
  final GameEventManager _eventManager;

  const DeleteUserAccount(
    this._authRepository,
    this._profileRepository,
    this._eventManager,
  );

  /// Execute account deletion operation
  ///
  /// Parameters:
  /// - [uid]: User ID of account to delete
  /// - [confirmationCredentials]: User credentials for verification
  /// - [deleteImmediately]: Whether to delete immediately or mark for deletion
  /// - [anonymizeData]: Whether to anonymize data instead of hard delete
  ///
  /// Returns success or failure result
  Future<Either<Failure, void>> execute(
    String uid, {
    AuthCredentials? confirmationCredentials,
    bool deleteImmediately = false,
    bool anonymizeData = false,
  }) async {
    try {
      Log.warning('Initiating account deletion for user: $uid');

      // Verify user identity if credentials provided
      if (confirmationCredentials != null) {
        final authResult = await _verifyUserIdentity(confirmationCredentials);
        if (authResult.isLeft()) {
          return authResult;
        }
      }

      // Load user profile for deletion processing
      final profileResult = await _profileRepository.getProfile(uid);

      return profileResult.fold(
        (failure) async {
          Log.error(
            'Could not load user profile for deletion: ${failure.toString()}',
          );
          return Left(failure);
        },
        (profile) async {
          if (profile == null) {
            Log.warning('User profile not found: $uid');
            return Left(NotFoundFailure(message: 'User profile not found'));
          }

          // Process account deletion based on options
          if (anonymizeData) {
            return await _anonymizeUserData(profile);
          } else if (deleteImmediately) {
            return await _deleteAccountImmediately(profile);
          } else {
            return await _markAccountForDeletion(profile);
          }
        },
      );
    } catch (e) {
      Log.error('Unexpected error during account deletion: $e');
      return Left(
        ServerFailure(message: 'Account deletion failed: ${e.toString()}'),
      );
    }
  }

  /// Verify user identity before sensitive operations
  Future<Either<Failure, void>> _verifyUserIdentity(
    AuthCredentials credentials,
  ) async {
    try {
      Log.debug('Verifying user identity for account deletion');

      if (!credentials.isValid) {
        return Left(
          ValidationFailure(
            message: 'Invalid credentials provided for verification',
          ),
        );
      }

      final authResult = await _authRepository.reauthenticate(credentials);

      return authResult.fold(
        (failure) {
          Log.error('User identity verification failed: ${failure.toString()}');
          return Left(failure);
        },
        (_) {
          Log.debug('User identity verified successfully');
          return const Right(null);
        },
      );
    } catch (e) {
      Log.error('Error verifying user identity: $e');
      return Left(
        ServerFailure(message: 'Identity verification failed: ${e.toString()}'),
      );
    }
  }

  /// Mark account for deletion (grace period approach)
  Future<Either<Failure, void>> _markAccountForDeletion(
    UserProfile profile,
  ) async {
    try {
      Log.info('Marking account for deletion: ${profile.uid}');

      // Update profile status to pending deletion
      final markedProfile = profile.markForDeletion();

      final updateResult = await _profileRepository.updateProfile(
        markedProfile,
      );

      return updateResult.fold(
        (failure) {
          Log.error(
            'Failed to mark account for deletion: ${failure.toString()}',
          );
          return Left(failure);
        },
        (_) {
          Log.success('Account marked for deletion: ${profile.uid}');

          // Log deletion request
          _logDeletionActivity(profile, 'marked_for_deletion');

          // Notify observers
          _eventManager.accountMarkedForDeletion(
            profile.uid,
            DateTime.now().add(const Duration(days: 30)),
          );

          // Schedule actual deletion after grace period
          _scheduleDeletionAfterGracePeriod(profile.uid);

          return const Right(null);
        },
      );
    } catch (e) {
      Log.error('Error marking account for deletion: $e');
      return Left(
        ServerFailure(
          message: 'Failed to mark account for deletion: ${e.toString()}',
        ),
      );
    }
  }

  /// Delete account immediately (permanent deletion)
  Future<Either<Failure, void>> _deleteAccountImmediately(
    UserProfile profile,
  ) async {
    try {
      Log.warning('Performing immediate account deletion: ${profile.uid}');

      // Export user data for compliance before deletion
      final exportResult = await _exportUserDataForCompliance(profile);
      exportResult.fold(
        (failure) =>
            Log.warning('Could not export user data: ${failure.toString()}'),
        (_) => Log.debug('User data exported for compliance'),
      );

      // Delete in order: profile data, authentication
      await _deleteAllUserData(profile);
      await _deleteAuthentication(profile.uid);

      Log.success('Account deleted immediately: ${profile.uid}');

      // Log final deletion
      _logDeletionActivity(profile, 'deleted_immediately');

      // Notify observers
      _eventManager.accountDeleted(profile.uid, 'immediate_deletion_requested');

      return const Right(null);
    } catch (e) {
      Log.error('Error during immediate account deletion: $e');
      return Left(
        ServerFailure(message: 'Immediate deletion failed: ${e.toString()}'),
      );
    }
  }

  /// Anonymize user data (GDPR right to be forgotten)
  Future<Either<Failure, void>> _anonymizeUserData(UserProfile profile) async {
    try {
      Log.info('Anonymizing user data: ${profile.uid}');

      // Anonymize profile data
      final anonymizedProfile = profile.anonymize();

      final updateResult = await _profileRepository.updateProfile(
        anonymizedProfile,
      );

      return updateResult.fold(
        (failure) {
          Log.error('Failed to anonymize user data: ${failure.toString()}');
          return Left(failure);
        },
        (_) {
          Log.success('User data anonymized: ${profile.uid}');

          // Delete associated files (photos, etc.)
          _deleteAssociatedFiles(profile.uid);

          // Log anonymization
          _logDeletionActivity(profile, 'anonymized');

          // Notify observers
          _eventManager.accountAnonymized(
            profile.uid,
            'gdpr_anonymization_requested',
          );

          return const Right(null);
        },
      );
    } catch (e) {
      Log.error('Error anonymizing user data: $e');
      return Left(
        ServerFailure(message: 'Data anonymization failed: ${e.toString()}'),
      );
    }
  }

  /// Delete all user data from profile repository
  Future<void> _deleteAllUserData(UserProfile profile) async {
    try {
      Log.debug('Deleting all user data: ${profile.uid}');

      // Delete profile photo
      await _profileRepository.deleteProfilePhoto(profile.uid);

      // Delete profile data
      await _profileRepository.deleteProfile(profile.uid);

      // Delete associated files and data
      await _deleteAssociatedFiles(profile.uid);

      Log.debug('All user data deleted: ${profile.uid}');
    } catch (e) {
      Log.error('Error deleting user data: $e');
      // Continue with deletion process even if some data cleanup fails
    }
  }

  /// Delete user authentication
  Future<void> _deleteAuthentication(String uid) async {
    try {
      Log.debug('Deleting user authentication: $uid');

      final deleteResult = await _authRepository.deleteAccount();

      deleteResult.fold(
        (failure) =>
            Log.error('Authentication deletion failed: ${failure.toString()}'),
        (_) => Log.debug('User authentication deleted: $uid'),
      );
    } catch (e) {
      Log.error('Error deleting authentication: $e');
    }
  }

  /// Delete associated files and data
  Future<void> _deleteAssociatedFiles(String uid) async {
    try {
      Log.debug('Deleting associated files for user: $uid');

      // In a real implementation, this would:
      // - Delete profile photos from storage
      // - Remove cached data
      // - Clean up temporary files
      // - Delete analytics data
      // - Remove from search indices

      Log.debug('Associated files cleanup completed for user: $uid');
    } catch (e) {
      Log.error('Error deleting associated files: $e');
    }
  }

  /// Export user data for compliance purposes
  Future<Either<Failure, Map<String, dynamic>>> _exportUserDataForCompliance(
    UserProfile profile,
  ) async {
    try {
      Log.debug('Exporting user data for compliance: ${profile.uid}');

      return await _profileRepository.exportUserData(profile.uid);
    } catch (e) {
      Log.error('Error exporting user data: $e');
      return Left(
        ServerFailure(message: 'Data export failed: ${e.toString()}'),
      );
    }
  }

  /// Schedule deletion after grace period
  void _scheduleDeletionAfterGracePeriod(String uid) {
    try {
      // In a real implementation, this would schedule a background job
      // to delete the account after a grace period (e.g., 30 days)
      Log.debug('Scheduled deletion after grace period for user: $uid');

      // This could use:
      // - Cloud Functions with scheduled triggers
      // - Background job queue
      // - Cron job system
    } catch (e) {
      Log.error('Error scheduling deletion: $e');
    }
  }

  /// Log account deletion activity
  void _logDeletionActivity(UserProfile profile, String action) {
    try {
      _profileRepository.logActivity(profile.uid, action, {
        'user_email': profile.email,
        'account_age_days': DateTime.now().difference(profile.createdAt).inDays,
        'profile_completeness': profile.profileCompleteness,
        'games_played': profile.gamesPlayed,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Log.warning('Failed to log deletion activity: $e');
    }
  }

  /// Cancel account deletion (during grace period)
  Future<Either<Failure, UserProfile>> cancelAccountDeletion(String uid) async {
    try {
      Log.info('Cancelling account deletion for user: $uid');

      final profileResult = await _profileRepository.getProfile(uid);

      return profileResult.fold((failure) => Left(failure), (profile) async {
        if (profile == null) {
          return Left(NotFoundFailure(message: 'User profile not found'));
        }

        if (profile.accountStatus != 'pending_deletion') {
          return Left(
            ValidationFailure(message: 'Account is not marked for deletion'),
          );
        }

        // Restore account to active status
        final restoredProfile = profile.copyWith(
          accountStatus: 'active',
          lastUpdated: DateTime.now(),
        );

        final updateResult = await _profileRepository.updateProfile(
          restoredProfile,
        );

        return updateResult.fold(
          (failure) {
            Log.error(
              'Failed to cancel account deletion: ${failure.toString()}',
            );
            return Left(failure);
          },
          (updatedProfile) {
            Log.success('Account deletion cancelled: $uid');

            _logDeletionActivity(profile, 'deletion_cancelled');
            _eventManager.accountDeletionCancelled(
              uid,
              'user_requested_cancellation',
            );

            return Right(updatedProfile);
          },
        );
      });
    } catch (e) {
      Log.error('Error cancelling account deletion: $e');
      return Left(
        ServerFailure(message: 'Deletion cancellation failed: ${e.toString()}'),
      );
    }
  }

  /// Get account deletion status
  Future<Either<Failure, Map<String, dynamic>>> getDeletionStatus(
    String uid,
  ) async {
    try {
      final profileResult = await _profileRepository.getProfile(uid);

      return profileResult.fold((failure) => Left(failure), (profile) {
        if (profile == null) {
          return Left(NotFoundFailure(message: 'User profile not found'));
        }

        final status = {
          'account_status': profile.accountStatus,
          'is_marked_for_deletion': profile.accountStatus == 'pending_deletion',
          'can_cancel_deletion': profile.accountStatus == 'pending_deletion',
          'deletion_grace_period_days': 30, // Example grace period
          'last_updated': profile.lastUpdated.toIso8601String(),
        };

        return Right(status);
      });
    } catch (e) {
      Log.error('Error getting deletion status: $e');
      return Left(
        ServerFailure(
          message: 'Could not get deletion status: ${e.toString()}',
        ),
      );
    }
  }
}
