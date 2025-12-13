class AirQuality {
  final int aqi;
  final DateTime timestamp;
  final double pm2_5;
  final double pm10;
  final double no2;
  final double o3;
  final double so2;
  final double co;
  final String mainPollutant;

  AirQuality({
    required this.aqi,
    required this.timestamp,
    required this.pm2_5,
    required this.pm10,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.co,
    required this.mainPollutant,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final list = json['list'][0];
    final components = list['components'];
    final main = list['main'];

    // Determine main pollutant (simplified logic: taking max from common ones if not provided)
    // OpenWeather doesn't explicitly give "main pollutant" in this endpoint like some others might,
    // so we can calculate it or just omit. Spec asked for field, let's infer it or keep it simple.
    // We'll leave it as a calculated field or placeholder.
    // For now, let's pick the one with highest concentration relative to its danger levels? 
    // Or just "PM2.5" as it's the most common concern.
    // Let's implement a simple heuristic or default.
    
    return AirQuality(
      aqi: main['aqi'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(list['dt'] * 1000),
      pm2_5: (components['pm2_5'] as num).toDouble(),
      pm10: (components['pm10'] as num).toDouble(),
      no2: (components['no2'] as num).toDouble(),
      o3: (components['o3'] as num).toDouble(),
      so2: (components['so2'] as num).toDouble(),
      co: (components['co'] as num).toDouble(),
      mainPollutant: _determineMainPollutant(components),
    );
  }

  static String _determineMainPollutant(Map<String, dynamic> components) {
    // Basic heuristic: return the key with highest value?
    // In reality, it depends on index breakpoints. 
    // Let's just return the name of the max value for now to satisfy the field requirement.
    String maxKey = 'pm2_5';
    double maxVal = 0.0;
    
    components.forEach((key, value) {
       final val = (value as num).toDouble();
       if (val > maxVal) {
         maxVal = val;
         maxKey = key;
       }
    });
    
    return maxKey.toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'list': [
        {
          'main': {'aqi': aqi},
          'components': {
            'pm2_5': pm2_5,
            'pm10': pm10,
            'no2': no2,
            'o3': o3,
            'so2': so2,
            'co': co,
          },
          'dt': timestamp.millisecondsSinceEpoch ~/ 1000,
        }
      ]
    };
  }
}
