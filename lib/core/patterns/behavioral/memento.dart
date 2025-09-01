/// Memento Pattern - Tower Defense Context
///
/// PATTERN: Memento - Captures and restores object's internal state
/// WHERE: Game save/load system, configuration backups, undo functionality
/// HOW: Memento stores state, Originator creates/restores from memento, Caretaker manages mementos
/// WHY: Allows state restoration without exposing object's internal structure
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../logging/console_logger.dart';

/// Generic memento interface
abstract class Memento {
  DateTime get timestamp;

  String get description;
}

/// Game state memento - captures complete game state
class GameStateMemento extends Equatable implements Memento {
  @override
  final DateTime timestamp;
  @override
  final String description;

  final int playerLevel;
  final int experience;
  final int evolutionPoints;
  final int currentWave;
  final int score;
  final Map<String, dynamic> gameSettings;
  final List<Map<String, dynamic>> towers;
  final Map<String, bool> achievements;
  final Duration playTime;

  const GameStateMemento({
    required this.timestamp,
    required this.description,
    required this.playerLevel,
    required this.experience,
    required this.evolutionPoints,
    required this.currentWave,
    required this.score,
    required this.gameSettings,
    required this.towers,
    required this.achievements,
    required this.playTime,
  });

  @override
  List<Object> get props => [
    timestamp,
    description,
    playerLevel,
    experience,
    evolutionPoints,
    currentWave,
    score,
    gameSettings,
    towers,
    achievements,
    playTime,
  ];

  /// Convert memento to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'playerLevel': playerLevel,
      'experience': experience,
      'evolutionPoints': evolutionPoints,
      'currentWave': currentWave,
      'score': score,
      'gameSettings': gameSettings,
      'towers': towers,
      'achievements': achievements,
      'playTime': playTime.inMilliseconds,
    };
  }

  /// Create memento from JSON
  factory GameStateMemento.fromJson(Map<String, dynamic> json) {
    return GameStateMemento(
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      playerLevel: json['playerLevel'],
      experience: json['experience'],
      evolutionPoints: json['evolutionPoints'],
      currentWave: json['currentWave'],
      score: json['score'],
      gameSettings: Map<String, dynamic>.from(json['gameSettings']),
      towers: List<Map<String, dynamic>>.from(json['towers']),
      achievements: Map<String, bool>.from(json['achievements']),
      playTime: Duration(milliseconds: json['playTime']),
    );
  }
}

/// Configuration memento - for app settings
class ConfigurationMemento extends Equatable implements Memento {
  @override
  final DateTime timestamp;
  @override
  final String description;

  final String language;
  final bool soundEnabled;
  final bool musicEnabled;
  final double volume;
  final String theme;
  final bool notificationsEnabled;
  final Map<String, dynamic> customSettings;

  const ConfigurationMemento({
    required this.timestamp,
    required this.description,
    required this.language,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.volume,
    required this.theme,
    required this.notificationsEnabled,
    required this.customSettings,
  });

  @override
  List<Object> get props => [
    timestamp,
    description,
    language,
    soundEnabled,
    musicEnabled,
    volume,
    theme,
    notificationsEnabled,
    customSettings,
  ];

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'language': language,
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'volume': volume,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'customSettings': customSettings,
    };
  }

  factory ConfigurationMemento.fromJson(Map<String, dynamic> json) {
    return ConfigurationMemento(
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      language: json['language'],
      soundEnabled: json['soundEnabled'],
      musicEnabled: json['musicEnabled'],
      volume: json['volume'].toDouble(),
      theme: json['theme'],
      notificationsEnabled: json['notificationsEnabled'],
      customSettings: Map<String, dynamic>.from(json['customSettings']),
    );
  }
}

/// Originator - Game State Manager
class GameStateManager {
  // Current state
  int _playerLevel = 1;
  int _experience = 0;
  int _evolutionPoints = 0;
  int _currentWave = 1;
  int _score = 0;
  Map<String, dynamic> _gameSettings = {};
  List<Map<String, dynamic>> _towers = [];
  Map<String, bool> _achievements = {};
  Duration _playTime = Duration.zero;

  // Getters
  int get playerLevel => _playerLevel;

  int get experience => _experience;

  int get evolutionPoints => _evolutionPoints;

  int get currentWave => _currentWave;

  int get score => _score;

