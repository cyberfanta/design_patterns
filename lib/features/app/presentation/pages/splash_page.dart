/// Splash Page - App Entry Point
///
/// PATTERN: Facade Pattern - Simplifies app initialization complexity
/// WHERE: App feature presentation layer
/// HOW: Displays loading screen while initializing app services and dependencies
/// WHY: Provides smooth user experience during startup and service initialization
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/logging.dart';
import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/components/mesh_gradient_background.dart';
import '../../../../core/presentation/routing/app_router.dart';
import '../../../../core/presentation/themes/app_theme.dart';

/// Splash screen with animated loading and service initialization.
///
/// Represents the Tower Defense app startup sequence, displaying
/// the app branding while preparing all necessary services for
/// the design patterns learning experience.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configure system UI overlay
    AppTheme.configureSystemUI(isDark: false);

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start initialization sequence
    _initializeApp();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Initialize app services and navigate to home
  Future<void> _initializeApp() async {
    try {
      // Start animations
      _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      _scaleController.forward();

      // Initialize core services in parallel
      await Future.wait([
        _initializeTranslationService(),
        _initializeConfigurationService(),
        _initializeUserProfileService(),
        // Minimum splash duration for better UX
        Future.delayed(const Duration(milliseconds: 2500)),
      ]);

      // Navigate to home page
      if (mounted) {
        context.toHome();
      }
    } catch (e) {
      // Handle initialization errors gracefully
      _showInitializationError(e.toString());
    }
  }

  /// Initialize translation service
  Future<void> _initializeTranslationService() async {
    // Simplified initialization - services are dependency injected
    Log.debug('Translation service initialization completed');
  }

  /// Initialize configuration service
  Future<void> _initializeConfigurationService() async {
    // Simplified initialization - services are dependency injected
    Log.debug('Configuration service initialization completed');
  }

  /// Initialize user profile service
  Future<void> _initializeUserProfileService() async {
    // Simplified initialization - services are dependency injected
    Log.debug('User profile service initialization completed');
  }

  /// Show initialization error dialog
  void _showInitializationError(String error) {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: Text(
          'Failed to initialize the app:\n$error\n\n'
          'Please restart the application.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.toHome(); // Try to continue anyway
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeshGradientBackground(
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GlassContainer.panel(
                    width: 300,
                    height: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo/Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.psychology_outlined,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),

                        // App Title
                        Text(
                          'Design Patterns',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),

                        const SizedBox(height: AppTheme.spacingS),

                        // Subtitle
                        Text(
                          'Tower Defense Learning',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),

                        // Loading indicator
                        SizedBox(
                          width: 150,
                          height: 4,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingM),

                        // Loading text
                        Text(
                          'Initializing services...',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
