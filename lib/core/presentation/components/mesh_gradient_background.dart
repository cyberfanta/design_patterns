/// Mesh Gradient Background Component
///
/// PATTERN: Decorator Pattern - Provides consistent background styling
/// WHERE: Core presentation components for app-wide background effects
/// HOW: Creates animated mesh gradient backgrounds using mesh_gradient package
/// WHY: Maintains consistent visual identity with green/cream color scheme
library;

import 'package:flutter/material.dart';

// Mesh gradient implemented with custom linear gradients
import '../themes/app_theme.dart';

/// Animated mesh gradient background component following design specifications.
///
/// Provides the signature green/cream mesh gradient background for the
/// Tower Defense learning app, creating an engaging backdrop that represents
/// the battlefield environment while maintaining readability.
class MeshGradientBackground extends StatefulWidget {
  /// Child widget to overlay on the gradient background
  final Widget child;

  /// Enable animation for the gradient
  final bool animated;

  /// Animation duration for color transitions
  final Duration animationDuration;

  /// Custom colors override (defaults to theme colors)
  final List<Color>? customColors;

  /// Gradient intensity (0.0-1.0)
  final double intensity;

  const MeshGradientBackground({
    super.key,
    required this.child,
    this.animated = true,
    this.animationDuration = const Duration(seconds: 8),
    this.customColors,
    this.intensity = 0.8,
  });

  /// Factory constructor for static gradient backgrounds
  factory MeshGradientBackground.static({
    Key? key,
    required Widget child,
    List<Color>? customColors,
    double intensity = 0.6,
  }) {
    return MeshGradientBackground(
      key: key,
      animated: false,
      customColors: customColors,
      intensity: intensity,
      child: child,
    );
  }

  /// Factory constructor for highly animated backgrounds
  factory MeshGradientBackground.dynamic({
    Key? key,
    required Widget child,
    Duration? animationDuration,
    List<Color>? customColors,
  }) {
    return MeshGradientBackground(
      key: key,
      animated: true,
      animationDuration: animationDuration ?? const Duration(seconds: 4),
      customColors: customColors,
      intensity: 1.0,
      child: child,
    );
  }

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _meshControllers;

  @override
  void initState() {
    super.initState();

    if (widget.animated) {
      _animationController = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      )..repeat(reverse: true);

      // Multiple controllers for complex mesh animation
      _meshControllers = List.generate(
        4,
        (index) => AnimationController(
          duration: Duration(
            milliseconds:
                (widget.animationDuration.inMilliseconds * (0.7 + index * 0.15))
                    .round(),
          ),
          vsync: this,
        )..repeat(reverse: true),
      );
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _animationController.dispose();
      for (final controller in _meshControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.customColors ?? AppTheme.meshGradientColors;

    if (!widget.animated) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors[0].withValues(alpha: widget.intensity),
              colors[1].withValues(alpha: widget.intensity),
              colors[2].withValues(alpha: widget.intensity),
              colors[3].withValues(alpha: widget.intensity),
            ],
          ),
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final time = _animationController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(time * 2 * 3.14159),
              colors: [
                colors[0].withValues(
                  alpha: widget.intensity * (0.8 + time * 0.2),
                ),
                colors[1].withValues(
                  alpha: widget.intensity * (0.7 + time * 0.3),
                ),
                colors[2].withValues(
                  alpha: widget.intensity * (0.9 + time * 0.1),
                ),
                colors[3].withValues(
                  alpha: widget.intensity * (0.8 + time * 0.2),
                ),
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Specialized background for specific app sections
class PatternCategoryBackground extends StatelessWidget {
  final Widget child;
  final PatternCategoryType categoryType;

  const PatternCategoryBackground({
    super.key,
    required this.child,
    required this.categoryType,
  });

  @override
  Widget build(BuildContext context) {
    late List<Color> categoryColors;
    late Duration animationDuration;

    switch (categoryType) {
      case PatternCategoryType.creational:
        categoryColors = [
          AppTheme.meshGradientColors[0], // Green
          AppTheme.meshGradientColors[1], // Light green
          AppTheme.meshGradientColors[4], // Very light green
          const Color(0xFFE8F5E8), // Pale green
        ];
        animationDuration = const Duration(seconds: 6);
        break;

      case PatternCategoryType.structural:
        categoryColors = [
          AppTheme.meshGradientColors[1], // Light green
          AppTheme.meshGradientColors[2], // Cream
          AppTheme.meshGradientColors[3], // Light cream
          const Color(0xFFFFF8DC), // Pale cream
        ];
        animationDuration = const Duration(seconds: 8);
        break;

      case PatternCategoryType.behavioral:
        categoryColors = [
          AppTheme.meshGradientColors[0], // Green
          AppTheme.meshGradientColors[2], // Cream
          AppTheme.meshGradientColors[4], // Very light green
          AppTheme.meshGradientColors[3], // Light cream
        ];
        animationDuration = const Duration(seconds: 10);
        break;
    }

    return MeshGradientBackground(
      customColors: categoryColors,
      animationDuration: animationDuration,
      intensity: 0.7,
      child: child,
    );
  }
}

/// Pattern category types for specialized backgrounds
enum PatternCategoryType { creational, structural, behavioral }
