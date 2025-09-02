/// User Profile Feature - Main Export File
///
/// PATTERN: Facade - Simplified interface to user profile subsystem
/// WHERE: Feature-level public API for user profile functionality
/// HOW: Exports all public components while hiding internal complexity
/// WHY: Provides clean, organized access to user profile features
library;

import 'package:design_patterns/features/user_profile/domain/services/user_profile_service.dart';

import 'domain/services/game_event_manager.dart';

export 'domain/entities/auth_credentials.dart';
export 'domain/entities/auth_result.dart';
// Core Exports - Public API

// Domain Layer - Public Contracts
export 'domain/entities/user_profile.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/repositories/user_profile_repository.dart';
export 'domain/services/game_event_manager.dart';
// Domain Services - Core Business Services
export 'domain/services/user_profile_service.dart';
export 'domain/use_cases/delete_user_account.dart';
// Domain Use Cases - Business Logic
export 'domain/use_cases/sign_in_user.dart';
export 'domain/use_cases/sign_up_user.dart';
export 'domain/use_cases/update_user_profile.dart';
// Dependency Injection - Service Registration
export 'user_profile_injection.dart';

// Helper Functions and Utilities (if any are created later)
// These would be convenience functions for common user profile operations

/// User Profile Feature Information
class UserProfileFeature {
  static const String name = 'User Profile';
  static const String version = '1.0.0';
  static const String description =
      'Complete user authentication and profile management system with Firebase integration';

  /// List of design patterns implemented in this feature
  static const List<String> implementedPatterns = [
    'Singleton', // UserProfileService, GameEventManager
    'Observer', // Profile change notifications, game event management
    'Memento', // Profile state management and undo functionality
    'Repository', // Data access abstraction
    'Proxy', // Future implementation for caching/offline access
    'Dependency Injection', // Service registration and management
    'Factory Method', // AuthCredentials creation methods
    'Data Transfer Object', // Models for data serialization
  ];

  /// List of main features provided
  static const List<String> features = [
    'Email/Password Authentication',
    'Google Sign-In Integration',
    'Apple Sign-In Integration (iOS/macOS)',
    'Anonymous Authentication',
    'User Profile Management',
    'Profile Image Upload/Delete',
    'Real-time Profile Updates',
    'Game Progress Tracking',
    'GDPR Compliance (Account Deletion/Anonymization)',
    'Profile State Management with Undo',
    'Game Event Integration',
    'Multi-platform Support',
  ];

  /// Get feature information
  static Map<String, dynamic> getInfo() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'implemented_patterns': implementedPatterns,
      'features': features,
      'tower_defense_context': {
        'player_authentication': 'Secure user login and registration',
        'game_progress_tracking': 'Track wins, losses, level progression',
        'achievement_system': 'Game event integration for achievements',
        'profile_customization': 'Avatar upload and display name',
        'leaderboards': 'Game statistics and ranking support',
        'cloud_save': 'Profile-based game state persistence',
      },
    };
  }
}

/// User Profile Helper Functions
///
/// PATTERN: Facade - Simplified access to common operations
///
/// These functions provide convenient access to frequently used
/// user profile operations without requiring direct service interaction.
class UserProfileHelpers {
  /// Quick access to the user profile service
  static UserProfileService get service => UserProfileService();

  /// Quick access to the game event manager
  static GameEventManager get gameEvents => GameEventManager();

  /// Check if a user is currently signed in
  static bool get isUserSignedIn => service.isSignedIn;

  /// Get current user's email (if available)
  static String? get currentUserEmail => service.userEmail;

  /// Get current user's display name (if available)
  static String? get currentUserDisplayName => service.displayName;

  /// Get current user's game level
  static int get currentUserGameLevel => service.gameLevel;

  /// Get current user's win rate
  static double get currentUserWinRate => service.winRate;

  /// Check if current user's profile is complete
  static bool get isProfileComplete => service.profileComplete;

  /// Quick sign out
  static Future<bool> signOut() => service.signOut();

  /// Update game level for current user
  static Future<bool> updateGameLevel(int newLevel) {
    return service.updateProfileField('gameLevel', newLevel);
  }

  /// Record a game completion
  static void recordGameCompletion({required bool victory}) {
    gameEvents.gameOver(victory: victory);
  }

  /// Record enemy defeat (for XP tracking)
  static void recordEnemyDefeat(String enemyType, int xpGained) {
    gameEvents.enemyDefeated(enemyType, xpGained);
  }

  /// Record player level up
  static void recordLevelUp(int newLevel) {
    gameEvents.playerLevelUp(newLevel);
  }

  /// Get user profile debug information
  static Map<String, dynamic> getDebugInfo() {
    return {
      'service_status': service.getDebugInfo(),
      'game_events_status': gameEvents.getStats(),
      'feature_info': UserProfileFeature.getInfo(),
    };
  }
}

/// User Profile Constants
class UserProfileConstants {
  // Authentication Providers
  static const String emailPasswordProvider = 'email_password';
  static const String googleProvider = 'google';
  static const String appleProvider = 'apple';
  static const String anonymousProvider = 'anonymous';

  // Profile Visibility Options
  static const String publicVisibility = 'public';
  static const String friendsOnlyVisibility = 'friends_only';
  static const String privateVisibility = 'private';

  // Account Status Options
  static const String activeStatus = 'active';
  static const String pendingDeletionStatus = 'pending_deletion';
  static const String suspendedStatus = 'suspended';
  static const String anonymizedStatus = 'anonymized';

  // Game Event Types (Tower Defense specific)
  static const String enemyDefeatedEvent = 'enemy_defeated';
  static const String playerLevelUpEvent = 'player_level_up';
  static const String gameOverEvent = 'game_over';
  static const String achievementUnlockedEvent = 'achievement_unlocked';
  static const String towerUpgradedEvent = 'tower_upgraded';
  static const String trapActivatedEvent = 'trap_activated';

  // Default Values
  static const int defaultGameLevel = 1;
  static const int defaultGamesPlayed = 0;
  static const int defaultGamesWon = 0;
  static const String defaultLanguage = 'en';

  // Validation Limits
  static const int minPasswordLength = 8;
  static const int maxDisplayNameLength = 50;
  static const int maxBioLength = 200;
  static const int maxProfileImageSizeMB = 5;

  // Error Messages
  static const String invalidEmailError = 'Invalid email address format';
  static const String weakPasswordError =
      'Password must be at least 8 characters';
  static const String emailAlreadyInUseError =
      'Email address is already registered';
  static const String userNotFoundError = 'No user found with this email';
  static const String wrongPasswordError = 'Incorrect password provided';
  static const String networkError = 'Network connection error';
  static const String accountDisabledError = 'User account has been disabled';
  static const String tooManyRequestsError =
      'Too many requests, please try again later';
}
