/// Behavioral Dashboard Card - Interactive Pattern Card for Dashboard UI
///
/// PATTERN: Composite + Template Method + Observer Pattern
/// WHERE: Behavioral Patterns feature - Interactive dashboard card component
/// HOW: Creates complex interactive cards with nested components and animations
/// WHY: Provides rich, engaging pattern exploration with Tower Defense theming
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/presentation/themes/app_theme.dart';
import '../controllers/behavioral_patterns_controller.dart';
import '../models/behavioral_pattern_info.dart';

/// Interactive dashboard card for behavioral patterns.
///
/// Features multiple interaction modes and visual states to represent
/// pattern communication flows in Tower Defense context.
class BehavioralDashboardCard extends StatefulWidget {
  final BehavioralPatternInfo pattern;
  final int index;
  final BehavioralPatternsController controller;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const BehavioralDashboardCard({
    super.key,
    required this.pattern,
    required this.index,
    required this.controller,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  State<BehavioralDashboardCard> createState() =>
      _BehavioralDashboardCardState();
}

class _BehavioralDashboardCardState extends State<BehavioralDashboardCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  bool _isHovered = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Start continuous animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredGrid(
      position: widget.index,
      duration: const Duration(milliseconds: 375),
      columnCount: 2,
      child: ScaleAnimation(
        child: FadeInAnimation(
          child: MouseRegion(
            onEnter: (_) => _onHoverEnter(),
            onExit: (_) => _onHoverExit(),
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _hoverAnimation,
                _pulseAnimation,
                _rotationAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _hoverAnimation.value,
                  child: _buildDashboardCard(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard() {
    final CardStyle cardStyle = _getCardStyleFromPattern();

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: _toggleExpanded,
      child: Container(
        height: _isExpanded ? 280 : 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          gradient: cardStyle.gradient,
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: cardStyle.glowColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            _buildBackgroundPattern(cardStyle),
            _buildCardContent(cardStyle),
            _buildInteractionElements(cardStyle),
            if (_isExpanded) _buildExpandedContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern(CardStyle cardStyle) {
    return Positioned.fill(
      child: CustomPaint(
        painter: CommunicationPatternPainter(
          pattern: widget.pattern,
          animationValue: _rotationAnimation.value,
          color: cardStyle.accentColor.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildCardContent(CardStyle cardStyle) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(cardStyle),
          const SizedBox(height: AppTheme.spacingM),
          _buildDescription(),
          const SizedBox(height: AppTheme.spacingM),
          _buildMetrics(cardStyle),
          if (!_isExpanded) const Spacer(),
          if (!_isExpanded) _buildFooter(cardStyle),
        ],
      ),
    );
  }

  Widget _buildHeader(CardStyle cardStyle) {
    return Row(
      children: [
        // Animated pattern icon
        Transform.rotate(
          angle: _rotationAnimation.value * 0.1,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: cardStyle.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              widget.pattern.icon,
              color: cardStyle.accentColor,
              size: 24,
            ),
          ),
        ),

        const SizedBox(width: AppTheme.spacingM),

        // Pattern name and difficulty
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.pattern.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.pattern.difficulty,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cardStyle.accentColor),
              ),
            ],
          ),
        ),

        // Favorite button
        GestureDetector(
          onTap: widget.onFavoriteToggle,
          child: AnimatedScale(
            scale: widget.isFavorite ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? Colors.red : Colors.white60,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.pattern.description,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.8),
      ),
      maxLines: _isExpanded ? null : 2,
      overflow: _isExpanded ? null : TextOverflow.ellipsis,
    );
  }

  Widget _buildMetrics(CardStyle cardStyle) {
    return Row(
      children: [
        _buildMetricChip(
          icon: Icons.speed,
          label: 'Complexity',
          value: widget.pattern.complexity.toStringAsFixed(1),
          color: cardStyle.accentColor,
        ),
        const SizedBox(width: AppTheme.spacingS),
        _buildMetricChip(
          icon: Icons.star,
          label: 'Popular',
          value: widget.pattern.isPopular ? 'Yes' : 'No',
          color: widget.pattern.isPopular ? Colors.amber : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(CardStyle cardStyle) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Tower Defense: ${widget.pattern.communicationType}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cardStyle.accentColor.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          Icons.touch_app,
          size: 16,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  Widget _buildInteractionElements(CardStyle cardStyle) {
    return Positioned(
      top: 8,
      right: 8,
      child: AnimatedOpacity(
        opacity: _isHovered ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cardStyle.accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility, size: 16, color: cardStyle.accentColor),
              const SizedBox(width: 4),
              Icon(Icons.code, size: 16, color: cardStyle.accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Positioned(
      bottom: AppTheme.spacingL,
      left: AppTheme.spacingL,
      right: AppTheme.spacingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Benefits:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: widget.pattern.keyBenefits
                .take(3)
                .map(
                  (benefit) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      benefit,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  CardStyle _getCardStyleFromPattern() {
    switch (widget.pattern.category) {
      case 'Communication Pattern':
        return CardStyle.communication();
      case 'Action Pattern':
        return CardStyle.action();
      case 'Algorithm Pattern':
        return CardStyle.algorithm();
      case 'State Pattern':
        return CardStyle.state();
      case 'Handler Pattern':
        return CardStyle.handler();
      case 'Coordination Pattern':
        return CardStyle.coordination();
      case 'Template Pattern':
        return CardStyle.template();
      case 'Operation Pattern':
        return CardStyle.operation();
      case 'Access Pattern':
        return CardStyle.access();
      case 'State Management':
        return CardStyle.stateManagement();
      case 'Language Pattern':
        return CardStyle.language();
      default:
        return CardStyle.defaultStyle();
    }
  }
}

/// Custom painter for drawing communication patterns in the background
class CommunicationPatternPainter extends CustomPainter {
  final BehavioralPatternInfo pattern;
  final double animationValue;
  final Color color;

  CommunicationPatternPainter({
    required this.pattern,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    switch (pattern.name) {
      case 'Observer':
        _drawObserverPattern(canvas, size, paint);
        break;
      case 'Command':
        _drawCommandPattern(canvas, size, paint);
        break;
      case 'Strategy':
        _drawStrategyPattern(canvas, size, paint);
        break;
      case 'State':
        _drawStatePattern(canvas, size, paint);
        break;
      case 'Chain of Responsibility':
        _drawChainPattern(canvas, size, paint);
        break;
      case 'Mediator':
        _drawMediatorPattern(canvas, size, paint);
        break;
      case 'Template Method':
        _drawTemplatePattern(canvas, size, paint);
        break;
      case 'Visitor':
        _drawVisitorPattern(canvas, size, paint);
        break;
      case 'Iterator':
        _drawIteratorPattern(canvas, size, paint);
        break;
      case 'Memento':
        _drawMementoPattern(canvas, size, paint);
        break;
      case 'Interpreter':
        _drawInterpreterPattern(canvas, size, paint);
        break;
      default:
        _drawDefaultPattern(canvas, size, paint);
        break;
    }
  }

  void _drawObserverPattern(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 4;

    // Central observer
    canvas.drawCircle(center, 8.0, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;

    // Surrounding observers
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + (animationValue * 0.5);
      final offset = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawCircle(offset, 4.0, paint);
      canvas.drawLine(center, offset, paint);
    }
  }

  void _drawCommandPattern(Canvas canvas, Size size, Paint paint) {
    final width = size.width * 0.8;
    final height = size.height * 0.6;
    final startX = (size.width - width) / 2;
    final startY = (size.height - height) / 2;

    for (int i = 0; i < 3; i++) {
      final y = startY + (i * height / 2);
      final progress = (animationValue + i * 0.3) % 1.0;
      final endX = startX + (width * progress);

      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        paint..strokeWidth = 2,
      );

      // Arrow head
      if (progress > 0.8) {
        canvas.drawLine(Offset(endX, y), Offset(endX - 8, y - 4), paint);
        canvas.drawLine(Offset(endX, y), Offset(endX - 8, y + 4), paint);
      }
    }
  }

  void _drawStrategyPattern(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: 60, height: 40);
    canvas.drawRect(rect, paint);

    // Multiple strategy paths
    final paths = [
      Path()
        ..moveTo(rect.right, center.dy)
        ..quadraticBezierTo(
          rect.right + 30,
          rect.top,
          rect.right + 60,
          center.dy,
        ),
      Path()
        ..moveTo(rect.right, center.dy)
        ..lineTo(rect.right + 60, center.dy),
      Path()
        ..moveTo(rect.right, center.dy)
        ..quadraticBezierTo(
          rect.right + 30,
          rect.bottom,
          rect.right + 60,
          center.dy,
        ),
    ];

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  void _drawStatePattern(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final states = [
      Offset(center.dx - 30, center.dy - 20),
      Offset(center.dx + 30, center.dy - 20),
      Offset(center.dx, center.dy + 30),
    ];

    final currentState =
        (animationValue * states.length).floor() % states.length;

    for (int i = 0; i < states.length; i++) {
      final paint = Paint()
        ..color = i == currentState
            ? color.withValues(alpha: 1.0)
            : color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(states[i], 12.0, paint);
    }

    // Transition arrows
    paint.style = PaintingStyle.stroke;
    for (int i = 0; i < states.length; i++) {
      final next = (i + 1) % states.length;
      canvas.drawLine(states[i], states[next], paint);
    }
  }

  void _drawChainPattern(Canvas canvas, Size size, Paint paint) {
    final chainLinks = 5;
    final linkSize = size.width / (chainLinks + 1);

    for (int i = 0; i < chainLinks; i++) {
      final x = linkSize * (i + 1);
      final y = size.height / 2;
      final progress = (animationValue + i * 0.2) % 1.0;

      canvas.drawCircle(
        Offset(x, y),
        8 + (progress * 4),
        paint..style = PaintingStyle.stroke,
      );

      if (i < chainLinks - 1) {
        canvas.drawLine(Offset(x + 8, y), Offset(x + linkSize - 8, y), paint);
      }
    }
  }

  void _drawMediatorPattern(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final mediatorRadius = 12;
    final componentRadius = 6;
    final distance = 50;

    // Central mediator
    canvas.drawCircle(
      center,
      mediatorRadius.toDouble(),
      paint..style = PaintingStyle.fill,
    );

    // Components around mediator
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (animationValue * math.pi * 2);
      final offset = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      canvas.drawCircle(
        offset,
        componentRadius.toDouble(),
        paint..style = PaintingStyle.stroke,
      );
      canvas.drawLine(center, offset, paint..strokeWidth = 1);
    }
  }

  void _drawTemplatePattern(Canvas canvas, Size size, Paint paint) {
    final steps = 4;
    final stepHeight = size.height / (steps + 1);

    for (int i = 0; i < steps; i++) {
      final y = stepHeight * (i + 1);
      final width = size.width * 0.6;
      final x = (size.width - width) / 2;

      final rect = Rect.fromLTWH(x, y - 8, width, 16);
      final progress = ((animationValue * steps) - i).clamp(0.0, 1.0);

      if (progress > 0) {
        canvas.drawRect(rect, paint..style = PaintingStyle.stroke);

        // Fill based on progress
        if (progress < 1.0) {
          final fillRect = Rect.fromLTWH(x, y - 8, width * progress, 16);
          canvas.drawRect(fillRect, paint..style = PaintingStyle.fill);
        }
      }

      // Connection lines
      if (i < steps - 1) {
        canvas.drawLine(
          Offset(size.width / 2, y + 8),
          Offset(size.width / 2, y + stepHeight - 8),
          paint..style = PaintingStyle.stroke,
        );
      }
    }
  }

  void _drawVisitorPattern(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final treeNodes = [
      Offset(center.dx, center.dy - 30),
      Offset(center.dx - 25, center.dy),
      Offset(center.dx + 25, center.dy),
      Offset(center.dx - 40, center.dy + 30),
      Offset(center.dx - 10, center.dy + 30),
      Offset(center.dx + 10, center.dy + 30),
      Offset(center.dx + 40, center.dy + 30),
    ];

    // Draw tree structure
    final connections = [
      [0, 1],
      [0, 2],
      [1, 3],
      [1, 4],
      [2, 5],
      [2, 6],
    ];

    for (final connection in connections) {
      canvas.drawLine(
        treeNodes[connection[0]],
        treeNodes[connection[1]],
        paint..style = PaintingStyle.stroke,
      );
    }

    // Draw nodes
    for (int i = 0; i < treeNodes.length; i++) {
      canvas.drawCircle(treeNodes[i], 6, paint);
    }

    // Draw visitor path
    final visitorProgress = animationValue;
    final currentNode =
        (visitorProgress * treeNodes.length).floor() % treeNodes.length;

    canvas.drawCircle(
      treeNodes[currentNode],
      10,
      paint
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawIteratorPattern(Canvas canvas, Size size, Paint paint) {
    final items = 6;
    final itemWidth = size.width / items;

    for (int i = 0; i < items; i++) {
      final x = itemWidth * i + itemWidth / 2;
      final y = size.height / 2;
      final rect = Rect.fromCenter(center: Offset(x, y), width: 20, height: 20);

      canvas.drawRect(rect, paint..style = PaintingStyle.stroke);

      // Current iterator position
      final iteratorPos = (animationValue * items) % items;
      if (i == iteratorPos.floor()) {
        canvas.drawRect(rect, paint..style = PaintingStyle.fill);
      }
    }

    // Iterator arrow
    final arrowX =
        itemWidth * ((animationValue * items) % items) + itemWidth / 2;
    final arrowY = size.height / 2 - 35;

    canvas.drawLine(
      Offset(arrowX, arrowY),
      Offset(arrowX, arrowY + 10),
      paint..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(arrowX, arrowY + 10),
      Offset(arrowX - 5, arrowY + 5),
      paint,
    );
    canvas.drawLine(
      Offset(arrowX, arrowY + 10),
      Offset(arrowX + 5, arrowY + 5),
      paint,
    );
  }

  void _drawMementoPattern(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final snapshots = 5;
    final snapshotSpacing = size.width / snapshots;

    for (int i = 0; i < snapshots; i++) {
      final x = snapshotSpacing * i + snapshotSpacing / 2;
      final rect = Rect.fromCenter(
        center: Offset(x, center.dy),
        width: 25,
        height: 35,
      );

      final isActive = ((animationValue * snapshots).floor() % snapshots) == i;

      canvas.drawRect(
        rect,
        paint
          ..style = isActive ? PaintingStyle.fill : PaintingStyle.stroke
          ..color = isActive ? color : color.withValues(alpha: 0.5),
      );

      // Timestamp line
      canvas.drawLine(
        Offset(x, rect.bottom + 5),
        Offset(x, rect.bottom + 15),
        paint..strokeWidth = 1,
      );
    }
  }

  void _drawInterpreterPattern(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);

    // Grammar tree
    final nodes = [
      Offset(center.dx, center.dy - 25), // Expression
      Offset(center.dx - 30, center.dy), // Term
      Offset(center.dx + 30, center.dy), // Operator
      Offset(center.dx - 45, center.dy + 25), // Number
      Offset(center.dx - 15, center.dy + 25), // Variable
      Offset(center.dx + 15, center.dy + 25), // Plus
      Offset(center.dx + 45, center.dy + 25), // Minus
    ];

    // Draw connections
    final connections = [
      [0, 1],
      [0, 2],
      [1, 3],
      [1, 4],
      [2, 5],
      [2, 6],
    ];

    for (final connection in connections) {
      canvas.drawLine(
        nodes[connection[0]],
        nodes[connection[1]],
        paint..style = PaintingStyle.stroke,
      );
    }

    // Draw nodes with interpretation progress
    for (int i = 0; i < nodes.length; i++) {
      final progress = ((animationValue * nodes.length) - i).clamp(0.0, 1.0);
      final alpha = progress > 0 ? 1.0 : 0.3;

      canvas.drawCircle(
        nodes[i],
        8,
        paint
          ..color = color.withValues(alpha: alpha)
          ..style = progress > 0 ? PaintingStyle.fill : PaintingStyle.stroke,
      );
    }
  }

  void _drawDefaultPattern(Canvas canvas, Size size, Paint paint) {
    // Draw a simple network pattern
    final center = Offset(size.width / 2, size.height / 2);
    final nodes = 6;
    final radius = math.min(size.width, size.height) / 3;

    for (int i = 0; i < nodes; i++) {
      final angle = (i * 2 * math.pi / nodes) + (animationValue * math.pi);
      final offset = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      canvas.drawCircle(offset, 6, paint);

      if (i < nodes - 1) {
        final nextAngle =
            ((i + 1) * 2 * math.pi / nodes) + (animationValue * math.pi);
        final nextOffset = Offset(
          center.dx + math.cos(nextAngle) * radius,
          center.dy + math.sin(nextAngle) * radius,
        );
        canvas.drawLine(offset, nextOffset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CommunicationPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Card styling configuration for different behavioral pattern categories
class CardStyle {
  final Gradient gradient;
  final Color accentColor;
  final Color glowColor;

  const CardStyle({
    required this.gradient,
    required this.accentColor,
    required this.glowColor,
  });

  factory CardStyle.communication() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF667eea).withValues(alpha: 0.3),
        const Color(0xFF764ba2).withValues(alpha: 0.3),
      ],
    ),
    accentColor: const Color(0xFF667eea),
    glowColor: const Color(0xFF667eea),
  );

  factory CardStyle.action() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFf093fb).withValues(alpha: 0.3),
        const Color(0xFFf5576c).withValues(alpha: 0.3),
      ],
    ),
    accentColor: const Color(0xFFf5576c),
    glowColor: const Color(0xFFf5576c),
  );

  factory CardStyle.algorithm() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF4facfe).withValues(alpha: 0.3),
        const Color(0xFF00f2fe).withValues(alpha: 0.3),
      ],
    ),
    accentColor: const Color(0xFF4facfe),
    glowColor: const Color(0xFF4facfe),
  );

  factory CardStyle.state() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF43e97b).withValues(alpha: 0.3),
        const Color(0xFF38f9d7).withValues(alpha: 0.3),
      ],
    ),
    accentColor: const Color(0xFF43e97b),
    glowColor: const Color(0xFF43e97b),
  );

