/// Translation Repository Implementation - Clean Architecture Data Layer
///
/// PATTERN: Repository - Concrete implementation of translation data access
/// WHERE: Data layer implementing domain repository contract
/// HOW: Coordinates between datasources and converts models to entities
/// WHY: Centralizes data access logic and maintains clean boundaries
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/features/localization/data/data_sources/local_translation_datasource.dart';
import 'package:design_patterns/features/localization/data/models/language_model.dart';
import 'package:design_patterns/features/localization/data/models/translation_model.dart';
import 'package:design_patterns/features/localization/domain/entities/language.dart';
import 'package:design_patterns/features/localization/domain/entities/translation.dart';
import 'package:design_patterns/features/localization/domain/repositories/translation_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Concrete implementation of TranslationRepository
///
/// PATTERN: Repository - Implements domain repository interface
/// Coordinates between local datasource and domain layer,
/// providing translation data for the Tower Defense multilingual system.
class TranslationRepositoryImpl implements TranslationRepository {
  final LocalTranslationDataSource _localDataSource;

  const TranslationRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, Translation>> loadTranslations(
    String languageCode,
  ) async {
    try {
      Log.debug('Repository: Loading translations for $languageCode');

      final translationModel = await _localDataSource.loadTranslation(
        languageCode,
      );

      if (translationModel == null) {
        Log.warning('No translation data found for $languageCode');
        return Left(
          NotFoundFailure(
            message: 'Translation not found for language: $languageCode',
          ),
        );
      }

      if (!translationModel.isValid()) {
        Log.error('Invalid translation data for $languageCode');
        return Left(
          ValidationFailure(
            message: 'Invalid translation data for $languageCode',
          ),
        );
      }

      final translation = translationModel.toEntity();
      Log.success(
        'Repository: Loaded ${translation.count} translations for $languageCode',
      );

      return Right(translation);
    } catch (e) {
      Log.error('Repository: Error loading translations for $languageCode: $e');
      return Left(
        ServerFailure(message: 'Failed to load translations: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Translation>>> loadMultipleTranslations(
    List<String> languageCodes,
  ) async {
    try {
      Log.debug(
        'Repository: Loading translations for ${languageCodes.length} languages',
      );

      final translations = <Translation>[];
      final failures = <String>[];

      for (final languageCode in languageCodes) {
        final result = await loadTranslations(languageCode);

        result.fold(
          (failure) => failures.add('$languageCode: ${failure.toString()}'),
          (translation) => translations.add(translation),
        );
      }

      if (translations.isEmpty) {
        Log.error('No translations loaded successfully');
        return Left(
          ServerFailure(
            message: 'Failed to load any translations: ${failures.join(', ')}',
          ),
        );
      }

      Log.success(
        'Repository: Loaded translations for ${translations.length}/${languageCodes.length} languages',
      );
      return Right(translations);
    } catch (e) {
      Log.error('Repository: Error loading multiple translations: $e');
      return Left(
        ServerFailure(message: 'Failed to load translations: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Language>> getSystemLanguage() async {
    try {
      Log.debug('Repository: Getting system language');

      final languageModel = await _localDataSource.getSystemLanguage();
      final language = languageModel.toEntity();

      Log.success('Repository: System language detected: ${language.code}');
      return Right(language);
    } catch (e) {
      Log.error('Repository: Error getting system language: $e');
      return Left(
        ServerFailure(
          message: 'Failed to detect system language: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Language>> getCurrentLanguage() async {
    try {
      Log.debug('Repository: Getting current language preference');

      final languageModel = await _localDataSource.getLanguagePreference();

      if (languageModel == null) {
        // No saved preference, try to get system language
        Log.debug('No saved preference, checking system language');
        return await getSystemLanguage();
      }

      final language = languageModel.toEntity();
      Log.success('Repository: Current language preference: ${language.code}');

      return Right(language);
    } catch (e) {
      Log.error('Repository: Error getting current language: $e');
      return Left(
        ServerFailure(
          message: 'Failed to get current language: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveLanguagePreference(
    Language language,
  ) async {
    try {
      Log.debug('Repository: Saving language preference: ${language.code}');

      final languageModel = LanguageModel.fromEntity(language);
      await _localDataSource.saveLanguagePreference(languageModel);

      Log.success('Repository: Language preference saved: ${language.code}');
      return const Right(null);
    } catch (e) {
      Log.error('Repository: Error saving language preference: $e');
      return Left(
        ServerFailure(
          message: 'Failed to save language preference: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isLanguageSupported(String languageCode) async {
    try {
      Log.debug('Repository: Checking if language is supported: $languageCode');

      final isSupported = await _localDataSource.hasTranslation(languageCode);

      Log.debug('Repository: Language $languageCode supported: $isSupported');
      return Right(isSupported);
    } catch (e) {
      Log.error('Repository: Error checking language support: $e');
      return Left(
        ServerFailure(
          message: 'Failed to check language support: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Language>>> getSupportedLanguages() async {
    try {
      Log.debug('Repository: Getting supported languages');

      final languages = LanguageModel.supportedLanguageModels
          .map((model) => model.toEntity())
          .toList();

      Log.success('Repository: Found ${languages.length} supported languages');
      return Right(languages);
    } catch (e) {
      Log.error('Repository: Error getting supported languages: $e');
      return Left(
        ServerFailure(
          message: 'Failed to get supported languages: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      Log.debug('Repository: Clearing translation cache');

      await _localDataSource.clearAllTranslations();

      Log.success('Repository: Translation cache cleared');
      return const Right(null);
    } catch (e) {
      Log.error('Repository: Error clearing cache: $e');
      return Left(
        ServerFailure(message: 'Failed to clear cache: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateTranslationCache(
    String languageCode,
    Translation translation,
  ) async {
    try {
      Log.debug('Repository: Updating translation cache for $languageCode');

      final translationModel = TranslationModel.fromEntity(translation);
      await _localDataSource.updateTranslation(languageCode, translationModel);

      Log.success('Repository: Translation cache updated for $languageCode');
      return const Right(null);
    } catch (e) {
      Log.error('Repository: Error updating translation cache: $e');
      return Left(
        ServerFailure(message: 'Failed to update cache: ${e.toString()}'),
      );
    }
  }

  /// Get cache information and statistics
  ///
  /// Additional method for debugging and monitoring cache performance
  Future<Either<Failure, Map<String, dynamic>>> getCacheInfo() async {
    try {
      Log.debug('Repository: Getting cache information');

      final cacheInfo = await _localDataSource.getCacheInfo();

      Log.debug('Repository: Cache info retrieved');
      return Right(cacheInfo);
    } catch (e) {
      Log.error('Repository: Error getting cache info: $e');
      return Left(
        ServerFailure(message: 'Failed to get cache info: ${e.toString()}'),
      );
    }
  }

  /// Check if local storage is available
  ///
  /// Additional method to verify storage capabilities
  Future<Either<Failure, bool>> checkStorageAvailability() async {
    try {
      Log.debug('Repository: Checking storage availability');

      final isAvailable = await _localDataSource.isStorageAvailable();

      Log.debug('Repository: Storage available: $isAvailable');
      return Right(isAvailable);
    } catch (e) {
      Log.error('Repository: Error checking storage availability: $e');
      return Left(
        ServerFailure(message: 'Failed to check storage: ${e.toString()}'),
      );
    }
  }

  /// Get cached languages list
  ///
  /// Additional method for cache management
  Future<Either<Failure, List<String>>> getCachedLanguages() async {
    try {
      Log.debug('Repository: Getting cached languages');

      final cachedLanguages = await _localDataSource.getCachedLanguages();

      Log.debug('Repository: Found ${cachedLanguages.length} cached languages');
      return Right(cachedLanguages);
    } catch (e) {
      Log.error('Repository: Error getting cached languages: $e');
      return Left(
        ServerFailure(
          message: 'Failed to get cached languages: ${e.toString()}',
        ),
      );
    }
  }
}
