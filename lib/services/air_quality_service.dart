import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/air_quality.dart';

class AirQualityService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/air_pollution';

  Future<AirQuality> fetchByCoords(double lat, double lon) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null) throw Exception('API Key not found');
    final url = Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return AirQuality.fromJson(jsonDecode(response.body));
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load air quality data');
      } catch (_) {
         throw Exception('Failed to load air quality: ${response.statusCode}');
      }
    }
  }
}
