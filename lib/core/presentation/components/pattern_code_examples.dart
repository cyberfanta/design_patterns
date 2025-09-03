/// Pattern Code Examples - Predefined Code Examples for Design Patterns
///
/// PATTERN: Template Method + Factory - Predefined pattern examples with consistent structure
/// WHERE: Core presentation components for educational pattern examples
/// HOW: Template Method defines structure, Factory creates specific pattern examples
/// WHY: Consistent Tower Defense context examples across all patterns for learning
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'glass_code_viewer.dart';

/// Pattern category enumeration for organization
enum PatternCategory {
  creational(
    'Creational Patterns',
    'Object creation mechanisms',
    Icons.build,
    Color(0xFF4CAF50),
  ),
  structural(
    'Structural Patterns',
    'Object composition',
    Icons.architecture,
    Color(0xFF2196F3),
  ),
  behavioral(
    'Behavioral Patterns',
    'Communication between objects',
    Icons.psychology,
    Color(0xFFFF9800),
  );

  const PatternCategory(this.name, this.description, this.icon, this.color);

  final String name;
  final String description;
  final IconData icon;
  final Color color;
}

/// Predefined pattern example data
class PatternExample {
  final String name;
  final String description;
  final PatternCategory category;
  final Map<String, dynamic> context;
  final String difficulty;
  final List<String> concepts;
  final List<String> useCases;

  const PatternExample({
    required this.name,
    required this.description,
    required this.category,
    required this.context,
    this.difficulty = 'Intermediate',
    this.concepts = const [],
    this.useCases = const [],
  });
}

