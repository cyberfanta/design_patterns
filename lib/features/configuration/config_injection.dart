/// Configuration Dependency Injection - Clean Architecture Setup
///
/// PATTERN: Dependency Injection + Factory - IoC container setup
/// WHERE: Feature-level dependency injection configuration
/// HOW: get_it service locator with factory registrations
/// WHY: Decouples dependencies and enables testing with clean boundaries
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/configuration/data/datasources/local_config_datasource.dart';
import 'package:design_patterns/features/configuration/data/datasources/sqlite_config_datasource.dart';
import 'package:design_patterns/features/configuration/data/repositories/config_repository_impl.dart';
import 'package:design_patterns/features/configuration/domain/repositories/config_repository.dart';
import 'package:design_patterns/features/configuration/domain/services/config_service.dart';
import 'package:design_patterns/features/configuration/domain/usecases/get_config.dart';
import 'package:design_patterns/features/configuration/domain/usecases/reset_config.dart';
import 'package:design_patterns/features/configuration/domain/usecases/save_config.dart';
import 'package:get_it/get_it.dart';

/// Configuration dependency injection setup
///
/// PATTERN: Dependency Injection - Configures IoC container
/// Registers all configuration-related dependencies following
/// Clean Architecture principles for the Tower Defense app.
class ConfigInjection {
  /// Initialize configuration dependencies
  ///
  /// Must be called during app initialization before using
  /// any configuration features.
  static Future<void> init() async {
    try {
      Log.debug('Initializing configuration dependencies...');

      final sl = GetIt.instance;

      // Data sources
      sl.registerLazySingleton<LocalConfigDataSource>(
        () => SQLiteConfigDataSource(),
      );

      // Initialize the SQLite data source
      final dataSource = sl<LocalConfigDataSource>();
      await dataSource.initialize();

      // Repository
      sl.registerLazySingleton<ConfigRepository>(
        () => ConfigRepositoryImpl(sl<LocalConfigDataSource>()),
      );

      // Use cases
      sl.registerLazySingleton<GetConfig>(
        () => GetConfig(sl<ConfigRepository>()),
      );

      sl.registerLazySingleton<SaveConfig>(
        () => SaveConfig(sl<ConfigRepository>()),
      );

      sl.registerLazySingleton<ResetConfig>(
        () => ResetConfig(sl<ConfigRepository>()),
      );

      // Services
      sl.registerLazySingleton<ConfigService>(() => ConfigService());

      Log.success('Configuration dependencies initialized successfully');

      // Initialize configuration service with dependencies
      await _initializeConfigService();
    } catch (e) {
      Log.error('Failed to initialize configuration dependencies: $e');
      rethrow;
    }
  }

  /// Initialize the configuration service with its dependencies
  static Future<void> _initializeConfigService() async {
    try {
      Log.debug('Initializing ConfigService...');

      final sl = GetIt.instance;
      final configService = sl<ConfigService>();

      // Inject use cases into the service
      configService.initialize(
        getConfig: sl<GetConfig>(),
        saveConfig: sl<SaveConfig>(),
        resetConfig: sl<ResetConfig>(),
      );

      // Initialize with configuration loading
      await configService.initializeWithConfig();

      Log.success('ConfigService initialized with configuration loading');
    } catch (e) {
      Log.error('Error initializing ConfigService: $e');
      // Don't rethrow - allow app to continue with default configuration
    }
  }

  /// Reset all configuration dependencies
  ///
  /// Useful for testing or app reset scenarios
  static Future<void> reset() async {
    try {
      Log.debug('Resetting configuration dependencies...');

      final sl = GetIt.instance;

      // Close data source connection before unregistering
      if (sl.isRegistered<LocalConfigDataSource>()) {
        final dataSource = sl<LocalConfigDataSource>();
        await dataSource.close();
      }

      // Unregister in reverse order
      if (sl.isRegistered<ConfigService>()) {
        sl.unregister<ConfigService>();
      }
      if (sl.isRegistered<ResetConfig>()) {
        sl.unregister<ResetConfig>();
      }
      if (sl.isRegistered<SaveConfig>()) {
        sl.unregister<SaveConfig>();
      }
      if (sl.isRegistered<GetConfig>()) {
        sl.unregister<GetConfig>();
      }
      if (sl.isRegistered<ConfigRepository>()) {
        sl.unregister<ConfigRepository>();
      }
      if (sl.isRegistered<LocalConfigDataSource>()) {
        sl.unregister<LocalConfigDataSource>();
      }

      Log.success('Configuration dependencies reset');
    } catch (e) {
      Log.error('Error resetting configuration dependencies: $e');
    }
  }

  /// Get configuration service instance
  ///
  /// Convenience method for accessing the configuration service
  static ConfigService get configService {
    return GetIt.instance<ConfigService>();
  }

  /// Check if configuration system is initialized
  ///
  /// Verify that all dependencies are registered and ready
  static bool get isInitialized {
    try {
      final sl = GetIt.instance;
      return sl.isRegistered<ConfigService>() &&
          sl.isRegistered<ConfigRepository>() &&
          sl.isRegistered<LocalConfigDataSource>() &&
          configService.isInitialized;
    } catch (e) {
      Log.error('Error checking initialization status: $e');
      return false;
    }
  }

  /// Get dependency status for debugging
  ///
  /// Returns information about registered dependencies
  static Map<String, bool> get dependencyStatus {
    final sl = GetIt.instance;

    return {
      'LocalConfigDataSource': sl.isRegistered<LocalConfigDataSource>(),
      'ConfigRepository': sl.isRegistered<ConfigRepository>(),
      'GetConfig': sl.isRegistered<GetConfig>(),
      'SaveConfig': sl.isRegistered<SaveConfig>(),
      'ResetConfig': sl.isRegistered<ResetConfig>(),
      'ConfigService': sl.isRegistered<ConfigService>(),
      'ConfigServiceInitialized': isInitialized,
    };
  }

  /// Get configuration debug information
  ///
  /// Returns detailed information about the configuration system
  static Map<String, dynamic> getDebugInfo() {
    try {
      final debugInfo = {
        'dependencies': dependencyStatus,
        'is_initialized': isInitialized,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (isInitialized) {
        debugInfo['config_service'] = configService.getDebugInfo();
      }

      return debugInfo;
    } catch (e) {
      Log.error('Error getting configuration debug info: $e');
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Perform system health check
  ///
  /// Validates that all configuration components are working properly
  static Future<Map<String, dynamic>> performHealthCheck() async {
    try {
      Log.debug('Performing configuration system health check...');

      final healthCheck = <String, dynamic>{
        'dependencies_status': dependencyStatus,
        'is_initialized': isInitialized,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (isInitialized) {
        final sl = GetIt.instance;

        // Check repository health
        try {
          final repository = sl<ConfigRepository>();
          final storageInfo = await repository.getStorageInfo();

          storageInfo.fold(
            (failure) => healthCheck['storage_error'] = failure.toString(),
            (info) => healthCheck['storage_info'] = info,
          );

          // Check if configuration can be loaded
          final configResult = await repository.loadConfig();
          configResult.fold(
            (failure) => healthCheck['config_load_error'] = failure.toString(),
            (_) => healthCheck['config_load_status'] = 'OK',
          );
        } catch (e) {
          healthCheck['repository_error'] = e.toString();
        }

        // Check service status
        try {
          healthCheck['service_status'] = configService.getDebugInfo();
        } catch (e) {
          healthCheck['service_error'] = e.toString();
        }
      }

      Log.success('Configuration system health check completed');
      return healthCheck;
    } catch (e) {
      Log.error('Error performing configuration health check: $e');
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
