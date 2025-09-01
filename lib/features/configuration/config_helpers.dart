/// Configuration Helper Functions - Convenience Layer
///
/// PATTERN: Facade - Simplified access to configuration functionality
/// WHERE: Public API layer for easy access to configuration
/// HOW: Static methods wrapping ConfigService functionality
/// WHY: Provides convenient access without exposing internal complexity
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/configuration/domain/entities/app_config.dart';
import 'package:design_patterns/features/configuration/domain/services/config_service.dart';
import 'package:get_it/get_it.dart';

/// Helper class providing convenient access to configuration features
///
/// PATTERN: Facade - Simplifies access to complex configuration subsystem
/// Used throughout the Tower Defense app for easy configuration access
/// without directly coupling to the ConfigService.
class ConfigHelpers {
  // Private constructor to prevent instantiation
  const ConfigHelpers._();

  /// Get configuration service instance
  static ConfigService get _service {
    try {
      return GetIt.instance<ConfigService>();
    } catch (e) {
      Log.error('ConfigService not initialized: $e');
      rethrow;
    }
  }

  /// Get current configuration
  ///
  /// Returns the current app configuration with all settings.
  static AppConfig get currentConfig {
    try {
      return _service.currentConfig;
    } catch (e) {
      Log.warning('Could not get current configuration: $e');
      return AppConfig.defaultConfig; // Fallback
    }
  }

  /// Check if configuration system is initialized
  ///
  /// Returns true if the configuration system is ready to use.
  static bool get isInitialized {
    try {
      return _service.isInitialized;
    } catch (e) {
      Log.debug('Configuration not initialized: $e');
      return false;
    }
  }

  /// Get current language code
  ///
  /// Returns the currently configured language code.
  static String get languageCode {
    try {
      return _service.languageCode;
    } catch (e) {
      Log.warning('Could not get language code: $e');
      return 'en'; // Default
    }
  }

  /// Get current theme mode
  ///
  /// Returns the currently configured theme mode.
  static String get themeMode {
    try {
      return _service.themeMode;
    } catch (e) {
      Log.warning('Could not get theme mode: $e');
      return 'system'; // Default
    }
  }

  /// Get current difficulty level
  ///
  /// Returns the currently configured game difficulty.
  static String get difficultyLevel {
    try {
      return _service.difficultyLevel;
    } catch (e) {
      Log.warning('Could not get difficulty level: $e');
      return 'normal'; // Default
    }
  }

  /// Check if sound is enabled
  ///
  /// Returns true if game sound effects are enabled.
  static bool get soundEnabled {
    try {
      return _service.soundEnabled;
    } catch (e) {
      Log.warning('Could not get sound enabled status: $e');
      return true; // Default
    }
  }

  /// Check if music is enabled
  ///
  /// Returns true if game background music is enabled.
  static bool get musicEnabled {
    try {
      return _service.musicEnabled;
    } catch (e) {
      Log.warning('Could not get music enabled status: $e');
      return true; // Default
    }
  }

  /// Get current volume level
  ///
  /// Returns the current audio volume (0.0 to 1.0).
  static double get volume {
    try {
      return _service.volume;
    } catch (e) {
      Log.warning('Could not get volume level: $e');
      return 0.8; // Default
    }
  }

  /// Check if this is first run
  ///
  /// Returns true if the app has not been launched before.
  static bool get isFirstRun {
    try {
      return _service.isFirstRun;
    } catch (e) {
      Log.warning('Could not get first run status: $e');
      return true; // Default
    }
  }

  /// Update language setting
  ///
  /// Changes the app language and returns true if successful.
  static Future<bool> updateLanguage(String languageCode) async {
    try {
      if (!AppConfig.supportedLanguages.contains(languageCode)) {
        Log.error('Unsupported language code: $languageCode');
        return false;
      }

      return await _service.updateConfigValue('languageCode', languageCode);
    } catch (e) {
      Log.error('Failed to update language: $e');
      return false;
    }
  }

  /// Update theme mode
  ///
  /// Changes the app theme and returns true if successful.
  static Future<bool> updateThemeMode(String themeMode) async {
    try {
      if (!AppConfig.supportedThemeModes.contains(themeMode)) {
        Log.error('Unsupported theme mode: $themeMode');
        return false;
      }

      return await _service.updateConfigValue('themeMode', themeMode);
    } catch (e) {
      Log.error('Failed to update theme mode: $e');
      return false;
    }
  }

  /// Update difficulty level
  ///
  /// Changes the game difficulty and returns true if successful.
  static Future<bool> updateDifficulty(String difficulty) async {
    try {
      if (!AppConfig.supportedDifficulties.contains(difficulty)) {
        Log.error('Unsupported difficulty: $difficulty');
        return false;
      }

      return await _service.updateConfigValue('difficultyLevel', difficulty);
    } catch (e) {
      Log.error('Failed to update difficulty: $e');
      return false;
    }
  }

  /// Update sound enabled setting
  ///
  /// Enables/disables sound effects and returns true if successful.
  static Future<bool> updateSoundEnabled(bool enabled) async {
    try {
      return await _service.updateConfigValue('soundEnabled', enabled);
    } catch (e) {
      Log.error('Failed to update sound enabled: $e');
      return false;
    }
  }

