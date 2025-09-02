/// Firebase Authentication Data Source
///
/// PATTERN: Data Access Object (DAO) - Firebase Auth operations
/// WHERE: Data layer datasource for Firebase Authentication
/// HOW: Implements authentication operations with Firebase Auth SDK
/// WHY: Isolates Firebase Auth implementation from business logic
library;

import 'dart:io';

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/utils/result.dart';
import 'package:design_patterns/features/user_profile/data/models/auth_credentials_model.dart';
import 'package:design_patterns/features/user_profile/data/models/auth_result_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Abstract interface for authentication data source
abstract class AuthDataSource {
  Future<Result<AuthResultModel, Exception>> signInWithEmailAndPassword(
    AuthCredentialsModel credentials,
  );

  Future<Result<AuthResultModel, Exception>> registerWithEmailAndPassword(
    AuthCredentialsModel credentials, {
    required bool acceptedTerms,
    required bool privacyConsent,
  });

  Future<Result<AuthResultModel, Exception>> signInWithGoogle();

  Future<Result<AuthResultModel, Exception>> signInWithApple();

  Future<Result<AuthResultModel, Exception>> signInAnonymously();

  Future<Result<void, Exception>> signOut();

  Future<Result<void, Exception>> deleteAccount();

  User? getCurrentUser();

  Stream<User?> authStateChanges();
}

/// Firebase implementation of authentication data source
///
/// PATTERN: Data Access Object - Firebase Auth integration
///
/// In Tower Defense context, this datasource handles all Firebase
/// authentication operations including email/password, Google, Apple,
/// and anonymous authentication with proper error handling.
class FirebaseAuthDataSource implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final DeviceInfoPlugin _deviceInfo;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    DeviceInfoPlugin? deviceInfo,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _deviceInfo = deviceInfo ?? DeviceInfoPlugin() {
    Log.debug('FirebaseAuthDataSource initialized');

