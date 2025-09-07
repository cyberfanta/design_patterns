/// Lifecycle Observer Pattern - Abstract observer pattern for lifecycle events
///
/// PATTERN: Observer Pattern (Abstract Implementation)
/// WHERE: Core lifecycle management - Observer pattern contracts
/// HOW: Defines observer interfaces for lifecycle event notifications
/// WHY: Enables loose coupling between lifecycle events and their handlers
library;

import '../entities/lifecycle_event.dart';

/// Abstract observer interface for lifecycle events.
///
/// Components that need to respond to app lifecycle changes should implement
/// this interface and register with the LifecycleManager.
abstract class LifecycleObserver {
  /// Priority level for this observer (higher = executed first)
  EventPriority get priority => EventPriority.medium;

  /// Unique identifier for this observer
  String get observerId;

  /// Called when a lifecycle event occurs
  void onLifecycleEvent(LifecycleEvent event);

  /// Called when the observer is registered
  void onRegistered() {}

  /// Called when the observer is unregistered
  void onUnregistered() {}

  /// Filter to determine which events this observer should receive
  bool shouldHandleEvent(LifecycleEvent event) => true;
}

/// Abstract subject interface for lifecycle events.
///
/// The LifecycleManager implements this interface to manage observers.
abstract class LifecycleSubject {
  /// Add an observer to receive lifecycle events
  void addObserver(LifecycleObserver observer);

  /// Remove an observer from receiving lifecycle events
  void removeObserver(LifecycleObserver observer);
}

/// Specialized observer for state persistence events
abstract class StateAwareObserver extends LifecycleObserver {
  /// Capture the current state of this component
  Map<String, dynamic> captureState();

  /// Restore the state of this component
  Future<void> restoreState(Map<String, dynamic> state);

  /// Validate that the provided state is compatible with this component
  bool validateState(Map<String, dynamic> state) => true;

  /// Get the state key for this observer (used in AppStateMemento)
  String get stateKey;

  @override
  bool shouldHandleEvent(LifecycleEvent event) {
    return event.shouldPersistState || event.isForegrounding;
  }
}

/// Observer for UI-specific lifecycle events
abstract class UILifecycleObserver extends StateAwareObserver {
  @override
  EventPriority get priority => EventPriority.high;

  /// Called when the UI should prepare for backgrounding
  void onUIBackgrounding(LifecycleEvent event) {}

  /// Called when the UI should restore from backgrounding
  void onUIForegrounding(LifecycleEvent event) {}

  /// Called when memory pressure is detected
  void onMemoryPressure(LifecycleEvent event) {}

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event.isBackgrounding) {
      onUIBackgrounding(event);
    } else if (event.isForegrounding) {
      onUIForegrounding(event);
    } else if (event.eventType == LifecycleEventType.lowMemory) {
      onMemoryPressure(event);
    }
  }
}

/// Observer for navigation-specific lifecycle events
abstract class NavigationLifecycleObserver extends StateAwareObserver {
  @override
  String get stateKey => 'navigation';

  @override
  EventPriority get priority => EventPriority.high;

  /// Called when navigation state should be preserved
  void onNavigationSaveState(LifecycleEvent event) {}

  /// Called when navigation state should be restored
  void onNavigationRestoreState(LifecycleEvent event) {}

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event.shouldPersistState) {
      onNavigationSaveState(event);
    } else if (event.isForegrounding) {
      onNavigationRestoreState(event);
    }
  }
}

/// Observer for user session lifecycle events
abstract class SessionLifecycleObserver extends StateAwareObserver {
  @override
  String get stateKey => 'session';

  @override
  EventPriority get priority => EventPriority.critical;

  /// Called when user session should be preserved
  void onSessionSaveState(LifecycleEvent event) {}

  /// Called when user session should be restored
  void onSessionRestoreState(LifecycleEvent event) {}

  /// Called when session should be cleared (app terminating)
  void onSessionClear(LifecycleEvent event) {}

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event.isTerminating) {
      onSessionClear(event);
    } else if (event.shouldPersistState) {
      onSessionSaveState(event);
    } else if (event.isForegrounding) {
      onSessionRestoreState(event);
    }
  }
}

