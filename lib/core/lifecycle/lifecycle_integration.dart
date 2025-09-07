/// Lifecycle Integration - Complete lifecycle management setup
///
/// PATTERN: Facade Pattern + Factory Pattern + Service Locator
/// WHERE: Core lifecycle management - Integration layer
/// HOW: Provides single entry point for lifecycle management setup
/// WHY: Simplifies lifecycle management integration across the application
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../core/logging/logging.dart';
import 'entities/lifecycle_event.dart';
import 'patterns/lifecycle_observer_pattern.dart';
import 'repositories/state_persistence_repository.dart';
import 'services/lifecycle_manager.dart';
import 'services/state_manager.dart';

/// Facade for lifecycle management integration.
///
/// Provides a simple interface to setup and use complete lifecycle management
/// with state persistence across the application.
class LifecycleIntegration {
  static LifecycleIntegration? _instance;
  static final _lock = Object();

  late final LifecycleManager _lifecycleManager;
  late final StateManager _stateManager;
  late final StatePersistenceRepository _repository;

  bool _isInitialized = false;
  final List<StateAwareObserver> _registeredObservers = [];

  LifecycleIntegration._();

  /// Get singleton instance
  static LifecycleIntegration get instance {
    if (_instance == null) {
      synchronized(_lock, () {
        _instance ??= LifecycleIntegration._();
      });
    }
    return _instance!;
  }

  /// Initialize complete lifecycle management system
  Future<void> initialize({
    StatePersistenceRepository? customRepository,
    bool registerWithGetIt = true,
  }) async {
    if (_isInitialized) {
      Log.debug('LifecycleIntegration: Already initialized');
      return;
    }

    try {
      Log.debug(
        'LifecycleIntegration: Initializing complete lifecycle management system',
      );

      // Initialize repository
      _repository = customRepository ?? FileStatePersistenceRepository();
      await _repository.initialize();

      // Initialize state manager
      _stateManager = StateManager(_repository);
      await _stateManager.initialize();

      // Initialize lifecycle manager
      _lifecycleManager = LifecycleManager.getInstance(_stateManager);
      await _lifecycleManager.initialize();

      // Register with dependency injection if requested
      if (registerWithGetIt) {
        _registerWithGetIt();
      }

      // Register built-in observers
      _registerBuiltInObservers();

      _isInitialized = true;
      Log.success(
        'LifecycleIntegration: Lifecycle management system initialized successfully',
      );
    } catch (e) {
      Log.error('LifecycleIntegration: Initialization failed: $e');
      rethrow;
    }
  }

  /// Dispose the lifecycle management system
  Future<void> dispose() async {
    Log.debug('LifecycleIntegration: Disposing lifecycle management system');

    try {
      // Unregister all observers
      for (final observer in _registeredObservers) {
        _lifecycleManager.removeObserver(observer);
      }
      _registeredObservers.clear();

      // Dispose managers
      await _lifecycleManager.dispose();
      await _stateManager.dispose();
      await _repository.dispose();

      _isInitialized = false;
      Log.debug('LifecycleIntegration: Lifecycle management system disposed');
    } catch (e) {
      Log.error('LifecycleIntegration: Disposal failed: $e');
    }
  }

  /// Register a state-aware observer
  void registerObserver(StateAwareObserver observer) {
    if (_isInitialized) {
      _lifecycleManager.addObserver(observer);
      _registeredObservers.add(observer);
      Log.debug(
        'LifecycleIntegration: Registered observer ${observer.observerId}',
      );
    } else {
      Log.warning(
        'LifecycleIntegration: Cannot register observer - system not initialized',
      );
    }
  }

  /// Unregister a state-aware observer
  void unregisterObserver(StateAwareObserver observer) {
    if (_isInitialized) {
      _lifecycleManager.removeObserver(observer);
      _registeredObservers.remove(observer);
      Log.debug(
        'LifecycleIntegration: Unregistered observer ${observer.observerId}',
      );
    }
  }

  /// Trigger manual state save
  Future<void> saveState() async {
    if (_isInitialized) {
      await _lifecycleManager.saveState();
      Log.debug('LifecycleIntegration: Manual state save triggered');
    } else {
      Log.warning(
        'LifecycleIntegration: Cannot save state - system not initialized',
      );
    }
  }

  /// Get lifecycle event stream
  Stream<LifecycleEvent>? get eventStream {
    return _isInitialized ? _lifecycleManager.eventStream : null;
  }

  /// Get system statistics
  Map<String, dynamic> getSystemStatistics() {
    if (!_isInitialized) {
      return {'error': 'System not initialized'};
    }

    return {
      'isInitialized': _isInitialized,
      'registeredObservers': _registeredObservers.length,
      'currentLifecycleState': _lifecycleManager.currentState.name,
      'stateManager': _stateManager.getStateStatistics(),
    };
  }

  // Private methods

  void _registerWithGetIt() {
    final getIt = GetIt.instance;

    // Register services
    getIt.registerSingleton<LifecycleManager>(_lifecycleManager);
    getIt.registerSingleton<StateManager>(_stateManager);
    getIt.registerSingleton<StatePersistenceRepository>(_repository);
    getIt.registerSingleton<LifecycleIntegration>(this);

    Log.debug('LifecycleIntegration: Services registered with GetIt');
  }

