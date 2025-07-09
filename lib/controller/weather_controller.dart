import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherController {
  static final String _apiUrl = dotenv.get('API_URL');
  static final String _apiKey = dotenv.get('API_KEY');

  static Future<Map<String, dynamic>?> fetchWeather(String city) async {
    final trimmed = city.trim();

    if (trimmed.isEmpty) {
      HapticFeedback.lightImpact();
      return null;
    }

    HapticFeedback.lightImpact();

    final url = Uri.parse(
      '${_apiUrl}weather?q=$trimmed&appid=$_apiKey&units=metric',
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
