/// Configuration System Demo - Integration Example
///
/// PATTERN: Facade - Demonstrates configuration system usage
/// WHERE: Demo layer showing real-world usage examples
/// HOW: Simple demo methods showcasing all configuration capabilities
/// WHY: Provides clear examples of how to use the configuration system
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:design_patterns/core/patterns/behavioral/observer.dart';
import 'package:design_patterns/features/configuration/configuration.dart';

/// Demo class showing how to use the configuration system
///
/// This demonstrates all the patterns implemented:
/// - Singleton (ConfigService)
/// - Repository (ConfigRepository)
/// - Memento (Configuration state management)
/// - Observer (Configuration change notifications)
/// - Factory (SQLite configuration creation)
class ConfigDemo {
  /// Demonstrate basic configuration operations
  static Future<void> demonstrateBasicOperations() async {
    Log.debug('=== Configuration System Demo - Basic Operations ===');

    try {
      // Initialize configuration system (normally done in main.dart)
      await ConfigInjection.init();

      Log.success('Configuration system initialized successfully');

      // Get current configuration
      final currentConfig = ConfigHelpers.currentConfig;
      Log.info('Current language: ${currentConfig.languageCode}');
      Log.info('Current theme: ${currentConfig.themeMode}');
      Log.info('Current difficulty: ${currentConfig.difficultyLevel}');

      // Update individual settings
      Log.debug('\n--- Updating Configuration Settings ---');

      await ConfigHelpers.updateLanguage('es');
      Log.success('Language updated to Spanish');

      await ConfigHelpers.updateThemeMode('dark');
      Log.success('Theme updated to dark mode');

      await ConfigHelpers.updateDifficulty('hard');
      Log.success('Difficulty updated to hard');

      await ConfigHelpers.updateVolume(0.5);
      Log.success('Volume updated to 50%');

      // Show updated configuration
      final updatedConfig = ConfigHelpers.currentConfig;
      Log.info('\n--- Updated Configuration ---');
      Log.info('New language: ${updatedConfig.languageCode}');
      Log.info('New theme: ${updatedConfig.themeMode}');
      Log.info('New difficulty: ${updatedConfig.difficultyLevel}');
      Log.info('New volume: ${(updatedConfig.volume * 100).round()}%');
    } catch (e) {
      Log.error('Error in basic configuration demo: $e');
    }
  }

  /// Demonstrate advanced configuration features
  static Future<void> demonstrateAdvancedFeatures() async {
    Log.debug('\n=== Configuration System Demo - Advanced Features ===');

    try {
      // Show configuration summary
      final summary = ConfigHelpers.configSummary;
      Log.info('\n--- Configuration Summary ---');
      summary.forEach((key, value) {
        Log.info('$key: $value');
      });

      // Demonstrate undo functionality
      Log.debug('\n--- Undo Functionality ---');
      Log.info('History count before change: ${ConfigHelpers.historyCount}');

      await ConfigHelpers.updateLanguage('fr');
      Log.info('Changed language to French');
      Log.info('History count after change: ${ConfigHelpers.historyCount}');

      if (ConfigHelpers.canUndo) {
        ConfigHelpers.undoLastChange();
        Log.success('Undid last change successfully');
        final restoredConfig = ConfigHelpers.currentConfig;
        Log.info('Restored language: ${restoredConfig.languageCode}');
      }

      // Demonstrate configuration reset
      Log.debug('\n--- Configuration Reset ---');
      await ConfigHelpers.resetToDefaults(preserveLanguage: true);
      Log.success('Configuration reset to defaults (language preserved)');

      final resetConfig = ConfigHelpers.currentConfig;
      Log.info('Reset config language: ${resetConfig.languageCode}');
      Log.info('Reset config difficulty: ${resetConfig.difficultyLevel}');
    } catch (e) {
      Log.error('Error in advanced configuration demo: $e');
    }
  }

  /// Demonstrate Observer pattern with configuration changes
  static Future<void> demonstrateObserverPattern() async {
    Log.debug('\n=== Configuration System Demo - Observer Pattern ===');

    try {
      final configService = ConfigInjection.configService;

      // Create a demo observer
      final demoObserver = ConfigDemoObserver();

      // Register observer
      configService.addObserver(demoObserver);
      Log.info('Demo observer registered');

      // Make changes that will trigger notifications
      await ConfigHelpers.updateLanguage('de');
      await ConfigHelpers.updateThemeMode('light');
      await ConfigHelpers.updateSoundEnabled(false);

      // Unregister observer
      configService.removeObserver(demoObserver);
      Log.info('Demo observer unregistered');

      // This change won't trigger the demo observer
      await ConfigHelpers.updateLanguage('en');
    } catch (e) {
      Log.error('Error in observer pattern demo: $e');
    }
  }

  /// Demonstrate Memento pattern with state management
  static Future<void> demonstrateMementoPattern() async {
    Log.debug('\n=== Configuration System Demo - Memento Pattern ===');

    try {
      final configService = ConfigInjection.configService;

      // Create initial state
      await ConfigHelpers.updateLanguage('en');
      await ConfigHelpers.updateDifficulty('normal');
      Log.info('Initial state: EN, Normal difficulty');

      // Create memento (save state)
      final memento = configService.createMemento();
      Log.success('Configuration state saved to memento');

      // Make changes
      await ConfigHelpers.updateLanguage('es');
      await ConfigHelpers.updateDifficulty('hard');
      Log.info('Changed to: ES, Hard difficulty');

      // Restore from memento
      configService.restoreFromMemento(memento);
      Log.success('Configuration restored from memento');

      final restoredConfig = ConfigHelpers.currentConfig;
      Log.info(
        'Restored state: ${restoredConfig.languageCode}, ${restoredConfig.difficultyLevel}',
      );
    } catch (e) {
      Log.error('Error in memento pattern demo: $e');
    }
  }

  /// Run complete configuration system demonstration
  static Future<void> runCompleteDemo() async {
    Log.debug('\n🎮 === TOWER DEFENSE CONFIGURATION SYSTEM DEMO ===');

    await demonstrateBasicOperations();
    await demonstrateAdvancedFeatures();
    await demonstrateObserverPattern();
    await demonstrateMementoPattern();

    Log.success('\n🎉 Configuration System Demo completed successfully!');

    // Show debug information
    final debugInfo = ConfigHelpers.debugInfo;
    Log.debug('\n--- System Debug Info ---');
    Log.debug('Is Initialized: ${debugInfo['is_initialized']}');
    Log.debug('History Count: ${debugInfo['history_count']}');
    Log.debug('Observers Count: ${debugInfo['observers_count']}');
  }
}

/// Demo observer for configuration changes
class ConfigDemoObserver implements Observer<ConfigChangeEvent> {
  @override
  void update(ConfigChangeEvent event) {
    Log.debug('🔔 Configuration changed!');
    Log.debug(
      '   Old: ${event.oldConfig.languageCode}/${event.oldConfig.themeMode}',
    );
    Log.debug(
      '   New: ${event.newConfig.languageCode}/${event.newConfig.themeMode}',
    );

    final changes = event.changedKeys;
    if (changes.isNotEmpty) {
      Log.debug('   Changed: ${changes.join(', ')}');
    }

    if (event.isRestore) {
      Log.debug('   🔄 This was a restore operation');
    }
  }
}
