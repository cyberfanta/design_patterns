/// Home Page - Main Navigation Hub
///
/// PATTERN: Facade Pattern - Simplifies access to pattern categories
/// WHERE: App feature presentation layer
/// HOW: Provides navigation to pattern categories and user features
/// WHY: Creates intuitive entry point to the learning experience
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/presentation/components/mesh_gradient_background.dart';
import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/themes/app_theme.dart';
import '../../../../core/presentation/routing/app_router.dart';
import '../widgets/app_drawer.dart';
import '../widgets/pattern_category_card.dart';
import '../widgets/welcome_section.dart';

/// Main home page displaying pattern categories and navigation options.
///
/// Represents the Tower Defense command center where players select
/// different pattern categories to learn, each with unique gameplay
/// mechanics and visual presentation styles.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: MeshGradientBackground(
        child: Column(
          children: [
            // Welcome section (no SafeArea as specified)
            Container(
              padding: const EdgeInsets.only(
                top: 60, // Manual status bar spacing
                left: AppTheme.spacingL,
                right: AppTheme.spacingL,
                bottom: AppTheme.spacingL,
              ),
              child: const WelcomeSection(),
            ),

            // Main content with PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // Main categories page
                  _buildCategoriesPage(),

                  // Additional info page
                  _buildInfoPage(),
                ],
              ),
            ),

            // Page indicator
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPageIndicator(0),
                  const SizedBox(width: AppTheme.spacingS),
                  _buildPageIndicator(1),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GlassFloatingActionButton(
        onPressed: () => _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        child: Icon(
          _currentPage == 0 ? Icons.arrow_forward : Icons.arrow_back,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// Builds the main pattern categories page
  Widget _buildCategoriesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              'Pattern Categories',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: AppTheme.spacingS),

            Text(
              'Each category offers unique gameplay mechanics and learning approaches',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Pattern category cards
            AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 600),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    PatternCategoryCard(
                      title: 'Creational Patterns',
                      subtitle: 'Object Creation Mastery',
                      description:
                          'Learn how objects come to life in the Tower Defense battlefield',
                      icon: Icons.construction,
                      categoryType: PatternCategoryType.creational,
                      designNote: 'Tabs Navigation • MVC + Cubits',
                      patternCount: 5,
                      onTap: () => context.toCreationalPatterns(),
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    PatternCategoryCard(
                      title: 'Structural Patterns',
                      subtitle: 'Architecture & Composition',
                      description:
                          'Master the art of building robust tower defense systems',
                      icon: Icons.architecture,
                      categoryType: PatternCategoryType.structural,
                      designNote: 'PageView Navigation • MVP + Blocs',
                      patternCount: 7,
                      onTap: () => context.toStructuralPatterns(),
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    PatternCategoryCard(
                      title: 'Behavioral Patterns',
                      subtitle: 'Communication & Interaction',
                      description:
                          'Control tower behaviors and enemy interactions',
                      icon: Icons.psychology,
                      categoryType: PatternCategoryType.behavioral,
                      designNote: 'Grid Layout • MVVM-C + GetX',
                      patternCount: 11,
                      onTap: () => context.toBehavioralPatterns(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the additional information page
  Widget _buildInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Learning Experience',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Features list
          ...AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 400),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              _buildFeatureCard(
                icon: Icons.code,
                title: 'Multi-Language Code Examples',
                description:
                    'View patterns implemented in Flutter, TypeScript, Kotlin, Swift, Java, and C#',
              ),

              const SizedBox(height: AppTheme.spacingL),

              _buildFeatureCard(
                icon: Icons.account_tree,
                title: 'Interactive Diagrams',
                description:
                    'Explore UML diagrams and visual representations of each pattern',
              ),

              const SizedBox(height: AppTheme.spacingL),

              _buildFeatureCard(
                icon: Icons.games,
                title: 'Tower Defense Context',
                description:
                    'Learn through practical examples in a tower defense game scenario',
              ),

              const SizedBox(height: AppTheme.spacingL),

              _buildFeatureCard(
                icon: Icons.architecture,
                title: 'Clean Architecture',
                description:
                    'Built with MVVM, Clean Architecture, and modern development practices',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a feature description card
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return GlassContainer.card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),

          const SizedBox(width: AppTheme.spacingL),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingS),

                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds page indicator dot
  Widget _buildPageIndicator(int page) {
    final isActive = _currentPage == page;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isActive ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
