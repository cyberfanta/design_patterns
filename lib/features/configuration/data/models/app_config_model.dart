/// App Configuration Model - Clean Architecture Data Layer
///
/// PATTERN: Data Transfer Object (DTO) - Data layer representation
/// WHERE: Data layer for JSON/SQLite serialization
/// HOW: Extends domain entity with persistence capabilities
/// WHY: Separates data structure from business logic
library;

import 'package:design_patterns/features/configuration/domain/entities/app_config.dart';

/// Data model for AppConfig entity with JSON/SQLite serialization
///
/// This model extends the domain AppConfig entity to provide
/// JSON serialization capabilities for SQLite storage and
/// configuration management in the Tower Defense app.
class AppConfigModel extends AppConfig {
  AppConfigModel({
    required super.languageCode,
    required super.themeMode,
    required super.soundEnabled,
    required super.musicEnabled,
    required super.volume,
    required super.difficultyLevel,
    required super.showTutorial,
    required super.analyticsEnabled,
    required super.isFirstRun,
    required super.configVersion,
    required super.lastUpdated,
  });

  /// Create AppConfigModel from domain AppConfig entity
  factory AppConfigModel.fromEntity(AppConfig config) {
    return AppConfigModel(
      languageCode: config.languageCode,
      themeMode: config.themeMode,
      soundEnabled: config.soundEnabled,
      musicEnabled: config.musicEnabled,
      volume: config.volume,
      difficultyLevel: config.difficultyLevel,
      showTutorial: config.showTutorial,
      analyticsEnabled: config.analyticsEnabled,
      isFirstRun: config.isFirstRun,
      configVersion: config.configVersion,
      lastUpdated: config.lastUpdated,
    );
  }

