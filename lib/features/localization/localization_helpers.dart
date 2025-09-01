/// Localization Helper Functions - Convenience Layer
///
/// PATTERN: Facade - Simplified access to translation functionality
/// WHERE: Public API layer for easy access to translations
/// HOW: Static methods wrapping TranslationService functionality
/// WHY: Provides convenient access without exposing internal complexity
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/localization/domain/entities/language.dart';
import 'package:design_patterns/features/localization/domain/services/translation_service.dart';
import 'package:get_it/get_it.dart';

/// Helper class providing convenient access to localization features
///
/// PATTERN: Facade - Simplifies access to complex localization subsystem
/// Used throughout the Tower Defense app for easy text translation
/// without directly coupling to the TranslationService.
class LocalizationHelpers {
  // Private constructor to prevent instantiation
  const LocalizationHelpers._();

  /// Get translation service instance
  static TranslationService get _service {
    try {
      return GetIt.instance<TranslationService>();
    } catch (e) {
      Log.error('TranslationService not initialized: $e');
      rethrow;
    }
  }

  /// Translate a key to current language
  ///
  /// Example usage:
  /// ```dart
  /// Text(tr('game_start')) // Returns "Start Game" or translated text
  /// ```
  static String tr(String key) {
    try {
      return _service.translate(key);
    } catch (e) {
      Log.warning('Translation failed for key "$key": $e');
      return key; // Fallback to key if translation fails
    }
  }

  /// Translate with arguments (parameter substitution)
  ///
  /// Example usage:
  /// ```dart
  /// trArgs('welcome_user', {'name': 'Player'}) // "Welcome, Player!"
  /// ```
  static String trArgs(String key, Map<String, String> args) {
    try {
      return _service.translateWithArgs(key, args);
    } catch (e) {
      Log.warning('Translation with args failed for key "$key": $e');
      return key;
    }
  }

  /// Get current language
  ///
  /// Returns the currently active language
  static Language get currentLanguage {
    try {
      return _service.currentLanguage;
    } catch (e) {
      Log.warning('Could not get current language: $e');
      return Language.english; // Fallback
    }
  }

  /// Change language
  ///
  /// Returns true if language change was successful
  static Future<bool> changeLanguage(Language language) async {
    try {
      return await _service.changeLanguage(language);
    } catch (e) {
      Log.error('Language change failed: $e');
      return false;
    }
  }

  /// Check if localization is initialized
  ///
  /// Returns true if the translation system is ready
  static bool get isInitialized {
    try {
      return _service.isInitialized;
    } catch (e) {
      Log.debug('Localization not initialized: $e');
      return false;
    }
  }

  /// Get supported languages
  ///
  /// Returns list of all supported languages
  static List<Language> get supportedLanguages {
    return Language.supportedLanguages;
  }

  /// Check if a language is supported
  ///
  /// Returns true if the language code is supported
  static bool isLanguageSupported(String languageCode) {
    return Language.isSupported(languageCode);
  }

  /// Get language from code
  ///
  /// Returns Language object or English as fallback
  static Language languageFromCode(String code) {
    return Language.fromCode(code);
  }

  /// Get cache information for debugging
  ///
  /// Returns translation service cache statistics
  static Map<String, dynamic> get cacheInfo {
    try {
      return _service.getCacheInfo();
    } catch (e) {
      Log.error('Could not get cache info: $e');
      return {'error': e.toString()};
    }
  }

  /// Clear translation cache
  ///
  /// Forces reload of translations
  static void clearCache() {
    try {
      _service.clearCache();
      Log.debug('Translation cache cleared via helpers');
    } catch (e) {
      Log.error('Failed to clear cache via helpers: $e');
    }
  }

  /// Debug method: List all available translation keys
  ///
  /// Returns all translation keys for the current language
  static List<String> get availableKeys {
    try {
      final translation = _service.currentTranslation;
      if (translation == null) return [];

      return translation.keys.toList()..sort();
    } catch (e) {
      Log.error('Could not get available keys: $e');
      return [];
    }
  }

  /// Debug method: Get translation statistics
  ///
  /// Returns information about the current translation state
  static Map<String, dynamic> get translationStats {
    try {
      final translation = _service.currentTranslation;
      if (translation == null) {
        return {
          'initialized': false,
          'current_language': currentLanguage.code,
          'translation_count': 0,
        };
      }

      return {
        'initialized': true,
        'current_language': currentLanguage.code,
        'translation_count': translation.count,
        'is_empty': translation.isEmpty,
        'version': translation.version,
        'supported_languages': supportedLanguages.map((l) => l.code).toList(),
      };
    } catch (e) {
      Log.error('Could not get translation stats: $e');
      return {'error': e.toString()};
    }
  }
}

// Convenience global functions for even easier access

/// Global translation function
///
/// Shorthand for LocalizationHelpers.tr()
String tr(String key) => LocalizationHelpers.tr(key);

/// Global translation with arguments function
///
/// Shorthand for LocalizationHelpers.trArgs()
String trArgs(String key, Map<String, String> args) =>
    LocalizationHelpers.trArgs(key, args);
