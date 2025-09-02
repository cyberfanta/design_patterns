/// User Profile Provider - State Management for User Data
///
/// PATTERN: Observer Pattern - Notifies UI of profile changes
/// WHERE: User Profile feature presentation layer
/// HOW: Provides reactive user profile state using Riverpod
/// WHY: Enables UI to respond to user profile changes throughout the app
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/services/user_profile_service.dart';

/// Provider for current user profile state
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final profileService = UserProfileService();
  return profileService.currentProfile;
});

/// Provider for user profile service instance
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

/// Provider for user authentication state
final userAuthStateProvider = StreamProvider<bool>((ref) {
  final profileService = ref.watch(userProfileServiceProvider);
  return profileService.authStateChanges.map(
    (authState) => authState == AuthenticationState.authenticated,
  );
});

/// Provider for user profile stream (real-time updates)
final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final profileService = ref.watch(userProfileServiceProvider);
  final currentProfile = profileService.currentProfile;

  if (currentProfile == null) {
    return Stream.value(null);
  }

  return profileService.profileChanges.map((change) => change.newProfile);
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(userAuthStateProvider);
  return authState.when(
    data: (isAuthenticated) => isAuthenticated,
    loading: () => false,
    error: (_, _) => false,
  );
});

/// Provider for user display information
final userDisplayInfoProvider = Provider<Map<String, String?>>((ref) {
  final userProfile = ref.watch(userProfileProvider);

  return userProfile.when(
    data: (profile) => {
      'displayName': profile?.displayName,
      'email': profile?.email,
      'photoUrl': profile?.photoUrl,
      'initials': profile?.displayName != null
          ? profile!.displayName!.split(' ').map((e) => e[0]).take(2).join('')
          : profile?.email.substring(0, 1).toUpperCase(),
    },
    loading: () => {
      'displayName': null,
      'email': null,
      'photoUrl': null,
      'initials': null,
    },
    error: (error, stackTrace) => {
      'displayName': 'Error',
      'email': null,
      'photoUrl': null,
      'initials': 'E',
    },
  );
});

/// Provider for user game progress
final userGameProgressProvider = Provider<Map<String, dynamic>>((ref) {
  final userProfile = ref.watch(userProfileProvider);

  return userProfile.when(
    data: (profile) => {
      'gamesPlayed': profile?.gamesPlayed ?? 0,
      'gamesWon': profile?.gamesWon ?? 0,
      'winRate': profile?.winRate ?? 0.0,
      'gameLevel': profile?.gameLevel ?? 1,
      'profileCompleteness': profile?.profileCompleteness ?? 0.0,
    },
    loading: () => {
      'gamesPlayed': 0,
      'gamesWon': 0,
      'winRate': 0.0,
      'gameLevel': 1,
      'profileCompleteness': 0.0,
    },
    error: (error, stackTrace) => {
      'gamesPlayed': 0,
      'gamesWon': 0,
      'winRate': 0.0,
      'gameLevel': 1,
      'profileCompleteness': 0.0,
    },
  );
});

/// Provider family for specific user profiles (for admin/social features)
final specificUserProfileProvider = FutureProvider.family<UserProfile?, String>((
  ref,
  uid,
) async {
  final profileService = ref.watch(userProfileServiceProvider);

  // Return current profile if UID matches, null for other users (not implemented yet)
  if (profileService.currentProfile?.uid == uid) {
    return profileService.currentProfile;
  }

  // For other users, this would require a repository method to fetch by UID
  // This is an advanced feature for admin/social functionality
  return null;
});

/// Notifier for user profile actions
final userProfileActionsProvider = Provider<UserProfileActions>((ref) {
  return UserProfileActions(ref);
});

/// Actions class for user profile operations
class UserProfileActions {
  final Ref _ref;

  UserProfileActions(this._ref);

  /// Update user profile
  Future<bool> updateProfile(UserProfile profile) async {
    try {
      final profileService = _ref.read(userProfileServiceProvider);
      await profileService.updateProfile(profile);

      // Refresh the provider
      _ref.invalidate(userProfileProvider);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sign out user
  Future<bool> signOut() async {
    try {
      final profileService = _ref.read(userProfileServiceProvider);
      final success = await profileService.signOut();

      // Refresh providers
      _ref.invalidate(userProfileProvider);
      _ref.invalidate(userAuthStateProvider);

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Update game progress
  Future<bool> updateGameProgress({
    int? gamesPlayed,
    int? gamesWon,
    int? gameLevel,
  }) async {
    try {
      final profileService = _ref.read(userProfileServiceProvider);
      await profileService.updateGameProgress(
        gamesPlayed: gamesPlayed,
        gamesWon: gamesWon,
        gameLevel: gameLevel,
      );

      // Refresh the provider
      _ref.invalidate(userProfileProvider);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    try {
      final profileService = _ref.read(userProfileServiceProvider);
      final success = await profileService.deleteAccount();

      // Clear all providers
      _ref.invalidate(userProfileProvider);
      _ref.invalidate(userAuthStateProvider);

      return success;
    } catch (e) {
      return false;
    }
  }
}
