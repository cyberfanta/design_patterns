/// Glass Toast Component - Glassmorphism Notifications
///
/// PATTERN: Singleton Pattern + Factory Pattern - Global toast manager with different toast types
/// WHERE: Core presentation components for user feedback notifications
/// HOW: Singleton manager creates different toast types using factory methods
/// WHY: Consistent notification system across Tower Defense app with contextual feedback
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'glass_container.dart';

/// Toast type enumeration
enum ToastType { success, error, warning, info }

/// Toast position enumeration
enum ToastPosition { top, center, bottom }

/// Toast data model
class ToastData {
  final String message;
  final ToastType type;
  final Duration duration;
  final ToastPosition position;
  final IconData? icon;
  final VoidCallback? onTap;

  const ToastData({
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.position = ToastPosition.bottom,
    this.icon,
    this.onTap,
  });
}

/// Singleton Glass Toast Manager
///
/// PATTERN: Singleton - Ensures only one toast manager instance exists
class GlassToastManager {
  static GlassToastManager? _instance;

  static GlassToastManager get instance => _instance ??= GlassToastManager._();

  GlassToastManager._() {
    Log.debug('GlassToastManager: Singleton instance created');
  }

  OverlayEntry? _currentOverlay;
  bool _isShowing = false;

  /// Show toast with custom data
  void show({required BuildContext context, required ToastData data}) {
    // Dismiss current toast if showing
    if (_isShowing) {
      dismiss();
    }

    Log.debug(
      'GlassToastManager: Showing ${data.type.name} toast - "${data.message}"',
    );

    _currentOverlay = OverlayEntry(
      builder: (context) => _GlassToastWidget(data: data, onDismiss: dismiss),
    );

    Overlay.of(context).insert(_currentOverlay!);
    _isShowing = true;

    // Auto dismiss after duration
    Future.delayed(data.duration, () {
      dismiss();
    });
  }

  /// Factory method for success toasts
  void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      data: ToastData(
        message: message,
        type: ToastType.success,
        duration: duration,
        position: position,
        icon: Icons.check_circle_outline,
        onTap: onTap,
      ),
    );
  }

  /// Factory method for error toasts
  void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    ToastPosition position = ToastPosition.bottom,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      data: ToastData(
        message: message,
        type: ToastType.error,
        duration: duration,
        position: position,
        icon: Icons.error_outline,
        onTap: onTap,
      ),
    );
  }

  /// Factory method for warning toasts
  void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      data: ToastData(
        message: message,
        type: ToastType.warning,
        duration: duration,
        position: position,
        icon: Icons.warning_amber_outlined,
        onTap: onTap,
      ),
    );
  }

  /// Factory method for info toasts
  void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      data: ToastData(
        message: message,
        type: ToastType.info,
        duration: duration,
        position: position,
        icon: Icons.info_outline,
        onTap: onTap,
      ),
    );
  }

  /// Dismiss current toast
  void dismiss() {
    if (_isShowing && _currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
      _isShowing = false;
      Log.debug('GlassToastManager: Toast dismissed');
    }
  }

  /// Check if toast is currently showing
  bool get isShowing => _isShowing;
}

/// Internal toast widget with glassmorphism effects
class _GlassToastWidget extends StatefulWidget {
  final ToastData data;
  final VoidCallback onDismiss;

  const _GlassToastWidget({required this.data, required this.onDismiss});

  @override
  State<_GlassToastWidget> createState() => _GlassToastWidgetState();
}

