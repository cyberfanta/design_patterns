/// Configuration Service - Singleton + Memento + Observer Implementation
///
/// PATTERN: Singleton + Observer + Memento - Centralized configuration management
/// WHERE: Domain layer service for global configuration access
/// HOW: Singleton with Observer notifications and Memento state management
/// WHY: Ensures single source of truth for configuration across the app
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/patterns/behavioral/memento.dart';
import 'package:design_patterns/core/patterns/behavioral/observer.dart';
import 'package:design_patterns/features/configuration/domain/entities/app_config.dart';
import 'package:design_patterns/features/configuration/domain/usecases/get_config.dart';
import 'package:design_patterns/features/configuration/domain/usecases/reset_config.dart';
import 'package:design_patterns/features/configuration/domain/usecases/save_config.dart';

/// Configuration service implementing multiple design patterns
///
/// PATTERN: Singleton - Ensures single instance across the app
/// PATTERN: Observer - Notifies UI components of configuration changes
/// PATTERN: Memento - Saves and restores configuration state
///
/// In the Tower Defense context, this service manages all game and app
/// configuration including language, difficulty, audio settings.
class ConfigService extends Subject<ConfigChangeEvent>
    implements Observer<GameEvent> {
  // PATTERN: Singleton implementation
  static final ConfigService _instance = ConfigService._internal();

  factory ConfigService() => _instance;

  ConfigService._internal() {
    // Register as observer for game events
    GameEventManager().addObserver(this);
    Log.debug('ConfigService initialized as Singleton');
  }

  // Observer pattern - list of components listening for config changes
  final List<Observer<ConfigChangeEvent>> _observers = [];

  // Current state
  AppConfig _currentConfig = AppConfig.defaultConfig;
  final List<ConfigMemento> _configHistory = [];
  bool _isInitialized = false;

  // Use cases injected via dependency injection
  GetConfig? _getConfig;
  SaveConfig? _saveConfig;
  ResetConfig? _resetConfig;

  // Getters for current state
  AppConfig get currentConfig => _currentConfig;

  bool get isInitialized => _isInitialized;

  // Convenient getters for common settings
  String get languageCode => _currentConfig.languageCode;

  String get themeMode => _currentConfig.themeMode;

  bool get soundEnabled => _currentConfig.soundEnabled;

  bool get musicEnabled => _currentConfig.musicEnabled;

  double get volume => _currentConfig.volume;

  String get difficultyLevel => _currentConfig.difficultyLevel;

  bool get isFirstRun => _currentConfig.isFirstRun;

  /// Initialize the configuration service with use cases
  void initialize({
    required GetConfig getConfig,
    required SaveConfig saveConfig,
    required ResetConfig resetConfig,
  }) {
    _getConfig = getConfig;
    _saveConfig = saveConfig;
    _resetConfig = resetConfig;
    Log.debug('ConfigService dependencies injected');
  }

  /// Initialize with configuration loading
  Future<void> initializeWithConfig() async {
    try {
      Log.debug('Initializing configuration service...');

      if (_getConfig == null) {
        Log.error('ConfigService not properly initialized with dependencies');
        return;
      }

      // Load current configuration
      final result = await _getConfig!.execute();

      result.fold(
        (failure) {
          Log.warning(
            'Could not load config, using default: ${failure.toString()}',
          );
          _setConfig(AppConfig.defaultConfig);
        },
        (config) {
          Log.success(
            'Configuration loaded: ${config.languageCode}, ${config.themeMode}',
          );
          _setConfig(config);
        },
      );

      _isInitialized = true;
      Log.success('ConfigService initialization completed');
    } catch (e) {
      Log.error('Error initializing configuration service: $e');
      _setConfig(AppConfig.defaultConfig);
      _isInitialized = true; // Set as initialized even with defaults
    }
  }

  /// Update configuration
  Future<bool> updateConfig(AppConfig newConfig) async {
    try {
      if (_saveConfig == null) {
        Log.error('SaveConfig use case not injected');
        return false;
      }

      Log.debug('Updating configuration...');

      final oldConfig = _currentConfig;

      // Create memento before change
      final memento = createMemento();
      _saveToHistory(memento);

      final result = await _saveConfig!.execute(newConfig);

      return result.fold(
        (failure) {
          Log.error('Failed to update configuration: ${failure.toString()}');
          return false;
        },
        (_) {
          _setConfig(newConfig);
          _notifyConfigChange(oldConfig, newConfig);
          return true;
        },
      );
    } catch (e) {
      Log.error('Error updating configuration: $e');
      return false;
    }
  }

  /// Update specific configuration value
  Future<bool> updateConfigValue(String key, dynamic value) async {
    try {
      if (_saveConfig == null) {
        Log.error('SaveConfig use case not injected');
        return false;
      }

      Log.debug('Updating configuration value: $key = $value');

      // Create new config with updated value
      AppConfig newConfig;

      switch (key) {
        case 'languageCode':
          newConfig = _currentConfig.withLanguage(value as String);
          break;
        case 'themeMode':
          newConfig = _currentConfig.copyWith(themeMode: value as String);
          break;
        case 'soundEnabled':
          newConfig = _currentConfig.withAudioSettings(
            soundEnabled: value as bool,
          );
          break;
        case 'musicEnabled':
          newConfig = _currentConfig.withAudioSettings(
            musicEnabled: value as bool,
          );
          break;
        case 'volume':
          newConfig = _currentConfig.withAudioSettings(volume: value as double);
          break;
        case 'difficultyLevel':
          newConfig = _currentConfig.withDifficulty(value as String);
          break;
        case 'showTutorial':
          newConfig = _currentConfig.copyWith(showTutorial: value as bool);
          break;
        case 'analyticsEnabled':
          newConfig = _currentConfig.copyWith(analyticsEnabled: value as bool);
          break;
        default:
          Log.error('Unknown configuration key: $key');
          return false;
      }

      return await updateConfig(newConfig);
    } catch (e) {
      Log.error('Error updating configuration value $key: $e');
      return false;
    }
  }

  /// Reset configuration to defaults
  Future<bool> resetConfig({
    bool preserveLanguage = false,
    bool createBackup = true,
  }) async {
    try {
      if (_resetConfig == null) {
        Log.error('ResetConfig use case not injected');
        return false;
      }

      Log.debug('Resetting configuration to defaults...');

      final oldConfig = _currentConfig;

      // Create backup before reset
      if (createBackup) {
        final memento = createMemento();
        _saveToHistory(memento);
      }

      final result = await _resetConfig!.execute(
        createBackup: createBackup,
        preserveLanguage: preserveLanguage,
      );

      return result.fold(
        (failure) {
          Log.error('Failed to reset configuration: ${failure.toString()}');
          return false;
        },
        (defaultConfig) {
          _setConfig(defaultConfig);
          _notifyConfigChange(oldConfig, defaultConfig);
          Log.success('Configuration reset to defaults');
          return true;
        },
      );
    } catch (e) {
      Log.error('Error resetting configuration: $e');
      return false;
    }
  }

  /// Set current configuration and notify observers
  void _setConfig(AppConfig config) {
    _currentConfig = config;
    Log.debug('Configuration updated: ${config.debugInfo}');
  }

  /// Notify observers of configuration change
  void _notifyConfigChange(AppConfig oldConfig, AppConfig newConfig) {
    // PATTERN: Observer - Notify all observers of configuration change
    final event = ConfigChangeEvent(
      oldConfig: oldConfig,
      newConfig: newConfig,
      timestamp: DateTime.now(),
    );

    notifyObservers(event);
    Log.debug(
      'Configuration change notification sent to ${_observers.length} observers',
    );
  }

  // PATTERN: Memento - Save current state
  ConfigMemento createMemento() {
    return ConfigMemento(config: _currentConfig, timestamp: DateTime.now());
  }

  // PATTERN: Memento - Restore from saved state
  void restoreFromMemento(ConfigMemento memento) {
    final oldConfig = _currentConfig;
    _currentConfig = memento.config;

    Log.debug('ConfigService state restored from memento');

    // Notify observers of restoration
    final event = ConfigChangeEvent(
      oldConfig: oldConfig,
      newConfig: _currentConfig,
      timestamp: DateTime.now(),
      isRestore: true,
    );

    notifyObservers(event);
  }

  /// Save memento to history for undo functionality
  void _saveToHistory(ConfigMemento memento) {
    _configHistory.add(memento);

    // Keep only last 10 states
    if (_configHistory.length > 10) {
      _configHistory.removeAt(0);
    }

    Log.debug(
      'Configuration state saved to history (${_configHistory.length} states)',
    );
  }

  /// Undo last configuration change
  bool undoLastChange() {
    if (_configHistory.isEmpty) {
      Log.warning('No configuration history available for undo');
      return false;
    }

    final lastMemento = _configHistory.removeLast();
    restoreFromMemento(lastMemento);

    Log.info('Configuration change undone');
    return true;
  }

  /// Get configuration history count
  int get historyCount => _configHistory.length;

  /// Get configuration debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'current_config': _currentConfig.debugInfo,
      'is_initialized': _isInitialized,
      'history_count': _configHistory.length,
      'observers_count': _observers.length,
      'last_updated': _currentConfig.lastUpdated.toIso8601String(),
    };
  }

  // PATTERN: Observer - Implementation for game events
  @override
  void update(GameEvent event) {
    // Listen for game-related configuration events
    switch (event.type) {
      case GameEventType.gameOver:
        // Could update difficulty based on performance
        Log.debug('Game over event received in ConfigService');
        break;
      case GameEventType.playerLevelUp:
        // Could unlock new configuration options
        Log.debug('Player level up event received in ConfigService');
        break;
      default:
        // Ignore other events
        break;
    }
  }

  // PATTERN: Observer - Subject implementation
  @override
  void addObserver(Observer<ConfigChangeEvent> observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
      Log.debug('Observer added to ConfigService (${_observers.length} total)');
    }
  }

  @override
  void removeObserver(Observer<ConfigChangeEvent> observer) {
    _observers.remove(observer);
    Log.debug(
      'Observer removed from ConfigService (${_observers.length} remaining)',
    );
  }

  @override
  void notifyObservers(ConfigChangeEvent event) {
    Log.debug(
      'Notifying ${_observers.length} observers of configuration change',
    );

    for (final observer in _observers) {
      try {
        observer.update(event);
      } catch (e) {
        Log.error('Error notifying configuration observer: $e');
      }
    }
  }
}

