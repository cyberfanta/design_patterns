/// App Configuration Entity Tests
library;

import 'package:design_patterns/features/configuration/domain/entities/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig Entity Tests', () {
    test('should create default configuration', () {
      // Act
      final config = AppConfig.defaultConfig;

      // Assert
      expect(config.languageCode, 'en');
      expect(config.themeMode, 'system');
      expect(config.soundEnabled, true);
      expect(config.musicEnabled, true);
      expect(config.volume, 0.8);
      expect(config.difficultyLevel, 'normal');
      expect(config.showTutorial, true);
      expect(config.analyticsEnabled, false);
      expect(config.isFirstRun, true);
      expect(config.configVersion, 1);
    });

    test('should validate correct configuration', () {
      // Arrange
      final config = AppConfig(
        languageCode: 'es',
        themeMode: 'dark',
        difficultyLevel: 'hard',
        volume: 0.5,
      );

      // Assert
      expect(config.isValid, true);
    });

    test('should invalidate configuration with wrong language', () {
      // Arrange
      final config = AppConfig(languageCode: 'invalid');

      // Assert
      expect(config.isValid, false);
    });

    test('should create copy with modified properties', () {
      // Arrange
      final original = AppConfig.defaultConfig;

      // Act
      final modified = original.copyWith(languageCode: 'es', volume: 0.5);

      // Assert
      expect(modified.languageCode, 'es');
      expect(modified.volume, 0.5);
      expect(modified.themeMode, original.themeMode); // Unchanged
    });

    test('should create configuration with difficulty', () {
      // Arrange
      final config = AppConfig.defaultConfig;

      // Act
      final hardConfig = config.withDifficulty('hard');

      // Assert
      expect(hardConfig.difficultyLevel, 'hard');
      expect(hardConfig.languageCode, config.languageCode); // Unchanged
    });

    test('should create configuration with audio settings', () {
      // Arrange
      final config = AppConfig.defaultConfig;

      // Act
      final audioConfig = config.withAudioSettings(
        soundEnabled: false,
        volume: 0.3,
      );

      // Assert
      expect(audioConfig.soundEnabled, false);
      expect(audioConfig.volume, 0.3);
      expect(audioConfig.musicEnabled, config.musicEnabled); // Unchanged
    });
  });
}
