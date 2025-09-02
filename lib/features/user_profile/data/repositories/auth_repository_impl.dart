/// Authentication Repository Implementation
///
/// PATTERN: Repository - Data access abstraction
/// WHERE: Data layer implementing domain repository contract
/// HOW: Coordinates authentication operations between use cases and data sources
/// WHY: Isolates data access implementation from domain logic
library;

import 'package:design_patterns/core/error/failures.dart' as core_failures;
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/utils/result.dart';
import 'package:design_patterns/features/user_profile/data/data_sources/firebase_auth_datasource.dart';
import 'package:design_patterns/features/user_profile/data/models/auth_credentials_model.dart';
import 'package:design_patterns/features/user_profile/domain/entities/auth_credentials.dart';
import 'package:design_patterns/features/user_profile/domain/entities/auth_result.dart';
import 'package:design_patterns/features/user_profile/domain/entities/user_profile.dart';
import 'package:design_patterns/features/user_profile/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Repository implementation for authentication operations
///
/// PATTERN: Repository - Authentication data access coordination
///
/// In Tower Defense context, this repository handles authentication
/// operations by coordinating between domain use cases and Firebase
/// Auth datasource, providing a clean interface for authentication.
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;

  AuthRepositoryImpl({required AuthDataSource authDataSource})
    : _authDataSource = authDataSource {
    Log.debug('AuthRepositoryImpl initialized');
  }

  /// Convert Result< T, Exception > to Either< Failure, T >
  Either<core_failures.Failure, T> _resultToEither<T>(
    Result<T, Exception> result,
  ) {
    return result.fold(
      (exception) =>
          Left(core_failures.ServerFailure(message: exception.toString())),
      (value) => Right(value),
    );
  }

  @override
  Future<Either<core_failures.Failure, AuthResult>> signIn(
    AuthCredentials credentials,
  ) async {
    try {
      Log.debug('AuthRepository: Signing in with email/password');

      // Convert domain entity to data model
      final credentialsModel = credentials is AuthCredentialsModel
          ? credentials
          : AuthCredentialsModel.fromEntity(credentials);

      // Validate credentials
      if (!credentialsModel.isValid) {
        Log.warning('Invalid credentials provided for email/password sign-in');
        return Left(
          core_failures.ValidationFailure(
            message: 'Invalid email or password credentials',
          ),
        );
      }

      // Call data source
      final result = await _authDataSource.signInWithEmailAndPassword(
        credentialsModel,
      );

      // Convert Result to Either using helper
      return _resultToEither(result);
    } catch (e) {
      Log.error('AuthRepository: Unexpected error during sign-in - $e');
      return Left(core_failures.ServerFailure(message: 'Sign-in failed: $e'));
    }
  }

  @override
  Future<Either<core_failures.Failure, AuthResult>> signUp(
    AuthCredentials credentials,
  ) async {
    try {
      Log.debug('AuthRepository: Registering with email/password');

      // Convert domain entity to data model
      final credentialsModel = credentials is AuthCredentialsModel
          ? credentials
          : AuthCredentialsModel.fromEntity(credentials);

      // Validate credentials
      if (!credentialsModel.isValid) {
        Log.warning('Invalid credentials provided for registration');
        return Left(
          core_failures.ValidationFailure(
            message: 'Invalid email or password credentials',
          ),
        );
      }

      // Call data source
      final result = await _authDataSource.registerWithEmailAndPassword(
        credentialsModel,
        acceptedTerms: true,
        privacyConsent: true,
      );

      // Convert Result to Either using helper
      return _resultToEither(result);
    } catch (e) {
      Log.error('AuthRepository: Unexpected error during registration - $e');
      return Left(
        core_failures.ServerFailure(message: 'Registration failed: $e'),
      );
    }
  }

  Future<Result<AuthResult, Exception>> signInWithGoogle() async {
    try {
      Log.debug('AuthRepository: Signing in with Google');

      final result = await _authDataSource.signInWithGoogle();

      return result.fold(
        (failure) {
          Log.error('AuthRepository: Google sign-in failed - $failure');
          return Result.failure(failure);
        },
        (authResult) {
          Log.success('AuthRepository: Google sign-in successful');
          return Result.success(authResult);
        },
      );
    } catch (e) {
      Log.error('AuthRepository: Unexpected error during Google sign-in - $e');
      return Result.failure(Exception('Google sign-in failed: $e'));
    }
  }

  Future<Result<AuthResult, Exception>> signInWithApple() async {
    try {
      Log.debug('AuthRepository: Signing in with Apple');

      final result = await _authDataSource.signInWithApple();

      return result.fold(
        (failure) {
          Log.error('AuthRepository: Apple sign-in failed - $failure');
          return Result.failure(failure);
        },
        (authResult) {
          Log.success('AuthRepository: Apple sign-in successful');
          return Result.success(authResult);
        },
      );
    } catch (e) {
      Log.error('AuthRepository: Unexpected error during Apple sign-in - $e');
      return Result.failure(Exception('Apple sign-in failed: $e'));
    }
  }

  @override
  Future<Either<core_failures.Failure, AuthResult>> signInAnonymously() async {
    try {
      Log.debug('AuthRepository: Signing in anonymously');

      final result = await _authDataSource.signInAnonymously();

      // Convert Result to Either using helper
      return _resultToEither(result);
    } catch (e) {
      Log.error(
        'AuthRepository: Unexpected error during anonymous sign-in - $e',
      );
      return Left(
        core_failures.ServerFailure(message: 'Anonymous sign-in failed: $e'),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, void>> signOut() async {
    try {
      Log.debug('AuthRepository: Signing out user');

      final result = await _authDataSource.signOut();

      // Convert Result to Either using helper
      return _resultToEither(result);
    } catch (e) {
      Log.error('AuthRepository: Unexpected error during sign-out - $e');
      return Left(core_failures.ServerFailure(message: 'Sign-out failed: $e'));
    }
  }

  Future<Result<void, Exception>> deleteCurrentUser() async {
    try {
      Log.warning('AuthRepository: Deleting current user account');

      final result = await _authDataSource.deleteAccount();

      return result.fold(
        (failure) {
          Log.error('AuthRepository: Account deletion failed - $failure');
          return Result.failure(failure);
        },
        (_) {
          Log.success('AuthRepository: Account deletion successful');
          return Result.success(null);
        },
      );
    } catch (e) {
      Log.error(
        'AuthRepository: Unexpected error during account deletion - $e',
      );
      return Result.failure(Exception('Account deletion failed: $e'));
    }
  }

  String? getCurrentUserId() {
    try {
      final user = _authDataSource.getCurrentUser();
      final uid = user?.uid;

      if (uid != null) {
        Log.debug('AuthRepository: Current user ID retrieved');
      } else {
        Log.debug('AuthRepository: No current user');
      }

      return uid;
    } catch (e) {
      Log.error('AuthRepository: Error getting current user ID - $e');
      return null;
    }
  }

  bool isUserSignedIn() {
    try {
      final user = _authDataSource.getCurrentUser();
      final isSignedIn = user != null;

      Log.debug('AuthRepository: User signed in status - $isSignedIn');
      return isSignedIn;
    } catch (e) {
      Log.error('AuthRepository: Error checking sign-in status - $e');
      return false;
    }
  }

  @override
  Stream<Either<core_failures.Failure, UserProfile?>> authStateChanges() {
    try {
      Log.debug('AuthRepository: Setting up auth state changes stream');

      return _authDataSource.authStateChanges().map((user) {
        final uid = user?.uid;
        if (uid != null) {
          Log.debug('AuthRepository: User authenticated - $uid');
          // Return success with null profile (profile should be loaded separately)
          return Right<core_failures.Failure, UserProfile?>(null);
        } else {
          Log.debug('AuthRepository: User signed out');
          return Right<core_failures.Failure, UserProfile?>(null);
        }
      });
    } catch (e) {
      Log.error('AuthRepository: Error setting up auth state stream - $e');
      return Stream.value(
        Left(core_failures.ServerFailure(message: 'Auth state error: $e')),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, void>> sendEmailVerification() async {
    try {
      Log.debug('AuthRepository: Sending email verification');

      if (_authDataSource is FirebaseAuthDataSource) {
        final firebaseSource = _authDataSource;
        final result = await firebaseSource.sendEmailVerification();

        // Convert Result to Either using helper
        return _resultToEither(result);
      } else {
        Log.warning(
          'AuthRepository: Email verification not supported by current data source',
        );
        return Left(
          core_failures.ServerFailure(
            message: 'Email verification not supported',
          ),
        );
      }
    } catch (e) {
      Log.error(
        'AuthRepository: Unexpected error sending email verification - $e',
      );
      return Left(
        core_failures.ServerFailure(message: 'Email verification failed: $e'),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, void>> sendPasswordResetEmail(
    String email,
  ) async {
    try {
      Log.debug('AuthRepository: Sending password reset email to $email');

      if (_authDataSource is FirebaseAuthDataSource) {
        final firebaseSource = _authDataSource;
        final result = await firebaseSource.sendPasswordResetEmail(email);

        // Convert Result to Either using helper
        return _resultToEither(result);
      } else {
        Log.warning(
          'AuthRepository: Password reset not supported by current data source',
        );
        return Left(
          core_failures.ServerFailure(message: 'Password reset not supported'),
        );
      }
    } catch (e) {
      Log.error('AuthRepository: Unexpected error sending password reset - $e');
      return Left(
        core_failures.ServerFailure(message: 'Password reset failed: $e'),
      );
    }
  }

  Future<Result<void, Exception>> reloadCurrentUser() async {
    try {
      Log.debug('AuthRepository: Reloading current user data');

      if (_authDataSource is FirebaseAuthDataSource) {
        final firebaseSource = _authDataSource;
        final result = await firebaseSource.reloadUser();

        return result.fold(
          (failure) {
            Log.error('AuthRepository: User reload failed - $failure');
            return Result.failure(failure);
          },
          (_) {
            Log.success('AuthRepository: User data reloaded');
            return Result.success(null);
          },
        );
      } else {
        Log.warning(
          'AuthRepository: User reload not supported by current data source',
        );
        return Result.failure(Exception('User reload not supported'));
      }
    } catch (e) {
      Log.error('AuthRepository: Unexpected error reloading user - $e');
      return Result.failure(Exception('User reload failed: $e'));
    }
  }

  /// Get authentication status information
  Map<String, dynamic> getAuthStatus() {
    try {
      final user = _authDataSource.getCurrentUser();

      return {
        'is_signed_in': user != null,
        'user_id': user?.uid,
        'email': user?.email,
        'display_name': user?.displayName,
        'email_verified': user?.emailVerified ?? false,
        'is_anonymous': user?.isAnonymous ?? false,
        'provider_data': user?.providerData
            .map(
              (info) => {
                'provider_id': info.providerId,
                'uid': info.uid,
                'display_name': info.displayName,
                'email': info.email,
                'phone_number': info.phoneNumber,
                'photo_url': info.photoURL,
              },
            )
            .toList(),
      };
    } catch (e) {
      Log.error('AuthRepository: Error getting auth status - $e');
      return {'error': e.toString()};
    }
  }

  // STUB IMPLEMENTATIONS - Basic implementations to satisfy interface
  // These can be expanded with full functionality as needed

  @override
  Future<Either<core_failures.Failure, bool>> isSignedIn() async {
    try {
      final user = _authDataSource.getCurrentUser();
      return Right(user != null);
    } catch (e) {
      return Left(
        core_failures.ServerFailure(
          message: 'Failed to check sign-in status: $e',
        ),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, UserProfile?>> getCurrentUser() async {
    try {
      final user = _authDataSource.getCurrentUser();
      if (user == null) return const Right(null);

      // Return basic user profile stub
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
      return Right(profile);
    } catch (e) {
      return Left(
        core_failures.ServerFailure(message: 'Failed to get current user: $e'),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, void>> refreshToken() async {
    Log.warning('refreshToken not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, void>> updatePassword(
    String newPassword,
  ) async {
    Log.warning('updatePassword not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, void>> updateEmail(
    String newEmail,
  ) async {
    Log.warning('updateEmail not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, void>> reauthenticate(
    AuthCredentials credentials,
  ) async {
    Log.warning('reauthenticate not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, void>> deleteAccount() async {
    try {
      final result = await _authDataSource.deleteAccount();
      return _resultToEither(result);
    } catch (e) {
      return Left(
        core_failures.ServerFailure(message: 'Failed to delete account: $e'),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, void>> linkProvider(
    AuthCredentials credentials,
  ) async {
    Log.warning('linkProvider not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, void>> unlinkProvider(
    AuthProviderType provider,
  ) async {
    Log.warning('unlinkProvider not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, List<AuthProviderType>>>
  getLinkedProviders() async {
    Log.warning('getLinkedProviders not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, bool>> isEmailVerified() async {
    try {
      final user = _authDataSource.getCurrentUser();
      return Right(user?.emailVerified ?? false);
    } catch (e) {
      return Left(
        core_failures.ServerFailure(
          message: 'Failed to check email verification: $e',
        ),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, Map<String, dynamic>>>
  getSessionInfo() async {
    try {
      final authStatus = getAuthStatus();
      return Right(authStatus);
    } catch (e) {
      return Left(
        core_failures.ServerFailure(message: 'Failed to get session info: $e'),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, void>> setPersistentAuth(
    bool enabled,
  ) async {
    Log.warning('setPersistentAuth not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }

  @override
  Future<Either<core_failures.Failure, bool>> validateToken() async {
    try {
      final user = _authDataSource.getCurrentUser();
      return Right(user != null);
    } catch (e) {
      return Left(
        core_failures.ServerFailure(message: 'Failed to validate token: $e'),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, String?>> getIdToken() async {
    try {
      final user = _authDataSource.getCurrentUser();
      if (user == null) return const Right(null);

      final token = await user.getIdToken();
      return Right(token);
    } catch (e) {
      return Left(
        core_failures.ServerFailure(message: 'Failed to get ID token: $e'),
      );
    }
  }

  @override
  Future<Either<core_failures.Failure, AuthResult>> convertAnonymousAccount(
    AuthCredentials credentials,
  ) async {
    Log.warning('convertAnonymousAccount not implemented yet');
    return Left(core_failures.ServerFailure(message: 'Method not implemented'));
  }
}
