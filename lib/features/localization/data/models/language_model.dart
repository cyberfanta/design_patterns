/// Language Model - Clean Architecture Data Layer
///
/// PATTERN: Data Transfer Object (DTO) - Data layer representation
/// WHERE: Data layer for serialization/deserialization
/// HOW: Extends domain entity with JSON conversion methods
/// WHY: Separates data structure from business logic
library;

import 'package:design_patterns/features/localization/domain/entities/language.dart';

/// Data model for Language entity with JSON serialization
///
/// This model extends the domain Language entity to provide
/// JSON serialization capabilities for persistent storage
/// and API communication in the Tower Defense context.
class LanguageModel extends Language {
  const LanguageModel({
    required super.code,
    required super.name,
    required super.englishName,
    required super.flag,
    super.isSystemDefault,
  });

  /// Create LanguageModel from domain Language entity
  factory LanguageModel.fromEntity(Language language) {
    return LanguageModel(
      code: language.code,
      name: language.name,
      englishName: language.englishName,
      flag: language.flag,
      isSystemDefault: language.isSystemDefault,
    );
  }

  /// Create LanguageModel from JSON map
  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] as String? ?? 'en',
      name: json['name'] as String? ?? 'English',
      englishName: json['english_name'] as String? ?? 'English',
      flag: json['flag'] as String? ?? '🇺🇸',
      isSystemDefault: json['is_system_default'] as bool? ?? false,
    );
  }

  /// Convert LanguageModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'english_name': englishName,
      'flag': flag,
      'is_system_default': isSystemDefault,
    };
  }

  /// Convert to domain Language entity
  Language toEntity() {
    return Language(
      code: code,
      name: name,
      englishName: englishName,
      flag: flag,
      isSystemDefault: isSystemDefault,
    );
  }

  /// Create copy with modified properties
  @override
  LanguageModel copyWith({
    String? code,
    String? name,
    String? englishName,
    String? flag,
    bool? isSystemDefault,
  }) {
    return LanguageModel(
      code: code ?? this.code,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      flag: flag ?? this.flag,
      isSystemDefault: isSystemDefault ?? this.isSystemDefault,
    );
  }

  /// Predefined language models (data layer versions)
  static const LanguageModel englishModel = LanguageModel(
    code: 'en',
    name: 'English',
    englishName: 'English',
    flag: '🇺🇸',
  );

  static const LanguageModel spanishModel = LanguageModel(
    code: 'es',
    name: 'Español',
    englishName: 'Spanish',
    flag: '🇪🇸',
  );

  static const LanguageModel frenchModel = LanguageModel(
    code: 'fr',
    name: 'Français',
    englishName: 'French',
    flag: '🇫🇷',
  );

  static const LanguageModel germanModel = LanguageModel(
    code: 'de',
    name: 'Deutsch',
    englishName: 'German',
    flag: '🇩🇪',
  );

  static const List<LanguageModel> supportedLanguageModels = [
    englishModel,
    spanishModel,
    frenchModel,
    germanModel,
  ];

  /// Factory method to create LanguageModel from code
  static LanguageModel fromCode(String code) {
    try {
      return supportedLanguageModels.firstWhere(
        (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return englishModel; // Default to English
    }
  }

  @override
  String toString() => 'LanguageModel($code: $name)';
}
