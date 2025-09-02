/// App Router Configuration
///
/// PATTERN: Router Pattern - Centralized navigation management
/// WHERE: Core presentation layer routing
/// HOW: Defines app navigation structure and route handling
/// WHY: Maintains clean navigation architecture and supports deep linking
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/app/presentation/pages/home_page.dart';
import '../../../features/app/presentation/pages/splash_page.dart';
import '../../../features/design_patterns/presentation/pages/behavioral_patterns_page.dart';
import '../../../features/design_patterns/presentation/pages/creational_patterns_page.dart';
import '../../../features/design_patterns/presentation/pages/structural_patterns_page.dart';
import '../../../features/user_profile/presentation/pages/auth_page.dart';
import '../../../features/user_profile/presentation/pages/profile_page.dart';

/// App router managing all navigation within the design patterns app.
///
/// Implements clean navigation architecture supporting the Tower Defense
/// learning experience with proper route management and navigation flow.
class AppRouter {
  // Route names as constants
  static const String splash = '/';
  static const String home = '/home';
  static const String auth = '/auth';
  static const String profile = '/profile';
  static const String creationalPatterns = '/patterns/creational';
  static const String structuralPatterns = '/patterns/structural';
  static const String behavioralPatterns = '/patterns/behavioral';
  static const String patternDetail = '/patterns/detail';

  /// Generate routes for the app
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _createRoute(const SplashPage(), settings);

      case home:
        return _createRoute(const HomePage(), settings);

      case auth:
        return _createRoute(const AuthPage(), settings);

      case profile:
        return _createRoute(const ProfilePage(), settings);

      case creationalPatterns:
        return _createRoute(const CreationalPatternsPage(), settings);

      case structuralPatterns:
        return _createRoute(const StructuralPatternsPage(), settings);

      case behavioralPatterns:
        return _createRoute(const BehavioralPatternsPage(), settings);

      case patternDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(
          PatternDetailPage(
            patternType: args?['patternType'] ?? '',
            category: args?['category'] ?? '',
          ),
          settings,
        );

      default:
        return _createRoute(const NotFoundPage(), settings);
    }
  }

  /// Creates custom page route with animation
  static PageRoute<dynamic> _createRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Custom transition animation - slide from right
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Navigation helpers for type-safe navigation
extension AppNavigator on BuildContext {
  /// Navigate to splash page
  void toSplash() {
    Navigator.of(
      this,
    ).pushNamedAndRemoveUntil(AppRouter.splash, (route) => false);
  }

  /// Navigate to home page
  void toHome() {
    Navigator.of(
      this,
    ).pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
  }

  /// Navigate to authentication page
  void toAuth() {
    Navigator.of(this).pushNamed(AppRouter.auth);
  }

  /// Navigate to profile page
  void toProfile() {
    Navigator.of(this).pushNamed(AppRouter.profile);
  }

  /// Navigate to creational patterns page
  void toCreationalPatterns() {
    Navigator.of(this).pushNamed(AppRouter.creationalPatterns);
  }

  /// Navigate to structural patterns page
  void toStructuralPatterns() {
    Navigator.of(this).pushNamed(AppRouter.structuralPatterns);
  }

  /// Navigate to behavioral patterns page
  void toBehavioralPatterns() {
    Navigator.of(this).pushNamed(AppRouter.behavioralPatterns);
  }

  /// Navigate to pattern detail page
  void toPatternDetail({
    required String patternType,
    required String category,
  }) {
    Navigator.of(this).pushNamed(
      AppRouter.patternDetail,
      arguments: {'patternType': patternType, 'category': category},
    );
  }

  /// Go back to previous page
  void goBack() {
    Navigator.of(this).pop();
  }

  /// Check if can go back
  bool canGoBack() {
    return Navigator.of(this).canPop();
  }
}

/// Provider for current route information
final currentRouteProvider = StateProvider<String>((ref) => AppRouter.splash);

/// Route observer for tracking navigation changes
class AppRouteObserver extends NavigatorObserver {
  final WidgetRef ref;

  AppRouteObserver(this.ref);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      ref.read(currentRouteProvider.notifier).state = route.settings.name!;
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      ref.read(currentRouteProvider.notifier).state =
          previousRoute!.settings.name!;
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      ref.read(currentRouteProvider.notifier).state = newRoute!.settings.name!;
    }
  }
}

/// Not found page for unknown routes
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The requested page could not be found.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.toHome(),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pattern detail page placeholder
class PatternDetailPage extends StatelessWidget {
  final String patternType;
  final String category;

  const PatternDetailPage({
    super.key,
    required this.patternType,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$patternType Pattern')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              patternType,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Category: $category', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
