class Weather {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final String description;
  final int sunrise;
  final int sunset;
  final int humidity;      // ✅ Added
  final double windSpeed;  // ✅ Added
  final int pressure;      // ✅ Added

  Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.sunrise,
    required this.sunset,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json["name"],
      temperature: (json["main"]["temp"]).toDouble(),
      feelsLike: (json["main"]["feels_like"]).toDouble(),
      description: json["weather"][0]["description"],
      sunrise: json["sys"]["sunrise"],
      sunset: json["sys"]["sunset"],
      humidity: json["main"]["humidity"], // ✅ parse humidity
      windSpeed: (json["wind"]["speed"]).toDouble(), // ✅ parse wind speed
      pressure: json["main"]["pressure"], // ✅ parse pressure
    );
  }
}
