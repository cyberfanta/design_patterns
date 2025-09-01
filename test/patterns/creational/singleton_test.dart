/// Singleton Pattern Tests
///
/// PATTERN: Singleton - Ensures only one instance exists with global access
/// WHERE: GameManager instance management testing
/// HOW: Tests single instance guarantee and state management
/// WHY: Verifies singleton behavior and global state consistency
library;

import 'package:design_patterns/core/patterns/creational/singleton.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Singleton Pattern Tests', () {
    tearDown(() {
      // Reset GameManager state after each test
      GameManager.instance.reset();
    });

    group('Instance Management', () {
      test('GameManager() returns the same instance', () {
        final manager1 = GameManager();
        final manager2 = GameManager();

        expect(identical(manager1, manager2), isTrue);
      });

      test('GameManager.instance returns the same instance', () {
        final manager1 = GameManager.instance;
        final manager2 = GameManager.instance;

        expect(identical(manager1, manager2), isTrue);
      });

      test('Factory and static getter return same instance', () {
        final manager1 = GameManager();
        final manager2 = GameManager.instance;

        expect(identical(manager1, manager2), isTrue);
      });
    });

    group('Game State Management', () {
      test('Initial game state is correct', () {
        final manager = GameManager();

        expect(manager.currentState, equals(GameState.menu));
        expect(manager.playerProgress.level, equals(1));
        expect(manager.playerProgress.experience, equals(0));
        expect(manager.playerProgress.evolutionPoints, equals(0));
        expect(manager.playerProgress.currentWave, equals(1));
        expect(manager.playerProgress.highScore, equals(0));
        expect(manager.isPlaying, isFalse);
        expect(manager.isPaused, isFalse);
        expect(manager.isGameOver, isFalse);
      });

      test('State changes work correctly', () {
        final manager = GameManager();

        manager.startGame();
        expect(manager.currentState, equals(GameState.playing));
        expect(manager.isPlaying, isTrue);

        manager.pauseGame();
        expect(manager.currentState, equals(GameState.paused));
        expect(manager.isPaused, isTrue);

        manager.resumeGame();
        expect(manager.currentState, equals(GameState.playing));

        manager.endGame(true);
        expect(manager.currentState, equals(GameState.victory));

        manager.endGame(false);
        expect(manager.currentState, equals(GameState.gameOver));
        expect(manager.isGameOver, isTrue);

        manager.returnToMenu();
        expect(manager.currentState, equals(GameState.menu));
      });
    });

    group('Player Progress Management', () {
      test('Experience and level calculation works', () {
        final manager = GameManager();

        manager.addExperience(50);
        expect(manager.playerProgress.experience, equals(50));
        expect(manager.playerProgress.level, equals(1));

        manager.addExperience(75); // Total: 125, should level up
        expect(manager.playerProgress.experience, equals(125));
        expect(
          manager.playerProgress.level,
          equals(2),
        ); // level = (exp / 100).floor() + 1
        expect(
          manager.playerProgress.evolutionPoints,
          equals(1),
        ); // gained 1 level
      });

      test('Evolution points can be spent', () {
        final manager = GameManager();

        manager.addExperience(
          200,
        ); // Should get to level 3 with 2 evolution points
        expect(manager.playerProgress.evolutionPoints, equals(2));

        manager.spendEvolutionPoints(1);
        expect(manager.playerProgress.evolutionPoints, equals(1));

        // Cannot spend more than available
        manager.spendEvolutionPoints(5);
        expect(
          manager.playerProgress.evolutionPoints,
          equals(1),
        ); // Should remain unchanged
      });

      test('Wave advancement works', () {
        final manager = GameManager();

        expect(manager.playerProgress.currentWave, equals(1));
        expect(manager.gameStats.wavesSurvived, equals(0));

        manager.advanceWave();
        expect(manager.playerProgress.currentWave, equals(2));
        expect(manager.gameStats.wavesSurvived, equals(1));
      });
    });

    group('Game Statistics', () {
      test('Enemy kill tracking works', () {
        final manager = GameManager();

        expect(manager.gameStats.enemiesKilled, equals(0));

        manager.recordEnemyKilled(10);
        expect(manager.gameStats.enemiesKilled, equals(1));
        expect(manager.playerProgress.experience, equals(10));

        manager.recordEnemyKilled(15);
        expect(manager.gameStats.enemiesKilled, equals(2));
        expect(manager.playerProgress.experience, equals(25));
      });

      test('Tower building tracking works', () {
        final manager = GameManager();

        expect(manager.gameStats.towersBuilt, equals(0));

        manager.recordTowerBuilt();
        expect(manager.gameStats.towersBuilt, equals(1));

        manager.recordTowerBuilt();
        expect(manager.gameStats.towersBuilt, equals(2));
      });

      test('Damage tracking works', () {
        final manager = GameManager();

        expect(manager.gameStats.totalDamageDealt, equals(0));

        manager.recordDamageDealt(100);
        expect(manager.gameStats.totalDamageDealt, equals(100));

        manager.recordDamageDealt(250);
        expect(manager.gameStats.totalDamageDealt, equals(350));
      });
    });

    group('Observer Integration', () {
      test('State observers are notified', () {
        final manager = GameManager();
        GameState? notifiedState;

        manager.addStateObserver((state) {
          notifiedState = state;
        });

        manager.startGame();
        expect(notifiedState, equals(GameState.playing));

        manager.pauseGame();
        expect(notifiedState, equals(GameState.paused));
      });

      test('Progress observers are notified', () {
        final manager = GameManager();
        PlayerProgress? notifiedProgress;

        manager.addProgressObserver((progress) {
          notifiedProgress = progress;
        });

        manager.addExperience(50);
        expect(notifiedProgress, isNotNull);
        expect(notifiedProgress!.experience, equals(50));
      });

      test('Stats observers are notified', () {
        final manager = GameManager();
        GameStats? notifiedStats;

        manager.addStatsObserver((stats) {
          notifiedStats = stats;
        });

        manager.recordEnemyKilled(10);
        expect(notifiedStats, isNotNull);
        expect(notifiedStats!.enemiesKilled, equals(1));
      });
    });

    group('Serialization', () {
      test('toJson and fromJson work correctly', () {
        final manager = GameManager();

        // Set up some state
        manager.startGame();
        manager.addExperience(150);
        manager.recordEnemyKilled(10);
        manager.recordTowerBuilt();

        // Serialize
        final json = manager.toJson();
        expect(json, isA<Map<String, dynamic>>());

        // Reset and restore
        manager.reset();
        expect(manager.playerProgress.level, equals(1));

        manager.fromJson(json);
        expect(manager.playerProgress.level, equals(2)); // 150 exp = level 2
        expect(manager.playerProgress.experience, equals(150));
        expect(manager.gameStats.enemiesKilled, equals(1));
        expect(manager.gameStats.towersBuilt, equals(1));
      });
    });

    group('Helper Class', () {
      test('Game helper class provides easy access', () {
        GameManager.instance.startGame();
        GameManager.instance.addExperience(100);

        expect(Game.state, equals(GameState.playing));
        expect(Game.progress.experience, equals(100));
        expect(Game.manager, equals(GameManager.instance));

        Game.pause();
        expect(Game.state, equals(GameState.paused));

        Game.resume();
        expect(Game.state, equals(GameState.playing));

        Game.end(victory: true);
        expect(Game.state, equals(GameState.victory));
      });
    });
  });
}
