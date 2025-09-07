/// Lifecycle Manager - Central lifecycle management with Observer pattern
///
/// PATTERN: Observer Pattern + Singleton + Template Method
/// WHERE: Core lifecycle management - Central coordinator
/// HOW: Observes app lifecycle changes and coordinates state preservation
/// WHY: Provides centralized, automatic lifecycle management with state persistence
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../../core/logging/logging.dart';
import '../entities/app_state_memento.dart';
import '../entities/lifecycle_event.dart';
import '../patterns/lifecycle_observer_pattern.dart';
import 'state_manager.dart';

/// Central lifecycle manager implementing Observer pattern.
///
/// Coordinates automatic state preservation and restoration across app lifecycle
/// events using Memento pattern for state management.
class LifecycleManager with WidgetsBindingObserver implements LifecycleSubject {
  static LifecycleManager? _instance;
  static final _lock = Object();

  final StateManager _stateManager;
  final List<LifecycleObserver> _observers = [];
  final StreamController<LifecycleEvent> _eventController =
      StreamController<LifecycleEvent>.broadcast();

  AppLifecycleState? _previousState;
  DateTime? _lastStateChangeTime;
  Timer? _backgroundTimer;
  Timer? _saveTimer;
  bool _isInitialized = false;

  // Configuration
  static const Duration _backgroundSaveDelay = Duration(seconds: 2);
  static const Duration _periodicSaveInterval = Duration(minutes: 5);

  LifecycleManager._(this._stateManager) {
    Log.debug('LifecycleManager: Initializing lifecycle management');
  }

  /// Singleton instance access
  factory LifecycleManager.getInstance(StateManager stateManager) {
    if (_instance == null) {
      synchronized(_lock, () {
        _instance ??= LifecycleManager._(stateManager);
      });
    }
    return _instance!;
  }

  /// Get current instance (must be initialized first)
  static LifecycleManager get instance {
    if (_instance == null) {
      throw StateError('LifecycleManager must be initialized before use');
    }
    return _instance!;
  }

  /// Stream of lifecycle events
  Stream<LifecycleEvent> get eventStream => _eventController.stream;

  /// Initialize the lifecycle manager
  Future<void> initialize() async {
    if (_isInitialized) {
      Log.debug('LifecycleManager: Already initialized');
      return;
    }

    try {
      Log.debug('LifecycleManager: Starting initialization');

      // Register as lifecycle observer with Flutter binding
      WidgetsBinding.instance.addObserver(this);

      // Initialize state manager
      await _stateManager.initialize();

      // Restore last saved state if available
      await _restoreApplicationState();

      // Start periodic state saving
      _startPeriodicSaving();

      // Handle platform-specific lifecycle events
      if (Platform.isAndroid || Platform.isIOS) {
        _setupMobileLifecycleHandling();
      }

      _isInitialized = true;
      Log.debug('LifecycleManager: Initialization completed');

      // Notify observers that initialization is complete
      final initEvent = LifecycleEvent(
        eventId: 'init_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        currentState:
            WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
        eventType: LifecycleEventType.stateChange,
        shouldPersistState: false,
        priority: EventPriority.medium,
        source: LifecycleEventSource.system,
        metadata: {'phase': 'initialization'},
      );
      _notifyObservers(initEvent);
    } catch (e) {
      Log.error('LifecycleManager: Initialization failed: $e');
      rethrow;
    }
  }

  /// Dispose of the lifecycle manager
  Future<void> dispose() async {
    Log.debug('LifecycleManager: Starting disposal');

    try {
      // Save current state before disposing
      await _saveApplicationState(immediate: true);

      // Stop timers
      _backgroundTimer?.cancel();
      _saveTimer?.cancel();

      // Remove lifecycle observer
      WidgetsBinding.instance.removeObserver(this);

      // Close event stream
      await _eventController.close();

      // Dispose state manager
      await _stateManager.dispose();

      _isInitialized = false;
      Log.debug('LifecycleManager: Disposal completed');
    } catch (e) {
      Log.error('LifecycleManager: Disposal failed: $e');
    }
  }

