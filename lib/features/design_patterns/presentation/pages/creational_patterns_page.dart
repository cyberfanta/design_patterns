/// Creational Patterns Page - MVC + Cubits Architecture
///
/// PATTERN: Model-View-Controller (MVC) with Cubits for state management
/// WHERE: Design Patterns feature - Creational category presentation
/// HOW: Displays creational patterns using TabBar navigation as specified
/// WHY: Demonstrates object creation patterns with interactive tab-based UI
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/components/mesh_gradient_background.dart';
import '../../../../core/presentation/themes/app_theme.dart';
import '../cubits/creational_patterns_cubit.dart';
import '../cubits/creational_patterns_state.dart';
import '../widgets/pattern_list_item.dart';

/// Creational patterns page using MVC architecture with Cubits.
///
/// Implements TabBar navigation as specified for creational patterns,
/// demonstrating object creation patterns in Tower Defense context.
class CreationalPatternsPage extends StatefulWidget {
  const CreationalPatternsPage({super.key});

  @override
  State<CreationalPatternsPage> createState() => _CreationalPatternsPageState();
}

class _CreationalPatternsPageState extends State<CreationalPatternsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // MVC Pattern: These represent the "Model" data
  final List<PatternTab> _tabs = [
    PatternTab(
      title: 'All Patterns',
      icon: Icons.list,
      patterns: _allCreationalPatterns,
    ),
    PatternTab(
      title: 'Object Creation',
      icon: Icons.construction,
      patterns: _objectCreationPatterns,
    ),
    PatternTab(
      title: 'Instance Management',
      icon: Icons.settings,
      patterns: _instanceManagementPatterns,
    ),
    PatternTab(
      title: 'Favorites',
      icon: Icons.favorite,
      patterns: [], // Will be populated by Cubit
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MVC Pattern: This method represents the "View"
    return BlocProvider(
      create: (context) => CreationalPatternsCubit()..loadPatterns(),
      child: PatternCategoryBackground(
        categoryType: PatternCategoryType.creational,
        child: Scaffold(
          body: Column(
            children: [
              // Custom app bar with glass effect (no SafeArea as specified)
              Container(
                padding: const EdgeInsets.only(
                  top: 60, // Manual status bar spacing
                  left: AppTheme.spacingL,
                  right: AppTheme.spacingL,
                  bottom: AppTheme.spacingM,
                ),
                child: _buildAppBar(context),
              ),

              // Tab bar with glass styling
              _buildTabBar(context),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) => _buildTabContent(tab)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// MVC Pattern: Controller method for building app bar
  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        // Back button
        GlassContainer.button(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),

        const SizedBox(width: AppTheme.spacingL),

        // Title section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Creational Patterns',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              Text(
                'Master object creation mechanisms',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),

        // Action buttons
        GlassContainer.button(
          onTap: () => _showFilterDialog(context),
          child: const Icon(Icons.filter_list, color: Colors.white),
        ),
      ],
    );
  }

  /// Build tab bar with glass styling
  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppTheme.spacingS),
        borderRadius: AppTheme.radiusL,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
            ),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: _tabs.map((tab) => _buildTab(tab)).toList(),
        ),
      ),
    );
  }

  /// Build individual tab
  Widget _buildTab(PatternTab tab) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tab.icon, size: 18),
          const SizedBox(width: AppTheme.spacingS),
          Text(tab.title),
        ],
      ),
    );
  }

  /// MVC Pattern: Controller method for building tab content
  Widget _buildTabContent(PatternTab tab) {
    return BlocBuilder<CreationalPatternsCubit, CreationalPatternsState>(
      builder: (context, state) {
        if (state is CreationalPatternsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CreationalPatternsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Error loading patterns',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  state.error,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        if (state is CreationalPatternsLoaded) {
          List<PatternInfo> patternsToShow;

          if (tab.title == 'Favorites') {
            patternsToShow = state.allPatterns.where((pattern) =>
                state.favoritePatterns.contains(pattern.name)
            ).toList();
          } else {
            patternsToShow = tab.patterns;
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            itemCount: patternsToShow.length,
            itemBuilder: (context, index) {
              final pattern = patternsToShow[index];
              return PatternListItem(
                pattern: pattern,
                onTap: () => _navigateToPattern(context, pattern),
                onFavoriteToggle: () => _toggleFavorite(context, pattern),
                isFavorite: state.favoritePatterns.contains(pattern.name),
              );
            },
          );
        }

        return const Center(child: Text('No patterns available'));
      },
    );
  }

  /// MVC Pattern: Controller method for navigation
  void _navigateToPattern(BuildContext context, PatternInfo pattern) {
    Navigator.of(context).pushNamed(
      '/patterns/detail',
      arguments: {'patternType': pattern.name, 'category': 'creational'},
    );
  }

  /// MVC Pattern: Controller method for favorite toggle
  void _toggleFavorite(BuildContext context, PatternInfo pattern) {
    context.read<CreationalPatternsCubit>().toggleFavorite(pattern.name);
  }

  /// Show filter dialog
  void _showFilterDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Patterns'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show Completed'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Show In Progress'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Show Not Started'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

