/// State Manager - Memento pattern implementation for state persistence
///
/// PATTERN: Memento Pattern + Repository Pattern + Strategy Pattern
/// WHERE: Core lifecycle management - State persistence manager
/// HOW: Manages state snapshots with configurable persistence strategies
/// WHY: Provides reliable state preservation and restoration across app sessions
library;

import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../../core/logging/logging.dart';
import '../../error/failures.dart';
import '../entities/app_state_memento.dart';
import '../repositories/state_persistence_repository.dart';

/// Manages application state persistence using Memento pattern.
///
/// Provides automatic state saving, restoration, and cleanup with
/// configurable persistence strategies and compression.
class StateManager {
  final StatePersistenceRepository _repository;

  // Configuration
  static const int maxStoredMementos = 10;
  static const Duration defaultMementoLifetime = Duration(days: 7);
  static const int compressionThreshold = 1024; // bytes

  // State tracking
  AppStateMemento? _currentMemento;
  AppStateMemento? _lastSavedMemento;
  final List<AppStateMemento> _mementoHistory = [];
  bool _isInitialized = false;

  StateManager(this._repository);

  /// Initialize the state manager
  Future<void> initialize() async {
    if (_isInitialized) {
      Log.debug('StateManager: Already initialized');
      return;
    }

    try {
      Log.debug('StateManager: Initializing state manager');

      await _repository.initialize();
      await _loadExistingMementos();
      await _cleanupOldMementos();

      _isInitialized = true;
      Log.success('StateManager: State manager initialized successfully');
    } catch (e) {
      Log.error('StateManager: Initialization failed: $e');
      rethrow;
    }
  }

  /// Dispose of the state manager
  Future<void> dispose() async {
    Log.debug('StateManager: Disposing state manager');

    try {
      // Save current state before disposal
      if (_currentMemento != null) {
        await saveState(_currentMemento!);
      }

      await _repository.dispose();

      _isInitialized = false;
      Log.debug('StateManager: State manager disposed');
    } catch (e) {
      Log.error('StateManager: Disposal failed: $e');
    }
  }

