/// Firebase App Check Service
///
/// PATTERN: Proxy Pattern - Security validation proxy
/// WHERE: Core Firebase services - App Check security implementation
/// HOW: Proxy pattern intercepts requests to validate app authenticity
/// WHY: Protect Firebase resources from abuse and ensure authentic app access
library;

import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:fpdart/fpdart.dart';

import '../../error/failures.dart';
import '../../logging/logging.dart';
import '../contracts/app_check_contract.dart';
import '../entities/app_check_token.dart';

/// Firebase App Check Service Implementation
///
/// Tower Defense Context: Protects educational resources and user data
/// from unauthorized access and abuse
class FirebaseAppCheckService implements AppCheckContract {
  FirebaseAppCheckService._();

  static FirebaseAppCheckService? _instance;

  /// PATTERN: Singleton - Single app check service instance
  static FirebaseAppCheckService get instance {
    _instance ??= FirebaseAppCheckService._();
    return _instance!;
  }

  late final FirebaseAppCheck _appCheck;
  bool _isInitialized = false;
  bool _appCheckEnabled = true;
  AppCheckToken? _currentToken;
  Timer? _tokenRefreshTimer;

  /// Initialize App Check service
  @override
  Future<Either<Failure, void>> initialize() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      Log.debug('FirebaseAppCheckService: Initializing app check service');

      _appCheck = FirebaseAppCheck.instance;

      // Activate App Check with debug token in debug mode
      await _appCheck.activate(
        // Configure providers based on platform
        androidProvider: AndroidProvider.debug,
        // Change to playIntegrity in production
        appleProvider: AppleProvider.debug, // Change to appAttest in production
      );

      // Setup token refresh listener
      _setupTokenRefresh();

      _isInitialized = true;
      Log.success('FirebaseAppCheckService: App check service initialized');

