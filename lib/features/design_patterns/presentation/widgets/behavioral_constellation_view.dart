/// Behavioral Constellation View - Interactive Star Map of Behavioral Patterns
///
/// PATTERN: Composite + Flyweight + Observer Pattern
/// WHERE: Behavioral Patterns feature - Alternative constellation visualization
/// HOW: Displays patterns as constellations with interactive connections and animations
/// WHY: Provides an innovative, space-themed approach to pattern exploration
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/presentation/components/glass_container.dart';
import '../../../../core/presentation/themes/app_theme.dart';
import '../controllers/behavioral_patterns_controller.dart';
import '../models/behavioral_pattern_info.dart';

/// Interactive constellation view for behavioral patterns.
///
/// Creates a star map where each pattern is a constellation,
/// with connections showing pattern relationships in Tower Defense context.
class BehavioralConstellationView extends StatefulWidget {
  final BehavioralPatternsController controller;

  const BehavioralConstellationView({super.key, required this.controller});

  @override
  State<BehavioralConstellationView> createState() =>
      _BehavioralConstellationViewState();
}

class _BehavioralConstellationViewState
    extends State<BehavioralConstellationView>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _twinkleController;
  late AnimationController _connectionController;

  int? selectedConstellationIndex;
  List<ConstellationData> constellations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateConstellations();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(minutes: 5),
      vsync: this,
    );

    _twinkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _connectionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController.repeat();
    _twinkleController.repeat();
  }

  void _generateConstellations() {
    final patterns = widget.controller.allPatterns;
    final screenCenter = const Offset(200, 200); // Will be updated in build

    constellations = patterns.asMap().entries.map((entry) {
      final index = entry.key;
      final pattern = entry.value;

      // Position constellations in a spiral
      final angle = (index * 2 * math.pi / patterns.length);
      final radius = 100 + (index % 3) * 50;
      final position = Offset(
        screenCenter.dx + math.cos(angle) * radius,
        screenCenter.dy + math.sin(angle) * radius,
      );

      return ConstellationData(
        pattern: pattern,
        position: position,
        stars: _generateStarsForPattern(pattern, position),
        connections: _generateConnectionsForPattern(pattern),
      );
    }).toList();
  }

  List<StarData> _generateStarsForPattern(
    BehavioralPatternInfo pattern,
    Offset center,
  ) {
    final starCount = 3 + (pattern.complexity ~/ 2);
    final stars = <StarData>[];

    for (int i = 0; i < starCount; i++) {
      final angle = (i * 2 * math.pi / starCount) + math.pi / 4;
      final distance = 20 + (i % 2) * 15;
      final position = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      stars.add(
        StarData(
          position: position,
          brightness: 0.5 + (i % 3) * 0.25,
          size: 2 + (i % 2) * 2,
          twinklePhase: i * 0.3,
        ),
      );
    }

    return stars;
  }

  List<int> _generateConnectionsForPattern(BehavioralPatternInfo pattern) {
    // Generate connections based on related patterns
    // This is a simplified version - in a real app, you'd use actual pattern relationships
    final connections = <int>[];
    final patternIndex = widget.controller.allPatterns.indexOf(pattern);

    // Connect to 1-3 related patterns based on complexity
    final connectionCount = math.min(3, (pattern.complexity ~/ 3));
    for (int i = 1; i <= connectionCount; i++) {
      final targetIndex =
          (patternIndex + i * 2) % widget.controller.allPatterns.length;
      if (targetIndex != patternIndex) {
        connections.add(targetIndex);
      }
    }

    return connections;
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _twinkleController.dispose();
    _connectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Update constellation positions for actual screen size
    if (constellations.isNotEmpty) {
      _updateConstellationPositions(screenSize);
    }

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      color: Colors.black.withValues(alpha: 0.9),
      child: Stack(
        children: [_buildStarField(), _buildConstellations(), _buildUI()],
      ),
    );
  }

  Widget _buildStarField() {
    return AnimatedBuilder(
      animation: _twinkleController,
      builder: (context, child) {
        return CustomPaint(
          painter: StarFieldPainter(
            twinkleAnimation: _twinkleController.value,
            rotationAnimation: _rotationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildConstellations() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _twinkleController,
        _connectionController,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: ConstellationPainter(
            constellations: constellations,
            selectedIndex: selectedConstellationIndex,
            rotationAnimation: _rotationController.value,
            twinkleAnimation: _twinkleController.value,
            connectionAnimation: _connectionController.value,
          ),
          size: Size.infinite,
          child: GestureDetector(onTapDown: _handleTapDown),
        );
      },
    );
  }

  Widget _buildUI() {
    return Positioned(
      top: 60,
      left: AppTheme.spacingL,
      right: AppTheme.spacingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppTheme.spacingL),
          if (selectedConstellationIndex != null) _buildPatternDetails(),
        ],
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
                'Pattern Constellations',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Touch a constellation to explore',
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

  Widget _buildPatternDetails() {
    final pattern = constellations[selectedConstellationIndex!].pattern;

    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50,
        child: FadeInAnimation(
          child: GlassContainer(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      pattern.icon,
                      color: _getConstellationColor(
                        selectedConstellationIndex!,
                      ),
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Text(
                        pattern.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => selectedConstellationIndex = null),
                      child: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  pattern.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Tower Defense Context:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  pattern.towerDefenseContext,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Row(
                  children: [
                    _buildMetricChip(
                      'Complexity',
                      pattern.complexity.toStringAsFixed(1),
                      _getConstellationColor(selectedConstellationIndex!),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    _buildMetricChip(
                      'Category',
                      pattern.category,
                      _getConstellationColor(selectedConstellationIndex!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    final position = details.localPosition;

    for (int i = 0; i < constellations.length; i++) {
      final constellation = constellations[i];
      final distance = (constellation.position - position).distance;

      if (distance < 60) {
        // Touch tolerance
        setState(() {
          selectedConstellationIndex = selectedConstellationIndex == i
              ? null
              : i;
        });

        if (selectedConstellationIndex == i) {
          _connectionController.forward();
        }
        break;
      }
    }
  }

  void _updateConstellationPositions(Size screenSize) {
    final patterns = widget.controller.allPatterns;
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);

    for (int i = 0; i < constellations.length; i++) {
      final angle = (i * 2 * math.pi / patterns.length);
      final radius =
          math.min(screenSize.width, screenSize.height) / 4 + (i % 3) * 30;
      final position = Offset(
        screenCenter.dx + math.cos(angle) * radius,
        screenCenter.dy + math.sin(angle) * radius,
      );

      constellations[i] = constellations[i].copyWith(
        position: position,
        stars: _generateStarsForPattern(patterns[i], position),
      );
    }
  }

  Color _getConstellationColor(int index) {
    final colors = [
      const Color(0xFF667eea),
      const Color(0xFFf5576c),
      const Color(0xFF4facfe),
      const Color(0xFF43e97b),
      const Color(0xFFfa709a),
      const Color(0xFF9b59b6),
      const Color(0xFFe67e22),
      const Color(0xFF8e44ad),
      const Color(0xFF3498db),
      const Color(0xFF9c27b0),
      const Color(0xFFf39c12),
    ];
    return colors[index % colors.length];
  }
}

/// Data class for constellation information
class ConstellationData {
  final BehavioralPatternInfo pattern;
  final Offset position;
  final List<StarData> stars;
  final List<int> connections;

  const ConstellationData({
    required this.pattern,
    required this.position,
    required this.stars,
    required this.connections,
  });

  ConstellationData copyWith({
    BehavioralPatternInfo? pattern,
    Offset? position,
    List<StarData>? stars,
    List<int>? connections,
  }) {
    return ConstellationData(
      pattern: pattern ?? this.pattern,
      position: position ?? this.position,
      stars: stars ?? this.stars,
      connections: connections ?? this.connections,
    );
  }
}

/// Data class for star information
class StarData {
  final Offset position;
  final double brightness;
  final double size;
  final double twinklePhase;

  const StarData({
    required this.position,
    required this.brightness,
    required this.size,
    required this.twinklePhase,
  });
}

/// Custom painter for the background star field
class StarFieldPainter extends CustomPainter {
  final double twinkleAnimation;
  final double rotationAnimation;

  StarFieldPainter({
    required this.twinkleAnimation,
    required this.rotationAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate background stars
    final random = math.Random(42); // Fixed seed for consistent star field
    final starCount = 150;

    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinklePhase = random.nextDouble() * 2 * math.pi;
      final baseAlpha = 0.1 + random.nextDouble() * 0.4;

      final twinkleOffset = math.sin(
        (twinkleAnimation * 2 * math.pi) + twinklePhase,
      );
      final alpha = (baseAlpha + twinkleOffset * 0.3).clamp(0.0, 1.0);

      paint.color = Colors.white.withValues(alpha: alpha);

      final radius = 0.5 + random.nextDouble() * 1.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) {
    return oldDelegate.twinkleAnimation != twinkleAnimation ||
        oldDelegate.rotationAnimation != rotationAnimation;
  }
}

/// Custom painter for drawing constellations
class ConstellationPainter extends CustomPainter {
  final List<ConstellationData> constellations;
  final int? selectedIndex;
  final double rotationAnimation;
  final double twinkleAnimation;
  final double connectionAnimation;

  ConstellationPainter({
    required this.constellations,
    this.selectedIndex,
    required this.rotationAnimation,
    required this.twinkleAnimation,
    required this.connectionAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawConnections(canvas);
    _drawConstellations(canvas);
    _drawLabels(canvas);
  }

  void _drawConnections(Canvas canvas) {
    if (selectedIndex == null) return;

    final selectedConstellation = constellations[selectedIndex!];
    final paint = Paint()
      ..color = _getConstellationColor(selectedIndex!).withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final connectionIndex in selectedConstellation.connections) {
      if (connectionIndex < constellations.length) {
        final targetConstellation = constellations[connectionIndex];

        final path = Path();
        path.moveTo(
          selectedConstellation.position.dx,
          selectedConstellation.position.dy,
        );

        // Create curved connection line
        final controlPoint = Offset(
          (selectedConstellation.position.dx +
                  targetConstellation.position.dx) /
              2,
          (selectedConstellation.position.dy +
                      targetConstellation.position.dy) /
                  2 -
              50,
        );

        path.quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          targetConstellation.position.dx,
          targetConstellation.position.dy,
        );

        // Animate the line drawing
        final pathMetrics = path.computeMetrics();
        for (final pathMetric in pathMetrics) {
          final extractPath = pathMetric.extractPath(
            0.0,
            pathMetric.length * connectionAnimation,
          );
          canvas.drawPath(extractPath, paint);
        }
      }
    }
  }

  void _drawConstellations(Canvas canvas) {
    for (int i = 0; i < constellations.length; i++) {
      final constellation = constellations[i];
      final isSelected = i == selectedIndex;
      final baseColor = _getConstellationColor(i);

      // Draw constellation lines
      _drawConstellationLines(canvas, constellation, baseColor, isSelected);

      // Draw stars
      _drawStars(canvas, constellation, baseColor, isSelected);

      // Draw constellation center
      final centerPaint = Paint()
        ..color = baseColor.withValues(alpha: isSelected ? 0.8 : 0.6)
        ..style = PaintingStyle.fill;

      final centerRadius = isSelected ? 6.0 : 4.0;
      canvas.drawCircle(constellation.position, centerRadius, centerPaint);

      // Draw selection ring
      if (isSelected) {
        final ringPaint = Paint()
          ..color = baseColor.withValues(alpha: 0.4)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        final pulseRadius = 20 + math.sin(twinkleAnimation * 2 * math.pi) * 5;
        canvas.drawCircle(constellation.position, pulseRadius, ringPaint);
      }
    }
  }

  void _drawConstellationLines(
    Canvas canvas,
    ConstellationData constellation,
    Color baseColor,
    bool isSelected,
  ) {
    final paint = Paint()
      ..color = baseColor.withValues(alpha: isSelected ? 0.6 : 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Connect stars in constellation
    final stars = constellation.stars;
    for (int i = 0; i < stars.length - 1; i++) {
      canvas.drawLine(stars[i].position, stars[i + 1].position, paint);
    }

    // Close the constellation
    if (stars.length > 2) {
      canvas.drawLine(stars.last.position, stars.first.position, paint);
    }
  }

  void _drawStars(
    Canvas canvas,
    ConstellationData constellation,
    Color baseColor,
    bool isSelected,
  ) {
    for (final star in constellation.stars) {
      final twinkleOffset = math.sin(
        (twinkleAnimation * 2 * math.pi) + star.twinklePhase,
      );
      final alpha = (star.brightness + twinkleOffset * 0.3).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = baseColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      final radius = star.size * (isSelected ? 1.5 : 1.0);
      canvas.drawCircle(star.position, radius, paint);
    }
  }

  void _drawLabels(Canvas canvas) {
    for (int i = 0; i < constellations.length; i++) {
      final constellation = constellations[i];
      final isSelected = i == selectedIndex;

      if (isSelected) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: constellation.pattern.name,
            style: TextStyle(
              color: _getConstellationColor(i),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        final offset = Offset(
          constellation.position.dx - textPainter.width / 2,
          constellation.position.dy - 40,
        );

        textPainter.paint(canvas, offset);
      }
    }
  }

  Color _getConstellationColor(int index) {
    final colors = [
      const Color(0xFF667eea),
      const Color(0xFFf5576c),
      const Color(0xFF4facfe),
      const Color(0xFF43e97b),
      const Color(0xFFfa709a),
      const Color(0xFF9b59b6),
      const Color(0xFFe67e22),
      const Color(0xFF8e44ad),
      const Color(0xFF3498db),
      const Color(0xFF9c27b6),
      const Color(0xFFf39c12),
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(ConstellationPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.rotationAnimation != rotationAnimation ||
        oldDelegate.twinkleAnimation != twinkleAnimation ||
        oldDelegate.connectionAnimation != connectionAnimation;
  }
}