  // Observer Pattern Implementation
  @override
  void addObserver(LifecycleObserver observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
      Log.debug(
        'LifecycleManager: Observer added (${_observers.length} total)',
      );
    }
  }

  @override
  void removeObserver(LifecycleObserver observer) {
    if (_observers.remove(observer)) {
      Log.debug(
        'LifecycleManager: Observer removed (${_observers.length} total)',
      );
    }
  }

  void _notifyObservers(LifecycleEvent event) {
    Log.debug(
      'LifecycleManager: Notifying ${_observers.length} observers of ${event.eventType}',
    );

    // Add event to stream
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }

    // Notify observers based on priority
    final sortedObservers = List<LifecycleObserver>.from(_observers)
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

    for (final observer in sortedObservers) {
      try {
        observer.onLifecycleEvent(event);
      } catch (e) {
        Log.error('LifecycleManager: Observer notification failed: $e');
      }
    }
  }

  // Flutter WidgetsBindingObserver Implementation
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Log.debug('LifecycleManager: Lifecycle state changed to $state');
    _handleLifecycleStateChange(state);
  }

  @override
  void didChangeAccessibilityFeatures() {
    _handleAccessibilityChange();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    _handleLocaleChange(locales);
  }

  @override
  void didChangeTextScaleFactor() {
    _handleTextScaleFactorChange();
  }

  @override
  void didChangePlatformBrightness() {
    _handlePlatformBrightnessChange();
  }

  @override
  void didHaveMemoryPressure() {
    _handleMemoryPressure();
  }

  // Core Lifecycle Handling
  void _handleLifecycleStateChange(AppLifecycleState newState) {
    final now = DateTime.now();
    final previousState = _previousState;
    final stateDuration = _lastStateChangeTime != null
        ? now.difference(_lastStateChangeTime!)
        : null;

    // Create lifecycle event
    LifecycleEvent event;

    if (newState.isBackground && !(previousState?.isBackground ?? true)) {
      // App is going to background
      event = LifecycleEvent.appBackgrounded(
        previousState: previousState,
        currentState: newState,
        stateDuration: stateDuration,
        metadata: {
          'platform': Platform.operatingSystem,
          'timestamp': now.toIso8601String(),
        },
      );
    } else if (newState.isActive && (previousState?.isBackground ?? false)) {
      // App is coming to foreground
      event = LifecycleEvent.appForegrounded(
        previousState: previousState,
        currentState: newState,
        stateDuration: stateDuration,
        metadata: {
          'platform': Platform.operatingSystem,
          'timestamp': now.toIso8601String(),
        },
      );
    } else if (newState == AppLifecycleState.detached) {
      // App is terminating
      event = LifecycleEvent.appTerminating(
        previousState: previousState,
        stateDuration: stateDuration,
        metadata: {
          'platform': Platform.operatingSystem,
          'timestamp': now.toIso8601String(),
        },
      );
    } else {
      // General state change
      event = LifecycleEvent(
        eventId: 'state_${now.millisecondsSinceEpoch}',
        timestamp: now,
        previousState: previousState,
        currentState: newState,
        eventType: LifecycleEventType.stateChange,
        stateDuration: stateDuration,
        shouldPersistState: newState.persistencePriority > 5,
        priority: EventPriority.medium,
        source: LifecycleEventSource.system,
        metadata: {
          'platform': Platform.operatingSystem,
          'timestamp': now.toIso8601String(),
        },
      );
    }

    // Update tracking variables
    _previousState = newState;
    _lastStateChangeTime = now;

    // Handle state persistence
    if (event.shouldPersistState) {
      _scheduleStateSave(event);
    }

    // Restore state if coming from background
    if (event.isForegrounding) {
      _restoreApplicationState();
    }

    // Notify observers
    _notifyObservers(event);
  }

  void _handleMemoryPressure() {
    Log.warning('LifecycleManager: Memory pressure detected');

    final event = LifecycleEvent(
      eventId: 'memory_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      currentState:
          WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
      eventType: LifecycleEventType.lowMemory,
      shouldPersistState: true,
      priority: EventPriority.high,
      source: LifecycleEventSource.system,
      metadata: {'reason': 'memory_pressure'},
    );

    // Immediate state save due to memory pressure
    _scheduleStateSave(event, immediate: true);
    _notifyObservers(event);
  }

  void _handleAccessibilityChange() {
    final event = LifecycleEvent(
      eventId: 'a11y_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      currentState:
          WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
      eventType: LifecycleEventType.stateChange,
      shouldPersistState: false,
      priority: EventPriority.low,
      source: LifecycleEventSource.system,
      metadata: {'change_type': 'accessibility'},
    );

    _notifyObservers(event);
  }

  void _handleLocaleChange(List<Locale>? locales) {
    final event = LifecycleEvent(
      eventId: 'locale_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      currentState:
          WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
      eventType: LifecycleEventType.stateChange,
      shouldPersistState: false,
      priority: EventPriority.medium,
      source: LifecycleEventSource.system,
      metadata: {
        'change_type': 'locale',
        'locales': locales?.map((l) => l.toString()).toList(),
      },
    );

    _notifyObservers(event);
  }

  void _handleTextScaleFactorChange() {
    final event = LifecycleEvent(
      eventId: 'scale_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      currentState:
          WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
      eventType: LifecycleEventType.stateChange,
      shouldPersistState: false,
      priority: EventPriority.low,
      source: LifecycleEventSource.system,
      metadata: {'change_type': 'text_scale'},
    );

    _notifyObservers(event);
  }

  void _handlePlatformBrightnessChange() {
    final event = LifecycleEvent(
      eventId: 'brightness_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      currentState:
          WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
      eventType: LifecycleEventType.stateChange,
      shouldPersistState: false,
      priority: EventPriority.low,
      source: LifecycleEventSource.system,
      metadata: {'change_type': 'brightness'},
    );

    _notifyObservers(event);
  }

  // State Management
  void _scheduleStateSave(LifecycleEvent event, {bool immediate = false}) {
    if (event.priority == EventPriority.critical || immediate) {
      // Save immediately for critical events
      _saveApplicationState(immediate: true);
    } else {
      // Debounced save for other events
      _backgroundTimer?.cancel();
      _backgroundTimer = Timer(_backgroundSaveDelay, () {
        _saveApplicationState();
      });
    }
  }

  Future<void> _saveApplicationState({bool immediate = false}) async {
    try {
      Log.debug(
        'LifecycleManager: Saving application state (immediate: $immediate)',
      );

      final memento = await _captureCurrentState();
      await _stateManager.saveState(memento);

      Log.success('LifecycleManager: Application state saved successfully');
    } catch (e) {
      Log.error('LifecycleManager: Failed to save application state: $e');
    }
  }

  Future<void> _restoreApplicationState() async {
    try {
      Log.debug('LifecycleManager: Restoring application state');

      final memento = await _stateManager.getLastSavedState();
      if (memento != null && !memento.isStale(const Duration(hours: 24))) {
        await _applyStateMemento(memento);
        Log.success(
          'LifecycleManager: Application state restored successfully',
        );
      } else {
        Log.debug(
          'LifecycleManager: No valid saved state found or state is stale',
        );
      }
    } catch (e) {
      Log.error('LifecycleManager: Failed to restore application state: $e');
    }
  }

  Future<AppStateMemento> _captureCurrentState() async {
    // TODO: Collect state from all registered observers
    // For now, create a basic memento
    return AppStateMemento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      lifecycleState:
          WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
      currentRoute: '/',
      // TODO: Get from navigation
      navigationStack: ['/'],
      // TODO: Get from navigation
      userSession: {},
      // TODO: Get from user session
      uiState: {},
      // TODO: Get from UI state
      patternStates: {},
      // TODO: Get from pattern pages
      appConfig: {},
      // TODO: Get from configuration
      backgroundTasks: {},
      // TODO: Get from background tasks
      networkStates: {},
      // TODO: Get from network manager
      animationStates: {},
      // TODO: Get from animation controllers
      firebaseState: {},
      // TODO: Get from Firebase
      localizationState: {}, // TODO: Get from localization
    );
  }

  Future<void> _applyStateMemento(AppStateMemento memento) async {
    // TODO: Apply state to all registered observers
    Log.debug(
      'LifecycleManager: Applying state memento from ${memento.timestamp}',
    );
  }

  void _startPeriodicSaving() {
    _saveTimer = Timer.periodic(_periodicSaveInterval, (timer) {
      if (_isInitialized) {
        _saveApplicationState();
      }
    });
  }

  void _setupMobileLifecycleHandling() {
    // Additional mobile-specific lifecycle handling can be added here
    Log.debug('LifecycleManager: Mobile lifecycle handling configured');
  }

  // Utility method for synchronization
  static T synchronized<T>(Object lock, T Function() computation) {
    // Simple synchronization - in production, consider using a proper lock mechanism
    return computation();
  }

  /// Manual state save trigger
  Future<void> saveState() async {
    final event = LifecycleEvent.manualSave(
      currentState:
          WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
      metadata: {'trigger': 'manual'},
    );

    await _saveApplicationState(immediate: true);
    _notifyObservers(event);
  }

  /// Get the current lifecycle state
  AppLifecycleState get currentState =>
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.detached;

  /// Check if the lifecycle manager is initialized
  bool get isInitialized => _isInitialized;
}
