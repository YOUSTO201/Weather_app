import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:weather_app/dependency_injection.dart';
import 'package:weather_app/screens/weather_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  DependencyInjection.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemStatusBarContrastEnforced: false,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}
