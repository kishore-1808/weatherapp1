import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const String _apiKey = "4ca712448a8b43f913119086b935f7a9"; // your OpenWeatherMap API key
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  // ✅ Fetch weather by city name
  Future<Weather> fetchWeather(String city) async {
    final url = Uri.parse("$_baseUrl?q=$city&appid=$_apiKey&units=metric");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  // ✅ Fetch weather by GPS (latitude & longitude)
  Future<Weather> fetchWeatherByLocation(double latitude, double longitude) async {
    final url = Uri.parse("$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception("Failed to load weather data by location");
    }
  }
}
