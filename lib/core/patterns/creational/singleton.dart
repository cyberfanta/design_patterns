/// Singleton Pattern - Tower Defense Context
///
/// PATTERN: Singleton - Ensures only one instance exists with global access
/// WHERE: GameManager for centralized game state management
/// HOW: Private constructor with static instance and factory constructor
/// WHY: Need single source of truth for game state and global access point
library;

import 'package:equatable/equatable.dart';

import '../../logging/console_logger.dart';

/// Game state enumeration
enum GameState { menu, loading, playing, paused, gameOver, victory }

/// Player progress data
class PlayerProgress extends Equatable {
  final int level;
  final int experience;
  final int evolutionPoints;
  final int currentWave;
  final int highScore;

  const PlayerProgress({
    required this.level,
    required this.experience,
    required this.evolutionPoints,
    required this.currentWave,
    required this.highScore,
  });

  PlayerProgress copyWith({
    int? level,
    int? experience,
    int? evolutionPoints,
    int? currentWave,
    int? highScore,
  }) {
    return PlayerProgress(
      level: level ?? this.level,
      experience: experience ?? this.experience,
      evolutionPoints: evolutionPoints ?? this.evolutionPoints,
      currentWave: currentWave ?? this.currentWave,
      highScore: highScore ?? this.highScore,
    );
  }

  @override
  List<Object> get props => [
    level,
    experience,
    evolutionPoints,
    currentWave,
    highScore,
  ];
}

/// Game statistics
class GameStats extends Equatable {
  final int enemiesKilled;
  final int towersBuilt;
  final int totalDamageDealt;
  final Duration playTime;
  final int wavesSurvived;

  const GameStats({
    required this.enemiesKilled,
    required this.towersBuilt,
    required this.totalDamageDealt,
    required this.playTime,
    required this.wavesSurvived,
  });

  GameStats copyWith({
    int? enemiesKilled,
    int? towersBuilt,
    int? totalDamageDealt,
    Duration? playTime,
    int? wavesSurvived,
  }) {
    return GameStats(
      enemiesKilled: enemiesKilled ?? this.enemiesKilled,
      towersBuilt: towersBuilt ?? this.towersBuilt,
      totalDamageDealt: totalDamageDealt ?? this.totalDamageDealt,
      playTime: playTime ?? this.playTime,
      wavesSurvived: wavesSurvived ?? this.wavesSurvived,
    );
  }

  @override
  List<Object> get props => [
    enemiesKilled,
    towersBuilt,
    totalDamageDealt,
    playTime,
    wavesSurvived,
  ];
}

/// Singleton GameManager - Controls all game state
class GameManager {
  // Private static instance
  static GameManager? _instance;

  // Private constructor to prevent external instantiation
  GameManager._internal() {
    _initialize();
  }

  // Factory constructor - returns the same instance
  factory GameManager() {
    _instance ??= GameManager._internal();
    return _instance!;
  }

  // Alternative static getter for global access
  static GameManager get instance {
    _instance ??= GameManager._internal();
    return _instance!;
  }

  // Game state variables
  GameState _currentState = GameState.menu;
  PlayerProgress _playerProgress = const PlayerProgress(
    level: 1,
    experience: 0,
    evolutionPoints: 0,
    currentWave: 1,
    highScore: 0,
  );
  GameStats _gameStats = const GameStats(
    enemiesKilled: 0,
    towersBuilt: 0,
    totalDamageDealt: 0,
    playTime: Duration.zero,
    wavesSurvived: 0,
  );

  // Observers for state changes (Observer Pattern integration)
  final List<Function(GameState)> _stateObservers = [];
  final List<Function(PlayerProgress)> _progressObservers = [];
  final List<Function(GameStats)> _statsObservers = [];

  // Private initialization method
  void _initialize() {
    // Initialize game systems, load saved data, etc.
    Log.debug('GameManager initialized');
  }

  // Getters for accessing state
  GameState get currentState => _currentState;

  PlayerProgress get playerProgress => _playerProgress;

  GameStats get gameStats => _gameStats;