    // Initialize GoogleSignIn - configuration will be handled by platform setup
  }

  @override
  Future<Result<AuthResultModel, Exception>> signInWithEmailAndPassword(
    AuthCredentialsModel credentials,
  ) async {
    try {
      if (!credentials.isValid) {
        return Result.failure(Exception('Invalid email/password credentials'));
      }

      Log.debug('Signing in with email: ${credentials.email}');

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: credentials.email!,
        password: credentials.password!,
      );

      final deviceModel = await _getDeviceModel();

      final result = AuthResultModel.fromFirebaseUser(
        credential: userCredential,
        authProvider: 'email_password',
        deviceModel: deviceModel,
        metadata: {
          'sign_in_method': 'email_password',
          'device_model': deviceModel,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      Log.success('User signed in successfully: ${userCredential.user?.uid}');
      return Result.success(result);
    } on FirebaseAuthException catch (e) {
      Log.error('Firebase Auth error during sign-in: ${e.code} - ${e.message}');
      return Result.failure(AuthResultModel.failure(exception: e) as Exception);
    } catch (e) {
      Log.error('Unexpected error during sign-in: $e');
      return Result.failure(Exception('Sign-in failed: $e'));
    }
  }

  @override
  Future<Result<AuthResultModel, Exception>> registerWithEmailAndPassword(
    AuthCredentialsModel credentials, {
    required bool acceptedTerms,
    required bool privacyConsent,
  }) async {
    try {
      if (!credentials.isValid) {
        return Result.failure(Exception('Invalid email/password credentials'));
      }

      if (!acceptedTerms || !privacyConsent) {
        return Result.failure(
          Exception('Terms and privacy consent are required'),
        );
      }

      Log.debug('Registering user with email: ${credentials.email}');

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: credentials.email!,
        password: credentials.password!,
      );

      // Update display name if provided
      if (credentials.displayName != null) {
        await userCredential.user?.updateDisplayName(credentials.displayName);
        await userCredential.user?.reload();
      }

      // Send email verification
      if (!userCredential.user!.emailVerified) {
        await userCredential.user?.sendEmailVerification();
        Log.debug('Email verification sent to: ${credentials.email}');
      }

      final deviceModel = await _getDeviceModel();
      final now = DateTime.now();

      final result = AuthResultModel.fromFirebaseUser(
        credential: userCredential,
        authProvider: 'email_password',
        deviceModel: deviceModel,
        acceptedTermsAt: now,
        privacyConsentAt: now,
        metadata: {
          'sign_in_method': 'email_password',
          'device_model': deviceModel,
          'timestamp': now.toIso8601String(),
          'accepted_terms': acceptedTerms,
          'privacy_consent': privacyConsent,
        },
      );

      Log.success('User registered successfully: ${userCredential.user?.uid}');
      return Result.success(result);
    } on FirebaseAuthException catch (e) {
      Log.error(
        'Firebase Auth error during registration: ${e.code} - ${e.message}',
      );
      return Result.failure(AuthResultModel.failure(exception: e) as Exception);
    } catch (e) {
      Log.error('Unexpected error during registration: $e');
      return Result.failure(Exception('Registration failed: $e'));
    }
  }

  @override
  Future<Result<AuthResultModel, Exception>> signInWithGoogle() async {
    try {
      Log.debug('Initiating Google sign-in');

      // For now, use a simplified approach - disable Google Sign-In until properly configured
      Log.warning(
        'Google Sign-In temporarily disabled - requires platform configuration',
      );
      return Result.failure(
        Exception(
          'Google Sign-In not available - please configure platform setup first',
        ),
      );

      // TODO: Implement proper GoogleSignIn 7.1.1 API once platform is configured
      // This includes:
      // 1. Platform-specific client ID configuration
      // 2. Proper scopes setup
      // 3. Authentication flow with new API
    } catch (e) {
      Log.error('Unexpected error during Google sign-in: $e');
      return Result.failure(Exception('Google sign-in failed: $e'));
    }
  }

  @override
  Future<Result<AuthResultModel, Exception>> signInWithApple() async {
    try {
      if (!Platform.isIOS && !Platform.isMacOS) {
        return Result.failure(
          Exception('Apple Sign-In is only available on iOS and macOS'),
        );
      }

      Log.debug('Initiating Apple sign-in');

      // Check if Apple Sign In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        return Result.failure(
          Exception('Apple Sign-In is not available on this device'),
        );
      }

      // Request credential for the currently signed in Apple ID
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create a new credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );

      final deviceModel = await _getDeviceModel();

      final result = AuthResultModel.fromFirebaseUser(
        credential: userCredential,
        authProvider: 'apple',
        deviceModel: deviceModel,
        acceptedTermsAt: DateTime.now(),
        // Required for Apple sign-in
        privacyConsentAt: DateTime.now(),
        // Implied by using Apple
        metadata: {
          'sign_in_method': 'apple',
          'device_model': deviceModel,
          'timestamp': DateTime.now().toIso8601String(),
          'apple_user_id': appleCredential.userIdentifier,
        },
      );

      Log.success('Apple sign-in successful: ${userCredential.user?.uid}');
      return Result.success(result);
    } on FirebaseAuthException catch (e) {
      Log.error(
        'Firebase Auth error during Apple sign-in: ${e.code} - ${e.message}',
      );
      return Result.failure(AuthResultModel.failure(exception: e) as Exception);
    } on SignInWithAppleAuthorizationException catch (e) {
      Log.error('Apple sign-in authorization error: ${e.code} - ${e.message}');
      return Result.failure(
        Exception('Apple sign-in authorization failed: ${e.message}'),
      );
    } catch (e) {
      Log.error('Unexpected error during Apple sign-in: $e');
      return Result.failure(Exception('Apple sign-in failed: $e'));
    }
  }

  @override
  Future<Result<AuthResultModel, Exception>> signInAnonymously() async {
    try {
      Log.debug('Signing in anonymously');

      final userCredential = await _firebaseAuth.signInAnonymously();

      final deviceModel = await _getDeviceModel();

      final result = AuthResultModel.fromFirebaseUser(
        credential: userCredential,
        authProvider: 'anonymous',
        deviceModel: deviceModel,
        metadata: {
          'sign_in_method': 'anonymous',
          'device_model': deviceModel,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      Log.success('Anonymous sign-in successful: ${userCredential.user?.uid}');
      return Result.success(result);
    } on FirebaseAuthException catch (e) {
      Log.error(
        'Firebase Auth error during anonymous sign-in: ${e.code} - ${e.message}',
      );
      return Result.failure(AuthResultModel.failure(exception: e) as Exception);
    } catch (e) {
      Log.error('Unexpected error during anonymous sign-in: $e');
      return Result.failure(Exception('Anonymous sign-in failed: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> signOut() async {
    try {
      Log.debug('Signing out user');

      // Sign out from Google if signed in with Google
      // TODO: Implement proper check when GoogleSignIn 7.1.1 is configured
      try {
        await _googleSignIn.signOut();
        Log.debug('Google sign-out completed');
      } catch (e) {
        Log.debug('Google sign-out not needed or failed: $e');
      }

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      Log.success('User signed out successfully');
      return Result.success(null);
    } catch (e) {
      Log.error('Error during sign-out: $e');
      return Result.failure(Exception('Sign-out failed: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(Exception('No user is currently signed in'));
      }

      Log.warning('Deleting user account: ${user.uid}');

      // Sign out from Google if needed
      // TODO: Implement proper check when GoogleSignIn 7.1.1 is configured
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        Log.debug('Google sign-out not needed or failed: $e');
      }

      // Delete the user account
      await user.delete();

      Log.success('User account deleted successfully');
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      Log.error(
        'Firebase Auth error during account deletion: ${e.code} - ${e.message}',
      );
      return Result.failure(Exception('Account deletion failed: ${e.message}'));
    } catch (e) {
      Log.error('Unexpected error during account deletion: $e');
      return Result.failure(Exception('Account deletion failed: $e'));
    }
  }

  @override
  User? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      Log.debug('Current user: ${user.uid} (${user.email})');
    } else {
      Log.debug('No current user');
    }
    return user;
  }

  @override
  Stream<User?> authStateChanges() {
    Log.debug('Setting up auth state change listener');
    return _firebaseAuth.authStateChanges();
  }

  /// Get device model information
  Future<String> _getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        return macInfo.model;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return linuxInfo.name;
      } else {
        return 'Web Browser';
      }
    } catch (e) {
      Log.warning('Failed to get device info: $e');
      return 'Unknown Device';
    }
  }

  /// Send email verification to current user
  Future<Result<void, Exception>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(Exception('No user is currently signed in'));
      }

      if (user.emailVerified) {
        Log.debug('User email is already verified');
        return Result.success(null);
      }

      await user.sendEmailVerification();
      Log.success('Email verification sent to: ${user.email}');
      return Result.success(null);
    } catch (e) {
      Log.error('Failed to send email verification: $e');
      return Result.failure(Exception('Failed to send email verification: $e'));
    }
  }

  /// Send password reset email
  Future<Result<void, Exception>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      Log.success('Password reset email sent to: $email');
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      Log.error(
        'Firebase Auth error sending password reset: ${e.code} - ${e.message}',
      );
      return Result.failure(Exception('Password reset failed: ${e.message}'));
    } catch (e) {
      Log.error('Unexpected error sending password reset: $e');
      return Result.failure(Exception('Password reset failed: $e'));
    }
  }

  /// Reload current user data
  Future<Result<void, Exception>> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(Exception('No user is currently signed in'));
      }

      await user.reload();
      Log.debug('User data reloaded');
      return Result.success(null);
    } catch (e) {
      Log.error('Failed to reload user data: $e');
      return Result.failure(Exception('Failed to reload user data: $e'));
    }
  }
}
