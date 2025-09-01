/// Configuration Feature Export - Clean Architecture
///
/// PATTERN: Facade - Simplified interface to configuration subsystem
/// WHERE: Feature-level public API
/// HOW: Single export file for all configuration functionality
/// WHY: Provides clean, organized access to configuration capabilities
library;

// Public convenience methods for easy access
export 'config_helpers.dart';
// Dependency Injection
export 'config_injection.dart';
// Data Models
export 'data/models/app_config_model.dart';
// Domain Entities
export 'domain/entities/app_config.dart';
// Domain Repositories (Contracts)
export 'domain/repositories/config_repository.dart';
// Domain Services (Singleton + Observer + Memento)
export 'domain/services/config_service.dart';
// Domain Use Cases
export 'domain/usecases/get_config.dart';
export 'domain/usecases/reset_config.dart';
export 'domain/usecases/save_config.dart';