/// Factory for creating pattern examples
class PatternExampleFactory {
  static final Map<String, PatternExample> _examples = {
    // CREATIONAL PATTERNS
    'singleton': PatternExample(
      name: 'Singleton',
      description:
          'Ensures a class has only one instance and provides global access',
      category: PatternCategory.creational,
      difficulty: 'Beginner',
      concepts: [
        'Global access',
        'Single instance',
        'Lazy initialization',
        'Thread safety',
      ],
      useCases: [
        'Game manager',
        'Configuration settings',
        'Database connections',
        'Logging service',
      ],
      context: {
        'className': 'TowerDefenseGame',
        'patternType': 'Creational',
        'howImplementation':
            'Ensures only one game instance exists globally with thread-safe lazy initialization',
        'whyUseful':
            'Manages global game state, resources, and settings from a single point of control',
        'towerDefenseContext':
            'Game manager that tracks gold, lives, and game state across all components',
        'keyBenefits': [
          'Global state management',
          'Resource control',
          'Consistency',
        ],
        'realWorldExample': 'Game configuration manager in Tower Defense apps',
      },
    ),

    'factory': PatternExample(
      name: 'Factory Method',
      description: 'Creates objects without specifying exact classes',
      category: PatternCategory.creational,
      difficulty: 'Intermediate',
      concepts: [
        'Object creation',
        'Abstraction',
        'Polymorphism',
        'Extensibility',
      ],
      useCases: [
        'Tower creation',
        'Enemy spawning',
        'UI components',
        'Strategy selection',
      ],
      context: {
        'className': 'TowerFactory',
        'patternType': 'Creational',
        'howImplementation':
            'Factory method creates different tower types based on string parameters with polymorphic behavior',
        'whyUseful':
            'Allows creating towers without tight coupling to specific classes, enabling easy addition of new tower types',
        'towerDefenseContext':
            'Tower creation system that spawns Archer, Cannon, and Magic towers based on player selection',
        'keyBenefits': [
          'Loose coupling',
          'Easy extensibility',
          'Centralized creation logic',
        ],
        'realWorldExample': 'Tower placement system in strategy games',
      },
    ),

    'builder': PatternExample(
      name: 'Builder',
      description: 'Constructs complex objects step by step',
      category: PatternCategory.creational,
      difficulty: 'Intermediate',
      concepts: [
        'Step-by-step construction',
        'Fluent interface',
        'Complex objects',
        'Configuration',
      ],
      useCases: [
        'Tower configuration',
        'Level generation',
        'UI layouts',
        'Game settings',
      ],
      context: {
        'className': 'TowerBuilder',
        'patternType': 'Creational',
        'howImplementation':
            'Builder constructs towers step-by-step with fluent interface for configuring properties',
        'whyUseful':
            'Enables creating complex tower configurations with optional parameters and validation',
        'towerDefenseContext':
            'Tower customization system allowing players to configure damage, range, and special abilities',
        'keyBenefits': [
          'Flexible construction',
          'Readable code',
          'Parameter validation',
        ],
        'realWorldExample': 'Character customization in RPG games',
      },
    ),

    // STRUCTURAL PATTERNS
    'adapter': PatternExample(
      name: 'Adapter',
      description: 'Allows incompatible interfaces to work together',
      category: PatternCategory.structural,
      difficulty: 'Beginner',
      concepts: [
        'Interface compatibility',
        'Wrapper',
        'Legacy integration',
        'API adaptation',
      ],
      useCases: [
        'Third-party APIs',
        'Legacy systems',
        'Data format conversion',
        'Platform compatibility',
      ],
      context: {
        'className': 'LegacyTowerAdapter',
        'patternType': 'Structural',
        'howImplementation':
            'Adapter wraps legacy tower system to work with new tower interface without changing existing code',
        'whyUseful':
            'Integrates old tower types with new game engine without rewriting legacy tower implementations',
        'towerDefenseContext':
            'Compatibility layer for importing tower designs from previous game versions',
        'keyBenefits': [
          'Legacy compatibility',
          'No code changes to existing classes',
          'Gradual migration',
        ],
        'realWorldExample': 'Plugin systems in game engines',
      },
    ),

    'decorator': PatternExample(
      name: 'Decorator',
      description:
          'Adds behavior to objects dynamically without altering structure',
      category: PatternCategory.structural,
      difficulty: 'Intermediate',
      concepts: [
        'Dynamic behavior',
        'Composition over inheritance',
        'Flexible extension',
        'Wrapper pattern',
      ],
      useCases: [
        'Tower upgrades',
        'UI effects',
        'Ability stacking',
        'Feature toggling',
      ],
      context: {
        'className': 'TowerDecorator',
        'patternType': 'Structural',
        'howImplementation':
            'Decorator wraps towers with additional abilities like fire damage, freeze effect, or double shot',
        'whyUseful':
            'Allows combining multiple tower enhancements without creating numerous subclasses for each combination',
        'towerDefenseContext':
            'Tower enhancement system where players can add multiple upgrades like fire damage + freeze + double shot',
        'keyBenefits': [
          'Flexible combinations',
          'No class explosion',
          'Runtime configuration',
        ],
        'realWorldExample': 'Item enchantments in RPG games',
      },
    ),

    'facade': PatternExample(
      name: 'Facade',
      description: 'Provides simplified interface to complex subsystem',
      category: PatternCategory.structural,
      difficulty: 'Beginner',
      concepts: [
        'Simplified interface',
        'Subsystem coordination',
        'Complexity hiding',
        'API simplification',
      ],
      useCases: [
        'Game engine API',
        'Complex system integration',
        'Third-party libraries',
        'Service coordination',
      ],
      context: {
        'className': 'GameFacade',
        'patternType': 'Structural',
        'howImplementation':
            'Facade coordinates multiple subsystems (towers, enemies, UI, sound) through single simple interface',
        'whyUseful':
            'Simplifies complex game operations like "start wave" which involves enemy spawning, tower activation, UI updates',
        'towerDefenseContext':
            'Game controller that manages wave progression, tower behavior, enemy movement, and UI updates',
        'keyBenefits': ['Simplified API', 'Reduced coupling', 'Easy to use'],
        'realWorldExample': 'Game state management in mobile games',
      },
    ),

    // BEHAVIORAL PATTERNS
    'observer': PatternExample(
      name: 'Observer',
      description:
          'Defines subscription mechanism for notifying multiple objects',
      category: PatternCategory.behavioral,
      difficulty: 'Intermediate',
      concepts: [
        'Event notification',
        'Loose coupling',
        'Publisher-subscriber',
        'Dynamic relationships',
      ],
      useCases: [
        'Game events',
        'UI updates',
        'Achievement system',
        'Statistics tracking',
      ],
      context: {
        'className': 'GameEventManager',
        'patternType': 'Behavioral',
        'howImplementation':
            'Observer pattern notifies UI, sound system, and statistics when enemies are defeated or waves completed',
        'whyUseful':
            'Decouples game logic from UI updates, allowing multiple systems to react to events independently',
        'towerDefenseContext':
            'Event system that notifies score display, sound effects, achievements when towers destroy enemies',
        'keyBenefits': [
          'Loose coupling',
          'Dynamic subscriptions',
          'Event-driven architecture',
        ],
        'realWorldExample': 'Achievement systems in mobile games',
      },
    ),

    'strategy': PatternExample(
      name: 'Strategy',
      description:
          'Defines family of algorithms and makes them interchangeable',
      category: PatternCategory.behavioral,
      difficulty: 'Intermediate',
      concepts: [
        'Algorithm selection',
        'Runtime switching',
        'Polymorphism',
        'Encapsulation',
      ],
      useCases: [
        'AI behavior',
        'Tower targeting',
        'Enemy movement',
        'Difficulty levels',
      ],
      context: {
        'className': 'TowerTargetingStrategy',
        'patternType': 'Behavioral',
        'howImplementation':
            'Strategy pattern allows towers to switch between targeting algorithms (nearest, strongest, weakest)',
        'whyUseful':
            'Enables changing tower behavior dynamically based on player preference or game situation',
        'towerDefenseContext':
            'Tower targeting system with strategies: target nearest enemy, strongest enemy, or weakest enemy',
        'keyBenefits': [
          'Runtime algorithm switching',
          'Easy to extend',
          'Clean separation',
        ],
        'realWorldExample': 'AI difficulty settings in strategy games',
      },
    ),

    'command': PatternExample(
      name: 'Command',
      description:
          'Encapsulates requests as objects for queuing and undo operations',
      category: PatternCategory.behavioral,
      difficulty: 'Advanced',
      concepts: [
        'Request encapsulation',
        'Undo/Redo',
        'Queuing',
        'Macro commands',
      ],
      useCases: [
        'Tower placement',
        'Undo/Redo system',
        'Macro recording',
        'Action queuing',
      ],
      context: {
        'className': 'TowerCommand',
        'patternType': 'Behavioral',
        'howImplementation':
            'Command pattern encapsulates tower operations (place, upgrade, sell) as objects supporting undo/redo',
        'whyUseful':
            'Enables undo/redo functionality and allows queuing tower operations during game pause',
        'towerDefenseContext':
            'Tower management system with undo/redo support for placement, upgrades, and sales',
        'keyBenefits': [
          'Undo/Redo support',
          'Operation queuing',
          'Macro commands',
        ],
        'realWorldExample': 'Build queue systems in RTS games',
      },
    ),
  };

