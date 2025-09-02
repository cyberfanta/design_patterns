/// Pattern List Item - Individual Pattern Display Component
///
/// PATTERN: Template Method Pattern - Defines pattern item display structure
/// WHERE: Design Patterns feature presentation widgets
/// HOW: Displays pattern information with interactive elements in a glass container
/// WHY: Provides consistent pattern item presentation across different categories
library;

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/themes/app_theme.dart';
import '../pages/creational_patterns_page.dart';

/// Interactive list item for displaying pattern information.
///
/// Shows pattern details in the Tower Defense learning context with
/// glassmorphism styling and smooth animations.
class PatternListItem extends StatefulWidget {
  final PatternInfo pattern;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;
  final int? index; // For staggered animations

  const PatternListItem({
    super.key,
    required this.pattern,
    required this.onTap,
    required this.onFavoriteToggle,
    this.isFavorite = false,
    this.index,
  });

  @override
  State<PatternListItem> createState() => _PatternListItemState();
}

class _PatternListItemState extends State<PatternListItem>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _favoriteController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _favoriteScaleAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));

    _favoriteScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _favoriteController, curve: Curves.elasticOut),
    );

    // Set initial favorite state
    if (widget.isFavorite) {
      _favoriteController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PatternListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate favorite changes
    if (widget.isFavorite != oldWidget.isFavorite) {
      if (widget.isFavorite) {
        _favoriteController.forward();
      } else {
        _favoriteController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  /// Get difficulty color
  Color get _difficultyColor {
    switch (widget.pattern.difficulty) {
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

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _favoriteScaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: GlassContainer.card(
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pattern icon
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
                        child: Icon(
                          widget.pattern.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: AppTheme.spacingL),

                      // Pattern info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pattern name
                            Text(
                              widget.pattern.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),

                            const SizedBox(height: AppTheme.spacingXS),

                            // Difficulty badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingS,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusS,
                                ),
                                color: _difficultyColor.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: _difficultyColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.pattern.difficulty,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: _difficultyColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Favorite button
                      Transform.scale(
                        scale: _favoriteScaleAnimation.value,
                        child: GlassContainer(
                          width: 40,
                          height: 40,
                          padding: EdgeInsets.zero,
                          borderRadius: 20,
                          onTap: widget.onFavoriteToggle,
                          child: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.isFavorite
                                ? Colors.red
                                : Colors.white.withValues(alpha: 0.7),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  // Pattern description
                  Text(
                    widget.pattern.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  // Tower Defense context
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
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
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),

                            const SizedBox(width: AppTheme.spacingS),

                            Text(
                              'Tower Defense Context',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spacingS),

                        Text(
                          widget.pattern.towerDefenseContext,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                height: 1.3,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  // Use cases chips
                  Wrap(
                    spacing: AppTheme.spacingS,
                    runSpacing: AppTheme.spacingS,
                    children: widget.pattern.useCases.map((useCase) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Add staggered animation if index is provided
    if (widget.index != null) {
      content = AnimationConfiguration.staggeredList(
        position: widget.index!,
        duration: const Duration(milliseconds: 600),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(child: content),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
      child: content,
    );
  }

  /// Handle hover state changes
  void _onHover(bool isHovered) {
    if (_isHovered != isHovered) {
      setState(() {
        _isHovered = isHovered;
      });

      if (isHovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }
}

/// Compact version for use in grids or smaller spaces
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
    return GlassContainer.card(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and favorite
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: Icon(pattern.icon, color: Colors.white, size: 16),
              ),

              const Spacer(),

              Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite
                    ? Colors.red
                    : Colors.white.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Pattern name
          Text(
            pattern.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppTheme.spacingS),

          // Difficulty
          Text(
            pattern.difficulty,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
