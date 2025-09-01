/// Factory Method Pattern Tests
///
/// PATTERN: Factory Method - Creates objects without specifying exact classes
/// WHERE: Enemy creation system testing
/// HOW: Tests different enemy factories and their products
/// WHY: Verifies correct object creation and polymorphic behavior
library;

import 'package:design_patterns/core/patterns/creational/factory_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Factory Method Pattern Tests', () {
    group('Enemy Factories', () {
      test('AntFactory creates correct Ant enemy', () {
        final factory = AntFactory();
        final enemy = factory.createEnemy();

        expect(enemy, isA<Ant>());
        expect(enemy.name, equals('Worker Ant'));
        expect(enemy.health, equals(100));
        expect(enemy.speed, equals(50.0));
        expect(enemy.damage, equals(10.0));
        expect(enemy.type, equals('ant'));
        expect(enemy.experienceReward, equals(10));
        expect(enemy.isAlive, isTrue);
      });

      test('GrasshopperFactory creates correct Grasshopper enemy', () {
        final factory = GrasshopperFactory();
        final enemy = factory.createEnemy();

        expect(enemy, isA<Grasshopper>());
        expect(enemy.name, equals('Jumping Grasshopper'));
        expect(enemy.health, equals(150));
        expect(enemy.speed, equals(75.0));
        expect(enemy.damage, equals(15.0));
        expect(enemy.type, equals('grasshopper'));
        expect(enemy.experienceReward, equals(15));
      });

      test('CockroachFactory creates correct Cockroach enemy', () {
        final factory = CockroachFactory();
        final enemy = factory.createEnemy();

        expect(enemy, isA<Cockroach>());
        expect(enemy.name, equals('Armored Cockroach'));
        expect(enemy.health, equals(200));
        expect(enemy.speed, equals(40.0));
        expect(enemy.damage, equals(20.0));
        expect(enemy.type, equals('cockroach'));
        expect(enemy.experienceReward, equals(20));
      });
    });

    group('Template Method Usage', () {
      test('spawnEnemy uses factory method correctly', () {
        final factory = AntFactory();
        final enemy = factory.spawnEnemy();

        expect(enemy, isA<Ant>());
        expect(enemy.name, equals('Worker Ant'));
      });
    });

    group('Static Factory', () {
      test('EnemyCreator creates enemies by type', () {
        final ant = EnemyCreator.createEnemy('ant');
        final grasshopper = EnemyCreator.createEnemy('grasshopper');
        final cockroach = EnemyCreator.createEnemy('cockroach');

        expect(ant, isA<Ant>());
        expect(grasshopper, isA<Grasshopper>());
        expect(cockroach, isA<Cockroach>());
      });

      test('EnemyCreator returns null for invalid type', () {
        final enemy = EnemyCreator.createEnemy('invalid_type');

        expect(enemy, isNull);
      });

      test('EnemyCreator provides available types', () {
        final types = EnemyCreator.availableTypes;

        expect(types, contains('ant'));
        expect(types, contains('grasshopper'));
        expect(types, contains('cockroach'));
        expect(types.length, equals(3));
      });
    });

    group('Polymorphism', () {
      test('All enemies implement Enemy interface correctly', () {
        final enemies = [
          AntFactory().createEnemy(),
          GrasshopperFactory().createEnemy(),
          CockroachFactory().createEnemy(),
        ];

        for (final enemy in enemies) {
          expect(enemy, isA<Enemy>());
          expect(enemy.name, isNotEmpty);
          expect(enemy.health, greaterThan(0));
          expect(enemy.speed, greaterThan(0));
          expect(enemy.damage, greaterThan(0));
          expect(enemy.type, isNotEmpty);
          expect(enemy.experienceReward, greaterThan(0));
          expect(enemy.isAlive, isTrue);
        }
      });
    });

    group('Enemy Behavior', () {
      test('Enemy equality works correctly', () {
        final ant1 = const Ant();
        final ant2 = const Ant();
        final grasshopper = const Grasshopper();

        expect(ant1, equals(ant2));
        expect(ant1, isNot(equals(grasshopper)));
      });

      test('Enemy properties are immutable', () {
        const ant = Ant();

        // These should remain constant
        expect(ant.health, equals(100));
        expect(ant.speed, equals(50.0));
        expect(ant.damage, equals(10.0));
      });
    });
  });
}
