/// Memento Pattern - Abstract memento pattern for state management
///
/// PATTERN: Memento Pattern (Abstract Implementation)
/// WHERE: Core lifecycle management - Memento pattern contracts
/// HOW: Defines memento interfaces for state capture and restoration
/// WHY: Provides structured approach to state preservation without exposing internals
library;

import 'dart:async';

/// Abstract originator interface for objects that can create mementos.
///
/// Objects that need to preserve their state should implement this interface
/// to create and restore from memento snapshots.
abstract class MementoOriginator<T extends StateMemento> {
  /// Create a memento capturing the current state
  T createMemento();

  /// Restore state from a memento
  void restoreFromMemento(T memento);

  /// Validate that a memento is compatible with this originator
  bool validateMemento(T memento) => true;

  /// Get the unique identifier for this originator
  String get originatorId;

  /// Get the version of the state format (for compatibility)
  String get stateVersion => '1.0.0';
}

/// Abstract memento interface for state snapshots.
///
/// All state mementos should implement this interface to provide
/// consistent serialization and identification.
abstract class StateMemento {
  /// Unique identifier for this memento
  String get mementoId;

  /// Timestamp when this memento was created
  DateTime get timestamp;

  /// Originator that created this memento
  String get originatorId;

  /// Version of the state format
  String get stateVersion;

  /// Serialize memento to Map for persistence
  Map<String, dynamic> toMap();

  /// Check if this memento is stale
  bool isStale(Duration maxAge) {
    return DateTime.now().difference(timestamp) > maxAge;
  }

  /// Get the age of this memento
  Duration getAge() {
    return DateTime.now().difference(timestamp);
  }
}

/// Caretaker interface for managing mementos.
///
/// Caretakers are responsible for storing and retrieving mementos
/// without knowing their internal structure.
abstract class MementoCaretaker<T extends StateMemento> {
  /// Store a memento
  Future<void> storeMemento(T memento);

  /// Retrieve a memento by ID
  Future<T?> retrieveMemento(String mementoId);

  /// Retrieve the latest memento for an originator
  Future<T?> retrieveLatestMemento(String originatorId);

  /// Retrieve all mementos for an originator
  Future<List<T>> retrieveAllMementos(String originatorId);

  /// Delete a memento
  Future<void> deleteMemento(String mementoId);

  /// Clear all mementos for an originator
  Future<void> clearMementos(String originatorId);

  /// Get memento statistics
  Future<MementoStatistics> getStatistics();
}

/// Specialized memento for UI components
abstract class UIStateMemento extends StateMemento {
  /// Widget-specific state data
  Map<String, dynamic> get widgetState;

  /// Form field values
  Map<String, dynamic> get formState;

  /// Scroll positions
  Map<String, double> get scrollPositions;

  /// Focus states
  Map<String, bool> get focusStates;

  /// Selection states
  Map<String, dynamic> get selectionStates;

  /// Animation states
  Map<String, double> get animationStates;
}

/// Specialized memento for navigation state
abstract class NavigationStateMemento extends StateMemento {
  /// Current route information
  String get currentRoute;

  /// Route parameters
  Map<String, String> get routeParameters;

  /// Navigation stack
  List<String> get navigationStack;

  /// Tab indices
  Map<String, int> get tabIndices;

  /// Drawer state
  bool get isDrawerOpen;

  /// Modal states
  Map<String, bool> get modalStates;
}

/// Specialized memento for user session state
abstract class SessionStateMemento extends StateMemento {
  /// User authentication state
  bool get isAuthenticated;

  /// User profile data
  Map<String, dynamic> get userProfile;

  /// User preferences
  Map<String, dynamic> get preferences;

  /// Session tokens (should be encrypted)
  Map<String, String> get tokens;

  /// Last activity timestamp
  DateTime get lastActivity;

  /// Session metadata
  Map<String, dynamic> get sessionMetadata;
}

/// Specialized memento for pattern-specific state
abstract class PatternStateMemento extends StateMemento {
  /// Pattern category (creational, structural, behavioral)
  String get patternCategory;

  /// Current pattern selection
  String? get selectedPattern;

  /// View mode state
  Map<String, dynamic> get viewModeState;

  /// Filter states
  Map<String, dynamic> get filterStates;

  /// Search queries
  Map<String, String> get searchStates;

  /// Favorite patterns
  List<String> get favoritePatterns;

  /// Pattern-specific data
  Map<String, dynamic> get patternData;
}

