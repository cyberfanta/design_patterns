/// Lifecycle Event - Event entity for lifecycle state changes
///
/// PATTERN: Event Pattern + Value Object
/// WHERE: Core lifecycle management - Event representation
/// HOW: Represents lifecycle state change events with comprehensive metadata
/// WHY: Provides detailed context for lifecycle transitions and state management
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Represents a lifecycle event with comprehensive context information.
///
/// Used by the Observer pattern to notify components of app lifecycle changes
/// and trigger appropriate Memento state preservation/restoration actions.
class LifecycleEvent extends Equatable {
  /// Unique identifier for this event
  final String eventId;

  /// Timestamp when the event occurred
  final DateTime timestamp;

  /// Previous lifecycle state
  final AppLifecycleState? previousState;

  /// Current lifecycle state
  final AppLifecycleState currentState;

  /// Event type classification
  final LifecycleEventType eventType;

  /// Duration the app was in the previous state
  final Duration? stateDuration;

  /// Additional metadata about the event
  final Map<String, dynamic> metadata;

  /// Whether this event should trigger state persistence
  final bool shouldPersistState;

  /// Priority level for handling this event
  final EventPriority priority;

  /// Source of the lifecycle event
  final LifecycleEventSource source;

  const LifecycleEvent({
    required this.eventId,
    required this.timestamp,
    this.previousState,
    required this.currentState,
    required this.eventType,
    this.stateDuration,
    this.metadata = const {},
    required this.shouldPersistState,
    required this.priority,
    required this.source,
  });

  /// Create a lifecycle event for app backgrounding
  factory LifecycleEvent.appBackgrounded({
    AppLifecycleState? previousState,
    required AppLifecycleState currentState,
    Duration? stateDuration,
    Map<String, dynamic> metadata = const {},
  }) {
    return LifecycleEvent(
      eventId: 'bg_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      previousState: previousState,
      currentState: currentState,
      eventType: LifecycleEventType.backgrounding,
      stateDuration: stateDuration,
      metadata: metadata,
      shouldPersistState: true,
      priority: EventPriority.high,
      source: LifecycleEventSource.system,
    );
  }

  /// Create a lifecycle event for app foregrounding
  factory LifecycleEvent.appForegrounded({
    AppLifecycleState? previousState,
    required AppLifecycleState currentState,
    Duration? stateDuration,
    Map<String, dynamic> metadata = const {},
  }) {
    return LifecycleEvent(
      eventId: 'fg_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      previousState: previousState,
      currentState: currentState,
      eventType: LifecycleEventType.foregrounding,
      stateDuration: stateDuration,
      metadata: metadata,
      shouldPersistState: false,
      priority: EventPriority.high,
      source: LifecycleEventSource.system,
    );
  }

  /// Create a lifecycle event for app termination
  factory LifecycleEvent.appTerminating({
    AppLifecycleState? previousState,
    Duration? stateDuration,
    Map<String, dynamic> metadata = const {},
  }) {
    return LifecycleEvent(
      eventId: 'term_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      previousState: previousState,
      currentState: AppLifecycleState.detached,
      eventType: LifecycleEventType.terminating,
      stateDuration: stateDuration,
      metadata: metadata,
      shouldPersistState: true,
      priority: EventPriority.critical,
      source: LifecycleEventSource.system,
    );
  }

  /// Create a manual state save event
  factory LifecycleEvent.manualSave({
    required AppLifecycleState currentState,
    Map<String, dynamic> metadata = const {},
  }) {
    return LifecycleEvent(
      eventId: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      currentState: currentState,
      eventType: LifecycleEventType.manualSave,
      metadata: metadata,
      shouldPersistState: true,
      priority: EventPriority.medium,
      source: LifecycleEventSource.user,
    );
  }