  /// Save application state as a memento
  Future<Either<Failure, void>> saveState(AppStateMemento memento) async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'StateManager not initialized'));
    }

    try {
      Log.debug('StateManager: Saving state memento ${memento.id}');

      // Validate memento
      final validationResult = _validateMemento(memento);
      if (validationResult.isLeft()) {
        return validationResult;
      }

      // Compress if necessary
      final processedMemento = await _processMemento(memento);

      // Save to repository
      final saveResult = await _repository.saveMemento(processedMemento);
      if (saveResult.isLeft()) {
        return saveResult;
      }

      // Update tracking
      _currentMemento = processedMemento;
      _lastSavedMemento = processedMemento;
      _addToHistory(processedMemento);

      Log.success(
        'StateManager: State memento ${memento.id} saved successfully',
      );
      return const Right(null);
    } catch (e) {
      final error = 'Failed to save state memento: $e';
      Log.error('StateManager: $error');
      return Left(ServerFailure(message: error));
    }
  }

  /// Load the most recent saved state
  Future<AppStateMemento?> getLastSavedState() async {
    if (!_isInitialized) {
      Log.warning(
        'StateManager: Cannot get last saved state - not initialized',
      );
      return null;
    }

    try {
      Log.debug('StateManager: Getting last saved state');

      final result = await _repository.getLatestMemento();
      return result.fold(
        (failure) {
          Log.error(
            'StateManager: Failed to get last saved state: ${failure.toString()}',
          );
          return null;
        },
        (memento) {
          if (memento != null) {
            Log.success(
              'StateManager: Retrieved last saved state from ${memento.timestamp}',
            );
            return _processLoadedMemento(memento);
          } else {
            Log.debug('StateManager: No saved state found');
            return null;
          }
        },
      );
    } catch (e) {
      Log.error('StateManager: Failed to get last saved state: $e');
      return null;
    }
  }

  /// Load a specific state by ID
  Future<AppStateMemento?> getStateById(String mementoId) async {
    if (!_isInitialized) {
      Log.warning('StateManager: Cannot get state by ID - not initialized');
      return null;
    }

    try {
      Log.debug('StateManager: Getting state by ID: $mementoId');

      final result = await _repository.getMementoById(mementoId);
      return result.fold(
        (failure) {
          Log.error(
            'StateManager: Failed to get state by ID: ${failure.toString()}',
          );
          return null;
        },
        (memento) {
          if (memento != null) {
            Log.success('StateManager: Retrieved state by ID: $mementoId');
            return _processLoadedMemento(memento);
          } else {
            Log.debug('StateManager: State not found for ID: $mementoId');
            return null;
          }
        },
      );
    } catch (e) {
      Log.error('StateManager: Failed to get state by ID: $e');
      return null;
    }
  }

  /// Get all stored mementos
  Future<List<AppStateMemento>> getAllStates() async {
    if (!_isInitialized) {
      Log.warning('StateManager: Cannot get all states - not initialized');
      return [];
    }

    try {
      Log.debug('StateManager: Getting all stored states');

      final result = await _repository.getAllMementos();
      return result.fold(
        (failure) {
          Log.error(
            'StateManager: Failed to get all states: ${failure.toString()}',
          );
          return [];
        },
        (mementos) {
          Log.success(
            'StateManager: Retrieved ${mementos.length} stored states',
          );
          return mementos.map(_processLoadedMemento).toList();
        },
      );
    } catch (e) {
      Log.error('StateManager: Failed to get all states: $e');
      return [];
    }
  }

  /// Delete a specific state
  Future<Either<Failure, void>> deleteState(String mementoId) async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'StateManager not initialized'));
    }

    try {
      Log.debug('StateManager: Deleting state: $mementoId');

      final result = await _repository.deleteMemento(mementoId);
      if (result.isRight()) {
        _mementoHistory.removeWhere((m) => m.id == mementoId);
        Log.success('StateManager: State $mementoId deleted successfully');
      }

      return result;
    } catch (e) {
      final error = 'Failed to delete state: $e';
      Log.error('StateManager: $error');
      return Left(ServerFailure(message: error));
    }
  }

  /// Clear all stored states
  Future<Either<Failure, void>> clearAllStates() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'StateManager not initialized'));
    }

    try {
      Log.debug('StateManager: Clearing all states');

      final result = await _repository.clearAllMementos();
      if (result.isRight()) {
        _mementoHistory.clear();
        _currentMemento = null;
        _lastSavedMemento = null;
        Log.success('StateManager: All states cleared successfully');
      }

      return result;
    } catch (e) {
      final error = 'Failed to clear all states: $e';
      Log.error('StateManager: $error');
      return Left(ServerFailure(message: error));
    }
  }

  /// Create a diff between two mementos
  Map<String, dynamic> createStateDiff(
    AppStateMemento oldState,
    AppStateMemento newState,
  ) {
    final diff = <String, dynamic>{};

    // Compare each major state component
    if (oldState.currentRoute != newState.currentRoute) {
      diff['currentRoute'] = {
        'old': oldState.currentRoute,
        'new': newState.currentRoute,
      };
    }

    if (!_mapEquals(oldState.userSession, newState.userSession)) {
      diff['userSession'] = _createMapDiff(
        oldState.userSession,
        newState.userSession,
      );
    }

    if (!_mapEquals(oldState.uiState, newState.uiState)) {
      diff['uiState'] = _createMapDiff(oldState.uiState, newState.uiState);
    }

    if (!_mapEquals(oldState.patternStates, newState.patternStates)) {
      diff['patternStates'] = _createMapDiff(
        oldState.patternStates,
        newState.patternStates,
      );
    }

    return diff;
  }

  /// Get state statistics
  Map<String, dynamic> getStateStatistics() {
    return {
      'totalMementos': _mementoHistory.length,
      'currentMementoId': _currentMemento?.id,
      'lastSavedMementoId': _lastSavedMemento?.id,
      'oldestMemento': _mementoHistory.isNotEmpty
          ? _mementoHistory.first.timestamp.toIso8601String()
          : null,
      'newestMemento': _mementoHistory.isNotEmpty
          ? _mementoHistory.last.timestamp.toIso8601String()
          : null,
      'isInitialized': _isInitialized,
    };
  }

  // Private methods

  Future<void> _loadExistingMementos() async {
    final mementos = await getAllStates();
    _mementoHistory.clear();
    _mementoHistory.addAll(mementos);

    if (_mementoHistory.isNotEmpty) {
      _lastSavedMemento = _mementoHistory.last;
      Log.debug(
        'StateManager: Loaded ${_mementoHistory.length} existing mementos',
      );
    }
  }

  Future<void> _cleanupOldMementos() async {
    final now = DateTime.now();
    final cutoffTime = now.subtract(defaultMementoLifetime);

    final toDelete = _mementoHistory
        .where((m) => m.timestamp.isBefore(cutoffTime))
        .toList();

    for (final memento in toDelete) {
      await deleteState(memento.id);
    }

    // Keep only the most recent mementos
    if (_mementoHistory.length > maxStoredMementos) {
      _mementoHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final toRemove = _mementoHistory.skip(maxStoredMementos).toList();

      for (final memento in toRemove) {
        await deleteState(memento.id);
      }
    }

    Log.debug('StateManager: Cleaned up old mementos');
  }

  Either<Failure, void> _validateMemento(AppStateMemento memento) {
    if (memento.id.isEmpty) {
      return Left(ValidationFailure(message: 'Memento ID cannot be empty'));
    }

    if (memento.timestamp.isAfter(
      DateTime.now().add(const Duration(minutes: 1)),
    )) {
      return Left(
        ValidationFailure(message: 'Memento timestamp cannot be in the future'),
      );
    }

    return const Right(null);
  }

  Future<AppStateMemento> _processMemento(AppStateMemento memento) async {
    // Add compression, encryption, or other processing here if needed
    return memento;
  }

  AppStateMemento _processLoadedMemento(AppStateMemento memento) {
    // Add decompression, decryption, or other processing here if needed
    return memento;
  }

  void _addToHistory(AppStateMemento memento) {
    _mementoHistory.add(memento);
    _mementoHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Remove duplicates
    final uniqueMementos = <String, AppStateMemento>{};
    for (final m in _mementoHistory) {
      uniqueMementos[m.id] = m;
    }
    _mementoHistory.clear();
    _mementoHistory.addAll(uniqueMementos.values);
  }

  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }

    return true;
  }

  Map<String, dynamic> _createMapDiff(
    Map<String, dynamic> oldMap,
    Map<String, dynamic> newMap,
  ) {
    final diff = <String, dynamic>{};
    final allKeys = {...oldMap.keys, ...newMap.keys};

    for (final key in allKeys) {
      final oldValue = oldMap[key];
      final newValue = newMap[key];

      if (oldValue != newValue) {
        diff[key] = {'old': oldValue, 'new': newValue};
      }
    }

    return diff;
  }

  /// Current memento accessor
  AppStateMemento? get currentMemento => _currentMemento;

  /// Last saved memento accessor
  AppStateMemento? get lastSavedMemento => _lastSavedMemento;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Get memento history
  List<AppStateMemento> get mementoHistory =>
      List.unmodifiable(_mementoHistory);
}
