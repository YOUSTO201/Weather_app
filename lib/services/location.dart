import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static bool _isFetchingLocation = false;
  static bool _isDialogOpen = false;
  static Timer? _permissionTimer;

  static Future<Position> getCurrentLocation({
    required BuildContext context,
    required Future<void> Function() fetchWeatherData,
  }) async {
    if (_isFetchingLocation) {
      throw Exception("Location fetch already in progress");
    }
    _isFetchingLocation = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final result = await _showLocationServiceDialog(
          context,
          fetchWeatherData,
        );
        if (result != true) {
          throw Exception('Location services are disabled.');
        }
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are still disabled.');
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission was denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final result = await _showLocationPermissionDialog(
          context,
          fetchWeatherData,
        );
        if (result != true) {
          throw Exception('Location permissions are permanently denied.');
        }

        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are still denied.');
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } finally {
      _isFetchingLocation = false;
    }
  }

  static Future<bool?> _showLocationPermissionDialog(
    BuildContext context,
    Future<void> Function() fetchWeatherData,
  ) async {
    if (_isDialogOpen) return null;
    _isDialogOpen = true;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _PermissionDialog(ctx: ctx, fetchWeatherData: fetchWeatherData);
      },
    ).then((value) {
      _isDialogOpen = false;
      return value;
    });
  }

  static Future<bool?> _showLocationServiceDialog(
    BuildContext context,
    Future<void> Function() fetchWeatherData,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _ServiceDialog(ctx: ctx, fetchWeatherData: fetchWeatherData);
      },
    );
  }
}

class _PermissionDialog extends StatelessWidget {
  final BuildContext ctx;
  final Future<void> Function() fetchWeatherData;

  const _PermissionDialog({required this.ctx, required this.fetchWeatherData});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(89),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(51)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.gps_off_rounded,
                  size: 50,
                  color: Colors.orangeAccent,
                ),
                SizedBox(height: size.height * 0.025),
                Text(
                  'Location Permission Required',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Go to :',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Permissions → Location → Allow only while using the app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'to enable location access.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: size.height * 0.032),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        await Geolocator.openAppSettings();
                        await Future.delayed(Duration(seconds: 2));
                        LocationHelper._permissionTimer = Timer.periodic(
                          Duration(seconds: 1),
                          (t) async {
                            final permission =
                                await Geolocator.checkPermission();
                            if (permission != LocationPermission.denied &&
                                permission !=
                                    LocationPermission.deniedForever) {
                              if (context.mounted &&
                                  Navigator.of(ctx).canPop()) {
                                Navigator.of(ctx).pop(true);
                              }
                              LocationHelper._permissionTimer?.cancel();
                            }
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Open Settings'),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        fetchWeatherData();
                        Navigator.of(ctx).pop(false);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.025),
                Text(
                  'Note: If you cancel, a random location will be used instead, which may not reflect your actual position. For a better experience, please enable full location access.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceDialog extends StatefulWidget {
  final BuildContext ctx;
  final Future<void> Function() fetchWeatherData;

  const _ServiceDialog({required this.ctx, required this.fetchWeatherData});

  @override
  State<_ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<_ServiceDialog> {
  bool _checking = false;
  Timer? _serviceTimer;

  @override
  void dispose() {
    _serviceTimer?.cancel();
    super.dispose();
  }

  Future<void> _openLocationSettingsAndCheck() async {
    if (_checking) return;
    setState(() => _checking = true);
    await Geolocator.openLocationSettings();
    if (mounted) {
      setState(() => _checking = false);
    }
    _serviceTimer?.cancel();
    _serviceTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (enabled && mounted && Navigator.of(context).canPop()) {
        timer.cancel();
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(51)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off, size: 50, color: Colors.redAccent),
                  SizedBox(height: size.height * 0.025),
                  Text(
                    'Location Services Disabled',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  const Text(
                    'Please enable location services from settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: size.height * 0.031),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _checking
                            ? null
                            : _openLocationSettingsAndCheck,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _checking
                            ? SizedBox(
                                width: size.width * 0.025,
                                height: size.height * 0.025,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Open Settings'),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          // widget.fetchWeatherData();
                          Navigator.of(widget.ctx).pop(false);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.025),
                  Text(
                    'Note: If you cancel, a random location will be used instead, which may not reflect your actual position. For a better experience, please enable full location access.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
