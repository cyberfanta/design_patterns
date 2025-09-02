/// Glass Bottom Sheet Component - Glassmorphism Modal Bottom Sheets
///
/// PATTERN: Strategy Pattern - Different presentation strategies for bottom sheets
/// WHERE: Core presentation components for bottom-up modal interactions
/// HOW: Configurable bottom sheet with multiple display strategies and glass effects
/// WHY: Flexible modal presentation for Tower Defense UI actions and menus
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'glass_container.dart';

/// Strategy interface for bottom sheet presentation
abstract class BottomSheetStrategy {
  Widget buildSheet(BuildContext context, Widget content);

  double get maxHeight;

  bool get isDismissible;

  bool get enableDrag;
}

/// Compact strategy - small height, quick actions
class CompactBottomSheetStrategy implements BottomSheetStrategy {
  @override
  double get maxHeight => 0.4;

  @override
  bool get isDismissible => true;

  @override
  bool get enableDrag => true;

  @override
  Widget buildSheet(BuildContext context, Widget content) {
    return GlassContainer.panel(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const SizedBox(height: AppTheme.spacingM),
          content,
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.glassBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Expanded strategy - larger height, detailed content
class ExpandedBottomSheetStrategy implements BottomSheetStrategy {
  @override
  double get maxHeight => 0.7;

  @override
  bool get isDismissible => true;

  @override
  bool get enableDrag => true;

  @override
  Widget buildSheet(BuildContext context, Widget content) {
    return GlassContainer.panel(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * maxHeight,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.glassBorder, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
        ],
      ),
    );
  }
}

/// Full screen strategy - maximum height, complex interactions
class FullScreenBottomSheetStrategy implements BottomSheetStrategy {
  @override
  double get maxHeight => 0.95;

  @override
  bool get isDismissible => false;

  @override
  bool get enableDrag => false;

  @override
  Widget buildSheet(BuildContext context, Widget content) {
    return GlassContainer(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * maxHeight,
      borderRadius: AppTheme.radiusL,
      // Only top corners rounded
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      margin: const EdgeInsets.all(AppTheme.spacingM),
      blurIntensity: 20.0,
      opacity: 0.08,
      borderWidth: 0.5,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.glassBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          GlassContainer.button(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.close,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Main Glass Bottom Sheet component using Strategy pattern
class GlassBottomSheet extends StatelessWidget {
  /// Sheet content
  final Widget child;

  /// Presentation strategy
  final BottomSheetStrategy strategy;

  /// Optional title for the sheet
  final String? title;

  /// Custom barrier color
  final Color? barrierColor;

  const GlassBottomSheet({
    super.key,
    required this.child,
    required this.strategy,
    this.title,
    this.barrierColor,
  });

  /// Factory constructor for compact sheets
  factory GlassBottomSheet.compact({
    Key? key,
    required Widget child,
    String? title,
    Color? barrierColor,
  }) {
    return GlassBottomSheet(
      key: key,
      strategy: CompactBottomSheetStrategy(),
      title: title,
      barrierColor: barrierColor,
      child: child,
    );
  }

  /// Factory constructor for expanded sheets
  factory GlassBottomSheet.expanded({
    Key? key,
    required Widget child,
    String? title,
    Color? barrierColor,
  }) {
    return GlassBottomSheet(
      key: key,
      strategy: ExpandedBottomSheetStrategy(),
      title: title,
      barrierColor: barrierColor,
      child: child,
    );
  }

  /// Factory constructor for full screen sheets
  factory GlassBottomSheet.fullScreen({
    Key? key,
    required Widget child,
    String? title,
    Color? barrierColor,
  }) {
    return GlassBottomSheet(
      key: key,
      strategy: FullScreenBottomSheetStrategy(),
      title: title,
      barrierColor: barrierColor,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = title != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Expanded(child: child),
            ],
          )
        : child;

    return strategy.buildSheet(context, content);
  }

  /// Static method to show bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required GlassBottomSheet sheet,
  }) {
    Log.debug(
      'GlassBottomSheet: Showing sheet with strategy ${sheet.strategy.runtimeType}',
    );

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: sheet.barrierColor ?? Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      isDismissible: sheet.strategy.isDismissible,
      enableDrag: sheet.strategy.enableDrag,
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height * sheet.strategy.maxHeight,
      ),
      builder: (_) => sheet,
    );
  }
}

/// Specialized bottom sheet for action lists
class GlassActionBottomSheet extends StatelessWidget {
  final String title;
  final List<GlassActionItem> actions;
  final VoidCallback? onDismiss;

  const GlassActionBottomSheet({
    super.key,
    required this.title,
    required this.actions,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet.compact(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: actions
            .map((action) => _buildActionItem(context, action))
            .toList(),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, GlassActionItem action) {
    return GlassContainer.button(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      onTap: () {
        Navigator.of(context).pop();
        action.onTap();
      },
      child: Row(
        children: [
          if (action.icon != null) ...[
            Icon(
              action.icon,
              color: action.isDestructive ? Colors.red : AppTheme.textPrimary,
              size: 20,
            ),
            const SizedBox(width: AppTheme.spacingM),
          ],
          Expanded(
            child: Text(
              action.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: action.isDestructive ? Colors.red : AppTheme.textPrimary,
                fontWeight: action.isDestructive
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          if (action.trailing != null) action.trailing!,
        ],
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<GlassActionItem> actions,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      builder: (_) => GlassActionBottomSheet(title: title, actions: actions),
    );
  }
}

/// Action item for action bottom sheets
class GlassActionItem {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isDestructive;

  const GlassActionItem({
    required this.title,
    required this.onTap,
    this.icon,
    this.trailing,
    this.isDestructive = false,
  });
}

/// Specialized bottom sheet for settings/configuration
class GlassSettingsBottomSheet extends StatelessWidget {
  final String title;
  final List<GlassSettingItem> settings;

  const GlassSettingsBottomSheet({
    super.key,
    required this.title,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet.expanded(
      title: title,
      child: ListView.separated(
        itemCount: settings.length,
        separatorBuilder: (context, index) =>
            Divider(color: AppTheme.glassBorder, height: 1),
        itemBuilder: (context, index) => _buildSettingItem(settings[index]),
      ),
    );
  }

  Widget _buildSettingItem(GlassSettingItem setting) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingS,
      ),
      leading: setting.icon != null
          ? Icon(setting.icon, color: AppTheme.textSecondary)
          : null,
      title: Text(
        setting.title,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: setting.subtitle != null
          ? Text(
              setting.subtitle!,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            )
          : null,
      trailing: setting.trailing,
      onTap: setting.onTap,
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<GlassSettingItem> settings,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      builder: (_) =>
          GlassSettingsBottomSheet(title: title, settings: settings),
    );
  }
}

/// Setting item for settings bottom sheets
class GlassSettingItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const GlassSettingItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
  });
}
