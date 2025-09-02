/// Sign In User Use Case - Clean Architecture Domain Layer
///
/// PATTERN: Command - Encapsulates user sign-in operation
/// WHERE: Domain layer use cases for authentication management
/// HOW: Single responsibility class coordinating authentication
/// WHY: Centralizes sign-in logic with validation and error handling
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/user_profile/domain/entities/auth_credentials.dart';
import 'package:design_patterns/features/user_profile/domain/entities/auth_result.dart';
import 'package:design_patterns/features/user_profile/domain/repositories/auth_repository.dart';
import 'package:design_patterns/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:design_patterns/features/user_profile/domain/services/game_event_manager.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for signing in users with various authentication methods
///
/// In the Tower Defense context, this handles player authentication
/// through email/password, Google, and Apple sign-in methods.
/// Manages session persistence and profile synchronization.
class SignInUser {
  final AuthRepository _authRepository;
  final UserProfileRepository _profileRepository;
  final GameEventManager _eventManager;

  const SignInUser(
    this._authRepository,
    this._profileRepository,
    this._eventManager,
  );

  /// Execute user sign-in operation
  ///
  /// Parameters:
  /// - [credentials]: Authentication credentials for sign-in
  /// - [createProfileIfMissing]: Create profile if user doesn't have one
  ///
  /// Returns [AuthResult] with user data or error information
  Future<Either<Failure, AuthResult>> execute(
    AuthCredentials credentials, {
    bool createProfileIfMissing = true,
  }) async {
    try {
      Log.debug(
        'Attempting to sign in user with ${credentials.providerDisplayName}',
      );

      // Validate credentials before attempting sign-in
      if (!credentials.isValid) {
        Log.error('Invalid credentials provided for sign-in');
        return Right(AuthResult.invalidCredentials);
      }

      // Set persistent authentication based on user preference
      await _authRepository.setPersistentAuth(credentials.keepLoggedIn);

      // Attempt authentication
      final authResult = await _authRepository.signIn(credentials);

      return authResult.fold(
        (failure) async {
          Log.error('Authentication failed: ${failure.toString()}');
          return Left(failure);
        },
        (result) async {
          if (!result.isSuccess) {
            Log.warning('Sign-in failed: ${result.errorMessage}');
            return Right(result);
          }

          Log.success(
            'Authentication successful for user: ${result.userProfile?.email}',
          );

          // Handle post-authentication tasks
          return await _handlePostSignIn(result, createProfileIfMissing);
        },
      );
    } catch (e) {
      Log.error('Unexpected error during sign-in: $e');
      return Left(
        ServerFailure(message: 'Sign-in operation failed: ${e.toString()}'),
      );
    }
  }

  /// Handle tasks after successful authentication
  Future<Either<Failure, AuthResult>> _handlePostSignIn(
    AuthResult authResult,
    bool createProfileIfMissing,
  ) async {
    try {
      final userProfile = authResult.userProfile!;

      // Check if user profile exists in our database
      final profileExistsResult = await _profileRepository.profileExists(
        userProfile.uid,
      );

      return profileExistsResult.fold(
        (failure) async {
          Log.warning(
            'Could not check profile existence: ${failure.toString()}',
          );
          // Continue with existing profile from auth
          return Right(authResult);
        },
        (profileExists) async {
          if (!profileExists && createProfileIfMissing) {
            Log.info('Creating new user profile for ${userProfile.email}');
            return await _createUserProfile(authResult);
          } else if (!profileExists) {
            Log.warning('User profile does not exist and creation is disabled');
            return Right(
              AuthResult.failure(
                errorMessage: 'User profile not found',
                errorCode: 'profile-not-found',
              ),
            );
          } else {
            // Load existing profile and merge with auth data
            return await _syncExistingProfile(authResult);
          }
        },
      );
    } catch (e) {
      Log.error('Error in post-sign-in handling: $e');
      return Right(
        authResult,
      ); // Return original result if post-processing fails
    }
  }

