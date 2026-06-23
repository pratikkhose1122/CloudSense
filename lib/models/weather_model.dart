/// Weather Model for Kisan Mitra App
/// Represents current weather and forecast data from OpenWeather API
class WeatherModel {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double? rainProbability;
  final double lat;
  final double lon;
  final int conditionCode;
  final List<DailyForecast> dailyForecast;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    this.rainProbability,
    required this.lat,
    required this.lon,
    required this.conditionCode,
    required this.dailyForecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? json;
    final daily = json['daily'] ?? [];

    List<DailyForecast> forecastList = [];
    if (daily is List && daily.isNotEmpty) {
      for (int i = 0; i < daily.length && i < 7; i++) {
        forecastList.add(DailyForecast.fromJson(daily[i]));
      }
    }

    return WeatherModel(
      cityName: json['name'] ?? json['timezone'] ?? 'Unknown',
      temperature: (current['temp'] ?? current['temperature_2m'] ?? 0).toDouble(),
      feelsLike: (current['feels_like'] ?? current['temperature_2m'] ?? 0).toDouble(),
      description: _getWeatherDescription(current['weather']?[0]?['id'] ?? current['weather_code'] ?? 0),
      icon: current['weather']?[0]?['icon'] ?? _getWeatherIcon(current['weather_code'] ?? 0),
      humidity: (current['humidity'] ?? current['relative_humidity_2m'] ?? 0).toInt(),
      windSpeed: (current['wind_speed'] ?? current['wind_speed_10m'] ?? 0).toDouble(),
      rainProbability: current['pop']?.toDouble(),
      lat: (json['coord']?['lat'] ?? json['lat'] ?? 0).toDouble(),
      lon: (json['coord']?['lon'] ?? json['lon'] ?? 0).toDouble(),
      conditionCode: current['weather']?[0]?['id'] ?? current['weather_code'] ?? 0,
      dailyForecast: forecastList,
    );
  }

  static String _getWeatherDescription(int code) {
    if (code == 0) return 'Clear sky';
    if (code >= 1 && code <= 3) return 'Partly cloudy';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code >= 85 && code <= 86) return 'Snow showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    
    // OpenWeather codes
    if (code >= 200 && code < 300) return 'Thunderstorm';
    if (code >= 300 && code < 400) return 'Drizzle';
    if (code >= 500 && code < 600) return 'Rain';
    if (code >= 600 && code < 700) return 'Snow';
    if (code >= 700 && code < 800) return 'Atmosphere';
    if (code == 800) return 'Clear sky';
    if (code > 800) return 'Clouds';
    return 'Unknown';
  }

  static String _getWeatherIcon(int code) {
    // WMO codes
    if (code == 0) return '01d';
    if (code >= 1 && code <= 3) return '02d';
    if (code >= 45 && code <= 48) return '50d';
    if (code >= 51 && code <= 55) return '09d';
    if (code >= 61 && code <= 65) return '10d';
    if (code >= 71 && code <= 77) return '13d';
    if (code >= 80 && code <= 82) return '09d';
    if (code >= 85 && code <= 86) return '13d';
    if (code >= 95 && code <= 99) return '11d';
    return '01d';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
      },
      'weather': [
        {
          'description': description,
          'icon': icon,
          'id': conditionCode,
        }
      ],
      'wind': {'speed': windSpeed},
      'coord': {'lat': lat, 'lon': lon},
      'daily': dailyForecast.map((f) => f.toJson()).toList(),
    };
  }
}

/// Daily Forecast Model
class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String description;
  final String icon;
  final int conditionCode;
  final double? rainProbability;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
    required this.icon,
    required this.conditionCode,
    this.rainProbability,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final temp = json['temp'] ?? {};
    final weather = json['weather'];
    
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      maxTemp: (temp['max'] ?? json['temp_max'] ?? json['temperature_2m_max'] ?? 0).toDouble(),
      minTemp: (temp['min'] ?? json['temp_min'] ?? json['temperature_2m_min'] ?? 0).toDouble(),
      description: weather?[0]?['description'] ?? 'Unknown',
      icon: weather?[0]?['icon'] ?? '01d',
      conditionCode: weather?[0]?['id'] ?? 0,
      rainProbability: json['pop']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': date.millisecondsSinceEpoch ~/ 1000,
      'temp': {'max': maxTemp, 'min': minTemp},
      'weather': [
        {'description': description, 'icon': icon, 'id': conditionCode}
      ],
      'pop': rainProbability,
    };
  }
}
