/// Get Current Language Use Case - Clean Architecture Domain Layer
///
/// PATTERN: Command - Encapsulates language retrieval operation
/// WHERE: Domain layer use cases for language management
/// HOW: Single responsibility class with execute method
/// WHY: Separates business logic from UI and data layers
library;

import 'package:design_patterns/core/error/failures.dart';
import 'package:design_patterns/features/localization/domain/entities/language.dart';
import 'package:design_patterns/features/localization/domain/repositories/translation_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for retrieving the current active language
///
/// In the Tower Defense context, this ensures that all game elements
/// (tower names, enemy descriptions, UI text) are displayed in the
/// player's preferred language with proper fallback handling.
class GetCurrentLanguage {
  final TranslationRepository _repository;

  const GetCurrentLanguage(this._repository);

  /// Execute the use case to get current language
  ///
  /// Returns the user's preferred language or system default.
  /// Falls back to English if no preference is set or if there's an error.
  Future<Either<Failure, Language>> execute() async {
    try {
      // First try to get user's saved preference
      final result = await _repository.getCurrentLanguage();

      return result.fold(
        // If no saved preference, try to get system language
        (failure) async {
          final systemResult = await _repository.getSystemLanguage();

          return systemResult.fold(
            // If system language also fails, use English as fallback
            (systemFailure) => const Right(Language.english),
            (systemLanguage) {
              // Check if system language is supported
              return Language.isSupported(systemLanguage.code)
                  ? Right(systemLanguage)
                  : const Right(Language.english);
            },
          );
        },
        // Return saved preference if available
        (language) => Right(language),
      );
    } catch (e) {
      // Fallback to English on any unexpected error
      return const Right(Language.english);
    }
  }
}
