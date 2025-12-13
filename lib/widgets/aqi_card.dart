import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/air_quality.dart';
import 'glass_container.dart';
import 'pollutant_chip.dart';

class AqiCard extends StatelessWidget {
  final AirQuality airQuality;

  const AqiCard({super.key, required this.airQuality});

  Map<String, dynamic> _getAqiInfo(int aqi) {
    switch (aqi) {
      case 1:
        return {'label': 'Good', 'color': Colors.greenAccent, 'advice': 'Air quality is considered satisfactory. Enjoy your outdoor activities.'};
      case 2:
        return {'label': 'Fair', 'color': Colors.yellowAccent, 'advice': 'Air quality is acceptable. Sensitive groups should monitor their health.'};
      case 3:
        return {'label': 'Moderate', 'color': Colors.orangeAccent, 'advice': 'Members of sensitive groups may experience health effects. General public is not likely affected.'};
      case 4:
        return {'label': 'Poor', 'color': Colors.redAccent, 'advice': 'Everyone may begin to experience health effects. Sensitive groups may experience more serious health effects.'};
      case 5:
        return {'label': 'Very Poor', 'color': Colors.purpleAccent, 'advice': 'Health warnings of emergency conditions. The entire population is more likely to be affected.'};
      default:
        return {'label': 'Unknown', 'color': Colors.grey, 'advice': 'No data available.'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _getAqiInfo(airQuality.aqi);
    final color = info['color'] as Color;

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.air, color: Colors.white.withOpacity(0.9)),
                    const SizedBox(width: 8),
                    Text(
                      'Air Quality',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Text(
                    info['label'],
                    style: GoogleFonts.poppins(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${airQuality.aqi}',
                   style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Index',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              info['advice'],
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  PollutantChip(label: 'PM2.5', value: airQuality.pm2_5.toStringAsFixed(1)),
                  const SizedBox(width: 8),
                  PollutantChip(label: 'PM10', value: airQuality.pm10.toStringAsFixed(1)),
                  const SizedBox(width: 8),
                  PollutantChip(label: 'NO2', value: airQuality.no2.toStringAsFixed(1)),
                  const SizedBox(width: 8),
                  PollutantChip(label: 'O3', value: airQuality.o3.toStringAsFixed(1)),
                  const SizedBox(width: 8),
                  PollutantChip(label: 'SO2', value: airQuality.so2.toStringAsFixed(1)),
                  const SizedBox(width: 8),
                  PollutantChip(label: 'CO', value: airQuality.co.toStringAsFixed(1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
