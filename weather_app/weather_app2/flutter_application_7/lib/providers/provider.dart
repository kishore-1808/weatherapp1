import '../providers/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'weather_provider.dart';

class AppProviders {
  static List<SingleChildWidget> get allProviders => [
        ChangeNotifierProvider<WeatherProvider>(
          create: (_) => WeatherProvider(),
        ),
      ];
}