  /// Create AppConfigModel from JSON map
  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    return AppConfigModel(
      languageCode: json['language_code'] as String? ?? 'en',
      themeMode: json['theme_mode'] as String? ?? 'system',
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      musicEnabled: json['music_enabled'] as bool? ?? true,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.8,
      difficultyLevel: json['difficulty_level'] as String? ?? 'normal',
      showTutorial: json['show_tutorial'] as bool? ?? true,
      analyticsEnabled: json['analytics_enabled'] as bool? ?? false,
      isFirstRun: json['is_first_run'] as bool? ?? true,
      configVersion: json['config_version'] as int? ?? 1,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
    );
  }

  /// Create AppConfigModel from SQLite map
  factory AppConfigModel.fromSQLite(Map<String, dynamic> map) {
    return AppConfigModel(
      languageCode: map['language_code'] as String,
      themeMode: map['theme_mode'] as String,
      soundEnabled: (map['sound_enabled'] as int) == 1,
      musicEnabled: (map['music_enabled'] as int) == 1,
      volume: map['volume'] as double,
      difficultyLevel: map['difficulty_level'] as String,
      showTutorial: (map['show_tutorial'] as int) == 1,
      analyticsEnabled: (map['analytics_enabled'] as int) == 1,
      isFirstRun: (map['is_first_run'] as int) == 1,
      configVersion: map['config_version'] as int,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        map['last_updated'] as int,
      ),
    );
  }

  /// Convert AppConfigModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'language_code': languageCode,
      'theme_mode': themeMode,
      'sound_enabled': soundEnabled,
      'music_enabled': musicEnabled,
      'volume': volume,
      'difficulty_level': difficultyLevel,
      'show_tutorial': showTutorial,
      'analytics_enabled': analyticsEnabled,
      'is_first_run': isFirstRun,
      'config_version': configVersion,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  /// Convert AppConfigModel to SQLite map
  Map<String, dynamic> toSQLite() {
    return {
      'language_code': languageCode,
      'theme_mode': themeMode,
      'sound_enabled': soundEnabled ? 1 : 0,
      'music_enabled': musicEnabled ? 1 : 0,
      'volume': volume,
      'difficulty_level': difficultyLevel,
      'show_tutorial': showTutorial ? 1 : 0,
      'analytics_enabled': analyticsEnabled ? 1 : 0,
      'is_first_run': isFirstRun ? 1 : 0,
      'config_version': configVersion,
      'last_updated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  /// Convert to domain AppConfig entity
  AppConfig toEntity() {
    return AppConfig(
      languageCode: languageCode,
      themeMode: themeMode,
      soundEnabled: soundEnabled,
      musicEnabled: musicEnabled,
      volume: volume,
      difficultyLevel: difficultyLevel,
      showTutorial: showTutorial,
      analyticsEnabled: analyticsEnabled,
      isFirstRun: isFirstRun,
      configVersion: configVersion,
      lastUpdated: lastUpdated,
    );
  }

  /// Create copy with modified properties
  @override
  AppConfigModel copyWith({
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
    return AppConfigModel(
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

  /// Default configuration model
  static AppConfigModel get defaultModel => AppConfigModel(
    languageCode: 'en',
    themeMode: 'system',
    soundEnabled: true,
    musicEnabled: true,
    volume: 0.8,
    difficultyLevel: 'normal',
    showTutorial: true,
    analyticsEnabled: false,
    isFirstRun: true,
    configVersion: 1,
    lastUpdated: DateTime.now(),
  );

  /// Validate model data
  bool get isValidModel {
    return isValid && // Use parent validation
        languageCode.isNotEmpty &&
        themeMode.isNotEmpty &&
        difficultyLevel.isNotEmpty &&
        volume >= 0.0 &&
        volume <= 1.0 &&
        configVersion > 0;
  }

  /// Get model statistics for debugging
  Map<String, dynamic> get modelStats {
    return {
      'model_type': 'AppConfigModel',
      'is_valid': isValidModel,
      'data_size': toJson().toString().length,
      'sqlite_fields': toSQLite().length,
      'last_updated_ago': DateTime.now().difference(lastUpdated).inMinutes,
    };
  }

  /// SQLite table creation SQL
  static const String createTableSQL = '''
    CREATE TABLE IF NOT EXISTS app_config (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      language_code TEXT NOT NULL,
      theme_mode TEXT NOT NULL,
      sound_enabled INTEGER NOT NULL,
      music_enabled INTEGER NOT NULL,
      volume REAL NOT NULL,
      difficulty_level TEXT NOT NULL,
      show_tutorial INTEGER NOT NULL,
      analytics_enabled INTEGER NOT NULL,
      is_first_run INTEGER NOT NULL,
      config_version INTEGER NOT NULL,
      last_updated INTEGER NOT NULL,
      created_at INTEGER DEFAULT (strftime('%s', 'now') * 1000),
      UNIQUE(id)
    );
  ''';

  /// SQLite insert SQL
  static const String insertSQL = '''
    INSERT OR REPLACE INTO app_config (
      id,
      language_code,
      theme_mode,
      sound_enabled,
      music_enabled,
      volume,
      difficulty_level,
      show_tutorial,
      analytics_enabled,
      is_first_run,
      config_version,
      last_updated
    ) VALUES (
      1,
      ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
    );
  ''';

  /// SQLite select SQL
  static const String selectSQL = '''
    SELECT 
      language_code,
      theme_mode,
      sound_enabled,
      music_enabled,
      volume,
      difficulty_level,
      show_tutorial,
      analytics_enabled,
      is_first_run,
      config_version,
      last_updated
    FROM app_config 
    WHERE id = 1 
    LIMIT 1;
  ''';

  /// Get values for SQLite insertion
  List<dynamic> getSQLiteInsertValues() {
    return [
      languageCode,
      themeMode,
      soundEnabled ? 1 : 0,
      musicEnabled ? 1 : 0,
      volume,
      difficultyLevel,
      showTutorial ? 1 : 0,
      analyticsEnabled ? 1 : 0,
      isFirstRun ? 1 : 0,
      configVersion,
      lastUpdated.millisecondsSinceEpoch,
    ];
  }

  @override
  String toString() =>
      'AppConfigModel(lang: $languageCode, theme: $themeMode, '
      'version: $configVersion, updated: ${lastUpdated.toIso8601String()})';
}