  Map<String, dynamic> get gameSettings => Map.unmodifiable(_gameSettings);

  List<Map<String, dynamic>> get towers => List.unmodifiable(_towers);

  Map<String, bool> get achievements => Map.unmodifiable(_achievements);

  Duration get playTime => _playTime;

  // State modification methods
  void setPlayerLevel(int level) => _playerLevel = level;

  void setExperience(int exp) => _experience = exp;

  void setEvolutionPoints(int points) => _evolutionPoints = points;

  void setCurrentWave(int wave) => _currentWave = wave;

  void setScore(int newScore) => _score = newScore;

  void updateGameSettings(Map<String, dynamic> settings) =>
      _gameSettings = Map.from(settings);

  void updateTowers(List<Map<String, dynamic>> towerList) =>
      _towers = List.from(towerList);

  void updateAchievements(Map<String, bool> achievementMap) =>
      _achievements = Map.from(achievementMap);

  void updatePlayTime(Duration time) => _playTime = time;

  /// Create memento with current state
  GameStateMemento createMemento(String description) {
    return GameStateMemento(
      timestamp: DateTime.now(),
      description: description,
      playerLevel: _playerLevel,
      experience: _experience,
      evolutionPoints: _evolutionPoints,
      currentWave: _currentWave,
      score: _score,
      gameSettings: Map<String, dynamic>.from(_gameSettings),
      towers: List<Map<String, dynamic>>.from(_towers),
      achievements: Map<String, bool>.from(_achievements),
      playTime: _playTime,
    );
  }

  /// Restore state from memento
  void restoreFromMemento(GameStateMemento memento) {
    _playerLevel = memento.playerLevel;
    _experience = memento.experience;
    _evolutionPoints = memento.evolutionPoints;
    _currentWave = memento.currentWave;
    _score = memento.score;
    _gameSettings = Map<String, dynamic>.from(memento.gameSettings);
    _towers = List<Map<String, dynamic>>.from(memento.towers);
    _achievements = Map<String, bool>.from(memento.achievements);
    _playTime = memento.playTime;
  }

  /// Quick save current state
  GameStateMemento quickSave() {
    return createMemento(
      'Quick Save - ${DateTime.now().toString().substring(0, 19)}',
    );
  }

  /// Create checkpoint at specific moments
  GameStateMemento createCheckpoint(String checkpointName) {
    return createMemento('Checkpoint: $checkpointName');
  }
}

/// Originator - Configuration Manager
class ConfigurationManager {
  // Current configuration state
  String _language = 'en';
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _volume = 1.0;
  String _theme = 'dark';
  bool _notificationsEnabled = true;
  Map<String, dynamic> _customSettings = {};

  // Getters
  String get language => _language;

  bool get soundEnabled => _soundEnabled;

  bool get musicEnabled => _musicEnabled;

  double get volume => _volume;

  String get theme => _theme;

  bool get notificationsEnabled => _notificationsEnabled;

  Map<String, dynamic> get customSettings => Map.unmodifiable(_customSettings);

  // Setters
  void setLanguage(String lang) => _language = lang;

  void setSoundEnabled(bool enabled) => _soundEnabled = enabled;

  void setMusicEnabled(bool enabled) => _musicEnabled = enabled;

  void setVolume(double vol) => _volume = vol.clamp(0.0, 1.0);

  void setTheme(String selectedTheme) => _theme = selectedTheme;

  void setNotificationsEnabled(bool enabled) => _notificationsEnabled = enabled;

  void updateCustomSettings(Map<String, dynamic> settings) =>
      _customSettings = Map.from(settings);

  /// Create configuration memento
  ConfigurationMemento createMemento(String description) {
    return ConfigurationMemento(
      timestamp: DateTime.now(),
      description: description,
      language: _language,
      soundEnabled: _soundEnabled,
      musicEnabled: _musicEnabled,
      volume: _volume,
      theme: _theme,
      notificationsEnabled: _notificationsEnabled,
      customSettings: Map<String, dynamic>.from(_customSettings),
    );
  }

  /// Restore configuration from memento
  void restoreFromMemento(ConfigurationMemento memento) {
    _language = memento.language;
    _soundEnabled = memento.soundEnabled;
    _musicEnabled = memento.musicEnabled;
    _volume = memento.volume;
    _theme = memento.theme;
    _notificationsEnabled = memento.notificationsEnabled;
    _customSettings = Map<String, dynamic>.from(memento.customSettings);
  }