/// Event class for configuration changes
class ConfigChangeEvent {
  final AppConfig oldConfig;
  final AppConfig newConfig;
  final DateTime timestamp;
  final bool isRestore;

  const ConfigChangeEvent({
    required this.oldConfig,
    required this.newConfig,
    required this.timestamp,
    this.isRestore = false,
  });

  /// Get list of changed configuration keys
  List<String> get changedKeys {
    final changes = <String>[];

    if (oldConfig.languageCode != newConfig.languageCode)
      changes.add('languageCode');
    if (oldConfig.themeMode != newConfig.themeMode) changes.add('themeMode');
    if (oldConfig.soundEnabled != newConfig.soundEnabled)
      changes.add('soundEnabled');
    if (oldConfig.musicEnabled != newConfig.musicEnabled)
      changes.add('musicEnabled');
    if (oldConfig.volume != newConfig.volume) changes.add('volume');
    if (oldConfig.difficultyLevel != newConfig.difficultyLevel)
      changes.add('difficultyLevel');
    if (oldConfig.showTutorial != newConfig.showTutorial)
      changes.add('showTutorial');
    if (oldConfig.analyticsEnabled != newConfig.analyticsEnabled)
      changes.add('analyticsEnabled');
    if (oldConfig.isFirstRun != newConfig.isFirstRun) changes.add('isFirstRun');

    return changes;
  }

  /// Check if specific key changed
  bool hasChanged(String key) => changedKeys.contains(key);
}

/// Memento class for saving configuration service state
class ConfigMemento extends Memento {
  final AppConfig config;

  @override
  final DateTime timestamp;

  @override
  final String description;

  ConfigMemento({required this.config, required this.timestamp})
    : description =
          'Config: ${config.languageCode}/${config.themeMode}/${config.difficultyLevel}';

  Map<String, dynamic> toJson() {
    return {
      'config': config.debugInfo,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  @override
  String toString() =>
      'ConfigMemento($description at ${timestamp.toIso8601String()})';
}
