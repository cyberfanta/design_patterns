/// Profile Page - User Account Management
///
/// PATTERN: Observer Pattern - Reacts to user profile changes
/// WHERE: User Profile feature presentation layer
/// HOW: Displays user information and account management options
/// WHY: Provides centralized profile management and settings interface
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/components/mesh_gradient_background.dart';
import '../../../../core/presentation/themes/app_theme.dart';
import '../providers/user_profile_provider.dart';

/// Profile page displaying user information and account settings.
///
/// Shows Tower Defense themed profile with game progress,
/// account management options, and GDPR compliance features.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      body: MeshGradientBackground(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                top: 60, // Manual status bar spacing
                left: AppTheme.spacingL,
                right: AppTheme.spacingL,
                bottom: AppTheme.spacingM,
              ),
              child: _buildHeader(context),
            ),

            // Profile content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: userProfile.when(
                  data: (profile) =>
                      _buildProfileContent(context, ref, profile),
                  loading: () => _buildLoadingContent(context),
                  error: (error, stackTrace) =>
                      _buildErrorContent(context, error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GlassContainer.button(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),

        const SizedBox(width: AppTheme.spacingL),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              Text(
                'Manage your account and game progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),

        GlassContainer.button(
          onTap: () => _showSettingsMenu(context),
          child: const Icon(Icons.settings, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    dynamic profile,
  ) {
    if (profile == null) {
      return _buildNotSignedInContent(context);
    }

    return Column(
      children: [
        // Profile header card
        GlassContainer.panel(
          child: Column(
            children: [
              // Avatar and basic info
              Row(
                children: [
                  // Profile avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: profile.photoUrl != null
                        ? CachedNetworkImageProvider(profile.photoUrl!)
                        : null,
                    child: profile.photoUrl == null
                        ? Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),

                  const SizedBox(width: AppTheme.spacingXL),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName ?? 'Commander',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),

                        const SizedBox(height: AppTheme.spacingS),

                        Text(
                          profile.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                        ),

                        const SizedBox(height: AppTheme.spacingM),

                        // Level and progress
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingS,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusM,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer,
                              ],
                            ),
                          ),
                          child: Text(
                            'Level ${profile.gameLevel ?? 1} Commander',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingL),

        // Game progress stats
        _buildGameProgressCard(context, profile),

        const SizedBox(height: AppTheme.spacingL),

        // Account actions
        _buildAccountActionsCard(context, ref),

        const SizedBox(height: AppTheme.spacingL),

        // GDPR and legal
        _buildLegalCard(context),
      ],
    );
  }

  Widget _buildGameProgressCard(BuildContext context, dynamic profile) {
    return GlassContainer.panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tower Defense Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.games,
                  label: 'Games Played',
                  value: '${profile.gamesPlayed ?? 0}',
                ),
              ),

              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.military_tech,
                  label: 'Games Won',
                  value: '${profile.gamesWon ?? 0}',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.trending_up,
                  label: 'Win Rate',
                  value:
                      '${((profile.winRate ?? 0.0) * 100).toStringAsFixed(1)}%',
                ),
              ),

              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.account_circle,
                  label: 'Profile Complete',
                  value:
                      '${((profile.profileCompleteness ?? 0.0) * 100).toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),

        const SizedBox(height: AppTheme.spacingS),

        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAccountActionsCard(BuildContext context, WidgetRef ref) {
    return GlassContainer.panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          _buildActionItem(
            context,
            icon: Icons.edit,
            title: 'Edit Profile',
            subtitle: 'Update your information',
            onTap: () => _editProfile(context),
          ),

          _buildActionItem(
            context,
            icon: Icons.security,
            title: 'Privacy Settings',
            subtitle: 'Manage your privacy preferences',
            onTap: () => _showPrivacySettings(context),
          ),

          _buildActionItem(
            context,
            icon: Icons.download,
            title: 'Download My Data',
            subtitle: 'Export your account data',
            onTap: () => _downloadData(context),
          ),

          _buildActionItem(
            context,
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () => _signOut(context, ref),
            isDestructive: false,
          ),

          _buildActionItem(
            context,
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            onTap: () => _deleteAccount(context, ref),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.red : Colors.white),

            const SizedBox(width: AppTheme.spacingL),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDestructive ? Colors.red : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalCard(BuildContext context) {
    return GlassContainer.panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legal & Privacy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          _buildLegalItem(context, 'Terms of Service', () {}),
          _buildLegalItem(context, 'Privacy Policy', () {}),
          _buildLegalItem(context, 'GDPR Rights', () {}),
        ],
      ),
    );
  }

  Widget _buildLegalItem(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),

            Icon(
              Icons.open_in_new,
              size: 16,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotSignedInContent(BuildContext context) {
    return GlassContainer.panel(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.white.withValues(alpha: 0.5),
          ),

          const SizedBox(height: AppTheme.spacingXL),

          Text(
            'Not Signed In',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            'Sign in to track your progress and sync across devices',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spacingXL),

          GlassContainer.button(
            onTap: () => Navigator.of(context).pushNamed('/auth'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXL,
                vertical: AppTheme.spacingM,
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorContent(BuildContext context, Object error) {
    return GlassContainer.panel(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),

          const SizedBox(height: AppTheme.spacingL),

          Text(
            'Error Loading Profile',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    // TODO: Implement settings menu
  }

  void _editProfile(BuildContext context) {
    // TODO: Implement profile editing
  }

  void _showPrivacySettings(BuildContext context) {
    // TODO: Implement privacy settings
  }

  void _downloadData(BuildContext context) {
    // TODO: Implement data download
  }

  void _signOut(BuildContext context, WidgetRef ref) {
    // TODO: Implement sign out
  }

  void _deleteAccount(BuildContext context, WidgetRef ref) {
    // TODO: Implement account deletion with confirmation
  }
}
