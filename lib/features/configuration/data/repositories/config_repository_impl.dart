/// Configuration Repository Implementation - Clean Architecture Data Layer
///
/// PATTERN: Repository - Concrete implementation of configuration data access
/// WHERE: Data layer implementing domain repository contract
/// HOW: Coordinates between datasources and converts models to entities
/// WHY: Centralizes configuration data access logic and maintains clean boundaries
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/configuration/data/datasources/local_config_datasource.dart';
import 'package:design_patterns/features/configuration/data/models/app_config_model.dart';
import 'package:design_patterns/features/configuration/domain/entities/app_config.dart';
import 'package:design_patterns/features/configuration/domain/repositories/config_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Concrete implementation of ConfigRepository
///
/// PATTERN: Repository - Implements domain repository interface
/// Coordinates between local datasource and domain layer,
/// providing configuration persistence for the Tower Defense app.
class ConfigRepositoryImpl implements ConfigRepository {
  final LocalConfigDataSource _localDataSource;

  const ConfigRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, AppConfig>> loadConfig() async {
    try {
      Log.debug('Repository: Loading application configuration');

      final configModel = await _localDataSource.loadConfig();

      if (configModel == null) {
        Log.info('No configuration found, returning default');
        final defaultConfig = AppConfig.defaultConfig;

        // Save default config for future use
        final defaultModel = AppConfigModel.fromEntity(defaultConfig);
        await _localDataSource.saveConfig(defaultModel);

        return Right(defaultConfig);
      }

      if (!configModel.isValidModel) {
        Log.error('Invalid configuration data loaded');
        return Left(
          ValidationFailure(message: 'Invalid configuration data in storage'),
        );
      }

      final config = configModel.toEntity();
      Log.success('Repository: Configuration loaded successfully');

      return Right(config);
    } catch (e) {
      Log.error('Repository: Error loading configuration: $e');
      return Left(
        ServerFailure(message: 'Failed to load configuration: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveConfig(AppConfig config) async {
    try {
      Log.debug('Repository: Saving configuration');

      if (!config.isValid) {
        Log.error('Invalid configuration provided for save');
        return Left(
          ValidationFailure(message: 'Configuration validation failed'),
        );
      }

      final configModel = AppConfigModel.fromEntity(config);
      await _localDataSource.saveConfig(configModel);

      Log.success('Repository: Configuration saved successfully');
      return const Right(null);
    } catch (e) {
      Log.error('Repository: Error saving configuration: $e');
      return Left(
        ServerFailure(message: 'Failed to save configuration: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, AppConfig>> resetConfig() async {
    try {
      Log.debug('Repository: Resetting configuration to defaults');

      await _localDataSource.resetToDefaults();

      // Return the default configuration
      final defaultConfig = AppConfig.defaultConfig;

      Log.success('Repository: Configuration reset to defaults');
      return Right(defaultConfig);
    } catch (e) {
      Log.error('Repository: Error resetting configuration: $e');
      return Left(
        ServerFailure(
          message: 'Failed to reset configuration: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> hasConfig() async {
    try {
      Log.debug('Repository: Checking configuration existence');

      final hasConfig = await _localDataSource.hasConfig();

      Log.debug('Repository: Configuration exists: $hasConfig');
      return Right(hasConfig);
    } catch (e) {
      Log.error('Repository: Error checking configuration existence: $e');
      return Left(
        ServerFailure(
          message: 'Failed to check configuration existence: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getConfigVersion() async {
    try {
      Log.debug('Repository: Getting configuration version');

      final version = await _localDataSource.getConfigVersion();

      Log.debug('Repository: Configuration version: $version');
      return Right(version);
    } catch (e) {
      Log.error('Repository: Error getting configuration version: $e');
      return Left(
        ServerFailure(
          message: 'Failed to get configuration version: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateConfigValue(
    String key,
    dynamic value,
  ) async {
    try {
      Log.debug('Repository: Updating configuration value: $key');

      if (key.isEmpty) {
        return Left(
          ValidationFailure(message: 'Configuration key cannot be empty'),
        );
      }

      await _localDataSource.updateConfigValue(key, value);

      Log.success('Repository: Configuration value updated: $key');
      return const Right(null);
    } catch (e) {
      Log.error('Repository: Error updating configuration value: $e');
      return Left(
        ServerFailure(
          message: 'Failed to update configuration value: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, T>> getConfigValue<T>(
    String key,
    T defaultValue,
  ) async {
    try {
      Log.debug('Repository: Getting configuration value: $key');

      final value = await _localDataSource.getConfigValue<T>(key);
      final result = value ?? defaultValue;

      Log.debug('Repository: Configuration value retrieved: $key = $result');
      return Right(result);
    } catch (e) {
      Log.error('Repository: Error getting configuration value: $e');
      return Left(
        ServerFailure(
          message: 'Failed to get configuration value: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportConfig() async {
    try {
      Log.debug('Repository: Exporting configuration');

      final exportData = await _localDataSource.exportConfig();

      if (exportData == null) {
        return Left(
          NotFoundFailure(message: 'No configuration available for export'),
        );
      }

      Log.success('Repository: Configuration exported successfully');
      return Right(exportData);
    } catch (e) {
      Log.error('Repository: Error exporting configuration: $e');
      return Left(
        ServerFailure(
          message: 'Failed to export configuration: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> importConfig(
    Map<String, dynamic> configData,
  ) async {
    try {
      Log.debug('Repository: Importing configuration');

      if (configData.isEmpty) {
        return Left(
          ValidationFailure(message: 'Configuration data cannot be empty'),
        );
      }

      // Validate configuration data before import
      try {
        final configModel = AppConfigModel.fromJson(configData);
        if (!configModel.isValidModel) {
          return Left(
            ValidationFailure(message: 'Invalid configuration data for import'),
          );
        }
      } catch (e) {
        return Left(
          ValidationFailure(
            message: 'Configuration data format is invalid: ${e.toString()}',
          ),
        );
      }

      await _localDataSource.importConfig(configData);

      Log.success('Repository: Configuration imported successfully');
      return const Right(null);
    } catch (e) {
      Log.error('Repository: Error importing configuration: $e');
      return Left(
        ServerFailure(
          message: 'Failed to import configuration: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearConfig() async {
    try {
      Log.debug('Repository: Clearing all configuration data');

      await _localDataSource.clearConfig();

      Log.warning('Repository: All configuration data cleared');
      return const Right(null);
    } catch (e) {
      Log.error('Repository: Error clearing configuration: $e');
      return Left(
        ServerFailure(
          message: 'Failed to clear configuration: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AppConfig>> migrateConfig(
    AppConfig oldConfig,
    int targetVersion,
  ) async {
    try {
      Log.debug(
        'Repository: Migrating configuration from version ${oldConfig.configVersion} to $targetVersion',
      );

      if (oldConfig.configVersion >= targetVersion) {
        Log.debug('Configuration already at target version or newer');
        return Right(oldConfig);
      }

      AppConfig migratedConfig = oldConfig;

      // Perform version-specific migrations
      if (oldConfig.configVersion < 1) {
        // Migration to version 1 - no changes needed for now
        migratedConfig = oldConfig.copyWith(
          configVersion: 1,
          lastUpdated: DateTime.now(),
        );
        Log.debug('Migrated configuration to version 1');
      }

      // Future migrations would go here
      if (migratedConfig.configVersion < targetVersion) {
        // Add more migration steps as needed
        migratedConfig = migratedConfig.copyWith(
          configVersion: targetVersion,
          lastUpdated: DateTime.now(),
        );
      }

      // Save migrated configuration
      final saveResult = await saveConfig(migratedConfig);

      return saveResult.fold(
        (failure) {
          Log.error('Failed to save migrated configuration');
          return Left(failure);
        },
        (_) {
          Log.success(
            'Configuration migrated successfully to version $targetVersion',
          );
          return Right(migratedConfig);
        },
      );
    } catch (e) {
      Log.error('Repository: Error migrating configuration: $e');
      return Left(
        ServerFailure(
          message: 'Configuration migration failed: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStorageInfo() async {
    try {
      Log.debug('Repository: Getting storage information');

      final storageStats = await _localDataSource.getStorageStats();

      // Add repository-level information
      final info = {
        ...storageStats,
        'repository_type': 'ConfigRepositoryImpl',
        'domain_layer_version': 1,
        'last_accessed': DateTime.now().toIso8601String(),
      };

      Log.debug('Repository: Storage information retrieved');
      return Right(info);
    } catch (e) {
      Log.error('Repository: Error getting storage information: $e');
      return Left(
        ServerFailure(
          message: 'Failed to get storage information: ${e.toString()}',
        ),
      );
    }
  }

  /// Additional repository methods for advanced configuration management

  /// Backup current configuration
  Future<Either<Failure, String>> backupConfig() async {
    try {
      Log.debug('Repository: Creating configuration backup');

      final backupId = await _localDataSource.backupConfig();

      if (backupId == null) {
        return Left(
          ServerFailure(message: 'Failed to create configuration backup'),
        );
      }

      Log.success('Repository: Configuration backup created: $backupId');
      return Right(backupId);
    } catch (e) {
      Log.error('Repository: Error creating backup: $e');
      return Left(
        ServerFailure(message: 'Backup creation failed: ${e.toString()}'),
      );
    }
  }

  /// Restore configuration from backup
  Future<Either<Failure, void>> restoreFromBackup(String backupId) async {
    try {
      Log.debug('Repository: Restoring configuration from backup: $backupId');

      await _localDataSource.restoreFromBackup(backupId);

      Log.success('Repository: Configuration restored from backup');
      return const Right(null);
    } catch (e) {
      Log.error('Repository: Error restoring from backup: $e');
      return Left(
        ServerFailure(message: 'Backup restoration failed: ${e.toString()}'),
      );
    }
  }

  /// Optimize storage for better performance
  Future<Either<Failure, void>> optimizeStorage() async {
    try {
      Log.debug('Repository: Optimizing storage');

      await _localDataSource.optimizeStorage();

      Log.success('Repository: Storage optimization completed');
      return const Right(null);
    } catch (e) {
      Log.error('Repository: Error optimizing storage: $e');
      return Left(
        ServerFailure(message: 'Storage optimization failed: ${e.toString()}'),
      );
    }
  }

  /// Check storage health and integrity
  Future<Either<Failure, bool>> checkStorageHealth() async {
    try {
      Log.debug('Repository: Checking storage health');

      final isHealthy = await _localDataSource.checkStorageHealth();

      Log.debug(
        'Repository: Storage health status: ${isHealthy ? 'OK' : 'FAILED'}',
      );
      return Right(isHealthy);
    } catch (e) {
      Log.error('Repository: Error checking storage health: $e');
      return Left(
        ServerFailure(message: 'Storage health check failed: ${e.toString()}'),
      );
    }
  }
}
