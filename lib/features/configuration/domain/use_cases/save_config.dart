/// Save Configuration Use Case - Clean Architecture Domain Layer
///
/// PATTERN: Command - Encapsulates configuration save operation
/// WHERE: Domain layer use cases for configuration persistence
/// HOW: Single responsibility class with validation and error handling
/// WHY: Centralizes configuration saving logic with business rule validation
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/configuration/domain/entities/app_config.dart';
import 'package:design_patterns/features/configuration/domain/repositories/config_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for saving application configuration
///
/// In the Tower Defense context, this persists all game and app settings
/// including language changes, difficulty adjustments, audio preferences,
/// and other customizations made by the player during gameplay.
class SaveConfig {
  final ConfigRepository _repository;

  const SaveConfig(this._repository);

  /// Execute configuration saving operation
  ///
  /// Validates configuration before saving and updates timestamp.
  /// Parameters:
  /// - [config]: The configuration to save
  /// - [validateBefore]: Whether to validate config before saving
  Future<Either<Failure, void>> execute(
    AppConfig config, {
    bool validateBefore = true,
  }) async {
    try {
      Log.debug('Saving application configuration...');

      // Validate configuration if requested
      if (validateBefore) {
        final validationResult = _validateConfiguration(config);
        if (validationResult.isLeft()) {
          return validationResult;
        }
      }

      // Update last updated timestamp
      final configToSave = config.copyWith(lastUpdated: DateTime.now());

      // Log configuration changes for debugging
      _logConfigurationChanges(configToSave);

      // Save to repository
      final saveResult = await _repository.saveConfig(configToSave);

      return saveResult.fold(
        (failure) {
          Log.error('Failed to save configuration: ${failure.toString()}');
          return Left(failure);
        },
        (_) {
          Log.success('Configuration saved successfully');
          return const Right(null);
        },
      );
    } catch (e) {
      Log.error('Unexpected error saving configuration: $e');
      return Left(
        ServerFailure(message: 'Failed to save configuration: ${e.toString()}'),
      );
    }
  }

  /// Save specific configuration value
  ///
  /// Updates a single configuration parameter without loading entire config.
  /// Useful for individual setting changes like volume or language.
  Future<Either<Failure, void>> saveConfigValue(
    String key,
    dynamic value,
  ) async {
    try {
      Log.debug('Saving configuration value: $key = $value');

      // Validate key and value
      if (key.isEmpty) {
        return Left(
          ValidationFailure(message: 'Configuration key cannot be empty'),
        );
      }

      // Save single value
      final result = await _repository.updateConfigValue(key, value);

      return result.fold(
        (failure) {
          Log.error('Failed to save config value $key: ${failure.toString()}');
          return Left(failure);
        },
        (_) {
          Log.success('Configuration value $key saved successfully');
          return const Right(null);
        },
      );
    } catch (e) {
      Log.error('Error saving config value $key: $e');
      return Left(
        ServerFailure(message: 'Failed to save config value: ${e.toString()}'),
      );
    }
  }

  /// Validate configuration before saving
  Either<Failure, void> _validateConfiguration(AppConfig config) {
    try {
      Log.debug('Validating configuration before save');

      // Basic validation
      if (!config.isValid) {
        Log.error('Configuration validation failed: invalid values detected');
        return Left(
          ValidationFailure(message: 'Configuration contains invalid values'),
        );
      }

      // Validate language code
      if (!AppConfig.supportedLanguages.contains(config.languageCode)) {
        Log.error('Invalid language code: ${config.languageCode}');
        return Left(
          ValidationFailure(
            message: 'Unsupported language: ${config.languageCode}',
          ),
        );
      }

      // Validate theme mode
      if (!AppConfig.supportedThemeModes.contains(config.themeMode)) {
        Log.error('Invalid theme mode: ${config.themeMode}');
        return Left(
          ValidationFailure(
            message: 'Unsupported theme mode: ${config.themeMode}',
          ),
        );
      }

      // Validate difficulty level
      if (!AppConfig.supportedDifficulties.contains(config.difficultyLevel)) {
        Log.error('Invalid difficulty level: ${config.difficultyLevel}');
        return Left(
          ValidationFailure(
            message: 'Unsupported difficulty: ${config.difficultyLevel}',
          ),
        );
      }

      // Validate volume range
      if (config.volume < 0.0 || config.volume > 1.0) {
        Log.error('Invalid volume level: ${config.volume}');
        return Left(
          ValidationFailure(message: 'Volume must be between 0.0 and 1.0'),
        );
      }

      // Validate configuration version
      if (config.configVersion <= 0) {
        Log.error('Invalid config version: ${config.configVersion}');
        return Left(
          ValidationFailure(message: 'Configuration version must be positive'),
        );
      }

      Log.debug('Configuration validation successful');
      return const Right(null);
    } catch (e) {
      Log.error('Error during configuration validation: $e');
      return Left(
        ValidationFailure(
          message: 'Configuration validation error: ${e.toString()}',
        ),
      );
    }
  }

  /// Log configuration changes for debugging
  void _logConfigurationChanges(AppConfig config) {
    try {
      final debugInfo = config.debugInfo;
      Log.debug('Configuration to save:');

      for (final entry in debugInfo.entries) {
        Log.debug('  ${entry.key}: ${entry.value}');
      }
    } catch (e) {
      Log.warning('Could not log configuration changes: $e');
    }
  }

  /// Backup current configuration before major changes
  Future<Either<Failure, Map<String, dynamic>>> backupConfig() async {
    try {
      Log.debug('Creating configuration backup');

      return await _repository.exportConfig();
    } catch (e) {
      Log.error('Error creating configuration backup: $e');
      return Left(
        ServerFailure(
          message: 'Failed to backup configuration: ${e.toString()}',
        ),
      );
    }
  }

  /// Restore configuration from backup
  Future<Either<Failure, void>> restoreConfig(
    Map<String, dynamic> backupData,
  ) async {
    try {
      Log.debug('Restoring configuration from backup');

      return await _repository.importConfig(backupData);
    } catch (e) {
      Log.error('Error restoring configuration: $e');
      return Left(
        ServerFailure(
          message: 'Failed to restore configuration: ${e.toString()}',
        ),
      );
    }
  }
}