      return const Right(null);
    } catch (e) {
      Log.error('FirebaseAppCheckService: Failed to initialize: $e');
      return Left(
        TechnicalFailure(message: 'App Check initialization failed: $e'),
      );
    }
  }

  /// Setup automatic token refresh
  void _setupTokenRefresh() {
    // Listen for token changes
    _appCheck.onTokenChange.listen((token) {
      if (token != null && token.isNotEmpty) {
        _currentToken = AppCheckToken(
          token: token,
          expirationTimestamp: DateTime.now().add(
            const Duration(hours: 1),
          ), // Approximate
        );

        Log.debug('FirebaseAppCheckService: App Check token refreshed');
      }
    });

    // Setup periodic token validation
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _validateCurrentToken();
    });
  }

  /// Validate current token
  Future<void> _validateCurrentToken() async {
    if (_currentToken == null || _currentToken!.isExpired) {
      Log.warning(
        'FirebaseAppCheckService: Token expired or missing, requesting new token',
      );
      await getToken();
    }
  }

  /// Get App Check token
  @override
  Future<Either<Failure, String>> getToken({bool forceRefresh = false}) async {
    if (!_isInitialized || !_appCheckEnabled) {
      return Left(
        ValidationFailure(message: 'App Check service not available'),
      );
    }

    try {
      Log.debug('FirebaseAppCheckService: Getting App Check token');

      final token = await _appCheck.getToken(forceRefresh);

      if (token != null && token.isNotEmpty) {
        _currentToken = AppCheckToken(
          token: token,
          expirationTimestamp: DateTime.now().add(const Duration(hours: 1)),
        );

        Log.success('FirebaseAppCheckService: App Check token obtained');
        return Right(token);
      } else {
        Log.error('FirebaseAppCheckService: Failed to obtain token');
        return Left(
          TechnicalFailure(message: 'Failed to obtain App Check token'),
        );
      }
    } catch (e) {
      Log.error('FirebaseAppCheckService: Token retrieval failed: $e');
      return Left(TechnicalFailure(message: 'Token retrieval failed: $e'));
    }
  }

  /// Set token auto refresh enabled
  @override
  Future<Either<Failure, void>> setTokenAutoRefreshEnabled(bool enabled) async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'App Check not initialized'));
    }

    try {
      await _appCheck.setTokenAutoRefreshEnabled(enabled);
      Log.info(
        'FirebaseAppCheckService: Token auto refresh ${enabled ? 'enabled' : 'disabled'}',
      );
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseAppCheckService: Failed to set auto refresh: $e');
      return Left(TechnicalFailure(message: 'Failed to set auto refresh: $e'));
    }
  }

  /// Enable or disable App Check
  @override
  Future<Either<Failure, void>> setAppCheckEnabled(bool enabled) async {
    try {
      _appCheckEnabled = enabled;

      if (!enabled && _tokenRefreshTimer != null) {
        _tokenRefreshTimer!.cancel();
        _tokenRefreshTimer = null;
      } else if (enabled && _tokenRefreshTimer == null) {
        _setupTokenRefresh();
      }

      Log.info(
        'FirebaseAppCheckService: App Check ${enabled ? 'enabled' : 'disabled'}',
      );
      return const Right(null);
    } catch (e) {
      Log.error('FirebaseAppCheckService: Failed to toggle App Check: $e');
      return Left(TechnicalFailure(message: 'Failed to toggle App Check: $e'));
    }
  }

  /// PATTERN: Proxy Pattern - Validate request before allowing access
  Future<Either<Failure, T>> validateRequest<T>({
    required Future<T> Function() request,
    bool requireValidToken = true,
  }) async {
    if (!_isInitialized || !_appCheckEnabled) {
      // If App Check is disabled, allow request through
      return _executeRequest(request);
    }

    try {
      Log.debug('FirebaseAppCheckService: Validating request');

      // Check if we have a valid token
      if (requireValidToken) {
        if (_currentToken == null || _currentToken!.isExpired) {
          final tokenResult = await getToken(forceRefresh: true);
          if (tokenResult.isLeft()) {
            return Left(tokenResult.fold((l) => l, (r) => throw 'Unreachable'));
          }
        }
      }

      // Execute the validated request
      return _executeRequest(request);
    } catch (e) {
      Log.error('FirebaseAppCheckService: Request validation failed: $e');
      return Left(SecurityFailure(message: 'Request validation failed: $e'));
    }
  }

  /// Execute the actual request
  Future<Either<Failure, T>> _executeRequest<T>(
    Future<T> Function() request,
  ) async {
    try {
      final result = await request();
      Log.debug('FirebaseAppCheckService: Request executed successfully');
      return Right(result);
    } catch (e) {
      Log.error('FirebaseAppCheckService: Request execution failed: $e');
      return Left(TechnicalFailure(message: 'Request execution failed: $e'));
    }
  }

  /// Get current token status
  @override
  Future<Either<Failure, AppCheckTokenStatus>> getTokenStatus() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'App Check not initialized'));
    }

    try {
      final status = AppCheckTokenStatus(
        hasToken: _currentToken != null,
        isExpired: _currentToken?.isExpired ?? true,
        expirationTime: _currentToken?.expirationTimestamp,
        isAutoRefreshEnabled: _tokenRefreshTimer != null,
      );

      return Right(status);
    } catch (e) {
      Log.error('FirebaseAppCheckService: Failed to get token status: $e');
      return Left(TechnicalFailure(message: 'Failed to get token status: $e'));
    }
  }

  /// Dispose service and clean up resources
  Future<void> dispose() async {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
    _currentToken = null;

    Log.debug('FirebaseAppCheckService: Service disposed');
  }
}

/// Tower Defense App Check Helper
///
/// Educational Context: Specific security validation for educational resources
class TowerDefenseAppCheckHelper {
  static final FirebaseAppCheckService _appCheck =
      FirebaseAppCheckService.instance;

  /// Validate educational content access
  static Future<Either<Failure, T>> validateEducationalAccess<T>({
    required String patternName,
    required Future<T> Function() contentRequest,
  }) async {
    return _appCheck.validateRequest(
      request: () async {
        Log.info('Accessing educational content: $patternName');
        return contentRequest();
      },
      requireValidToken: true,
    );
  }

  /// Validate game progress save
  static Future<Either<Failure, void>> validateProgressSave({
    required Map<String, dynamic> progressData,
    required Future<void> Function() saveOperation,
  }) async {
    final result = await _appCheck.validateRequest(
      request: saveOperation,
      requireValidToken: true,
    );

    return result.map((_) {});
  }

  /// Validate user profile operations
  static Future<Either<Failure, T>> validateProfileOperation<T>({
    required String operation,
    required Future<T> Function() profileRequest,
  }) async {
    return _appCheck.validateRequest(
      request: () async {
        Log.info('Profile operation: $operation');
        return profileRequest();
      },
      requireValidToken: true,
    );
  }

  /// Check security status
  static Future<Either<Failure, bool>> checkSecurityStatus() async {
    final statusResult = await _appCheck.getTokenStatus();

    return statusResult.map((status) {
      final isSecure =
          status.hasToken && !status.isExpired && status.isAutoRefreshEnabled;
      Log.debug('Security status check: ${isSecure ? 'SECURE' : 'INSECURE'}');
      return isSecure;
    });
  }
}
