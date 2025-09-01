/// Adapter Pattern - Tower Defense Context
///
/// PATTERN: Adapter - Allows incompatible interfaces to work together
/// WHERE: Legacy tower compatibility with new tower system
/// HOW: Wrapper class that adapts old interface to new interface
/// WHY: Enables integration of legacy towers without modifying existing code
library;

import 'package:equatable/equatable.dart';

import '../../logging/console_logger.dart';

/// Modern tower interface that all new towers should implement
abstract class ModernTower {
  String get towerType;

  double get baseDamage;

  double get attackRange;

  double get attackSpeed;

  List<String> get supportedUpgrades;

  void attack(double targetX, double targetY, List<dynamic> enemies);

  void upgrade(String upgradeType);

  bool canUpgrade(String upgradeType);

  Map<String, dynamic> getStatus();
}

/// Legacy tower from old system that we need to integrate
class LegacyCannonTower extends Equatable {
  final String name;
  final int damage;
  final int range;
  final double fireRate;
  final bool isLoaded;

  const LegacyCannonTower({
    required this.name,
    required this.damage,
    required this.range,
    required this.fireRate,
    this.isLoaded = true,
  });

  // Old interface methods with different signatures
  void fireCannon(int x, int y) {
    Log.debug('Legacy cannon fires at ($x, $y) with damage $damage');
  }

  void reloadCannon() {
    Log.debug('Legacy cannon reloading...');
  }

  int getDamageOutput() => damage;

  int getShootingRange() => range;

  double getReloadSpeed() => fireRate;

  bool isReadyToFire() => isLoaded;

  void enhanceCannon(String enhancement) {
    Log.debug('Legacy cannon enhanced with $enhancement');
  }

  @override
  List<Object> get props => [name, damage, range, fireRate, isLoaded];
}

/// Another legacy tower with different interface
class OldArcherTower extends Equatable {
  final String towerName;
  final int arrowDamage;
  final int bowRange;
  final int arrowsPerSecond;
  final List<String> specialAbilities;

  const OldArcherTower({
    required this.towerName,
    required this.arrowDamage,
    required this.bowRange,
    required this.arrowsPerSecond,
    required this.specialAbilities,
  });

  // Different method names and signatures
  void shootArrow(double posX, double posY, String enemyType) {
    Log.debug('Old archer shoots arrow at ($posX, $posY) targeting $enemyType');
  }

  void trainArcher(String skill) {
    Log.debug('Archer trained in $skill');
  }

  int calculateDamage() => arrowDamage;

  int maxRange() => bowRange;

  int getFireRate() => arrowsPerSecond;

  List<String> getAbilities() => specialAbilities;

  @override
  List<Object> get props => [
    towerName,
    arrowDamage,
    bowRange,
    arrowsPerSecond,
    specialAbilities,
  ];
}

/// Adapter for Legacy Cannon Tower - Adapts old interface to new interface
class LegacyCannonAdapter implements ModernTower {
  final LegacyCannonTower _legacyCannon;

  LegacyCannonAdapter(this._legacyCannon);

  @override
  String get towerType => 'Legacy Cannon (Adapted)';

  @override
  double get baseDamage => _legacyCannon.getDamageOutput().toDouble();

  @override
  double get attackRange => _legacyCannon.getShootingRange().toDouble();

  @override
  double get attackSpeed => _legacyCannon.getReloadSpeed();

  @override
  List<String> get supportedUpgrades => [
    'damage_boost',
    'range_extension',
    'rapid_reload',
    'explosive_shells',
  ];

  @override
  void attack(double targetX, double targetY, List<dynamic> enemies) {
    // Adapt modern attack method to legacy interface
    if (_legacyCannon.isReadyToFire()) {
      _legacyCannon.fireCannon(targetX.round(), targetY.round());
      _legacyCannon.reloadCannon();
    }
  }

