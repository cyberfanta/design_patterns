/// App Check Service Contract
///
/// PATTERN: Abstract Factory - App Check service interface
/// WHERE: Core Firebase contracts - App Check abstraction
/// HOW: Interface defining security validation operations with Either error handling
/// WHY: Allows multiple security implementations (Firebase App Check, custom validation, etc.)
library;

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../entities/app_check_token.dart';

/// Abstract contract for App Check security services
///
/// Tower Defense Context: Defines how security validation should work
/// for protecting educational resources and user data
abstract class AppCheckContract {
  /// Initialize App Check service
  Future<Either<Failure, void>> initialize();

  /// Get App Check token
  Future<Either<Failure, String>> getToken({bool forceRefresh = false});

  /// Set token auto refresh enabled
  Future<Either<Failure, void>> setTokenAutoRefreshEnabled(bool enabled);

  /// Enable or disable App Check
  Future<Either<Failure, void>> setAppCheckEnabled(bool enabled);

  /// Get current token status
  Future<Either<Failure, AppCheckTokenStatus>> getTokenStatus();
}
