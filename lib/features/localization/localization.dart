/// Localization Feature Export - Clean Architecture
///
/// PATTERN: Facade - Simplified interface to localization subsystem
/// WHERE: Feature-level public API
/// HOW: Single export file for all localization functionality
/// WHY: Provides clean, organized access to multilingual capabilities
library;

// Data Models
export 'data/models/language_model.dart';
export 'data/models/translation_model.dart';
// Domain Entities
export 'domain/entities/language.dart';
export 'domain/entities/translation.dart';
// Domain Repositories (Contracts)
export 'domain/repositories/translation_repository.dart';
// Domain Services (Singleton + Observer + Memento)
export 'domain/services/translation_service.dart';
export 'domain/usecases/change_language.dart';
// Domain Use Cases
export 'domain/usecases/get_current_language.dart';
export 'domain/usecases/load_translations.dart';
// Public convenience methods for easy access
export 'localization_helpers.dart';
// Dependency Injection
export 'localization_injection.dart';
