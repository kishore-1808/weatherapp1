import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_api.dart';

class WeatherProvider extends ChangeNotifier {
  Weather? _weather;
  final WeatherApi _api = WeatherApi();

  Weather? get weather => _weather;

  Future<void> fetchWeather(String city) async {
    _weather = await _api.fetchWeather(city);
    notifyListeners();
  }
}
