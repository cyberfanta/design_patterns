/// Translation Repository Contract - Clean Architecture Domain Layer
///
/// PATTERN: Repository - Abstract interface for translation data access
/// WHERE: Domain layer defining contracts for data access
/// HOW: Abstract class with async methods for translation operations
/// WHY: Decouples business logic from data sources, enables testing
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/features/localization/domain/entities/language.dart';
import 'package:design_patterns/features/localization/domain/entities/translation.dart';
import 'package:fpdart/fpdart.dart';

/// Abstract repository for managing translation data
///
/// This contract defines how the domain layer interacts with translation
/// data sources, following the Tower Defense context where players need
/// multilingual support for game instructions and UI elements.
abstract class TranslationRepository {
  /// Load translations for a specific language
  ///
  /// Returns [Translation] with all available translations for the language
  /// or [Failure] if loading fails
  Future<Either<Failure, Translation>> loadTranslations(String languageCode);

  /// Load translations for multiple languages
  ///
  /// Useful for preloading or background loading of translation data
  Future<Either<Failure, List<Translation>>> loadMultipleTranslations(
    List<String> languageCodes,
  );

  /// Get the system's detected language
  ///
  /// Returns the device's current language setting
  Future<Either<Failure, Language>> getSystemLanguage();

  /// Get currently selected/saved language preference
  ///
  /// Returns the user's chosen language or system default
  Future<Either<Failure, Language>> getCurrentLanguage();

  /// Save user's language preference
  ///
  /// Persists the selected language for future app sessions
  Future<Either<Failure, void>> saveLanguagePreference(Language language);

  /// Check if translations are available for a language
  ///
  /// Useful for validating language support before loading
  Future<Either<Failure, bool>> isLanguageSupported(String languageCode);

  /// Get all available/supported languages
  ///
  /// Returns list of languages that have translation data available
  Future<Either<Failure, List<Language>>> getSupportedLanguages();

  /// Clear cached translation data
  ///
  /// Forces reload of translations on next access
  Future<Either<Failure, void>> clearCache();

  /// Update translation cache with new data
  ///
  /// Used for updating translations without app restart
  Future<Either<Failure, void>> updateTranslationCache(
    String languageCode,
    Translation translation,
  );
}
