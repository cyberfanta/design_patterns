/// Sign Up User Use Case - Clean Architecture Domain Layer
///
/// PATTERN: Command - Encapsulates user registration operation
/// WHERE: Domain layer use cases for user registration
/// HOW: Single responsibility class coordinating registration and validation
/// WHY: Centralizes registration logic with business rules and validation
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/user_profile/domain/entities/auth_credentials.dart';
import 'package:design_patterns/features/user_profile/domain/entities/auth_result.dart';
import 'package:design_patterns/features/user_profile/domain/entities/user_profile.dart';
import 'package:design_patterns/features/user_profile/domain/repositories/auth_repository.dart';
import 'package:design_patterns/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:design_patterns/features/user_profile/domain/services/game_event_manager.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for registering new users with various authentication methods
///
/// In the Tower Defense context, this handles new player registration
/// through email/password, OAuth providers, ensuring GDPR compliance
/// and proper profile initialization.
class SignUpUser {
  final AuthRepository _authRepository;
  final UserProfileRepository _profileRepository;
  final GameEventManager _eventManager;

  const SignUpUser(
    this._authRepository,
    this._profileRepository,
    this._eventManager,
  );

  /// Execute user registration operation
  ///
  /// Parameters:
  /// - [credentials]: Authentication credentials for registration
  /// - [profileData]: Additional profile data for new user
  /// - [acceptedTerms]: Whether user accepted terms and conditions
  /// - [privacyConsent]: Whether user consented to privacy policy
  ///
  /// Returns [AuthResult] with new user data or error information
  Future<Either<Failure, AuthResult>> execute(
    AuthCredentials credentials, {
    Map<String, dynamic>? profileData,
    required bool acceptedTerms,
    required bool privacyConsent,
  }) async {
    try {
      Log.debug(
        'Attempting user registration with ${credentials.providerDisplayName}',
      );

      // Validate registration requirements
      final validationResult = _validateRegistration(
        credentials,
        acceptedTerms,
        privacyConsent,
      );

      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(), // This should never happen
        );
      }

      // Set persistent authentication based on user preference
      await _authRepository.setPersistentAuth(credentials.keepLoggedIn);

      // Attempt user registration
      final authResult = await _authRepository.signUp(credentials);

