import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/air_quality.dart';

class AqiBadge extends StatefulWidget {
  final AirQuality airQuality;
  final VoidCallback onTap;

  const AqiBadge({
    super.key,
    required this.airQuality,
    required this.onTap,
  });

  @override
  State<AqiBadge> createState() => _AqiBadgeState();
}

class _AqiBadgeState extends State<AqiBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Pulse if data is recent (< 15 mins)
    final diff = DateTime.now().difference(widget.airQuality.timestamp);
    if (diff.inMinutes < 15) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AqiBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.airQuality != widget.airQuality) {
      final diff = DateTime.now().difference(widget.airQuality.timestamp);
      if (diff.inMinutes < 15) {
         if (!_controller.isAnimating) _controller.repeat(reverse: true);
      } else {
         _controller.stop();
         _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper for color and label
  ({Color color, String label, Color textColor}) _getAqiStyle(int aqi) {
    switch (aqi) {
      case 1:
        return (color: const Color(0xFF55A84F), label: 'Good', textColor: Colors.white);
      case 2:
        return (color: const Color(0xFFFFD32F), label: 'Fair', textColor: Colors.black87);
      case 3:
        return (color: const Color(0xFFFF7E3D), label: 'Moderate', textColor: Colors.black87);
      case 4:
        return (color: const Color(0xFFD9534F), label: 'Poor', textColor: Colors.white);
      case 5:
        return (color: const Color(0xFF7E0023), label: 'Very Poor', textColor: Colors.white);
      default:
        return (color: Colors.grey, label: '-', textColor: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getAqiStyle(widget.airQuality.aqi);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _controller.isAnimating ? _scaleAnimation.value : 1.0,
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: style.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: style.color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.air, size: 14, color: style.textColor),
              const SizedBox(width: 6),
              Text(
                '${widget.airQuality.aqi}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: style.textColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                style.label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: style.textColor.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
