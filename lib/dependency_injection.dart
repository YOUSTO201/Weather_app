import 'package:get/instance_manager.dart';
import 'package:weather_app/controller/network_controller.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
