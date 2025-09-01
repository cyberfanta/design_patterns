/// Extensions for Either type from fpdart
///
/// PATTERN: Extension Pattern - Adding functionality to existing types
/// WHERE: Used throughout the app for functional programming convenience
/// WHY: Provides convenient methods for working with Either< Failure, T >
library;

import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

typedef EitherFailure<T> = Either<Failure, T>;

extension EitherX<L, R> on Either<L, R> {
  /// Returns true if this is a Right value
  bool get isRight => fold((_) => false, (_) => true);

  /// Returns true if this is a Left value
  bool get isLeft => fold((_) => true, (_) => false);

  /// Maps the right value, keeping left unchanged
  Either<L, T> mapRight<T>(T Function(R) f) => map(f);

  /// Maps the left value, keeping right unchanged
  Either<T, R> mapLeft<T>(T Function(L) f) => mapLeft(f);
}

extension EitherFailureX<T> on EitherFailure<T> {
  /// Converts Either< Failure, T > to T or throws
  T get orThrow =>
      fold((failure) => throw Exception(failure.message), (value) => value);

  /// Returns the value or a default
  T getOrElse(T defaultValue) => fold((_) => defaultValue, (value) => value);

  /// Returns the failure or null
  Failure? get failureOrNull => fold((failure) => failure, (_) => null);
}