/// Memento for application configuration
abstract class ConfigurationMemento extends StateMemento {
  /// Application settings
  Map<String, dynamic> get appSettings;

  /// Theme configuration
  Map<String, dynamic> get themeConfig;

  /// Localization settings
  Map<String, String> get localizationConfig;

  /// Feature flags
  Map<String, bool> get featureFlags;

  /// Performance settings
  Map<String, dynamic> get performanceConfig;
}

/// Statistics about stored mementos
class MementoStatistics {
  final int totalMementos;
  final int mementosByOriginator;
  final DateTime? oldestMemento;
  final DateTime? newestMemento;
  final int totalSizeBytes;
  final Duration averageAge;
  final Map<String, int> originatorCounts;

  const MementoStatistics({
    required this.totalMementos,
    required this.mementosByOriginator,
    this.oldestMemento,
    this.newestMemento,
    required this.totalSizeBytes,
    required this.averageAge,
    required this.originatorCounts,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalMementos': totalMementos,
      'mementosByOriginator': mementosByOriginator,
      'oldestMemento': oldestMemento?.toIso8601String(),
      'newestMemento': newestMemento?.toIso8601String(),
      'totalSizeBytes': totalSizeBytes,
      'averageAgeSeconds': averageAge.inSeconds,
      'originatorCounts': originatorCounts,
    };
  }
}

/// Mixin for objects that can automatically create mementos
mixin AutoMementoCapture<T extends StateMemento> on MementoOriginator<T> {
  T? _lastMemento;
  Timer? _autoSaveTimer;

  /// Enable automatic memento creation at intervals
  void enableAutoCapture({
    Duration interval = const Duration(minutes: 1),
    bool captureOnChange = true,
  }) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(interval, (_) {
      _captureIfChanged();
    });
  }

  /// Disable automatic memento creation
  void disableAutoCapture() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  /// Capture memento if state has changed
  void _captureIfChanged() {
    final currentMemento = createMemento();

    if (_lastMemento == null ||
        _hasStateChanged(_lastMemento!, currentMemento)) {
      _lastMemento = currentMemento;
      onMementoCreated(currentMemento);
    }
  }

  /// Override this to be notified when a memento is created
  void onMementoCreated(T memento) {}

  /// Override this to define state change detection logic
  bool _hasStateChanged(T oldMemento, T newMemento) {
    // Default implementation compares serialized states
    return oldMemento.toMap().toString() != newMemento.toMap().toString();
  }

  /// Dispose auto-capture resources
  void disposeAutoCapture() {
    disableAutoCapture();
    _lastMemento = null;
  }

  /// Get the last captured memento
  T? get lastMemento => _lastMemento;
}

/// Composite memento that combines multiple mementos
class CompositeMementoState extends StateMemento {
  final List<StateMemento> _childMementos;
  final String _mementoId;
  final DateTime _timestamp;
  final String _originatorId;

  CompositeMementoState({
    required String mementoId,
    required String originatorId,
    required List<StateMemento> childMementos,
  }) : _mementoId = mementoId,
       _originatorId = originatorId,
       _timestamp = DateTime.now(),
       _childMementos = List.from(childMementos);

  @override
  String get mementoId => _mementoId;

  @override
  DateTime get timestamp => _timestamp;

  @override
  String get originatorId => _originatorId;

  @override
  String get stateVersion => '1.0.0';

  /// Get child mementos
  List<StateMemento> get childMementos => List.unmodifiable(_childMementos);

  /// Add a child memento
  void addChildMemento(StateMemento memento) {
    _childMementos.add(memento);
  }

  /// Remove a child memento
  void removeChildMemento(String mementoId) {
    _childMementos.removeWhere((m) => m.mementoId == mementoId);
  }

  /// Get a child memento by ID
  StateMemento? getChildMemento(String mementoId) {
    try {
      return _childMementos.firstWhere((m) => m.mementoId == mementoId);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'mementoId': mementoId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'originatorId': originatorId,
      'stateVersion': stateVersion,
      'childMementos': _childMementos.map((m) => m.toMap()).toList(),
    };
  }

  /// Create from Map
  static CompositeMementoState fromMap(Map<String, dynamic> map) {
    final childMementos = <StateMemento>[];
    // Note: Child mementos would be reconstructed here in a real implementation

    // Note: In a real implementation, you'd need a factory to create
    // the appropriate StateMemento subtype based on the data

    return CompositeMementoState(
      mementoId: map['mementoId'] ?? '',
      originatorId: map['originatorId'] ?? '',
      childMementos: childMementos,
    );
  }
}
