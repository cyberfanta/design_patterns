/// Core failure definitions for error handling
///
/// PATTERN: Strategy Pattern - Different failure types with specific handling
/// WHERE: Used throughout all layers for consistent error management
/// WHY: Provides structured error handling with functional programming approach
library;

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String code;

  const Failure({required this.message, required this.code});

  @override
  List<Object> get props => [message, code];
}

// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection failed',
    super.code = 'NETWORK_ERROR',
  });
}

// Firebase-related failures
class FirebaseFailure extends Failure {
  const FirebaseFailure({
    required super.message,
    super.code = 'FIREBASE_ERROR',
  });
}

// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed',
    super.code = 'AUTH_ERROR',
  });
}

// Local database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code = 'DATABASE_ERROR',
  });
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
  });
}

// Pattern-specific failures
class PatternImplementationFailure extends Failure {
  const PatternImplementationFailure({
    required super.message,
    super.code = 'PATTERN_ERROR',
  });
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache operation failed',
    super.code = 'CACHE_ERROR',
  });
}

// Server failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code = 'SERVER_ERROR',
  });
}

// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code = 'NOT_FOUND_ERROR',
  });
}

// Technical failures
class TechnicalFailure extends Failure {
  const TechnicalFailure({
    required super.message,
    super.code = 'TECHNICAL_ERROR',
  });
}

// Security failures
class SecurityFailure extends Failure {
  const SecurityFailure({
    required super.message,
    super.code = 'SECURITY_ERROR',
  });
}
