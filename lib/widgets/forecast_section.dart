import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';
import 'glass_container.dart';
import 'hourly_chart.dart';

class ForecastSection extends StatelessWidget {
  const ForecastSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.poppins(),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: '3-Hourly'),
              Tab(text: '5-Day'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 320,
            child: TabBarView(
              children: [
                _buildHourlyList(context),
                _buildDailyList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyList(BuildContext context) {
    final hourly = Provider.of<WeatherProvider>(context).hourly;
    if (hourly.isEmpty) {
      return const Center(child: Text('No forecast available', style: TextStyle(color: Colors.white54)));
    }

    final chartPoints = hourly.take(8).map((h) => HourlyPoint(
      time: h.dt,
      temp: h.temp,
      pop: h.pop,
    )).toList();

    return Column(
      children: [
        SizedBox(
          height: 100,
          child: HourlyChart(points: chartPoints),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: hourly.length,
            itemBuilder: (context, index) {
              final item = hourly[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GlassContainer(
                  width: 100,
                  padding: const EdgeInsets.all(12),
                  borderRadius: 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.j().format(item.dt), // 1 PM
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        'https://openweathermap.org/img/wn/${item.icon}.png',
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.cloud, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${item.temp.toStringAsFixed(0)}°',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyList(BuildContext context) {
    final daily = Provider.of<WeatherProvider>(context).daily;
    if (daily.isEmpty) {
      return const Center(child: Text('No forecast available', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: daily.length,
      itemBuilder: (context, index) {
        final item = daily[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GlassContainer(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            borderRadius: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    DateFormat.E().format(item.date), // Mon
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Image.network(
                  'https://openweathermap.org/img/wn/${item.icon}.png',
                  width: 30,
                  height: 30,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.cloud, color: Colors.white, size: 24),
                ),
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '${item.maxTemp.toStringAsFixed(0)}° / ${item.minTemp.toStringAsFixed(0)}°',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
