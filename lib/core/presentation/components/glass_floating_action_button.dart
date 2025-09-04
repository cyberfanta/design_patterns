/// Glass Floating Action Button - Glassmorphism Floating Action Button
///
/// PATTERN: Template Method + Strategy Pattern
/// WHERE: Core presentation components - Glassmorphism floating action button
/// HOW: Creates floating action button with glassmorphism effect and customizable appearance
/// WHY: Provides consistent floating action button styling across the application
library;

import 'package:flutter/material.dart';

/// Floating action button with glassmorphism effect.
///
/// Provides a consistent design language for floating action buttons
/// throughout the application with Tower Defense theming.
class GlassFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final String? tooltip;
  final bool mini;

  const GlassFloatingActionButton({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.tooltip,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(mini ? 28 : 32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(mini ? 28 : 32),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(mini ? 28 : 32),
            child: Container(
              width: mini ? 40 : 56,
              height: mini ? 40 : 56,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
