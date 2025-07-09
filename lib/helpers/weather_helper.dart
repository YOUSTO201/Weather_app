import 'package:flutter/material.dart';

String getWeatherImage(Map<String, dynamic>? weatherData) {
  final condition = weatherData?['weather'][0]['main'] ?? 'Clear';

  switch (condition) {
    case 'Clouds':
      return 'assets/images/cloudy.png';
    case 'Rain':
    case 'Drizzle':
    case 'Showers':
      return 'assets/images/rainy.png';
    case 'Thunderstorm':
      return 'assets/images/thunderstorm.png';
    case 'Snow':
    case 'Sleet':
    case 'Hail':
      return 'assets/images/snowy.png';
    case 'Fog':
      return 'assets/images/foggy.png';
    default:
      return 'assets/images/sunny.png';
  }
}
LinearGradient getWeatherGradient(Map<String, dynamic>? weatherData) {
  final weatherCondition = weatherData?['weather'][0]['main']?.toString() ?? 'Clear';

  switch (weatherCondition) {
    case 'Clear':
      return LinearGradient(
        colors: [
          Color.fromARGB(255, 77, 134, 213),
          Color.fromARGB(255, 24, 65, 135),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'Clouds':
      return LinearGradient(
        colors: [
          Color.fromARGB(255, 160, 178, 196),
          Color.fromARGB(255, 95, 109, 122),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'Rain':
    case 'Fog':
      return LinearGradient(
        colors: [Color(0xFF6D8B9A), Color(0xFF4A6B8A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    case 'Thunderstorm':
      return LinearGradient(
        colors: [Color(0xFF5E6FBE), Color(0xFF3A3D8E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    case 'Snow':
      return LinearGradient(
        colors: [Color(0xFFD4E6F1), Color(0xFFA7C4D9)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    default:
      return LinearGradient(
        colors: [
          Color.fromARGB(255, 77, 134, 213),
          Color.fromARGB(255, 24, 65, 135),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}
