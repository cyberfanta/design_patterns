/// Shared Preferences Data Source Implementation - Data Layer
///
/// PATTERN: Adapter - Adapts SharedPreferences to LocalTranslationDataSource
/// WHERE: Data layer implementation for local storage
/// HOW: Concrete implementation using SharedPreferences for persistence
/// WHY: Provides persistent local storage for language preferences and cache
library;

import 'dart:convert';
import 'dart:io';

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/localization/data/data_sources/embedded_translations_datasource.dart';
import 'package:design_patterns/features/localization/data/data_sources/local_translation_datasource.dart';
import 'package:design_patterns/features/localization/data/models/language_model.dart';
import 'package:design_patterns/features/localization/data/models/translation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences implementation of LocalTranslationDataSource
///
/// PATTERN: Adapter - Adapts SharedPreferences API to our domain contracts
/// Uses device's persistent storage to cache translation data and
/// user preferences for the Tower Defense multilingual system.
class SharedPreferencesDataSource implements LocalTranslationDataSource {
  final SharedPreferences _prefs;
  final EmbeddedTranslationsDataSource _embeddedSource;

  // Storage keys
  static const String _keyLanguagePreference = 'language_preference';
  static const String _keyTranslationPrefix = 'translation_';
  static const String _keyCacheTimestamp = 'cache_timestamp_';
  static const String _keyCacheInfo = 'cache_info';

  const SharedPreferencesDataSource(this._prefs, this._embeddedSource);

