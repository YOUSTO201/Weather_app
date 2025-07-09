import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static final String _apiUrl = dotenv.get('API_URL');
  static final String _apiKey = dotenv.get('API_KEY');

  static Future<Map<String, dynamic>> fetchWeatherByLocation(
    double lat,
    double lon,
  ) async {
    final String url =
        '${_apiUrl}weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }
}
