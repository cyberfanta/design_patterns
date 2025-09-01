/// Prototype Pattern - Tower Defense Context
///
/// PATTERN: Prototype - Creates objects by cloning existing instances
/// WHERE: Tower configuration cloning for evolution tree upgrades
/// HOW: Cloneable interface with deep copy implementation
/// WHY: Efficiently creates similar objects with different configurations
library;

import 'package:equatable/equatable.dart';

/// Abstract prototype interface
abstract class Cloneable<T> {
  T clone();
}

/// Tower upgrade configuration that can be cloned
class TowerUpgrade extends Equatable implements Cloneable<TowerUpgrade> {
  final String name;
  final String description;
  final double damageIncrease;
  final double rangeIncrease;
  final double fireRateIncrease;
  final int cost;
  final String upgradeType;
  final List<String> effects;

  const TowerUpgrade({
    required this.name,
    required this.description,
    required this.damageIncrease,
    required this.rangeIncrease,
    required this.fireRateIncrease,
    required this.cost,
    required this.upgradeType,
    required this.effects,
  });

  @override
  TowerUpgrade clone() {
    return TowerUpgrade(
      name: name,
      description: description,
      damageIncrease: damageIncrease,
      rangeIncrease: rangeIncrease,
      fireRateIncrease: fireRateIncrease,
      cost: cost,
      upgradeType: upgradeType,
      effects: List<String>.from(effects), // Deep copy of list
    );
  }

  /// Create a modified clone with different values
  TowerUpgrade cloneWith({
    String? name,
    String? description,
    double? damageIncrease,
    double? rangeIncrease,
    double? fireRateIncrease,
    int? cost,
    String? upgradeType,
    List<String>? effects,
  }) {
    return TowerUpgrade(
      name: name ?? this.name,
      description: description ?? this.description,
      damageIncrease: damageIncrease ?? this.damageIncrease,
      rangeIncrease: rangeIncrease ?? this.rangeIncrease,
      fireRateIncrease: fireRateIncrease ?? this.fireRateIncrease,
      cost: cost ?? this.cost,
      upgradeType: upgradeType ?? this.upgradeType,
      effects: effects ?? List<String>.from(this.effects),
    );
  }

  @override
  List<Object> get props => [
    name,
    description,
    damageIncrease,
    rangeIncrease,
    fireRateIncrease,
    cost,
    upgradeType,
    effects,
  ];
}

/// Evolution tree node that contains upgrade configurations
class EvolutionNode extends Equatable implements Cloneable<EvolutionNode> {
  final String id;
  final String name;
  final TowerUpgrade upgrade;
  final List<String> prerequisites;
  final List<EvolutionNode> children;
  final int tier;
  final bool isUnlocked;

  const EvolutionNode({
    required this.id,
    required this.name,
    required this.upgrade,
    required this.prerequisites,
    required this.children,
    required this.tier,
    this.isUnlocked = false,
  });

  @override
  EvolutionNode clone() {
    return EvolutionNode(
      id: id,
      name: name,
      upgrade: upgrade.clone(),
      // Deep copy of upgrade
      prerequisites: List<String>.from(prerequisites),
      children: children.map((child) => child.clone()).toList(),
      // Deep copy of children
      tier: tier,
      isUnlocked: isUnlocked,
    );
  }

