/// Glass Loader Component - Glassmorphism Loading Indicators
///
/// PATTERN: Builder Pattern + State Pattern - Configurable loaders with different states
/// WHERE: Core presentation components for loading feedback
/// HOW: Builder creates customized loaders, State pattern manages loading states
/// WHY: Consistent loading experience in Tower Defense app with visual feedback
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:design_patterns/core/logging/logging.dart';

import 'glass_container.dart';
import '../themes/app_theme.dart';

/// Loading state enumeration
enum LoadingState { idle, loading, success, error }

/// Loading type enumeration
enum LoadingType { spinner, dots, pulse, progress, shimmer }

/// Loading configuration model
class LoadingConfig {
  final LoadingType type;
  final String? message;
  final Color? color;
  final double size;
  final Duration duration;
  final bool showBackground;
  final double? progress; // For progress loader

  const LoadingConfig({
    this.type = LoadingType.spinner,
    this.message,
    this.color,
    this.size = 48.0,
    this.duration = const Duration(seconds: 1),
    this.showBackground = true,
    this.progress,
  });
}

/// Builder for creating glass loaders
class GlassLoaderBuilder {
  LoadingType _type = LoadingType.spinner;
  String? _message;
  Color? _color;
  double _size = 48.0;
  Duration _duration = const Duration(seconds: 1);
  bool _showBackground = true;
  double? _progress;

  /// Set loader type
  GlassLoaderBuilder type(LoadingType type) {
    _type = type;
    return this;
  }

  /// Set loading message
  GlassLoaderBuilder message(String message) {
    _message = message;
    return this;
  }

  /// Set color
  GlassLoaderBuilder color(Color color) {
    _color = color;
    return this;
  }

  /// Set size
  GlassLoaderBuilder size(double size) {
    _size = size;
    return this;
  }

  /// Set animation duration
  GlassLoaderBuilder duration(Duration duration) {
    _duration = duration;
    return this;
  }

  /// Set background visibility
  GlassLoaderBuilder showBackground(bool show) {
    _showBackground = show;
    return this;
  }

  /// Set progress value (for progress loader)
  GlassLoaderBuilder progress(double progress) {
    _progress = progress;
    return this;
  }

  /// Build the loader configuration
  LoadingConfig build() {
    return LoadingConfig(
      type: _type,
      message: _message,
      color: _color,
      size: _size,
      duration: _duration,
      showBackground: _showBackground,
      progress: _progress,
    );
  }
}

/// Main glass loader component with state management
class GlassLoader extends StatefulWidget {
  /// Loading configuration
  final LoadingConfig config;

  /// Current loading state
  final LoadingState state;

  /// Child widget to show when not loading
  final Widget? child;

  const GlassLoader({
    super.key,
    required this.config,
    this.state = LoadingState.loading,
    this.child,
  });

  /// Factory constructor for spinner loader
  factory GlassLoader.spinner({
    Key? key,
    String? message,
    Color? color,
    double size = 48.0,
    LoadingState state = LoadingState.loading,
    Widget? child,
  }) {
    final builder = GlassLoaderBuilder().type(LoadingType.spinner).size(size);

    if (message != null) builder.message(message);
    if (color != null) builder.color(color);

    return GlassLoader(
      key: key,
      config: builder.build(),
      state: state,
      child: child,
    );
  }

  /// Factory constructor for dots loader
  factory GlassLoader.dots({
    Key? key,
    String? message,
    Color? color,
    double size = 48.0,
    LoadingState state = LoadingState.loading,
    Widget? child,
  }) {
    final builder = GlassLoaderBuilder().type(LoadingType.dots).size(size);

    if (message != null) builder.message(message);
    if (color != null) builder.color(color);

    return GlassLoader(
      key: key,
      config: builder.build(),
      state: state,
      child: child,
    );
  }

  /// Factory constructor for pulse loader
  factory GlassLoader.pulse({
    Key? key,
    String? message,
    Color? color,
    double size = 48.0,
    LoadingState state = LoadingState.loading,
    Widget? child,
  }) {
    final builder = GlassLoaderBuilder().type(LoadingType.pulse).size(size);

    if (message != null) builder.message(message);
    if (color != null) builder.color(color);

    return GlassLoader(
      key: key,
      config: builder.build(),
      state: state,
      child: child,
    );
  }

  /// Factory constructor for progress loader
  factory GlassLoader.progress({
    Key? key,
    required double progress,
    String? message,
    Color? color,
    double size = 48.0,
    LoadingState state = LoadingState.loading,
    Widget? child,
  }) {
    final builder = GlassLoaderBuilder()
        .type(LoadingType.progress)
        .progress(progress)
        .size(size);

    if (message != null) builder.message(message);
    if (color != null) builder.color(color);

    return GlassLoader(
      key: key,
      config: builder.build(),
      state: state,
      child: child,
    );
  }

  @override
  State<GlassLoader> createState() => _GlassLoaderState();
}

