import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiquidBlob extends StatefulWidget {
  final double size;
  final Gradient gradient;
  final Duration duration;

  const LiquidBlob({
    super.key,
    this.size = 200,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.duration = const Duration(seconds: 10),
  });

  @override
  State<LiquidBlob> createState() => _LiquidBlobState();
}

class _LiquidBlobState extends State<LiquidBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
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
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Transform.scale(
            scale: 1.0 + 0.1 * math.sin(_controller.value * 2 * math.pi),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: widget.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.colors.first.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
