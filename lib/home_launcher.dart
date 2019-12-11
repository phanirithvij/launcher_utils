import 'dart:async';

import 'package:flutter/services.dart';

class HomeLauncher {
  static const MethodChannel _channel =
      const MethodChannel('home_launcher');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
