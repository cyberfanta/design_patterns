/// Abstract Factory Pattern - Tower Defense Context
///
/// PATTERN: Abstract Factory - Creates families of related objects
/// WHERE: Tower and Projectile families (Archer+Arrow, StoneThower+Stone)
/// HOW: Abstract factory with concrete implementations for each family
/// WHY: Ensures compatible objects are created together (tower + matching projectile)
library;

import 'package:equatable/equatable.dart';

/// Base projectile class - Abstract Product A
abstract class Projectile extends Equatable {
  final String name;
  final double damage;
  final double speed;
  final double range;
  final String type;

  const Projectile({
    required this.name,
    required this.damage,
    required this.speed,
    required this.range,
    required this.type,
  });

  /// Fire projectile towards target
  void fire(double targetX, double targetY);

  /// Update projectile position
  void update(double deltaTime);

  /// Check if projectile hit target
  bool checkCollision(double x, double y, double radius);

  @override
  List<Object> get props => [name, damage, speed, range, type];
}

/// Base tower class - Abstract Product B
abstract class Tower extends Equatable {
  final String name;
  final double damage;
  final double range;
  final double fireRate;
  final String type;

  const Tower({
    required this.name,
    required this.damage,
    required this.range,
    required this.fireRate,
    required this.type,
  });

  /// Create compatible projectile
  Projectile createProjectile();

  /// Attack target with appropriate projectile
  void attack(double targetX, double targetY);

  /// Check if target is in range
  bool isInRange(double targetX, double targetY, double towerX, double towerY);

  @override
  List<Object> get props => [name, damage, range, fireRate, type];
}

/// Concrete Projectiles - Product A implementations
class Arrow extends Projectile {
  const Arrow()
    : super(
        name: 'Steel Arrow',
        damage: 50.0,
        speed: 200.0,
        range: 150.0,
        type: 'arrow',
      );

  @override
  void fire(double targetX, double targetY) {
    // Arrow-specific firing logic - precise and fast
  }

  @override
  void update(double deltaTime) {
    // Arrow-specific movement - straight line
  }

  @override
  bool checkCollision(double x, double y, double radius) {
    // Arrow-specific collision - point collision
    return false;
  }
}

class Stone extends Projectile {
  const Stone()
    : super(
        name: 'Heavy Stone',
        damage: 80.0,
        speed: 100.0,
        range: 120.0,
        type: 'stone',
      );

  @override
  void fire(double targetX, double targetY) {
    // Stone-specific firing logic - arc trajectory
  }

  @override
  void update(double deltaTime) {
    // Stone-specific movement - parabolic arc
  }

  @override
  bool checkCollision(double x, double y, double radius) {
    // Stone-specific collision - area of effect
    return false;
  }
}

/// Concrete Towers - Product B implementations
class ArcherTower extends Tower {
  const ArcherTower()
    : super(
        name: 'Archer Tower',
        damage: 50.0,
        range: 150.0,
        fireRate: 2.0,
        type: 'archer',
      );

  @override
  Projectile createProjectile() => const Arrow(); // Creates compatible projectile

  @override
  void attack(double targetX, double targetY) {
    final projectile = createProjectile();
    projectile.fire(targetX, targetY);
  }

  @override
  bool isInRange(double targetX, double targetY, double towerX, double towerY) {
    final distance =
        ((targetX - towerX) * (targetX - towerX) +
        (targetY - towerY) * (targetY - towerY));
    return distance <= range * range;
  }
}

class StoneThrowerTower extends Tower {
  const StoneThrowerTower()
    : super(
        name: 'Stone Thrower',
        damage: 80.0,
        range: 120.0,
        fireRate: 1.5,
        type: 'stone_thrower',
      );

  @override
  Projectile createProjectile() => const Stone(); // Creates compatible projectile

  @override
  void attack(double targetX, double targetY) {
    final projectile = createProjectile();
    projectile.fire(targetX, targetY);
  }

  @override
  bool isInRange(double targetX, double targetY, double towerX, double towerY) {
    final distance =
        ((targetX - towerX) * (targetX - towerX) +
        (targetY - towerY) * (targetY - towerY));
    return distance <= range * range;
  }
}

/// Abstract Factory - Creates families of related objects
abstract class TowerFactory {
  Tower createTower();

  Projectile createProjectile();

  /// Convenience method to create complete tower setup
  TowerSetup createTowerSetup() {
    return TowerSetup(tower: createTower(), projectile: createProjectile());
  }
}

/// Concrete Factory A - Creates Archer family
class ArcherTowerFactory extends TowerFactory {
  @override
  Tower createTower() => const ArcherTower();

  @override
  Projectile createProjectile() => const Arrow();
}

/// Concrete Factory B - Creates Stone Thrower family
class StoneThrowerFactory extends TowerFactory {
  @override
  Tower createTower() => const StoneThrowerTower();

  @override
  Projectile createProjectile() => const Stone();
}

/// Helper class to group related products
class TowerSetup extends Equatable {
  final Tower tower;
  final Projectile projectile;

  const TowerSetup({required this.tower, required this.projectile});

  @override
  List<Object> get props => [tower, projectile];
}

/// Factory Manager - Provides access to concrete factories
class TowerFactoryManager {
  static final Map<String, TowerFactory> _factories = {
    'archer': ArcherTowerFactory(),
    'stone_thrower': StoneThrowerFactory(),
  };

  static TowerFactory? getFactory(String type) => _factories[type];

  static TowerSetup? createTowerSetup(String type) {
    final factory = _factories[type];
    return factory?.createTowerSetup();
  }

  static List<String> get availableTypes => _factories.keys.toList();
}
