import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Star animation widget for background
class StarField extends StatefulWidget {
  final int starCount;
  final Color starColor;
  final double minOpacity;
  final double maxOpacity;

  const StarField({
    super.key,
    this.starCount = 100,
    this.starColor = Colors.white,
    this.minOpacity = 0.3,
    this.maxOpacity = 1.0,
  });

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Initialize stars with random positions and animation delays
    for (int i = 0; i < widget.starCount; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2 + 1,
        animationDelay: _random.nextDouble() * 2,
        animationSpeed: _random.nextDouble() * 0.5 + 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarFieldPainter(
            stars: _stars,
            animationValue: _controller.value,
            starColor: widget.starColor,
            minOpacity: widget.minOpacity,
            maxOpacity: widget.maxOpacity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double animationDelay;
  final double animationSpeed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.animationDelay,
    required this.animationSpeed,
  });
}

class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;
  final Color starColor;
  final double minOpacity;
  final double maxOpacity;

  StarFieldPainter({
    required this.stars,
    required this.animationValue,
    required this.starColor,
    required this.minOpacity,
    required this.maxOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      // Calculate twinkling effect using sine wave with delay
      final normalizedTime =
          (animationValue * star.animationSpeed + star.animationDelay) % 1.0;
      final opacity = minOpacity +
          (maxOpacity - minOpacity) *
              (0.5 + 0.5 * math.sin(normalizedTime * 2 * math.pi));

      final paint = Paint()
        ..color = starColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final x = star.x * size.width;
      final y = star.y * size.height;

      // Draw star as a small circle with optional cross shape for larger stars
      canvas.drawCircle(Offset(x, y), star.size, paint);

      // Add cross shape for larger stars
      if (star.size > 1.5) {
        final crossSize = star.size * 0.8;
        canvas.drawLine(
          Offset(x - crossSize, y),
          Offset(x + crossSize, y),
          paint,
        );
        canvas.drawLine(
          Offset(x, y - crossSize),
          Offset(x, y + crossSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
