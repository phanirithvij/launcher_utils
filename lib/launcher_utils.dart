import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:launcher_utils/exceptions.dart';

/// Launcher utility class which provides the methods
class LauncherUtils {
  static const MethodChannel _channel = const MethodChannel('launcher_utils');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Returns whether the wallpaper is supported.
  /// Returns null if API is less than Android M.
  /// This is a wrapper around android's `WallpaperManager.isWallpaperSupported`
  static Future<bool> get isWallpaperSupported async {
    try {
      final bool supported =
          await _channel.invokeMethod('isWallpaperSupported');
      return supported;
    } on PlatformException catch (e) {
      print(e.message);
      return null;
    }
  }

  static Future<void> setWallpaper({ImageProvider image}) async {
    if (image == null) {
      await _channel.invokeMethod('setWallpaper');
    } else {
      // TODO: Convert to bytes and send it
      await _channel.invokeMethod('setWallpaper', image);
      // Returns whether setting the wallpaper succeeded
    }
  }

  /// Returns the wallpaper as a byte array.
  /// Use [Image.memory] to display it
  static Future getWallpaper() async {
    // TODO: Check if permission for external storage is needed
    // For Android < M it's not needed

    // Checking by default for now
    // Check if permission for external storage is granted
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      // If not granted request
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
        // if not granted request
        throw PermissionDeniedException("Permission denied by user");
      }
    }
    var image = await _channel.invokeMethod('getWallpaper');
    print(image.runtimeType);
    return image;
  }
}
