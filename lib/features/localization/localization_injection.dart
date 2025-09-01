/// Localization Dependency Injection - Clean Architecture Setup
///
/// PATTERN: Dependency Injection + Factory - IoC container setup
/// WHERE: Feature-level dependency injection configuration
/// HOW: get_it service locator with factory registrations
/// WHY: Decouples dependencies and enables testing with clean boundaries
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/patterns/behavioral/observer.dart';
import 'package:design_patterns/features/localization/data/datasources/embedded_translations_datasource.dart';
import 'package:design_patterns/features/localization/data/datasources/local_translation_datasource.dart';
import 'package:design_patterns/features/localization/data/datasources/shared_preferences_datasource.dart';
import 'package:design_patterns/features/localization/data/repositories/translation_repository_impl.dart';
import 'package:design_patterns/features/localization/domain/repositories/translation_repository.dart';
import 'package:design_patterns/features/localization/domain/services/translation_service.dart';
import 'package:design_patterns/features/localization/domain/usecases/change_language.dart';
import 'package:design_patterns/features/localization/domain/usecases/get_current_language.dart';
import 'package:design_patterns/features/localization/domain/usecases/load_translations.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Localization dependency injection setup
///
/// PATTERN: Dependency Injection - Configures IoC container
/// Registers all localization-related dependencies following
/// Clean Architecture principles for the Tower Defense app.
class LocalizationInjection {
  /// Initialize localization dependencies
  ///
  /// Must be called during app initialization before using
  /// any localization features.
  static Future<void> init() async {
    try {
      Log.debug('Initializing localization dependencies...');

      final sl = GetIt.instance;

      // External dependencies
      final sharedPreferences = await SharedPreferences.getInstance();
      sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

      // Data sources
      sl.registerLazySingleton<EmbeddedTranslationsDataSource>(
        () => EmbeddedTranslationsDataSource(),
      );

      sl.registerLazySingleton<LocalTranslationDataSource>(
        () => SharedPreferencesDataSource(
          sl<SharedPreferences>(),
          sl<EmbeddedTranslationsDataSource>(),
        ),
      );

      // Repository
      sl.registerLazySingleton<TranslationRepository>(
        () => TranslationRepositoryImpl(sl<LocalTranslationDataSource>()),
      );

      // Use cases
      sl.registerLazySingleton<GetCurrentLanguage>(
        () => GetCurrentLanguage(sl<TranslationRepository>()),
      );

      sl.registerLazySingleton<ChangeLanguage>(
        () => ChangeLanguage(
          sl<TranslationRepository>(),
          GameEventManager(), // Singleton instance
        ),
      );

      sl.registerLazySingleton<LoadTranslations>(
        () => LoadTranslations(sl<TranslationRepository>()),
      );

      // Services
      sl.registerLazySingleton<TranslationService>(() => TranslationService());

      Log.success('Localization dependencies initialized successfully');

      // Initialize translation service with dependencies
      await _initializeTranslationService();
    } catch (e) {
      Log.error('Failed to initialize localization dependencies: $e');
      rethrow;
    }
  }

  /// Initialize the translation service with its dependencies
  static Future<void> _initializeTranslationService() async {
    try {
      Log.debug('Initializing TranslationService...');

      final sl = GetIt.instance;
      final translationService = sl<TranslationService>();

      // Inject use cases into the service
      translationService.initialize(
        getCurrentLanguage: sl<GetCurrentLanguage>(),
        changeLanguage: sl<ChangeLanguage>(),
        loadTranslations: sl<LoadTranslations>(),
      );

      // Initialize with system language detection
      await translationService.initializeWithSystemLanguage();

      Log.success('TranslationService initialized with system language');
    } catch (e) {
      Log.error('Error initializing TranslationService: $e');
      // Don't rethrow - allow app to continue with default language
    }
  }

  /// Reset all localization dependencies
  ///
  /// Useful for testing or app reset scenarios
  static Future<void> reset() async {
    try {
      Log.debug('Resetting localization dependencies...');

      final sl = GetIt.instance;

      // Unregister in reverse order
      if (sl.isRegistered<TranslationService>()) {
        sl.unregister<TranslationService>();
      }
      if (sl.isRegistered<LoadTranslations>()) {
        sl.unregister<LoadTranslations>();
      }
      if (sl.isRegistered<ChangeLanguage>()) {
        sl.unregister<ChangeLanguage>();
      }
      if (sl.isRegistered<GetCurrentLanguage>()) {
        sl.unregister<GetCurrentLanguage>();
      }
      if (sl.isRegistered<TranslationRepository>()) {
        sl.unregister<TranslationRepository>();
      }
      if (sl.isRegistered<LocalTranslationDataSource>()) {
        sl.unregister<LocalTranslationDataSource>();
      }
      if (sl.isRegistered<EmbeddedTranslationsDataSource>()) {
        sl.unregister<EmbeddedTranslationsDataSource>();
      }

      Log.success('Localization dependencies reset');
    } catch (e) {
      Log.error('Error resetting localization dependencies: $e');
    }
  }

  /// Get translation service instance
  ///
  /// Convenience method for accessing the translation service
  static TranslationService get translationService {
    return GetIt.instance<TranslationService>();
  }

  /// Check if localization is initialized
  ///
  /// Verify that all dependencies are registered and ready
  static bool get isInitialized {
    try {
      final sl = GetIt.instance;
      return sl.isRegistered<TranslationService>() &&
          sl.isRegistered<TranslationRepository>() &&
          sl.isRegistered<LocalTranslationDataSource>() &&
          translationService.isInitialized;
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
      'SharedPreferences': sl.isRegistered<SharedPreferences>(),
      'EmbeddedTranslationsDataSource': sl
          .isRegistered<EmbeddedTranslationsDataSource>(),
      'LocalTranslationDataSource': sl
          .isRegistered<LocalTranslationDataSource>(),
      'TranslationRepository': sl.isRegistered<TranslationRepository>(),
      'GetCurrentLanguage': sl.isRegistered<GetCurrentLanguage>(),
      'ChangeLanguage': sl.isRegistered<ChangeLanguage>(),
      'LoadTranslations': sl.isRegistered<LoadTranslations>(),
      'TranslationService': sl.isRegistered<TranslationService>(),
      'TranslationServiceInitialized': isInitialized,
    };
  }
}
