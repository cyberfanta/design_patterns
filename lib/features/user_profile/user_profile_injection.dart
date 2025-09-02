/// User Profile Dependency Injection
///
/// PATTERN: Dependency Injection - Service registration and management
/// WHERE: Feature-level DI setup for user profile components
/// HOW: Registers all user profile services, repositories, and use cases with get_it
/// WHY: Decouples components and enables easy testing and maintenance
library;

import 'package:cloud_firestore/cloud_firestore.dart';
// Core
import 'package:design_patterns/core/logging/logging.dart';
// Data Sources
import 'package:design_patterns/features/user_profile/data/data_sources/firebase_auth_datasource.dart';
import 'package:design_patterns/features/user_profile/data/data_sources/firestore_profile_datasource.dart';
// Repositories
import 'package:design_patterns/features/user_profile/data/repositories/auth_repository_impl.dart';
import 'package:design_patterns/features/user_profile/data/repositories/user_profile_repository_impl.dart';
import 'package:design_patterns/features/user_profile/domain/repositories/auth_repository.dart';
import 'package:design_patterns/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:design_patterns/features/user_profile/domain/services/game_event_manager.dart';
// Services
import 'package:design_patterns/features/user_profile/domain/services/user_profile_service.dart';
import 'package:design_patterns/features/user_profile/domain/use_cases/delete_user_account.dart';
// Use Cases
import 'package:design_patterns/features/user_profile/domain/use_cases/sign_in_user.dart';
import 'package:design_patterns/features/user_profile/domain/use_cases/sign_up_user.dart';
import 'package:design_patterns/features/user_profile/domain/use_cases/update_user_profile.dart';
import 'package:device_info_plus/device_info_plus.dart';
// Firebase dependencies
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// User Profile Dependency Injection Setup
///
/// PATTERN: Dependency Injection - Feature component registration
///
/// In Tower Defense context, this sets up all user profile related
/// components including Firebase integration, authentication, profile
/// management, and game event coordination.
class UserProfileInjection {
  /// Setup user profile dependencies
  static Future<void> setupDependencies() async {
    try {
      Log.info('Setting up User Profile dependencies...');

      // Register external services
      _registerExternalServices();

      // Register data sources
      _registerDataSources();

      // Register repositories
      _registerRepositories();

      // Register use cases
      _registerUseCases();

      // Register services (Singletons)
      _registerServices();

      // Initialize services
      await _initializeServices();

      Log.success('User Profile dependencies setup completed');
    } catch (e) {
      Log.error('Failed to setup User Profile dependencies: $e');
      rethrow;
    }
  }

  /// Register external Firebase services
  static void _registerExternalServices() {
    final getIt = GetIt.instance;

    // Register Firebase services if not already registered
    if (!getIt.isRegistered<FirebaseAuth>()) {
      getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    }

    if (!getIt.isRegistered<FirebaseFirestore>()) {
      getIt.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance,
      );
    }

    if (!getIt.isRegistered<FirebaseStorage>()) {
      getIt.registerLazySingleton<FirebaseStorage>(
        () => FirebaseStorage.instance,
      );
    }

    // Register platform services
    if (!getIt.isRegistered<GoogleSignIn>()) {
      getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
    }

    if (!getIt.isRegistered<DeviceInfoPlugin>()) {
      getIt.registerLazySingleton<DeviceInfoPlugin>(() => DeviceInfoPlugin());
    }

