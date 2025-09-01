/// Language Entity - Clean Architecture Domain Layer
///
/// PATTERN: Value Object - Immutable language representation
/// WHERE: Domain layer for language management
/// HOW: Immutable class with validation and equality
/// WHY: Ensures data integrity and business rules for languages
library;

import 'package:equatable/equatable.dart';

/// Represents a supported language in the application
///
/// This entity encapsulates all language-related information following
/// the Tower Defense context where players from different countries
/// can enjoy the game in their native language.
class Language extends Equatable {
  /// Language code (ISO 639-1 format)
  final String code;

  /// Display name in the language itself
  final String name;

  /// Display name in English for reference
  final String englishName;

  /// Flag emoji or country code for UI display
  final String flag;

  /// Whether this is the system's detected language
  final bool isSystemDefault;

  const Language({
    required this.code,
    required this.name,
    required this.englishName,
    required this.flag,
    this.isSystemDefault = false,
  });

  /// Predefined supported languages for the Tower Defense app
  static const Language english = Language(
    code: 'en',
    name: 'English',
    englishName: 'English',
    flag: '🇺🇸',
  );

  static const Language spanish = Language(
    code: 'es',
    name: 'Español',
    englishName: 'Spanish',
    flag: '🇪🇸',
  );

  static const Language french = Language(
    code: 'fr',
    name: 'Français',
    englishName: 'French',
    flag: '🇫🇷',
  );

  static const Language german = Language(
    code: 'de',
    name: 'Deutsch',
    englishName: 'German',
    flag: '🇩🇪',
  );

  /// List of all supported languages
  static const List<Language> supportedLanguages = [
    english,
    spanish,
    french,
    german,
  ];

  /// Factory method to create Language from code
  static Language fromCode(String code) {
    try {
      return supportedLanguages.firstWhere(
        (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      // Default to English if language not supported
      return english;
    }
  }

  /// Check if language code is supported
  static bool isSupported(String code) {
    return supportedLanguages.any(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
    );
  }

  /// Create copy with modified properties
  Language copyWith({
    String? code,
    String? name,
    String? englishName,
    String? flag,
    bool? isSystemDefault,
  }) {
    return Language(
      code: code ?? this.code,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      flag: flag ?? this.flag,
      isSystemDefault: isSystemDefault ?? this.isSystemDefault,
    );
  }

  @override
  List<Object> get props => [code, name, englishName, flag, isSystemDefault];

  @override
  String toString() => 'Language($code: $name)';
}
