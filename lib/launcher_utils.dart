import 'dart:async';

import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:launcher_utils/permission_helper.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:launcher_utils/exceptions.dart';

/// Launcher utility class which provides the methods
class LauncherUtils with ChangeNotifier {
  PageController scrollController;
  bool scroll = true;
  int pageCount = 7;
  List<Color> colors = [Colors.black, Colors.black, Colors.black];
  Uint8List wallpaperImage;

  static const _channel = const MethodChannel('launcher_utils/api');
  static const _eventChannel = const EventChannel('launcher_utils/events');

  /// Set [initColors] to true if need to fecth colors during initialization.
  /// Scroll is enabled by default.
  /// Use [enableScroll], [disableScroll], [toggleScroll] to control scrolling.
  /// The [controller] is used for scroll events if provided.
  LauncherUtils({
    PageController controller,
    bool initColors: false,
    bool subscribeWallpaperChanges: false,
    int pageCount,
    Function eventCallback,
  }) {
    if (subscribeWallpaperChanges) onEvent(callback: eventCallback);
    if (initColors) getWallpaperColors();
    scrollController = (controller == null) ? PageController() : controller;
    if (pageCount != null) this.pageCount = pageCount;
  }

  /// On event change execute the [callback].
  /// It recieves an argument [event].
  /// TODO: Give the function a proper type so that it accepts one argument.
  Future<void> onEvent({Function callback}) async {
    _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      print(event);
      developer.log("${event.runtimeType}");
      // notify listeners to only subscribed events
      notifyListeners();
      if (callback != null) callback(event);
    }, onError: (dynamic error) {
      developer.log('Received error', error: error);
    });
  }

  /// Returns whether the wallpaper is supported.
  /// Returns null if API is less than Android M.
  /// This is a wrapper around android's `WallpaperManager.isWallpaperSupported`
  Future<bool> get isWallpaperSupported async {
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
  Future<void> setWallpaper({
    ImageProvider image,
    bool useChooser: false,
  }) async {
    if (image == null) {
      developer.log("requesting to setWallpaper");
      await _channel.invokeMethod('setWallpaper', {"chooser": useChooser});
    } else {
      image.resolve(ImageConfiguration()).addListener(
        ImageStreamListener((img, a) async {
          developer.log(a.toString());
          var data = await img.image.toByteData(format: ui.ImageByteFormat.png);
          // https://stackoverflow.com/a/50121777/8608146
          // TODO: On android side `wallpaperManager.setBitmap` is not perfect
          print("height: ${img.image.height}, width: ${img.image.width}");
          var response = await _channel.invokeMethod(
            'setWallpaper',
            {"image": data.buffer.asUint8List()},
          );

          developer.log(response.toString());
        }),
      );
      // Returns whether setting the wallpaper succeeded
    }
  }

  Future<void> getWallpaperImage({BuildContext context}) async {
    try {
      // TODO: Bug
      // Before setting the wallpaper using the platform channel
      // The minDesiredWidth, minDesiredHeight are being set
      // After the wallpaper changes to live wallpaper the getWallpaper method still sees the same min width and height thus returning the wallpaper as with the dimensions of the previously set wallpaper.
      // This might be a problem as if the wallpaper is changed by any other method than the setWallpaper of this plugin,
      // the getWallpaper would return a wallpaper with wrong dimensions.
      wallpaperImage = await getWallpaper();
      notifyListeners();
      var image = MemoryImage(wallpaperImage);
      image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((img, a) async {
        print("${img.image.width}, ${img.image.height}");
      }));
    } on PermissionDeniedException catch (e) {
      // open settings or show snackbar
      print(e);
      if (context != null) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Permission denied"),
            action: SnackBarAction(
              label: "Grant Permission",
              onPressed: () async {
                // if rejected show snackbar with an action that opens the settings
                final status = await _requestPermissions();
                if (status == PermissionStatusX.doNotAskAgain) {
                  bool isOpened = await PermissionHandler().openAppSettings();
                  print("settings page opened $isOpened");
                  if (!isOpened) {
                    // TODO: Show user that they need to open the settings manually
                  }
                }
              },
            ),
          ),
        );
      }
    } on Exception catch (e) {
      print(e);
      if (context != null) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("$e"),
          ),
        );
      }
    }
  }

  /// Returns the wallpaper as a byte array.
  /// Use [Image.memory] to display it
  Future getWallpaper() async {
    // TODO: Check if permission for external storage is needed
    // For Android < M it's not needed

    // Checking by default for now
    // Check if permission for external storage is granted
    final status = await _requestPermissions();
    if (status != PermissionStatusX.granted) {
      throw PermissionDeniedException("Permission denied by user");
    }
    var image = await _channel.invokeMethod('getWallpaper');
    print(image.runtimeType);
    return image;
  }

  /// Returns the wallpaper colors
  /// Wrapper around android's `WallpaperManager.getWallpaperColors`
  /// Requires min Api 27
  Future<void> getWallpaperColors() async {
    try {
      List data = await _channel.invokeMethod("getColors");
      var prevColors = List<Color>.from(colors);
      colors.clear();
      data.forEach((c) {
        Color col;
        if (c != null) {
          col = Color(c as int);
        }
        colors.add(col);
      });
      // if prev colors not same as colors
      // then notify listeners
      var same = true;
      if (prevColors.length != colors.length) same = false;
      if (same) {
        for (int i = 0; i < prevColors.length; i++) {
          if (prevColors[i] != colors[i]) {
            same = false;
            break;
          }
        }
      }
      developer.log("Colors $colors");
      if (!same) {
        notifyListeners();
        prevColors.clear();
      }
    } on PlatformException catch (e) {
      developer.log("Failed to get Wallpaper colors", error: e);
      notifyListeners();
    }
  }

  void updateScrollEvents() {
    if (scrollController.hasListeners) {
      scrollController.removeListener(performScroll);
    }
    if (scroll) scrollController.addListener(performScroll);
  }

  // Page argument is for the first time
  void performScroll({double page}) {
    // print("${scrollController.page} $pageCount");
    // TODO: Android change WallpaperOffsetSteps
    // This doesn't seem right
    if (page != null) {
      setWallpaperOffsets(page, pageCount);
    } else
      setWallpaperOffsets(scrollController.page, pageCount);
  }

  /// Call this method to enable the wallpaper scroll
  void enableScroll() => scroll = true;

  /// Call this method to disable the wallpaper scroll
  void disableScroll() => scroll = false;

  /// Call this method to toggle the wallpaper scroll
  void toggleScroll() => scroll = !scroll;

  /// Sends a command to live wallpapers so they could receive tap events
  /// Must provide a `PointerDownEvent` or a `TapDownDetails`
  /// which come from `Listener.onPointerDown` and `GestureDetector.onTapDown` respectively
  Future<void> sendWallpaperCommand(
      {PointerDownEvent event, TapDownDetails details}) async {
    print('send data');
    Map<String, double> pos = {'x': 0, 'y': 0};
    assert(event != null || details != null);
    pos['x'] =
        (details != null) ? details.globalPosition.dx : event.position.dx;
    pos['y'] =
        (details != null) ? details.globalPosition.dy : event.position.dy;
    try {
      await _channel.invokeMethod("wallpaperCommand", [pos['x'], pos['y']]);
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

  /// Live Wallpaper chooser
  Future<void> openLiveWallpaperChooser() async {
    try {
      await _channel.invokeMethod('openLiveWallpaperChooser');
    } on PlatformException catch (e) {
      developer.log("Failed to open live wallpaper chooser", error: e);
    }
  }

  /// Returns true if the wallpaper is a live wallpaper
  Future<bool> isLiveWallpaper() async {
    try {
      return await _channel.invokeMethod('isLiveWallpaper');
    } on PlatformException catch (e) {
      developer.log("Failed to check if wallpaper is a live wallpaper",
          error: e);
      return false;
    }
  }

  /// Current live Wallpaper settings
  Future<void> openLiveWallpaperSettings() async {
    try {
      await _channel.invokeMethod('openLiveWallpaperSettings');
    } on PlatformException catch (e) {
      developer.log("Failed to open live wallpaper settings", error: e);
    }
  }

  Future<PermissionStatusX> _requestPermissions() async {
    final status = PermissionHelper.requestPermissions(
        TargetPlatform.android, PermissionGroup.storage);
    return status;
  }
}
