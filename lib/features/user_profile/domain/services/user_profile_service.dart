/// User Profile Service - Singleton + Observer + Memento Implementation
///
/// PATTERN: Singleton + Observer + Memento - Centralized profile management
/// WHERE: Domain layer service for global user profile access
/// HOW: Singleton with Observer notifications and Memento state management
/// WHY: Ensures single source of truth for user profile across the app
library;

import 'dart:async';

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/patterns/behavioral/memento.dart';
import 'package:design_patterns/core/patterns/behavioral/observer.dart'
    as core_observer;
import 'package:design_patterns/features/user_profile/domain/entities/auth_credentials.dart';
import 'package:design_patterns/features/user_profile/domain/entities/auth_result.dart';
import 'package:design_patterns/features/user_profile/domain/entities/user_profile.dart';
import 'package:design_patterns/features/user_profile/domain/services/game_event_manager.dart';
import 'package:design_patterns/features/user_profile/domain/use_cases/delete_user_account.dart';
import 'package:design_patterns/features/user_profile/domain/use_cases/sign_in_user.dart';
import 'package:design_patterns/features/user_profile/domain/use_cases/sign_up_user.dart';
import 'package:design_patterns/features/user_profile/domain/use_cases/update_user_profile.dart';

/// User profile service implementing multiple design patterns
///
/// PATTERN: Singleton - Ensures single instance across the app
/// PATTERN: Observer - Notifies UI components of profile changes
/// PATTERN: Memento - Saves and restores profile state
///
/// In the Tower Defense context, this service manages all user-related
/// operations including authentication, profile management, and GDPR compliance.
class UserProfileService extends core_observer.Subject<GameEvent>
    implements core_observer.Observer<GameEvent> {
  // PATTERN: Singleton implementation
  static final UserProfileService _instance = UserProfileService._internal();

  factory UserProfileService() => _instance;

  UserProfileService._internal() {
    // Register as observer for game events
    GameEventManager().addObserver(this);
    Log.debug('UserProfileService initialized as Singleton');
  }

  // Observer pattern - list of components listening for profile changes
  final List<core_observer.Observer<GameEvent>> _observers = [];

  // Stream controllers for reactive programming
  final StreamController<AuthenticationState> _authStateController =
      StreamController<AuthenticationState>.broadcast();
  final StreamController<ProfileChangeEvent> _profileChangeController =
      StreamController<ProfileChangeEvent>.broadcast();

  // Current state
  UserProfile? _currentProfile;
  AuthenticationState _authState = AuthenticationState.unauthenticated;
  final List<ProfileMemento> _profileHistory = [];
  bool _isInitialized = false;

  // Use cases injected via dependency injection
  SignInUser? _signInUser;
  SignUpUser? _signUpUser;
  UpdateUserProfile? _updateUserProfile;
  DeleteUserAccount? _deleteUserAccount;

  // Getters for current state
  UserProfile? get currentProfile => _currentProfile;

  AuthenticationState get authState => _authState;

  bool get isInitialized => _isInitialized;

  bool get isSignedIn =>
      _authState == AuthenticationState.authenticated &&
      _currentProfile != null;

  bool get isAnonymous => _currentProfile?.authProvider == 'anonymous';

  // Convenient getters for profile data
  String? get userEmail => _currentProfile?.email;

  String? get displayName => _currentProfile?.displayName;

  String? get fullName => _currentProfile?.fullName;

  String? get photoUrl => _currentProfile?.photoUrl;

  int get gameLevel => _currentProfile?.gameLevel ?? 1;

  double get winRate => _currentProfile?.winRate ?? 0.0;

  bool get profileComplete => _currentProfile?.isComplete ?? false;

  // Stream getters for reactive programming
  Stream<AuthenticationState> get authStateChanges =>
      _authStateController.stream;

  Stream<ProfileChangeEvent> get profileChanges =>
      _profileChangeController.stream;

  /// Initialize the user profile service with use cases
  void initialize({
    required SignInUser signInUser,
    required SignUpUser signUpUser,
    required UpdateUserProfile updateUserProfile,
    required DeleteUserAccount deleteUserAccount,
  }) {
    _signInUser = signInUser;
    _signUpUser = signUpUser;
    _updateUserProfile = updateUserProfile;
    _deleteUserAccount = deleteUserAccount;
    Log.debug('UserProfileService dependencies injected');
  }

  /// Initialize with current authentication state
  Future<void> initializeWithCurrentUser() async {
    try {
      Log.debug('Initializing user profile service...');

      if (_signInUser == null) {
        Log.error(
          'UserProfileService not properly initialized with dependencies',
        );
        return;
      }

      _setAuthState(AuthenticationState.checking);

      // In a real implementation, this would check current auth state
      // For now, we'll simulate checking for existing session
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if user is already signed in
      // This would typically involve checking Firebase Auth state
      Log.debug('No existing authentication session found');
      _setAuthState(AuthenticationState.unauthenticated);

      _isInitialized = true;
      Log.success('UserProfileService initialization completed');
    } catch (e) {
      Log.error('Error initializing user profile service: $e');
      _setAuthState(AuthenticationState.error);
      _isInitialized = true; // Set as initialized even with error
    }
  }

  /// Sign in user with credentials
  Future<AuthResult> signIn(AuthCredentials credentials) async {
    try {
      if (_signInUser == null) {
        Log.error('SignInUser use case not injected');
        return AuthResult.failure(
          errorMessage: 'Authentication service not available',
          errorCode: 'service-unavailable',
        );
      }

      Log.debug('Signing in user with ${credentials.providerDisplayName}');

      _setAuthState(AuthenticationState.signingIn);

      // Create memento before authentication attempt
      if (_currentProfile != null) {
        final memento = createMemento();
        _saveToHistory(memento);
      }

      final result = await _signInUser!.execute(credentials);

      return result.fold(
        (failure) {
          Log.error('Sign-in failed: ${failure.toString()}');
          _setAuthState(AuthenticationState.error);
          return AuthResult.failure(
            errorMessage: failure.message,
            errorCode: 'sign-in-failed',
          );
        },
        (authResult) {
          if (authResult.isSuccess && authResult.userProfile != null) {
            _setCurrentProfile(authResult.userProfile!);
            _setAuthState(AuthenticationState.authenticated);
            _notifyProfileChange(
              null,
              authResult.userProfile!,
              ProfileChangeType.signIn,
            );
          } else {
            _setAuthState(AuthenticationState.unauthenticated);
          }

          return authResult;
        },
      );
    } catch (e) {
      Log.error('Error during sign-in: $e');
      _setAuthState(AuthenticationState.error);
      return AuthResult.failure(
        errorMessage: 'Sign-in error: ${e.toString()}',
        errorCode: 'unexpected-error',
      );
    }
  }

  /// Register new user
  Future<AuthResult> signUp(
    AuthCredentials credentials, {
    Map<String, dynamic>? profileData,
    required bool acceptedTerms,
    required bool privacyConsent,
  }) async {
    try {
      if (_signUpUser == null) {
        Log.error('SignUpUser use case not injected');
        return AuthResult.failure(
          errorMessage: 'Registration service not available',
          errorCode: 'service-unavailable',
        );
      }

      Log.debug('Registering new user with ${credentials.providerDisplayName}');

      _setAuthState(AuthenticationState.signingUp);

      final result = await _signUpUser!.execute(
        credentials,
        profileData: profileData,
        acceptedTerms: acceptedTerms,
        privacyConsent: privacyConsent,
      );

      return result.fold(
        (failure) {
          Log.error('Sign-up failed: ${failure.toString()}');
          _setAuthState(AuthenticationState.error);
          return AuthResult.failure(
            errorMessage: failure.message,
            errorCode: 'sign-up-failed',
          );
        },
        (authResult) {
          if (authResult.isSuccess && authResult.userProfile != null) {
            _setCurrentProfile(authResult.userProfile!);
            _setAuthState(AuthenticationState.authenticated);
            _notifyProfileChange(
              null,
              authResult.userProfile!,
              ProfileChangeType.signUp,
            );
          } else {
            _setAuthState(AuthenticationState.unauthenticated);
          }

          return authResult;
        },
      );
    } catch (e) {
      Log.error('Error during sign-up: $e');
      _setAuthState(AuthenticationState.error);
      return AuthResult.failure(
        errorMessage: 'Registration error: ${e.toString()}',
        errorCode: 'unexpected-error',
      );
    }
  }

  /// Sign out current user
  Future<bool> signOut() async {
    try {
      if (!isSignedIn) {
        Log.warning('No user signed in to sign out');
        return true;
      }

      Log.debug('Signing out user: ${_currentProfile?.email}');

      _setAuthState(AuthenticationState.signingOut);

      final oldProfile = _currentProfile;

      // Create memento before sign out
      if (oldProfile != null) {
        final memento = createMemento();
        _saveToHistory(memento);
      }

      // Clear current profile
      _setCurrentProfile(null);
      _setAuthState(AuthenticationState.unauthenticated);

      // Notify observers
      if (oldProfile != null) {
        _notifyProfileChange(oldProfile, null, ProfileChangeType.signOut);
      }

      Log.success('User signed out successfully');
      return true;
    } catch (e) {
      Log.error('Error during sign-out: $e');
      _setAuthState(AuthenticationState.error);
      return false;
    }
  }

  /// Update current user profile
  Future<bool> updateProfile(UserProfile updatedProfile) async {
    try {
      if (_updateUserProfile == null) {
        Log.error('UpdateUserProfile use case not injected');
        return false;
      }

      if (!isSignedIn) {
        Log.error('No user signed in to update profile');
        return false;
      }

      Log.debug('Updating user profile for: ${updatedProfile.uid}');

      final oldProfile = _currentProfile;

      // Create memento before update
      if (oldProfile != null) {
        final memento = createMemento();
        _saveToHistory(memento);
      }

      final result = await _updateUserProfile!.execute(updatedProfile);

      return result.fold(
        (failure) {
          Log.error('Profile update failed: ${failure.toString()}');
          return false;
        },
        (profile) {
          _setCurrentProfile(profile);
          _notifyProfileChange(oldProfile, profile, ProfileChangeType.update);
          return true;
        },
      );
    } catch (e) {
      Log.error('Error updating profile: $e');
      return false;
    }
  }

  /// Update specific profile field
  Future<bool> updateProfileField(String field, dynamic value) async {
    try {
      if (_updateUserProfile == null || !isSignedIn) {
        return false;
      }

      Log.debug(
        'Updating profile field $field for user: ${_currentProfile!.uid}',
      );

      final result = await _updateUserProfile!.updateField(
        _currentProfile!.uid,
        field,
        value,
      );

      return result.fold(
        (failure) {
          Log.error('Field update failed: ${failure.toString()}');
          return false;
        },
        (_) {
          // Reload profile to get updated data
          _reloadCurrentProfile();
          return true;
        },
      );
    } catch (e) {
      Log.error('Error updating profile field: $e');
      return false;
    }
  }

  /// Delete current user account
  Future<bool> deleteAccount({
    AuthCredentials? confirmationCredentials,
    bool deleteImmediately = false,
    bool anonymizeData = false,
  }) async {
    try {
      if (_deleteUserAccount == null) {
        Log.error('DeleteUserAccount use case not injected');
        return false;
      }

      if (!isSignedIn) {
        Log.error('No user signed in to delete account');
        return false;
      }

      Log.warning('Deleting account for user: ${_currentProfile!.uid}');

      final oldProfile = _currentProfile;

      // Create memento before deletion
      if (oldProfile != null) {
        final memento = createMemento();
        _saveToHistory(memento);
      }

      final result = await _deleteUserAccount!.execute(
        _currentProfile!.uid,
        confirmationCredentials: confirmationCredentials,
        deleteImmediately: deleteImmediately,
        anonymizeData: anonymizeData,
      );

      return result.fold(
        (failure) {
          Log.error('Account deletion failed: ${failure.toString()}');
          return false;
        },
        (_) {
          if (deleteImmediately || anonymizeData) {
            // Account deleted/anonymized - sign out user
            _setCurrentProfile(null);
            _setAuthState(AuthenticationState.unauthenticated);
            _notifyProfileChange(
              oldProfile,
              null,
              ProfileChangeType.accountDeleted,
            );
          } else {
            // Account marked for deletion - keep user signed in but update status
            _reloadCurrentProfile();
          }

          return true;
        },
      );
    } catch (e) {
      Log.error('Error deleting account: $e');
      return false;
    }
  }

  /// Set current profile and handle state changes
  void _setCurrentProfile(UserProfile? profile) {
    _currentProfile = profile;
    if (profile != null) {
      Log.debug('Current profile set: ${profile.email}');
    } else {
      Log.debug('Current profile cleared');
    }
  }

  /// Set authentication state and notify observers
  void _setAuthState(AuthenticationState state) {
    if (_authState != state) {
      final oldState = _authState;
      _authState = state;
      Log.debug('Auth state changed: $oldState -> $state');

      // Emit to auth state stream
      _authStateController.add(state);

      // Notify observers of auth state change
      _notifyProfileChange(
        oldState == AuthenticationState.authenticated ? _currentProfile : null,
        state == AuthenticationState.authenticated ? _currentProfile : null,
        ProfileChangeType.authStateChange,
      );
    }
  }

  /// Reload current profile from repository
  Future<void> _reloadCurrentProfile() async {
    try {
      if (_currentProfile == null) return;

      // In a real implementation, this would reload from repository
      // For now, just log the action
      Log.debug('Profile reload requested for: ${_currentProfile!.uid}');
    } catch (e) {
      Log.error('Error reloading profile: $e');
    }
  }

  /// Notify observers of profile change
  void _notifyProfileChange(
    UserProfile? oldProfile,
    UserProfile? newProfile,
    ProfileChangeType changeType,
  ) {
    final event = ProfileChangeEvent(
      oldProfile: oldProfile,
      newProfile: newProfile,
      changeType: changeType,
      timestamp: DateTime.now(),
    );

    // Emit to profile changes stream
    _profileChangeController.add(event);

    // Convert to GameEvent and notify observers
    final gameEvent = GameEvent(
      type: _getGameEventTypeFromProfileChange(changeType),
      timestamp: event.timestamp,
      data: {
        'old_profile': oldProfile?.uid,
        'new_profile': newProfile?.uid,
        'change_type': changeType.toString(),
      },
    );

    notifyObservers(gameEvent);
    Log.debug('Profile change notification sent: $changeType');
  }

  /// Map profile change type to game event type
  GameEventType _getGameEventTypeFromProfileChange(
    ProfileChangeType changeType,
  ) {
    switch (changeType) {
      case ProfileChangeType.signIn:
      case ProfileChangeType.signOut:
      case ProfileChangeType.update:
      case ProfileChangeType.restore:
        return GameEventType.userAction;
      case ProfileChangeType.signUp:
        return GameEventType.userAction;
      case ProfileChangeType.accountDeleted:
        return GameEventType.userAction;
      case ProfileChangeType.authStateChange:
        return GameEventType.userAction;
    }
  }

  // PATTERN: Memento - Save current state
  ProfileMemento createMemento() {
    return ProfileMemento(
      profile: _currentProfile,
      authState: _authState,
      timestamp: DateTime.now(),
    );
  }

  // PATTERN: Memento - Restore from saved state
  void restoreFromMemento(ProfileMemento memento) {
    final oldProfile = _currentProfile;

    _currentProfile = memento.profile;
    _authState = memento.authState;

    Log.debug('UserProfileService state restored from memento');

    // Notify observers of restoration
    _notifyProfileChange(
      oldProfile,
      _currentProfile,
      ProfileChangeType.restore,
    );
  }

  /// Save memento to history for undo functionality
  void _saveToHistory(ProfileMemento memento) {
    _profileHistory.add(memento);

    // Keep only last 10 states
    if (_profileHistory.length > 10) {
      _profileHistory.removeAt(0);
    }

    Log.debug(
      'Profile state saved to history (${_profileHistory.length} states)',
    );
  }

  /// Undo last profile change
  bool undoLastChange() {
    if (_profileHistory.isEmpty) {
      Log.warning('No profile history available for undo');
      return false;
    }

    final lastMemento = _profileHistory.removeLast();
    restoreFromMemento(lastMemento);

    Log.info('Profile change undone');
    return true;
  }

  /// Get profile history count
  int get historyCount => _profileHistory.length;

  /// Get profile debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'current_profile': _currentProfile?.getExportData(),
      'auth_state': _authState.name,
      'is_initialized': _isInitialized,
      'is_signed_in': isSignedIn,
      'history_count': _profileHistory.length,
      'observers_count': _observers.length,
      'profile_complete': profileComplete,
    };
  }

  // PATTERN: Observer - Implementation for game events
  @override
  void update(GameEvent event) {
    // Listen for game-related profile events
    switch (event.type) {
      case GameEventType.gameOver:
        // Update game statistics
        if (isSignedIn && event.data != null) {
          _updateGameStats(event.data!);
        }
        break;
      case GameEventType.playerLevelUp:
        // Update player level
        if (isSignedIn && event.data != null) {
          updateProfileField('gameLevel', event.data!['new_level']);
        }
        break;
      case GameEventType.achievementUnlocked:
        // Handle achievement updates
        Log.debug('Achievement event received in UserProfileService');
        break;
      default:
        // Ignore other events
        break;
    }
  }

  /// Update game statistics based on game events
  void _updateGameStats(Map<String, dynamic> gameData) {
    try {
      if (_currentProfile == null) return;

      final isWin = gameData['victory'] ?? false;
      final newGamesPlayed = _currentProfile!.gamesPlayed + 1;
      final newGamesWon = _currentProfile!.gamesWon + (isWin ? 1 : 0);

      final updatedProfile = _currentProfile!.updateGameProgress(
        gamesPlayed: newGamesPlayed,
        gamesWon: newGamesWon,
      );

      updateProfile(updatedProfile);
    } catch (e) {
      Log.error('Error updating game stats: $e');
    }
  }

  /// Public method to update game progress (for provider compatibility)
  Future<void> updateGameProgress({
    int? gamesPlayed,
    int? gamesWon,
    int? gameLevel,
  }) async {
    if (_currentProfile == null) {
      Log.warning('Cannot update game progress - user not signed in');
      return;
    }

    try {
      Log.debug('Updating game progress for user: ${_currentProfile!.uid}');

      final updatedProfile = _currentProfile!.updateGameProgress(
        gamesPlayed: gamesPlayed ?? _currentProfile!.gamesPlayed,
        gamesWon: gamesWon ?? _currentProfile!.gamesWon,
        gameLevel: gameLevel ?? _currentProfile!.gameLevel,
      );

      await updateProfile(updatedProfile);
    } catch (e) {
      Log.error('Error updating game progress: $e');
    }
  }

  // PATTERN: Observer - Subject implementation
  @override
  void addObserver(core_observer.Observer<GameEvent> observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
      Log.debug(
        'Observer added to UserProfileService (${_observers.length} total)',
      );
    }
  }

  @override
  void removeObserver(core_observer.Observer<GameEvent> observer) {
    _observers.remove(observer);
    Log.debug(
      'Observer removed from UserProfileService (${_observers.length} remaining)',
    );
  }

  @override
  void notifyObservers(GameEvent event) {
    Log.debug(
      'Notifying ${_observers.length} observers of game event: ${event.type}',
    );

    for (final observer in _observers) {
      try {
        observer.update(event);
      } catch (e) {
        Log.error('Error notifying profile observer: $e');
      }
    }
  }
}