/// Observer for pattern-specific lifecycle events (behavioral patterns page, etc.)
abstract class PatternLifecycleObserver extends StateAwareObserver {
  @override
  String get stateKey => 'patterns';

  @override
  EventPriority get priority => EventPriority.medium;

  /// The specific pattern category this observer handles
  String get patternCategory;

  /// Called when pattern state should be preserved
  void onPatternSaveState(LifecycleEvent event) {}

  /// Called when pattern state should be restored
  void onPatternRestoreState(LifecycleEvent event) {}

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event.shouldPersistState) {
      onPatternSaveState(event);
    } else if (event.isForegrounding) {
      onPatternRestoreState(event);
    }
  }
}

/// Observer for animation lifecycle events
abstract class AnimationLifecycleObserver extends LifecycleObserver {
  @override
  EventPriority get priority => EventPriority.medium;

  /// Called when animations should be paused
  void onAnimationsPause(LifecycleEvent event) {}

  /// Called when animations should be resumed
  void onAnimationsResume(LifecycleEvent event) {}

  /// Called when animations should be disposed due to memory pressure
  void onAnimationsDispose(LifecycleEvent event) {}

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event.isBackgrounding) {
      onAnimationsPause(event);
    } else if (event.isForegrounding) {
      onAnimationsResume(event);
    } else if (event.eventType == LifecycleEventType.lowMemory) {
      onAnimationsDispose(event);
    }
  }
}

/// Observer for network-related lifecycle events
abstract class NetworkLifecycleObserver extends StateAwareObserver {
  @override
  String get stateKey => 'network';

  @override
  EventPriority get priority => EventPriority.high;

  /// Called when network operations should be paused
  void onNetworkPause(LifecycleEvent event) {}

  /// Called when network operations should be resumed
  void onNetworkResume(LifecycleEvent event) {}

  /// Called when network state should be cleaned up
  void onNetworkCleanup(LifecycleEvent event) {}

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event.isBackgrounding) {
      onNetworkPause(event);
    } else if (event.isForegrounding) {
      onNetworkResume(event);
    } else if (event.isTerminating) {
      onNetworkCleanup(event);
    }
  }
}

/// Mixin for automatic observer registration/unregistration
mixin AutoLifecycleObserver on LifecycleObserver {
  bool _isRegistered = false;

  /// Automatically register with the LifecycleManager
  void autoRegister() {
    if (!_isRegistered) {
      // Note: This would need LifecycleManager.instance.addObserver(this);
      // but we want to avoid circular dependencies
      _isRegistered = true;
      onRegistered();
    }
  }

  /// Automatically unregister from the LifecycleManager
  void autoUnregister() {
    if (_isRegistered) {
      // Note: This would need LifecycleManager.instance.removeObserver(this);
      // but we want to avoid circular dependencies
      _isRegistered = false;
      onUnregistered();
    }
  }

  /// Check if this observer is registered
  bool get isRegistered => _isRegistered;
}

/// Observer that combines multiple observer types
abstract class CompositeLifecycleObserver extends LifecycleObserver {
  final List<LifecycleObserver> _observers = [];

  /// Add a child observer
  void addChildObserver(LifecycleObserver observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  /// Remove a child observer
  void removeChildObserver(LifecycleObserver observer) {
    _observers.remove(observer);
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    // Forward event to all child observers
    for (final observer in _observers) {
      if (observer.shouldHandleEvent(event)) {
        try {
          observer.onLifecycleEvent(event);
        } catch (e) {
          // Log error but continue with other observers
          // Log.error would be used here
        }
      }
    }
  }

  @override
  void onRegistered() {
    for (final observer in _observers) {
      observer.onRegistered();
    }
  }

  @override
  void onUnregistered() {
    for (final observer in _observers) {
      observer.onUnregistered();
    }
  }

  /// Get all child observers
  List<LifecycleObserver> get childObservers => List.unmodifiable(_observers);
}
