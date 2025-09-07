/// App State Memento - State snapshot entity for lifecycle management
///
/// PATTERN: Memento Pattern + Value Object
/// WHERE: Core lifecycle management - State snapshot entity
/// HOW: Captures complete application state at specific moments in time
/// WHY: Enables automatic state preservation and restoration across app lifecycle events
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Represents a complete snapshot of application state.
///
/// This memento captures all critical application data that should be preserved
/// when the app goes to background and restored when it returns to foreground.
class AppStateMemento extends Equatable {
  /// Unique identifier for this state snapshot
  final String id;

  /// Timestamp when this state was captured
  final DateTime timestamp;

  /// Application lifecycle state when captured
  final AppLifecycleState lifecycleState;

  /// Current route information
  final String currentRoute;

  /// Navigation stack state
  final List<String> navigationStack;

  /// User session data
  final Map<String, dynamic> userSession;

  /// UI state data (forms, selections, etc.)
  final Map<String, dynamic> uiState;

  /// Pattern-specific states (behavioral patterns page, etc.)
  final Map<String, dynamic> patternStates;

  /// Configuration and preferences
  final Map<String, dynamic> appConfig;

  /// Background task states
  final Map<String, dynamic> backgroundTasks;

  /// Network request states
  final Map<String, dynamic> networkStates;

  /// Animation states
  final Map<String, dynamic> animationStates;

  /// Tower Defense game state (if applicable)
  final Map<String, dynamic>? gameState;

  /// Firebase connection state
  final Map<String, dynamic> firebaseState;

  /// Locale and language state
  final Map<String, dynamic> localizationState;

  const AppStateMemento({
    required this.id,
    required this.timestamp,
    required this.lifecycleState,
    required this.currentRoute,
    required this.navigationStack,
    required this.userSession,
    required this.uiState,
    required this.patternStates,
    required this.appConfig,
    required this.backgroundTasks,
    required this.networkStates,
    required this.animationStates,
    this.gameState,
    required this.firebaseState,
    required this.localizationState,
  });

