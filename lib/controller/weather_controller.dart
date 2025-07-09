import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class WeatherController {
  static Future<Map<String, dynamic>?> fetchWeather(String city) async {
    final trimmed = city.trim();

    if (trimmed.isEmpty) {
      HapticFeedback.lightImpact();
      return null;
    }

    HapticFeedback.lightImpact();

    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$trimmed&appid=b8cd0eb8480c826751045839441ecf8e&units=metric',
    );



    try {
      final response = await http.get(url);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['cod'] == 200) {
        return data;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception("Connection error");
    }
  }
}
