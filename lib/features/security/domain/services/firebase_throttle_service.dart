/// Firebase Throttling Service - Security Domain Layer
///
/// PATTERN: Singleton + Observer - Global request throttling with notifications
/// WHERE: Domain layer service for Firebase rate limiting
/// HOW: Singleton service with observer notifications for rate limit events
/// WHY: Prevents Firebase quota exhaustion and provides system-wide monitoring
library;

import 'dart:async';
import 'dart:collection';

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/patterns/behavioral/observer.dart';

/// Firebase throttling service with singleton pattern and observer notifications
///
/// PATTERN: Singleton + Observer - Global throttling with event system
///
/// Manages Firebase request rate limiting across the Tower Defense app
/// to prevent quota exhaustion and ensure optimal performance.
class FirebaseThrottleService extends Subject<ThrottleEvent> {
  // PATTERN: Singleton implementation
  static final FirebaseThrottleService _instance =
      FirebaseThrottleService._internal();

  factory FirebaseThrottleService() => _instance;

  FirebaseThrottleService._internal() {
    _startCleanupTimer();
    Log.debug('FirebaseThrottleService initialized as Singleton');
  }

  // Observer pattern - list of components listening for throttle events
  final List<Observer<ThrottleEvent>> _observers = [];

  // Request tracking by service type
  final Map<FirebaseServiceType, Queue<DateTime>> _requestHistory = {};

  // Service-specific rate limits (requests per minute)
  final Map<FirebaseServiceType, int> _rateLimits = {
    FirebaseServiceType.authentication: 300, // Firebase Auth has high limits
    FirebaseServiceType.firestore: 200, // Firestore read/write limits
    FirebaseServiceType.storage: 150, // Storage operations
    FirebaseServiceType.analytics: 500, // Analytics events
    FirebaseServiceType.performance: 100, // Performance monitoring
    FirebaseServiceType.appCheck: 50, // App Check verifications
    FirebaseServiceType.crashlytics: 1000, // Crash reports (burst allowed)
  };

  // Time windows for rate limiting
  final Duration _timeWindow = const Duration(minutes: 1);
  final Duration _burstWindow = const Duration(seconds: 10);

  // Burst limits (short-term high-frequency requests)
  final Map<FirebaseServiceType, int> _burstLimits = {
    FirebaseServiceType.authentication: 50,
    FirebaseServiceType.firestore: 30,
    FirebaseServiceType.storage: 20,
    FirebaseServiceType.analytics: 100,
    FirebaseServiceType.performance: 15,
    FirebaseServiceType.appCheck: 10,
    FirebaseServiceType.crashlytics: 200,
  };

  // Circuit breaker state
  final Map<FirebaseServiceType, CircuitBreakerState> _circuitStates = {};

  // Cleanup timer
  Timer? _cleanupTimer;

