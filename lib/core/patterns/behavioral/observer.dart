/// Observer Pattern - Tower Defense Context
///
/// PATTERN: Observer - Defines one-to-many dependency between objects
/// WHERE: Game events notification system, UI updates, multi-language system
/// HOW: Subject maintains list of observers and notifies them of state changes
/// WHY: Loose coupling between objects that need to react to state changes
library;

import 'package:equatable/equatable.dart';

import '../../logging/console_logger.dart';

/// Generic observer interface
abstract class Observer<T> {
  void update(T data);
}

/// Generic subject/observable interface
abstract class Subject<T> {
  void addObserver(Observer<T> observer);

  void removeObserver(Observer<T> observer);

  void notifyObservers(T data);
}

/// Game event types that can be observed
enum GameEventType {
  enemyKilled,
  waveCompleted,
  towerBuilt,
  playerLevelUp,
  gameOver,
  victory,
  settingsChanged,
  languageChanged,
}

/// Game event data
class GameEvent extends Equatable {
  final GameEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  GameEvent({required this.type, required this.data})
    : timestamp = DateTime.now();

  @override
  List<Object> get props => [type, data, timestamp];
}

/// Concrete subject - Game Event Manager
class GameEventManager extends Subject<GameEvent> {
  static final GameEventManager _instance = GameEventManager._internal();

  factory GameEventManager() => _instance;

  GameEventManager._internal();

  final List<Observer<GameEvent>> _observers = [];

  @override
  void addObserver(Observer<GameEvent> observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  @override
  void removeObserver(Observer<GameEvent> observer) {
    _observers.remove(observer);
  }

  @override
  void notifyObservers(GameEvent event) {
    // Create a copy to avoid concurrent modification
    final observersCopy = List<Observer<GameEvent>>.from(_observers);
    for (final observer in observersCopy) {
      try {
        observer.update(event);
      } catch (e) {
        Log.debug('Error notifying observer: $e');
        // Remove faulty observers
        _observers.remove(observer);
      }
    }
  }

  // Convenience methods for firing specific events
  void enemyKilled(String enemyType, int experience, double x, double y) {
    final event = GameEvent(
      type: GameEventType.enemyKilled,
      data: {'enemyType': enemyType, 'experience': experience, 'x': x, 'y': y},
    );
    notifyObservers(event);
  }

  void waveCompleted(int waveNumber, int enemiesKilled, Duration waveTime) {
    final event = GameEvent(
      type: GameEventType.waveCompleted,
      data: {
        'waveNumber': waveNumber,
        'enemiesKilled': enemiesKilled,
        'waveTime': waveTime.inSeconds,
      },
    );
    notifyObservers(event);
  }

  void towerBuilt(String towerType, double x, double y, int cost) {
    final event = GameEvent(
      type: GameEventType.towerBuilt,
      data: {'towerType': towerType, 'x': x, 'y': y, 'cost': cost},
    );
    notifyObservers(event);
  }

  void playerLevelUp(int newLevel, int newExperience, int evolutionPoints) {
    final event = GameEvent(
      type: GameEventType.playerLevelUp,
      data: {
        'newLevel': newLevel,
        'newExperience': newExperience,
        'evolutionPoints': evolutionPoints,
      },
    );
    notifyObservers(event);
  }

  void gameOver(bool victory, int finalScore, int wavesCompleted) {
    final event = GameEvent(
      type: victory ? GameEventType.victory : GameEventType.gameOver,
      data: {
        'victory': victory,
        'finalScore': finalScore,
        'wavesCompleted': wavesCompleted,
      },
    );
    notifyObservers(event);
  }

  void languageChanged(String oldLanguage, String newLanguage) {
    final event = GameEvent(
      type: GameEventType.languageChanged,
      data: {'oldLanguage': oldLanguage, 'newLanguage': newLanguage},
    );
    notifyObservers(event);
  }

  int get observerCount => _observers.length;

  List<Observer<GameEvent>> get observers => List.unmodifiable(_observers);
}

/// Concrete observer - Statistics Tracker
class StatisticsTracker implements Observer<GameEvent> {
  int _enemiesKilled = 0;
  int _towersBuilt = 0;
  int _wavesCompleted = 0;
  int _totalExperience = 0;
  Duration _totalPlayTime = Duration.zero;
  final DateTime _sessionStart = DateTime.now();

  // Getters for statistics
  int get enemiesKilled => _enemiesKilled;

  int get towersBuilt => _towersBuilt;

  int get wavesCompleted => _wavesCompleted;

  int get totalExperience => _totalExperience;

  Duration get totalPlayTime =>
      DateTime.now().difference(_sessionStart) + _totalPlayTime;