class _GlassLoaderState extends State<GlassLoader>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );

    if (widget.state == LoadingState.loading) {
      _startAnimation();
    }

    Log.debug('GlassLoader: Initialized with type ${widget.config.type.name}');
  }

  @override
  void didUpdateWidget(GlassLoader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state != oldWidget.state) {
      if (widget.state == LoadingState.loading) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _animationController.repeat();
  }

  void _stopAnimation() {
    _animationController.stop();
  }

  @override
  Widget build(BuildContext context) {
    // Show child if not loading
    if (widget.state == LoadingState.idle && widget.child != null) {
      return widget.child!;
    }

    return widget.config.showBackground
        ? GlassContainer.panel(child: _buildLoaderContent())
        : _buildLoaderContent();
  }

  Widget _buildLoaderContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLoader(),
        if (widget.config.message != null) ...[
          const SizedBox(height: AppTheme.spacingM),
          Text(
            widget.config.message!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
        if (widget.state == LoadingState.success) ...[
          const SizedBox(height: AppTheme.spacingS),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
        if (widget.state == LoadingState.error) ...[
          const SizedBox(height: AppTheme.spacingS),
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
        ],
      ],
    );
  }

  Widget _buildLoader() {
    final color = widget.config.color ?? AppTheme.primaryColor;
    final size = widget.config.size;

    switch (widget.config.type) {
      case LoadingType.spinner:
        return _buildSpinner(color, size);
      case LoadingType.dots:
        return _buildDots(color, size);
      case LoadingType.pulse:
        return _buildPulse(color, size);
      case LoadingType.progress:
        return _buildProgress(color, size);
      case LoadingType.shimmer:
        return _buildShimmer(color, size);
    }
  }

  Widget _buildSpinner(Color color, double size) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: color.withValues(alpha: 0.2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDots(Color color, double size) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: size,
          height: size / 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              final delay = index * 0.2;
              final animValue = (_animation.value + delay) % 1.0;
              final scale = (math.sin(animValue * 2 * math.pi) * 0.5 + 0.5);

              return Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: Container(
                  width: size / 8,
                  height: size / 8,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.5 + scale * 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildPulse(Color color, double size) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final scale = 0.8 + (math.sin(_animation.value * 2 * math.pi) * 0.2);
        final opacity = 0.5 + (math.sin(_animation.value * 2 * math.pi) * 0.3);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.refresh,
              color: Colors.white.withValues(alpha: 0.8),
              size: size * 0.6,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgress(Color color, double size) {
    final progress = widget.config.progress ?? 0.0;

    return Column(
      children: [
        SizedBox(
          width: size * 2,
          height: 6,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer(Color color, double size) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: size * 2,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
              stops: [0.0, _animation.value, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
        );
      },
    );
  }
}

/// Overlay loader for full-screen loading states
class GlassOverlayLoader {
  static OverlayEntry? _currentOverlay;
  static bool _isShowing = false;

  /// Show overlay loader
  static void show({
    required BuildContext context,
    LoadingConfig? config,
    String? message,
    bool dismissible = false,
  }) {
    if (_isShowing) return;

    Log.debug('GlassOverlayLoader: Showing overlay loader');

    final loaderConfig =
        config ??
        GlassLoaderBuilder()
            .type(LoadingType.spinner)
            .message(message ?? 'Loading...')
            .showBackground(true)
            .build();

    _currentOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.5),
        child: GestureDetector(
          onTap: dismissible ? hide : null,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: GlassLoader(
                config: loaderConfig,
                state: LoadingState.loading,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
    _isShowing = true;
  }

  /// Hide overlay loader
  static void hide() {
    if (_isShowing && _currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
      _isShowing = false;
      Log.debug('GlassOverlayLoader: Overlay loader hidden');
    }
  }

  /// Check if loader is showing
  static bool get isShowing => _isShowing;
}

/// Specialized loaders for Tower Defense game states
class GlassTowerDefenseLoaders {
  /// Loading game assets
  static Widget gameAssetsLoader() {
    return GlassLoader.progress(
      progress: 0.0, // This would be updated by game logic
      message: 'Loading game assets...',
      color: AppTheme.primaryColor,
    );
  }

  /// Calculating tower damage
  static Widget towerCalculationLoader() {
    return GlassLoader.dots(
      message: 'Calculating optimal tower placement...',
      color: Colors.orange,
      size: 32,
    );
  }

  /// Processing wave generation
  static Widget waveGenerationLoader() {
    return GlassLoader.pulse(
      message: 'Generating next wave...',
      color: Colors.red,
      size: 40,
    );
  }

  /// Saving game progress
  static Widget saveProgressLoader() {
    return GlassLoader.spinner(
      message: 'Saving progress...',
      color: Colors.green,
      size: 36,
    );
  }

  /// Loading pattern explanation
  static Widget patternExplanationLoader() {
    return GlassLoader(
      config: GlassLoaderBuilder()
          .type(LoadingType.shimmer)
          .message('Loading pattern explanation...')
          .color(AppTheme.primaryColor)
          .size(48)
          .build(),
      state: LoadingState.loading,
    );
  }
}
