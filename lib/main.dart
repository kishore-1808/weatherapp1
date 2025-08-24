import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'models/weather.dart';
import 'services/weather_service.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  Weather? _weather;
  bool _isLoading = false;
  String _error = "";
  DateTime? _lastUpdated;
  bool _isCelsius = true;

  /// Favorites
  List<String> _favoriteCities = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _getWeatherByLocation();
  }

  /// Load favorites
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteCities = prefs.getStringList("favorites") ?? [];
    });
  }

  /// Save favorites
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("favorites", _favoriteCities);
  }

  /// Fetch weather
  Future<void> _getWeather([String? city]) async {
    final query = city ?? _cityController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = "";
    });

    try {
      final weather = await _weatherService.fetchWeather(query);
      setState(() {
        _weather = weather;
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _error = "Could not load weather";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fetch weather by GPS
  Future<void> _getWeatherByLocation() async {
    setState(() {
      _isLoading = true;
      _error = "";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")),
        );
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied.")),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Location permissions are permanently denied.")),
        );
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final weather = await _weatherService.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _weather = weather;
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not fetch location weather.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Background color
  Color _getBackgroundColor() {
    if (_weather == null) return Colors.blueGrey;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final isNight = now < _weather!.sunrise || now > _weather!.sunset;

    if (isNight) return Colors.indigo.shade900;
    if (_weather!.description.contains("rain")) return Colors.blueGrey;
    if (_weather!.description.contains("cloud")) return Colors.grey.shade400;
    return Colors.orangeAccent;
  }

  /// Friendly message
  String _getWeatherMessage() {
    if (_weather == null) return "";
    final desc = _weather!.description.toLowerCase();

    if (desc.contains("rain")) return "☔ Don't forget your umbrella!";
    if (desc.contains("cloud")) return "⛅ A bit cloudy today.";
    if (desc.contains("clear")) return "☀ Perfect day to go outside!";
    if (desc.contains("snow")) return "❄ Stay warm, it's snowing!";
    return "🌍 Have a great day!";
  }

  /// Celsius ↔ Fahrenheit
  String _formatTemperature(double tempC) {
    if (_isCelsius) {
      return "${tempC.toStringAsFixed(1)}°C";
    } else {
      final tempF = (tempC * 9 / 5) + 32;
      return "${tempF.toStringAsFixed(1)}°F";
    }
  }

  /// Toggle favorites
  void _toggleFavorite() {
    if (_weather == null) return;
    final city = _weather!.cityName;
    setState(() {
      if (_favoriteCities.contains(city)) {
        _favoriteCities.remove(city);
      } else {
        _favoriteCities.add(city);
      }
    });
    _saveFavorites();
  }

  /// Share current weather
  void _shareWeather() {
    if (_weather == null) return;
    final msg = """
Weather in ${_weather!.cityName}:
Temperature: ${_formatTemperature(_weather!.temperature)}
Feels like: ${_formatTemperature(_weather!.feelsLike)}
Condition: ${_weather!.description}
Humidity: ${_weather!.humidity}%
Wind: ${_weather!.windSpeed} m/s
    """;
    Share.share(msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: const Text("Weather App"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: _getWeatherByLocation,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareWeather,
          ),
          Row(
            children: [
              const Text("°C", style: TextStyle(color: Colors.white)),
              Switch(
                value: !_isCelsius,
                onChanged: (value) {
                  setState(() {
                    _isCelsius = !value;
                  });
                },
                activeColor: Colors.orangeAccent,
              ),
              const Text("°F", style: TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Text("⭐ Favorite Cities",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _favoriteCities.length,
                itemBuilder: (context, index) {
                  final city = _favoriteCities[index];
                  return ListTile(
                    title: Text(city),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _favoriteCities.removeAt(index);
                        });
                        _saveFavorites();
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _getWeather(city);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: "Enter city",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _getWeather,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            if (_weather != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weather!.cityName,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  IconButton(
                    icon: Icon(
                      _favoriteCities.contains(_weather!.cityName)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.yellow,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
              Text(
                _formatTemperature(_weather!.temperature),
                style: const TextStyle(
                    fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                _weather!.description,
                style: const TextStyle(fontSize: 20, color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Text(
                _getWeatherMessage(),
                style: const TextStyle(fontSize: 18, color: Colors.yellowAccent),
              ),
              const SizedBox(height: 10),
              Text(
                "Feels like: ${_formatTemperature(_weather!.feelsLike)}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                "Humidity: ${_weather!.humidity}%",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                "Wind: ${_weather!.windSpeed} m/s",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                "Sunrise: ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(_weather!.sunrise * 1000))}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                "Sunset: ${DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(_weather!.sunset * 1000))}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 15),
              if (_lastUpdated != null)
                Text(
                  "Updated: ${DateFormat('EEE, MMM d, hh:mm a').format(_lastUpdated!)}",
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
