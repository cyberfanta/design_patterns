/// Configuration Repository Contract - Clean Architecture Domain Layer
///
/// PATTERN: Repository - Abstract interface for configuration data access
/// WHERE: Domain layer defining contracts for configuration persistence
/// HOW: Abstract class with async methods for CRUD operations
/// WHY: Decouples business logic from data sources, enables testing
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/features/configuration/domain/entities/app_config.dart';
import 'package:fpdart/fpdart.dart';

/// Abstract repository for managing application configuration
///
/// This contract defines how the domain layer interacts with configuration
/// data sources, supporting the Tower Defense app's settings persistence
/// with SQLite storage and configuration management.
abstract class ConfigRepository {
  /// Load current configuration from persistent storage
  ///
  /// Returns [AppConfig] with current settings or [Failure] if loading fails.
  /// If no configuration exists, returns default configuration.
  Future<Either<Failure, AppConfig>> loadConfig();

  /// Save configuration to persistent storage
  ///
  /// Persists the provided configuration settings to local storage.
  /// Updates lastUpdated timestamp automatically.
  Future<Either<Failure, void>> saveConfig(AppConfig config);

  /// Reset configuration to default values
  ///
  /// Clears all custom settings and restores app to initial state.
  /// Useful for troubleshooting or user preference reset.
  Future<Either<Failure, AppConfig>> resetConfig();

  /// Check if configuration exists in storage
  ///
  /// Returns true if configuration has been previously saved,
  /// false if this is a fresh installation or after reset.
  Future<Either<Failure, bool>> hasConfig();

  /// Get configuration version for migration purposes
  ///
  /// Returns the stored configuration version to determine
  /// if data migration is needed.
  Future<Either<Failure, int>> getConfigVersion();

  /// Update specific configuration value
  ///
  /// Allows partial updates without loading/saving entire config.
  /// Useful for single setting changes like language or volume.
  Future<Either<Failure, void>> updateConfigValue(String key, dynamic value);

  /// Get specific configuration value
  ///
  /// Retrieves a single configuration value without loading entire config.
  /// Returns default value if key doesn't exist.
  Future<Either<Failure, T>> getConfigValue<T>(String key, T defaultValue);

  /// Export configuration for backup/sharing
  ///
  /// Returns configuration as JSON map for external storage or transfer.
  /// Excludes sensitive data like analytics preferences.
  Future<Either<Failure, Map<String, dynamic>>> exportConfig();

  /// Import configuration from backup
  ///
  /// Restores configuration from previously exported JSON data.
  /// Validates data integrity before applying changes.
  Future<Either<Failure, void>> importConfig(Map<String, dynamic> configData);

  /// Clear all configuration data
  ///
  /// Removes all stored configuration from persistent storage.
  /// Different from reset - this removes the data entirely.
  Future<Either<Failure, void>> clearConfig();

  /// Migrate configuration to newer version
  ///
  /// Handles configuration data migration between app versions.
  /// Ensures backward compatibility and data preservation.
  Future<Either<Failure, AppConfig>> migrateConfig(
    AppConfig oldConfig,
    int targetVersion,
  );

  /// Get storage statistics
  ///
  /// Returns information about configuration storage usage,
  /// last update times, and storage health.
  Future<Either<Failure, Map<String, dynamic>>> getStorageInfo();
}