  @override
  void upgrade(String upgradeType) {
    // Adapt upgrade system to legacy enhancement system
    switch (upgradeType) {
      case 'damage_boost':
        _legacyCannon.enhanceCannon('Heavy Shells');
        break;
      case 'range_extension':
        _legacyCannon.enhanceCannon('Long Barrel');
        break;
      case 'rapid_reload':
        _legacyCannon.enhanceCannon('Quick Reload');
        break;
      case 'explosive_shells':
        _legacyCannon.enhanceCannon('Explosive Ammunition');
        break;
      default:
        _legacyCannon.enhanceCannon(upgradeType);
    }
  }

  @override
  bool canUpgrade(String upgradeType) {
    // Legacy system doesn't have upgrade restrictions, so always true
    return supportedUpgrades.contains(upgradeType);
  }

  @override
  Map<String, dynamic> getStatus() {
    return {
      'type': towerType,
      'damage': baseDamage,
      'range': attackRange,
      'speed': attackSpeed,
      'ready': _legacyCannon.isReadyToFire(),
      'legacy_name': _legacyCannon.name,
    };
  }
}

/// Adapter for Old Archer Tower
class OldArcherAdapter implements ModernTower {
  final OldArcherTower _oldArcher;

  OldArcherAdapter(this._oldArcher);

  @override
  String get towerType => 'Old Archer (Adapted)';

  @override
  double get baseDamage => _oldArcher.calculateDamage().toDouble();

  @override
  double get attackRange => _oldArcher.maxRange().toDouble();

  @override
  double get attackSpeed => _oldArcher.getFireRate().toDouble();

  @override
  List<String> get supportedUpgrades => [
    'sharp_arrows',
    'multi_shot',
    'poison_tips',
    'fire_arrows',
    ..._oldArcher.getAbilities().map((ability) => 'legacy_$ability'),
  ];

  @override
  void attack(double targetX, double targetY, List<dynamic> enemies) {
    // Adapt to old archer interface
    String enemyType = 'unknown';
    if (enemies.isNotEmpty) {
      enemyType = enemies.first.runtimeType.toString().toLowerCase();
    }
    _oldArcher.shootArrow(targetX, targetY, enemyType);
  }

  @override
  void upgrade(String upgradeType) {
    // Map modern upgrades to old training system
    switch (upgradeType) {
      case 'sharp_arrows':
        _oldArcher.trainArcher('Precision');
        break;
      case 'multi_shot':
        _oldArcher.trainArcher('Rapid Fire');
        break;
      case 'poison_tips':
        _oldArcher.trainArcher('Poison Mastery');
        break;
      case 'fire_arrows':
        _oldArcher.trainArcher('Fire Arrows');
        break;
      default:
        if (upgradeType.startsWith('legacy_')) {
          final skill = upgradeType.replaceFirst('legacy_', '');
          _oldArcher.trainArcher(skill);
        } else {
          _oldArcher.trainArcher(upgradeType);
        }
    }
  }

  @override
  bool canUpgrade(String upgradeType) {
    return supportedUpgrades.contains(upgradeType);
  }

  @override
  Map<String, dynamic> getStatus() {
    return {
      'type': towerType,
      'damage': baseDamage,
      'range': attackRange,
      'speed': attackSpeed,
      'abilities': _oldArcher.getAbilities(),
      'legacy_name': _oldArcher.towerName,
    };
  }
}

/// Modern tower implementation for comparison
class ModernDefenseTower implements ModernTower {
  final String _type;
  final double _baseDamage;
  final double _attackRange;
  final double _attackSpeed;
  final List<String> _upgrades;

  ModernDefenseTower({
    required String type,
    required double baseDamage,
    required double attackRange,
    required double attackSpeed,
    List<String>? supportedUpgrades,
  }) : _type = type,
       _baseDamage = baseDamage,
       _attackRange = attackRange,
       _attackSpeed = attackSpeed,
       _upgrades = supportedUpgrades ?? [];

  @override
  String get towerType => _type;

  @override
  double get baseDamage => _baseDamage;

  @override
  double get attackRange => _attackRange;

  @override
  double get attackSpeed => _attackSpeed;

  @override
  List<String> get supportedUpgrades => _upgrades;

  @override
  void attack(double targetX, double targetY, List<dynamic> enemies) {
    Log.debug('Modern $towerType attacks at ($targetX, $targetY)');
  }

