/// Firebase Facades Index - Export all facade implementations
/// PATTERN: Facade Pattern - Centralized facade exports
/// WHERE: Firebase facades index - Single import point for all facades
/// HOW: Barrel exports for simplified facade access
/// WHY: Clean imports and centralized facade management
library;

// Import facades for registry
import 'error_handling_facade.dart';
import 'firebase_services_facade.dart';
import 'performance_operations_facade.dart';
import 'security_operations_facade.dart';
import 'tower_defense_firebase_facade.dart';

export 'error_handling_facade.dart';
export 'firebase_services_facade.dart';
export 'performance_operations_facade.dart';
export 'security_operations_facade.dart';
export 'tower_defense_firebase_facade.dart';

/// Firebase Facades Registry
/// Centralized access to all Firebase facades for the Tower Defense game
class FirebaseFacadesRegistry {
  /// Get Firebase Services Facade
  static FirebaseServicesFacade get services => FirebaseServicesFacade.instance;

  /// Get Tower Defense Firebase Facade
  static TowerDefenseFirebaseFacade get towerDefense =>
      TowerDefenseFirebaseFacade.instance;

  /// Get Security Operations Facade
  static SecurityOperationsFacade get security =>
      SecurityOperationsFacade.instance;

  /// Get Performance Operations Facade
  static PerformanceOperationsFacade get performance =>
      PerformanceOperationsFacade.instance;

  /// Get Error Handling Facade
  static ErrorHandlingFacade get errorHandling => ErrorHandlingFacade.instance;

  /// Initialize all facades
  static Future<void> initializeAll({
    bool enableAnalytics = true,
    bool enablePerformance = true,
    bool enableCrashlytics = true,
    bool enableAppCheck = true,
  }) async {
    // Initialize core services
    await services.initialize(
      enableAnalytics: enableAnalytics,
      enablePerformance: enablePerformance,
      enableCrashlytics: enableCrashlytics,
      enableAppCheck: enableAppCheck,
    );

    // Initialize error handling
    await errorHandling.initialize();
  }

  /// Dispose all facades
  static Future<void> disposeAll() async {
    await services.dispose();
    await errorHandling.dispose();
  }

  /// Get health status of all facades
  static Future<Map<String, dynamic>> getHealthStatus() async {
    return {
      'services': services.getServicesStatus(),
      'tower_defense': await towerDefense.getHealthStatus(),
      'security': await security.getSecurityStatus(),
      'performance': await performance.getPerformanceStatus(),
      'error_handling': errorHandling.getErrorStatistics(),
    };
  }
}
