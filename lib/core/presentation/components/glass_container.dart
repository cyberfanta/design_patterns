/// Glass Container Component - Glassmorphism Effect
///
/// PATTERN: Decorator Pattern - Enhances widgets with glass effects
/// WHERE: Core presentation components for reusable UI elements
/// HOW: Wraps child widgets with glass morphism styling using glass_kit
/// WHY: Provides consistent glassmorphism effects throughout the app
library;

import 'package:flutter/material.dart';

// Glass effect will be implemented with custom containers
import '../themes/app_theme.dart';

/// Reusable glass container component following design specifications.
///
/// In Tower Defense context, represents translucent UI panels that overlay
/// the game battlefield, maintaining visibility while providing clear
/// interactive surfaces for pattern selection and information display.
class GlassContainer extends StatelessWidget {
  /// Child widget to be wrapped with glass effect
  final Widget child;

  /// Container width (null for auto-sizing)
  final double? width;

  /// Container height (null for auto-sizing)
  final double? height;

  /// Internal padding for child content
  final EdgeInsetsGeometry padding;

  /// External margin for container positioning
  final EdgeInsetsGeometry margin;

  /// Border radius for rounded corners
  final double borderRadius;

  /// Glass blur intensity (0-25)
  final double blurIntensity;

  /// Glass opacity (0.0-1.0)
  final double opacity;

  /// Border width
  final double borderWidth;

  /// Custom glass color override
  final Color? glassColor;

  /// Custom border color override
  final Color? borderColor;

  /// Gradient overlay colors
  final List<Color>? gradientColors;

  /// Tap callback for interactive containers
  final VoidCallback? onTap;

  /// Long press callback
  final VoidCallback? onLongPress;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppTheme.spacingM),
    this.margin = EdgeInsets.zero,
    this.borderRadius = AppTheme.radiusL,
    this.blurIntensity = 10.0,
    this.opacity = 0.1,
    this.borderWidth = 1.0,
    this.glassColor,
    this.borderColor,
    this.gradientColors,
    this.onTap,
    this.onLongPress,
  });

  /// Factory constructor for card-style glass containers
  factory GlassContainer.card({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return GlassContainer(
      key: key,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingL),
      margin: margin ?? const EdgeInsets.all(AppTheme.spacingS),
      borderRadius: AppTheme.radiusL,
      blurIntensity: 15.0,
      opacity: 0.15,
      onTap: onTap,
      child: child,
    );
  }

  /// Factory constructor for button-style glass containers
  factory GlassContainer.button({
    Key? key,
    required Widget child,
    required VoidCallback onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassContainer(
      key: key,
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
      margin: margin ?? const EdgeInsets.all(AppTheme.spacingS),
      borderRadius: AppTheme.radiusM,
      blurIntensity: 8.0,
      opacity: 0.2,
      onTap: onTap,
      child: child,
    );
  }

  /// Factory constructor for panel-style glass containers
  factory GlassContainer.panel({
    Key? key,
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassContainer(
      key: key,
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingXL),
      margin: margin ?? const EdgeInsets.all(AppTheme.spacingM),
      borderRadius: AppTheme.radiusXL,
      blurIntensity: 20.0,
      opacity: 0.08,
      borderWidth: 0.5,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Custom glass effect implementation
    Widget glassWidget = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: (glassColor ?? AppTheme.glassColor).withValues(alpha: opacity),
        border: Border.all(
          color: borderColor ?? AppTheme.glassBorder,
          width: borderWidth,
        ),
        gradient: gradientColors != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors!,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: blurIntensity,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    // Add margin if specified
    if (margin != EdgeInsets.zero) {
      glassWidget = Container(margin: margin, child: glassWidget);
    }

    // Add interaction if callbacks provided
    if (onTap != null || onLongPress != null) {
      glassWidget = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: glassWidget,
      );
    }

    return glassWidget;
  }
}

/// Specialized glass navigation container for drawer/navigation elements
class GlassNavigationContainer extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final VoidCallback? onTap;

  const GlassNavigationContainer({
    super.key,
    required this.child,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingM,
      ),
      borderRadius: AppTheme.radiusM,
      blurIntensity: isActive ? 15.0 : 8.0,
      opacity: isActive ? 0.25 : 0.1,
      borderWidth: isActive ? 1.5 : 0.5,
      borderColor: isActive
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
          : AppTheme.glassBorder,
      onTap: onTap,
      child: child,
    );
  }
}

/// Glass floating action button
class GlassFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double size;

  const GlassFloatingActionButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: size,
      height: size,
      padding: EdgeInsets.zero,
      borderRadius: size / 2,
      blurIntensity: 12.0,
      opacity: 0.2,
      borderWidth: 1.5,
      onTap: onPressed,
      child: Center(child: child),
    );
  }
}