  @override
  void upgrade(String upgradeType) {
    if (canUpgrade(upgradeType)) {
      Log.debug('Modern $towerType upgraded with $upgradeType');
    }
  }

  @override
  bool canUpgrade(String upgradeType) {
    return supportedUpgrades.contains(upgradeType);
  }

  @override
  Map<String, dynamic> getStatus() {
    return {
      'type': towerType,
      'damage': baseDamage,
      'range': attackRange,
      'speed': attackSpeed,
      'upgrades_available': supportedUpgrades.length,
    };
  }
}

/// Tower manager that works with both legacy and modern towers through adapter
class TowerManager {
  final List<ModernTower> _towers = [];

  void addTower(ModernTower tower) {
    _towers.add(tower);
  }

  // Factory methods that use adapters for legacy towers
  void addLegacyCannon(LegacyCannonTower legacyCannon) {
    final adapter = LegacyCannonAdapter(legacyCannon);
    _towers.add(adapter);
  }

  void addOldArcher(OldArcherTower oldArcher) {
    final adapter = OldArcherAdapter(oldArcher);
    _towers.add(adapter);
  }

  void addModernTower(ModernDefenseTower modernTower) {
    _towers.add(modernTower);
  }

  // Unified operations that work with all towers through common interface
  void attackAllTargets(double targetX, double targetY, List<dynamic> enemies) {
    for (final tower in _towers) {
      tower.attack(targetX, targetY, enemies);
    }
  }

  void upgradeAllTowers(String upgradeType) {
    for (final tower in _towers) {
      if (tower.canUpgrade(upgradeType)) {
        tower.upgrade(upgradeType);
      }
    }
  }

  List<Map<String, dynamic>> getAllTowerStatus() {
    return _towers.map((tower) => tower.getStatus()).toList();
  }

  double getTotalDamage() {
    return _towers.fold(0.0, (sum, tower) => sum + tower.baseDamage);
  }

  double getMaxRange() {
    if (_towers.isEmpty) return 0.0;
    return _towers
        .map((tower) => tower.attackRange)
        .reduce((a, b) => a > b ? a : b);
  }

  int get towerCount => _towers.length;

  List<ModernTower> get towers => List.unmodifiable(_towers);

  void clear() => _towers.clear();
}

/// Usage example demonstrating the adapter pattern
class AdapterPatternDemo {
  static void demonstratePattern() {
    Log.debug('=== Adapter Pattern Demo ===\n');

    final manager = TowerManager();

    // Add legacy towers through adapters
    final legacyCannon = LegacyCannonTower(
      name: 'Old Destroyer',
      damage: 150,
      range: 200,
      fireRate: 1.5,
    );

    final oldArcher = OldArcherTower(
      towerName: 'Veteran Bowman',
      arrowDamage: 75,
      bowRange: 180,
      arrowsPerSecond: 3,
      specialAbilities: ['Piercing Shot', 'Multi Target'],
    );

    // Add modern tower
    final modernTower = ModernDefenseTower(
      type: 'Laser Turret',
      baseDamage: 200,
      attackRange: 250,
      attackSpeed: 2.0,
      supportedUpgrades: ['beam_focus', 'cooling_system', 'overcharge'],
    );

    // Add all towers (legacy ones through adapters)
    manager.addLegacyCannon(legacyCannon);
    manager.addOldArcher(oldArcher);
    manager.addModernTower(modernTower);

    Log.debug('Tower Manager Status:');
    Log.debug('Total towers: ${manager.towerCount}');
    Log.debug('Total damage: ${manager.getTotalDamage()}');
    Log.debug('Max range: ${manager.getMaxRange()}\n');

    // All towers can be controlled through unified interface
    Log.debug('Attacking enemy at (100, 150):');
    manager.attackAllTargets(100, 150, ['enemy1']);

    Log.debug('\nUpgrading all towers:');
    manager.upgradeAllTowers('damage_boost');

    Log.debug('\nFinal tower statuses:');
    final statuses = manager.getAllTowerStatus();
    for (final status in statuses) {
      Log.debug(
        '${status['type']}: Damage ${status['damage']}, Range ${status['range']}',
      );
    }
  }
}
