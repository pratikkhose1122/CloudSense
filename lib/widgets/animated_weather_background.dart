import 'package:flutter/material.dart';

class AnimatedWeatherBackground extends StatefulWidget {
  final String condition;

  const AnimatedWeatherBackground({
    super.key,
    this.condition = 'clear',
  });

  @override
  State<AnimatedWeatherBackground> createState() => _AnimatedWeatherBackgroundState();
}

class _AnimatedWeatherBackgroundState extends State<AnimatedWeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _sunMoonController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
       duration: const Duration(seconds: 40), vsync: this)..repeat();
    _sunMoonController = AnimationController(
       duration: const Duration(seconds: 10), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _sunMoonController.dispose();
    super.dispose();
  }

  List<Color> _getGradient(String condition) {
    switch (condition) {
      case 'clear':
        return [const Color(0xFF56CCF2), const Color(0xFF2F80ED)]; // Bright Blue
      case 'clouds':
        return [const Color(0xFFD7DDE8), const Color(0xFF757F9A)]; // Grey/Blue
      case 'rain':
        return [const Color(0xFF4B6CB7), const Color(0xFF182848)]; // Dark Blue
      case 'snow':
        return [const Color(0xFF83a4d4), const Color(0xFFb6fbff)]; // Icy
      case 'night':
        return [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]; // Navy
      default:
        return [const Color(0xFF56CCF2), const Color(0xFF2F80ED)];
    }
  }
  
  Color _getOverlayColor(String condition) {
    switch (condition) {
      case 'clear': return Colors.orangeAccent.withOpacity(0.06);
      case 'clouds': return Colors.blueGrey.withOpacity(0.06);
      case 'rain': return Colors.indigo.withOpacity(0.08);
      case 'snow': return Colors.white.withOpacity(0.1);
      case 'night': return Colors.indigo.withOpacity(0.12);
      default: return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gradientColors = _getGradient(widget.condition);
    final overlayColor = _getOverlayColor(widget.condition);
    final isNight = widget.condition == 'night';

    return Stack(
      children: [
        // 1. Sky Gradient
        AnimatedContainer(
           duration: const Duration(seconds: 1),
           decoration: BoxDecoration(
             gradient: LinearGradient(
               begin: Alignment.topCenter,
               end: Alignment.bottomCenter,
               colors: gradientColors,
             )
           ),
        ),

        // 2. Sun / Moon
        // 2. Sun / Moon
        Positioned(
          top: 40,
          right: 24,
          child: AnimatedBuilder(
            animation: _sunMoonController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 10 * _sunMoonController.value),
                child: child,
              );
            },
            child: Image.asset(
              isNight ? 'assets/images/moon.png' : 'assets/images/sun.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (_,__,___) => const SizedBox(),
            ),
          ),
        ),

        // 3. Parallax Clouds
        if (widget.condition != 'clear' && widget.condition != 'night') ...[
           // Far Clouds
           _buildParallaxCloud(size.width, 30, 0.4, 'assets/images/cloud_far.png', 0.2),
           // Mid Clouds
           _buildParallaxCloud(size.width, 20, 0.6, 'assets/images/cloud_mid.png', 0.5),
           // Near Clouds
           _buildParallaxCloud(size.width, 15, 0.9, 'assets/images/cloud_near.png', 0.8),
        ],

        // 4. Tint Overlay
        Container(color: overlayColor),
        
        // 5. Vignette
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.5,
              colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              stops: const [0.6, 1.0],
            )
          ),
        ),
      ],
    );
  }

  Widget _buildParallaxCloud(double screenWidth, int durationSec, double opacity, String asset, double alignmentY) {
    return AnimatedBuilder(
       animation: _cloudController,
       builder: (context, child) {
         final percent = (_cloudController.value * (40 / durationSec)) % 1.0;
         final offset = percent * screenWidth * 2 - screenWidth; 
         
         return Positioned(
           top: MediaQuery.of(context).size.height * alignmentY,
           left: offset,
           child: Opacity(
             opacity: opacity,
             child: Image.asset(
               asset,
               width: screenWidth * 0.8, // Slightly smaller than full width to avoid huge blocking
               height: 150, // Fixed height to prevent aspect ratio issues taking up whole screen
               fit: BoxFit.contain,
               repeat: ImageRepeat.noRepeat,
               errorBuilder: (_,__,___) => const SizedBox(),
             ),
           ),
         );
       },
    );
  }
}
