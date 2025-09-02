/// App Drawer - Navigation and Actions
///
/// PATTERN: Observer Pattern - Responds to navigation state changes
/// WHERE: App feature presentation widgets
/// HOW: Provides slide-out navigation with glassmorphism styling
/// WHY: Centralizes navigation and secondary actions like "Buy me a coffee"
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/routing/app_router.dart';
import '../../../../core/presentation/themes/app_theme.dart';
import '../../../../features/user_profile/presentation/providers/user_profile_provider.dart';
import 'buy_me_coffee_widget.dart';

/// Custom drawer with glassmorphism effects and Tower Defense theming.
///
/// Provides navigation to main app sections and includes the
/// "Buy me a coffee" support widget as specified in requirements.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x88000000), // Semi-transparent black
              Color(0x44000000), // Lighter transparency
            ],
          ),
        ),
        child: Column(
          children: [
            // Header section with user info
            Container(
              padding: const EdgeInsets.only(
                top: 60, // Manual status bar spacing
                left: AppTheme.spacingL,
                right: AppTheme.spacingL,
                bottom: AppTheme.spacingL,
              ),
              child: GlassContainer.panel(
                child: _buildUserHeader(context, userProfile),
              ),
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                ),
                children: [
                  _buildNavigationSection(context, ref),

                  const SizedBox(height: AppTheme.spacingL),

                  _buildPatternSection(context, ref),

                  const SizedBox(height: AppTheme.spacingL),

                  _buildSettingsSection(context, ref),
                ],
              ),
            ),

            // Buy me a coffee section
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: const BuyMeCoffeeWidget(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds user header section
  Widget _buildUserHeader(BuildContext context, AsyncValue userProfile) {
    return userProfile.when(
      data: (profile) => Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: profile?.photoUrl != null
                ? CachedNetworkImageProvider(profile!.photoUrl!)
                : null,
            child: profile?.photoUrl == null
                ? Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),

          const SizedBox(width: AppTheme.spacingL),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.displayName ?? 'Guest User',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXS),

                Text(
                  profile?.email ?? 'Not signed in',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      loading: () => const Row(
        children: [
          CircleAvatar(radius: 30, child: CircularProgressIndicator()),
          SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Loading...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => const Row(
        children: [
          CircleAvatar(radius: 30, child: Icon(Icons.error, color: Colors.red)),
          SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Text(
              'Error loading profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds main navigation section
  Widget _buildNavigationSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Text(
            'Navigation',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),

        _buildDrawerItem(
          context: context,
          icon: Icons.home,
          title: 'Home',
          subtitle: 'Main dashboard',
          onTap: () {
            Navigator.of(context).pop();
            context.toHome();
          },
          isActive: ref.watch(currentRouteProvider) == AppRouter.home,
        ),

        _buildDrawerItem(
          context: context,
          icon: Icons.person,
          title: 'Profile',
          subtitle: 'Account settings',
          onTap: () {
            Navigator.of(context).pop();
            context.toProfile();
          },
          isActive: ref.watch(currentRouteProvider) == AppRouter.profile,
        ),

        _buildDrawerItem(
          context: context,
          icon: Icons.login,
          title: 'Authentication',
          subtitle: 'Sign in / Sign up',
          onTap: () {
            Navigator.of(context).pop();
            context.toAuth();
          },
          isActive: ref.watch(currentRouteProvider) == AppRouter.auth,
        ),
      ],
    );
  }

  /// Builds pattern categories section
  Widget _buildPatternSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Text(
            'Pattern Categories',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),

        _buildDrawerItem(
          context: context,
          icon: Icons.construction,
          title: 'Creational',
          subtitle: 'Object creation patterns',
          onTap: () {
            Navigator.of(context).pop();
            context.toCreationalPatterns();
          },
          isActive:
              ref.watch(currentRouteProvider) == AppRouter.creationalPatterns,
        ),

        _buildDrawerItem(
          context: context,
          icon: Icons.architecture,
          title: 'Structural',
          subtitle: 'Object composition patterns',
          onTap: () {
            Navigator.of(context).pop();
            context.toStructuralPatterns();
          },
          isActive:
              ref.watch(currentRouteProvider) == AppRouter.structuralPatterns,
        ),

        _buildDrawerItem(
          context: context,
          icon: Icons.psychology,
          title: 'Behavioral',
          subtitle: 'Object interaction patterns',
          onTap: () {
            Navigator.of(context).pop();
            context.toBehavioralPatterns();
          },
          isActive:
              ref.watch(currentRouteProvider) == AppRouter.behavioralPatterns,
        ),
      ],
    );
  }

  /// Builds settings and actions section
  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Text(
            'Settings & Actions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),

        _buildDrawerItem(
          context: context,
          icon: Icons.language,
          title: 'Language',
          subtitle: 'Change app language',
          onTap: () {
            Navigator.of(context).pop();
            _showLanguageSelector(context);
          },
        ),

        _buildDrawerItem(
          context: context,
          icon: Icons.palette,
          title: 'Theme',
          subtitle: 'Light / Dark mode',
          onTap: () {
            Navigator.of(context).pop();
            _showThemeSelector(context);
          },
        ),

        _buildDrawerItem(
          context: context,
          icon: Icons.info,
          title: 'About',
          subtitle: 'App information',
          onTap: () {
            Navigator.of(context).pop();
            _showAboutDialog(context);
          },
        ),
      ],
    );
  }

  /// Builds individual drawer item
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GlassNavigationContainer(
      isActive: isActive,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withValues(alpha: 0.8),
          ),

          const SizedBox(width: AppTheme.spacingL),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          if (isActive)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.6),
            ),
        ],
      ),
    );
  }

  /// Show language selector dialog
  void _showLanguageSelector(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇺🇸'),
              title: const Text('English'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Text('🇪🇸'),
              title: const Text('Español'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Text('🇫🇷'),
              title: const Text('Français'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Text('🇩🇪'),
              title: const Text('Deutsch'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  /// Show theme selector dialog
  void _showThemeSelector(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Mode'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.auto_mode),
              title: const Text('System Default'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Design Patterns',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Design Patterns Learning App',
      children: const [
        Text(
          'Learn design patterns through Tower Defense gameplay. '
          'Built with Clean Architecture, MVVM, and modern Flutter practices.',
        ),
      ],
    );
  }
}
