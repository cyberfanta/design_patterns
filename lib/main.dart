/// Design Patterns Flutter App - Tower Defense Learning Platform
/// 
/// PATTERN: Factory Pattern + Observer Pattern - App initialization and pattern demonstration
/// WHERE: Main app entry point with pattern demos
/// HOW: Demonstrates implemented patterns with Tower Defense context
/// WHY: Educational showcase of design patterns with practical examples
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_constants.dart';
import 'core/logging/logging.dart';
// Import pattern demonstrations
import 'core/patterns/behavioral/memento.dart';
import 'core/patterns/behavioral/observer.dart';
import 'core/patterns/creational/abstract_factory.dart';
import 'core/patterns/creational/builder.dart';
import 'core/patterns/creational/factory_method.dart';
import 'core/patterns/creational/prototype.dart';
import 'core/patterns/creational/singleton.dart';
import 'core/patterns/structural/adapter.dart';
// Import localization system
import 'features/localization/localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style - black status bar and navigation bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // PATTERN: Dependency Injection - Initialize localization system
  // Initialize localization system with Observer + Memento + Singleton patterns
  try {
    Log.debug('Initializing Design Patterns Tower Defense App...');
    await LocalizationInjection.init();
    Log.success('Localization system initialized successfully');
  } catch (e) {
    Log.error('Failed to initialize localization: $e');
    // Continue with app launch even if localization fails
  }

  runApp(const DesignPatternsApp());
}

class DesignPatternsApp extends StatelessWidget {
  const DesignPatternsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: LocalizationHelpers.isInitialized ? tr('app_name') : AppConstants
          .appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E8B57), // Sea green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PatternDemoPage(),
    );
  }
}

class PatternDemoPage extends StatefulWidget {
  const PatternDemoPage({super.key});

  @override
  State<PatternDemoPage> createState() => _PatternDemoPageState();
}

