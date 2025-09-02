/// Change Language Use Case - Clean Architecture Domain Layer
///
/// PATTERN: Command - Encapsulates language change operation
/// WHERE: Domain layer use cases for language management
/// HOW: Single responsibility class with parameters and execute method
/// WHY: Centralizes language change logic and triggers Observer notifications
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/patterns/behavioral/observer.dart';
import 'package:design_patterns/features/localization/domain/entities/language.dart';
import 'package:design_patterns/features/localization/domain/repositories/translation_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for changing the application language
///
/// In the Tower Defense context, this allows players to switch between
/// supported languages (English, Spanish, French, German) and ensures
/// all game elements update accordingly through Observer notifications.
class ChangeLanguage {
  final TranslationRepository _repository;
  final GameEventManager _eventManager;

  const ChangeLanguage(this._repository, this._eventManager);

  /// Execute the language change operation
  ///
  /// Parameters:
  /// - [newLanguage]: The language to switch to
  ///
  /// Returns success or failure of the language change operation.
  /// Triggers Observer notifications for UI updates.
  Future<Either<Failure, void>> execute(Language newLanguage) async {
    try {
      Log.debug('Attempting to change language to: ${newLanguage.code}');

      // Validate that the language is supported
      if (!Language.isSupported(newLanguage.code)) {
        Log.warning('Unsupported language code: ${newLanguage.code}');
        return Left(
          ValidationFailure(
            message: 'Unsupported language: ${newLanguage.code}',
          ),
        );
      }

      // Get current language for comparison
      final currentResult = await _repository.getCurrentLanguage();

      return currentResult.fold(
        (failure) async {
          // If can't get current language, proceed with change anyway
          Log.warning('Could not get current language, proceeding with change');
          return await _performLanguageChange(Language.english, newLanguage);
        },
        (currentLanguage) async {
          // Check if language is actually changing
          if (currentLanguage.code == newLanguage.code) {
            Log.debug('Language already set to ${newLanguage.code}');
            return const Right(null);
          }

          return await _performLanguageChange(currentLanguage, newLanguage);
        },
      );
    } catch (e) {
      Log.error('Unexpected error changing language: $e');
      return Left(
        ServerFailure(message: 'Failed to change language: ${e.toString()}'),
      );
    }
  }

  /// Perform the actual language change operation
  Future<Either<Failure, void>> _performLanguageChange(
    Language oldLanguage,
    Language newLanguage,
  ) async {
    try {
      // Check if translations are available for the new language
      final supportedResult = await _repository.isLanguageSupported(
        newLanguage.code,
      );

      final isSupported = supportedResult.fold((failure) {
        Log.warning('Could not verify language support, assuming supported');
        return true;
      }, (supported) => supported);

      if (!isSupported) {
        Log.error(
          'Translations not available for language: ${newLanguage.code}',
        );
        return Left(
          ValidationFailure(
            message: 'Translations not available for ${newLanguage.code}',
          ),
        );
      }

      // Save the new language preference
      final saveResult = await _repository.saveLanguagePreference(newLanguage);

      return saveResult.fold(
        (failure) {
          Log.error(
            'Failed to save language preference: ${failure.toString()}',
          );
          return Left(failure);
        },
        (_) {
          Log.success(
            'Successfully changed language from ${oldLanguage.code} to ${newLanguage.code}',
          );

          // PATTERN: Observer - Notify all observers about language change
          // This will trigger UI updates, audio language changes, etc.
          _eventManager.languageChanged(oldLanguage.code, newLanguage.code);

          return const Right(null);
        },
      );
    } catch (e) {
      Log.error('Error performing language change: $e');
      return Left(
        ServerFailure(message: 'Language change failed: ${e.toString()}'),
      );
    }
  }
}