  /// Create an empty memento for initialization
  factory AppStateMemento.empty() {
    return AppStateMemento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      lifecycleState: AppLifecycleState.detached,
      currentRoute: '/',
      navigationStack: ['/'],
      userSession: {},
      uiState: {},
      patternStates: {},
      appConfig: {},
      backgroundTasks: {},
      networkStates: {},
      animationStates: {},
      firebaseState: {},
      localizationState: {},
    );
  }

  /// Create a memento from Map (for deserialization)
  factory AppStateMemento.fromMap(Map<String, dynamic> map) {
    return AppStateMemento(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      lifecycleState: _parseLifecycleState(map['lifecycleState']),
      currentRoute: map['currentRoute'] ?? '/',
      navigationStack: List<String>.from(map['navigationStack'] ?? ['/']),
      userSession: Map<String, dynamic>.from(map['userSession'] ?? {}),
      uiState: Map<String, dynamic>.from(map['uiState'] ?? {}),
      patternStates: Map<String, dynamic>.from(map['patternStates'] ?? {}),
      appConfig: Map<String, dynamic>.from(map['appConfig'] ?? {}),
      backgroundTasks: Map<String, dynamic>.from(map['backgroundTasks'] ?? {}),
      networkStates: Map<String, dynamic>.from(map['networkStates'] ?? {}),
      animationStates: Map<String, dynamic>.from(map['animationStates'] ?? {}),
      gameState: map['gameState'] != null
          ? Map<String, dynamic>.from(map['gameState'])
          : null,
      firebaseState: Map<String, dynamic>.from(map['firebaseState'] ?? {}),
      localizationState: Map<String, dynamic>.from(
        map['localizationState'] ?? {},
      ),
    );
  }

  /// Convert memento to Map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'lifecycleState': lifecycleState.name,
      'currentRoute': currentRoute,
      'navigationStack': navigationStack,
      'userSession': userSession,
      'uiState': uiState,
      'patternStates': patternStates,
      'appConfig': appConfig,
      'backgroundTasks': backgroundTasks,
      'networkStates': networkStates,
      'animationStates': animationStates,
      'gameState': gameState,
      'firebaseState': firebaseState,
      'localizationState': localizationState,
    };
  }

  /// Create a new memento with updated data
  AppStateMemento copyWith({
    String? id,
    DateTime? timestamp,
    AppLifecycleState? lifecycleState,
    String? currentRoute,
    List<String>? navigationStack,
    Map<String, dynamic>? userSession,
    Map<String, dynamic>? uiState,
    Map<String, dynamic>? patternStates,
    Map<String, dynamic>? appConfig,
    Map<String, dynamic>? backgroundTasks,
    Map<String, dynamic>? networkStates,
    Map<String, dynamic>? animationStates,
    Map<String, dynamic>? gameState,
    Map<String, dynamic>? firebaseState,
    Map<String, dynamic>? localizationState,
  }) {
    return AppStateMemento(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      currentRoute: currentRoute ?? this.currentRoute,
      navigationStack: navigationStack ?? this.navigationStack,
      userSession: userSession ?? this.userSession,
      uiState: uiState ?? this.uiState,
      patternStates: patternStates ?? this.patternStates,
      appConfig: appConfig ?? this.appConfig,
      backgroundTasks: backgroundTasks ?? this.backgroundTasks,
      networkStates: networkStates ?? this.networkStates,
      animationStates: animationStates ?? this.animationStates,
      gameState: gameState ?? this.gameState,
      firebaseState: firebaseState ?? this.firebaseState,
      localizationState: localizationState ?? this.localizationState,
    );
  }

  /// Get the age of this memento in seconds
  int getAgeInSeconds() {
    return DateTime.now().difference(timestamp).inSeconds;
  }

  /// Check if this memento is stale (older than specified duration)
  bool isStale(Duration maxAge) {
    return getAgeInSeconds() > maxAge.inSeconds;
  }

  /// Merge another memento's data into this one
  AppStateMemento mergeWith(AppStateMemento other) {
    return copyWith(
      timestamp: other.timestamp.isAfter(timestamp)
          ? other.timestamp
          : timestamp,
      lifecycleState: other.lifecycleState,
      currentRoute: other.currentRoute,
      navigationStack: other.navigationStack,
      userSession: {...userSession, ...other.userSession},
      uiState: {...uiState, ...other.uiState},
      patternStates: {...patternStates, ...other.patternStates},
      appConfig: {...appConfig, ...other.appConfig},
      backgroundTasks: {...backgroundTasks, ...other.backgroundTasks},
      networkStates: {...networkStates, ...other.networkStates},
      animationStates: {...animationStates, ...other.animationStates},
      gameState: other.gameState ?? gameState,
      firebaseState: {...firebaseState, ...other.firebaseState},
      localizationState: {...localizationState, ...other.localizationState},
    );
  }

  @override
  List<Object?> get props => [
    id,
    timestamp,
    lifecycleState,
    currentRoute,
    navigationStack,
    userSession,
    uiState,
    patternStates,
    appConfig,
    backgroundTasks,
    networkStates,
    animationStates,
    gameState,
    firebaseState,
    localizationState,
  ];

  /// Helper method to parse lifecycle state from string
  static AppLifecycleState _parseLifecycleState(String? value) {
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
        return AppLifecycleState.detached;
    }
  }
}

/// Extensions for AppLifecycleState
extension AppLifecycleStateExtension on AppLifecycleState {
  /// Check if the app is in background
  bool get isBackground =>
      this == AppLifecycleState.paused ||
      this == AppLifecycleState.inactive ||
      this == AppLifecycleState.detached ||
      this == AppLifecycleState.hidden;

  /// Check if the app is active
  bool get isActive => this == AppLifecycleState.resumed;

  /// Get priority for state persistence (higher = more important)
  int get persistencePriority {
    switch (this) {
      case AppLifecycleState.paused:
        return 10; // Highest priority - app is going to background
      case AppLifecycleState.inactive:
        return 8;
      case AppLifecycleState.detached:
        return 6;
      case AppLifecycleState.hidden:
        return 4;
      case AppLifecycleState.resumed:
        return 2; // Lower priority - app is active
    }
  }
}
