import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/controller/weather_controller.dart';
import 'package:weather_app/helpers/weather_helper.dart';
import 'package:weather_app/services/location.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/widgets/refresh_button.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  TextEditingController _cityController = TextEditingController();
  String _city = 'paris';
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? errorMessage;
  bool searchIcon = true;
  // bool ConectivityResult = false;
  bool isUsingLocation = false;
  Timer? _permissionTimer;

  Future<void> _fetchWeatherData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      Map<String, dynamic>? data;
      if (_city.trim().isNotEmpty) {
        data = await WeatherController.fetchWeather(_city);
      } else {
        final position = await Geolocator.getCurrentPosition();
        data = await WeatherService.fetchWeatherByLocation(
          position.latitude,
          position.longitude,
        );
      }
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _initializeWeather() async {
    if (isUsingLocation || weatherData != null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final position = await LocationHelper.getCurrentLocation(
        context: context,
        fetchWeatherData: _fetchWeatherData,
      );
      final data = await WeatherService.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      setState(() {
        weatherData = data;
        _city = '';
        isUsingLocation = true;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWeather();
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _permissionTimer?.cancel();
    super.dispose();
  }

  Future<void> _searchWeather() async {
    final input = _cityController.text.trim();
    if (input.isEmpty) {
      return;
    }
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    setState(() => isLoading = true);

    try {
      final data = await WeatherController.fetchWeather(input);
      if (data != null) {
        setState(() {
          weatherData = data;
          _city = input;
          isUsingLocation = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('City not found'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.5),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Connection error occurred ⚠️'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.5),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    } finally {
      _cityController.clear();
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(gradient: getWeatherGradient(weatherData)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    width: size.width * 1,
                    height: size.height * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                      color: Colors.black.withAlpha(25),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withAlpha(38),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: size.width * 0.05,
                        top: size.height * 0.04,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Weather App',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.07),
              Padding(
                padding: EdgeInsets.only(
                  left: size.width * 0.04,
                  right: size.width * 0.04,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(25),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        border: Border.all(color: Colors.white.withAlpha(38)),
                      ),
                      child: TextField(
                        controller: _cityController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchWeather(),
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: 'Search for a city...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withAlpha(178),
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: Color.fromARGB(0, 169, 50, 50),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015,
                          ),
                          suffixIcon: IconButton(
                            onPressed: _cityController.text.trim().isEmpty
                                ? null
                                : () async {
                                    await _searchWeather();
                                  },
                            icon: Icon(
                              Icons.search_rounded,
                              color: _cityController.text.trim().isEmpty
                                  ? Colors.white.withAlpha(127)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              weatherData == null
                  ? Container()
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withAlpha(25),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.black.withAlpha(25),
                        disabledForegroundColor: Colors.white.withAlpha(127),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.white.withAlpha(38)),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isUsingLocation
                          ? null
                          : () async {
                              await HapticFeedback.mediumImpact();
                              setState(() => isLoading = true);
                              try {
                                final position =
                                    await LocationHelper.getCurrentLocation(
                                      context: context,
                                      fetchWeatherData: _fetchWeatherData,
                                    );
                                final data =
                                    await WeatherService.fetchWeatherByLocation(
                                      position.latitude,
                                      position.longitude,
                                    );
                                setState(() {
                                  weatherData = data;
                                  _city = '';
                                  isUsingLocation = true;
                                });
                              } catch (e) {}
                              setState(() => isLoading = false);
                            },
                      icon: Icon(Icons.my_location),
                      label: Text('Use My Current Location'),
                    ),
              SizedBox(height: size.height * 0.03),
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    width: size.width * 0.93,
                    height: size.height * 0.53,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(25),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withAlpha(38)),
                    ),
                    child: isLoading
                        ? Center(
                            child: Lottie.asset(
                              'assets/animation/loading.json',
                              height: size.height * 0.5,
                              width: size.width * 0.4,
                            ),
                          )
                        : weatherData == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: size.width * 0.1,
                                  top: size.height * 0.01,
                                ),
                                child: Text(
                                  'Please Access your location Permission to improve your app experience',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.03),
                              Text(
                                'By pressing this button',
                                style: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 25,
                                ),
                              ),
                              SizedBox(height: size.height * 0.03),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black.withAlpha(25),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.black
                                      .withAlpha(25),
                                  disabledForegroundColor: Colors.white
                                      .withAlpha(127),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                      color: Colors.white.withAlpha(38),
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: isUsingLocation
                                    ? null
                                    : () async {
                                        await HapticFeedback.mediumImpact();
                                        setState(() => isLoading = true);
                                        try {
                                          final position =
                                              await LocationHelper.getCurrentLocation(
                                                context: context,
                                                fetchWeatherData:
                                                    _fetchWeatherData,
                                              );
                                          final data =
                                              await WeatherService.fetchWeatherByLocation(
                                                position.latitude,
                                                position.longitude,
                                              );
                                          setState(() {
                                            weatherData = data;
                                            _city = '';
                                            isUsingLocation = true;
                                          });
                                        } catch (e) {}
                                        setState(() => isLoading = false);
                                      },
                                icon: Icon(Icons.my_location),
                                label: Text('Access Location Permission'),
                              ),
                              SizedBox(height: size.height * 0.03),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: size.width * 0.07,
                                  right: size.width * 0.07,
                                ),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.03,
                                      // right: size.width * 0.01,
                                    ),
                                    child: Text(
                                      'start your search using the top search bar ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.search_rounded,
                                    color: Colors.white.withAlpha(127),
                                    size: 18,
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),
                              Lottie.asset(
                                'assets/animation/loading.json',
                                width: size.width * 0.3,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.02,
                                    ),
                                    child: Row(
                                      children: [
                                        _city.isEmpty
                                            ? Row(
                                                children: [
                                                  Icon(
                                                    Icons.my_location_rounded,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    '${weatherData?['name']}, ${weatherData?['sys']['country']}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on_outlined,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    '${weatherData?['name']}, ${weatherData?['sys']['country']}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ],
                                    ),
                                  ),
                                  Expanded(child: SizedBox()),
                                  RefreshButton(
                                    fetchWeather: _fetchWeatherData,
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              Text(
                                DateFormat(
                                  'EEEE, d MMMM yyyy',
                                ).format(DateTime.now()),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Updated at: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('h:mm a').format(DateTime.now()),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.005),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Image.asset(
                                        getWeatherImage(weatherData),
                                        width: size.width * 0.375,
                                      ),
                                      Text(
                                        '${weatherData?['weather'][0]['description']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 27,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${weatherData?['main']['temp'].round()}°',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 55,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'feels like: ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${weatherData?['main']['feels_like'].round()}°',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size.height * 0.02),
                                      Row(
                                        children: [
                                          Text(
                                            'H:',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${weatherData?['main']['temp_max'].round()}°',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.05),
                                          Text(
                                            'L:',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${weatherData?['main']['temp_min'].round()}°',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
