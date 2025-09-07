/// Performance Metric Entity
///
/// PATTERN: Value Object - Immutable performance measurement data
/// WHERE: Core Firebase entities - Performance metric structure
/// HOW: Immutable class representing performance measurements
/// WHY: Type-safe performance data for Tower Defense optimization
library;

import 'package:equatable/equatable.dart';

/// Performance Metric Value Object
///
/// Tower Defense Context: Represents performance measurements for
/// game operations, pattern loading, and educational content delivery
class PerformanceMetric extends Equatable {
  const PerformanceMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.category,
    this.context = const {},
  });

  final String name;
  final double value;
  final PerformanceUnit unit;
  final DateTime timestamp;
  final String? category;
  final Map<String, dynamic> context;

  /// Factory: Duration metric (for execution time measurements)
  factory PerformanceMetric.duration({
    required String name,
    required Duration duration,
    String? category,
    Map<String, dynamic>? context,
  }) {
    return PerformanceMetric(
      name: name,
      value: duration.inMilliseconds.toDouble(),
      unit: PerformanceUnit.milliseconds,
      timestamp: DateTime.now(),
      category: category ?? 'timing',
      context: context ?? {},
    );
  }

  /// Factory: Memory usage metric
  factory PerformanceMetric.memoryUsage({
    required String name,
    required int bytes,
    String? category,
    Map<String, dynamic>? context,
  }) {
    return PerformanceMetric(
      name: name,
      value: bytes.toDouble(),
      unit: PerformanceUnit.bytes,
      timestamp: DateTime.now(),
      category: category ?? 'memory',
      context: context ?? {},
    );
  }

  /// Factory: Frame rate metric
  factory PerformanceMetric.frameRate({
    required double fps,
    String? category,
    Map<String, dynamic>? context,
  }) {
    return PerformanceMetric(
      name: 'frame_rate',
      value: fps,
      unit: PerformanceUnit.framesPerSecond,
      timestamp: DateTime.now(),
      category: category ?? 'rendering',
      context: context ?? {},
    );
  }

  /// Factory: Network throughput metric
  factory PerformanceMetric.networkThroughput({
    required String operation,
    required int bytesTransferred,
    required Duration duration,
    Map<String, dynamic>? context,
  }) {
    final bytesPerSecond = bytesTransferred / duration.inSeconds;
    return PerformanceMetric(
      name: 'network_throughput_$operation',
      value: bytesPerSecond,
      unit: PerformanceUnit.bytesPerSecond,
      timestamp: DateTime.now(),
      category: 'network',
      context: {
        'operation': operation,
        'total_bytes': bytesTransferred,
        'duration_ms': duration.inMilliseconds,
        ...?context,
      },
    );
  }

  /// Factory: Tower Defense specific - Pattern loading time
  factory PerformanceMetric.patternLoadTime({
    required String patternName,
    required Duration loadTime,
    String? complexity,
  }) {
    return PerformanceMetric(
      name: 'pattern_load_time',
      value: loadTime.inMilliseconds.toDouble(),
      unit: PerformanceUnit.milliseconds,
      timestamp: DateTime.now(),
      category: 'educational_content',
      context: {
        'pattern_name': patternName,
        'complexity': complexity ?? 'unknown',
        'educational_metric': true,
      },
    );
  }

  /// Factory: Tower Defense specific - Game frame processing time
  factory PerformanceMetric.gameFrameTime({
    required Duration frameTime,
    required int enemyCount,
    required int towerCount,
    required String level,
  }) {
    return PerformanceMetric(
      name: 'game_frame_time',
      value: frameTime.inMicroseconds.toDouble(),
      unit: PerformanceUnit.microseconds,
      timestamp: DateTime.now(),
      category: 'game_performance',
      context: {
        'enemy_count': enemyCount,
        'tower_count': towerCount,
        'level': level,
        'game_metric': true,
      },
    );
  }

  /// Convert to Map for Firebase Analytics
  Map<String, dynamic> toAnalyticsMap() {
    return {
      'metric_name': name,
      'metric_value': value,
      'metric_unit': unit.name,
      'metric_category': category,
      'timestamp': timestamp.toIso8601String(),
      ...context,
    };
  }

  /// Convert to Map for logging
  Map<String, dynamic> toLogMap() {
    return {
      'name': name,
      'value': value,
      'unit': unit.displayName,
      'category': category,
      'timestamp': timestamp.toString(),
      'context': context,
    };
  }

  /// Get human-readable value with unit
  String get displayValue {
    switch (unit) {
      case PerformanceUnit.milliseconds:
        return '${value.toStringAsFixed(2)} ms';
      case PerformanceUnit.microseconds:
        return '${value.toStringAsFixed(0)} μs';
      case PerformanceUnit.seconds:
        return '${(value / 1000).toStringAsFixed(2)} s';
      case PerformanceUnit.bytes:
        return _formatBytes(value.toInt());
      case PerformanceUnit.bytesPerSecond:
        return '${_formatBytes(value.toInt())}/s';
      case PerformanceUnit.framesPerSecond:
        return '${value.toStringAsFixed(1)} FPS';
      case PerformanceUnit.count:
        return value.toStringAsFixed(0);
      case PerformanceUnit.percentage:
        return '${value.toStringAsFixed(1)}%';
    }
  }

  /// Format bytes in human-readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check if metric indicates poor performance
  bool get isPerformanceConcern {
    switch (name) {
      case 'pattern_load_time':
        return value > 2000; // More than 2 seconds
      case 'game_frame_time':
        return value > 16666; // More than 16.66ms (60 FPS)
      case 'frame_rate':
        return value < 30; // Less than 30 FPS
      case 'memory_usage':
        return value > 100 * 1024 * 1024; // More than 100MB
      default:
        return false;
    }
  }

  @override
  List<Object?> get props => [name, value, unit, timestamp, category, context];

  @override
  String toString() {
    return 'PerformanceMetric(name: $name, value: $displayValue, category: $category)';
  }
}