/// Data model for tab configuration
class PatternTab {
  final String title;
  final IconData icon;
  final List<PatternInfo> patterns;

  PatternTab({required this.title, required this.icon, required this.patterns});
}

// MVC Pattern: Model data - using PatternInfo from state
final List<PatternInfo> _allCreationalPatterns = [
  ..._objectCreationPatterns,
  ..._instanceManagementPatterns,
];

final List<PatternInfo> _objectCreationPatterns = [
  PatternInfo(
    name: 'Factory Method',
    description: 'Create objects without specifying their concrete classes',
    difficulty: 'Beginner',
    category: 'Object Creation',
    keyBenefits: const [
      'Tower creation',
      'Enemy spawning',
      'Projectile generation',
    ],
    useCases: const [
      'Tower creation',
      'Enemy spawning',
      'Projectile generation',
    ],
    relatedPatterns: const ['Abstract Factory', 'Builder', 'Prototype'],
    towerDefenseExample:
        'Different tower types (Archer, Cannon, Magic) created through factory methods',
    complexity: 4.0,
    isPopular: true,
  ),
  PatternInfo(
    name: 'Abstract Factory',
    description: 'Create families of related objects',
    difficulty: 'Intermediate',
    category: 'Object Creation',
    keyBenefits: const [
      'Theme systems',
      'Platform-specific UI',
      'Game difficulty levels',
    ],
    useCases: const [
      'Theme systems',
      'Platform-specific UI',
      'Game difficulty levels',
    ],
    relatedPatterns: const ['Factory Method', 'Builder', 'Singleton'],
    towerDefenseExample:
        'Medieval, Futuristic, and Fantasy tower families with matching environments',
    complexity: 6.5,
  ),
  PatternInfo(
    name: 'Builder',
    description: 'Construct complex objects step by step',
    difficulty: 'Intermediate',
    category: 'Object Creation',
    keyBenefits: const [
      'Tower customization',
      'Level generation',
      'Player configuration',
    ],
    useCases: const [
      'Tower customization',
      'Level generation',
      'Player configuration',
    ],
    relatedPatterns: const ['Factory Method', 'Abstract Factory', 'Composite'],
    towerDefenseExample:
        'Building customized towers with different upgrades, weapons, and special abilities',
    complexity: 5.5,
    isPopular: true,
  ),
];

final List<PatternInfo> _instanceManagementPatterns = [
  PatternInfo(
    name: 'Singleton',
    description: 'Ensure a class has only one instance',
    difficulty: 'Beginner',
    category: 'Instance Management',
    keyBenefits: const ['Game manager', 'Audio controller', 'Settings manager'],
    useCases: const ['Game manager', 'Audio controller', 'Settings manager'],
    relatedPatterns: const ['Factory Method', 'Abstract Factory', 'Facade'],
    towerDefenseExample:
        'Game state manager controlling wave progression and global game rules',
    complexity: 3.0,
    isPopular: true,
  ),
  PatternInfo(
    name: 'Prototype',
    description: 'Create objects by cloning existing instances',
    difficulty: 'Intermediate',
    category: 'Instance Management',
    keyBenefits: const ['Enemy templates', 'Tower presets', 'Level copying'],
    useCases: const ['Enemy templates', 'Tower presets', 'Level copying'],
    relatedPatterns: const ['Factory Method', 'Builder', 'Flyweight'],
    towerDefenseExample:
        'Cloning enemy units with variations and pre-configured tower setups',
    complexity: 5.0,
  ),
];