/// Authentication states
enum AuthenticationState {
  unauthenticated,
  checking,
  signingIn,
  signingUp,
  signingOut,
  authenticated,
  error,
}

/// Types of profile changes
enum ProfileChangeType {
  signIn,
  signUp,
  signOut,
  update,
  authStateChange,
  accountDeleted,
  restore,
}

/// Event class for profile changes
class ProfileChangeEvent {
  final UserProfile? oldProfile;
  final UserProfile? newProfile;
  final ProfileChangeType changeType;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  const ProfileChangeEvent({
    required this.oldProfile,
    required this.newProfile,
    required this.changeType,
    required this.timestamp,
    this.additionalData,
  });

  /// Check if user signed in
  bool get isSignIn => changeType == ProfileChangeType.signIn;

  /// Check if user signed out
  bool get isSignOut => changeType == ProfileChangeType.signOut;

  /// Check if profile was updated
  bool get isProfileUpdate => changeType == ProfileChangeType.update;

  /// Check if this was a restore operation
  bool get isRestore => changeType == ProfileChangeType.restore;
}

/// Memento class for saving profile service state
class ProfileMemento extends Memento {
  final UserProfile? profile;
  final AuthenticationState authState;

  @override
  final DateTime timestamp;

  @override
  final String description;

  ProfileMemento({
    required this.profile,
    required this.authState,
    required this.timestamp,
  }) : description = 'Profile: ${profile?.email ?? 'none'} (${authState.name})';

  Map<String, dynamic> toJson() {
    return {
      'profile': profile?.getExportData(),
      'auth_state': authState.name,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  @override
  String toString() =>
      'ProfileMemento($description at ${timestamp.toIso8601String()})';
}