    Log.debug('External services registered');
  }

  /// Register data sources
  static void _registerDataSources() {
    final getIt = GetIt.instance;

    // Register Firebase Auth Data Source
    getIt.registerLazySingleton<AuthDataSource>(
      () => FirebaseAuthDataSource(
        firebaseAuth: getIt<FirebaseAuth>(),
        googleSignIn: getIt<GoogleSignIn>(),
        deviceInfo: getIt<DeviceInfoPlugin>(),
      ),
    );

    // Register Firestore Profile Data Source
    getIt.registerLazySingleton<ProfileDataSource>(
      () => FirestoreProfileDataSource(
        firestore: getIt<FirebaseFirestore>(),
        storage: getIt<FirebaseStorage>(),
      ),
    );

    Log.debug('Data sources registered');
  }

  /// Register repositories
  static void _registerRepositories() {
    final getIt = GetIt.instance;

    // Register Auth Repository
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(authDataSource: getIt<AuthDataSource>()),
    );

    // Register User Profile Repository
    getIt.registerLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(
        profileDataSource: getIt<ProfileDataSource>(),
      ),
    );

    Log.debug('Repositories registered');
  }

  /// Register use cases
  static void _registerUseCases() {
    final getIt = GetIt.instance;

    // Register Sign In Use Case
    getIt.registerFactory<SignInUser>(
      () => SignInUser(
        getIt<AuthRepository>(),
        getIt<UserProfileRepository>(),
        getIt<GameEventManager>(),
      ),
    );

    // Register Sign Up Use Case
    getIt.registerFactory<SignUpUser>(
      () => SignUpUser(
        getIt<AuthRepository>(),
        getIt<UserProfileRepository>(),
        getIt<GameEventManager>(),
      ),
    );

    // Register Update Profile Use Case
    getIt.registerFactory<UpdateUserProfile>(
      () => UpdateUserProfile(
        getIt<UserProfileRepository>(),
        getIt<GameEventManager>(),
      ),
    );

    // Register Delete Account Use Case
    getIt.registerFactory<DeleteUserAccount>(
      () => DeleteUserAccount(
        getIt<AuthRepository>(),
        getIt<UserProfileRepository>(),
        getIt<GameEventManager>(),
      ),
    );

    Log.debug('Use cases registered');
  }

  /// Register services (Singletons with Observer patterns)
  static void _registerServices() {
    final getIt = GetIt.instance;

    // Register Game Event Manager (Singleton)
    getIt.registerLazySingleton<GameEventManager>(() => GameEventManager());

    // Register User Profile Service (Singleton)
    // This service is already a singleton internally, but we register it
    // with GetIt for dependency injection consistency
    getIt.registerLazySingleton<UserProfileService>(() => UserProfileService());

    Log.debug('Services registered');
  }

  /// Initialize services with dependencies
  static Future<void> _initializeServices() async {
    final getIt = GetIt.instance;

    try {
      // Initialize UserProfileService with use cases
      final profileService = getIt<UserProfileService>();
      profileService.initialize(
        signInUser: getIt<SignInUser>(),
        signUpUser: getIt<SignUpUser>(),
        updateUserProfile: getIt<UpdateUserProfile>(),
        deleteUserAccount: getIt<DeleteUserAccount>(),
      );

      // Initialize the service with current user state
      await profileService.initializeWithCurrentUser();

      Log.debug('Services initialized');
    } catch (e) {
      Log.error('Error initializing services: $e');
      rethrow;
    }
  }

  /// Clear user profile dependencies (for testing or reset)
  static void clearDependencies() {
    final getIt = GetIt.instance;

    try {
      Log.debug('Clearing User Profile dependencies...');

      // Clear use cases
      if (getIt.isRegistered<SignInUser>()) {
        getIt.unregister<SignInUser>();
      }
      if (getIt.isRegistered<SignUpUser>()) {
        getIt.unregister<SignUpUser>();
      }
      if (getIt.isRegistered<UpdateUserProfile>()) {
        getIt.unregister<UpdateUserProfile>();
      }
      if (getIt.isRegistered<DeleteUserAccount>()) {
        getIt.unregister<DeleteUserAccount>();
      }

      // Clear repositories
      if (getIt.isRegistered<AuthRepository>()) {
        getIt.unregister<AuthRepository>();
      }
      if (getIt.isRegistered<UserProfileRepository>()) {
        getIt.unregister<UserProfileRepository>();
      }

      // Clear data sources
      if (getIt.isRegistered<AuthDataSource>()) {
        getIt.unregister<AuthDataSource>();
      }
      if (getIt.isRegistered<ProfileDataSource>()) {
        getIt.unregister<ProfileDataSource>();
      }

      // Note: We don't clear Firebase services as they might be used elsewhere
      // Note: We don't clear Singleton services as they manage their own lifecycle

      Log.debug('User Profile dependencies cleared');
    } catch (e) {
      Log.error('Error clearing User Profile dependencies: $e');
    }
  }

  /// Get service instances (convenience getters)
  static UserProfileService get profileService =>
      GetIt.instance<UserProfileService>();

  static GameEventManager get gameEventManager =>
      GetIt.instance<GameEventManager>();

  static AuthRepository get authRepository => GetIt.instance<AuthRepository>();

  static UserProfileRepository get userProfileRepository =>
      GetIt.instance<UserProfileRepository>();

  /// Register test dependencies (for testing)
  static void registerTestDependencies({
    AuthDataSource? mockAuthDataSource,
    ProfileDataSource? mockProfileDataSource,
    AuthRepository? mockAuthRepository,
    UserProfileRepository? mockProfileRepository,
  }) {
    final getIt = GetIt.instance;

    try {
      Log.debug('Registering test dependencies for User Profile...');

      // Clear existing dependencies first
      clearDependencies();

      // Register mock data sources if provided
      if (mockAuthDataSource != null) {
        getIt.registerLazySingleton<AuthDataSource>(() => mockAuthDataSource);
      }
      if (mockProfileDataSource != null) {
        getIt.registerLazySingleton<ProfileDataSource>(
          () => mockProfileDataSource,
        );
      }

      // Register mock repositories if provided
      if (mockAuthRepository != null) {
        getIt.registerLazySingleton<AuthRepository>(() => mockAuthRepository);
      }
      if (mockProfileRepository != null) {
        getIt.registerLazySingleton<UserProfileRepository>(
          () => mockProfileRepository,
        );
      }

      // If mocks not provided, register real implementations with mocked dependencies
      if (!getIt.isRegistered<AuthRepository>()) {
        getIt.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(authDataSource: getIt<AuthDataSource>()),
        );
      }

      if (!getIt.isRegistered<UserProfileRepository>()) {
        getIt.registerLazySingleton<UserProfileRepository>(
          () => UserProfileRepositoryImpl(
            profileDataSource: getIt<ProfileDataSource>(),
          ),
        );
      }

      // Register use cases with mocked dependencies
      _registerUseCases();

      Log.debug('Test dependencies registered');
    } catch (e) {
      Log.error('Error registering test dependencies: $e');
      rethrow;
    }
  }

  /// Get dependency status
  static Map<String, dynamic> getDependencyStatus() {
    final getIt = GetIt.instance;

    return {
      'services': {
        'user_profile_service': getIt.isRegistered<UserProfileService>(),
        'game_event_manager': getIt.isRegistered<GameEventManager>(),
      },
      'repositories': {
        'auth_repository': getIt.isRegistered<AuthRepository>(),
        'user_profile_repository': getIt.isRegistered<UserProfileRepository>(),
      },
      'data_sources': {
        'auth_data_source': getIt.isRegistered<AuthDataSource>(),
        'profile_data_source': getIt.isRegistered<ProfileDataSource>(),
      },
      'use_cases': {
        'sign_in_user': getIt.isRegistered<SignInUser>(),
        'sign_up_user': getIt.isRegistered<SignUpUser>(),
        'update_user_profile': getIt.isRegistered<UpdateUserProfile>(),
        'delete_user_account': getIt.isRegistered<DeleteUserAccount>(),
      },
      'external_services': {
        'firebase_auth': getIt.isRegistered<FirebaseAuth>(),
        'firebase_firestore': getIt.isRegistered<FirebaseFirestore>(),
        'firebase_storage': getIt.isRegistered<FirebaseStorage>(),
        'google_sign_in': getIt.isRegistered<GoogleSignIn>(),
        'device_info_plugin': getIt.isRegistered<DeviceInfoPlugin>(),
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
