/// Translation Service - Singleton Pattern Implementation
///
/// PATTERN: Singleton + Observer + Memento - Centralized translation management
/// WHERE: Domain layer service for global translation access
/// HOW: Singleton with Observer notifications and Memento state management
/// WHY: Ensures single source of truth for translations across the app
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/patterns/behavioral/memento.dart';
import 'package:design_patterns/core/patterns/behavioral/observer.dart';
import 'package:design_patterns/features/localization/domain/entities/language.dart';
import 'package:design_patterns/features/localization/domain/entities/translation.dart';
import 'package:design_patterns/features/localization/domain/usecases/change_language.dart';
import 'package:design_patterns/features/localization/domain/usecases/get_current_language.dart';
import 'package:design_patterns/features/localization/domain/usecases/load_translations.dart';

/// Translation service implementing multiple design patterns
///
/// PATTERN: Singleton - Ensures single instance across the app
/// PATTERN: Observer - Notifies UI components of language changes
/// PATTERN: Memento - Saves and restores translation state
///
/// In the Tower Defense context, this service manages all game text
/// translations and ensures consistent language experience.
class TranslationService extends Subject<LanguageChangeEvent>
    implements Observer<GameEvent> {
  // PATTERN: Singleton implementation
  static final TranslationService _instance = TranslationService._internal();

  factory TranslationService() => _instance;

  TranslationService._internal() {
    // Register as observer for game events
    GameEventManager().addObserver(this);
    Log.debug('TranslationService initialized as Singleton');
  }

  // Observer pattern - list of UI components listening for language changes
  final List<Observer<LanguageChangeEvent>> _observers = [];

  // Current state
  Language _currentLanguage = Language.english;
  Translation? _currentTranslation;
  final Map<String, Translation> _translationCache = {};

  // Use cases injected via dependency injection
  GetCurrentLanguage? _getCurrentLanguage;
  ChangeLanguage? _changeLanguage;
  LoadTranslations? _loadTranslations;

  // Getters for current state
  Language get currentLanguage => _currentLanguage;

  Translation? get currentTranslation => _currentTranslation;

  bool get isInitialized => _currentTranslation != null;

  /// Initialize the translation service with use cases
  void initialize({
    required GetCurrentLanguage getCurrentLanguage,
    required ChangeLanguage changeLanguage,
    required LoadTranslations loadTranslations,
  }) {
    _getCurrentLanguage = getCurrentLanguage;
    _changeLanguage = changeLanguage;
    _loadTranslations = loadTranslations;
    Log.debug('TranslationService dependencies injected');
  }

  /// Initialize with system language detection
  Future<void> initializeWithSystemLanguage() async {
    try {
      Log.debug('Initializing translation service with system language');

      if (_getCurrentLanguage == null) {
        Log.error(
          'TranslationService not properly initialized with dependencies',
        );
        return;
      }

      // Get current/preferred language
      final result = await _getCurrentLanguage!.execute();

      result.fold(
        (failure) {
          Log.warning(
            'Could not get current language, using English: ${failure.toString()}',
          );
          _setLanguage(Language.english);
        },
        (language) {
          Log.success('System language detected: ${language.code}');
          _setLanguage(language);
        },
      );

      // Load translations for the detected/preferred language
      await _loadCurrentLanguageTranslations();
    } catch (e) {
      Log.error('Error initializing translation service: $e');
      _setLanguage(Language.english);
    }
  }

  /// Change the current language
  Future<bool> changeLanguage(Language newLanguage) async {
    try {
      if (_changeLanguage == null) {
        Log.error('ChangeLanguage use case not injected');
        return false;
      }

      Log.debug('Requesting language change to: ${newLanguage.code}');

      final result = await _changeLanguage!.execute(newLanguage);

      return result.fold(
        (failure) {
          Log.error('Failed to change language: ${failure.toString()}');
          return false;
        },
        (_) {
          _setLanguage(newLanguage);
          _loadCurrentLanguageTranslations();
          return true;
        },
      );
    } catch (e) {
      Log.error('Error changing language: $e');
      return false;
    }
  }

  /// Get translation for a key
  String translate(String key) {
    if (_currentTranslation == null) {
      Log.warning('No translation loaded, returning key: $key');
      return key;
    }

    final translation = _currentTranslation!.translate(key);
    if (translation == key) {
      Log.debug('Translation not found for key: $key');
    }

    return translation;
  }

  /// Get translation with parameters (simple interpolation)
  String translateWithArgs(String key, Map<String, String> args) {
    String translation = translate(key);

    for (final entry in args.entries) {
      translation = translation.replaceAll('{${entry.key}}', entry.value);
    }

    return translation;
  }

  /// Load translations for current language
  Future<void> _loadCurrentLanguageTranslations() async {
    try {
      if (_loadTranslations == null) {
        Log.error('LoadTranslations use case not injected');
        return;
      }

      // Check cache first
      if (_translationCache.containsKey(_currentLanguage.code)) {
        _currentTranslation = _translationCache[_currentLanguage.code];
        Log.debug('Using cached translations for ${_currentLanguage.code}');
        return;
      }

      Log.debug('Loading translations for ${_currentLanguage.code}');

      final result = await _loadTranslations!.execute(_currentLanguage);

      result.fold(
        (failure) {
          Log.error('Failed to load translations: ${failure.toString()}');
        },
        (translation) {
          _currentTranslation = translation;
          _translationCache[_currentLanguage.code] = translation;
          Log.success('Translations loaded for ${_currentLanguage.code}');
        },
      );
    } catch (e) {
      Log.error('Error loading translations: $e');
    }
  }

  /// Set current language and notify observers
  void _setLanguage(Language language) {
    final oldLanguage = _currentLanguage;
    _currentLanguage = language;

    // PATTERN: Observer - Notify all observers of language change
    final event = LanguageChangeEvent(
      oldLanguage: oldLanguage,
      newLanguage: language,
      timestamp: DateTime.now(),
    );

    notifyObservers(event);
    Log.debug('Language changed from ${oldLanguage.code} to ${language.code}');
  }

  // PATTERN: Memento - Save current state
  LanguageMemento createMemento() {
    return LanguageMemento(
      language: _currentLanguage,
      translation: _currentTranslation,
      cacheSnapshot: Map.from(_translationCache),
      timestamp: DateTime.now(),
    );
  }

  // PATTERN: Memento - Restore from saved state
  void restoreFromMemento(LanguageMemento memento) {
    _currentLanguage = memento.language;
    _currentTranslation = memento.translation;
    _translationCache.clear();
    _translationCache.addAll(memento.cacheSnapshot);

    Log.debug('TranslationService state restored from memento');

    // Notify observers of restoration
    final event = LanguageChangeEvent(
      oldLanguage: _currentLanguage, // Same language, but state restored
      newLanguage: _currentLanguage,
      timestamp: DateTime.now(),
      isRestore: true,
    );

    notifyObservers(event);
  }

  /// Clear translation cache
  void clearCache() {
    _translationCache.clear();
    Log.debug('Translation cache cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheInfo() {
    return {
      'cached_languages': _translationCache.keys.toList(),
      'cache_size': _translationCache.length,
      'current_language': _currentLanguage.code,
      'is_initialized': isInitialized,
    };
  }

  // PATTERN: Observer - Implementation for game events
  @override
  void update(GameEvent event) {
    // Listen for language-related game events
    if (event.type == GameEventType.languageChanged) {
      Log.debug('Received language change event from GameEventManager');
      // Additional logic for game-specific language changes
    }
  }

  // PATTERN: Observer - Subject implementation
  @override
  void addObserver(Observer<LanguageChangeEvent> observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
      Log.debug(
        'Observer added to TranslationService (${_observers.length} total)',
      );
    }
  }

  @override
  void removeObserver(Observer<LanguageChangeEvent> observer) {
    _observers.remove(observer);
    Log.debug(
      'Observer removed from TranslationService (${_observers.length} remaining)',
    );
  }

  @override
  void notifyObservers(LanguageChangeEvent event) {
    Log.debug('Notifying ${_observers.length} observers of language change');

    for (final observer in _observers) {
      try {
        observer.update(event);
      } catch (e) {
        Log.error('Error notifying observer: $e');
      }
    }
  }
}

/// Event class for language changes
class LanguageChangeEvent {
  final Language oldLanguage;
  final Language newLanguage;
  final DateTime timestamp;
  final bool isRestore;

  const LanguageChangeEvent({
    required this.oldLanguage,
    required this.newLanguage,
    required this.timestamp,
    this.isRestore = false,
  });
}

/// Memento class for saving translation service state
class LanguageMemento extends Memento {
  final Language language;
  final Translation? translation;
  final Map<String, Translation> cacheSnapshot;

  @override
  final DateTime timestamp;

  @override
  final String description;

  LanguageMemento({
    required this.language,
    required this.translation,
    required this.cacheSnapshot,
    required this.timestamp,
  }) : description = 'Language: ${language.code}';

  Map<String, dynamic> toJson() {
    return {
      'language_code': language.code,
      'has_translation': translation != null,
      'cached_languages': cacheSnapshot.keys.toList(),
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  @override
  String toString() =>
      'LanguageMemento(${language.code} at ${timestamp.toIso8601String()})';
}