  bool get isPlaying => _currentState == GameState.playing;

  bool get isPaused => _currentState == GameState.paused;

  bool get isGameOver => _currentState == GameState.gameOver;

  // State management methods
  void changeState(GameState newState) {
    if (_currentState != newState) {
      final oldState = _currentState;
      _currentState = newState;

      // Notify observers
      for (final observer in _stateObservers) {
        observer(newState);
      }

      // Handle state-specific logic
      _handleStateChange(oldState, newState);
    }
  }

  void startGame() {
    changeState(GameState.playing);
    _resetGameStats();
  }

  void pauseGame() {
    if (_currentState == GameState.playing) {
      changeState(GameState.paused);
    }
  }

  void resumeGame() {
    if (_currentState == GameState.paused) {
      changeState(GameState.playing);
    }
  }

  void endGame(bool victory) {
    changeState(victory ? GameState.victory : GameState.gameOver);
    _updateHighScore();
  }

  void returnToMenu() {
    changeState(GameState.menu);
  }

  // Player progress management
  void addExperience(int amount) {
    final newExperience = _playerProgress.experience + amount;
    final newLevel = _calculateLevel(newExperience);
    final evolutionPointsGained = newLevel - _playerProgress.level;

    _playerProgress = _playerProgress.copyWith(
      experience: newExperience,
      level: newLevel,
      evolutionPoints: _playerProgress.evolutionPoints + evolutionPointsGained,
    );

    // Notify observers
    for (final observer in _progressObservers) {
      observer(_playerProgress);
    }
  }

  void spendEvolutionPoints(int amount) {
    if (_playerProgress.evolutionPoints >= amount) {
      _playerProgress = _playerProgress.copyWith(
        evolutionPoints: _playerProgress.evolutionPoints - amount,
      );

      // Notify observers
      for (final observer in _progressObservers) {
        observer(_playerProgress);
      }
    }
  }

  void advanceWave() {
    _playerProgress = _playerProgress.copyWith(
      currentWave: _playerProgress.currentWave + 1,
    );

    _gameStats = _gameStats.copyWith(
      wavesSurvived: _gameStats.wavesSurvived + 1,
    );

    // Notify observers
    for (final observer in _progressObservers) {
      observer(_playerProgress);
    }
    for (final observer in _statsObservers) {
      observer(_gameStats);
    }
  }

  // Game statistics updates
  void recordEnemyKilled(int experienceGained) {
    _gameStats = _gameStats.copyWith(
      enemiesKilled: _gameStats.enemiesKilled + 1,
    );

    addExperience(experienceGained);

    // Notify observers
    for (final observer in _statsObservers) {
      observer(_gameStats);
    }
  }

  void recordTowerBuilt() {
    _gameStats = _gameStats.copyWith(towersBuilt: _gameStats.towersBuilt + 1);

    // Notify observers
    for (final observer in _statsObservers) {
      observer(_gameStats);
    }
  }

  void recordDamageDealt(int damage) {
    _gameStats = _gameStats.copyWith(
      totalDamageDealt: _gameStats.totalDamageDealt + damage,
    );

    // Notify observers
    for (final observer in _statsObservers) {
      observer(_gameStats);
    }
  }

  // Observer pattern methods
  void addStateObserver(Function(GameState) observer) {
    _stateObservers.add(observer);
  }

  void removeStateObserver(Function(GameState) observer) {
    _stateObservers.remove(observer);
  }

  void addProgressObserver(Function(PlayerProgress) observer) {
    _progressObservers.add(observer);
  }

  void removeProgressObserver(Function(PlayerProgress) observer) {
    _progressObservers.remove(observer);
  }

  void addStatsObserver(Function(GameStats) observer) {
    _statsObservers.add(observer);
  }

  void removeStatsObserver(Function(GameStats) observer) {
    _statsObservers.remove(observer);
  }

