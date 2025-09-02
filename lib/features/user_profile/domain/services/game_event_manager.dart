/// Game Event Manager - Central hub for game events
///
/// PATTERN: Singleton + Observer - Centralized event management
/// WHERE: Domain layer service for coordinating game events
/// HOW: Singleton event dispatcher with Observer pattern
/// WHY: Decouples game events from profile updates and other systems
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/patterns/behavioral/observer.dart';

/// Singleton manager for all game events in Tower Defense
///
/// PATTERN: Singleton - Ensures single event dispatcher
/// PATTERN: Observer - Notifies multiple systems of game events
///
/// In Tower Defense context, this manages events like:
/// - Enemy defeated (XP gain)
/// - Player level up
/// - Game over (win/lose)
/// - Achievement unlocked
/// - Tower upgraded
class GameEventManager extends Subject<GameEvent> {
  // PATTERN: Singleton implementation
  static final GameEventManager _instance = GameEventManager._internal();

  factory GameEventManager() => _instance;

  GameEventManager._internal() {
    Log.debug('GameEventManager initialized as Singleton');
  }

  final List<Observer<GameEvent>> _observers = [];

  /// Dispatch a game event to all observers
  void dispatchEvent(GameEventType type, {Map<String, dynamic>? data}) {
    final event = GameEvent(type: type, timestamp: DateTime.now(), data: data);

    Log.debug('Dispatching game event: ${type.name}');
    notifyObservers(event);
  }