  /// Create a modified clone
  EvolutionNode cloneWith({
    String? id,
    String? name,
    TowerUpgrade? upgrade,
    List<String>? prerequisites,
    List<EvolutionNode>? children,
    int? tier,
    bool? isUnlocked,
  }) {
    return EvolutionNode(
      id: id ?? this.id,
      name: name ?? this.name,
      upgrade: upgrade ?? this.upgrade.clone(),
      prerequisites: prerequisites ?? List<String>.from(this.prerequisites),
      children:
          children ?? this.children.map((child) => child.clone()).toList(),
      tier: tier ?? this.tier,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  List<Object> get props => [
    id,
    name,
    upgrade,
    prerequisites,
    children,
    tier,
    isUnlocked,
  ];
}

/// Prototype manager that stores and clones configurations
class EvolutionPrototypeManager {
  final Map<String, EvolutionNode> _prototypes = {};

  // Initialize with base prototypes
  EvolutionPrototypeManager() {
    _initializePrototypes();
  }

  void _initializePrototypes() {
    // Base Archer Tower Evolution Tree
    _prototypes['archer_damage_1'] = EvolutionNode(
      id: 'archer_damage_1',
      name: 'Sharp Arrows',
      upgrade: const TowerUpgrade(
        name: 'Sharp Arrows',
        description: 'Increases arrow damage by 25%',
        damageIncrease: 0.25,
        rangeIncrease: 0.0,
        fireRateIncrease: 0.0,
        cost: 50,
        upgradeType: 'damage',
        effects: ['sharp_tip', 'armor_piercing'],
      ),
      prerequisites: [],
      children: [],
      tier: 1,
    );

    _prototypes['archer_range_1'] = EvolutionNode(
      id: 'archer_range_1',
      name: 'Eagle Eye',
      upgrade: const TowerUpgrade(
        name: 'Eagle Eye',
        description: 'Increases shooting range by 30%',
        damageIncrease: 0.0,
        rangeIncrease: 0.30,
        fireRateIncrease: 0.0,
        cost: 40,
        upgradeType: 'range',
        effects: ['enhanced_sight', 'wind_compensation'],
      ),
      prerequisites: [],
      children: [],
      tier: 1,
    );

    _prototypes['archer_speed_1'] = EvolutionNode(
      id: 'archer_speed_1',
      name: 'Rapid Fire',
      upgrade: const TowerUpgrade(
        name: 'Rapid Fire',
        description: 'Increases fire rate by 40%',
        damageIncrease: 0.0,
        rangeIncrease: 0.0,
        fireRateIncrease: 0.40,
        cost: 60,
        upgradeType: 'speed',
        effects: ['quick_reload', 'steady_aim'],
      ),
      prerequisites: [],
      children: [],
      tier: 1,
    );

    // Base Stone Thrower Evolution Tree
    _prototypes['stone_damage_1'] = EvolutionNode(
      id: 'stone_damage_1',
      name: 'Heavy Stones',
      upgrade: const TowerUpgrade(
        name: 'Heavy Stones',
        description: 'Throws heavier stones for 35% more damage',
        damageIncrease: 0.35,
        rangeIncrease: 0.0,
        fireRateIncrease: -0.10,
        // Negative for slower fire rate
        cost: 70,
        upgradeType: 'damage',
        effects: ['crushing_weight', 'area_damage'],
      ),
      prerequisites: [],
      children: [],
      tier: 1,
    );

    _prototypes['stone_splash_1'] = EvolutionNode(
      id: 'stone_splash_1',
      name: 'Explosive Stones',
      upgrade: const TowerUpgrade(
        name: 'Explosive Stones',
        description: 'Stones explode on impact, damaging nearby enemies',
        damageIncrease: 0.15,
        rangeIncrease: 0.0,
        fireRateIncrease: 0.0,
        cost: 80,
        upgradeType: 'special',
        effects: ['explosion', 'splash_damage', 'debris'],
      ),
      prerequisites: [],
      children: [],
      tier: 1,
    );
  }

  /// Get a clone of a prototype by key
  EvolutionNode? getPrototype(String key) {
    final prototype = _prototypes[key];
    return prototype?.clone();
  }

  /// Register a new prototype
  void registerPrototype(String key, EvolutionNode prototype) {
    _prototypes[key] = prototype.clone();
  }

  /// Create a new evolution node based on existing prototype
  EvolutionNode? createEvolutionNode(
    String prototypeKey, {
    String? newId,
    String? newName,
    int? newTier,
    List<String>? newPrerequisites,
  }) {
    final prototype = getPrototype(prototypeKey);
    if (prototype == null) return null;

    return prototype.cloneWith(
      id: newId ?? prototype.id,
      name: newName ?? prototype.name,
      tier: newTier ?? prototype.tier,
      prerequisites: newPrerequisites ?? prototype.prerequisites,
    );
  }

  /// Create advanced evolution node by combining prototypes
  EvolutionNode? createCombinedEvolution(
    List<String> prototypeKeys,
    String newId,
    String newName,
  ) {
    if (prototypeKeys.isEmpty) return null;

    final basePrototype = getPrototype(prototypeKeys.first);
    if (basePrototype == null) return null;

    // Start with the first prototype
    double totalDamageIncrease = basePrototype.upgrade.damageIncrease;
    double totalRangeIncrease = basePrototype.upgrade.rangeIncrease;
    double totalFireRateIncrease = basePrototype.upgrade.fireRateIncrease;
    int totalCost = basePrototype.upgrade.cost;
    final List<String> combinedEffects = List<String>.from(
      basePrototype.upgrade.effects,
    );

    // Combine effects from other prototypes
    for (int i = 1; i < prototypeKeys.length; i++) {
      final prototype = getPrototype(prototypeKeys[i]);
      if (prototype != null) {
        totalDamageIncrease +=
            prototype.upgrade.damageIncrease * 0.7; // Diminishing returns
        totalRangeIncrease += prototype.upgrade.rangeIncrease * 0.7;
        totalFireRateIncrease += prototype.upgrade.fireRateIncrease * 0.7;
        totalCost += (prototype.upgrade.cost * 1.5)
            .round(); // Increased cost for combinations

        // Add unique effects
        for (final effect in prototype.upgrade.effects) {
          if (!combinedEffects.contains(effect)) {
            combinedEffects.add(effect);
          }
        }
      }
    }

    final combinedUpgrade = TowerUpgrade(
      name: newName,
      description: 'Advanced upgrade combining multiple enhancements',
      damageIncrease: totalDamageIncrease,
      rangeIncrease: totalRangeIncrease,
      fireRateIncrease: totalFireRateIncrease,
      cost: totalCost,
      upgradeType: 'combined',
      effects: combinedEffects,
    );

    return EvolutionNode(
      id: newId,
      name: newName,
      upgrade: combinedUpgrade,
      prerequisites: prototypeKeys,
      children: [],
      tier: 3, // Combined upgrades are higher tier
    );
  }

  /// Get all available prototype keys
  List<String> get availablePrototypes => _prototypes.keys.toList();

  /// Create evolution tree branch from prototype
  EvolutionNode createEvolutionBranch(String rootPrototypeKey) {
    final root = getPrototype(rootPrototypeKey);
    if (root == null) {
      throw ArgumentError('Prototype $rootPrototypeKey not found');
    }

    // Create tier 2 upgrades based on tier 1
    final tier2Upgrades = _createTier2Upgrades(root);

    return root.cloneWith(children: tier2Upgrades);
  }

  List<EvolutionNode> _createTier2Upgrades(EvolutionNode tier1Node) {
    final tier2Nodes = <EvolutionNode>[];

    // Create enhanced version of the tier 1 upgrade
    final enhancedUpgrade = tier1Node.upgrade.cloneWith(
      name: 'Enhanced ${tier1Node.upgrade.name}',
      description: 'Improved version of ${tier1Node.upgrade.name}',
      damageIncrease: tier1Node.upgrade.damageIncrease * 1.5,
      rangeIncrease: tier1Node.upgrade.rangeIncrease * 1.5,
      fireRateIncrease: tier1Node.upgrade.fireRateIncrease * 1.5,
      cost: (tier1Node.upgrade.cost * 2.5).round(),
    );

    tier2Nodes.add(
      EvolutionNode(
        id: '${tier1Node.id}_enhanced',
        name: enhancedUpgrade.name,
        upgrade: enhancedUpgrade,
        prerequisites: [tier1Node.id],
        children: [],
        tier: 2,
      ),
    );

    return tier2Nodes;
  }

  /// Clear all prototypes (useful for testing)
  void clearPrototypes() {
    _prototypes.clear();
  }

  /// Get prototype count
  int get prototypeCount => _prototypes.length;
}

/// Factory class for creating evolution trees using prototypes
class EvolutionTreeFactory {
  static final _prototypeManager = EvolutionPrototypeManager();

  /// Create complete evolution tree for archer towers
  static EvolutionNode createArcherEvolutionTree() {
    final root = EvolutionNode(
      id: 'archer_root',
      name: 'Archer Tower Evolution',
      upgrade: const TowerUpgrade(
        name: 'Base Archer',
        description: 'Basic archer tower',
        damageIncrease: 0.0,
        rangeIncrease: 0.0,
        fireRateIncrease: 0.0,
        cost: 0,
        upgradeType: 'base',
        effects: [],
      ),
      prerequisites: [],
      children: [],
      tier: 0,
    );

    // Create tier 1 children
    final tier1Children = [
      _prototypeManager.getPrototype('archer_damage_1')!,
      _prototypeManager.getPrototype('archer_range_1')!,
      _prototypeManager.getPrototype('archer_speed_1')!,
    ];

    return root.cloneWith(children: tier1Children);
  }

  /// Create complete evolution tree for stone thrower towers
  static EvolutionNode createStoneEvolutionTree() {
    final root = EvolutionNode(
      id: 'stone_root',
      name: 'Stone Thrower Evolution',
      upgrade: const TowerUpgrade(
        name: 'Base Stone Thrower',
        description: 'Basic stone throwing tower',
        damageIncrease: 0.0,
        rangeIncrease: 0.0,
        fireRateIncrease: 0.0,
        cost: 0,
        upgradeType: 'base',
        effects: [],
      ),
      prerequisites: [],
      children: [],
      tier: 0,
    );

    // Create tier 1 children
    final tier1Children = [
      _prototypeManager.getPrototype('stone_damage_1')!,
      _prototypeManager.getPrototype('stone_splash_1')!,
    ];

    return root.cloneWith(children: tier1Children);
  }

  /// Create custom evolution node using prototype manager
  static EvolutionNode? createCustomEvolution(
    String prototypeKey,
    Map<String, dynamic> customizations,
  ) {
    return _prototypeManager.createEvolutionNode(
      prototypeKey,
      newId: customizations['id'],
      newName: customizations['name'],
      newTier: customizations['tier'],
      newPrerequisites: customizations['prerequisites'],
    );
  }

  /// Access to prototype manager for advanced usage
  static EvolutionPrototypeManager get prototypeManager => _prototypeManager;
}