  @override
  Future<TranslationModel?> loadTranslation(String languageCode) async {
    try {
      Log.debug('Loading translation from cache for: $languageCode');

      // First check embedded translations
      final embeddedTranslation = _embeddedSource.getTranslation(languageCode);
      if (embeddedTranslation != null) {
        Log.debug('Found embedded translation for $languageCode');

        // Cache it locally for future offline access
        await saveTranslation(embeddedTranslation);
        return embeddedTranslation;
      }

      // Fallback to cached data
      final key = '$_keyTranslationPrefix$languageCode';
      final jsonString = _prefs.getString(key);

      if (jsonString == null) {
        Log.debug('No cached translation found for $languageCode');
        return null;
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final translation = TranslationModel.fromJson(jsonMap);

      Log.success(
        'Loaded cached translation for $languageCode (${translation.count} keys)',
      );
      return translation;
    } catch (e) {
      Log.error('Error loading translation for $languageCode: $e');
      return null;
    }
  }

  @override
  Future<void> saveTranslation(TranslationModel translation) async {
    try {
      Log.debug('Saving translation to cache for: ${translation.languageCode}');

      final key = '$_keyTranslationPrefix${translation.languageCode}';
      final jsonString = jsonEncode(translation.toJson());

      await _prefs.setString(key, jsonString);

      // Save timestamp
      final timestampKey = '$_keyCacheTimestamp${translation.languageCode}';
      await _prefs.setString(timestampKey, DateTime.now().toIso8601String());

      Log.success('Translation cached for ${translation.languageCode}');
    } catch (e) {
      Log.error('Error saving translation: $e');
    }
  }

  @override
  Future<LanguageModel?> getLanguagePreference() async {
    try {
      final jsonString = _prefs.getString(_keyLanguagePreference);

      if (jsonString == null) {
        Log.debug('No language preference found');
        return null;
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final language = LanguageModel.fromJson(jsonMap);

      Log.debug('Loaded language preference: ${language.code}');
      return language;
    } catch (e) {
      Log.error('Error loading language preference: $e');
      return null;
    }
  }

  @override
  Future<void> saveLanguagePreference(LanguageModel language) async {
    try {
      Log.debug('Saving language preference: ${language.code}');

      final jsonString = jsonEncode(language.toJson());
      await _prefs.setString(_keyLanguagePreference, jsonString);

      Log.success('Language preference saved: ${language.code}');
    } catch (e) {
      Log.error('Error saving language preference: $e');
    }
  }

  @override
  Future<LanguageModel> getSystemLanguage() async {
    try {
      // Get system locale
      String systemLocale = Platform.localeName;
      Log.debug('System locale detected: $systemLocale');

      // Extract language code (first part before underscore)
      String languageCode = systemLocale.split('_').first.toLowerCase();

      // Check if system language is supported
      if (_embeddedSource.isLanguageSupported(languageCode)) {
        final language = LanguageModel.fromCode(languageCode);
        Log.success('System language supported: ${language.code}');
        return language.copyWith(isSystemDefault: true);
      } else {
        Log.warning(
          'System language $languageCode not supported, defaulting to English',
        );
        return LanguageModel.englishModel.copyWith(isSystemDefault: true);
      }
    } catch (e) {
      Log.error('Error detecting system language: $e');
      return LanguageModel.englishModel.copyWith(isSystemDefault: true);
    }
  }

  @override
  Future<bool> hasTranslation(String languageCode) async {
    try {
      // First check embedded translations
      if (_embeddedSource.isLanguageSupported(languageCode)) {
        return true;
      }

      // Check cached translations
      final key = '$_keyTranslationPrefix$languageCode';
      return _prefs.containsKey(key);
    } catch (e) {
      Log.error('Error checking translation existence: $e');
      return false;
    }
  }

  @override
  Future<List<String>> getCachedLanguages() async {
    try {
      final keys = _prefs.getKeys();
      final cachedLanguages = <String>[];

      for (final key in keys) {
        if (key.startsWith(_keyTranslationPrefix)) {
          final languageCode = key.substring(_keyTranslationPrefix.length);
          cachedLanguages.add(languageCode);
        }
      }

      Log.debug(
        'Found ${cachedLanguages.length} cached languages: $cachedLanguages',
      );
      return cachedLanguages;
    } catch (e) {
      Log.error('Error getting cached languages: $e');
      return [];
    }
  }

  @override
  Future<void> clearAllTranslations() async {
    try {
      Log.debug('Clearing all cached translations');

      final keys = _prefs.getKeys();
      final translationKeys = keys
          .where(
            (key) =>
                key.startsWith(_keyTranslationPrefix) ||
                key.startsWith(_keyCacheTimestamp),
          )
          .toList();

      for (final key in translationKeys) {
        await _prefs.remove(key);
      }

      // Clear cache info
      await _prefs.remove(_keyCacheInfo);

      Log.success('Cleared ${translationKeys.length} cached translations');
    } catch (e) {
      Log.error('Error clearing translations: $e');
    }
  }

  @override
  Future<void> clearTranslation(String languageCode) async {
    try {
      Log.debug('Clearing cached translation for: $languageCode');

      final translationKey = '$_keyTranslationPrefix$languageCode';
      final timestampKey = '$_keyCacheTimestamp$languageCode';

      await _prefs.remove(translationKey);
      await _prefs.remove(timestampKey);

      Log.success('Cleared cached translation for $languageCode');
    } catch (e) {
      Log.error('Error clearing translation for $languageCode: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final cachedLanguages = await getCachedLanguages();
      final info = <String, dynamic>{
        'cached_languages': cachedLanguages,
        'cache_count': cachedLanguages.length,
        'supported_languages': _embeddedSource.getSupportedLanguages(),
        'last_updated': DateTime.now().toIso8601String(),
        'storage_available': await isStorageAvailable(),
      };

      // Add timestamp information for each cached language
      for (final languageCode in cachedLanguages) {
        final timestamp = await getLastUpdateTime(languageCode);
        if (timestamp != null) {
          info['${languageCode}_cached_at'] = timestamp.toIso8601String();
        }
      }

      return info;
    } catch (e) {
      Log.error('Error getting cache info: $e');
      return {
        'error': e.toString(),
        'cached_languages': <String>[],
        'cache_count': 0,
      };
    }
  }

  @override
  Future<bool> isStorageAvailable() async {
    try {
      // Test write/read operation
      const testKey = 'storage_test';
      const testValue = 'test_value';

      await _prefs.setString(testKey, testValue);
      final retrieved = _prefs.getString(testKey);
      await _prefs.remove(testKey);

      return retrieved == testValue;
    } catch (e) {
      Log.error('Storage availability test failed: $e');
      return false;
    }
  }

  @override
  Future<void> updateTranslation(
    String languageCode,
    TranslationModel translation,
  ) async {
    try {
      Log.debug('Updating translation for: $languageCode');

      // First clear existing translation
      await clearTranslation(languageCode);

      // Save new translation
      await saveTranslation(translation);

      Log.success('Translation updated for $languageCode');
    } catch (e) {
      Log.error('Error updating translation for $languageCode: $e');
    }
  }

  @override
  Future<DateTime?> getLastUpdateTime(String languageCode) async {
    try {
      final key = '$_keyCacheTimestamp$languageCode';
      final timestampString = _prefs.getString(key);

      if (timestampString == null) {
        return null;
      }

      return DateTime.parse(timestampString);
    } catch (e) {
      Log.error('Error getting last update time for $languageCode: $e');
      return null;
    }
  }
}