  /// Check if a request to a Firebase service should be allowed
  Future<ThrottleDecision> checkRequest(
    FirebaseServiceType serviceType, {
    String? operationType,
    Map<String, dynamic>? context,
  }) async {
    final now = DateTime.now();

    Log.debug(
      'FirebaseThrottleService: Checking throttle for ${serviceType.name}',
    );

    // Initialize request history if needed
    _requestHistory[serviceType] ??= Queue<DateTime>();

    final requestQueue = _requestHistory[serviceType]!;

    // Clean old requests outside time window
    _cleanOldRequests(requestQueue, now);

    // Check circuit breaker state
    final circuitState = _getCircuitBreakerState(serviceType);
    if (circuitState == CircuitBreakerState.open) {
      final event = ThrottleEvent(
        serviceType: serviceType,
        decision: ThrottleDecision.denied,
        reason: ThrottleReason.circuitBreakerOpen,
        currentCount: requestQueue.length,
        limit: _rateLimits[serviceType]!,
        timestamp: now,
        operationType: operationType,
        context: context,
      );

      _notifyObservers(event);

      Log.warning(
        'FirebaseThrottleService: Circuit breaker OPEN for ${serviceType.name}',
      );
      return ThrottleDecision.denied;
    }

    // Check burst limit (last 10 seconds)
    final burstCount = _countRecentRequests(requestQueue, now, _burstWindow);
    final burstLimit = _burstLimits[serviceType]!;

    if (burstCount >= burstLimit) {
      final event = ThrottleEvent(
        serviceType: serviceType,
        decision: ThrottleDecision.denied,
        reason: ThrottleReason.burstLimitExceeded,
        currentCount: burstCount,
        limit: burstLimit,
        timestamp: now,
        operationType: operationType,
        context: context,
      );

      _notifyObservers(event);

      Log.warning(
        'FirebaseThrottleService: Burst limit exceeded for ${serviceType.name} '
        '($burstCount/$burstLimit in ${_burstWindow.inSeconds}s)',
      );
      return ThrottleDecision.denied;
    }

    // Check rate limit (last minute)
    final rateCount = requestQueue.length;
    final rateLimit = _rateLimits[serviceType]!;

    if (rateCount >= rateLimit) {
      // Trip circuit breaker if consistently hitting limits
      _updateCircuitBreaker(serviceType, true);

      final event = ThrottleEvent(
        serviceType: serviceType,
        decision: ThrottleDecision.denied,
        reason: ThrottleReason.rateLimitExceeded,
        currentCount: rateCount,
        limit: rateLimit,
        timestamp: now,
        operationType: operationType,
        context: context,
      );

      _notifyObservers(event);

      Log.warning(
        'FirebaseThrottleService: Rate limit exceeded for ${serviceType.name} '
        '($rateCount/$rateLimit in ${_timeWindow.inMinutes}m)',
      );
      return ThrottleDecision.denied;
    }

    // Request is allowed - record it
    requestQueue.add(now);

    // Reset circuit breaker on successful requests
    _updateCircuitBreaker(serviceType, false);

    // Determine if we should warn about approaching limits
    ThrottleDecision decision = ThrottleDecision.allowed;
    ThrottleReason? reason;

    if (rateCount >= (rateLimit * 0.8)) {
      decision = ThrottleDecision.allowedWithWarning;
      reason = ThrottleReason.approachingRateLimit;
    } else if (burstCount >= (burstLimit * 0.8)) {
      decision = ThrottleDecision.allowedWithWarning;
      reason = ThrottleReason.approachingBurstLimit;
    }

    final event = ThrottleEvent(
      serviceType: serviceType,
      decision: decision,
      reason: reason ?? ThrottleReason.withinLimits,
      currentCount: rateCount,
      limit: rateLimit,
      timestamp: now,
      operationType: operationType,
      context: context,
    );

    _notifyObservers(event);

    if (decision == ThrottleDecision.allowedWithWarning) {
      Log.info(
        'FirebaseThrottleService: WARNING - Approaching limits for ${serviceType.name}',
      );
    } else {
      Log.debug(
        'FirebaseThrottleService: Request allowed for ${serviceType.name}',
      );
    }

    return decision;
  }

  /// Get current throttling statistics
  Map<String, dynamic> getThrottleStats() {
    final now = DateTime.now();
    final stats = <String, dynamic>{};

    for (final serviceType in FirebaseServiceType.values) {
      final requestQueue = _requestHistory[serviceType] ?? Queue<DateTime>();
      _cleanOldRequests(requestQueue, now);

      final rateCount = requestQueue.length;
      final burstCount = _countRecentRequests(requestQueue, now, _burstWindow);

      stats[serviceType.name] = {
        'current_rate_count': rateCount,
        'rate_limit': _rateLimits[serviceType]!,
        'rate_utilization': (rateCount / _rateLimits[serviceType]! * 100)
            .round(),
        'current_burst_count': burstCount,
        'burst_limit': _burstLimits[serviceType]!,
        'burst_utilization': (burstCount / _burstLimits[serviceType]! * 100)
            .round(),
        'circuit_breaker': _getCircuitBreakerState(serviceType).name,
      };
    }

    return {
      'services': stats,
      'global_stats': {
        'total_observers': _observers.length,
        'active_services': _requestHistory.length,
        'cleanup_interval_minutes': 5,
        'time_window_minutes': _timeWindow.inMinutes,
        'burst_window_seconds': _burstWindow.inSeconds,
      },
      'generated_at': now.toIso8601String(),
    };
  }

