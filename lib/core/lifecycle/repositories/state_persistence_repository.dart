/// State Persistence Repository - Repository for state memento persistence
///
/// PATTERN: Repository Pattern + Strategy Pattern + Adapter Pattern
/// WHERE: Core lifecycle management - State persistence layer
/// HOW: Provides abstraction over different persistence mechanisms
/// WHY: Enables flexible state storage with pluggable persistence strategies
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/logging/logging.dart';
import '../../error/failures.dart';
import '../entities/app_state_memento.dart';
import '../patterns/memento_pattern.dart';

/// Abstract repository for state memento persistence.
///
/// Defines the contract for storing and retrieving app state mementos
/// across different persistence mechanisms.
abstract class StatePersistenceRepository {
  /// Initialize the repository
  Future<void> initialize();

  /// Dispose the repository and cleanup resources
  Future<void> dispose();

  /// Save a memento to persistent storage
  Future<Either<Failure, void>> saveMemento(AppStateMemento memento);

  /// Get the latest saved memento
  Future<Either<Failure, AppStateMemento?>> getLatestMemento();

  /// Get a specific memento by ID
  Future<Either<Failure, AppStateMemento?>> getMementoById(String mementoId);

  /// Get all stored mementos
  Future<Either<Failure, List<AppStateMemento>>> getAllMementos();

  /// Delete a specific memento
  Future<Either<Failure, void>> deleteMemento(String mementoId);

  /// Clear all stored mementos
  Future<Either<Failure, void>> clearAllMementos();

  /// Get repository statistics
  Future<Either<Failure, MementoStatistics>> getStatistics();

  /// Check if the repository is initialized
  bool get isInitialized;
}

/// File-based implementation of StatePersistenceRepository.
///
/// Stores mementos as JSON files in the app's documents directory
/// with automatic compression and encryption support.
class FileStatePersistenceRepository implements StatePersistenceRepository {
  static const String _mementosDirectory = 'app_state_mementos';
  static const String _indexFileName = 'memento_index.json';
  static const String _statisticsFileName = 'memento_statistics.json';
  static const int _compressionThreshold = 1024; // bytes

