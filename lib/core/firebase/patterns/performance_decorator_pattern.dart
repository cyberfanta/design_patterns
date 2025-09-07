/// Performance Decorator Pattern Implementation
///
/// PATTERN: Decorator Pattern - Performance monitoring wrapper
/// WHERE: Core Firebase patterns - Decorator implementation for performance
/// HOW: Decorators wrap operations to add performance monitoring automatically
/// WHY: Non-intrusive performance tracking for Tower Defense optimization
library;

import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../entities/performance_metric.dart';
import '../services/performance_service.dart';

/// Base component for performance-monitored operations
abstract class PerformanceComponent<T> {
  Future<Either<Failure, T>> execute();
}

/// Base decorator for adding performance monitoring
abstract class PerformanceDecorator<T> implements PerformanceComponent<T> {
  const PerformanceDecorator(this.component);

  final PerformanceComponent<T> component;

  @override
  Future<Either<Failure, T>> execute() {
    return component.execute();
  }
}

/// Execution Time Decorator
/// Tower Defense Context: Measures execution time for operations
class ExecutionTimeDecorator<T> extends PerformanceDecorator<T> {
  const ExecutionTimeDecorator({
    required PerformanceComponent<T> component,
    required this.operationName,
    this.category = 'general',
    this.context = const {},
  }) : super(component);

  final String operationName;
  final String category;
  final Map<String, dynamic> context;

  @override
  Future<Either<Failure, T>> execute() async {
    final stopwatch = Stopwatch()..start();

    try {
      Log.debug('PerformanceDecorator: Starting $operationName');

      final result = await component.execute();

      stopwatch.stop();
      final metric = PerformanceMetric.duration(
        name: operationName,
        duration: stopwatch.elapsed,
        category: category,
        context: context,
      );

      // Log the metric
      Log.info('Performance: ${metric.displayValue} - $operationName');

      // Report to Firebase Performance if significant
      if (stopwatch.elapsedMilliseconds > 100) {
        _reportToFirebasePerformance(metric);
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      Log.warning(
        'PerformanceDecorator: Operation $operationName failed after ${stopwatch.elapsed}',
      );
      rethrow;
    }
  }

  void _reportToFirebasePerformance(PerformanceMetric metric) {
    // Report to Firebase Performance Service
    FirebasePerformanceService.instance.measureExecution(
      traceName: metric.name,
      operation: () async => null,
      attributes: {
        'category': metric.category ?? 'unknown',
        'duration_ms': metric.value.toString(),
        ...metric.context.map((key, value) => MapEntry(key, value.toString())),
      },
    );
  }
}

/// Memory Usage Decorator
/// Tower Defense Context: Monitors memory usage during operations
class MemoryUsageDecorator<T> extends PerformanceDecorator<T> {
  const MemoryUsageDecorator({
    required PerformanceComponent<T> component,
    required this.operationName,
    this.trackPeakUsage = false,
  }) : super(component);

  final String operationName;
  final bool trackPeakUsage;

  @override
  Future<Either<Failure, T>> execute() async {
    final startMemory = _getCurrentMemoryUsage();
    int? peakMemory = startMemory;

    Timer? memoryTracker;
    if (trackPeakUsage) {
      memoryTracker = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) {
        final current = _getCurrentMemoryUsage();
        if (current > peakMemory!) {
          peakMemory = current;
        }
      });
    }

    try {
      final result = await component.execute();

      memoryTracker?.cancel();
      final endMemory = _getCurrentMemoryUsage();
      final memoryDelta = endMemory - startMemory;

      final metric = PerformanceMetric.memoryUsage(
        name: '${operationName}_memory_usage',
        bytes: trackPeakUsage ? peakMemory! : endMemory,
        category: 'memory',
        context: {
          'operation': operationName,
          'memory_delta_bytes': memoryDelta,
          'peak_usage': trackPeakUsage,
        },
      );

      if (memoryDelta > 1024 * 1024) {
        // More than 1MB
        Log.warning('Memory: ${metric.displayValue} used by $operationName');
      } else {
        Log.debug('Memory: ${metric.displayValue} used by $operationName');
      }

      return result;
    } catch (e) {
      memoryTracker?.cancel();
      rethrow;
    }
  }

  int _getCurrentMemoryUsage() {
    // This is a simplified implementation
    // In a real app, you'd use dart:developer or platform-specific APIs
    return DateTime.now().millisecondsSinceEpoch % 100000000;
  }
}