  /// Create an event from Map (deserialization)
  factory LifecycleEvent.fromMap(Map<String, dynamic> map) {
    return LifecycleEvent(
      eventId: map['eventId'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      previousState: _parseLifecycleState(map['previousState']),
      currentState:
          _parseLifecycleState(map['currentState']) ??
          AppLifecycleState.detached,
      eventType:
          _parseEventType(map['eventType']) ?? LifecycleEventType.stateChange,
      stateDuration: map['stateDuration'] != null
          ? Duration(milliseconds: map['stateDuration'])
          : null,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      shouldPersistState: map['shouldPersistState'] ?? false,
      priority: _parseEventPriority(map['priority']) ?? EventPriority.medium,
      source: _parseEventSource(map['source']) ?? LifecycleEventSource.system,
    );
  }

  /// Convert event to Map (serialization)
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'previousState': previousState?.name,
      'currentState': currentState.name,
      'eventType': eventType.name,
      'stateDuration': stateDuration?.inMilliseconds,
      'metadata': metadata,
      'shouldPersistState': shouldPersistState,
      'priority': priority.name,
      'source': source.name,
    };
  }

  /// Check if this event indicates the app is going to background
  bool get isBackgrounding {
    return eventType == LifecycleEventType.backgrounding ||
        (currentState == AppLifecycleState.paused ||
            currentState == AppLifecycleState.detached);
  }

  /// Check if this event indicates the app is coming to foreground
  bool get isForegrounding {
    return eventType == LifecycleEventType.foregrounding ||
        (currentState == AppLifecycleState.resumed &&
            (previousState == AppLifecycleState.paused ||
                previousState == AppLifecycleState.detached));
  }

  /// Check if this event indicates app termination
  bool get isTerminating {
    return eventType == LifecycleEventType.terminating ||
        currentState == AppLifecycleState.detached;
  }

  /// Get the age of this event in seconds
  int getAgeInSeconds() {
    return DateTime.now().difference(timestamp).inSeconds;
  }

  @override
  List<Object?> get props => [
    eventId,
    timestamp,
    previousState,
    currentState,
    eventType,
    stateDuration,
    metadata,
    shouldPersistState,
    priority,
    source,
  ];

  /// Helper method to parse lifecycle state from string
  static AppLifecycleState? _parseLifecycleState(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'resumed':
        return AppLifecycleState.resumed;
      case 'inactive':
        return AppLifecycleState.inactive;
      case 'paused':
        return AppLifecycleState.paused;
      case 'detached':
        return AppLifecycleState.detached;
      case 'hidden':
        return AppLifecycleState.hidden;
      default:
        return null;
    }
  }

  /// Helper method to parse event type from string
  static LifecycleEventType? _parseEventType(String? value) {
    if (value == null) return null;
    return LifecycleEventType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => LifecycleEventType.stateChange,
    );
  }

  /// Helper method to parse event priority from string
  static EventPriority? _parseEventPriority(String? value) {
    if (value == null) return null;
    return EventPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => EventPriority.medium,
    );
  }

  /// Helper method to parse event source from string
  static LifecycleEventSource? _parseEventSource(String? value) {
    if (value == null) return null;
    return LifecycleEventSource.values.firstWhere(
      (source) => source.name == value,
      orElse: () => LifecycleEventSource.system,
    );
  }
}

/// Types of lifecycle events
enum LifecycleEventType {
  /// General state change
  stateChange,

  /// App is going to background
  backgrounding,

  /// App is coming to foreground
  foregrounding,

  /// App is terminating
  terminating,

  /// Manual state save requested
  manualSave,

  /// Low memory warning
  lowMemory,

  /// Network connectivity change
  connectivityChange,

  /// Battery level change
  batteryChange,

  /// Device orientation change
  orientationChange,
}

/// Priority levels for event handling
enum EventPriority {
  /// Low priority - can be delayed
  low,

  /// Medium priority - normal handling
  medium,

  /// High priority - handle quickly
  high,

  /// Critical priority - handle immediately
  critical,
}

/// Sources of lifecycle events
enum LifecycleEventSource {
  /// System-generated event
  system,

  /// User-initiated event
  user,

  /// Application-generated event
  application,

  /// Network-related event
  network,

  /// Device-related event
  device,
}

/// Extension methods for LifecycleEventType
extension LifecycleEventTypeExtension on LifecycleEventType {
  /// Get default priority for this event type
  EventPriority get defaultPriority {
    switch (this) {
      case LifecycleEventType.terminating:
        return EventPriority.critical;
      case LifecycleEventType.backgrounding:
      case LifecycleEventType.foregrounding:
      case LifecycleEventType.lowMemory:
        return EventPriority.high;
      case LifecycleEventType.manualSave:
      case LifecycleEventType.connectivityChange:
        return EventPriority.medium;
      case LifecycleEventType.stateChange:
      case LifecycleEventType.batteryChange:
      case LifecycleEventType.orientationChange:
        return EventPriority.low;
    }
  }

  /// Check if this event type should trigger state persistence
  bool get shouldTriggerPersistence {
    switch (this) {
      case LifecycleEventType.backgrounding:
      case LifecycleEventType.terminating:
      case LifecycleEventType.manualSave:
      case LifecycleEventType.lowMemory:
        return true;
      case LifecycleEventType.foregrounding:
      case LifecycleEventType.stateChange:
      case LifecycleEventType.connectivityChange:
      case LifecycleEventType.batteryChange:
      case LifecycleEventType.orientationChange:
        return false;
    }
  }
}