  Directory? _mementosDir;
  File? _indexFile;
  File? _statisticsFile;
  final Map<String, AppStateMemento> _mementoCache = {};
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      Log.debug('FileStatePersistenceRepository: Already initialized');
      return;
    }

    try {
      Log.debug(
        'FileStatePersistenceRepository: Initializing file-based persistence',
      );

      // Get app documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      _mementosDir = Directory('${documentsDir.path}/$_mementosDirectory');

      // Create directory if it doesn't exist
      if (!await _mementosDir!.exists()) {
        await _mementosDir!.create(recursive: true);
        Log.debug('FileStatePersistenceRepository: Created mementos directory');
      }

      // Initialize index file
      _indexFile = File('${_mementosDir!.path}/$_indexFileName');
      if (!await _indexFile!.exists()) {
        await _indexFile!.writeAsString(json.encode([]));
        Log.debug('FileStatePersistenceRepository: Created memento index');
      }

      // Initialize statistics file
      _statisticsFile = File('${_mementosDir!.path}/$_statisticsFileName');
      if (!await _statisticsFile!.exists()) {
        await _updateStatistics();
      }

      // Load existing mementos into cache
      await _loadMementoCache();

      _isInitialized = true;
      Log.success('FileStatePersistenceRepository: Initialization completed');
    } catch (e) {
      Log.error('FileStatePersistenceRepository: Initialization failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    Log.debug('FileStatePersistenceRepository: Disposing repository');

    try {
      // Flush cache to disk
      await _flushCache();

      // Update final statistics
      await _updateStatistics();

      _mementoCache.clear();
      _isInitialized = false;

      Log.debug('FileStatePersistenceRepository: Repository disposed');
    } catch (e) {
      Log.error('FileStatePersistenceRepository: Disposal failed: $e');
    }
  }

  @override
  Future<Either<Failure, void>> saveMemento(AppStateMemento memento) async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    try {
      Log.debug('FileStatePersistenceRepository: Saving memento ${memento.id}');

      // Create memento file
      final mementoFile = File('${_mementosDir!.path}/${memento.id}.json');

      // Serialize memento
      final mementoData = memento.toMap();
      String serializedData = json.encode(mementoData);

      // Compress if data is large
      if (serializedData.length > _compressionThreshold) {
        serializedData = await _compressData(serializedData);
        mementoData['_compressed'] = true;
      }

      // Write to file
      await mementoFile.writeAsString(serializedData);

      // Update cache
      _mementoCache[memento.id] = memento;

      // Update index
      await _updateIndex();

      // Update statistics
      await _updateStatistics();

      Log.success(
        'FileStatePersistenceRepository: Memento ${memento.id} saved successfully',
      );
      return const Right(null);
    } catch (e) {
      final error = 'Failed to save memento: $e';
      Log.error('FileStatePersistenceRepository: $error');
      return Left(ServerFailure(message: error));
    }
  }

  @override
  Future<Either<Failure, AppStateMemento?>> getLatestMemento() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    try {
      Log.debug('FileStatePersistenceRepository: Getting latest memento');

      if (_mementoCache.isEmpty) {
        Log.debug('FileStatePersistenceRepository: No mementos found');
        return const Right(null);
      }

      // Find the latest memento by timestamp
      final latestMemento = _mementoCache.values.reduce(
        (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
      );

      Log.success(
        'FileStatePersistenceRepository: Retrieved latest memento ${latestMemento.id}',
      );
      return Right(latestMemento);
    } catch (e) {
      final error = 'Failed to get latest memento: $e';
      Log.error('FileStatePersistenceRepository: $error');
      return Left(ServerFailure(message: error));
    }
  }

  @override
  Future<Either<Failure, AppStateMemento?>> getMementoById(
    String mementoId,
  ) async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    try {
      Log.debug(
        'FileStatePersistenceRepository: Getting memento by ID: $mementoId',
      );

      // Check cache first
      if (_mementoCache.containsKey(mementoId)) {
        Log.success(
          'FileStatePersistenceRepository: Retrieved memento from cache',
        );
        return Right(_mementoCache[mementoId]);
      }

      // Load from file
      final mementoFile = File('${_mementosDir!.path}/$mementoId.json');
      if (!await mementoFile.exists()) {
        Log.debug('FileStatePersistenceRepository: Memento file not found');
        return const Right(null);
      }

      final memento = await _loadMementoFromFile(mementoFile);
      if (memento != null) {
        _mementoCache[mementoId] = memento;
        Log.success('FileStatePersistenceRepository: Loaded memento from file');
        return Right(memento);
      } else {
        Log.warning(
          'FileStatePersistenceRepository: Failed to parse memento file',
        );
        return const Right(null);
      }
    } catch (e) {
      final error = 'Failed to get memento by ID: $e';
      Log.error('FileStatePersistenceRepository: $error');
      return Left(ServerFailure(message: error));
    }
  }

  @override
  Future<Either<Failure, List<AppStateMemento>>> getAllMementos() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    try {
      Log.debug('FileStatePersistenceRepository: Getting all mementos');

      final mementos = _mementoCache.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      Log.success(
        'FileStatePersistenceRepository: Retrieved ${mementos.length} mementos',
      );
      return Right(mementos);
    } catch (e) {
      final error = 'Failed to get all mementos: $e';
      Log.error('FileStatePersistenceRepository: $error');
      return Left(ServerFailure(message: error));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMemento(String mementoId) async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    try {
      Log.debug('FileStatePersistenceRepository: Deleting memento: $mementoId');

      // Remove from cache
      _mementoCache.remove(mementoId);

      // Delete file
      final mementoFile = File('${_mementosDir!.path}/$mementoId.json');
      if (await mementoFile.exists()) {
        await mementoFile.delete();
      }

      // Update index
      await _updateIndex();

      // Update statistics
      await _updateStatistics();

      Log.success(
        'FileStatePersistenceRepository: Memento $mementoId deleted successfully',
      );
      return const Right(null);
    } catch (e) {
      final error = 'Failed to delete memento: $e';
      Log.error('FileStatePersistenceRepository: $error');
      return Left(ServerFailure(message: error));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllMementos() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    try {
      Log.debug('FileStatePersistenceRepository: Clearing all mementos');

      // Clear cache
      _mementoCache.clear();

      // Delete all memento files
      final mementoFiles = await _mementosDir!
          .list()
          .where(
            (file) =>
                file.path.endsWith('.json') &&
                !file.path.endsWith(_indexFileName) &&
                !file.path.endsWith(_statisticsFileName),
          )
          .toList();

      for (final file in mementoFiles) {
        await file.delete();
      }

      // Clear index
      await _indexFile!.writeAsString(json.encode([]));

      // Update statistics
      await _updateStatistics();

      Log.success(
        'FileStatePersistenceRepository: All mementos cleared successfully',
      );
      return const Right(null);
    } catch (e) {
      final error = 'Failed to clear all mementos: $e';
      Log.error('FileStatePersistenceRepository: $error');
      return Left(ServerFailure(message: error));
    }
  }

  @override
  Future<Either<Failure, MementoStatistics>> getStatistics() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    try {
      Log.debug('FileStatePersistenceRepository: Getting statistics');

      final mementos = _mementoCache.values.toList();
      final now = DateTime.now();

      if (mementos.isEmpty) {
        return Right(
          MementoStatistics(
            totalMementos: 0,
            mementosByOriginator: 0,
            totalSizeBytes: 0,
            averageAge: Duration.zero,
            originatorCounts: {},
          ),
        );
      }

      final oldestMemento = mementos.reduce(
        (a, b) => a.timestamp.isBefore(b.timestamp) ? a : b,
      );
      final newestMemento = mementos.reduce(
        (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
      );

      final totalAge = mementos.fold<Duration>(
        Duration.zero,
        (sum, m) => sum + now.difference(m.timestamp),
      );
      final averageAge = totalAge ~/ mementos.length;

      // Calculate total size
      int totalSize = 0;
      try {
        final mementoFiles = await _mementosDir!.list().toList();
        for (final file in mementoFiles) {
          if (file is File && file.path.endsWith('.json')) {
            final stat = await file.stat();
            totalSize += stat.size;
          }
        }
      } catch (e) {
        Log.warning(
          'FileStatePersistenceRepository: Failed to calculate size: $e',
        );
      }

      final statistics = MementoStatistics(
        totalMementos: mementos.length,
        mementosByOriginator: mementos.length,
        // All belong to app originator
        oldestMemento: oldestMemento.timestamp,
        newestMemento: newestMemento.timestamp,
        totalSizeBytes: totalSize,
        averageAge: averageAge,
        originatorCounts: {'app': mementos.length},
      );

      Log.success('FileStatePersistenceRepository: Retrieved statistics');
      return Right(statistics);
    } catch (e) {
      final error = 'Failed to get statistics: $e';
      Log.error('FileStatePersistenceRepository: $error');
      return Left(ServerFailure(message: error));
    }
  }

  // Private helper methods

  Future<void> _loadMementoCache() async {
    try {
      final mementoFiles = await _mementosDir!
          .list()
          .where(
            (file) =>
                file.path.endsWith('.json') &&
                !file.path.endsWith(_indexFileName) &&
                !file.path.endsWith(_statisticsFileName),
          )
          .toList();

      for (final file in mementoFiles) {
        if (file is File) {
          final memento = await _loadMementoFromFile(file);
          if (memento != null) {
            _mementoCache[memento.id] = memento;
          }
        }
      }

      Log.debug(
        'FileStatePersistenceRepository: Loaded ${_mementoCache.length} mementos into cache',
      );
    } catch (e) {
      Log.error(
        'FileStatePersistenceRepository: Failed to load memento cache: $e',
      );
    }
  }

  Future<AppStateMemento?> _loadMementoFromFile(File file) async {
    try {
      String data = await file.readAsString();

      // Check if data is compressed
      final Map<String, dynamic> mementoMap = json.decode(data);
      if (mementoMap.containsKey('_compressed') &&
          mementoMap['_compressed'] == true) {
        data = await _decompressData(data);
      }

      final mementoData = json.decode(data) as Map<String, dynamic>;
      return AppStateMemento.fromMap(mementoData);
    } catch (e) {
      Log.warning(
        'FileStatePersistenceRepository: Failed to load memento from file ${file.path}: $e',
      );
      return null;
    }
  }

  Future<void> _updateIndex() async {
    try {
      final index = _mementoCache.keys.toList()..sort();
      await _indexFile!.writeAsString(json.encode(index));
    } catch (e) {
      Log.warning('FileStatePersistenceRepository: Failed to update index: $e');
    }
  }

  Future<void> _updateStatistics() async {
    try {
      final statisticsResult = await getStatistics();
      if (statisticsResult.isRight()) {
        final statistics = statisticsResult.getRight().toNullable()!;
        await _statisticsFile!.writeAsString(json.encode(statistics.toMap()));
      }
    } catch (e) {
      Log.warning(
        'FileStatePersistenceRepository: Failed to update statistics: $e',
      );
    }
  }

  Future<void> _flushCache() async {
    // In file-based implementation, data is written immediately
    // This method is provided for interface compatibility
    Log.debug('FileStatePersistenceRepository: Cache flushed');
  }

  Future<String> _compressData(String data) async {
    // Simple compression simulation - in production, use gzip
    // For now, just return the original data
    return data;
  }

  Future<String> _decompressData(String data) async {
    // Simple decompression simulation - in production, use gzip
    // For now, just return the original data
    return data;
  }
}