/// Performance measurement units
enum PerformanceUnit {
  milliseconds('ms'),
  microseconds('μs'),
  seconds('s'),
  bytes('bytes'),
  bytesPerSecond('bytes/s'),
  framesPerSecond('fps'),
  count('count'),
  percentage('%');

  const PerformanceUnit(this.displayName);

  final String displayName;
}

/// Performance Measurement Summary
///
/// Tower Defense Context: Aggregated performance data for analysis
class PerformanceSummary extends Equatable {
  const PerformanceSummary({
    required this.metrics,
    required this.timeRange,
    required this.categories,
  });

  final List<PerformanceMetric> metrics;
  final DateTimeRange timeRange;
  final Set<String> categories;

  /// Get metrics by category
  List<PerformanceMetric> getMetricsByCategory(String category) {
    return metrics.where((m) => m.category == category).toList();
  }

  /// Get average value for named metric
  double? getAverageValue(String metricName) {
    final namedMetrics = metrics.where((m) => m.name == metricName).toList();
    if (namedMetrics.isEmpty) return null;

    final total = namedMetrics.fold(0.0, (sum, m) => sum + m.value);
    return total / namedMetrics.length;
  }

  /// Get performance concerns
  List<PerformanceMetric> get performanceConcerns {
    return metrics.where((m) => m.isPerformanceConcern).toList();
  }

  /// Get summary statistics
  Map<String, dynamic> get statistics {
    return {
      'total_metrics': metrics.length,
      'categories': categories.toList(),
      'time_range_hours': timeRange.duration.inHours,
      'performance_concerns': performanceConcerns.length,
      'avg_pattern_load_time': getAverageValue('pattern_load_time'),
      'avg_frame_time': getAverageValue('game_frame_time'),
      'avg_frame_rate': getAverageValue('frame_rate'),
    };
  }

  @override
  List<Object?> get props => [metrics, timeRange, categories];
}

/// Date time range helper
class DateTimeRange extends Equatable {
  const DateTimeRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);

  bool contains(DateTime dateTime) {
    return dateTime.isAfter(start) && dateTime.isBefore(end);
  }

  @override
  List<Object?> get props => [start, end];
}