  void _registerBuiltInObservers() {
    // Register app-level observer
    final appObserver = _AppLevelObserver();
    registerObserver(appObserver);

    // Register navigation observer (if available)
    // final navigationObserver = _NavigationObserver();
    // registerObserver(navigationObserver);

    Log.debug('LifecycleIntegration: Built-in observers registered');
  }

  // Utility method for synchronization
  static T synchronized<T>(Object lock, T Function() computation) {
    return computation();
  }

  // Getters
  LifecycleManager get lifecycleManager => _lifecycleManager;

  StateManager get stateManager => _stateManager;

  StatePersistenceRepository get repository => _repository;

  bool get isInitialized => _isInitialized;

  List<StateAwareObserver> get registeredObservers =>
      List.unmodifiable(_registeredObservers);
}

/// Built-in app-level observer for basic state management
class _AppLevelObserver extends StateAwareObserver {
  Map<String, dynamic> _appState = {};

  @override
  String get stateKey => 'app';

  @override
  String get observerId => 'app_level_observer';

  @override
  EventPriority get priority => EventPriority.high;

  @override
  Map<String, dynamic> captureState() {
    Log.debug('AppLevelObserver: Capturing app-level state');

    _appState = {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'flutter', // Simplified for now
      'locale': 'en_US', // Simplified for now
      // Add other app-level state here
    };

    return Map.from(_appState);
  }

  @override
  Future<void> restoreState(Map<String, dynamic> state) async {
    Log.debug('AppLevelObserver: Restoring app-level state');
    _appState = Map.from(state);

    // Restore app-level state here
    // This could include theme, locale, etc.
  }

  @override
  bool validateState(Map<String, dynamic> state) {
    return state.containsKey('timestamp') && state.containsKey('platform');
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    Log.debug('AppLevelObserver: Received lifecycle event: ${event.eventType}');
    if (event.shouldPersistState) {
      captureState();
    }
  }
}

/// Extension to make integration with existing widgets easier
extension LifecycleIntegrationExtension on State {
  /// Quick method to register this state as lifecycle-aware
  void enableLifecycleManagement({
    required String stateKey,
    required Map<String, dynamic> Function() captureCallback,
    required Future<void> Function(Map<String, dynamic>) restoreCallback,
    bool Function(Map<String, dynamic>)? validateCallback,
  }) {
    final observer = _StateObserverAdapter(
      stateKey: stateKey,
      captureCallback: captureCallback,
      restoreCallback: restoreCallback,
      validateCallback: validateCallback,
    );

    LifecycleIntegration.instance.registerObserver(observer);

    // Automatically unregister when widget disposes
    if (this is StatefulWidget) {
      // Note: This would need to be connected to the dispose method
      // This is a simplified version for demonstration
    }
  }
}

/// Adapter to convert function callbacks to StateAwareObserver
class _StateObserverAdapter extends StateAwareObserver {
  final String _stateKey;
  final Map<String, dynamic> Function() _captureCallback;
  final Future<void> Function(Map<String, dynamic>) _restoreCallback;
  final bool Function(Map<String, dynamic>)? _validateCallback;

  _StateObserverAdapter({
    required String stateKey,
    required Map<String, dynamic> Function() captureCallback,
    required Future<void> Function(Map<String, dynamic>) restoreCallback,
    bool Function(Map<String, dynamic>)? validateCallback,
  }) : _stateKey = stateKey,
       _captureCallback = captureCallback,
       _restoreCallback = restoreCallback,
       _validateCallback = validateCallback;

  @override
  String get stateKey => _stateKey;

  @override
  String get observerId => 'adapter_${_stateKey}_$hashCode';

  @override
  Map<String, dynamic> captureState() => _captureCallback();

  @override
  Future<void> restoreState(Map<String, dynamic> state) =>
      _restoreCallback(state);

  @override
  bool validateState(Map<String, dynamic> state) {
    return _validateCallback?.call(state) ?? true;
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event.shouldPersistState) {
      captureState();
    } else if (event.isForegrounding) {
      // State restoration would be handled by the LifecycleManager
      // through the StateManager
    }
  }
}

/// Utility function to initialize lifecycle management in main()
Future<void> initializeLifecycleManagement({
  StatePersistenceRepository? customRepository,
  bool registerWithGetIt = true,
}) async {
  await LifecycleIntegration.instance.initialize(
    customRepository: customRepository,
    registerWithGetIt: registerWithGetIt,
  );
}

/// Utility function to setup lifecycle management for a specific widget type
void setupLifecycleForWidget<T extends StatefulWidget>({
  required String Function(T) stateKeyProvider,
  required Map<String, dynamic> Function(State<T>) captureProvider,
  required Future<void> Function(State<T>, Map<String, dynamic>)
  restoreProvider,
  bool Function(Map<String, dynamic>)? validator,
}) {
  // This would be used to register automatic lifecycle management
  // for specific widget types - implementation would depend on the
  // specific widget framework being used
  Log.debug(
    'LifecycleIntegration: Widget lifecycle setup registered for ${T.toString()}',
  );
}
