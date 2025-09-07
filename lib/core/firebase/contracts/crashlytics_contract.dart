/// Crashlytics Service Contract
///
/// PATTERN: Abstract Factory - Crashlytics service interface
/// WHERE: Core Firebase contracts - Crashlytics abstraction
/// HOW: Interface defining crash reporting operations with Either error handling
/// WHY: Allows multiple crash reporting implementations (Firebase, custom, etc.)
library;

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';

/// Abstract contract for crashlytics services
///
/// Tower Defense Context: Defines how crash reporting should work
/// for educational game debugging and stability improvement
abstract class CrashlyticsContract {
  /// Initialize crashlytics service
  Future<Either<Failure, void>> initialize();

  /// Enable or disable crashlytics collection
  Future<Either<Failure, void>> setCrashlyticsEnabled(bool enabled);

  /// Record a custom error
  Future<Either<Failure, void>> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? context,
  });

  /// Log a custom message
  Future<Either<Failure, void>> log(String message);

  /// Set user identifier for crash reports
  Future<Either<Failure, void>> setUserIdentifier(String identifier);

  /// Set custom key-value pair for crash reports
  Future<Either<Failure, void>> setCustomKey({
    required String key,
    required dynamic value,
  });

  /// Force a crash for testing purposes
  Future<Either<Failure, void>> testCrash();

  /// Check if crashlytics collection is enabled
  Future<Either<Failure, bool>> isCrashlyticsCollectionEnabled();

  /// Send unsent crash reports
  Future<Either<Failure, void>> sendUnsentReports();

  /// Delete unsent crash reports
  Future<Either<Failure, void>> deleteUnsentReports();
}