/// Error Rate Decorator
/// Tower Defense Context: Tracks success/failure rates for operations
class ErrorRateDecorator<T> extends PerformanceDecorator<T> {
  ErrorRateDecorator({
    required PerformanceComponent<T> component,
    required this.operationName,
    this.category = 'reliability',
  }) : super(component);

  final String operationName;
  final String category;

  static final Map<String, _OperationStats> _operationStats = {};

  @override
  Future<Either<Failure, T>> execute() async {
    final stats = _operationStats.putIfAbsent(
      operationName,
      () => _OperationStats(),
    );

    stats.totalAttempts++;

    try {
      final result = await component.execute();

      if (result.isRight()) {
        stats.successes++;
      } else {
        stats.failures++;
      }

      // Log error rate if it's concerning
      final errorRate = stats.errorRate;
      if (errorRate > 0.1 && stats.totalAttempts > 10) {
        // > 10% error rate
        Log.warning(
          'ErrorRate: ${(errorRate * 100).toStringAsFixed(1)}% for $operationName',
        );
      }

      return result;
    } catch (e) {
      stats.failures++;
      Log.error('ErrorRateDecorator: Operation $operationName failed: $e');
      rethrow;
    }
  }

  /// Get error rate statistics for all operations
  static Map<String, double> getErrorRateStats() {
    return _operationStats.map(
      (name, stats) => MapEntry(name, stats.errorRate),
    );
  }

  /// Reset statistics for an operation
  static void resetStats(String operationName) {
    _operationStats.remove(operationName);
  }

  /// Clear all statistics
  static void clearAllStats() {
    _operationStats.clear();
  }
}

/// Operation statistics helper
class _OperationStats {
  int totalAttempts = 0;
  int successes = 0;
  int failures = 0;

  double get errorRate => totalAttempts == 0 ? 0.0 : failures / totalAttempts;

  double get successRate =>
      totalAttempts == 0 ? 0.0 : successes / totalAttempts;
}

/// Cache Performance Decorator
/// Tower Defense Context: Monitors cache hit/miss rates
class CachePerformanceDecorator<T> extends PerformanceDecorator<T> {
  const CachePerformanceDecorator({
    required PerformanceComponent<T> component,
    required this.operationName,
    required this.cacheKey,
  }) : super(component);

  final String operationName;
  final String cacheKey;

  static final Map<String, dynamic> _cache = {};
  static final Map<String, _CacheStats> _cacheStats = {};

  @override
  Future<Either<Failure, T>> execute() async {
    final stats = _cacheStats.putIfAbsent(operationName, () => _CacheStats());

    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      stats.hits++;
      Log.debug('CachePerformanceDecorator: Cache hit for $operationName');
      return Right(_cache[cacheKey] as T);
    }

    // Cache miss - execute operation
    stats.misses++;
    Log.debug('CachePerformanceDecorator: Cache miss for $operationName');

    final result = await component.execute();

    // Cache successful results
    if (result.isRight()) {
      _cache[cacheKey] = result.fold((l) => null, (r) => r);
    }

    // Log cache statistics
    final hitRate = stats.hitRate;
    if (stats.total > 10) {
      Log.info(
        'Cache: ${(hitRate * 100).toStringAsFixed(1)}% hit rate for $operationName',
      );
    }

    return result;
  }

  /// Get cache statistics
  static Map<String, double> getCacheStats() {
    return _cacheStats.map((name, stats) => MapEntry(name, stats.hitRate));
  }

  /// Clear cache for operation
  static void clearCache(String operationName) {
    _cache.removeWhere((key, _) => key.startsWith(operationName));
    _cacheStats.remove(operationName);
  }

  /// Clear all caches
  static void clearAllCaches() {
    _cache.clear();
    _cacheStats.clear();
  }
}