  /// Update rate limits (for configuration changes)
  void updateRateLimit(FirebaseServiceType serviceType, int newLimit) {
    final oldLimit = _rateLimits[serviceType];
    _rateLimits[serviceType] = newLimit;

    Log.info(
      'FirebaseThrottleService: Rate limit updated for ${serviceType.name} '
      'from $oldLimit to $newLimit requests/minute',
    );

    final event = ThrottleEvent(
      serviceType: serviceType,
      decision: ThrottleDecision.configurationChanged,
      reason: ThrottleReason.rateLimitUpdated,
      currentCount: 0,
      limit: newLimit,
      timestamp: DateTime.now(),
      context: {'old_limit': oldLimit, 'new_limit': newLimit},
    );

    _notifyObservers(event);
  }

  /// Manually reset circuit breaker for a service
  void resetCircuitBreaker(FirebaseServiceType serviceType) {
    _circuitStates[serviceType] = CircuitBreakerState.closed;

    Log.info(
      'FirebaseThrottleService: Circuit breaker reset for ${serviceType.name}',
    );

    final event = ThrottleEvent(
      serviceType: serviceType,
      decision: ThrottleDecision.configurationChanged,
      reason: ThrottleReason.circuitBreakerReset,
      currentCount: 0,
      limit: _rateLimits[serviceType]!,
      timestamp: DateTime.now(),
    );

    _notifyObservers(event);
  }

  /// Clear all request history (for testing or emergency reset)
  void clearHistory() {
    _requestHistory.clear();
    _circuitStates.clear();

    Log.warning('FirebaseThrottleService: All request history cleared');

    for (final serviceType in FirebaseServiceType.values) {
      final event = ThrottleEvent(
        serviceType: serviceType,
        decision: ThrottleDecision.configurationChanged,
        reason: ThrottleReason.historyCleared,
        currentCount: 0,
        limit: _rateLimits[serviceType]!,
        timestamp: DateTime.now(),
      );

      _notifyObservers(event);
    }
  }

  // Helper methods

  void _cleanOldRequests(Queue<DateTime> requestQueue, DateTime now) {
    while (requestQueue.isNotEmpty &&
        now.difference(requestQueue.first) > _timeWindow) {
      requestQueue.removeFirst();
    }
  }

  int _countRecentRequests(
    Queue<DateTime> requestQueue,
    DateTime now,
    Duration window,
  ) {
    return requestQueue.where((time) => now.difference(time) <= window).length;
  }

  CircuitBreakerState _getCircuitBreakerState(FirebaseServiceType serviceType) {
    return _circuitStates[serviceType] ?? CircuitBreakerState.closed;
  }

  void _updateCircuitBreaker(FirebaseServiceType serviceType, bool shouldTrip) {
    final currentState = _getCircuitBreakerState(serviceType);

    if (shouldTrip && currentState == CircuitBreakerState.closed) {
      _circuitStates[serviceType] = CircuitBreakerState.open;
      Log.error(
        'FirebaseThrottleService: Circuit breaker OPENED for ${serviceType.name}',
      );

      // Schedule automatic reset after 5 minutes
      Timer(const Duration(minutes: 5), () {
        if (_circuitStates[serviceType] == CircuitBreakerState.open) {
          _circuitStates[serviceType] = CircuitBreakerState.halfOpen;
          Log.info(
            'FirebaseThrottleService: Circuit breaker moved to HALF-OPEN for ${serviceType.name}',
          );
        }
      });
    } else if (!shouldTrip && currentState == CircuitBreakerState.halfOpen) {
      _circuitStates[serviceType] = CircuitBreakerState.closed;
      Log.info(
        'FirebaseThrottleService: Circuit breaker CLOSED for ${serviceType.name}',
      );
    }
  }

