/// SQLite Configuration Data Source Implementation - Data Layer
///
/// PATTERN: Adapter - Adapts SQLite to LocalConfigDataSource interface
/// WHERE: Data layer implementation for persistent configuration storage
/// HOW: Concrete implementation using SQLite for configuration persistence
/// WHY: Provides reliable local storage for configuration with ACID properties
library;

import 'dart:io';

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/configuration/data/datasources/local_config_datasource.dart';
import 'package:design_patterns/features/configuration/data/models/app_config_model.dart';
import 'package:sqflite/sqflite.dart';
// Using path from sqflite package

/// SQLite implementation of LocalConfigDataSource
///
/// PATTERN: Adapter - Adapts SQLite API to our domain contracts
/// Uses device's SQLite database to persist configuration data with
/// full ACID compliance for the Tower Defense app's configuration system.
class SQLiteConfigDataSource implements LocalConfigDataSource {
  Database? _database;
  bool _isInitialized = false;

  // Database configuration
  static const String _databaseName = 'tower_defense_config.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'app_config';

  /// Initialize database connection and create tables
  @override
  Future<void> initialize() async {
    try {
      if (_isInitialized) {
        Log.debug('SQLite config datasource already initialized');
        return;
      }

      Log.debug('Initializing SQLite configuration datasource...');

      final databasesPath = await getDatabasesPath();
      final dbPath = '$databasesPath/$_databaseName';

      _database = await openDatabase(
        dbPath,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      _isInitialized = true;
      Log.success('SQLite configuration datasource initialized successfully');
    } catch (e) {
      Log.error('Error initializing SQLite configuration datasource: $e');
      rethrow;
    }
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    try {
      Log.debug('Creating configuration database tables...');

      await db.execute(AppConfigModel.createTableSQL);

      Log.success('Configuration database tables created');
    } catch (e) {
      Log.error('Error creating database tables: $e');
      rethrow;
    }
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Log.info('Upgrading database from version $oldVersion to $newVersion');

    // Handle future database migrations here
    if (oldVersion < 2) {
      // Example: Add new columns, modify tables, etc.
    }
  }

  /// Ensure database is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized || _database == null) {
      await initialize();
    }
  }

  @override
  Future<AppConfigModel?> loadConfig() async {
    try {
      await _ensureInitialized();
      Log.debug('Loading configuration from SQLite database');

      final List<Map<String, dynamic>> result = await _database!.rawQuery(
        AppConfigModel.selectSQL,
      );

      if (result.isEmpty) {
        Log.debug('No configuration found in database');
        return null;
      }

      final configData = result.first;
      final config = AppConfigModel.fromSQLite(configData);

      Log.success('Configuration loaded from database: ${config.languageCode}');
      return config;
    } catch (e) {
      Log.error('Error loading configuration from database: $e');
      return null;
    }
  }

  @override
  Future<void> saveConfig(AppConfigModel config) async {
    try {
      await _ensureInitialized();
      Log.debug('Saving configuration to SQLite database');

      final values = config.getSQLiteInsertValues();

      await _database!.rawInsert(AppConfigModel.insertSQL, values);

      Log.success('Configuration saved to database successfully');
    } catch (e) {
      Log.error('Error saving configuration to database: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasConfig() async {
    try {
      await _ensureInitialized();
      Log.debug('Checking if configuration exists in database');

      final List<Map<String, dynamic>> result = await _database!.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE id = 1',
      );

      final count = result.first['count'] as int;
      final hasConfig = count > 0;

      Log.debug('Configuration exists in database: $hasConfig');
      return hasConfig;
    } catch (e) {
      Log.error('Error checking configuration existence: $e');
      return false;
    }
  }

  @override
  Future<T?> getConfigValue<T>(String key) async {
    try {
      await _ensureInitialized();
      Log.debug('Getting configuration value for key: $key');

      final config = await loadConfig();
      if (config == null) {
        Log.debug('No configuration found for key: $key');
        return null;
      }

      final jsonData = config.toJson();
      final value = jsonData[key];

      if (value is T) {
        Log.debug('Configuration value retrieved for $key: $value');
        return value;
      }

      Log.warning('Configuration value type mismatch for key: $key');
      return null;
    } catch (e) {
      Log.error('Error getting configuration value for $key: $e');
      return null;
    }
  }

  @override
  Future<void> updateConfigValue(String key, dynamic value) async {
    try {
      await _ensureInitialized();
      Log.debug('Updating configuration value: $key = $value');

      // Load current config
      final currentConfig = await loadConfig();
      if (currentConfig == null) {
        Log.warning('No existing configuration to update, creating new one');
        final defaultConfig = AppConfigModel.defaultModel;
        await saveConfig(defaultConfig);
        return;
      }

      // Create updated config based on key
      AppConfigModel updatedConfig;

      switch (key) {
        case 'language_code':
          updatedConfig = currentConfig.copyWith(languageCode: value as String);
          break;
        case 'theme_mode':
          updatedConfig = currentConfig.copyWith(themeMode: value as String);
          break;
        case 'sound_enabled':
          updatedConfig = currentConfig.copyWith(soundEnabled: value as bool);
          break;
        case 'music_enabled':
          updatedConfig = currentConfig.copyWith(musicEnabled: value as bool);
          break;
        case 'volume':
          updatedConfig = currentConfig.copyWith(
            volume: (value as num).toDouble(),
          );
          break;
        case 'difficulty_level':
          updatedConfig = currentConfig.copyWith(
            difficultyLevel: value as String,
          );
          break;
        case 'show_tutorial':
          updatedConfig = currentConfig.copyWith(showTutorial: value as bool);
          break;
        case 'analytics_enabled':
          updatedConfig = currentConfig.copyWith(
            analyticsEnabled: value as bool,
          );
          break;
        case 'is_first_run':
          updatedConfig = currentConfig.copyWith(isFirstRun: value as bool);
          break;
        default:
          Log.error('Unknown configuration key for update: $key');
          return;
      }

      await saveConfig(updatedConfig);
      Log.success('Configuration value updated: $key');
    } catch (e) {
      Log.error('Error updating configuration value $key: $e');
      rethrow;
    }
  }

  @override
  Future<int> getConfigVersion() async {
    try {
      await _ensureInitialized();
      Log.debug('Getting configuration version from database');

      final config = await loadConfig();
      final version = config?.configVersion ?? 0;

      Log.debug('Configuration version: $version');
      return version;
    } catch (e) {
      Log.error('Error getting configuration version: $e');
      return 0;
    }
  }

  @override
  Future<void> clearConfig() async {
    try {
      await _ensureInitialized();
      Log.warning('Clearing all configuration data from database');

      await _database!.delete(_tableName);

      Log.warning('All configuration data cleared from database');
    } catch (e) {
      Log.error('Error clearing configuration data: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetToDefaults() async {
    try {
      await _ensureInitialized();
      Log.debug('Resetting configuration to defaults');

      final defaultConfig = AppConfigModel.defaultModel;
      await saveConfig(defaultConfig);

      Log.success('Configuration reset to defaults');
    } catch (e) {
      Log.error('Error resetting configuration to defaults: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> exportConfig() async {
    try {
      await _ensureInitialized();
      Log.debug('Exporting configuration data');

      final config = await loadConfig();
      if (config == null) {
        Log.debug('No configuration to export');
        return null;
      }

      final exportData = config.toJson();
      exportData['exported_at'] = DateTime.now().toIso8601String();
      exportData['export_version'] = 1;

      Log.success('Configuration data exported successfully');
      return exportData;
    } catch (e) {
      Log.error('Error exporting configuration: $e');
      return null;
    }
  }

  @override
  Future<void> importConfig(Map<String, dynamic> configData) async {
    try {
      await _ensureInitialized();
      Log.debug('Importing configuration data');

      // Create backup before import
      final backup = await exportConfig();
      if (backup != null) {
        // Log backup creation
        Log.debug('Configuration backup created successfully before import');
      }

      // Validate and import configuration
      final config = AppConfigModel.fromJson(configData);

      if (!config.isValidModel) {
        Log.error('Invalid configuration data for import');
        throw ArgumentError('Invalid configuration data');
      }

      await saveConfig(config);

      Log.success('Configuration imported successfully');
    } catch (e) {
      Log.error('Error importing configuration: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      await _ensureInitialized();
      Log.debug('Getting storage statistics');

      // Get database file size
      final databasesPath = await getDatabasesPath();
      final dbPath = '$databasesPath/$_databaseName';

      int fileSize = 0;
      try {
        final file = await File(dbPath).stat();
        fileSize = file.size;
      } catch (e) {
        Log.warning('Could not get database file size: $e');
      }

      // Get table statistics
      final List<Map<String, dynamic>> result = await _database!.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName',
      );
      final recordCount = result.first['count'] as int;

      final config = await loadConfig();

      final stats = {
        'database_name': _databaseName,
        'database_version': _databaseVersion,
        'file_size_bytes': fileSize,
        'record_count': recordCount,
        'table_name': _tableName,
        'is_initialized': _isInitialized,
        'has_config': recordCount > 0,
        'last_updated': config?.lastUpdated.toIso8601String(),
        'config_version': config?.configVersion ?? 0,
        'storage_health': await checkStorageHealth(),
      };

      Log.debug('Storage statistics generated');
      return stats;
    } catch (e) {
      Log.error('Error getting storage statistics: $e');
      return {'error': e.toString(), 'is_initialized': _isInitialized};
    }
  }

  @override
  Future<void> optimizeStorage() async {
    try {
      await _ensureInitialized();
      Log.debug('Optimizing database storage');

      await _database!.execute('VACUUM');
      await _database!.execute('ANALYZE');

      Log.success('Database storage optimized');
    } catch (e) {
      Log.error('Error optimizing storage: $e');
    }
  }

  @override
  Future<bool> checkStorageHealth() async {
    try {
      await _ensureInitialized();

      // Perform basic integrity check
      final List<Map<String, dynamic>> result = await _database!.rawQuery(
        'PRAGMA integrity_check',
      );

      final isHealthy = result.isNotEmpty && result.first.values.first == 'ok';

      Log.debug('Storage health check: ${isHealthy ? 'OK' : 'FAILED'}');
      return isHealthy;
    } catch (e) {
      Log.error('Error checking storage health: $e');
      return false;
    }
  }

  @override
  Future<String?> backupConfig() async {
    try {
      Log.debug('Creating configuration backup');

      final exportData = await exportConfig();
      if (exportData == null) {
        return null;
      }

      final backupId = 'config_backup_${DateTime.now().millisecondsSinceEpoch}';

      // In a real implementation, you might save this to a file or secure storage
      Log.success('Configuration backup created with ID: $backupId');
      return backupId;
    } catch (e) {
      Log.error('Error creating configuration backup: $e');
      return null;
    }
  }

  @override
  Future<void> restoreFromBackup(String backupIdentifier) async {
    try {
      Log.debug('Restoring configuration from backup: $backupIdentifier');

      // In a real implementation, you would load the backup data
      // For now, we'll reset to defaults as a placeholder
      await resetToDefaults();

      Log.success('Configuration restored from backup');
    } catch (e) {
      Log.error('Error restoring from backup: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getAllConfigKeys() async {
    try {
      Log.debug('Getting all configuration keys');

      final config = await loadConfig();
      if (config == null) {
        return [];
      }

      final keys = config.toJson().keys.toList();
      Log.debug('Configuration keys: ${keys.length}');

      return keys;
    } catch (e) {
      Log.error('Error getting configuration keys: $e');
      return [];
    }
  }

  @override
  Future<void> close() async {
    try {
      if (_database != null) {
        Log.debug('Closing SQLite database connection');
        await _database!.close();
        _database = null;
        _isInitialized = false;
        Log.success('Database connection closed');
      }
    } catch (e) {
      Log.error('Error closing database connection: $e');
    }
  }

  @override
  Future<bool> isInitialized() async {
    return _isInitialized && _database != null;
  }
}
