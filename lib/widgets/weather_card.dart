import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather.dart';
import 'glass_container.dart';
import 'liquid_blob.dart';

class WeatherCard extends StatefulWidget {
  final Weather weather;

  const WeatherCard({super.key, required this.weather});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _iconAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getGlowColor(String description) {
    if (description.contains('clear') || description.contains('sun')) {
      return Colors.orangeAccent;
    } else if (description.contains('rain') || description.contains('drizzle')) {
      return Colors.lightBlueAccent;
    } else if (description.contains('cloud')) {
      return Colors.white70;
    } else {
      return Colors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = _getGlowColor(widget.weather.description.toLowerCase());
    
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Blob slightly behind the card center for depth
        Positioned(
          top: -20,
          right: -20,
           child: Opacity(
             opacity: 0.6,
             child: LiquidBlob(
              size: 140,
              duration: const Duration(seconds: 8),
              gradient: LinearGradient(
                colors: [glowColor.withOpacity(0.5), glowColor.withOpacity(0.1)],
              ),
            ),
           ),
        ),
        
        GlassContainer(
          borderRadius: 28,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          borderColor: Colors.white.withOpacity(0.2),
          gradient: LinearGradient(
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             colors: [
               Colors.white.withOpacity(0.2),
               Colors.white.withOpacity(0.05),
             ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // City Name
              Text(
                widget.weather.cityName,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 20),
              
              // Animated Icon
              AnimatedBuilder(
                animation: _iconAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _iconAnimation.value),
                    child: child,
                  );
                },
                child: Image.network(
                  'https://openweathermap.org/img/wn/${widget.weather.icon}@4x.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (context, _, __) =>
                      const Icon(Icons.wb_sunny, size: 100, color: Colors.amber),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Temperature
              Text(
                '${widget.weather.temperature.toStringAsFixed(0)}°',
                style: GoogleFonts.poppins(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0, 
                ),
              ),
              
              // Description
              Text(
                widget.weather.description.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  letterSpacing: 3.0,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Details
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDetailChip(
                    context,
                    Icons.water_drop_outlined,
                    '${widget.weather.humidity}%',
                    'Humidity',
                  ),
                  Container(height: 30, width: 1, color: Colors.white24),
                  _buildDetailChip(
                    context,
                    Icons.air,
                    '${widget.weather.windSpeed}',
                    'Wind (km/h)',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(
      BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
