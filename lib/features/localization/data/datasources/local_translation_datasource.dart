/// Local Translation Data Source - Clean Architecture Data Layer
///
/// PATTERN: Data Source - Abstract interface for local translation data
/// WHERE: Data layer for local translation storage and retrieval
/// HOW: Abstract class defining local data operations
/// WHY: Separates local storage implementation from business logic
library;

import 'package:design_patterns/features/localization/data/models/language_model.dart';
import 'package:design_patterns/features/localization/data/models/translation_model.dart';

/// Abstract data source for local translation operations
///
/// This defines the contract for local translation storage,
/// supporting the Tower Defense app's offline multilingual
/// functionality with persistent language preferences.
abstract class LocalTranslationDataSource {
  /// Load translation data from local storage
  ///
  /// Returns cached translation data for the specified language
  /// or null if no cached data exists
  Future<TranslationModel?> loadTranslation(String languageCode);

  /// Save translation data to local storage
  ///
  /// Caches translation data for offline access and performance
  Future<void> saveTranslation(TranslationModel translation);

  /// Load user's saved language preference
  ///
  /// Returns the user's previously selected language or null
  /// if no preference has been saved
  Future<LanguageModel?> getLanguagePreference();

  /// Save user's language preference
  ///
  /// Persists the user's language choice for future sessions
  Future<void> saveLanguagePreference(LanguageModel language);

  /// Get system/device language
  ///
  /// Detects the device's current language setting for
  /// automatic language selection
  Future<LanguageModel> getSystemLanguage();

  /// Check if translation data exists for a language
  ///
  /// Verifies if cached translations are available locally
  Future<bool> hasTranslation(String languageCode);

  /// Get all cached language codes
  ///
  /// Returns list of languages that have cached translation data
  Future<List<String>> getCachedLanguages();

  /// Clear all cached translation data
  ///
  /// Removes all stored translations to free up space or force refresh
  Future<void> clearAllTranslations();

  /// Clear translation data for specific language
  ///
  /// Removes cached data for a single language
  Future<void> clearTranslation(String languageCode);

  /// Get cache metadata and statistics
  ///
  /// Returns information about cached translations including
  /// cache size, last update times, and available languages
  Future<Map<String, dynamic>> getCacheInfo();

  /// Check if local storage is available and writable
  ///
  /// Validates that the device supports persistent storage
  Future<bool> isStorageAvailable();

  /// Update translation cache with new data
  ///
  /// Replaces existing translation data with updated version
  Future<void> updateTranslation(
    String languageCode,
    TranslationModel translation,
  );

  /// Get last cache update timestamp for a language
  ///
  /// Returns when the translation data was last cached
  Future<DateTime?> getLastUpdateTime(String languageCode);
}
