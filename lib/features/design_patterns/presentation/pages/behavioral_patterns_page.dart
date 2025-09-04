/// Behavioral Patterns Page - MVVM-C + GetX Architecture
///
/// PATTERN: Model-View-ViewModel-Coordinator (MVVM-C) with GetX for state management
/// WHERE: Design Patterns feature - Behavioral category presentation
/// HOW: Displays behavioral patterns using Interactive Dashboard as alternative design
/// WHY: Demonstrates communication patterns with innovative, multi-modal UI
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/components/glass_floating_action_button.dart' as gfab;
import '../../../../core/presentation/components/mesh_gradient_background.dart';
import '../../../../core/presentation/themes/app_theme.dart';
import '../controllers/behavioral_patterns_controller.dart';
import '../cubits/creational_patterns_state.dart' show PatternInfo;
import '../models/behavioral_pattern_info.dart';
import '../widgets/behavioral_constellation_view.dart';
import '../widgets/behavioral_dashboard_card.dart';

/// Behavioral patterns page using MVVM-C architecture with GetX.
///
/// Implements Interactive Dashboard with multiple visualization modes:
/// - Dashboard View: Interactive cards with animations and detailed information
/// - Constellation View: Space-themed pattern exploration
/// - List View: Traditional linear pattern display
class BehavioralPatternsPage extends StatelessWidget {
  const BehavioralPatternsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // MVVM-C Pattern: Initialize controller
    final controller = Get.put(BehavioralPatternsController());

    return PatternCategoryBackground(
      categoryType: PatternCategoryType.behavioral,
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
              child: _buildHeader(context, controller),
            ),

