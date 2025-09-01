/// Translation Model - Clean Architecture Data Layer
///
/// PATTERN: Data Transfer Object (DTO) - Data layer representation
/// WHERE: Data layer for JSON serialization and caching
/// HOW: Extends domain entity with persistence capabilities
/// WHY: Handles data format conversion and storage requirements
library;

import 'package:design_patterns/features/localization/domain/entities/translation.dart';

/// Data model for Translation entity with JSON serialization
///
/// This model extends the domain Translation entity to provide
/// JSON serialization capabilities for local storage and caching
/// in the Tower Defense multilingual system.
class TranslationModel extends Translation {
  const TranslationModel({
    required super.languageCode,
    required super.translations,
    required super.version,
  });

  /// Create TranslationModel from domain Translation entity
  factory TranslationModel.fromEntity(Translation translation) {
    return TranslationModel(
      languageCode: translation.languageCode,
      translations: Map.from(translation.translations),
      version: translation.version,
    );
  }

  /// Create TranslationModel from JSON map
  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    final translationsData =
        json['translations'] as Map<String, dynamic>? ?? {};
    final translations = <String, String>{};

    // Convert all values to strings
    for (final entry in translationsData.entries) {
      translations[entry.key] = entry.value.toString();
    }

    return TranslationModel(
      languageCode: json['language_code'] as String? ?? 'en',
      translations: translations,
      version: json['version'] as String? ?? '1.0.0',
    );
  }

  /// Convert TranslationModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'language_code': languageCode,
      'translations': translations,
      'version': version,
      'count': count,
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Convert to domain Translation entity
  Translation toEntity() {
    return Translation(
      languageCode: languageCode,
      translations: Map.from(translations),
      version: version,
    );
  }

  /// Create copy with additional or updated translations
  @override
  TranslationModel copyWith({
    String? languageCode,
    Map<String, String>? translations,
    String? version,
  }) {
    return TranslationModel(
      languageCode: languageCode ?? this.languageCode,
      translations: {...this.translations, ...?translations},
      version: version ?? this.version,
    );
  }

  /// Merge with another translation
  @override
  TranslationModel merge(Translation other) {
    assert(
      languageCode == other.languageCode,
      'Cannot merge translations from different languages',
    );

    return TranslationModel(
      languageCode: languageCode,
      translations: {...translations, ...other.translations},
      version: other.version,
    );
  }

  /// Merge with another translation model (specific for data layer)
  TranslationModel mergeModel(TranslationModel other) {
    return merge(other);
  }

  /// Validate translation model structure
  bool isValid() {
    return languageCode.isNotEmpty &&
        version.isNotEmpty &&
        translations.isNotEmpty;
  }

  /// Get translation statistics
  Map<String, dynamic> getStatistics() {
    return {
      'language_code': languageCode,
      'total_keys': count,
      'version': version,
      'is_empty': isEmpty,
      'longest_key': _getLongestKey(),
      'longest_value': _getLongestValue(),
      'average_value_length': _getAverageValueLength(),
    };
  }

  /// Get the longest translation key
  String? _getLongestKey() {
    if (isEmpty) return null;

    return keys.reduce((a, b) => a.length > b.length ? a : b);
  }

  /// Get the longest translation value
  String? _getLongestValue() {
    if (isEmpty) return null;

    return translations.values.reduce((a, b) => a.length > b.length ? a : b);
  }

  /// Calculate average value length
  double _getAverageValueLength() {
    if (isEmpty) return 0.0;

    final totalLength = translations.values.fold<int>(
      0,
      (sum, value) => sum + value.length,
    );
    return totalLength / count;
  }

  @override
  String toString() =>
      'TranslationModel($languageCode: $count keys, v$version)';
}