  @override
  void update(GameEvent event) {
    switch (event.type) {
      case GameEventType.enemyKilled:
        _enemiesKilled++;
        _totalExperience += event.data['experience'] as int? ?? 0;
        break;
      case GameEventType.towerBuilt:
        _towersBuilt++;
        break;
      case GameEventType.waveCompleted:
        _wavesCompleted++;
        break;
      case GameEventType.playerLevelUp:
        // Additional processing for level ups
        Log.debug('Player reached level ${event.data['newLevel']}!');
        break;
      case GameEventType.gameOver:
      case GameEventType.victory:
        _saveStatistics();
        break;
      default:
        // Handle other events as needed
        break;
    }
  }

  void _saveStatistics() {
    Log.debug('=== Game Session Statistics ===');
    Log.debug('Enemies killed: $_enemiesKilled');
    Log.debug('Towers built: $_towersBuilt');
    Log.debug('Waves completed: $_wavesCompleted');
    Log.debug('Total experience: $_totalExperience');
    Log.debug('Session duration: ${totalPlayTime.inMinutes} minutes');
  }

  Map<String, dynamic> getStatistics() {
    return {
      'enemiesKilled': _enemiesKilled,
      'towersBuilt': _towersBuilt,
      'wavesCompleted': _wavesCompleted,
      'totalExperience': _totalExperience,
      'totalPlayTime': totalPlayTime.inSeconds,
    };
  }

  void reset() {
    _enemiesKilled = 0;
    _towersBuilt = 0;
    _wavesCompleted = 0;
    _totalExperience = 0;
    _totalPlayTime = Duration.zero;
  }
}

/// Concrete observer - UI Notification Manager
class UINotificationManager implements Observer<GameEvent> {
  final List<String> _notifications = [];
  final int maxNotifications;

  UINotificationManager({this.maxNotifications = 10});

  @override
  void update(GameEvent event) {
    String notification;

    switch (event.type) {
      case GameEventType.enemyKilled:
        final enemyType = event.data['enemyType'] as String;
        final exp = event.data['experience'] as int;
        notification = 'Killed $enemyType (+$exp XP)';
        break;
      case GameEventType.waveCompleted:
        final wave = event.data['waveNumber'] as int;
        notification = 'Wave $wave completed!';
        break;
      case GameEventType.towerBuilt:
        final towerType = event.data['towerType'] as String;
        notification = '$towerType built';
        break;
      case GameEventType.playerLevelUp:
        final level = event.data['newLevel'] as int;
        final points = event.data['evolutionPoints'] as int;
        notification = 'Level up! Now level $level (+$points evolution points)';
        break;
      case GameEventType.victory:
        final score = event.data['finalScore'] as int;
        notification = 'Victory! Final score: $score';
        break;
      case GameEventType.gameOver:
        final waves = event.data['wavesCompleted'] as int;
        notification = 'Game Over. Survived $waves waves';
        break;
      case GameEventType.languageChanged:
        final newLang = event.data['newLanguage'] as String;
        notification = 'Language changed to $newLang';
        break;
      default:
        notification = 'Game event: ${event.type.name}';
    }

    _addNotification(notification);
  }

  void _addNotification(String notification) {
    _notifications.add(
      '[${DateTime.now().toString().substring(11, 19)}] $notification',
    );

    // Remove old notifications if we exceed the limit
    while (_notifications.length > maxNotifications) {
      _notifications.removeAt(0);
    }

    // Show notification (in real app, this would update UI)
    Log.debug('🔔 $notification');
  }

  List<String> get notifications => List.unmodifiable(_notifications);

  void clearNotifications() {
    _notifications.clear();
  }
}

/// Concrete observer - Audio Manager
class AudioManager implements Observer<GameEvent> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _volume = 1.0;

  // Getters and setters
  bool get soundEnabled => _soundEnabled;

  bool get musicEnabled => _musicEnabled;

  double get volume => _volume;