class _PatternDemoPageState extends State<PatternDemoPage>
    implements Observer<LanguageChangeEvent> {
  String _currentDemo = 'Welcome';

  @override
  void initState() {
    super.initState();
    // PATTERN: Observer - Listen for language changes
    if (LocalizationHelpers.isInitialized) {
      LocalizationInjection.translationService.addObserver(this);
    }
  }

  @override
  void dispose() {
    // PATTERN: Observer - Clean up observer registration
    if (LocalizationHelpers.isInitialized) {
      LocalizationInjection.translationService.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void update(LanguageChangeEvent event) {
    // PATTERN: Observer - React to language changes
    Log.debug('UI received language change notification: ${event.oldLanguage
        .code} -> ${event.newLanguage.code}');
    if (mounted) {
      setState(() {
        // Force UI rebuild with new language
      });
    }
  }

  final List<PatternDemo> _patterns = [
    PatternDemo(
      name: 'Factory Method',
      category: 'Creational',
      description: 'Creates enemies without specifying exact classes',
      demo: () => EnemyCreatorDemo.demonstratePattern(),
    ),
    PatternDemo(
      name: 'Abstract Factory',
      category: 'Creational',
      description: 'Creates families of related tower-projectile objects',
      demo: () => AbstractFactoryDemo.demonstratePattern(),
    ),
    PatternDemo(
      name: 'Builder',
      category: 'Creational',
      description: 'Constructs complex game maps step by step',
      demo: () => BuilderDemo.demonstratePattern(),
    ),
    PatternDemo(
      name: 'Prototype',
      category: 'Creational',
      description: 'Clones tower upgrade configurations',
      demo: () => PrototypeDemo.demonstratePattern(),
    ),
    PatternDemo(
      name: 'Singleton',
      category: 'Creational',
      description: 'Single GameManager instance for state management',
      demo: () => SingletonDemo.demonstratePattern(),
    ),
    PatternDemo(
      name: 'Adapter',
      category: 'Structural',
      description: 'Adapts legacy towers to modern interface',
      demo: () => AdapterPatternDemo.demonstratePattern(),
    ),
    PatternDemo(
      name: 'Observer',
      category: 'Behavioral',
      description: 'Game event notification system',
      demo: () => ObserverPatternDemo.demonstratePattern(),
    ),
    PatternDemo(
      name: 'Memento',
      category: 'Behavioral',
      description: 'Save/load game state and configurations',
      demo: () => MementoPatternDemo.demonstratePattern(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationHelpers.isInitialized
              ? tr('app_name')
              : 'Design Patterns - Tower Defense Edition',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E8B57).withValues(alpha: 0.8),
        elevation: 0,
        actions: [
          // PATTERN: Observer - Language selector updates UI automatically
          _buildLanguageSelector(),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2E8B57), // Sea green
              Color(0xFFF5F5DC), // Beige
              Color(0xFF90EE90), // Light green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Content
            Expanded(
              child: Row(
                children: [
                  // Pattern List Sidebar
                  Container(
                    width: 250,
                    margin: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: _patterns.length,
                      itemBuilder: (context, index) {
                        final pattern = _patterns[index];
                        final isSelected = _currentDemo == pattern.name;

                        return Card(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.1),
                          child: ListTile(
                            title: Text(
                              pattern.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              pattern.category,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap: () {
                              setState(() {
                                _currentDemo = pattern.name;
                              });
                              _runPatternDemo(pattern);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // Demo Content Area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _currentDemo == 'Welcome'
                          ? _buildWelcomeContent()
                          : _buildPatternContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build language selector dropdown
  /// 
  /// PATTERN: Observer - Changes automatically trigger UI updates
  Widget _buildLanguageSelector() {
    if (!LocalizationHelpers.isInitialized) {
      return const SizedBox.shrink();
    }

    final currentLanguage = LocalizationHelpers.currentLanguage;
    final supportedLanguages = LocalizationHelpers.supportedLanguages;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: DropdownButton<Language>(
        value: currentLanguage,
        icon: const Icon(Icons.language, color: Colors.white),
        dropdownColor: const Color(0xFF2E8B57),
        underline: Container(),
        items: supportedLanguages.map((Language language) {
          return DropdownMenuItem<Language>(
            value: language,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  language.flag,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  language.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (Language? newLanguage) async {
          if (newLanguage != null && newLanguage != currentLanguage) {
            Log.debug('User selected language: ${newLanguage.code}');

            // PATTERN: Observer - Language change will automatically trigger UI updates
            final success = await LocalizationHelpers.changeLanguage(
                newLanguage);

            if (success) {
              Log.success(
                  'Language changed successfully to ${newLanguage.code}');

              // Show confirmation snackbar
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('language_changed')),
                    backgroundColor: const Color(0xFF2E8B57),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } else {
              Log.error('Failed to change language to ${newLanguage.code}');
            }
          }
        },
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationHelpers.isInitialized
              ? tr('app_subtitle')
              : 'Welcome to Design Patterns Learning Platform',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          LocalizationHelpers.isInitialized
              ? trArgs('creational_desc', {}) // Using fallback for now
              : 'This app demonstrates design patterns using a Tower Defense game context. '
              'Each pattern is implemented with practical examples.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.87),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          LocalizationHelpers.isInitialized
              ? tr('help')
              : '← Select a pattern from the sidebar to see its implementation.',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        ),

        // PATTERN: Observer - Show language change status
        if (LocalizationHelpers.isInitialized) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.language, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${tr('language')}: ${LocalizationHelpers.currentLanguage
                      .name}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPatternContent() {
    final pattern = _patterns.firstWhere((p) => p.name == _currentDemo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pattern.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Category: ${pattern.category}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          pattern.description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.87),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => _runPatternDemo(pattern),
          child: const Text('Run Demo'),
        ),
        const SizedBox(height: 16),
        const Expanded(
          child: SingleChildScrollView(
            child: Text(
              'Check the console output to see the pattern demonstration.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _runPatternDemo(PatternDemo pattern) {
    Log.debug('\n${'=' * 50}');
    Log.debug('Running ${pattern.name} Demo');
    Log.debug('=' * 50);

    try {
      pattern.demo();
    } catch (e) {
      Log.debug('Error: $e');
    }

    Log.debug('=' * 50 + '\n');
  }
}

class PatternDemo {
  final String name;
  final String category;
  final String description;
  final VoidCallback demo;

  PatternDemo({
    required this.name,
    required this.category,
    required this.description,
    required this.demo,
  });
}

// Demo classes
class EnemyCreatorDemo {
  static void demonstratePattern() {
    Log.debug('Creating enemies with Factory Method...\n');

    final antFactory = AntFactory();
    final grasshopperFactory = GrasshopperFactory();
    final cockroachFactory = CockroachFactory();

    final ant = antFactory.createEnemy();
    final grasshopper = grasshopperFactory.createEnemy();
    final cockroach = cockroachFactory.createEnemy();

    Log.debug('Created enemies:');
    Log.debug('- ${ant.name}: HP=${ant.health}, Speed=${ant.speed}');
    Log.debug(
        '- ${grasshopper.name}: HP=${grasshopper.health}, Speed=${grasshopper
            .speed}');
    Log.debug('- ${cockroach.name}: HP=${cockroach.health}, Speed=${cockroach
        .speed}');
  }
}

class AbstractFactoryDemo {
  static void demonstratePattern() {
    Log.debug('Creating tower families with Abstract Factory...\n');

    final archerSetup = TowerFactoryManager.createTowerSetup('archer');
    final stoneSetup = TowerFactoryManager.createTowerSetup('stone_thrower');

    if (archerSetup != null) {
      Log.debug(
          'Archer Setup: ${archerSetup.tower.name} + ${archerSetup.projectile
              .name}');
    }

    if (stoneSetup != null) {
      Log.debug('Stone Setup: ${stoneSetup.tower.name} + ${stoneSetup.projectile
          .name}');
    }
  }
}

class BuilderDemo {
  static void demonstratePattern() {
    Log.debug('Building maps with Builder Pattern...\n');

    final basicMap = MapFactory.createBasicMap();
    final advancedMap = MapFactory.createAdvancedMap();

    Log.debug('Basic Map: ${basicMap.width}x${basicMap.height}, ${basicMap
        .difficulty}');
    Log.debug(
        'Advanced Map: ${advancedMap.width}x${advancedMap.height}, ${advancedMap
            .difficulty}');
  }
}

class PrototypeDemo {
  static void demonstratePattern() {
    Log.debug('Cloning configurations with Prototype Pattern...\n');

    final archerTree = EvolutionTreeFactory.createArcherEvolutionTree();
    Log.debug('Archer Tree: ${archerTree.name} with ${archerTree.children
        .length} upgrades');

    final clonedUpgrade = archerTree.children.first.upgrade.cloneWith(
      name: 'Super Sharp Arrows',
      damageIncrease: 0.5,
    );

    Log.debug('Cloned upgrade: ${clonedUpgrade.name}');
  }
}

class SingletonDemo {
  static void demonstratePattern() {
    Log.debug('Testing Singleton with GameManager...\n');

    final manager1 = GameManager();
    final manager2 = GameManager.instance;

    Log.debug('Same instance: ${identical(manager1, manager2)}');

    manager1.startGame();
    Log.debug('Game state: ${manager2.currentState}');
  }
}