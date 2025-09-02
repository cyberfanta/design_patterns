/// Authentication Repository Contract - Clean Architecture Domain Layer
///
/// PATTERN: Repository - Abstract interface for authentication data access
/// WHERE: Domain layer defining contracts for authentication operations
/// HOW: Abstract class with async methods for auth operations
/// WHY: Decouples authentication logic from data sources, enables testing
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/features/user_profile/domain/entities/auth_credentials.dart';
import 'package:design_patterns/features/user_profile/domain/entities/auth_result.dart';
import 'package:design_patterns/features/user_profile/domain/entities/user_profile.dart';
import 'package:fpdart/fpdart.dart';

/// Abstract repository for managing user authentication
///
/// This contract defines how the domain layer interacts with authentication
/// services, supporting the Tower Defense app's Firebase Authentication
/// integration with multiple providers.
abstract class AuthRepository {
  /// Sign in with credentials
  ///
  /// Authenticates user with provided credentials (email/password, OAuth).
  /// Returns [AuthResult] with user data or error information.
  Future<Either<Failure, AuthResult>> signIn(AuthCredentials credentials);

  /// Sign up new user with credentials
  ///
  /// Creates new user account with provided credentials.
  /// Returns [AuthResult] with user data or error information.
  Future<Either<Failure, AuthResult>> signUp(AuthCredentials credentials);

  /// Sign out current user
  ///
  /// Signs out the currently authenticated user from all sessions.
  Future<Either<Failure, void>> signOut();

  /// Get current authenticated user
  ///
  /// Returns currently authenticated user profile or null if not signed in.
  Future<Either<Failure, UserProfile?>> getCurrentUser();

  /// Check if user is currently signed in
  ///
  /// Returns true if there is an authenticated user session.
  Future<Either<Failure, bool>> isSignedIn();

  /// Refresh authentication token
  ///
  /// Refreshes the current user's authentication token.
  /// Useful for maintaining session validity.
  Future<Either<Failure, void>> refreshToken();

  /// Send password reset email
  ///
  /// Sends password reset email to the specified email address.
  /// Only works with email/password authentication.
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Update user password
  ///
  /// Updates the current user's password. User must be signed in.
  /// Only works with email/password authentication.
  Future<Either<Failure, void>> updatePassword(String newPassword);

  /// Update user email
  ///
  /// Updates the current user's email address. User must be signed in.
  /// May require re-authentication.
  Future<Either<Failure, void>> updateEmail(String newEmail);

  /// Re-authenticate user
  ///
  /// Re-authenticates the current user with fresh credentials.
  /// Required for sensitive operations like email/password changes.
  Future<Either<Failure, void>> reauthenticate(AuthCredentials credentials);

  /// Delete user account
  ///
  /// Permanently deletes the current user account from authentication system.
  /// This action cannot be undone. Used for GDPR compliance.
  Future<Either<Failure, void>> deleteAccount();

  /// Link authentication provider
  ///
  /// Links additional authentication provider to existing account.
  /// Allows user to sign in with multiple methods.
  Future<Either<Failure, void>> linkProvider(AuthCredentials credentials);

  /// Unlink authentication provider
  ///
  /// Removes authentication provider from account.
  /// User must have at least one provider remaining.
  Future<Either<Failure, void>> unlinkProvider(AuthProviderType provider);

  /// Get linked authentication providers
  ///
  /// Returns list of authentication providers linked to current account.
  Future<Either<Failure, List<AuthProviderType>>> getLinkedProviders();

  /// Verify email address
  ///
  /// Sends email verification to current user's email address.
  /// Only applicable for email/password authentication.
  Future<Either<Failure, void>> sendEmailVerification();

  /// Check if email is verified
  ///
  /// Returns true if current user's email address is verified.
  Future<Either<Failure, bool>> isEmailVerified();

  /// Get authentication session info
  ///
  /// Returns information about current authentication session.
  /// Includes provider, login time, expiration, etc.
  Future<Either<Failure, Map<String, dynamic>>> getSessionInfo();

  /// Set persistent authentication mode
  ///
  /// Controls whether authentication persists across app restarts.
  /// Used for "keep me logged in" functionality.
  Future<Either<Failure, void>> setPersistentAuth(bool enabled);

  /// Stream authentication state changes
  ///
  /// Returns stream that emits authentication state changes.
  /// Used for reactive UI updates based on auth status.
  Stream<Either<Failure, UserProfile?>> authStateChanges();

  /// Validate authentication token
  ///
  /// Validates current authentication token with server.
  /// Returns true if token is valid and not expired.
  Future<Either<Failure, bool>> validateToken();

  /// Get ID token for current user
  ///
  /// Returns current user's ID token for API authentication.
  /// Token includes claims and expires after specified duration.
  Future<Either<Failure, String?>> getIdToken();

  /// Sign in anonymously
  ///
  /// Creates anonymous user session for guest access.
  /// Can be upgraded to full account later.
  Future<Either<Failure, AuthResult>> signInAnonymously();

  /// Convert anonymous account to permanent
  ///
  /// Upgrades anonymous account to permanent account with credentials.
  /// Preserves existing user data.
  Future<Either<Failure, AuthResult>> convertAnonymousAccount(
    AuthCredentials credentials,
  );
}
