/// Pattern Category Card - Interactive Category Selection
///
/// PATTERN: Strategy Pattern - Different layouts per category type
/// WHERE: App feature presentation widgets
/// HOW: Displays category information with specialized styling per type
/// WHY: Provides intuitive navigation to different pattern categories
library;

import 'package:flutter/material.dart';

import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/components/mesh_gradient_background.dart';
import '../../../../core/presentation/themes/app_theme.dart';

/// Interactive card for pattern category selection with specialized styling.
///
/// Each category (Creational, Structural, Behavioral) has unique visual
/// treatment and navigation approach in the Tower Defense learning context.
class PatternCategoryCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final PatternCategoryType categoryType;
  final String designNote;
  final int patternCount;
  final VoidCallback onTap;

  const PatternCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.categoryType,
    required this.designNote,
    required this.patternCount,
    required this.onTap,
  });

  @override
  State<PatternCategoryCard> createState() => _PatternCategoryCardState();
}

class _PatternCategoryCardState extends State<PatternCategoryCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.1,
      end: 0.2,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  /// Get category-specific colors
  List<Color> get _categoryColors {
    switch (widget.categoryType) {
      case PatternCategoryType.creational:
        return [
          const Color(0xFF4CAF50), // Green
          const Color(0xFF81C784), // Light green
        ];
      case PatternCategoryType.structural:
        return [
          const Color(0xFF81C784), // Light green
          const Color(0xFFF5F5DC), // Cream
        ];
      case PatternCategoryType.behavioral:
        return [
          const Color(0xFF4CAF50), // Green
          const Color(0xFFF5F5DC), // Cream
        ];
    }
  }

  /// Get category-specific icon background
  Widget get _categoryIcon {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _categoryColors,
        ),
        boxShadow: [
          BoxShadow(
            color: _categoryColors[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(widget.icon, size: 32, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _opacityAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: GestureDetector(
              onTap: () {
                _rippleController.forward().then((_) {
                  _rippleController.reset();
                });
                widget.onTap();
              },
              onTapDown: (_) => _onHover(true),
              onTapUp: (_) => _onHover(false),
              onTapCancel: () => _onHover(false),
              child: GlassContainer(
                padding: const EdgeInsets.all(AppTheme.spacingXL),
                borderRadius: AppTheme.radiusXL,
                opacity: _opacityAnimation.value,
                blurIntensity: _isHovered ? 15.0 : 10.0,
                gradientColors: _isHovered ? _categoryColors : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with icon and pattern count
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _categoryIcon,

                        const Spacer(),

                        // Pattern count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingS,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusM,
                            ),
                            color: _categoryColors[0].withValues(alpha: 0.2),
                            border: Border.all(
                              color: _categoryColors[0].withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${widget.patternCount} patterns',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: _categoryColors[0],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // Title and subtitle
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),

                    const SizedBox(height: AppTheme.spacingS),

                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _categoryColors[0],
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingM),

                    // Description
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // Design approach note
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        border: Border.all(
                          color: _categoryColors[0].withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.architecture,
                            size: 16,
                            color: _categoryColors[0],
                          ),

                          const SizedBox(width: AppTheme.spacingS),

                          Expanded(
                            child: Text(
                              widget.designNote,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // Action button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingL,
                            vertical: AppTheme.spacingM,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusM,
                            ),
                            gradient: LinearGradient(colors: _categoryColors),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),

                              const SizedBox(width: AppTheme.spacingS),

                              const Icon(
                                Icons.arrow_forward,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
