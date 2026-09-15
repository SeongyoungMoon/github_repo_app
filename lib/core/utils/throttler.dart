import 'dart:async';
import 'package:flutter/foundation.dart';

class Throttler {
  final Duration duration;
  bool _isThrottling = false;

  Throttler({this.duration = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    if (_isThrottling) return;

    _isThrottling = true;
    action();

    Timer(duration, () {
      _isThrottling = false;
    });
  }
}