/// Cache statistics helper
class _CacheStats {
  int hits = 0;
  int misses = 0;

  int get total => hits + misses;

  double get hitRate => total == 0 ? 0.0 : hits / total;

  double get missRate => total == 0 ? 0.0 : misses / total;
}

/// Performance Decorator Builder
/// Tower Defense Context: Builder for combining multiple decorators
class PerformanceDecoratorBuilder<T> {
  PerformanceDecoratorBuilder(this._component);

  PerformanceComponent<T> _component;

  /// Add execution time monitoring
  PerformanceDecoratorBuilder<T> withExecutionTime({
    required String operationName,
    String category = 'general',
    Map<String, dynamic> context = const {},
  }) {
    _component = ExecutionTimeDecorator<T>(
      component: _component,
      operationName: operationName,
      category: category,
      context: context,
    );
    return this;
  }

  /// Add memory usage monitoring
  PerformanceDecoratorBuilder<T> withMemoryTracking({
    required String operationName,
    bool trackPeakUsage = false,
  }) {
    _component = MemoryUsageDecorator<T>(
      component: _component,
      operationName: operationName,
      trackPeakUsage: trackPeakUsage,
    );
    return this;
  }

  /// Add error rate monitoring
  PerformanceDecoratorBuilder<T> withErrorTracking({
    required String operationName,
    String category = 'reliability',
  }) {
    _component = ErrorRateDecorator<T>(
      component: _component,
      operationName: operationName,
      category: category,
    );
    return this;
  }

  /// Add cache monitoring
  PerformanceDecoratorBuilder<T> withCacheTracking({
    required String operationName,
    required String cacheKey,
  }) {
    _component = CachePerformanceDecorator<T>(
      component: _component,
      operationName: operationName,
      cacheKey: cacheKey,
    );
    return this;
  }

  /// Build the final decorated component
  PerformanceComponent<T> build() => _component;

  /// Execute the decorated operation
  Future<Either<Failure, T>> execute() => _component.execute();
}

/// Concrete implementation wrapper for any async operation
class OperationWrapper<T> implements PerformanceComponent<T> {
  const OperationWrapper(this.operation);

  final Future<Either<Failure, T>> Function() operation;

  @override
  Future<Either<Failure, T>> execute() => operation();
}

/// Tower Defense Performance Decorators Helper
class TowerDefensePerformanceDecorators {
  /// Decorate pattern loading operation
  static PerformanceComponent<T> decoratePatternLoading<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String patternName,
  }) {
    return PerformanceDecoratorBuilder<T>(OperationWrapper(operation))
        .withExecutionTime(
          operationName: 'pattern_loading',
          category: 'educational',
          context: {'pattern_name': patternName},
        )
        .withMemoryTracking(operationName: 'pattern_loading')
        .withErrorTracking(operationName: 'pattern_loading')
        .withCacheTracking(
          operationName: 'pattern_loading',
          cacheKey: 'pattern_$patternName',
        )
        .build();
  }

  /// Decorate game frame processing
  static PerformanceComponent<T> decorateGameFrame<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String level,
  }) {
    return PerformanceDecoratorBuilder<T>(OperationWrapper(operation))
        .withExecutionTime(
          operationName: 'game_frame_processing',
          category: 'game_performance',
          context: {'level': level},
        )
        .withMemoryTracking(
          operationName: 'game_frame_processing',
          trackPeakUsage: true,
        )
        .build();
  }

  /// Decorate UI rendering operation
  static PerformanceComponent<T> decorateUIRendering<T>({
    required Future<Either<Failure, T>> Function() operation,
    required String widgetName,
  }) {
    return PerformanceDecoratorBuilder<T>(OperationWrapper(operation))
        .withExecutionTime(
          operationName: 'ui_rendering',
          category: 'ui_performance',
          context: {'widget': widgetName},
        )
        .withErrorTracking(operationName: 'ui_rendering')
        .build();
  }
}
