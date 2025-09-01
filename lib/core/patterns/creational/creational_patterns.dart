/// Creational Design Patterns - Tower Defense Implementation
///
/// PATTERN CATEGORY: Creational Patterns
/// WHERE: Object creation mechanisms throughout the tower defense game
/// HOW: Abstract object creation process, making system independent of object creation
/// WHY: Provides flexibility in what gets created, who creates it, how it gets created, and when
library;

export 'abstract_factory.dart';
export 'builder.dart';
// Export all creational patterns
export 'factory_method.dart';
export 'prototype.dart';
export 'singleton.dart';

/// Creational patterns summary and usage guide
class CreationalPatternsGuide {
  static const String description = '''
Creational patterns provide various object creation mechanisms, which increase 
flexibility and reuse of existing code in the Tower Defense game context.

IMPLEMENTED PATTERNS:

1. FACTORY METHOD
   - Purpose: Creates enemies without specifying exact classes
   - Usage: Enemy spawning system (Ant, Grasshopper, Cockroach)
   - Benefit: Easy addition of new enemy types

2. ABSTRACT FACTORY  
   - Purpose: Creates families of related objects (Tower + Projectile)
   - Usage: Tower-Projectile combinations (Archer+Arrow, StoneThower+Stone)
   - Benefit: Ensures compatible objects are created together

3. BUILDER
   - Purpose: Constructs complex objects step by step
   - Usage: Game map construction with walls, paths, house, traps
   - Benefit: Flexible map creation with many configuration options

4. PROTOTYPE
   - Purpose: Creates objects by cloning existing instances
   - Usage: Tower evolution tree upgrades and configurations
   - Benefit: Efficient creation of similar upgrade configurations

5. SINGLETON
   - Purpose: Ensures only one instance with global access
   - Usage: GameManager for centralized game state management
   - Benefit: Single source of truth for game state
''';

  /// Get pattern by name
  static String getPatternDescription(String patternName) {
    switch (patternName.toLowerCase()) {
      case 'factory_method':
        return 'Creates objects without specifying their concrete classes. Used for enemy creation in tower defense.';
      case 'abstract_factory':
        return 'Creates families of related objects. Used for tower-projectile combinations.';
      case 'builder':
        return 'Constructs complex objects step by step. Used for game map construction.';
      case 'prototype':
        return 'Creates objects by cloning existing instances. Used for tower upgrade configurations.';
      case 'singleton':
        return 'Ensures a class has only one instance. Used for GameManager.';
      default:
        return 'Pattern not found in creational patterns.';
    }
  }

  /// Get all implemented creational patterns
  static List<String> get implementedPatterns => [
    'Factory Method',
    'Abstract Factory',
    'Builder',
    'Prototype',
    'Singleton',
  ];

  /// Check if pattern is implemented
  static bool isPatternImplemented(String patternName) {
    return implementedPatterns.any(
      (pattern) => pattern.toLowerCase() == patternName.toLowerCase(),
    );
  }
}
