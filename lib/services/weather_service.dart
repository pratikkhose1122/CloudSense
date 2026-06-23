import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/weather_model.dart';

/// Weather Service for Kisan Mitra App
/// Handles weather data fetching from OpenWeather API and location services
class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _oneCallUrl = 'https://api.openweathermap.org/data/3.0/onecall';
  
  // Replace with your OpenWeather API key
  static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY';

  /// Request location permission and get current position
  Future<Position?> getCurrentPosition() async {
    try {
      // Check location permission
      PermissionStatus permission = await Permission.location.status;
      
      if (permission.isDenied) {
        permission = await Permission.location.request();
        if (permission.isDenied) {
          return null;
        }
      }
      
      if (permission.isPermanentlyDenied) {
        return null;
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      return position;
    } catch (e) {
      throw Exception('Location error: $e');
    }
  }

  /// Fetch weather data by coordinates
  Future<WeatherModel> getWeatherByCoords(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Fetch 7-day forecast
        final forecastData = await _getForecastByCoords(lat, lon);
        data['daily'] = forecastData;
        
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Weather fetch error: $e');
    }
  }

  /// Fetch weather by city name
  Future<WeatherModel> getWeatherByCity(String city) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$city&units=metric&appid=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lat = (data['coord']['lat'] as num).toDouble();
        final lon = (data['coord']['lon'] as num).toDouble();
        
        // Fetch 7-day forecast
        final forecastData = await _getForecastByCoords(lat, lon);
        data['daily'] = forecastData;
        
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('City not found');
      }
    } catch (e) {
      throw Exception('Weather fetch error: $e');
    }
  }

  /// Get 7-day forecast by coordinates
  Future<List<dynamic>> _getForecastByCoords(double lat, double lon) async {
    try {
      // Using 5-day forecast API (free tier) - returns 3-hour intervals
      final url = Uri.parse(
        '$_baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['list'] as List;
        
        // Group by day and get daily min/max
        Map<String, Map<String, dynamic>> dailyData = {};
        
        for (var item in list) {
          final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final dateKey = '${date.year}-${date.month}-${date.day}';
          
          if (!dailyData.containsKey(dateKey)) {
            dailyData[dateKey] = {
              'dt': item['dt'],
              'temp_max': item['main']['temp_max'],
              'temp_min': item['main']['temp_min'],
              'weather': item['weather'],
              'pop': item['pop'] ?? 0,
            };
          } else {
            // Update min/max temps
            if (item['main']['temp_max'] > dailyData[dateKey]!['temp_max']) {
              dailyData[dateKey]!['temp_max'] = item['main']['temp_max'];
            }
            if (item['main']['temp_min'] < dailyData[dateKey]!['temp_min']) {
              dailyData[dateKey]!['temp_min'] = item['main']['temp_min'];
            }
            // Update rain probability if higher
            if ((item['pop'] ?? 0) > dailyData[dateKey]!['pop']) {
              dailyData[dateKey]!['pop'] = item['pop'];
            }
          }
        }
        
        return dailyData.values.toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Get weather icon URL
  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  /// Check if rain is expected in forecast
  Future<bool> isRainExpected(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['list'] as List;
        
        // Check next 24 hours for rain
        for (int i = 0; i < 8 && i < list.length; i++) {
          final weatherId = list[i]['weather'][0]['id'] as int;
          if (weatherId >= 200 && weatherId < 700) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
