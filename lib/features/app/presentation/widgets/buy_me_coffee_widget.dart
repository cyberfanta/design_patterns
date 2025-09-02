/// Buy Me a Coffee Widget - Support Component
///
/// PATTERN: Command Pattern - Encapsulates coffee support action
/// WHERE: App feature presentation widgets
/// HOW: Provides coffee support link with custom phrases and imagery
/// WHY: Enables user support for continued development as specified
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/themes/app_theme.dart';

/// Buy me a coffee support widget with rotating phrases and coffee imagery.
///
/// Implements the specific phrases and styling requirements:
/// - "Si te gustó esta app, puedes invitarme un café"
/// - "Tu apoyo me ayuda a seguir creando"
/// - "No es necesario, pero se agradece mucho"
class BuyMeCoffeeWidget extends StatefulWidget {
  const BuyMeCoffeeWidget({super.key});

  @override
  State<BuyMeCoffeeWidget> createState() => _BuyMeCoffeeWidgetState();
}

class _BuyMeCoffeeWidgetState extends State<BuyMeCoffeeWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _currentPhraseIndex = 0;

  // PATTERN: Strategy Pattern - Different support phrases
  static const List<String> _supportPhrases = [
    'Si te gustó esta app, puedes invitarme un café',
    'Tu apoyo me ayuda a seguir creando',
    'No es necesario, pero se agradece mucho',
  ];

  // Buy me a coffee URL
  static const String _coffeeUrl = 'https://buymeacoffee.com/designpatterns';

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate phrases every 4 seconds
    _startPhraseRotation();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Start automatic phrase rotation
  void _startPhraseRotation() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _currentPhraseIndex =
              (_currentPhraseIndex + 1) % _supportPhrases.length;
        });
        _startPhraseRotation();
      }
    });
  }

  /// Open buy me a coffee URL
  Future<void> _openCoffeeUrl() async {
    try {
      final uri = Uri.parse(_coffeeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Provide haptic feedback
        HapticFeedback.lightImpact();

        // Show thank you message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Gracias por tu apoyo! ☕'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
          );
        }
      } else {
        _showErrorDialog('No se pudo abrir el enlace de soporte');
      }
    } catch (e) {
      _showErrorDialog('Error al abrir el enlace: $e');
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer.card(
      onTap: _openCoffeeUrl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coffee icon with animation
          AnimatedBuilder(
            animation: Listenable.merge([_rotationController, _pulseAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotationController.value * 2 * pi * 0.1,
                  // Subtle rotation
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF8B4513), // Coffee brown
                          Color(0xFFD2691E), // Lighter brown
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.local_cafe,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Rotating support phrase
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _supportPhrases[_currentPhraseIndex],
              key: ValueKey(_currentPhraseIndex),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Coffee imagery (if available)
          if (_shouldShowCoffeeImage())
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/coffee_support.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Call to action
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  size: 16,
                  color: Colors.red.withValues(alpha: 0.8),
                ),

                const SizedBox(width: AppTheme.spacingS),

                Text(
                  'Apóyame',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Check if coffee image asset exists
  bool _shouldShowCoffeeImage() {
    // This would normally check if the asset exists
    // For now, return false as we haven't added the image yet
    return false;
  }
}

/// Compact version for use in different contexts
class BuyMeCoffeeCompact extends StatelessWidget {
  const BuyMeCoffeeCompact({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer.button(
      onTap: () async {
        final uri = Uri.parse('https://buymeacoffee.com/designpatterns');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_cafe, size: 18, color: Colors.white),

          const SizedBox(width: AppTheme.spacingS),

          Text(
            'Buy me a coffee',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
