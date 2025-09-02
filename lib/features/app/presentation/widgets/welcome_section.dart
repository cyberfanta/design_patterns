/// Welcome Section - App Introduction Header
///
/// PATTERN: Template Method Pattern - Defines welcome display structure
/// WHERE: App feature presentation widgets
/// HOW: Shows app branding, user greeting, and contextual information
/// WHY: Provides welcoming entry point and app orientation
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/themes/app_theme.dart';
import '../../../../features/user_profile/presentation/providers/user_profile_provider.dart';

/// Welcome section header with user greeting and app introduction.
///
/// Displays personalized welcome message in the context of the Tower Defense
/// design patterns learning experience, adapting to user authentication state.
class WelcomeSection extends ConsumerWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final currentTime = DateTime.now();

    return Row(
      children: [
        // Menu button
        GlassContainer.button(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: const Icon(Icons.menu, color: Colors.white),
        ),

        const SizedBox(width: AppTheme.spacingL),

        // Welcome content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time-based greeting
              Text(
                _getTimeBasedGreeting(currentTime),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),

              const SizedBox(height: AppTheme.spacingXS),

              // User-specific welcome
              userProfile.when(
                data: (profile) => _buildUserWelcome(context, profile),
                loading: () => _buildLoadingWelcome(context),
                error: (error, stackTrace) => _buildGuestWelcome(context),
              ),
            ],
          ),
        ),

        // Tower Defense context icon
        GlassContainer(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          borderRadius: AppTheme.radiusL,
          child: Icon(
            Icons.castle,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// Build welcome message for authenticated user
  Widget _buildUserWelcome(BuildContext context, dynamic profile) {
    final userName =
        profile?.displayName ?? profile?.email?.split('@').first ?? 'Commander';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $userName!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: AppTheme.spacingXS),

        Text(
          'Ready to master design patterns through tower defense?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Build welcome message for loading state
  Widget _buildLoadingWelcome(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 24,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(height: AppTheme.spacingS),

        Container(
          height: 16,
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  /// Build welcome message for guest user
  Widget _buildGuestWelcome(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, Commander!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: AppTheme.spacingXS),

        Text(
          'Enter the battlefield of design patterns learning',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Get time-based greeting message
  String _getTimeBasedGreeting(DateTime time) {
    final hour = time.hour;

    if (hour < 6) {
      return 'Working late, Commander?';
    } else if (hour < 12) {
      return 'Good morning!';
    } else if (hour < 18) {
      return 'Good afternoon!';
    } else if (hour < 22) {
      return 'Good evening!';
    } else {
      return 'Burning the midnight oil?';
    }
  }
}

/// Extended welcome section with additional context for first-time users
class ExtendedWelcomeSection extends ConsumerWidget {
  const ExtendedWelcomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer.panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main welcome
          const WelcomeSection(),

          const SizedBox(height: AppTheme.spacingXL),

          // App introduction
          Text(
            'About This Experience',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            'Learn 23 essential design patterns through interactive Tower Defense scenarios. '
            'Each pattern is demonstrated with real-world examples, code implementations '
            'in multiple languages, and engaging gameplay mechanics.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Quick stats
          Row(
            children: [
              _buildStatItem(
                context,
                icon: Icons.psychology,
                label: 'Patterns',
                value: '23',
              ),

              const SizedBox(width: AppTheme.spacingXL),

              _buildStatItem(
                context,
                icon: Icons.code,
                label: 'Languages',
                value: '6',
              ),

              const SizedBox(width: AppTheme.spacingXL),

              _buildStatItem(
                context,
                icon: Icons.category,
                label: 'Categories',
                value: '3',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),

        const SizedBox(height: AppTheme.spacingS),

        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
