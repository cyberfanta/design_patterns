/// App Configuration Entity - Clean Architecture Domain Layer
///
/// PATTERN: Value Object - Immutable configuration representation
/// WHERE: Domain layer for application configuration management
/// HOW: Immutable class with validation and default values
/// WHY: Ensures configuration integrity and business rules
library;

import 'package:equatable/equatable.dart';

/// Represents the application configuration
///
/// This entity encapsulates all app-wide configuration settings following
/// the Tower Defense context where players can customize their gaming
/// experience with language preferences, difficulty settings, etc.
class AppConfig extends Equatable {
  /// Language code for the application (ISO 639-1)
  final String languageCode;

  /// Theme mode preference (light, dark, system)
  final String themeMode;

  /// Sound enabled preference
  final bool soundEnabled;

  /// Music enabled preference
  final bool musicEnabled;

  /// Volume level (0.0 to 1.0)
  final double volume;

  /// Game difficulty level
  final String difficultyLevel;

  /// Show tutorial on startup
  final bool showTutorial;

  /// Analytics data collection consent
  final bool analyticsEnabled;

  /// First run flag
  final bool isFirstRun;

  /// Configuration version for migration purposes
  final int configVersion;

  /// Last updated timestamp
  final DateTime lastUpdated;

  AppConfig({
    this.languageCode = 'en',
    this.themeMode = 'system',
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.volume = 0.8,
    this.difficultyLevel = 'normal',
    this.showTutorial = true,
    this.analyticsEnabled = false,
    this.isFirstRun = true,
    this.configVersion = 1,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Default configuration for new installations
  static AppConfig get defaultConfig => AppConfig(lastUpdated: DateTime.now());

  /// Game difficulty levels
  static const List<String> supportedDifficulties = [
    'easy',
    'normal',
    'hard',
    'expert',
  ];

  /// Theme mode options
  static const List<String> supportedThemeModes = ['light', 'dark', 'system'];

  /// Language codes supported by the app
  static const List<String> supportedLanguages = ['en', 'es', 'fr', 'de'];

  /// Validate configuration values
  bool get isValid {
    return supportedLanguages.contains(languageCode) &&
        supportedThemeModes.contains(themeMode) &&
        supportedDifficulties.contains(difficultyLevel) &&
        volume >= 0.0 &&
        volume <= 1.0 &&
        configVersion > 0;
  }

  /// Create copy with modified properties
  AppConfig copyWith({
    String? languageCode,
    String? themeMode,
    bool? soundEnabled,
    bool? musicEnabled,
    double? volume,
    String? difficultyLevel,
    bool? showTutorial,
    bool? analyticsEnabled,
    bool? isFirstRun,
    int? configVersion,
    DateTime? lastUpdated,
  }) {
    return AppConfig(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      volume: volume ?? this.volume,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      showTutorial: showTutorial ?? this.showTutorial,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      isFirstRun: isFirstRun ?? this.isFirstRun,
      configVersion: configVersion ?? this.configVersion,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Create configuration for specific game difficulty
  AppConfig withDifficulty(String difficulty) {
    if (!supportedDifficulties.contains(difficulty)) {
      throw ArgumentError('Unsupported difficulty: $difficulty');
    }

    return copyWith(difficultyLevel: difficulty, lastUpdated: DateTime.now());
  }

  /// Create configuration with audio settings
  AppConfig withAudioSettings({
    bool? soundEnabled,
    bool? musicEnabled,
    double? volume,
  }) {
    final newVolume = volume?.clamp(0.0, 1.0) ?? this.volume;

    return copyWith(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      volume: newVolume,
      lastUpdated: DateTime.now(),
    );
  }

  /// Mark as not first run
  AppConfig markAsNotFirstRun() {
    return copyWith(isFirstRun: false, lastUpdated: DateTime.now());
  }

  /// Update language preference
  AppConfig withLanguage(String language) {
    if (!supportedLanguages.contains(language)) {
      throw ArgumentError('Unsupported language: $language');
    }

    return copyWith(languageCode: language, lastUpdated: DateTime.now());
  }

  /// Check if configuration needs migration
  bool get needsMigration => configVersion < 1;

  /// Get configuration summary for debugging
  Map<String, dynamic> get debugInfo => {
    'language': languageCode,
    'theme': themeMode,
    'audio_enabled': soundEnabled && musicEnabled,
    'volume': '${(volume * 100).round()}%',
    'difficulty': difficultyLevel,
    'first_run': isFirstRun,
    'version': configVersion,
    'last_updated': lastUpdated.toIso8601String(),
  };

  @override
  List<Object> get props => [
    languageCode,
    themeMode,
    soundEnabled,
    musicEnabled,
    volume,
    difficultyLevel,
    showTutorial,
    analyticsEnabled,
    isFirstRun,
    configVersion,
    lastUpdated,
  ];

  @override
  String toString() =>
      'AppConfig(lang: $languageCode, theme: $themeMode, '
      'audio: ${soundEnabled ? 'on' : 'off'}, difficulty: $difficultyLevel)';
}
