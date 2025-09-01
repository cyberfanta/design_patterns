/// Translation Entity - Clean Architecture Domain Layer
///
/// PATTERN: Value Object - Immutable translation representation
/// WHERE: Domain layer for translation management
/// HOW: Immutable class with key-value mapping
/// WHY: Ensures translation integrity and supports missing key handling
library;

import 'package:equatable/equatable.dart';

/// Represents a translation entry for a specific language
///
/// Each translation contains a mapping of translation keys to their
/// respective values in a specific language. Used in the Tower Defense
/// context to provide multilingual support for game elements.
class Translation extends Equatable {
  /// Language code this translation belongs to
  final String languageCode;

  /// Map of translation keys to translated text
  final Map<String, String> translations;

  /// Version or timestamp for cache invalidation
  final String version;

  const Translation({
    required this.languageCode,
    required this.translations,
    required this.version,
  });

  /// Get translation for a specific key
  /// Returns the key itself if translation is not found (fallback)
  String translate(String key) {
    return translations[key] ?? key;
  }

  /// Check if a translation key exists
  bool hasKey(String key) {
    return translations.containsKey(key);
  }

  /// Get all translation keys
  Set<String> get keys => translations.keys.toSet();

  /// Count of available translations
  int get count => translations.length;

  /// Check if translation set is empty
  bool get isEmpty => translations.isEmpty;

  /// Create copy with additional or updated translations
  Translation copyWith({
    String? languageCode,
    Map<String, String>? translations,
    String? version,
  }) {
    return Translation(
      languageCode: languageCode ?? this.languageCode,
      translations: {...this.translations, ...?translations},
      version: version ?? this.version,
    );
  }

  /// Merge with another translation (other takes precedence)
  Translation merge(Translation other) {
    assert(
      languageCode == other.languageCode,
      'Cannot merge translations from different languages',
    );

    return Translation(
      languageCode: languageCode,
      translations: {...translations, ...other.translations},
      version: other.version,
    );
  }

  @override
  List<Object> get props => [languageCode, translations, version];

  @override
  String toString() =>
      'Translation($languageCode: ${translations.length} keys)';
}