class _GlassToastWidgetState extends State<_GlassToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<double>(
          begin: widget.data.position == ToastPosition.top ? -1.0 : 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getColorForType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
        return AppTheme.primaryColor;
    }
  }

  Alignment _getAlignment() {
    switch (widget.data.position) {
      case ToastPosition.top:
        return Alignment.topCenter;
      case ToastPosition.center:
        return Alignment.center;
      case ToastPosition.bottom:
        return Alignment.bottomCenter;
    }
  }

  EdgeInsets _getMargin() {
    switch (widget.data.position) {
      case ToastPosition.top:
        return const EdgeInsets.only(
          top: 50.0,
          left: AppTheme.spacingM,
          right: AppTheme.spacingM,
        );
      case ToastPosition.center:
        return const EdgeInsets.symmetric(horizontal: AppTheme.spacingM);
      case ToastPosition.bottom:
        return const EdgeInsets.only(
          bottom: 50.0,
          left: AppTheme.spacingM,
          right: AppTheme.spacingM,
        );
    }
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getColorForType(widget.data.type);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Align(
          alignment: _getAlignment(),
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                margin: _getMargin(),
                child: GlassContainer(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  borderColor: typeColor.withValues(alpha: 0.3),
                  borderWidth: 1.5,
                  onTap: widget.data.onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      if (widget.data.icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingS),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusS,
                            ),
                          ),
                          child: Icon(
                            widget.data.icon,
                            color: typeColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                      ],

                      // Message
                      Flexible(
                        child: Text(
                          widget.data.message,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),

                      // Close button
                      const SizedBox(width: AppTheme.spacingM),
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.close,
                            color: AppTheme.textSecondary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Utility class for quick toast access
class GlassToast {
  /// Singleton instance
  static GlassToastManager get _manager => GlassToastManager.instance;

  /// Show success toast
  static void success({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
    VoidCallback? onTap,
  }) {
    _manager.showSuccess(
      context: context,
      message: message,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Show error toast
  static void error({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    ToastPosition position = ToastPosition.bottom,
    VoidCallback? onTap,
  }) {
    _manager.showError(
      context: context,
      message: message,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Show warning toast
  static void warning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
    VoidCallback? onTap,
  }) {
    _manager.showWarning(
      context: context,
      message: message,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Show info toast
  static void info({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
    VoidCallback? onTap,
  }) {
    _manager.showInfo(
      context: context,
      message: message,
      duration: duration,
      position: position,
      onTap: onTap,
    );
  }

  /// Dismiss current toast
  static void dismiss() {
    _manager.dismiss();
  }

  /// Check if toast is showing
  static bool get isShowing => _manager.isShowing;
}

/// Specialized toast for game-specific notifications
class GlassTowerDefenseToast {
  /// Show tower upgrade notification
  static void towerUpgraded({
    required BuildContext context,
    required String towerName,
    required int level,
  }) {
    GlassToast.success(
      context: context,
      message: '$towerName upgraded to Level $level!',
      duration: const Duration(seconds: 2),
    );
  }

  /// Show enemy defeated notification
  static void enemyDefeated({
    required BuildContext context,
    required String enemyName,
    required int gold,
  }) {
    GlassToast.success(
      context: context,
      message: '$enemyName defeated! +$gold gold',
      duration: const Duration(seconds: 2),
    );
  }

  /// Show wave completed notification
  static void waveCompleted({
    required BuildContext context,
    required int waveNumber,
    required int bonus,
  }) {
    GlassToast.success(
      context: context,
      message: 'Wave $waveNumber completed! Bonus: $bonus gold',
      duration: const Duration(seconds: 3),
    );
  }

  /// Show base under attack warning
  static void baseUnderAttack({
    required BuildContext context,
    required int health,
  }) {
    GlassToast.warning(
      context: context,
      message: 'Base under attack! Health: $health',
      duration: const Duration(seconds: 3),
      position: ToastPosition.top,
    );
  }

  /// Show game over notification
  static void gameOver({
    required BuildContext context,
    required int finalScore,
  }) {
    GlassToast.error(
      context: context,
      message: 'Game Over! Final Score: $finalScore',
      duration: const Duration(seconds: 5),
      position: ToastPosition.center,
    );
  }

  /// Show pattern learned notification
  static void patternLearned({
    required BuildContext context,
    required String patternName,
  }) {
    GlassToast.info(
      context: context,
      message: 'New pattern learned: $patternName',
      duration: const Duration(seconds: 4),
    );
  }
}
