import 'dart:async';

import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:launcher_utils/exceptions.dart';

/// Launcher utility class which provides the methods
class LauncherUtils with ChangeNotifier {
  PageController scrollController;
  bool scroll = true;
  int pageCount = 7;

  static const _channel = const MethodChannel('launcher_utils/api');
  static const _eventChannel = const EventChannel('launcher_utils/events');

  /// Set [initColors] to true if need to fecth colors during initialization
  /// Scroll is enabled by default
  /// Use [enableScroll], [disableScroll], [toggleScroll] to control stuff
  /// The [controller] is used for scroll events if provided
  LauncherUtils({
    PageController controller,
    bool initColors: false,
    bool subscribeWallpaperChanges: false,
    int pageCount,
  }) {
    if (subscribeWallpaperChanges)
      onWallpaperChanged(callback: (event) {
        print('Received Wallpaper changed event: $event');
      });
    if (initColors) getWallpaperColors();
    scrollController = (controller == null) ? PageController() : controller;
    if (pageCount != null) this.pageCount = pageCount;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// On wallpaper change execute the [callback]
  /// It recieves an argument [event]
  Future<void> onWallpaperChanged({Function callback}) async {
    _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      notifyListeners();
      if (callback != null) callback(event);
    }, onError: (dynamic error) {
      developer.log('Received error', error: error);
    });
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

  /// Sets the given wallpaper
  /// If no argument is provided, opens the wallpaper chooser
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

  /// Returns the wallpaper colors
  /// Wrapper around android's `WallpaperManager.getWallpaperColors`
  /// Requires min Api 27
  Future<List<Color>> getWallpaperColors() async {
    List<Color> colors = [Colors.black, Colors.black, Colors.black];
    try {
      List data = await _channel.invokeMethod("getColors");
      data.forEach((c) {
        Color col;
        if (c != null) {
          col = Color(c as int);
        }
        colors.add(col);
      });
      developer.log("Colors $colors");
      notifyListeners();
      return colors;
    } on PlatformException catch (e) {
      developer.log("Failed to get Wallpaper colors");
      print(e);
      return [];
    }
  }

  void updateScrollEvents() {
    if (scrollController.hasListeners) {
      scrollController.removeListener(scrollListener);
    }
    if (scroll) scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    // print("${scrollController.page} $pageCount");
    // TODO: Android change WallpaperOffsetSteps
    // This doesn't seem right
    setWallpaperOffsets(scrollController.page, pageCount);
  }

  void enableScroll() => scroll = true;
  void disableScroll() => scroll = false;
  void toggleScroll() => scroll = !scroll;

  /// Sends a command to live wallpapers so they could receive tap events
  Future<void> sendWallpaperCommand(TapDownDetails ev) async {
    try {
      await _channel.invokeMethod(
        "wallpaperCommand",
        [ev.globalPosition.dx, ev.globalPosition.dy],
      );
    } on PlatformException catch (e) {
      developer.log("Failed to send a Wallpaper command", error: e);
    }
  }

  /// Sets the wallpaper offsets
  /// [position] is a double in 0-[numPages]
  /// [numPages] must be >= 1
  Future<void> setWallpaperOffsets(double position, int numPages) async {
    try {
      await _channel.invokeMethod("setWallpaperOffsets", [position, numPages]);
    } on PlatformException catch (e) {
      developer.log("Failed to change wallpaper offsets", error: e);
    }
  }
}
