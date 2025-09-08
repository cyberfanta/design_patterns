/// PATTERN: Facade Pattern - Performance operations simplification
/// WHERE: Performance facade - Simplified performance monitoring interface
/// HOW: Single interface for complex performance decorator operations
/// WHY: Abstract performance monitoring complexity and provide convenient methods
library;

import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../patterns/performance_decorator_pattern.dart';
import '../services/performance_service.dart';

/// Performance Operations Facade
/// Tower Defense Context: Simplified performance monitoring for educational game
class PerformanceOperationsFacade {
  PerformanceOperationsFacade._();

  static PerformanceOperationsFacade? _instance;

  /// PATTERN: Singleton - Single performance facade instance
  static PerformanceOperationsFacade get instance {
    _instance ??= PerformanceOperationsFacade._();
    return _instance!;
  }

  final FirebasePerformanceService _performanceService =
      FirebasePerformanceService.instance;

  /// Create execution time decorator for operation monitoring
  ExecutionTimeDecorator<T> createExecutionTimeDecorator<T>({
    required PerformanceComponent<T> component,
    required String operationName,
    String category = 'general',
    Map<String, dynamic> context = const {},
  }) {
    return ExecutionTimeDecorator<T>(
      component: component,
      operationName: operationName,
      category: category,
      context: context,
    );
  }

  /// Create memory usage decorator for memory monitoring
  MemoryUsageDecorator<T> createMemoryUsageDecorator<T>({
    required PerformanceComponent<T> component,
    required String operationName,
    bool trackPeakUsage = false,
  }) {
    return MemoryUsageDecorator<T>(
      component: component,
      operationName: operationName,
      trackPeakUsage: trackPeakUsage,
    );
  }

  /// Create error rate decorator for reliability monitoring
  ErrorRateDecorator<T> createErrorRateDecorator<T>({
    required PerformanceComponent<T> component,
    required String operationName,
    String category = 'reliability',
  }) {
    return ErrorRateDecorator<T>(
      component: component,
      operationName: operationName,
      category: category,
    );
  }

  /// Create cache performance decorator for cache monitoring
  CachePerformanceDecorator<T> createCachePerformanceDecorator<T>({
    required PerformanceComponent<T> component,
    required String operationName,
    required String cacheKey,
  }) {
    return CachePerformanceDecorator<T>(
      component: component,
      operationName: operationName,
      cacheKey: cacheKey,
    );
  }