  void _notifyObservers(ThrottleEvent event) {
    Log.debug(
      'FirebaseThrottleService: Notifying ${_observers.length} observers',
    );

    for (final observer in _observers) {
      try {
        observer.update(event);
      } catch (e) {
        Log.error('FirebaseThrottleService: Error notifying observer: $e');
      }
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      final now = DateTime.now();
      int totalCleaned = 0;

      for (final queue in _requestHistory.values) {
        final sizeBefore = queue.length;
        _cleanOldRequests(queue, now);
        totalCleaned += sizeBefore - queue.length;
      }

      if (totalCleaned > 0) {
        Log.debug(
          'FirebaseThrottleService: Cleanup removed $totalCleaned old requests',
        );
      }
    });
  }

  // PATTERN: Observer - Subject implementation
  @override
  void addObserver(Observer<ThrottleEvent> observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
      Log.debug(
        'FirebaseThrottleService: Observer added (${_observers.length} total)',
      );
    }
  }

  @override
  void removeObserver(Observer<ThrottleEvent> observer) {
    _observers.remove(observer);
    Log.debug(
      'FirebaseThrottleService: Observer removed (${_observers.length} remaining)',
    );
  }

  @override
  void notifyObservers(ThrottleEvent event) {
    _notifyObservers(event);
  }

  /// Dispose resources (mainly for testing)
  void dispose() {
    _cleanupTimer?.cancel();
    _observers.clear();
    _requestHistory.clear();
    _circuitStates.clear();
    Log.debug('FirebaseThrottleService: Disposed');
  }
}

/// Firebase service types for throttling
enum FirebaseServiceType {
  authentication,
  firestore,
  storage,
  analytics,
  performance,
  appCheck,
  crashlytics,
}

/// Throttle decision types
enum ThrottleDecision {
  allowed,
  allowedWithWarning,
  denied,
  configurationChanged,
}

/// Throttle reason types
enum ThrottleReason {
  withinLimits,
  approachingRateLimit,
  approachingBurstLimit,
  rateLimitExceeded,
  burstLimitExceeded,
  circuitBreakerOpen,
  rateLimitUpdated,
  circuitBreakerReset,
  historyCleared,
}

/// Circuit breaker states
enum CircuitBreakerState {
  closed, // Normal operation
  open, // Blocking requests
  halfOpen, // Testing if service is back
}

/// Throttle event for observer notifications
class ThrottleEvent {
  final FirebaseServiceType serviceType;
  final ThrottleDecision decision;
  final ThrottleReason reason;
  final int currentCount;
  final int limit;
  final DateTime timestamp;
  final String? operationType;
  final Map<String, dynamic>? context;

  const ThrottleEvent({
    required this.serviceType,
    required this.decision,
    required this.reason,
    required this.currentCount,
    required this.limit,
    required this.timestamp,
    this.operationType,
    this.context,
  });

  /// Get utilization percentage
  double get utilizationPercentage =>
      (currentCount / limit * 100).clamp(0.0, 100.0);

  /// Check if this is a warning event
  bool get isWarning => decision == ThrottleDecision.allowedWithWarning;

  /// Check if this is a denial event
  bool get isDenial => decision == ThrottleDecision.denied;

  /// Check if this is a critical event (circuit breaker or severe limit)
  bool get isCritical =>
      reason == ThrottleReason.circuitBreakerOpen ||
      utilizationPercentage >= 90.0;

  @override
  String toString() =>
      'ThrottleEvent(${serviceType.name}: ${decision.name} - ${reason.name})';

  Map<String, dynamic> toJson() {
    return {
      'service_type': serviceType.name,
      'decision': decision.name,
      'reason': reason.name,
      'current_count': currentCount,
      'limit': limit,
      'utilization_percentage': utilizationPercentage,
      'timestamp': timestamp.toIso8601String(),
      'operation_type': operationType,
      'context': context,
    };
  }
}
