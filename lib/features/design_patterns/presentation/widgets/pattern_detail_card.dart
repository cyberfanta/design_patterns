/// Pattern Detail Card - Detailed Pattern Information Display
///
/// PATTERN: Composite Pattern - Combines multiple UI elements into detailed card
/// WHERE: Design Patterns feature presentation widgets
/// HOW: Displays comprehensive pattern information with interactive elements
/// WHY: Provides detailed pattern exploration for PageView-based structural patterns
library;

import 'package:flutter/material.dart';

import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/themes/app_theme.dart';
import '../blocs/structural_patterns_bloc.dart';

/// Detailed card for pattern information display in PageView.
///
/// Used primarily for structural patterns page with MVP + Blocs architecture,
/// providing comprehensive pattern details in Tower Defense context.
class PatternDetailCard extends StatelessWidget {
  final StructuralPatternInfo pattern;
  final VoidCallback onExplore;
  final VoidCallback onAddToFavorites;

  const PatternDetailCard({
    super.key,
    required this.pattern,
    required this.onExplore,
    required this.onAddToFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer.panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeader(context),

          const SizedBox(height: AppTheme.spacingXL),

          // Description section
          _buildDescription(context),

          const SizedBox(height: AppTheme.spacingXL),

          // Tower Defense context
          _buildTowerDefenseContext(context),

          const SizedBox(height: AppTheme.spacingXL),

          // Use cases
          _buildUseCases(context),

          const SizedBox(height: AppTheme.spacingXL),

          // Composition type (unique to structural patterns)
          _buildCompositionType(context),

          const SizedBox(height: AppTheme.spacingXL),

          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// Build header with icon, name, and difficulty
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Pattern icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(pattern.icon, size: 40, color: Colors.white),
        ),

        const SizedBox(width: AppTheme.spacingXL),

        // Pattern info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pattern.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppTheme.spacingS),

              // Difficulty badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  color: _getDifficultyColor().withValues(alpha: 0.2),
                  border: Border.all(
                    color: _getDifficultyColor().withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  pattern.difficulty,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _getDifficultyColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build description section
  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(height: AppTheme.spacingM),

        Text(
          pattern.description,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.5),
        ),
      ],
    );
  }

  /// Build Tower Defense context section
  Widget _buildTowerDefenseContext(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.castle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),

              const SizedBox(width: AppTheme.spacingM),

              Text(
                'Tower Defense Context',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            pattern.towerDefenseContext,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Build use cases section
  Widget _buildUseCases(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Common Use Cases',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(height: AppTheme.spacingM),

        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: pattern.useCases.map((useCase) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                useCase,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build composition type section (unique to structural patterns)
  Widget _buildCompositionType(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.architecture,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),

          const SizedBox(width: AppTheme.spacingM),

          Text(
            'Composition Type: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),

          Text(
            pattern.compositionType,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassContainer.button(
            onTap: onExplore,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.explore, color: Colors.white, size: 20),

                  const SizedBox(width: AppTheme.spacingS),

                  Text(
                    'Explore Pattern',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: AppTheme.spacingM),

        GlassContainer.button(
          onTap: onAddToFavorites,
          child: SizedBox(
            width: 48,
            height: 48,
            child: const Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// Get difficulty color based on pattern difficulty
  Color _getDifficultyColor() {
    switch (pattern.difficulty) {
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
