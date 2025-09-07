/// Firebase Performance Monitoring Service
///
/// PATTERN: Decorator Pattern - Performance monitoring wrapper
/// WHERE: Core Firebase services - Performance monitoring implementation
/// HOW: Decorator pattern wraps operations to measure performance automatically
/// WHY: Non-intrusive performance monitoring for Tower Defense learning optimization
library;

import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../contracts/performance_contract.dart';

/// Firebase Performance Monitoring Service
///
/// Tower Defense Context: Monitors game performance, loading times,
/// pattern complexity processing, and educational content delivery speed
class FirebasePerformanceService implements PerformanceContract {
  FirebasePerformanceService._();

  static FirebasePerformanceService? _instance;

  /// PATTERN: Singleton - Single performance monitoring instance
  static FirebasePerformanceService get instance {
    _instance ??= FirebasePerformanceService._();
    return _instance!;
  }

  late final FirebasePerformance _performance;
  final Map<String, Trace> _activeTraces = {};
  bool _isInitialized = false;
  bool _performanceEnabled = true;

  /// Initialize Performance service
  @override
  Future<Either<Failure, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      Log.debug(
        'FirebasePerformanceService: Initializing performance monitoring',
      );

      _performance = FirebasePerformance.instance;
      await _performance.setPerformanceCollectionEnabled(_performanceEnabled);

      _isInitialized = true;
      Log.success(
        'FirebasePerformanceService: Performance monitoring initialized',
      );

      return const Right(null);
    } catch (e) {
      Log.error('FirebasePerformanceService: Failed to initialize: $e');
      return Left(
        TechnicalFailure(message: 'Performance initialization failed: $e'),
      );
    }
  }

  /// Enable or disable performance collection
  @override
  Future<Either<Failure, void>> setPerformanceEnabled(bool enabled) async {
    try {
      await _performance.setPerformanceCollectionEnabled(enabled);
      _performanceEnabled = enabled;

      Log.info(
        'FirebasePerformanceService: Performance ${enabled ? 'enabled' : 'disabled'}',
      );
      return const Right(null);
    } catch (e) {
      Log.error('FirebasePerformanceService: Failed to toggle performance: $e');
      return Left(
        TechnicalFailure(message: 'Failed to toggle performance: $e'),
      );
    }
  }

  /// Start performance trace
  @override
  Future<Either<Failure, String>> startTrace(String traceName) async {
    if (!_isInitialized || !_performanceEnabled) {
      return Left(
        ValidationFailure(message: 'Performance service not available'),
      );
    }

    try {
      Log.debug('FirebasePerformanceService: Starting trace: $traceName');

      final trace = _performance.newTrace(traceName);
      await trace.start();

      _activeTraces[traceName] = trace;

      Log.success('FirebasePerformanceService: Trace started: $traceName');
      return Right(traceName);
    } catch (e) {
      Log.error('FirebasePerformanceService: Failed to start trace: $e');
      return Left(TechnicalFailure(message: 'Failed to start trace: $e'));
    }
  }

  /// Stop performance trace
  @override
  Future<Either<Failure, void>> stopTrace(String traceName) async {
    if (!_activeTraces.containsKey(traceName)) {
      return Left(ValidationFailure(message: 'Trace not found: $traceName'));
    }

    try {
      Log.debug('FirebasePerformanceService: Stopping trace: $traceName');

      final trace = _activeTraces[traceName]!;
      await trace.stop();

      _activeTraces.remove(traceName);

      Log.success('FirebasePerformanceService: Trace stopped: $traceName');
      return const Right(null);
    } catch (e) {
      Log.error('FirebasePerformanceService: Failed to stop trace: $e');
      return Left(TechnicalFailure(message: 'Failed to stop trace: $e'));
    }
  }

  /// Add metric to active trace
  @override
  Future<Either<Failure, void>> putMetric({
    required String traceName,
    required String metricName,
    required int value,
  }) async {
    if (!_activeTraces.containsKey(traceName)) {
      return Left(ValidationFailure(message: 'Trace not found: $traceName'));
    }

    try {
      final trace = _activeTraces[traceName]!;
      trace.setMetric(metricName, value);

      Log.debug(
        'FirebasePerformanceService: Metric added to $traceName: $metricName = $value',
      );
      return const Right(null);
    } catch (e) {
      Log.error('FirebasePerformanceService: Failed to put metric: $e');
      return Left(TechnicalFailure(message: 'Failed to put metric: $e'));
    }
  }

  /// Set custom attribute on trace
  @override
  Future<Either<Failure, void>> putAttribute({
    required String traceName,
    required String attributeName,
    required String attributeValue,
  }) async {
    if (!_activeTraces.containsKey(traceName)) {
      return Left(ValidationFailure(message: 'Trace not found: $traceName'));
    }

    try {
      final trace = _activeTraces[traceName]!;
      trace.putAttribute(attributeName, attributeValue);

      Log.debug(
        'FirebasePerformanceService: Attribute added to $traceName: $attributeName = $attributeValue',
      );
      return const Right(null);
    } catch (e) {
      Log.error('FirebasePerformanceService: Failed to put attribute: $e');
      return Left(TechnicalFailure(message: 'Failed to put attribute: $e'));
    }
  }

  /// Measure execution time of a function
  @override
  Future<Either<Failure, T>> measureExecution<T>({
    required String traceName,
    required Future<T> Function() operation,
    Map<String, String>? attributes,
  }) async {
    final startTraceResult = await startTrace(traceName);

    if (startTraceResult.isLeft()) {
      return Left(startTraceResult.fold((l) => l, (r) => throw 'Unreachable'));
    }

    try {
      // Add attributes if provided
      if (attributes != null) {
        for (final entry in attributes.entries) {
          await putAttribute(
            traceName: traceName,
            attributeName: entry.key,
            attributeValue: entry.value,
          );
        }
      }

      final result = await operation();

      await stopTrace(traceName);
      return Right(result);
    } catch (e) {
      await stopTrace(traceName);
      Log.error(
        'FirebasePerformanceService: Operation failed during measurement: $e',
      );
      return Left(TechnicalFailure(message: 'Operation failed: $e'));
    }
  }

  /// Create HTTP metric for network requests
  Future<Either<Failure, HttpMetric>> createHttpMetric({
    required String url,
    required HttpMethod httpMethod,
  }) async {
    if (!_isInitialized || !_performanceEnabled) {
      return Left(
        ValidationFailure(message: 'Performance service not available'),
      );
    }

    try {
      final metric = _performance.newHttpMetric(url, httpMethod);
      Log.debug('FirebasePerformanceService: HTTP metric created for: $url');
      return Right(metric);
    } catch (e) {
      Log.error('FirebasePerformanceService: Failed to create HTTP metric: $e');
      return Left(
        TechnicalFailure(message: 'Failed to create HTTP metric: $e'),
      );
    }
  }

  /// Dispose service and clean up active traces
  Future<void> dispose() async {
    for (final trace in _activeTraces.values) {
      try {
        await trace.stop();
      } catch (e) {
        Log.warning(
          'FirebasePerformanceService: Failed to stop trace during disposal: $e',
        );
      }
    }
    _activeTraces.clear();
    Log.debug('FirebasePerformanceService: Service disposed');
  }
}

