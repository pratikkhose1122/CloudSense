import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final Gradient? gradient;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final double width;
  final double height;
  final double elevation;
  final Color? shadowColor;

  const GlassContainer({
    super.key,
    this.child,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    this.blur = 12.0,
    this.gradient,
    this.borderColor,
    this.boxShadow,
    this.width = double.infinity,
    this.height = double.infinity,
    this.elevation = 0,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
       width: width == double.infinity ? null : width,
       height: height == double.infinity ? null : height,
       decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ?? [
             BoxShadow(
                color: shadowColor ?? Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
                spreadRadius: 2,
             ),
          ],
       ),
       child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.05),
                    ],
                    stops: const [0.1, 1.0],
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