  /// Get all available pattern examples
  static Map<String, PatternExample> get allExamples =>
      Map.unmodifiable(_examples);

  /// Get example by pattern name
  static PatternExample? getExample(String patternName) {
    final example = _examples[patternName.toLowerCase()];
    if (example != null) {
      Log.debug('Retrieved example for pattern: $patternName');
    } else {
      Log.warning('No example found for pattern: $patternName');
    }
    return example;
  }

  /// Get examples by category
  static List<PatternExample> getExamplesByCategory(PatternCategory category) {
    final examples = _examples.values
        .where((example) => example.category == category)
        .toList();
    Log.debug(
      'Retrieved ${examples.length} examples for category: ${category.name}',
    );
    return examples;
  }

  /// Get examples by difficulty level
  static List<PatternExample> getExamplesByDifficulty(String difficulty) {
    final examples = _examples.values
        .where(
          (example) =>
              example.difficulty.toLowerCase() == difficulty.toLowerCase(),
        )
        .toList();
    Log.debug(
      'Retrieved ${examples.length} examples for difficulty: $difficulty',
    );
    return examples;
  }

  /// Check if example exists for pattern
  static bool hasExample(String patternName) {
    return _examples.containsKey(patternName.toLowerCase());
  }

  /// Get random example
  static PatternExample getRandomExample() {
    final examples = _examples.values.toList();
    final randomIndex = DateTime.now().millisecondsSinceEpoch % examples.length;
    final example = examples[randomIndex];
    Log.debug('Retrieved random example: ${example.name}');
    return example;
  }

  /// Search examples by keyword
  static List<PatternExample> searchExamples(String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    final examples = _examples.values
        .where(
          (example) =>
              example.name.toLowerCase().contains(lowerKeyword) ||
              example.description.toLowerCase().contains(lowerKeyword) ||
              example.concepts.any(
                (concept) => concept.toLowerCase().contains(lowerKeyword),
              ) ||
              example.useCases.any(
                (useCase) => useCase.toLowerCase().contains(lowerKeyword),
              ),
        )
        .toList();
    Log.debug('Found ${examples.length} examples matching keyword: $keyword');
    return examples;
  }
}

/// Easy-to-use Pattern Code Viewer Widget
class PatternCodeExample extends StatelessWidget {
  /// Pattern name to display
  final String patternName;

  /// Additional context override
  final Map<String, dynamic>? contextOverride;

  /// List of observers
  final List<CodeViewerObserver> observers;

  /// Initial language selection
  final CodeLanguage initialLanguage;

  /// Whether to show expanded initially
  final bool initiallyExpanded;

  /// Custom header widget
  final Widget? customHeader;

  /// Whether to show pattern information
  final bool showPatternInfo;