  factory CardStyle.handler() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFfa709a).withValues(alpha: 0.3),
        const Color(0xFFfee140).withValues(alpha: 0.3),
      ],
    ),
    accentColor: const Color(0xFFfa709a),
    glowColor: const Color(0xFFfa709a),
  );

  factory CardStyle.coordination() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFa8edea).withValues(alpha: 0.3),
        const Color(0xFFfed6e3).withValues(alpha: 0.3),
      ],
    ),
    accentColor: const Color(0xFF9b59b6),
    glowColor: const Color(0xFF9b59b6),
  );

  factory CardStyle.template() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFffecd2).withValues(alpha: 0.3),
        const Color(0xFFfcb69f).withValues(alpha: 0.3),
      ],
    ),
    accentColor: const Color(0xFFe67e22),
    glowColor: const Color(0xFFe67e22),
  );

  factory CardStyle.operation() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFd299c2).withValues(alpha: 0.3),
        const Color(0xFFfef9d7).withValues(alpha: 0.3),
      ],
    ),
    accentColor: const Color(0xFF8e44ad),
    glowColor: const Color(0xFF8e44ad),
  );

  factory CardStyle.access() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF89f7fe).withValues(alpha: 0.3),
        const Color(0xFF66a6ff).withValues(alpha: 0.3),
      ],
    ),
    accentColor: const Color(0xFF3498db),
    glowColor: const Color(0xFF3498db),
  );

  factory CardStyle.stateManagement() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFfc00ff).withValues(alpha: 0.3),
        const Color(0xFF00dbde).withValues(alpha: 0.3),
      ],
    ),
    accentColor: const Color(0xFF9c27b0),
    glowColor: const Color(0xFF9c27b0),
  );

  factory CardStyle.language() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFfdbb2d).withValues(alpha: 0.3),
        const Color(0xFF22c1c3).withValues(alpha: 0.3),
      ],
    ),
    accentColor: const Color(0xFFf39c12),
    glowColor: const Color(0xFFf39c12),
  );

  factory CardStyle.defaultStyle() => CardStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.1),
        Colors.white.withValues(alpha: 0.05),
      ],
    ),
    accentColor: Colors.white,
    glowColor: Colors.white,
  );
}