  // Private helper methods
  void _handleStateChange(GameState oldState, GameState newState) {
    Log.debug('Game state changed from $oldState to $newState');

    switch (newState) {
      case GameState.playing:
        // Start game timers, resume systems
        break;
      case GameState.paused:
        // Pause timers, save state
        break;
      case GameState.gameOver:
      case GameState.victory:
        // Stop timers, calculate final score
        break;
      case GameState.menu:
        // Clean up game resources
        break;
      case GameState.loading:
        // Show loading indicators
        break;
    }
  }

  int _calculateLevel(int experience) {
    // Simple level calculation: level = sqrt(experience / 100) + 1
    return (experience / 100).floor() + 1;
  }

  void _resetGameStats() {
    _gameStats = const GameStats(
      enemiesKilled: 0,
      towersBuilt: 0,
      totalDamageDealt: 0,
      playTime: Duration.zero,
      wavesSurvived: 0,
    );

    // Notify observers
    for (final observer in _statsObservers) {
      observer(_gameStats);
    }
  }

  void _updateHighScore() {
    final currentScore = _calculateCurrentScore();
    if (currentScore > _playerProgress.highScore) {
      _playerProgress = _playerProgress.copyWith(highScore: currentScore);

      // Notify observers
      for (final observer in _progressObservers) {
        observer(_playerProgress);
      }
    }
  }

  int _calculateCurrentScore() {
    return _gameStats.enemiesKilled * 10 +
        _gameStats.wavesSurvived * 100 +
        _playerProgress.level * 50;
  }

  // Reset method for testing or complete reset
  void reset() {
    _currentState = GameState.menu;
    _playerProgress = const PlayerProgress(
      level: 1,
      experience: 0,
      evolutionPoints: 0,
      currentWave: 1,
      highScore: 0,
    );
    _gameStats = const GameStats(
      enemiesKilled: 0,
      towersBuilt: 0,
      totalDamageDealt: 0,
      playTime: Duration.zero,
      wavesSurvived: 0,
    );

    // Clear observers
    _stateObservers.clear();
    _progressObservers.clear();
    _statsObservers.clear();
  }

  // Save/Load methods (would integrate with persistence layer)
  Map<String, dynamic> toJson() {
    return {
      'currentState': _currentState.index,
      'playerProgress': {
        'level': _playerProgress.level,
        'experience': _playerProgress.experience,
        'evolutionPoints': _playerProgress.evolutionPoints,
        'currentWave': _playerProgress.currentWave,
        'highScore': _playerProgress.highScore,
      },
      'gameStats': {
        'enemiesKilled': _gameStats.enemiesKilled,
        'towersBuilt': _gameStats.towersBuilt,
        'totalDamageDealt': _gameStats.totalDamageDealt,
        'playTime': _gameStats.playTime.inMilliseconds,
        'wavesSurvived': _gameStats.wavesSurvived,
      },
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _currentState = GameState.values[json['currentState'] ?? 0];

    final progressData = json['playerProgress'] ?? {};
    _playerProgress = PlayerProgress(
      level: progressData['level'] ?? 1,
      experience: progressData['experience'] ?? 0,
      evolutionPoints: progressData['evolutionPoints'] ?? 0,
      currentWave: progressData['currentWave'] ?? 1,
      highScore: progressData['highScore'] ?? 0,
    );

    final statsData = json['gameStats'] ?? {};
    _gameStats = GameStats(
      enemiesKilled: statsData['enemiesKilled'] ?? 0,
      towersBuilt: statsData['towersBuilt'] ?? 0,
      totalDamageDealt: statsData['totalDamageDealt'] ?? 0,
      playTime: Duration(milliseconds: statsData['playTime'] ?? 0),
      wavesSurvived: statsData['wavesSurvived'] ?? 0,
    );
  }
}

/// Helper class for easy GameManager access
class Game {
  static GameManager get manager => GameManager.instance;

  static GameState get state => manager.currentState;

  static PlayerProgress get progress => manager.playerProgress;

  static GameStats get stats => manager.gameStats;

  static void start() => manager.startGame();

  static void pause() => manager.pauseGame();

  static void resume() => manager.resumeGame();

  static void end({bool victory = false}) => manager.endGame(victory);
}