/// Tower Defense Performance Helper
///
/// Educational Context: Specific performance tracking for game mechanics
class TowerDefensePerformanceHelper {
  static final FirebasePerformanceService _performance =
      FirebasePerformanceService.instance;

  /// Measure pattern loading time
  static Future<Either<Failure, T>> measurePatternLoading<T>({
    required String patternName,
    required Future<T> Function() loadOperation,
  }) async {
    return _performance.measureExecution(
      traceName: 'pattern_loading_$patternName',
      operation: loadOperation,
      attributes: {
        'pattern_name': patternName,
        'operation_type': 'pattern_loading',
        'educational_content': 'true',
      },
    );
  }

  /// Measure game level loading
  static Future<Either<Failure, T>> measureLevelLoading<T>({
    required String levelId,
    required Future<T> Function() loadOperation,
  }) async {
    return _performance.measureExecution(
      traceName: 'level_loading_$levelId',
      operation: loadOperation,
      attributes: {
        'level_id': levelId,
        'operation_type': 'level_loading',
        'game_mechanic': 'true',
      },
    );
  }

  /// Measure tower placement performance
  static Future<Either<Failure, void>> measureTowerPlacement({
    required String towerType,
    required Future<void> Function() placementOperation,
  }) async {
    final result = await _performance.measureExecution(
      traceName: 'tower_placement',
      operation: placementOperation,
      attributes: {
        'tower_type': towerType,
        'operation_type': 'tower_placement',
        'game_action': 'true',
      },
    );

    return result.map((_) {});
  }

  /// Measure code compilation/execution for educational examples
  static Future<Either<Failure, T>> measureCodeExecution<T>({
    required String patternName,
    required String language,
    required Future<T> Function() codeOperation,
  }) async {
    return _performance.measureExecution(
      traceName: 'code_execution',
      operation: codeOperation,
      attributes: {
        'pattern_name': patternName,
        'code_language': language,
        'operation_type': 'code_execution',
        'educational_demo': 'true',
      },
    );
  }

  /// Start custom trace for complex operations
  static Future<Either<Failure, String>> startCustomTrace({
    required String operation,
    Map<String, String>? metadata,
  }) async {
    final traceName =
        'custom_${operation}_${DateTime.now().millisecondsSinceEpoch}';
    final result = await _performance.startTrace(traceName);

    // Add metadata attributes if provided
    if (result.isRight() && metadata != null) {
      for (final entry in metadata.entries) {
        await _performance.putAttribute(
          traceName: traceName,
          attributeName: entry.key,
          attributeValue: entry.value,
        );
      }
    }

    return result;
  }

  /// Stop custom trace
  static Future<Either<Failure, void>> stopCustomTrace(String traceName) async {
    return _performance.stopTrace(traceName);
  }
}
