/// Glass Dialog Component - Glassmorphism Modal Dialogs
///
/// PATTERN: Template Method Pattern - Defines dialog structure with customizable steps
/// WHERE: Core presentation components for modal interactions
/// HOW: Base dialog template with glassmorphism effects and customizable content
/// WHY: Consistent modal experience across Tower Defense interface
library;

import 'package:design_patterns/core/logging/logging.dart';
import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'glass_container.dart';

/// Base glass dialog following Template Method pattern.
///
/// In Tower Defense context, represents command center popup dialogs for
/// confirming strategic decisions, displaying game information, or
/// providing interactive configuration panels.
abstract class GlassDialog extends StatelessWidget {
  /// Dialog title
  final String title;

  /// Dialog width (null for auto-sizing)
  final double? width;

  /// Dialog height (null for auto-sizing)
  final double? height;

  /// Whether dialog can be dismissed by tapping outside
  final bool dismissible;

  /// Custom barrier color
  final Color? barrierColor;

  const GlassDialog({
    super.key,
    required this.title,
    this.width,
    this.height,
    this.dismissible = true,
    this.barrierColor,
  });

  /// Template method - builds complete dialog structure
  @override
  Widget build(BuildContext context) {
    Log.debug('GlassDialog: Building dialog with title "$title"');

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer.panel(
        width: width ?? MediaQuery.of(context).size.width * 0.8,
        height: height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header section - standardized across all dialogs
            _buildHeader(context),

            // Content section - customized by subclasses
            Flexible(child: buildContent(context)),

            // Actions section - customized by subclasses
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// Template method step - header is standardized
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.glassBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          buildHeaderIcon(context),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (dismissible)
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

  /// Template method step - actions section is standardized
  Widget _buildActions(BuildContext context) {
    final actions = buildActions(context);
    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.only(top: AppTheme.spacingM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.glassBorder, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions
            .map(
              (action) => Padding(
                padding: const EdgeInsets.only(left: AppTheme.spacingS),
                child: action,
              ),
            )
            .toList(),
      ),
    );
  }

  /// Template method hook - header icon (customizable)
  Widget buildHeaderIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
    );
  }

  /// Template method abstract step - content area (must be implemented)
  Widget buildContent(BuildContext context);

  /// Template method hook - actions (optional)
  List<Widget> buildActions(BuildContext context) => [];

  /// Utility method to show dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required GlassDialog dialog,
    bool barrierDismissible = true,
  }) {
    Log.debug('GlassDialog: Showing dialog - ${dialog.title}');

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible && dialog.dismissible,
      barrierColor: dialog.barrierColor ?? Colors.black.withValues(alpha: 0.5),
      builder: (_) => dialog,
    );
  }
}

/// Confirmation dialog implementation
class GlassConfirmationDialog extends GlassDialog {
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? iconData;

  const GlassConfirmationDialog({
    super.key,
    required super.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.iconData,
    super.dismissible,
  });

  @override
  Widget buildHeaderIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Icon(
        iconData ?? Icons.help_outline,
        color: Colors.orange,
        size: 20,
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      GlassContainer.button(
        onTap: () {
          Navigator.of(context).pop(false);
          onCancel?.call();
        },
        child: Text(
          cancelText,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
      ),
      GlassContainer.button(
        onTap: () {
          Navigator.of(context).pop(true);
          onConfirm?.call();
        },
        child: Text(
          confirmText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
  }
}

/// Information dialog implementation
class GlassInfoDialog extends GlassDialog {
  final String message;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const GlassInfoDialog({
    super.key,
    required super.title,
    required this.message,
    this.buttonText = 'OK',
    this.onButtonPressed,
    super.dismissible,
  });

  @override
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      GlassContainer.button(
        onTap: () {
          Navigator.of(context).pop();
          onButtonPressed?.call();
        },
        child: Text(
          buttonText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
  }
}

/// Custom dialog builder for complex content
class GlassCustomDialog extends GlassDialog {
  final Widget content;
  final List<Widget> actions;
  final IconData? headerIconData;
  final Color? headerIconColor;

  const GlassCustomDialog({
    super.key,
    required super.title,
    required this.content,
    this.actions = const [],
    this.headerIconData,
    this.headerIconColor,
    super.width,
    super.height,
    super.dismissible,
  });

  @override
  Widget buildHeaderIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: (headerIconColor ?? AppTheme.primaryColor).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Icon(
        headerIconData ?? Icons.settings_outlined,
        color: headerIconColor ?? AppTheme.primaryColor,
        size: 20,
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
      child: content,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => actions;
}
