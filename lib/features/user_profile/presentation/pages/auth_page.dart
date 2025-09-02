/// Authentication Page - Sign In/Sign Up Interface
///
/// PATTERN: Facade Pattern - Simplifies complex authentication flows
/// WHERE: User Profile feature presentation layer
/// HOW: Provides unified interface for multiple authentication methods
/// WHY: Streamlines user onboarding with multiple auth providers
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/components/mesh_gradient_background.dart';
import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/themes/app_theme.dart';

/// Authentication page with multiple sign-in options.
///
/// Provides Tower Defense themed authentication interface with
/// email/password, Google, and Apple sign-in options.
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _isSignIn = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: _buildHeader(),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: GlassContainer.panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Toggle between Sign In / Sign Up
                      _buildAuthToggle(),

                      const SizedBox(height: AppTheme.spacingXL),

                      // Email/Password form
                      _buildEmailPasswordForm(),

                      const SizedBox(height: AppTheme.spacingL),

                      // Or divider
                      _buildOrDivider(),

                      const SizedBox(height: AppTheme.spacingL),

                      // Social sign-in buttons
                      _buildSocialSignIn(),

                      const SizedBox(height: AppTheme.spacingL),

                      // Terms and conditions
                      if (!_isSignIn) _buildTermsAndConditions(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                _isSignIn ? 'Welcome Back!' : 'Join the Battle!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              Text(
                _isSignIn
                    ? 'Sign in to continue your pattern learning journey'
                    : 'Create account to start mastering design patterns',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isSignIn = true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingM,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  color: _isSignIn
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
                child: Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: _isSignIn ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isSignIn = false),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingM,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  color: !_isSignIn
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: !_isSignIn
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailPasswordForm() {
    return Column(
      children: [
        if (!_isSignIn) ...[
          _buildInputField(
            controller: _nameController,
            label: 'Commander Name',
            icon: Icons.person,
          ),
          const SizedBox(height: AppTheme.spacingM),
        ],

        _buildInputField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: AppTheme.spacingM),

        _buildInputField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock,
          obscureText: true,
        ),

        const SizedBox(height: AppTheme.spacingXL),

        GlassContainer.button(
          onTap: _handleEmailPasswordAuth,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            child: Text(
              _isSignIn ? 'Sign In' : 'Create Account',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingS,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          child: Text(
            'or',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),

        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSignIn() {
    return Column(
      children: [
        GlassContainer.button(
          onTap: _handleGoogleSignIn,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.g_mobiledata, color: Colors.white),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppTheme.spacingM),

        GlassContainer.button(
          onTap: _handleAppleSignIn,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apple, color: Colors.white),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  'Continue with Apple',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Text(
      'By creating an account, you agree to our Terms of Service and Privacy Policy',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.6),
      ),
      textAlign: TextAlign.center,
    );
  }

  void _handleEmailPasswordAuth() {
    // TODO: Implement email/password authentication
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSignIn
              ? 'Sign in not implemented yet'
              : 'Sign up not implemented yet',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _handleGoogleSignIn() {
    // TODO: Implement Google sign-in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google sign-in not implemented yet'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleAppleSignIn() {
    // TODO: Implement Apple sign-in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple sign-in not implemented yet'),
        backgroundColor: Colors.black,
      ),
    );
  }
}
