/// App Configuration Model Tests
import 'package:design_patterns/features/configuration/data/models/app_config_model.dart';
import 'package:design_patterns/features/configuration/domain/entities/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfigModel Tests', () {
    test('should create model from entity', () {
      // Arrange
      final entity = AppConfig.defaultConfig;

      // Act
      final model = AppConfigModel.fromEntity(entity);

      // Assert
      expect(model.languageCode, entity.languageCode);
      expect(model.themeMode, entity.themeMode);
      expect(model.soundEnabled, entity.soundEnabled);
      expect(model.volume, entity.volume);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final model = AppConfigModel.defaultModel;

      // Act
      final json = model.toJson();

      // Assert
      expect(json['language_code'], 'en');
      expect(json['theme_mode'], 'system');
      expect(json['sound_enabled'], true);
      expect(json['volume'], 0.8);
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'language_code': 'es',
        'theme_mode': 'dark',
        'sound_enabled': false,
        'volume': 0.6,
        'difficulty_level': 'hard',
      };

      // Act
      final model = AppConfigModel.fromJson(json);

      // Assert
      expect(model.languageCode, 'es');
      expect(model.themeMode, 'dark');
      expect(model.soundEnabled, false);
      expect(model.volume, 0.6);
      expect(model.difficultyLevel, 'hard');
    });

    test('should convert to SQLite map correctly', () {
      // Arrange
      final model = AppConfigModel(
        languageCode: 'fr',
        themeMode: 'light',
        soundEnabled: true,
        musicEnabled: false,
        volume: 0.7,
        difficultyLevel: 'easy',
        showTutorial: false,
        analyticsEnabled: true,
        isFirstRun: false,
        configVersion: 1,
        lastUpdated: DateTime(2024, 1, 1),
      );

      // Act
      final sqliteMap = model.toSQLite();

      // Assert
      expect(sqliteMap['language_code'], 'fr');
      expect(sqliteMap['theme_mode'], 'light');
      expect(sqliteMap['sound_enabled'], 1);
      expect(sqliteMap['music_enabled'], 0);
      expect(sqliteMap['volume'], 0.7);
      expect(sqliteMap['show_tutorial'], 0);
      expect(sqliteMap['analytics_enabled'], 1);
      expect(sqliteMap['is_first_run'], 0);
    });

    test('should create from SQLite map correctly', () {
      // Arrange
      final sqliteMap = {
        'language_code': 'de',
        'theme_mode': 'dark',
        'sound_enabled': 1,
        'music_enabled': 0,
        'volume': 0.9,
        'difficulty_level': 'expert',
        'show_tutorial': 1,
        'analytics_enabled': 0,
        'is_first_run': 1,
        'config_version': 1,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      };

      // Act
      final model = AppConfigModel.fromSQLite(sqliteMap);

      // Assert
      expect(model.languageCode, 'de');
      expect(model.themeMode, 'dark');
      expect(model.soundEnabled, true);
      expect(model.musicEnabled, false);
      expect(model.volume, 0.9);
      expect(model.difficultyLevel, 'expert');
      expect(model.showTutorial, true);
      expect(model.analyticsEnabled, false);
      expect(model.isFirstRun, true);
    });

    test('should convert to entity correctly', () {
      // Arrange
      final model = AppConfigModel.defaultModel;

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.languageCode, model.languageCode);
      expect(entity.themeMode, model.themeMode);
      expect(entity.soundEnabled, model.soundEnabled);
      expect(entity.volume, model.volume);
    });

    test('should validate model correctly', () {
      // Arrange
      final validModel = AppConfigModel.defaultModel;
      final invalidModel = AppConfigModel(
        languageCode: '',
        themeMode: 'system',
        soundEnabled: true,
        musicEnabled: true,
        volume: 2.0,
        // Invalid volume
        difficultyLevel: 'normal',
        showTutorial: true,
        analyticsEnabled: false,
        isFirstRun: true,
        configVersion: -1,
        // Invalid version
        lastUpdated: DateTime.now(),
      );

      // Assert
      expect(validModel.isValidModel, true);
      expect(invalidModel.isValidModel, false);
    });
  });
}
