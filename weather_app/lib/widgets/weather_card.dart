import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(weather.cityName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("${weather.temperature.toStringAsFixed(1)} °C",
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(weather.description,
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            Text("Humidity: ${weather.humidity}%"),
          ],
        ),
      ),
    );
  }
}
