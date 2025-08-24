class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
    );
  }
}
