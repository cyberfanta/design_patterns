/// Performance Monitoring Service Contract
///
/// PATTERN: Abstract Factory - Performance monitoring interface
/// WHERE: Core Firebase contracts - Performance abstraction
/// HOW: Interface defining performance monitoring operations with Either error handling
/// WHY: Allows multiple performance implementations (Firebase, custom analytics, etc.)
library;

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';

/// Abstract contract for performance monitoring services
///
/// Tower Defense Context: Defines how performance monitoring should work
/// for educational game optimization and user experience improvement
abstract class PerformanceContract {
  /// Initialize performance monitoring service
  Future<Either<Failure, void>> initialize();

  /// Enable or disable performance collection
  Future<Either<Failure, void>> setPerformanceEnabled(bool enabled);

  /// Start a performance trace
  Future<Either<Failure, String>> startTrace(String traceName);

  /// Stop a performance trace
  Future<Either<Failure, void>> stopTrace(String traceName);

  /// Add a metric value to an active trace
  Future<Either<Failure, void>> putMetric({
    required String traceName,
    required String metricName,
    required int value,
  });

  /// Set a custom attribute on an active trace
  Future<Either<Failure, void>> putAttribute({
    required String traceName,
    required String attributeName,
    required String attributeValue,
  });

  /// Measure execution time of a function
  Future<Either<Failure, T>> measureExecution<T>({
    required String traceName,
    required Future<T> Function() operation,
    Map<String, String>? attributes,
  });
}