  /// Create backup before making changes
  ConfigurationMemento createBackup() {
    return createMemento(
      'Auto Backup - ${DateTime.now().toString().substring(0, 19)}',
    );
  }

  /// Create named configuration preset
  ConfigurationMemento createPreset(String presetName) {
    return createMemento('Preset: $presetName');
  }
}

/// Caretaker - Manages mementos and provides undo/redo functionality
class MementoCaretaker<T extends Memento> {
  final List<T> _mementos = [];
  final int maxMementos;
  int _currentIndex = -1;

  MementoCaretaker({this.maxMementos = 10});

  /// Save memento
  void saveMemento(T memento) {
    // Remove any mementos after current index (for redo functionality)
    if (_currentIndex < _mementos.length - 1) {
      _mementos.removeRange(_currentIndex + 1, _mementos.length);
    }

    // Add new memento
    _mementos.add(memento);
    _currentIndex = _mementos.length - 1;

    // Remove oldest mementos if we exceed the limit
    while (_mementos.length > maxMementos) {
      _mementos.removeAt(0);
      _currentIndex--;
    }
  }

  /// Get memento for undo operation
  T? undo() {
    if (canUndo()) {
      _currentIndex--;
      return _mementos[_currentIndex];
    }
    return null;
  }

  /// Get memento for redo operation
  T? redo() {
    if (canRedo()) {
      _currentIndex++;
      return _mementos[_currentIndex];
    }
    return null;
  }

  /// Check if undo is possible
  bool canUndo() => _currentIndex > 0;

  /// Check if redo is possible
  bool canRedo() => _currentIndex < _mementos.length - 1;

  /// Get current memento
  T? getCurrentMemento() {
    if (_currentIndex >= 0 && _currentIndex < _mementos.length) {
      return _mementos[_currentIndex];
    }
    return null;
  }

  /// Get all saved mementos
  List<T> getAllMementos() => List.unmodifiable(_mementos);

  /// Get memento by description
  T? getMementoByDescription(String description) {
    try {
      return _mementos.firstWhere(
        (memento) => memento.description == description,
      );
    } catch (e) {
      return null;
    }
  }

  /// Clear all mementos
  void clear() {
    _mementos.clear();
    _currentIndex = -1;
  }

  /// Get memento count
  int get mementoCount => _mementos.length;

  /// Get current position
  int get currentPosition => _currentIndex;
}

/// Game Save System using Memento Pattern
class GameSaveSystem {
  final GameStateManager _gameStateManager;
  final MementoCaretaker<GameStateMemento> _gameCaretaker;
  final ConfigurationManager _configManager;
  final MementoCaretaker<ConfigurationMemento> _configCaretaker;

  GameSaveSystem({
    required GameStateManager gameStateManager,
    required ConfigurationManager configManager,
  }) : _gameStateManager = gameStateManager,
       _configManager = configManager,
       _gameCaretaker = MementoCaretaker<GameStateMemento>(maxMementos: 5),
       _configCaretaker = MementoCaretaker<ConfigurationMemento>(
         maxMementos: 10,
       );

  // Game state operations
  void quickSaveGame() {
    final memento = _gameStateManager.quickSave();
    _gameCaretaker.saveMemento(memento);
    if (kDebugMode) {
      Log.debug('✅ Game quick saved: ${memento.description}');
    }
  }

  void saveGameCheckpoint(String checkpointName) {
    final memento = _gameStateManager.createCheckpoint(checkpointName);
    _gameCaretaker.saveMemento(memento);
    Log.debug('✅ Checkpoint saved: $checkpointName');
  }

  bool loadPreviousGame() {
    final memento = _gameCaretaker.undo();
    if (memento != null) {
      _gameStateManager.restoreFromMemento(memento);
      Log.debug('✅ Game loaded: ${memento.description}');
      return true;
    }
    Log.debug('❌ No previous save available');
    return false;
  }

  bool loadSpecificSave(String description) {
    final memento = _gameCaretaker.getMementoByDescription(description);
    if (memento != null) {
      _gameStateManager.restoreFromMemento(memento);
      Log.debug('✅ Game loaded: ${memento.description}');
      return true;
    }
    Log.debug('❌ Save not found: $description');
    return false;
  }

