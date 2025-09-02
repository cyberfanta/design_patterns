/// Get Configuration Use Case - Clean Architecture Domain Layer
///
/// PATTERN: Command - Encapsulates configuration retrieval operation
/// WHERE: Domain layer use cases for configuration management
/// HOW: Single responsibility class with validation and defaults
/// WHY: Separates configuration loading logic from UI and data layers
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/configuration/domain/entities/app_config.dart';
import 'package:design_patterns/features/configuration/domain/repositories/config_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for loading application configuration
///
/// In the Tower Defense context, this loads all game and app settings
/// including language preferences, difficulty settings, audio preferences,
/// and other customizations made by the player.
class GetConfig {
  final ConfigRepository _repository;

  const GetConfig(this._repository);

  /// Execute configuration loading operation
  ///
  /// Returns current configuration or default configuration if none exists.
  /// Handles migration if configuration version is outdated.
  /// Parameters:
  /// - [forceRefresh]: Whether to bypass cache and reload from storage
  Future<Either<Failure, AppConfig>> execute({
    bool forceRefresh = false,
  }) async {
    try {
      Log.debug('Loading application configuration...');

      // Check if configuration exists in storage
      final hasConfigResult = await _repository.hasConfig();

      return hasConfigResult.fold(
        (failure) async {
          Log.warning(
            'Could not check config existence: ${failure.toString()}',
          );
          // Return default config if can't check existence
          final defaultConfig = AppConfig.defaultConfig;
          Log.info('Using default configuration due to storage check failure');
          return Right(defaultConfig);
        },
        (hasConfig) async {
          if (!hasConfig) {
            Log.info('No configuration found, using default values');
            final defaultConfig = AppConfig.defaultConfig;

            // Save default config for future use
            await _repository.saveConfig(defaultConfig);
            Log.success('Default configuration saved to storage');

            return Right(defaultConfig);
          }

          return await _loadAndValidateConfig();
        },
      );
    } catch (e) {
      Log.error('Unexpected error loading configuration: $e');
      return Left(
        ServerFailure(message: 'Failed to load configuration: ${e.toString()}'),
      );
    }
  }

  /// Load existing configuration and validate
  Future<Either<Failure, AppConfig>> _loadAndValidateConfig() async {
    try {
      Log.debug('Loading existing configuration from storage');

      final configResult = await _repository.loadConfig();

      return configResult.fold(
        (failure) async {
          Log.error('Failed to load config: ${failure.toString()}');

          // If loading fails, try to use default config
          Log.debug('Attempting to use default configuration as fallback');
          final defaultConfig = AppConfig.defaultConfig;

          // Try to save default config
          final saveResult = await _repository.saveConfig(defaultConfig);
          saveResult.fold(
            (saveFailure) => Log.warning(
              'Could not save default config: ${saveFailure.toString()}',
            ),
            (_) => Log.success('Default configuration saved as fallback'),
          );

          return Right(defaultConfig);
        },
        (config) async {
          Log.success('Configuration loaded successfully');

          // Validate loaded configuration
          if (!config.isValid) {
            Log.warning('Loaded configuration is invalid, using default');
            final defaultConfig = AppConfig.defaultConfig;
            await _repository.saveConfig(defaultConfig);
            return Right(defaultConfig);
          }

          // Check if migration is needed
          if (config.needsMigration) {
            Log.info('Configuration needs migration');
            return await _migrateConfiguration(config);
          }

          Log.debug('Configuration validation successful');
          return Right(config);
        },
      );
    } catch (e) {
      Log.error('Error in load and validate: $e');
      return Left(
        ServerFailure(
          message: 'Configuration validation failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Migrate configuration to current version
  Future<Either<Failure, AppConfig>> _migrateConfiguration(
    AppConfig oldConfig,
  ) async {
    try {
      Log.debug(
        'Migrating configuration from version ${oldConfig.configVersion}',
      );

      const targetVersion = 1; // Current version
      final migrationResult = await _repository.migrateConfig(
        oldConfig,
        targetVersion,
      );

      return migrationResult.fold(
        (failure) {
          Log.error('Configuration migration failed: ${failure.toString()}');

          // If migration fails, use default config
          final defaultConfig = AppConfig.defaultConfig;
          Log.warning('Using default configuration due to migration failure');

          return Right(defaultConfig);
        },
        (migratedConfig) {
          Log.success('Configuration migrated to version $targetVersion');
          return Right(migratedConfig);
        },
      );
    } catch (e) {
      Log.error('Error during configuration migration: $e');
      return Left(
        ServerFailure(
          message: 'Configuration migration error: ${e.toString()}',
        ),
      );
    }
  }

  /// Get specific configuration value
  Future<Either<Failure, T>> getConfigValue<T>(
    String key,
    T defaultValue,
  ) async {
    try {
      Log.debug('Getting configuration value for key: $key');

      return await _repository.getConfigValue<T>(key, defaultValue);
    } catch (e) {
      Log.error('Error getting config value for $key: $e');
      return Left(
        ServerFailure(message: 'Failed to get config value: ${e.toString()}'),
      );
    }
  }

  /// Get storage information for debugging
  Future<Either<Failure, Map<String, dynamic>>> getStorageInfo() async {
    try {
      Log.debug('Getting configuration storage information');

      return await _repository.getStorageInfo();
    } catch (e) {
      Log.error('Error getting storage info: $e');
      return Left(
        ServerFailure(message: 'Failed to get storage info: ${e.toString()}'),
      );
    }
  }
}
