/// Result Type for Error Handling
///
/// PATTERN: Monad Pattern - Represents success or failure
/// WHERE: Core utility for consistent error handling
/// HOW: Wraps operations that can succeed or fail
/// WHY: Provides type-safe error handling without exceptions
library;

/// A generic Result type that represents either a success or a failure
///
/// PATTERN: Monad Pattern - Functional error handling
///
/// Used throughout the application to handle operations that can fail
/// without throwing exceptions, providing a clean interface for
/// success/failure handling.
sealed class Result<TSuccess, TFailure> {
  const Result();

  /// Create a successful result
  static Result<TSuccess, TFailure> success<TSuccess, TFailure>(
    TSuccess value,
  ) {
    return Success<TSuccess, TFailure>(value);
  }

  /// Create a failure result
  static Result<TSuccess, TFailure> failure<TSuccess, TFailure>(
    TFailure error,
  ) {
    return Failure<TSuccess, TFailure>(error);
  }

  /// Check if this result is successful
  bool get isSuccess => this is Success<TSuccess, TFailure>;

  /// Check if this result is a failure
  bool get isFailure => this is Failure<TSuccess, TFailure>;

  /// Get the success value (throws if failure)
  TSuccess get value {
    if (this is Success<TSuccess, TFailure>) {
      return (this as Success<TSuccess, TFailure>).value;
    }
    throw StateError('Tried to get value from a failure result');
  }

  /// Get the failure error (throws if success)
  TFailure get error {
    if (this is Failure<TSuccess, TFailure>) {
      return (this as Failure<TSuccess, TFailure>).error;
    }
    throw StateError('Tried to get error from a success result');
  }

  /// Transform the result with fold pattern
  R fold<R>(
    R Function(TFailure failure) onFailure,
    R Function(TSuccess success) onSuccess,
  ) {
    return switch (this) {
      Success<TSuccess, TFailure>(:final value) => onSuccess(value),
      Failure<TSuccess, TFailure>(:final error) => onFailure(error),
    };
  }

  /// Map the success value to a new type
  Result<R, TFailure> map<R>(R Function(TSuccess value) mapper) {
    return fold(
      (failure) => Result.failure<R, TFailure>(failure),
      (success) => Result.success<R, TFailure>(mapper(success)),
    );
  }

  /// Map the failure value to a new type
  Result<TSuccess, R> mapError<R>(R Function(TFailure error) mapper) {
    return fold(
      (failure) => Result.failure<TSuccess, R>(mapper(failure)),
      (success) => Result.success<TSuccess, R>(success),
    );
  }

  /// Chain operations that return Results
  Result<R, TFailure> flatMap<R>(
    Result<R, TFailure> Function(TSuccess value) mapper,
  ) {
    return fold(
      (failure) => Result.failure<R, TFailure>(failure),
      (success) => mapper(success),
    );
  }

  /// Get the success value or a default
  TSuccess getOrElse(TSuccess defaultValue) {
    return fold((_) => defaultValue, (success) => success);
  }

  /// Get the success value or compute a default
  TSuccess getOrElseGet(TSuccess Function() defaultValueProvider) {
    return fold((_) => defaultValueProvider(), (success) => success);
  }

  @override
  String toString() {
    return fold(
      (failure) => 'Failure($failure)',
      (success) => 'Success($success)',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Result<TSuccess, TFailure> &&
        fold(
          (failure) => other.fold(
            (otherFailure) => failure == otherFailure,
            (_) => false,
          ),
          (success) => other.fold(
            (_) => false,
            (otherSuccess) => success == otherSuccess,
          ),
        );
  }

  @override
  int get hashCode =>
      fold((failure) => failure.hashCode, (success) => success.hashCode);
}

/// Success result implementation
final class Success<TSuccess, TFailure> extends Result<TSuccess, TFailure> {
  @override
  final TSuccess value;

  const Success(this.value);
}

/// Failure result implementation
final class Failure<TSuccess, TFailure> extends Result<TSuccess, TFailure> {
  @override
  final TFailure error;

  const Failure(this.error);
}
