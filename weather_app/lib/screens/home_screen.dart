import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/weather_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/weather_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String city = "London";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchWeather(city);
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ClimaCast"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchCityBar(onSearch: (value) {
            setState(() {
              city = value;
            });
            weatherProvider.fetchWeather(city);
          }),
          Expanded(
            child: Center(
              child: weatherProvider.weather == null
                  ? const CircularProgressIndicator()
                  : WeatherCard(weather: weatherProvider.weather!),
            ),
          ),
        ],
      ),
    );
  }
}
