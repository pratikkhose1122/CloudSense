class ForecastItem {
  final DateTime dt;
  final double temp;
  final String icon;
  final String description;
  final double pop;

  ForecastItem({
    required this.dt,
    required this.temp,
    required this.icon,
    required this.description,
    required this.pop,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      dt: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temp: (json['main']['temp'] as num).toDouble(),
      icon: json['weather'][0]['icon'] ?? '',
      description: json['weather'][0]['description'] ?? '',
      pop: (json['pop'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailySummary {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String icon;
  final String description;

  DailySummary({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
    required this.description,
  });
}
