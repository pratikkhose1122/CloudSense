import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HourlyPoint {
  final DateTime time;
  final double temp;
  final double? pop;

  HourlyPoint({
    required this.time,
    required this.temp,
    this.pop,
  });
}

class HourlyChart extends StatelessWidget {
  final List<HourlyPoint> points;
  final bool showPrecip;
  final Color lineColor;
  final Color areaColor;

  const HourlyChart({
    super.key,
    required this.points,
    this.showPrecip = true,
    this.lineColor = const Color(0xFF4B6AFF),
    this.areaColor = const Color(0x594B6AFF),
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox();

    double minTemp = points.map((e) => e.temp).reduce((a, b) => a < b ? a : b);
    double maxTemp = points.map((e) => e.temp).reduce((a, b) => a > b ? a : b);
    
    // Add buffer
    minTemp -= 2;
    maxTemp += 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: AspectRatio(
        aspectRatio: 2.0,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: 3, // Show label every ~3 points if crowded
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < points.length) {
                       return Padding(
                         padding: const EdgeInsets.only(top: 8.0),
                         child: Text(
                           DateFormat.j().format(points[index].time),
                           style: GoogleFonts.poppins(
                             color: Colors.white70,
                             fontSize: 10,
                           ),
                         ),
                       );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (points.length - 1).toDouble(),
            minY: minTemp,
            maxY: maxTemp,
            lineBarsData: [
              LineChartBarData(
                spots: points.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.temp);
                }).toList(),
                isCurved: true,
                color: lineColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 3,
                    color: Colors.white,
                    strokeWidth: 1.5,
                    strokeColor: lineColor,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: areaColor.withOpacity(0.3),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => Colors.black54,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final point = points[touchedSpot.x.toInt()];
                    return LineTooltipItem(
                      '${DateFormat.j().format(point.time)}\n',
                      const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      children: [
                        TextSpan(
                          text: '${point.temp.toStringAsFixed(1)}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
