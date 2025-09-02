/// Behavioral Patterns Page - MVVM-C + GetX Architecture
///
/// PATTERN: Model-View-ViewModel-Coordinator (MVVM-C) with GetX for state management
/// WHERE: Design Patterns feature - Behavioral category presentation
/// HOW: Displays behavioral patterns using Grid Layout as alternative design
/// WHY: Demonstrates communication patterns with interactive grid-based UI
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/presentation/components/mesh_gradient_background.dart';
import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/themes/app_theme.dart';
import '../widgets/pattern_list_item.dart';
import '../controllers/behavioral_patterns_controller.dart';
import 'creational_patterns_page.dart'; // Para usar PatternInfo

/// Behavioral patterns page using MVVM-C architecture with GetX.
///
/// Implements Grid Layout as the alternative design (not tabs, not PageView)
/// for behavioral patterns, demonstrating communication patterns in Tower Defense.
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

            // Main content - Grid Layout (alternative design)
            Expanded(child: Obx(() => _buildContent(context, controller))),
          ],
        ),

        // Floating filter button
        floatingActionButton: Obx(
          () => controller.isFilterActive.value
              ? GlassFloatingActionButton(
                  onPressed: () => controller.clearFilters(),
                  child: const Icon(Icons.clear, color: Colors.white),
                )
              : GlassFloatingActionButton(
                  onPressed: () => controller.showFilterDialog(),
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
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

        // View toggle
        Obx(
          () => GlassContainer.button(
            onTap: () => controller.toggleViewMode(),
            child: Icon(
              controller.isGridView.value ? Icons.list : Icons.grid_view,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Build filters section
  Widget _buildFilters(
    BuildContext context,
    BehavioralPatternsController controller,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          // Search bar
          GlassContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            child: TextField(
              onChanged: (value) => controller.searchPatterns(value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search patterns...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Difficulty filter chips
          Obx(
            () => Wrap(
              spacing: AppTheme.spacingS,
              children: ['All', 'Beginner', 'Intermediate', 'Advanced']
                  .map(
                    (difficulty) => _buildFilterChip(
                      context,
                      controller,
                      difficulty,
                      controller.selectedDifficulty.value == difficulty,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(
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
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError.value) {
      return _buildErrorView(context, controller);
    }

    final patterns = controller.filteredPatterns;

    if (patterns.isEmpty) {
      return _buildEmptyView(context, controller);
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: controller.isGridView.value
          ? _buildGridView(context, controller, patterns)
          : _buildListView(context, controller, patterns),
    );
  }

  /// Build grid view (alternative design for behavioral patterns)
  Widget _buildGridView(
    BuildContext context,
    BehavioralPatternsController controller,
    List<BehavioralPatternInfo> patterns,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
        childAspectRatio: 0.8,
      ),
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final pattern = patterns[index];
        return _buildGridPatternCard(context, controller, pattern);
      },
    );
  }

  /// Build list view
  Widget _buildListView(
    BuildContext context,
    BehavioralPatternsController controller,
    List<BehavioralPatternInfo> patterns,
  ) {
    return ListView.builder(
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final pattern = patterns[index];
        return PatternListItemCompact(
          pattern: PatternInfo(
            name: pattern.name,
            description: pattern.description,
            icon: pattern.icon,
            difficulty: pattern.difficulty,
            useCases: pattern.useCases,
            towerDefenseContext: pattern.towerDefenseContext,
          ),
          onTap: () => controller.navigateToPattern(pattern),
          isFavorite: controller.favoritePatterns.contains(pattern),
        );
      },
    );
  }

  /// Build grid pattern card
  Widget _buildGridPatternCard(
    BuildContext context,
    BehavioralPatternsController controller,
    BehavioralPatternInfo pattern,
  ) {
    return GlassContainer.card(
      onTap: () => controller.navigateToPattern(pattern),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and favorite
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: Icon(pattern.icon, color: Colors.white, size: 20),
              ),

              const Spacer(),

              GestureDetector(
                onTap: () => controller.toggleFavorite(pattern),
                child: Icon(
                  controller.favoritePatterns.contains(pattern)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: controller.favoritePatterns.contains(pattern)
                      ? Colors.red
                      : Colors.white.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Pattern name
          Text(
            pattern.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppTheme.spacingS),

          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              color: _getDifficultyColor(
                pattern.difficulty,
              ).withValues(alpha: 0.2),
              border: Border.all(
                color: _getDifficultyColor(
                  pattern.difficulty,
                ).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              pattern.difficulty,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getDifficultyColor(pattern.difficulty),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Description
          Expanded(
            child: Text(
              pattern.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Communication type
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Text(
              pattern.communicationType,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(
    BuildContext context,
    BehavioralPatternsController controller,
  ) {
    return Center(
      child: GlassContainer.panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),

            const SizedBox(height: AppTheme.spacingL),

            Text(
              'Error Loading Patterns',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),

            const SizedBox(height: AppTheme.spacingL),

            GlassContainer.button(
              onTap: () => controller.loadPatterns(),
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

  /// Build empty view
  Widget _buildEmptyView(
    BuildContext context,
    BehavioralPatternsController controller,
  ) {
    return Center(
      child: GlassContainer.panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withValues(alpha: 0.5),
            ),

            const SizedBox(height: AppTheme.spacingL),

            Text(
              'No Patterns Found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),

            const SizedBox(height: AppTheme.spacingM),

            Text(
              'Try adjusting your filters or search terms',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppTheme.spacingL),

            GlassContainer.button(
              onTap: () => controller.clearFilters(),
              child: const Text(
                'Clear Filters',
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

  /// Get difficulty color
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Data model for behavioral pattern information
class BehavioralPatternInfo {
  final String name;
  final String description;
  final IconData icon;
  final String difficulty;
  final List<String> useCases;
  final String towerDefenseContext;
  final String communicationType; // Unique to behavioral patterns

  const BehavioralPatternInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.difficulty,
    required this.useCases,
    required this.towerDefenseContext,
    required this.communicationType,
  });
}
