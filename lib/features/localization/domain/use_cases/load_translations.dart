/// Load Translations Use Case - Clean Architecture Domain Layer
///
/// PATTERN: Command - Encapsulates translation loading operation
/// WHERE: Domain layer use cases for translation management
/// HOW: Single responsibility class with caching and error handling
/// WHY: Centralizes translation loading logic with performance optimization
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/localization/domain/entities/language.dart';
import 'package:design_patterns/features/localization/domain/entities/translation.dart';
import 'package:design_patterns/features/localization/domain/repositories/translation_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for loading translation data for a specific language
///
/// In the Tower Defense context, this loads all text translations for
/// game elements like tower names, enemy descriptions, UI buttons, and
/// game instructions in the player's selected language.
class LoadTranslations {
  final TranslationRepository _repository;

  const LoadTranslations(this._repository);

  /// Execute translation loading for a specific language
  ///
  /// Parameters:
  /// - [language]: The language to load translations for
  /// - [forceRefresh]: Whether to bypass cache and force reload
  ///
  /// Returns [Translation] object with all text mappings or [Failure]
  Future<Either<Failure, Translation>> execute(
    Language language, {
    bool forceRefresh = false,
  }) async {
    try {
      Log.debug('Loading translations for language: ${language.code}');

      // Validate language support before attempting to load
      final supportedResult = await _repository.isLanguageSupported(
        language.code,
      );

      final isSupported = supportedResult.fold((failure) {
        Log.warning('Could not verify language support: ${failure.toString()}');
        // Assume supported for fallback languages
        return Language.isSupported(language.code);
      }, (supported) => supported);

      if (!isSupported) {
        Log.error('Language not supported: ${language.code}');
        return Left(
          ValidationFailure(
            message: 'Language ${language.code} is not supported',
          ),
        );
      }

      // Clear cache if force refresh is requested
      if (forceRefresh) {
        Log.debug('Force refresh requested, clearing cache');
        await _repository.clearCache();
      }

      // Load translations from repository
      final result = await _repository.loadTranslations(language.code);

      return result.fold(
        (failure) {
          Log.error(
            'Failed to load translations for ${language.code}: ${failure.toString()}',
          );

          // If loading fails and it's not English, try to load English as fallback
          if (language.code != Language.english.code) {
            Log.debug('Attempting fallback to English translations');
            return _loadFallbackTranslations();
          }

          return Left(failure);
        },
        (translation) {
          Log.success(
            'Successfully loaded ${translation.count} translations for ${language.code}',
          );

          // Validate that essential translations exist
          if (!_validateEssentialTranslations(translation)) {
            Log.warning('Essential translations missing, loading fallback');
            return _loadFallbackTranslations();
          }

          return Right(translation);
        },
      );
    } catch (e) {
      Log.error('Unexpected error loading translations: $e');
      return Left(
        ServerFailure(message: 'Translation loading failed: ${e.toString()}'),
      );
    }
  }

  /// Load fallback English translations
  Future<Either<Failure, Translation>> _loadFallbackTranslations() async {
    try {
      Log.debug('Loading fallback English translations');
      return await _repository.loadTranslations(Language.english.code);
    } catch (e) {
      Log.error('Failed to load fallback translations: $e');
      return Left(
        ServerFailure(message: 'Could not load fallback translations'),
      );
    }
  }

  /// Validate that essential translations are present
  bool _validateEssentialTranslations(Translation translation) {
    // Essential keys for Tower Defense app
    const essentialKeys = [
      'app_name',
      'game_start',
      'game_over',
      'tower_archer',
      'tower_stone',
      'enemy_ant',
      'enemy_grasshopper',
      'enemy_cockroach',
      'build_tower',
      'upgrade_tower',
      'next_wave',
    ];

    for (final key in essentialKeys) {
      if (!translation.hasKey(key)) {
        Log.warning('Missing essential translation key: $key');
        return false;
      }
    }

    return true;
  }

  /// Preload translations for multiple languages
  ///
  /// Useful for background loading to improve performance
  Future<Either<Failure, List<Translation>>> preloadLanguages(
    List<Language> languages,
  ) async {
    try {
      Log.debug('Preloading translations for ${languages.length} languages');

      final languageCodes = languages.map((lang) => lang.code).toList();
      return await _repository.loadMultipleTranslations(languageCodes);
    } catch (e) {
      Log.error('Error preloading translations: $e');
      return Left(ServerFailure(message: 'Preload failed: ${e.toString()}'));
    }
  }
}