  /// Create new user profile after first sign-in
  Future<Either<Failure, AuthResult>> _createUserProfile(
    AuthResult authResult,
  ) async {
    try {
      final authProfile = authResult.userProfile!;

      // Create comprehensive profile from auth data
      final newProfile = authProfile.copyWith(
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        acceptedTerms: true,
        // Assumed accepted during sign-up
        privacyPolicyAcceptedAt: DateTime.now(),
        profileCompleteness: authProfile.calculateCompleteness(),
      );

      final createResult = await _profileRepository.createProfile(newProfile);

      return createResult.fold(
        (failure) {
          Log.error('Failed to create user profile: ${failure.toString()}');
          // Return auth result even if profile creation fails
          return Right(authResult);
        },
        (createdProfile) {
          Log.success('User profile created successfully');

          // Notify observers of new user registration
          _eventManager.userRegistered(
            createdProfile.uid,
            createdProfile.authProvider,
          );

          return Right(
            AuthResult.success(
              userProfile: createdProfile,
              isNewUser: true,
              additionalData: authResult.additionalData,
            ),
          );
        },
      );
    } catch (e) {
      Log.error('Error creating user profile: $e');
      return Right(authResult); // Fallback to auth result
    }
  }

  /// Sync existing profile with fresh auth data
  Future<Either<Failure, AuthResult>> _syncExistingProfile(
    AuthResult authResult,
  ) async {
    try {
      final authProfile = authResult.userProfile!;

      // Load existing profile
      final profileResult = await _profileRepository.getProfile(
        authProfile.uid,
      );

      return profileResult.fold(
        (failure) {
          Log.warning('Could not load existing profile: ${failure.toString()}');
          return Right(authResult); // Use auth profile as fallback
        },
        (existingProfile) async {
          if (existingProfile == null) {
            Log.warning('Profile not found despite existence check');
            return Right(authResult);
          }

          // Update profile with fresh auth data and login time
          final updatedProfile = existingProfile.copyWith(
            email: authProfile.email,
            // Update email if changed
            displayName: authProfile.displayName ?? existingProfile.displayName,
            photoUrl: authProfile.photoUrl ?? existingProfile.photoUrl,
            lastLogin: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

          final updateResult = await _profileRepository.updateProfile(
            updatedProfile,
          );

          return updateResult.fold(
            (failure) {
              Log.warning(
                'Failed to update profile on sign-in: ${failure.toString()}',
              );
              return Right(authResult.copyWith(userProfile: existingProfile));
            },
            (finalProfile) {
              Log.debug('Profile synchronized successfully');

              // Notify observers of user sign-in
              _eventManager.userSignedIn(
                finalProfile.uid,
                finalProfile.authProvider,
              );

              return Right(authResult.copyWith(userProfile: finalProfile));
            },
          );
        },
      );
    } catch (e) {
      Log.error('Error syncing existing profile: $e');
      return Right(authResult);
    }
  }

  /// Sign in with email and password
  Future<Either<Failure, AuthResult>> signInWithEmail(
    String email,
    String password, {
    bool keepLoggedIn = false,
  }) async {
    final credentials = AuthCredentials.emailPassword(
      email: email,
      password: password,
      keepLoggedIn: keepLoggedIn,
    );

    return execute(credentials);
  }

  /// Sign in with Google OAuth
  Future<Either<Failure, AuthResult>> signInWithGoogle({
    bool keepLoggedIn = false,
    Map<String, dynamic>? additionalData,
  }) async {
    // Note: In real implementation, Google OAuth would be triggered here
    // and tokens would be obtained from the OAuth flow
    Log.warning('Google sign-in requires OAuth flow implementation');

    return Right(
      AuthResult.failure(
        errorMessage: 'Google sign-in not yet implemented',
        errorCode: 'not-implemented',
      ),
    );
  }

  /// Sign in with Apple OAuth
  Future<Either<Failure, AuthResult>> signInWithApple({
    bool keepLoggedIn = false,
    Map<String, dynamic>? additionalData,
  }) async {
    // Note: In real implementation, Apple OAuth would be triggered here
    // and tokens would be obtained from the OAuth flow
    Log.warning('Apple sign-in requires OAuth flow implementation');

    return Right(
      AuthResult.failure(
        errorMessage: 'Apple sign-in not yet implemented',
        errorCode: 'not-implemented',
      ),
    );
  }

  /// Sign in anonymously for guest access
  Future<Either<Failure, AuthResult>> signInAnonymously() async {
    try {
      Log.debug('Signing in user anonymously');

      final authResult = await _authRepository.signInAnonymously();

      return authResult.fold(
        (failure) {
          Log.error('Anonymous sign-in failed: ${failure.toString()}');
          return Left(failure);
        },
        (result) async {
          if (result.isSuccess) {
            Log.success('Anonymous sign-in successful');

            // Create minimal profile for anonymous user
            return await _handlePostSignIn(result, true);
          }

          return Right(result);
        },
      );
    } catch (e) {
      Log.error('Error during anonymous sign-in: $e');
      return Left(
        ServerFailure(message: 'Anonymous sign-in failed: ${e.toString()}'),
      );
    }
  }
}
