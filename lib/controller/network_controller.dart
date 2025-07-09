import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  bool _dialogIsOpen = false;
  bool isLoading = false;

  late Future<void> Function() fetchWeather;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      _updateConnectionStatus(result);
    });
  }

  Future<void> _updateConnectionStatus(
    ConnectivityResult connectivityResult,
  ) async {
    if (connectivityResult == ConnectivityResult.none) {
      if (!_dialogIsOpen) {
        _dialogIsOpen = true;
        Future.delayed(Duration.zero, () {
          showDialog(
            context: Get.context!,
            barrierDismissible: false,
            builder: (ctx) {
              final size = MediaQuery.of(ctx).size;
              return AlertDialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                content: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(76),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withAlpha(38),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            color: Colors.red[400],
                            size: 40,
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            'No Internet Connection',
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Please check your network connection',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 215, 215, 215),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
      }
    } else {
      if (_dialogIsOpen && Get.context != null) {
        Navigator.of(Get.context!).pop();
        _dialogIsOpen = false;
        isLoading = true;
        await fetchWeather();
        isLoading = false;
      }
    }
  }
}