  /// Update music enabled setting
  ///
  /// Enables/disables background music and returns true if successful.
  static Future<bool> updateMusicEnabled(bool enabled) async {
    try {
      return await _service.updateConfigValue('musicEnabled', enabled);
    } catch (e) {
      Log.error('Failed to update music enabled: $e');
      return false;
    }
  }

  /// Update volume level
  ///
  /// Changes the audio volume (0.0 to 1.0) and returns true if successful.
  static Future<bool> updateVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      return await _service.updateConfigValue('volume', clampedVolume);
    } catch (e) {
      Log.error('Failed to update volume: $e');
      return false;
    }
  }

  /// Update tutorial setting
  ///
  /// Shows/hides tutorial on startup and returns true if successful.
  static Future<bool> updateShowTutorial(bool show) async {
    try {
      return await _service.updateConfigValue('showTutorial', show);
    } catch (e) {
      Log.error('Failed to update show tutorial: $e');
      return false;
    }
  }

  /// Update analytics setting
  ///
  /// Enables/disables analytics data collection and returns true if successful.
  static Future<bool> updateAnalyticsEnabled(bool enabled) async {
    try {
      return await _service.updateConfigValue('analyticsEnabled', enabled);
    } catch (e) {
      Log.error('Failed to update analytics enabled: $e');
      return false;
    }
  }

  /// Mark app as no longer first run
  ///
  /// Sets the first run flag to false and returns true if successful.
  static Future<bool> markAsNotFirstRun() async {
    try {
      return await _service.updateConfigValue('isFirstRun', false);
    } catch (e) {
      Log.error('Failed to mark as not first run: $e');
      return false;
    }
  }

  /// Reset configuration to defaults
  ///
  /// Resets all settings to default values.
  /// Parameters:
  /// - [preserveLanguage]: Keep current language setting
  /// - [createBackup]: Create backup before reset
  static Future<bool> resetToDefaults({
    bool preserveLanguage = false,
    bool createBackup = true,
  }) async {
    try {
      return await _service.resetConfig(
        preserveLanguage: preserveLanguage,
        createBackup: createBackup,
      );
    } catch (e) {
      Log.error('Failed to reset configuration: $e');
      return false;
    }
  }

  /// Undo last configuration change
  ///
  /// Restores the previous configuration state if available.
  static bool undoLastChange() {
    try {
      return _service.undoLastChange();
    } catch (e) {
      Log.error('Failed to undo last change: $e');
      return false;
    }
  }

  /// Get supported languages
  ///
  /// Returns list of all supported language codes.
  static List<String> get supportedLanguages => AppConfig.supportedLanguages;

  /// Get supported theme modes
  ///
  /// Returns list of all supported theme modes.
  static List<String> get supportedThemeModes => AppConfig.supportedThemeModes;

  /// Get supported difficulty levels
  ///
  /// Returns list of all supported game difficulties.
  static List<String> get supportedDifficulties =>
      AppConfig.supportedDifficulties;

  /// Get configuration debug information
  ///
  /// Returns detailed configuration system status for debugging.
  static Map<String, dynamic> get debugInfo {
    try {
      return _service.getDebugInfo();
    } catch (e) {
      Log.error('Could not get debug info: $e');
      return {'error': e.toString()};
    }
  }

  /// Get configuration history count
  ///
  /// Returns number of configuration states saved for undo.
  static int get historyCount {
    try {
      return _service.historyCount;
    } catch (e) {
      Log.error('Could not get history count: $e');
      return 0;
    }
  }

  /// Check if undo is available
  ///
  /// Returns true if there are previous configuration states to restore.
  static bool get canUndo => historyCount > 0;

  /// Get configuration summary for display
  ///
  /// Returns a user-friendly summary of current settings.
  static Map<String, String> get configSummary {
    try {
      return {
        'Language': languageCode.toUpperCase(),
        'Theme': themeMode,
        'Difficulty': difficultyLevel,
        'Sound': soundEnabled ? 'On' : 'Off',
        'Music': musicEnabled ? 'On' : 'Off',
        'Volume': '${(volume * 100).round()}%',
        'First Run': isFirstRun ? 'Yes' : 'No',
      };
    } catch (e) {
      Log.error('Could not get configuration summary: $e');
      return {'Error': e.toString()};
    }
  }
}

// Convenience global functions for even easier access

/// Get current configuration
AppConfig get currentConfig => ConfigHelpers.currentConfig;

/// Get current language code
String get languageCode => ConfigHelpers.languageCode;

/// Get current theme mode
String get themeMode => ConfigHelpers.themeMode;

/// Get current difficulty level
String get difficultyLevel => ConfigHelpers.difficultyLevel;

/// Check if sound is enabled
bool get soundEnabled => ConfigHelpers.soundEnabled;

/// Check if music is enabled
bool get musicEnabled => ConfigHelpers.musicEnabled;

/// Get current volume level
double get volume => ConfigHelpers.volume;