            // Filters and search
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
              ),
              child: _buildFilters(context, controller),
            ),

            // Main content - Dynamic view based on selected mode
            Expanded(child: Obx(() => _buildContent(context, controller))),
          ],
        ),

        // Multi-function floating action button
        floatingActionButton: Obx(
              () => _buildFloatingActionButton(controller),
        ),
      ),
    );
  }

  /// MVVM-C Pattern: View method for building header
  Widget _buildHeader(
    BuildContext context,
    BehavioralPatternsController controller,
  ) {
    return Row(
      children: [
        // Back button
        GlassContainer.button(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),

        const SizedBox(width: AppTheme.spacingL),

        // Title section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Behavioral Patterns',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              Obx(
                () => Text(
                  'Communication masters • ${controller.filteredPatterns.length} patterns',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),

        // View mode selector
        Obx(
              () =>
              Row(
                children: [
                  _buildViewModeButton(
                    icon: Icons.dashboard_customize,
                    isSelected: controller.viewMode.value == ViewMode.dashboard,
                    onTap: () => controller.setViewMode(ViewMode.dashboard),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  _buildViewModeButton(
                    icon: Icons.stars,
                    isSelected: controller.viewMode.value ==
                        ViewMode.constellation,
                    onTap: () => controller.setViewMode(ViewMode.constellation),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  _buildViewModeButton(
                    icon: Icons.list,
                    isSelected: controller.viewMode.value == ViewMode.list,
                    onTap: () => controller.setViewMode(ViewMode.list),
                  ),
                ],
              ),
        ),
      ],
    );
  }

  Widget _buildViewModeButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GlassContainer.button(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: isSelected
            ? BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
          color: Colors.white.withValues(alpha: 0.2),
        )
            : null,
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withValues(
              alpha: 0.6),
          size: 20,
        ),
      ),
    );
  }

  /// Build filters section
  Widget _buildFilters(
    BuildContext context,
    BehavioralPatternsController controller,
  ) {
    return Obx(() {
      // Hide filters in constellation view for immersion
      if (controller.viewMode.value == ViewMode.constellation) {
        return const SizedBox.shrink();
      }

      return GlassContainer(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            // Search bar
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search behavioral patterns...',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: BorderSide(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
              ),
              onChanged: controller.searchPatterns,
            ),

            const SizedBox(height: AppTheme.spacingM),

            // Difficulty filters
            Row(
              children: [
                Text(
                  'Difficulty:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Beginner', 'Intermediate', 'Advanced']
                          .map((difficulty) =>
                          Padding(
                            padding: const EdgeInsets.only(
                                right: AppTheme.spacingS),
                            child: _buildDifficultyChip(
                              context,
                              controller,
                              difficulty,
                              controller.selectedDifficulty.value == difficulty,
                            ),
                          ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDifficultyChip(
    BuildContext context,
    BehavioralPatternsController controller,
    String difficulty,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => controller.filterByDifficulty(difficulty),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          difficulty,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// MVVM-C Pattern: View method for building main content
  Widget _buildContent(
    BuildContext context,
    BehavioralPatternsController controller,
  ) {
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (controller.hasError.value) {
      return _buildErrorView(context, controller);
    }

    final patterns = controller.filteredPatterns;

    if (patterns.isEmpty) {
      return _buildEmptyView(context, controller);
    }

    // Route to different view modes
    switch (controller.viewMode.value) {
      case ViewMode.dashboard:
        return _buildDashboardView(context, controller, patterns);
      case ViewMode.constellation:
        return BehavioralConstellationView(controller: controller);
      case ViewMode.list:
        return _buildListView(context, controller, patterns);
    }
  }

  /// Build innovative dashboard view with interactive cards
  Widget _buildDashboardView(
    BuildContext context,
    BehavioralPatternsController controller,
    List<BehavioralPatternInfo> patterns,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 0.75,
        ),
        itemCount: patterns.length,
        itemBuilder: (context, index) {
          final pattern = patterns[index];
          return BehavioralDashboardCard(
            pattern: pattern,
            index: index,
            controller: controller,
            onTap: () => controller.navigateToPattern(pattern),
            onFavoriteToggle: () => controller.toggleFavorite(pattern),
            isFavorite: controller.favoritePatterns.contains(pattern),
          );
        },
      ),
    );
  }

  /// Build traditional list view
  Widget _buildListView(
    BuildContext context,
    BehavioralPatternsController controller,
    List<BehavioralPatternInfo> patterns,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: ListView.builder(
        itemCount: patterns.length,
        itemBuilder: (context, index) {
          final pattern = patterns[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: PatternListItemCompact(
              pattern: PatternInfo(
                name: pattern.name,
                description: pattern.description,
                difficulty: pattern.difficulty,
                category: pattern.category,
                keyBenefits: pattern.keyBenefits,
                useCases: pattern.useCases,
                relatedPatterns: pattern.relatedPatterns,
                towerDefenseExample: pattern.towerDefenseExample,
                complexity: pattern.complexity,
                isPopular: pattern.isPopular,
                icon: pattern.icon,
                towerDefenseContext: pattern.towerDefenseContext,
              ),
              onTap: () => controller.navigateToPattern(pattern),
              isFavorite: controller.favoritePatterns.contains(pattern),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    BehavioralPatternsController controller,
  ) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withValues(alpha: 0.8),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Oops! Something went wrong',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Failed to load behavioral patterns. Please try again.',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton(
              onPressed: controller.loadPatterns,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context,
      BehavioralPatternsController controller,) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'No patterns found',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Try adjusting your search or filter criteria.',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton(
              onPressed: controller.clearFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build multi-function floating action button
  Widget _buildFloatingActionButton(BehavioralPatternsController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Filter status indicator
        if (controller.isFilterActive.value)
          gfab.GlassFloatingActionButton(
            mini: true,
            onPressed: controller.clearFilters,
            child: const Icon(Icons.clear, color: Colors.white, size: 20),
          ),

        if (controller.isFilterActive.value)
          const SizedBox(height: AppTheme.spacingS),

        // Main action based on view mode
        GlassFloatingActionButton(
          onPressed: () {
            switch (controller.viewMode.value) {
              case ViewMode.dashboard:
                controller.showFilterDialog();
                break;
              case ViewMode.constellation:
              // Toggle constellation info overlay
                break;
              case ViewMode.list:
                controller.showFilterDialog();
                break;
            }
          },
          child: Obx(() {
            switch (controller.viewMode.value) {
              case ViewMode.dashboard:
                return const Icon(Icons.filter_list, color: Colors.white);
              case ViewMode.constellation:
                return const Icon(Icons.info_outline, color: Colors.white);
              case ViewMode.list:
                return const Icon(Icons.filter_list, color: Colors.white);
            }
          }),
        ),
      ],
    );
  }
}


/// Compact pattern list item for list view
class PatternListItemCompact extends StatelessWidget {
  final PatternInfo pattern;
  final VoidCallback onTap;
  final bool isFavorite;

  const PatternListItemCompact({
    super.key,
    required this.pattern,
    required this.onTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          children: [
            // Pattern icon
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(
                pattern.icon ?? Icons.psychology,
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                size: 24,
              ),
            ),

            const SizedBox(width: AppTheme.spacingL),

            // Pattern info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pattern.name,
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pattern.description,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Text(
                          pattern.difficulty,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Text(
                          pattern.complexity.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppTheme.spacingM),

            // Favorite and arrow
            Column(
              children: [
                Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white60,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}