import 'package:get/get.dart';
import 'package:weather_app/controller/network_controller.dart';
import 'package:weather_app/controller/weather_controller.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
    Get.put<WeatherController>(WeatherController(), permanent: true);
  }
}