  const PatternCodeExample({
    super.key,
    required this.patternName,
    this.contextOverride,
    this.observers = const [],
    this.initialLanguage = CodeLanguage.dart,
    this.initiallyExpanded = false,
    this.customHeader,
    this.showPatternInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    final example = PatternExampleFactory.getExample(patternName);

    if (example == null) {
      return _buildNotFoundWidget(context);
    }

    final finalContext = <String, dynamic>{
      ...example.context,
      ...?contextOverride,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (customHeader != null) ...[
          customHeader!,
          const SizedBox(height: AppTheme.spacingM),
        ],

        if (showPatternInfo) ...[
          _buildPatternInfo(context, example),
          const SizedBox(height: AppTheme.spacingM),
        ],

        GlassCodeViewer(
          patternName: example.name,
          context: finalContext,
          observers: observers,
          initialLanguage: initialLanguage,
          initiallyExpanded: initiallyExpanded,
        ),
      ],
    );
  }

  Widget _buildNotFoundWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pattern Example Not Found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'No example available for pattern: $patternName',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternInfo(BuildContext context, PatternExample example) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: example.category.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: example.category.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: example.category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  example.category.icon,
                  color: example.category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${example.name} Pattern',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      example.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(
                    example.difficulty,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  example.difficulty,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getDifficultyColor(example.difficulty),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (example.concepts.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Key Concepts:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Wrap(
              spacing: AppTheme.spacingS,
              runSpacing: AppTheme.spacingS,
              children: example.concepts.map((concept) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    concept,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          if (example.useCases.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Common Use Cases:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: example.useCases.map((useCase) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Text(
                          useCase,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return AppTheme.primaryColor;
    }
  }
}

/// Pattern Code Browser - Browse all available examples
class PatternCodeBrowser extends StatefulWidget {
  /// Initial category filter
  final PatternCategory? initialCategory;

  /// Initial difficulty filter
  final String? initialDifficulty;

  /// Callback when pattern is selected
  final ValueChanged<PatternExample>? onPatternSelected;

  const PatternCodeBrowser({
    super.key,
    this.initialCategory,
    this.initialDifficulty,
    this.onPatternSelected,
  });

  @override
  State<PatternCodeBrowser> createState() => _PatternCodeBrowserState();
}

class _PatternCodeBrowserState extends State<PatternCodeBrowser> {
  PatternCategory? _selectedCategory;
  String? _selectedDifficulty;
  final String _searchQuery = '';

  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedDifficulty = widget.initialDifficulty;
  }

  List<PatternExample> get _filteredExamples {
    var examples = PatternExampleFactory.allExamples.values.toList();

    if (_selectedCategory != null) {
      examples = examples
          .where((e) => e.category == _selectedCategory)
          .toList();
    }

    if (_selectedDifficulty != null) {
      examples = examples
          .where((e) => e.difficulty == _selectedDifficulty)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      examples = PatternExampleFactory.searchExamples(_searchQuery);
    }

    return examples;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        const SizedBox(height: AppTheme.spacingM),
        _buildExampleGrid(),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        // Category filter
        Expanded(
          child: DropdownButtonFormField<PatternCategory?>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<PatternCategory?>(
                value: null,
                child: Text('All Categories'),
              ),
              ...PatternCategory.values.map((category) {
                return DropdownMenuItem<PatternCategory?>(
                  value: category,
                  child: Text(category.name),
                );
              }),
            ],
            onChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        // Difficulty filter
        Expanded(
          child: DropdownButtonFormField<String?>(
            value: _selectedDifficulty,
            decoration: const InputDecoration(
              labelText: 'Difficulty',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Difficulties'),
              ),
              ..._difficulties.map((difficulty) {
                return DropdownMenuItem<String?>(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }),
            ],
            onChanged: (difficulty) {
              setState(() {
                _selectedDifficulty = difficulty;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExampleGrid() {
    final examples = _filteredExamples;

    if (examples.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'No patterns found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
            ),
            Text(
              'Try adjusting your filters',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
        childAspectRatio: 1.2,
      ),
      itemCount: examples.length,
      itemBuilder: (context, index) {
        final example = examples[index];
        return _buildExampleCard(example);
      },
    );
  }

  Widget _buildExampleCard(PatternExample example) {
    return Container(
      decoration: BoxDecoration(
        color: example.category.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: example.category.color.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onPatternSelected?.call(example),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      example.category.icon,
                      color: example.category.color,
                      size: 20,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                          example.difficulty,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        example.difficulty,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getDifficultyColor(example.difficulty),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  example.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    example.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Row(
                  children: [
                    Icon(Icons.code, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '6 languages',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return AppTheme.primaryColor;
    }
  }
}
