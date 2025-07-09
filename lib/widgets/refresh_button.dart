import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RefreshButton extends StatefulWidget {
  final Future<void> Function() fetchWeather;

  const RefreshButton({super.key, required this.fetchWeather});

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton> {
  bool isLoading = false;

  Future<void> _handleRefresh() async {
    isLoading = true;
    await widget.fetchWeather();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
        HapticFeedback.lightImpact();
        _handleRefresh();
      },
      icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 30),
    );
  }
}
