/// Factory Method Pattern - Tower Defense Context
///
/// PATTERN: Factory Method - Creates objects without specifying exact classes
/// WHERE: Enemy and Tower creation throughout the game
/// HOW: Abstract creator with concrete implementations for different types
/// WHY: Allows flexibility in object creation and easy addition of new types
library;

import 'package:equatable/equatable.dart';

/// Base enemy class - Product interface
abstract class Enemy extends Equatable {
  final String name;
  final double health;
  final double speed;
  final double damage;
  final String type;

  const Enemy({
    required this.name,
    required this.health,
    required this.speed,
    required this.damage,
    required this.type,
  });

  /// Move towards target position
  void move(double deltaTime);

  /// Take damage from tower attack
  void takeDamage(double damage);

  /// Check if enemy is alive
  bool get isAlive => health > 0;

  /// Get enemy experience points reward
  int get experienceReward;

  @override
  List<Object> get props => [name, health, speed, damage, type];
}

/// Concrete enemy implementations
class Ant extends Enemy {
  const Ant()
    : super(
        name: 'Worker Ant',
        health: 100,
        speed: 50.0,
        damage: 10.0,
        type: 'ant',
      );

  @override
  void move(double deltaTime) {
    // Ant-specific movement: fast and straight
  }

  @override
  void takeDamage(double damage) {
    // Ant-specific damage handling
  }

  @override
  int get experienceReward => 10;
}

class Grasshopper extends Enemy {
  const Grasshopper()
    : super(
        name: 'Jumping Grasshopper',
        health: 150,
        speed: 75.0,
        damage: 15.0,
        type: 'grasshopper',
      );

  @override
  void move(double deltaTime) {
    // Grasshopper-specific movement: jumping pattern
  }

  @override
  void takeDamage(double damage) {
    // Grasshopper-specific damage handling
  }

  @override
  int get experienceReward => 15;
}

class Cockroach extends Enemy {
  const Cockroach()
    : super(
        name: 'Armored Cockroach',
        health: 200,
        speed: 40.0,
        damage: 20.0,
        type: 'cockroach',
      );

  @override
  void move(double deltaTime) {
    // Cockroach-specific movement: zigzag pattern
  }

  @override
  void takeDamage(double damage) {
    // Cockroach-specific damage handling with armor
  }

  @override
  int get experienceReward => 20;
}

/// Abstract Creator - Factory Method Pattern
abstract class EnemyFactory {
  /// Factory method - to be implemented by concrete creators
  Enemy createEnemy();

  /// Template method using the factory method
  Enemy spawnEnemy() {
    final enemy = createEnemy();
    // Common spawning logic here
    return enemy;
  }
}

/// Concrete Creators - Implement the factory method
class AntFactory extends EnemyFactory {
  @override
  Enemy createEnemy() => const Ant();
}

class GrasshopperFactory extends EnemyFactory {
  @override
  Enemy createEnemy() => const Grasshopper();
}

class CockroachFactory extends EnemyFactory {
  @override
  Enemy createEnemy() => const Cockroach();
}

/// Static factory for easy access
class EnemyCreator {
  static final Map<String, EnemyFactory> _factories = {
    'ant': AntFactory(),
    'grasshopper': GrasshopperFactory(),
    'cockroach': CockroachFactory(),
  };

  static Enemy? createEnemy(String type) {
    final factory = _factories[type];
    return factory?.createEnemy();
  }

  static List<String> get availableTypes => _factories.keys.toList();
}
