import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> getWeather(String city) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null) throw Exception('API Key not found');
    final url = Uri.parse('$_baseUrl?q=$city&units=metric&appid=$apiKey');
    print('Requesting URL: $url'); // Debug print

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      // Decode error message if possible
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load weather');
      } catch (e) {
         if (e.toString().contains('Failed to load weather')) rethrow;
         throw Exception('Failed to load weather: ${response.statusCode}');
      }
    }
  }

  Future<Weather> getWeatherByCoords(double lat, double lon) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null) throw Exception('API Key not found');
    final url = Uri.parse('$_baseUrl?lat=$lat&lon=$lon&units=metric&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load weather');
      } catch (_) {
         throw Exception('Failed to load weather: ${response.statusCode}');
      }
    }
  }
  Future<List<dynamic>> getForecast(String city) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null) throw Exception('API Key not found');
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['list'];
    } else {
       throw Exception('Failed to load forecast');
    }
  }

  Future<List<dynamic>> getForecastByCoords(double lat, double lon) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null) throw Exception('API Key not found');
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['list'];
    } else {
      throw Exception('Failed to load forecast');
    }
  }
}
