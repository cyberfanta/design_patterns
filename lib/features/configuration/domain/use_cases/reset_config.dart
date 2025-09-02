/// Reset Configuration Use Case - Clean Architecture Domain Layer
///
/// PATTERN: Command - Encapsulates configuration reset operation
/// WHERE: Domain layer use cases for configuration management
/// HOW: Single responsibility class with backup and restore capabilities
/// WHY: Provides safe way to reset configuration with recovery options
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/configuration/domain/entities/app_config.dart';
import 'package:design_patterns/features/configuration/domain/repositories/config_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for resetting application configuration to defaults
///
/// In the Tower Defense context, this allows players to reset all
/// customizations back to original settings, useful for troubleshooting
/// or starting fresh with default game configurations.
class ResetConfig {
  final ConfigRepository _repository;

  const ResetConfig(this._repository);

  /// Execute configuration reset operation
  ///
  /// Creates backup of current config, then resets to defaults.
  /// Parameters:
  /// - [createBackup]: Whether to backup current config before reset
  /// - [preserveLanguage]: Whether to keep current language setting
  Future<Either<Failure, AppConfig>> execute({
    bool createBackup = true,
    bool preserveLanguage = false,
  }) async {
    try {
      Log.debug('Resetting application configuration to defaults...');

      AppConfig? currentConfig;

      // Create backup if requested
      if (createBackup) {
        final backupResult = await _createConfigBackup();
        backupResult.fold(
          (failure) =>
              Log.warning('Could not create backup: ${failure.toString()}'),
          (_) => Log.success('Configuration backup created successfully'),
        );

        // Get current config for language preservation if needed
        if (preserveLanguage) {
          final configResult = await _repository.loadConfig();
          configResult.fold(
            (failure) => Log.warning(
              'Could not load current config for language preservation',
            ),
            (config) {
              currentConfig = config;
              Log.debug('Current language preserved: ${config.languageCode}');
            },
          );
        }
      }

      // Reset configuration in repository
      final resetResult = await _repository.resetConfig();

      return resetResult.fold(
        (failure) {
          Log.error('Failed to reset configuration: ${failure.toString()}');
          return Left(failure);
        },
        (defaultConfig) {
          Log.success('Configuration reset to defaults successfully');

          // Preserve language if requested and available
          if (preserveLanguage && currentConfig != null) {
            final configWithLanguage = defaultConfig.withLanguage(
              currentConfig!.languageCode,
            );

            // Save the config with preserved language
            _repository.saveConfig(configWithLanguage).then((saveConfigResult) {
              saveConfigResult.fold(
                (failure) => Log.warning(
                  'Could not save config with preserved language',
                ),
                (_) => Log.debug('Language preference preserved in reset'),
              );
            });

            return Right(configWithLanguage);
          }

          return Right(defaultConfig);
        },
      );
    } catch (e) {
      Log.error('Unexpected error resetting configuration: $e');
      return Left(
        ServerFailure(
          message: 'Failed to reset configuration: ${e.toString()}',
        ),
      );
    }
  }

  /// Clear all configuration data completely
  ///
  /// More aggressive than reset - removes all stored configuration.
  /// Use with caution as this cannot be undone easily.
  Future<Either<Failure, void>> clearAllConfig() async {
    try {
      Log.warning('Clearing ALL configuration data...');

      // Create emergency backup
      final backupResult = await _createConfigBackup();
      backupResult.fold(
        (failure) => Log.error(
          'Could not create emergency backup: ${failure.toString()}',
        ),
        (_) => Log.info('Emergency backup created before clear'),
      );

      // Clear all configuration data
      final clearResult = await _repository.clearConfig();

      return clearResult.fold(
        (failure) {
          Log.error('Failed to clear configuration: ${failure.toString()}');
          return Left(failure);
        },
        (_) {
          Log.warning('All configuration data cleared successfully');
          return const Right(null);
        },
      );
    } catch (e) {
      Log.error('Error clearing configuration: $e');
      return Left(
        ServerFailure(
          message: 'Failed to clear configuration: ${e.toString()}',
        ),
      );
    }
  }

  /// Reset specific configuration section
  ///
  /// Allows partial reset of configuration categories.
  Future<Either<Failure, AppConfig>> resetConfigSection(String section) async {
    try {
      Log.debug('Resetting configuration section: $section');

      // Load current configuration
      final configResult = await _repository.loadConfig();

      return configResult.fold(
        (failure) {
          Log.error('Could not load current config for section reset');
          return Left(failure);
        },
        (currentConfig) async {
          final defaultConfig = AppConfig.defaultConfig;
          AppConfig updatedConfig;

          // Reset specific section based on parameter
          switch (section.toLowerCase()) {
            case 'audio':
              updatedConfig = currentConfig.withAudioSettings(
                soundEnabled: defaultConfig.soundEnabled,
                musicEnabled: defaultConfig.musicEnabled,
                volume: defaultConfig.volume,
              );
              break;

            case 'game':
              updatedConfig = currentConfig.copyWith(
                difficultyLevel: defaultConfig.difficultyLevel,
                showTutorial: defaultConfig.showTutorial,
              );
              break;

            case 'appearance':
              updatedConfig = currentConfig.copyWith(
                themeMode: defaultConfig.themeMode,
              );
              break;

            case 'privacy':
              updatedConfig = currentConfig.copyWith(
                analyticsEnabled: defaultConfig.analyticsEnabled,
              );
              break;

            default:
              Log.error('Unknown configuration section: $section');
              return Left(
                ValidationFailure(
                  message: 'Unknown configuration section: $section',
                ),
              );
          }

          // Save updated configuration
          final saveResult = await _repository.saveConfig(updatedConfig);

          return saveResult.fold(
            (failure) {
              Log.error('Failed to save section reset: ${failure.toString()}');
              return Left(failure);
            },
            (_) {
              Log.success('Configuration section $section reset successfully');
              return Right(updatedConfig);
            },
          );
        },
      );
    } catch (e) {
      Log.error('Error resetting configuration section: $e');
      return Left(
        ServerFailure(message: 'Failed to reset section: ${e.toString()}'),
      );
    }
  }

  /// Create backup of current configuration
  Future<Either<Failure, Map<String, dynamic>>> _createConfigBackup() async {
    try {
      Log.debug('Creating configuration backup before reset');

      return await _repository.exportConfig();
    } catch (e) {
      Log.error('Error creating configuration backup: $e');
      return Left(
        ServerFailure(message: 'Failed to create backup: ${e.toString()}'),
      );
    }
  }

  /// Get available configuration sections for partial reset
  List<String> getAvailableSections() {
    return ['audio', 'game', 'appearance', 'privacy'];
  }

  /// Validate reset parameters
  bool isValidSection(String section) {
    return getAvailableSections().contains(section.toLowerCase());
  }
}