  /// Measure pattern loading performance
  Future<Either<Failure, T>> measurePatternLoading<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String patternName,
    required String category,
  }) async {
    try {
      Log.debug(
        'PerformanceOperationsFacade: Measuring pattern loading: $patternName',
      );

      final traceName = 'pattern_loading_$patternName';
      return await _performanceService.measureExecution<T>(
        traceName: traceName,
        operation: () async {
          final result = await operation();
          return result.fold((l) => throw Exception(l.message), (r) => r);
        },
        attributes: {
          'pattern_name': patternName,
          'pattern_category': category,
          'operation_type': 'educational_content_loading',
        },
      );
    } catch (e) {
      Log.error(
        'PerformanceOperationsFacade: Failed to measure pattern loading: $e',
      );
      return Left(
        TechnicalFailure(message: 'Pattern loading measurement failed: $e'),
      );
    }
  }

  /// Measure game session performance
  Future<Either<Failure, T>> measureGameSession<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String sessionType,
    Map<String, String>? additionalAttributes,
  }) async {
    try {
      Log.debug(
        'PerformanceOperationsFacade: Measuring game session: $sessionType',
      );

      final traceName = 'game_session_$sessionType';
      return await _performanceService.measureExecution<T>(
        traceName: traceName,
        operation: () async {
          final result = await operation();
          return result.fold((l) => throw Exception(l.message), (r) => r);
        },
        attributes: {
          'session_type': sessionType,
          'game_context': 'tower_defense_educational',
          ...?additionalAttributes,
        },
      );
    } catch (e) {
      Log.error(
        'PerformanceOperationsFacade: Failed to measure game session: $e',
      );
      return Left(
        TechnicalFailure(message: 'Game session measurement failed: $e'),
      );
    }
  }

  /// Measure UI rendering performance
  Future<Either<Failure, T>> measureUIRendering<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String screenName,
    required String componentType,
  }) async {
    try {
      Log.debug(
        'PerformanceOperationsFacade: Measuring UI rendering: $screenName/$componentType',
      );

      final traceName = 'ui_rendering_${screenName}_$componentType';
      return await _performanceService.measureExecution<T>(
        traceName: traceName,
        operation: () async {
          final result = await operation();
          return result.fold((l) => throw Exception(l.message), (r) => r);
        },
        attributes: {
          'screen_name': screenName,
          'component_type': componentType,
          'ui_framework': 'flutter',
          'rendering_context': 'educational_ui',
        },
      );
    } catch (e) {
      Log.error(
        'PerformanceOperationsFacade: Failed to measure UI rendering: $e',
      );
      return Left(
        TechnicalFailure(message: 'UI rendering measurement failed: $e'),
      );
    }
  }

  /// Measure data processing performance
  Future<Either<Failure, T>> measureDataProcessing<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String dataType,
    required String processingType,
    int? dataSize,
  }) async {
    try {
      Log.debug(
        'PerformanceOperationsFacade: Measuring data processing: $dataType/$processingType',
      );

      final traceName = 'data_processing_${dataType}_$processingType';
      return await _performanceService.measureExecution<T>(
        traceName: traceName,
        operation: () async {
          final result = await operation();
          return result.fold((l) => throw Exception(l.message), (r) => r);
        },
        attributes: {
          'data_type': dataType,
          'processing_type': processingType,
          'educational_context': 'pattern_analysis',
          if (dataSize != null) 'data_size_bytes': dataSize.toString(),
        },
      );
    } catch (e) {
      Log.error(
        'PerformanceOperationsFacade: Failed to measure data processing: $e',
      );
      return Left(
        TechnicalFailure(message: 'Data processing measurement failed: $e'),
      );
    }
  }

  /// Get error rate statistics for all operations
  Map<String, double> getErrorRateStatistics() {
    try {
      return ErrorRateDecorator.getErrorRateStats();
    } catch (e) {
      Log.error(
        'PerformanceOperationsFacade: Failed to get error rate statistics: $e',
      );
      return <String, double>{};
    }
  }

  /// Get performance insights for educational content
  Map<String, dynamic> getEducationalPerformanceInsights() {
    try {
      final errorStats = getErrorRateStatistics();

      return {
        'timestamp': DateTime.now().toIso8601String(),
        'performance_monitoring': 'active',
        'educational_context': 'tower_defense_patterns',
        'error_rates': errorStats,
        'monitored_operations': {
          'pattern_loading': 'active',
          'ui_rendering': 'active',
          'data_processing': 'active',
          'game_sessions': 'active',
        },
        'optimization_recommendations': _generateOptimizationRecommendations(
          errorStats,
        ),
      };
    } catch (e) {
      Log.error(
        'PerformanceOperationsFacade: Failed to get performance insights: $e',
      );
      return {
        'error': 'Failed to generate performance insights',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Start custom performance trace
  Future<Either<Failure, String>> startCustomTrace({
    required String traceName,
    required String operation,
    Map<String, String>? metadata,
  }) async {
    try {
      Log.debug(
        'PerformanceOperationsFacade: Starting custom trace: $traceName',
      );

      final fullTraceName =
          'tower_defense_custom_${traceName}_${DateTime.now().millisecondsSinceEpoch}';
      final result = await _performanceService.startTrace(fullTraceName);

      // Add metadata attributes if provided
      if (result.isRight() && metadata != null) {
        for (final entry in metadata.entries) {
          await _performanceService.putAttribute(
            traceName: fullTraceName,
            attributeName: entry.key,
            attributeValue: entry.value,
          );
        }
      }

      return result;
    } catch (e) {
      Log.error(
        'PerformanceOperationsFacade: Failed to start custom trace: $e',
      );
      return Left(TechnicalFailure(message: 'Custom trace start failed: $e'));
    }
  }

  /// Stop custom performance trace
  Future<Either<Failure, void>> stopCustomTrace(String traceName) async {
    try {
      Log.debug(
        'PerformanceOperationsFacade: Stopping custom trace: $traceName',
      );

      return await _performanceService.stopTrace(traceName);
    } catch (e) {
      Log.error('PerformanceOperationsFacade: Failed to stop custom trace: $e');
      return Left(TechnicalFailure(message: 'Custom trace stop failed: $e'));
    }
  }

  /// Add metric to active trace
  Future<Either<Failure, void>> addTraceMetric({
    required String traceName,
    required String metricName,
    required int value,
  }) async {
    try {
      return await _performanceService.putMetric(
        traceName: traceName,
        metricName: metricName,
        value: value,
      );
    } catch (e) {
      Log.error('PerformanceOperationsFacade: Failed to add trace metric: $e');
      return Left(
        TechnicalFailure(message: 'Trace metric addition failed: $e'),
      );
    }
  }

  /// Generate optimization recommendations based on performance data
  List<String> _generateOptimizationRecommendations(
    Map<String, double> errorStats,
  ) {
    final recommendations = <String>[];

    for (final entry in errorStats.entries) {
      final operationName = entry.key;
      final errorRate = entry.value;

      if (errorRate > 0.1) {
        // > 10% error rate
        recommendations.add(
          'High error rate (${(errorRate * 100).toStringAsFixed(1)}%) detected in $operationName - investigate and optimize',
        );
      } else if (errorRate > 0.05) {
        // > 5% error rate
        recommendations.add(
          'Moderate error rate (${(errorRate * 100).toStringAsFixed(1)}%) in $operationName - monitor closely',
        );
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'All operations performing within acceptable error rates',
      );
    }

    // Add educational-specific recommendations
    recommendations.add(
      'Consider pattern loading caching for frequently accessed content',
    );
    recommendations.add(
      'Monitor UI rendering performance during pattern transitions',
    );
    recommendations.add('Optimize data processing for large pattern sets');

    return recommendations;
  }

  /// Get comprehensive performance status
  Future<Map<String, dynamic>> getPerformanceStatus() async {
    try {
      return {
        'facade_initialized': true,
        'performance_service_available': true,
        'monitoring_active': true,
        'error_statistics': getErrorRateStatistics(),
        'educational_insights': getEducationalPerformanceInsights(),
        'last_check': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'facade_initialized': false,
        'error': e.toString(),
        'last_check': DateTime.now().toIso8601String(),
      };
    }
  }
}
