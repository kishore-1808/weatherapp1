import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/weather_model.dart';

class WeatherApi {
  Future<Weather?> fetchWeather(String city) async {
    final url = Uri.parse("$baseUrl/weather?q=$city&appid=$weatherApiKey&units=metric");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }
}
