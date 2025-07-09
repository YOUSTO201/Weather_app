import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const _apiKey = 'b8cd0eb8480c826751045839441ecf8e';
  static Future<Map<String, dynamic>> fetchWeatherByLocation(
    double lat,
    double lon,
  ) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }
}
