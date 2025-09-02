/// Local Configuration Data Source - Clean Architecture Data Layer
///
/// PATTERN: Data Source - Abstract interface for local configuration data
/// WHERE: Data layer for local configuration storage and retrieval
/// HOW: Abstract class defining local data operations
/// WHY: Separates local storage implementation from business logic
library;

import 'package:design_patterns/features/configuration/data/models/app_config_model.dart';

/// Abstract data source for local configuration operations
///
/// This defines the contract for local configuration storage,
/// supporting the Tower Defense app's persistent configuration
/// functionality with SQLite database storage.
abstract class LocalConfigDataSource {
  /// Load configuration data from local storage
  ///
  /// Returns cached configuration data or null if no configuration
  /// has been previously saved to local storage.
  Future<AppConfigModel?> loadConfig();

  /// Save configuration data to local storage
  ///
  /// Persists configuration data to SQLite database for future access.
  /// Overwrites existing configuration if present.
  Future<void> saveConfig(AppConfigModel config);

  /// Check if configuration exists in local storage
  ///
  /// Returns true if configuration data has been previously saved,
  /// false if this is a fresh installation.
  Future<bool> hasConfig();

  /// Get specific configuration value from storage
  ///
  /// Retrieves a single configuration value by key without loading
  /// the entire configuration object. More efficient for single values.
  Future<T?> getConfigValue<T>(String key);

  /// Update specific configuration value in storage
  ///
  /// Updates a single configuration parameter without loading/saving
  /// the entire configuration object. Useful for individual changes.
  Future<void> updateConfigValue(String key, dynamic value);

  /// Get configuration version from storage
  ///
  /// Returns the stored configuration version for migration purposes.
  /// Returns 0 if no configuration exists.
  Future<int> getConfigVersion();

  /// Clear all configuration data from storage
  ///
  /// Removes all stored configuration from the local database.
  /// This operation cannot be undone.
  Future<void> clearConfig();

  /// Reset configuration to defaults
  ///
  /// Replaces existing configuration with default values.
  /// Preserves configuration table structure.
  Future<void> resetToDefaults();

  /// Export configuration data
  ///
  /// Returns configuration as a map for backup/export purposes.
  /// Excludes internal metadata like creation timestamps.
  Future<Map<String, dynamic>?> exportConfig();

  /// Import configuration data
  ///
  /// Restores configuration from previously exported data.
  /// Validates data before importing and creates backup of current config.
  Future<void> importConfig(Map<String, dynamic> configData);

  /// Get storage statistics
  ///
  /// Returns information about local storage usage, database size,
  /// and configuration metadata for debugging purposes.
  Future<Map<String, dynamic>> getStorageStats();

  /// Optimize storage
  ///
  /// Performs database maintenance operations like vacuuming
  /// and index optimization for better performance.
  Future<void> optimizeStorage();

  /// Check storage health
  ///
  /// Validates database integrity and reports any corruption
  /// or inconsistencies in the configuration storage.
  Future<bool> checkStorageHealth();

  /// Backup configuration
  ///
  /// Creates a backup of the current configuration in a separate
  /// location for recovery purposes. Returns backup path/identifier.
  Future<String?> backupConfig();

  /// Restore from backup
  ///
  /// Restores configuration from a previously created backup
  /// using the backup path/identifier returned from backupConfig.
  Future<void> restoreFromBackup(String backupIdentifier);

  /// Get all configuration keys
  ///
  /// Returns list of all available configuration keys in storage.
  /// Useful for debugging and configuration management.
  Future<List<String>> getAllConfigKeys();

  /// Initialize storage
  ///
  /// Prepares the local storage system, creates necessary tables,
  /// and performs any required initial setup operations.
  Future<void> initialize();

  /// Close storage connection
  ///
  /// Properly closes database connections and releases resources.
  /// Should be called when the app is shutting down.
  Future<void> close();

  /// Check if storage is initialized
  ///
  /// Returns true if the storage system has been properly initialized
  /// and is ready for configuration operations.
  Future<bool> isInitialized();
}
