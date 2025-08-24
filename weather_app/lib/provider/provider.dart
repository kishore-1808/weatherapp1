import 'package:flutter/material.dart';
import 'provider.dart';
import 'weather_provider.dart';
// Later you can add forecast_provider.dart, aqi_provider.dart, etc.

class AppProviders {
  static List<SingleChildWidget> get allProviders => [
        ChangeNotifierProvider<WeatherProvider>(
          create: (_) => WeatherProvider(),
        ),
        // Example (future extension):
        // ChangeNotifierProvider<ForecastProvider>(
        //   create: (_) => ForecastProvider(),
        // ),
      ];
}