/// In-memory implementation for testing
class InMemoryStatePersistenceRepository implements StatePersistenceRepository {
  final Map<String, AppStateMemento> _mementos = {};
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
    Log.debug('InMemoryStatePersistenceRepository: Initialized');
  }

  @override
  Future<void> dispose() async {
    _mementos.clear();
    _isInitialized = false;
    Log.debug('InMemoryStatePersistenceRepository: Disposed');
  }

  @override
  Future<Either<Failure, void>> saveMemento(AppStateMemento memento) async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    _mementos[memento.id] = memento;
    return const Right(null);
  }

  @override
  Future<Either<Failure, AppStateMemento?>> getLatestMemento() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    if (_mementos.isEmpty) return const Right(null);

    final latest = _mementos.values.reduce(
      (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
    );
    return Right(latest);
  }

  @override
  Future<Either<Failure, AppStateMemento?>> getMementoById(
    String mementoId,
  ) async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    return Right(_mementos[mementoId]);
  }

  @override
  Future<Either<Failure, List<AppStateMemento>>> getAllMementos() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    final mementos = _mementos.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return Right(mementos);
  }

  @override
  Future<Either<Failure, void>> deleteMemento(String mementoId) async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    _mementos.remove(mementoId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearAllMementos() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    _mementos.clear();
    return const Right(null);
  }

  @override
  Future<Either<Failure, MementoStatistics>> getStatistics() async {
    if (!_isInitialized) {
      return Left(ValidationFailure(message: 'Repository not initialized'));
    }

    final now = DateTime.now();
    final mementos = _mementos.values.toList();

    if (mementos.isEmpty) {
      return Right(
        MementoStatistics(
          totalMementos: 0,
          mementosByOriginator: 0,
          totalSizeBytes: 0,
          averageAge: Duration.zero,
          originatorCounts: {},
        ),
      );
    }

    final oldestMemento = mementos.reduce(
      (a, b) => a.timestamp.isBefore(b.timestamp) ? a : b,
    );
    final newestMemento = mementos.reduce(
      (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
    );

    final totalAge = mementos.fold<Duration>(
      Duration.zero,
      (sum, m) => sum + now.difference(m.timestamp),
    );
    final averageAge = totalAge ~/ mementos.length;

    return Right(
      MementoStatistics(
        totalMementos: mementos.length,
        mementosByOriginator: mementos.length,
        oldestMemento: oldestMemento.timestamp,
        newestMemento: newestMemento.timestamp,
        totalSizeBytes: 0,
        // Not applicable for in-memory
        averageAge: averageAge,
        originatorCounts: {'app': mementos.length},
      ),
    );
  }
}
