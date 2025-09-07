/// Analytics Service Contract
///
/// PATTERN: Strategy + Abstract Factory - Analytics service interface
/// WHERE: Core Firebase contracts - Analytics abstraction
/// HOW: Interface defining analytics operations with Either error handling
/// WHY: Allows multiple analytics implementations (Firebase, custom, etc.)
library;

import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../entities/analytics_event.dart';

/// Abstract contract for analytics services
///
/// Tower Defense Context: Defines how educational analytics should work
/// regardless of the underlying implementation (Firebase, custom, etc.)
abstract class AnalyticsContract {
  /// Initialize analytics service
  Future<Either<Failure, void>> initialize();

  /// Enable or disable analytics collection
  Future<Either<Failure, void>> setAnalyticsEnabled(bool enabled);

  /// Track a custom analytics event
  Future<Either<Failure, void>> trackEvent(AnalyticsEvent event);

  /// Track screen view
  Future<Either<Failure, void>> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  });

  /// Set user ID for analytics (privacy-compliant)
  Future<Either<Failure, void>> setUserId(String? userId);

  /// Set user property
  Future<Either<Failure, void>> setUserProperty({
    required String name,
    required String? value,
  });

  /// Reset analytics data (GDPR compliance)
  Future<Either<Failure, void>> resetAnalyticsData();
}

/// Analytics Event Observer Pattern Contract
abstract class AnalyticsEventObserver {
  void onAnalyticsEvent(AnalyticsEvent event);
}