      return authResult.fold(
        (failure) async {
          Log.error('User registration failed: ${failure.toString()}');
          return Left(failure);
        },
        (result) async {
          if (!result.isSuccess) {
            Log.warning('Registration failed: ${result.errorMessage}');
            return Right(result);
          }

          Log.success(
            'User registration successful: ${result.userProfile?.email}',
          );

          // Create comprehensive user profile
          return await _createNewUserProfile(
            result,
            profileData,
            acceptedTerms,
            privacyConsent,
          );
        },
      );
    } catch (e) {
      Log.error('Unexpected error during registration: $e');
      return Left(
        ServerFailure(
          message: 'Registration operation failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Validate registration requirements
  Either<Failure, void> _validateRegistration(
    AuthCredentials credentials,
    bool acceptedTerms,
    bool privacyConsent,
  ) {
    try {
      // Validate credentials
      if (!credentials.isValid) {
        Log.error('Invalid credentials provided for registration');
        return Left(
          ValidationFailure(message: 'Invalid registration credentials'),
        );
      }

      // Ensure terms acceptance
      if (!acceptedTerms) {
        Log.error('Terms and conditions not accepted');
        return Left(
          ValidationFailure(
            message: 'You must accept the terms and conditions to register',
          ),
        );
      }

      // Ensure privacy consent (GDPR compliance)
      if (!privacyConsent) {
        Log.error('Privacy policy not accepted');
        return Left(
          ValidationFailure(
            message: 'You must accept the privacy policy to register',
          ),
        );
      }

      // Additional email validation for email/password registration
      if (credentials.providerType == AuthProviderType.email) {
        final email = credentials.email;
        if (email == null || !_isValidEmail(email)) {
          return Left(
            ValidationFailure(message: 'Please provide a valid email address'),
          );
        }

        final password = credentials.password;
        if (password == null || !_isValidPassword(password)) {
          return Left(
            ValidationFailure(
              message: 'Password must be at least 6 characters long',
            ),
          );
        }
      }

      Log.debug('Registration validation successful');
      return const Right(null);
    } catch (e) {
      Log.error('Error during registration validation: $e');
      return Left(
        ValidationFailure(
          message: 'Registration validation failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Create comprehensive user profile after successful registration
  Future<Either<Failure, AuthResult>> _createNewUserProfile(
    AuthResult authResult,
    Map<String, dynamic>? profileData,
    bool acceptedTerms,
    bool privacyConsent,
  ) async {
    try {
      final authProfile = authResult.userProfile!;
      final now = DateTime.now();

      // Build comprehensive profile
      final newProfile = UserProfile(
        uid: authProfile.uid,
        email: authProfile.email,
        displayName: authProfile.displayName ?? profileData?['displayName'],
        firstName: profileData?['firstName'],
        lastName: profileData?['lastName'],
        photoUrl: authProfile.photoUrl,
        phoneNumber: profileData?['phoneNumber'],
        deviceModel: profileData?['deviceModel'],
        authProvider: authProfile.authProvider,
        createdAt: now,
        lastUpdated: now,
        lastLogin: now,
        keepLoggedIn: authProfile.keepLoggedIn,
        acceptedTerms: acceptedTerms,
        privacyPolicyAcceptedAt: privacyConsent ? now : null,
        marketingConsent: profileData?['marketingConsent'] ?? false,
        analyticsConsent: profileData?['analyticsConsent'] ?? false,
        accountStatus: 'active',
        preferredLanguage: profileData?['preferredLanguage'] ?? 'en',
        timezone: profileData?['timezone'],
        gameLevel: 1,
        experiencePoints: 0,
        gamesPlayed: 0,
        gamesWon: 0,
        winRate: 0.0,
      );

      // Calculate and set profile completeness
      final completeProfile = newProfile.copyWith(
        profileCompleteness: newProfile.calculateCompleteness(),
      );

      final createResult = await _profileRepository.createProfile(
        completeProfile,
      );

      return createResult.fold(
        (failure) {
          Log.error('Failed to create user profile: ${failure.toString()}');

          // Attempt to clean up orphaned auth account
          _cleanupFailedRegistration(authProfile.uid);

          return Left(
            ServerFailure(
              message: 'Registration failed: Could not create user profile',
            ),
          );
        },
        (createdProfile) {
          Log.success('User profile created successfully');

          // Log user activity
          _logRegistrationActivity(createdProfile);

          // Notify observers of successful registration
          _eventManager.userRegistered(
            createdProfile.uid,
            createdProfile.authProvider,
          );

          // Send welcome email if enabled
          _scheduleWelcomeActions(createdProfile);

          return Right(
            AuthResult.success(
              userProfile: createdProfile,
              isNewUser: true,
              additionalData: {
                ...?authResult.additionalData,
                'profile_completeness': createdProfile.profileCompleteness,
                'registration_source': createdProfile.authProvider,
              },
            ),
          );
        },
      );
    } catch (e) {
      Log.error('Error creating user profile: $e');
      return Left(
        ServerFailure(message: 'Profile creation failed: ${e.toString()}'),
      );
    }
  }

  /// Clean up orphaned authentication account after profile creation failure
  void _cleanupFailedRegistration(String uid) {
    try {
      Log.warning('Attempting to cleanup failed registration for user: $uid');
      // In a real implementation, this would delete the auth account
      // For now, just log the attempt
      Log.debug('Cleanup scheduled for user: $uid');
    } catch (e) {
      Log.error('Failed to cleanup orphaned auth account: $e');
    }
  }

  /// Log user registration activity
  void _logRegistrationActivity(UserProfile profile) {
    try {
      _profileRepository.logActivity(profile.uid, 'user_registered', {
        'auth_provider': profile.authProvider,
        'profile_completeness': profile.profileCompleteness,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Log.warning('Failed to log registration activity: $e');
    }
  }

  /// Schedule welcome actions for new user
  void _scheduleWelcomeActions(UserProfile profile) {
    try {
      // In a real implementation, this would schedule:
      // - Welcome email
      // - Push notification setup
      // - Tutorial flags
      // - First-time user bonuses
      Log.debug('Welcome actions scheduled for user: ${profile.email}');
    } catch (e) {
      Log.warning('Failed to schedule welcome actions: $e');
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  /// Validate password strength
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Register with email and password
  Future<Either<Failure, AuthResult>> registerWithEmail(
    String email,
    String password, {
    String? displayName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool keepLoggedIn = false,
    bool marketingConsent = false,
    bool analyticsConsent = false,
    required bool acceptedTerms,
    required bool privacyConsent,
  }) async {
    final credentials = AuthCredentials.emailPassword(
      email: email,
      password: password,
      keepLoggedIn: keepLoggedIn,
    );

    final profileData = <String, dynamic>{
      if (displayName != null) 'displayName': displayName,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'marketingConsent': marketingConsent,
      'analyticsConsent': analyticsConsent,
    };

    return execute(
      credentials,
      profileData: profileData,
      acceptedTerms: acceptedTerms,
      privacyConsent: privacyConsent,
    );
  }

  /// Convert anonymous account to permanent account
  Future<Either<Failure, AuthResult>> convertAnonymousAccount(
    AuthCredentials credentials, {
    Map<String, dynamic>? profileData,
    required bool acceptedTerms,
    required bool privacyConsent,
  }) async {
    try {
      Log.debug('Converting anonymous account to permanent account');

      // Validate conversion requirements
      final validationResult = _validateRegistration(
        credentials,
        acceptedTerms,
        privacyConsent,
      );

      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(), // This should never happen
        );
      }

      // Convert anonymous account
      final conversionResult = await _authRepository.convertAnonymousAccount(
        credentials,
      );

      return conversionResult.fold(
        (failure) {
          Log.error(
            'Anonymous account conversion failed: ${failure.toString()}',
          );
          return Left(failure);
        },
        (result) async {
          if (!result.isSuccess) {
            return Right(result);
          }

          // Update profile with permanent account data
          return await _updateAnonymousProfile(
            result,
            profileData,
            acceptedTerms,
            privacyConsent,
          );
        },
      );
    } catch (e) {
      Log.error('Error converting anonymous account: $e');
      return Left(
        ServerFailure(message: 'Account conversion failed: ${e.toString()}'),
      );
    }
  }

  /// Update anonymous profile to permanent profile
  Future<Either<Failure, AuthResult>> _updateAnonymousProfile(
    AuthResult authResult,
    Map<String, dynamic>? profileData,
    bool acceptedTerms,
    bool privacyConsent,
  ) async {
    try {
      final authProfile = authResult.userProfile!;

      // Load existing anonymous profile
      final profileResult = await _profileRepository.getProfile(
        authProfile.uid,
      );

      return profileResult.fold(
        (failure) {
          Log.error('Could not load anonymous profile: ${failure.toString()}');
          return Left(failure);
        },
        (existingProfile) async {
          if (existingProfile == null) {
            // Create new profile if none exists
            return await _createNewUserProfile(
              authResult,
              profileData,
              acceptedTerms,
              privacyConsent,
            );
          }

          // Update existing anonymous profile
          final updatedProfile = existingProfile.copyWith(
            email: authProfile.email,
            displayName: authProfile.displayName ?? profileData?['displayName'],
            firstName: profileData?['firstName'],
            lastName: profileData?['lastName'],
            phoneNumber: profileData?['phoneNumber'],
            authProvider: authProfile.authProvider,
            acceptedTerms: acceptedTerms,
            privacyPolicyAcceptedAt: privacyConsent ? DateTime.now() : null,
            marketingConsent: profileData?['marketingConsent'] ?? false,
            analyticsConsent: profileData?['analyticsConsent'] ?? false,
            accountStatus: 'active',
            lastUpdated: DateTime.now(),
          );

          final updateResult = await _profileRepository.updateProfile(
            updatedProfile.copyWith(
              profileCompleteness: updatedProfile.calculateCompleteness(),
            ),
          );

          return updateResult.fold(
            (failure) {
              Log.error(
                'Failed to update anonymous profile: ${failure.toString()}',
              );
              return Left(failure);
            },
            (finalProfile) {
              Log.success('Anonymous account converted successfully');

              _eventManager.userRegistered(
                finalProfile.uid,
                finalProfile.authProvider,
              );

              return Right(
                authResult.copyWith(
                  userProfile: finalProfile,
                  isNewUser: false, // Conversion, not new registration
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      Log.error('Error updating anonymous profile: $e');
      return Left(
        ServerFailure(message: 'Profile update failed: ${e.toString()}'),
      );
    }
  }
}