  set soundEnabled(bool enabled) {
    if (_soundEnabled != enabled) {
      _soundEnabled = enabled;
      Log.debug('🔊 Sound ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  set musicEnabled(bool enabled) {
    if (_musicEnabled != enabled) {
      _musicEnabled = enabled;
      Log.debug('🎵 Music ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  set volume(double vol) => _volume = vol.clamp(0.0, 1.0);

  @override
  void update(GameEvent event) {
    if (!_soundEnabled) return;

    switch (event.type) {
      case GameEventType.enemyKilled:
        _playSound('enemy_death.wav');
        break;
      case GameEventType.waveCompleted:
        _playSound('wave_complete.wav');
        break;
      case GameEventType.towerBuilt:
        _playSound('tower_build.wav');
        break;
      case GameEventType.playerLevelUp:
        _playSound('level_up.wav');
        break;
      case GameEventType.victory:
        _playMusic('victory_theme.mp3');
        break;
      case GameEventType.gameOver:
        _playMusic('game_over_theme.mp3');
        break;
      default:
        break;
    }
  }

  void _playSound(String soundFile) {
    if (_soundEnabled) {
      Log.debug(
        '🔊 Playing sound: $soundFile (volume: ${(_volume * 100).round()}%)',
      );
      // In real implementation, would play actual audio file
    }
  }

  void _playMusic(String musicFile) {
    if (_musicEnabled) {
      Log.debug(
        '🎵 Playing music: $musicFile (volume: ${(_volume * 100).round()}%)',
      );
      // In real implementation, would play actual music file
    }
  }
}

/// Concrete observer - Achievement System
class AchievementSystem implements Observer<GameEvent> {
  final Map<String, bool> _achievements = {};
  final List<String> _unlockedThisSession = [];

  AchievementSystem() {
    _initializeAchievements();
  }

  void _initializeAchievements() {
    _achievements.addAll({
      'first_kill': false,
      'kill_100_enemies': false,
      'kill_1000_enemies': false,
      'build_10_towers': false,
      'survive_10_waves': false,
      'reach_level_10': false,
      'victory_normal': false,
      'speed_killer': false, // Kill 10 enemies in 5 seconds
    });
  }

  @override
  void update(GameEvent event) {
    switch (event.type) {
      case GameEventType.enemyKilled:
        _checkKillAchievements();
        break;
      case GameEventType.towerBuilt:
        _checkBuildAchievements();
        break;
      case GameEventType.waveCompleted:
        _checkWaveAchievements(event.data['waveNumber'] as int);
        break;
      case GameEventType.playerLevelUp:
        _checkLevelAchievements(event.data['newLevel'] as int);
        break;
      case GameEventType.victory:
        _checkVictoryAchievements();
        break;
      default:
        break;
    }
  }

  void _checkKillAchievements() {
    // Get statistics from StatisticsTracker (in real app, would inject dependency)
    // For demo, using placeholder logic
    _unlockAchievement('first_kill');
  }

  void _checkBuildAchievements() {
    // Check building achievements
    _unlockAchievement('build_10_towers');
  }

  void _checkWaveAchievements(int waveNumber) {
    if (waveNumber >= 10) {
      _unlockAchievement('survive_10_waves');
    }
  }

  void _checkLevelAchievements(int level) {
    if (level >= 10) {
      _unlockAchievement('reach_level_10');
    }
  }

  void _checkVictoryAchievements() {
    _unlockAchievement('victory_normal');
  }

  void _unlockAchievement(String achievementId) {
    if (_achievements[achievementId] == false) {
      _achievements[achievementId] = true;
      _unlockedThisSession.add(achievementId);
      Log.debug('🏆 Achievement Unlocked: $achievementId');

      // Trigger achievement notification event
      GameEventManager().notifyObservers(
        GameEvent(
          type: GameEventType.settingsChanged,
          data: {'type': 'achievement_unlocked', 'achievement': achievementId},
        ),
      );
    }
  }

  Map<String, bool> get achievements => Map.unmodifiable(_achievements);

  List<String> get unlockedThisSession =>
      List.unmodifiable(_unlockedThisSession);

  int get totalAchievements => _achievements.length;

  int get unlockedAchievements =>
      _achievements.values.where((unlocked) => unlocked).length;

  double get completionPercentage =>
      unlockedAchievements / totalAchievements * 100;
}

/// Observer Pattern Demo
class ObserverPatternDemo {
  static void demonstratePattern() {
    Log.debug('=== Observer Pattern Demo ===\n');

    final eventManager = GameEventManager();
    final stats = StatisticsTracker();
    final notifications = UINotificationManager();
    final audio = AudioManager();
    final achievements = AchievementSystem();

    // Register observers
    eventManager.addObserver(stats);
    eventManager.addObserver(notifications);
    eventManager.addObserver(audio);
    eventManager.addObserver(achievements);

    Log.debug('Registered ${eventManager.observerCount} observers\n');

    // Simulate game events
    Log.debug('Simulating game session...\n');

    eventManager.towerBuilt('Archer Tower', 100, 200, 50);
    eventManager.enemyKilled('Ant', 10, 150, 180);
    eventManager.enemyKilled('Grasshopper', 15, 200, 220);
    eventManager.towerBuilt('Stone Thrower', 300, 250, 75);
    eventManager.waveCompleted(1, 5, Duration(seconds: 45));
    eventManager.playerLevelUp(2, 50, 1);
    eventManager.gameOver(true, 1500, 3);

    Log.debug('\n=== Final Statistics ===');
    final finalStats = stats.getStatistics();
    Log.debug('Enemies killed: ${finalStats['enemiesKilled']}');
    Log.debug('Towers built: ${finalStats['towersBuilt']}');
    Log.debug('Waves completed: ${finalStats['wavesCompleted']}');
    Log.debug(
      'Achievement progress: ${achievements.completionPercentage.toStringAsFixed(1)}%',
    );

    Log.debug('\n=== Recent Notifications ===');
    for (final notification in notifications.notifications.take(3)) {
      Log.debug(notification);
    }
  }
}
