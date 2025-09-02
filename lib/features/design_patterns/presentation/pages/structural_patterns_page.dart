/// Structural Patterns Page - MVP + Blocs Architecture
///
/// PATTERN: Model-View-Presenter (MVP) with Blocs for state management
/// WHERE: Design Patterns feature - Structural category presentation
/// HOW: Displays structural patterns using PageView navigation as specified
/// WHY: Demonstrates object composition patterns with swipe-based navigation
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/components/mesh_gradient_background.dart';
import '../../../../core/presentation/themes/app_theme.dart';
import '../blocs/structural_patterns_bloc.dart';
import '../widgets/pattern_detail_card.dart';

/// Structural patterns page using MVP architecture with Blocs.
///
/// Implements PageView navigation as specified for structural patterns,
/// demonstrating object composition patterns in Tower Defense context.
class StructuralPatternsPage extends StatefulWidget {
  const StructuralPatternsPage({super.key});

  @override
  State<StructuralPatternsPage> createState() => _StructuralPatternsPageState();
}

class _StructuralPatternsPageState extends State<StructuralPatternsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MVP Pattern: This is the View
    return BlocProvider(
      create: (context) =>
          StructuralPatternsBloc()..add(LoadStructuralPatterns()),
      child: PatternCategoryBackground(
        categoryType: PatternCategoryType.structural,
        child: Scaffold(
          body: Column(
            children: [
              // Header (no SafeArea as specified)
              Container(
                padding: const EdgeInsets.only(
                  top: 60, // Manual status bar spacing
                  left: AppTheme.spacingL,
                  right: AppTheme.spacingL,
                  bottom: AppTheme.spacingM,
                ),
                child: _StructuralPatternsPresenter(view: this).buildHeader(),
              ),

              // Page indicator
              BlocBuilder<StructuralPatternsBloc, StructuralPatternsState>(
                builder: (context, state) {
                  if (state is StructuralPatternsLoaded) {
                    return _buildPageIndicator(state.patterns.length);
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Main content with PageView
              Expanded(
                child:
                    BlocBuilder<
                      StructuralPatternsBloc,
                      StructuralPatternsState
                    >(
                      builder: (context, state) {
                        if (state is StructuralPatternsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is StructuralPatternsError) {
                          return _buildErrorView(state.message);
                        }

                        if (state is StructuralPatternsLoaded) {
                          return _buildPatternsPageView(state.patterns);
                        }

                        return const SizedBox.shrink();
                      },
                    ),
              ),

              // Navigation controls
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: _buildNavigationControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build patterns PageView
  Widget _buildPatternsPageView(List<StructuralPatternInfo> patterns) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final pattern = patterns[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
          child: PatternDetailCard(
            pattern: pattern,
            onExplore: () => _navigateToPattern(pattern),
            onAddToFavorites: () => _toggleFavorite(pattern),
          ),
        );
      },
    );
  }

  /// Build page indicator
  Widget _buildPageIndicator(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentPage == index
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(alpha: 0.3),
            ),
          );
        }),
      ),
    );
  }

  /// Build navigation controls
  Widget _buildNavigationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous button
        _currentPage > 0
            ? GlassContainer.button(
                onTap: () => _previousPage(),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),

        // Pattern counter
        GlassContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          child: BlocBuilder<StructuralPatternsBloc, StructuralPatternsState>(
            builder: (context, state) {
              if (state is StructuralPatternsLoaded) {
                return Text(
                  '${_currentPage + 1} of ${state.patterns.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
              return const Text('0 of 0');
            },
          ),
        ),

        // Next button
        _canGoNext()
            ? GlassContainer.button(
                onTap: () => _nextPage(),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
      ],
    );
  }

  /// Build error view
  Widget _buildErrorView(String message) {
    return Center(
      child: GlassContainer.panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),

            const SizedBox(height: AppTheme.spacingL),

            Text(
              'Error Loading Patterns',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),

            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppTheme.spacingL),

            GlassContainer.button(
              onTap: () {
                context.read<StructuralPatternsBloc>().add(
                  LoadStructuralPatterns(),
                );
              },
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to previous page
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to next page
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Check if can go to next page
  bool _canGoNext() {
    final state = context.read<StructuralPatternsBloc>().state;
    if (state is StructuralPatternsLoaded) {
      return _currentPage < state.patterns.length - 1;
    }
    return false;
  }

  /// Navigate to pattern detail
  void _navigateToPattern(StructuralPatternInfo pattern) {
    Navigator.of(context).pushNamed(
      '/patterns/detail',
      arguments: {'patternType': pattern.name, 'category': 'structural'},
    );
  }

  /// Toggle pattern favorite
  void _toggleFavorite(StructuralPatternInfo pattern) {
    context.read<StructuralPatternsBloc>().add(
      ToggleStructuralPatternFavorite(pattern),
    );
  }
}

/// MVP Pattern: Presenter class that handles business logic
class _StructuralPatternsPresenter {
  final _StructuralPatternsPageState view;

  _StructuralPatternsPresenter({required this.view});

  /// Build header section
  Widget buildHeader() {
    return Row(
      children: [
        // Back button
        GlassContainer.button(
          onTap: () => Navigator.of(view.context).pop(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),

        const SizedBox(width: AppTheme.spacingL),

        // Title section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Structural Patterns',
                style: Theme.of(view.context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              Text(
                'Master object composition and relationships',
                style: Theme.of(view.context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),

        // Menu button
        GlassContainer.button(
          onTap: () => _showOptionsMenu(view.context),
          child: const Icon(Icons.more_vert, color: Colors.white),
        ),
      ],
    );
  }

  /// Show options menu
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer.panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shuffle, color: Colors.white),
              title: const Text(
                'Shuffle Patterns',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Shuffle patterns logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark, color: Colors.white),
              title: const Text(
                'View Favorites',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Show favorites logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text(
                'Pattern Guide',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Show guide logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
