import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// 🌍 Constants
const String baseUrl = "https://api.openweathermap.org/data/2.5";
// ⚠️ Use dotenv or secure storage in production
const String weatherApiKey = "4ca712448a8b43f913119086b935f7a9";

/// 🌦 Weather Model
class Weather {
  final String city;
  final double temperature;
  final String description;

  Weather({
    required this.city,
    required this.temperature,
    required this.description,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: (json["name"] as String?)?.trim().isNotEmpty == true
          ? json["name"]
          : "Unknown",
      temperature: (json["main"]["temp"] as num).toDouble(),
      description: (json["weather"] as List).isNotEmpty
          ? (json["weather"][0]["description"] as String)
          : "N/A",
    );
  }
}

/// 📡 Weather API Service
class WeatherApi {
  Future<Weather> fetchWeatherByCity(String city) async {
    final url = Uri.parse(
        "$baseUrl/weather?q=$city&appid=$weatherApiKey&units=metric");
    try {
      final response =
          await http.get(url).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return Weather.fromJson(
            json.decode(response.body) as Map<String, dynamic>);
      }

      // Helpful error messages for common codes
      if (response.statusCode == 401) {
        throw Exception("Invalid API key (401). Check your key.");
      } else if (response.statusCode == 404) {
        throw Exception("City not found (404). Try another city.");
      } else {
        throw Exception("Request failed (${response.statusCode}).");
      }
    } on SocketException {
      throw Exception("No internet connection.");
    } on FormatException {
      throw Exception("Bad response format from server.");
    }
  }
}

/// 🔄 Provider
class WeatherProvider extends ChangeNotifier {
  final WeatherApi _api = WeatherApi();

  Weather? _weather;
  bool _isLoading = false;
  String? _error;

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather(String city) async {
    if (city.trim().isEmpty) {
      _error = "Please enter a city name.";
      _weather = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.fetchWeatherByCity(city.trim());
      _weather = result;
    } catch (e) {
      _weather = null;
      _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// 🎨 App Theme
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey, brightness: Brightness.dark),
    useMaterial3: true,
  );
}

/// 🏠 Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: "London"); // default city
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("ClimaCast")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) =>
                          context.read<WeatherProvider>().fetchWeather(v),
                      decoration: const InputDecoration(
                        labelText: "Enter City",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<WeatherProvider>()
                        .fetchWeather(_cityController.text),
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Loading
              if (provider.isLoading) const CircularProgressIndicator(),

              // Error
              if (!provider.isLoading && provider.error != null) ...[
                Text(
                  provider.error!,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],

              // Weather data
              if (!provider.isLoading && provider.weather != null)
                _WeatherCard(weather: provider.weather!),

              if (!provider.isLoading &&
                  provider.weather == null &&
                  provider.error == null)
                const Text(
                  "Search for a city to see current weather.",
                  style: TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final Weather weather;
  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(weather.city,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("${weather.temperature.toStringAsFixed(1)} °C",
                style: const TextStyle(
                    fontSize: 40, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              weather.description,
              style:
                  const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🚀 Main App
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClimaCast',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
