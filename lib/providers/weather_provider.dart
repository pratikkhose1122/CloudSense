import 'package:flutter/foundation.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  bool _loading = false;
  String? _error;

  Weather? get weather => _weather;
  bool get loading => _loading;
  String? get error => _error;

  List<ForecastItem> _hourly = [];
  List<DailySummary> _daily = [];

  List<ForecastItem> get hourly => _hourly;
  List<DailySummary> get daily => _daily;

  Future<void> search(String city) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _weatherService.getWeather(city);
      await _fetchForecastByCity(city);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _weather = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> searchByCoords(double lat, double lon) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _weatherService.getWeatherByCoords(lat, lon);
      await _fetchForecastByCoords(lat, lon);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _weather = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchForecastByCity(String city) async {
    try {
      final list = await _weatherService.getForecast(city);
      _processForecastData(list);
    } catch (e) {
      print('Forecast error: $e');
      // Non-critical, just empty forecast
      _hourly = [];
      _daily = [];
    }
  }

  Future<void> _fetchForecastByCoords(double lat, double lon) async {
    try {
      final list = await _weatherService.getForecastByCoords(lat, lon);
      _processForecastData(list);
    } catch (e) {
      print('Forecast error: $e');
      _hourly = [];
      _daily = [];
    }
  }

  void _processForecastData(List<dynamic> list) {
    _hourly = list.take(8).map((e) => ForecastItem.fromJson(e)).toList();

    // Aggregate daily
    final Map<String, List<ForecastItem>> grouped = {};
    for (var item in list) {
      final forecast = ForecastItem.fromJson(item);
      final key = '${forecast.dt.year}-${forecast.dt.month}-${forecast.dt.day}';
      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(forecast);
    }

    _daily = grouped.entries.map((e) {
      final items = e.value;
      final date = items.first.dt;
      double min = items.first.temp;
      double max = items.first.temp;
      
      // Simple logic: taking icon of the middle of the day (noon) if available
      String icon = items[items.length ~/ 2].icon;
      String desc = items[items.length ~/ 2].description;

      for (var i in items) {
        if (i.temp < min) min = i.temp;
        if (i.temp > max) max = i.temp;
      }

      return DailySummary(
        date: date,
        minTemp: min,
        maxTemp: max,
        icon: icon,
        description: desc,
      );
    }).skip(1).take(5).toList(); // Skip today (usually partial), take next 5
  }
}