  // Configuration operations
  void backupConfiguration() {
    final memento = _configManager.createBackup();
    _configCaretaker.saveMemento(memento);
    Log.debug('✅ Configuration backed up');
  }

  void saveConfigurationPreset(String presetName) {
    final memento = _configManager.createPreset(presetName);
    _configCaretaker.saveMemento(memento);
    Log.debug('✅ Configuration preset saved: $presetName');
  }

  bool undoConfigurationChanges() {
    final memento = _configCaretaker.undo();
    if (memento != null) {
      _configManager.restoreFromMemento(memento);
      Log.debug('✅ Configuration restored: ${memento.description}');
      return true;
    }
    Log.debug('❌ No previous configuration available');
    return false;
  }

  bool loadConfigurationPreset(String presetName) {
    final memento = _configCaretaker.getMementoByDescription(
      'Preset: $presetName',
    );
    if (memento != null) {
      _configManager.restoreFromMemento(memento);
      Log.debug('✅ Configuration preset loaded: $presetName');
      return true;
    }
    Log.debug('❌ Configuration preset not found: $presetName');
    return false;
  }

  // Information methods
  List<String> getAvailableSaves() {
    return _gameCaretaker
        .getAllMementos()
        .map((memento) => memento.description)
        .toList();
  }

  List<String> getAvailableConfigPresets() {
    return _configCaretaker
        .getAllMementos()
        .where((memento) => memento.description.startsWith('Preset:'))
        .map((memento) => memento.description.replaceFirst('Preset: ', ''))
        .toList();
  }

  bool get canUndoGame => _gameCaretaker.canUndo();

  bool get canRedoGame => _gameCaretaker.canRedo();

  bool get canUndoConfig => _configCaretaker.canUndo();

  bool get canRedoConfig => _configCaretaker.canRedo();
}

/// Memento Pattern Demo
class MementoPatternDemo {
  static void demonstratePattern() {
    Log.debug('=== Memento Pattern Demo ===\n');

    final gameManager = GameStateManager();
    final configManager = ConfigurationManager();
    final saveSystem = GameSaveSystem(
      gameStateManager: gameManager,
      configManager: configManager,
    );

    // Simulate game progress
    Log.debug('Starting new game...');
    gameManager.setPlayerLevel(1);
    gameManager.setScore(0);
    gameManager.setCurrentWave(1);

    // Save initial state
    saveSystem.saveGameCheckpoint('Game Start');

    // Progress in game
    Log.debug('\nProgressing in game...');
    gameManager.setPlayerLevel(3);
    gameManager.setScore(500);
    gameManager.setCurrentWave(5);
    saveSystem.quickSaveGame();

    // More progress
    Log.debug('More progress...');
    gameManager.setPlayerLevel(5);
    gameManager.setScore(1200);
    gameManager.setCurrentWave(8);
    saveSystem.saveGameCheckpoint('Mid Game');

    Log.debug(
      '\nCurrent state: Level ${gameManager.playerLevel}, Score ${gameManager.score}, Wave ${gameManager.currentWave}',
    );

    // Test loading previous save
    Log.debug('\nLoading previous save...');
    saveSystem.loadPreviousGame();
    Log.debug(
      'After load: Level ${gameManager.playerLevel}, Score ${gameManager.score}, Wave ${gameManager.currentWave}',
    );

    // Test configuration backup and restore
    Log.debug('\n--- Configuration Management ---');
    configManager.setLanguage('en');
    configManager.setVolume(0.8);
    configManager.setTheme('dark');

    saveSystem.backupConfiguration();
    saveSystem.saveConfigurationPreset('Gaming Setup');

    Log.debug(
      'Original config: ${configManager.language}, vol: ${configManager.volume}, theme: ${configManager.theme}',
    );

    // Change configuration
    configManager.setLanguage('es');
    configManager.setVolume(0.5);
    configManager.setTheme('light');

    Log.debug(
      'Changed config: ${configManager.language}, vol: ${configManager.volume}, theme: ${configManager.theme}',
    );

    // Restore configuration
    saveSystem.undoConfigurationChanges();
    Log.debug(
      'Restored config: ${configManager.language}, vol: ${configManager.volume}, theme: ${configManager.theme}',
    );

    // Show available saves and presets
    Log.debug('\nAvailable saves: ${saveSystem.getAvailableSaves()}');
    Log.debug('Available presets: ${saveSystem.getAvailableConfigPresets()}');
  }
}