  /// Convenience methods for common game events
  void playerLevelUp(int newLevel) {
    dispatchEvent(
      GameEventType.playerLevelUp,
      data: {
        'new_level': newLevel,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void enemyDefeated(String enemyType, int xpGained) {
    dispatchEvent(
      GameEventType.enemyDefeated,
      data: {
        'enemy_type': enemyType,
        'xp_gained': xpGained,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void gameOver({required bool victory, int? finalScore, int? wavesCompleted}) {
    dispatchEvent(
      GameEventType.gameOver,
      data: {
        'victory': victory,
        'final_score': finalScore,
        'waves_completed': wavesCompleted,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void achievementUnlocked(String achievementId, String achievementName) {
    dispatchEvent(
      GameEventType.achievementUnlocked,
      data: {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void towerUpgraded(String towerType, int newLevel) {
    dispatchEvent(
      GameEventType.towerUpgraded,
      data: {
        'tower_type': towerType,
        'new_level': newLevel,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void trapActivated(String trapType, int enemiesAffected) {
    dispatchEvent(
      GameEventType.trapActivated,
      data: {
        'trap_type': trapType,
        'enemies_affected': enemiesAffected,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  void addObserver(Observer<GameEvent> observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
      Log.debug(
        'Observer added to GameEventManager (${_observers.length} total)',
      );
    }
  }

  @override
  void removeObserver(Observer<GameEvent> observer) {
    _observers.remove(observer);
    Log.debug(
      'Observer removed from GameEventManager (${_observers.length} remaining)',
    );
  }

  @override
  void notifyObservers(GameEvent event) {
    Log.debug(
      'Notifying ${_observers.length} observers of game event: ${event.type.name}',
    );

    for (final observer in _observers) {
      try {
        observer.update(event);
      } catch (e) {
        Log.error('Error notifying game event observer: $e');
      }
    }
  }

  /// Get statistics about the event manager
  Map<String, dynamic> getStats() {
    return {
      'observers_count': _observers.length,
      'manager_instance': hashCode.toString(),
      'initialized': true,
    };
  }

  /// Notify when a user registers for the first time
  void userRegistered(String userId, String authProvider) {
    final event = GameEvent(
      type: GameEventType.userAction,
      timestamp: DateTime.now(),
      data: {
        'user_id': userId,
        'action': 'user_registered',
        'auth_provider': authProvider,
      },
    );

    notifyObservers(event);
    Log.info('GameEventManager: New user $userId registered via $authProvider');
  }

  /// Notify when a user signs in
  void userSignedIn(String userId, String authProvider) {
    final event = GameEvent(
      type: GameEventType.userAction,
      timestamp: DateTime.now(),
      data: {
        'user_id': userId,
        'action': 'user_signed_in',
        'auth_provider': authProvider,
      },
    );

    notifyObservers(event);
    Log.info('GameEventManager: User $userId signed in via $authProvider');
  }

  /// Notify when user profile is updated
  void profileUpdated(String userId, Map<String, dynamic> changes) {
    final event = GameEvent(
      type: GameEventType.userAction,
      timestamp: DateTime.now(),
      data: {
        'user_id': userId,
        'action': 'profile_updated',
        'changes': changes,
      },
    );

    notifyObservers(event);
    Log.info('GameEventManager: User $userId updated profile');
  }

  /// Notify when account is marked for deletion
  void accountMarkedForDeletion(String userId, DateTime deletionDate) {
    final event = GameEvent(
      type: GameEventType.userAction,
      timestamp: DateTime.now(),
      data: {
        'user_id': userId,
        'action': 'account_marked_for_deletion',
        'deletion_date': deletionDate.toIso8601String(),
      },
    );

    notifyObservers(event);
    Log.warning('GameEventManager: Account $userId marked for deletion');
  }

  /// Notify when account is permanently deleted
  void accountDeleted(String userId, String reason) {
    final event = GameEvent(
      type: GameEventType.userAction,
      timestamp: DateTime.now(),
      data: {'user_id': userId, 'action': 'account_deleted', 'reason': reason},
    );

    notifyObservers(event);
    Log.warning('GameEventManager: Account $userId permanently deleted');
  }

  /// Notify when account is anonymized
  void accountAnonymized(String userId, String reason) {
    final event = GameEvent(
      type: GameEventType.userAction,
      timestamp: DateTime.now(),
      data: {
        'user_id': userId,
        'action': 'account_anonymized',
        'reason': reason,
      },
    );

    notifyObservers(event);
    Log.info('GameEventManager: Account $userId anonymized');
  }

  /// Notify when account deletion is cancelled
  void accountDeletionCancelled(String userId, String reason) {
    final event = GameEvent(
      type: GameEventType.userAction,
      timestamp: DateTime.now(),
      data: {
        'user_id': userId,
        'action': 'account_deletion_cancelled',
        'reason': reason,
      },
    );

    notifyObservers(event);
    Log.info('GameEventManager: Account deletion cancelled for $userId');
  }
}

/// Game event types in Tower Defense context
enum GameEventType {
  /// Enemy-related events
  enemySpawned,
  enemyDefeated,
  enemyReachedBase,

  /// Tower-related events
  towerBuilt,
  towerUpgraded,
  towerSold,

  /// Player progression events
  playerLevelUp,
  xpGained,
  evolutionPointsGained,

  /// Game state events
  gameStarted,
  gameOver,
  gamePaused,
  gameResumed,

  /// Achievement events
  achievementUnlocked,
  achievementProgress,

  /// User action events
  userAction,

  /// Trap events
  trapActivated,
  trapExpired,

  /// Wave events
  waveStarted,
  waveCompleted,
  allWavesCompleted,

  /// Special events
  bossDefeated,
  perfectWave,
  speedRun,
}

/// Game event data container
class GameEvent {
  final GameEventType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const GameEvent({required this.type, required this.timestamp, this.data});

  /// Get specific data value
  T? getValue<T>(String key) {
    if (data == null) return null;
    final value = data![key];
    return value is T ? value : null;
  }

  /// Check if event has specific data key
  bool hasData(String key) {
    return data?.containsKey(key) ?? false;
  }

  /// Get event age in milliseconds
  int get ageInMilliseconds =>
      DateTime.now().difference(timestamp).inMilliseconds;

  /// Check if event is recent (within last 5 seconds)
  bool get isRecent => ageInMilliseconds < 5000;

  @override
  String toString() {
    return 'GameEvent(${type.name} at ${timestamp.toIso8601String()})';
  }

  /// Convert to JSON for logging or debugging
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }
}
