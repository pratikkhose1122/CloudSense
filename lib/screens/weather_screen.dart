import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';

/// Weather Screen - Tab 1
/// Shows current weather, 7-day forecast with GPS support
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return RefreshIndicator(
          onRefresh: () => weatherProvider.refreshWeather(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  _buildSearchBar(weatherProvider),
                  const SizedBox(height: 20),
                  
                  // Error Message
                  if (weatherProvider.error != null)
                    _buildErrorCard(weatherProvider),
                  
                  // Loading Indicator
                  if (weatherProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  
                  // Weather Content
                  if (!weatherProvider.isLoading && weatherProvider.weather != null)
                    _buildWeatherContent(weatherProvider.weather!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(WeatherProvider provider) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search city...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  provider.fetchWeatherWithLocation();
                },
              ),
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () => provider.fetchWeatherWithLocation(),
              tooltip: 'Use current location',
            ),
          ],
        ),
      ),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          provider.fetchWeatherByCity(value);
        }
      },
    );
  }

  Widget _buildErrorCard(WeatherProvider provider) {
    return Card(
      color: AppTheme.errorColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.error!,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            ),
            TextButton(
              onPressed: () => provider.clearError(),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(WeatherModel weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Weather Card
        _buildCurrentWeatherCard(weather),
        const SizedBox(height: 20),
        
        // Weather Details
        _buildWeatherDetails(weather),
        const SizedBox(height: 20),
        
        // 7-Day Forecast
        _buildForecastSection(weather),
      ],
    );
  }

  Widget _buildCurrentWeatherCard(WeatherModel weather) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.primaryLight],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Location
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  weather.cityName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, d MMMM').format(DateTime.now()),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 20),
            
            // Temperature and Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  WeatherService.getWeatherIconUrl(weather.icon),
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.cloud,
                      size: 80,
                      color: Colors.white,
                    );
                  },
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.round()}°C',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      weather.description.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Feels Like
            Text(
              'Feels like ${weather.feelsLike.round()}°C',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetails(WeatherModel weather) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailCard(
            icon: Icons.water_drop_outlined,
            label: 'Humidity',
            value: '${weather.humidity}%',
            color: AppTheme.rainColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDetailCard(
            icon: Icons.air,
            label: 'Wind Speed',
            value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
            color: AppTheme.infoColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDetailCard(
            icon: Icons.umbrella_outlined,
            label: 'Rain Chance',
            value: weather.rainProbability != null 
                ? '${(weather.rainProbability! * 100).round()}%' 
                : 'N/A',
            color: AppTheme.rainColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastSection(WeatherModel weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '7-Day Forecast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weather.dailyForecast.length,
            itemBuilder: (context, index) {
              final forecast = weather.dailyForecast[index];
              return _buildForecastCard(forecast);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForecastCard(DailyForecast forecast) {
    final isToday = DateTime.now().day == forecast.date.day;
    
    return Card(
      margin: const EdgeInsets.only(right: 12),
      elevation: isToday ? 4 : 2,
      color: isToday ? AppTheme.primaryColor.withOpacity(0.1) : null,
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isToday ? 'Today' : DateFormat('EEE').format(forecast.date),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isToday ? AppTheme.primaryColor : null,
              ),
            ),
            const SizedBox(height: 8),
            Image.network(
              WeatherService.getWeatherIconUrl(forecast.icon),
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.cloud, size: 40);
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${forecast.maxTemp.round()}° / ${forecast.minTemp.round()}°',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
