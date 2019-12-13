import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:launcher_utils/launcher_utils.dart';
import 'package:launcher_utils/exceptions.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _isWallpaperSupported = 'Unknown';
  // dynamic _bytes;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getWallpaper();
  }

  Future<void> initPlatformState() async {
    String isWallpaperSupported;
    bool supported = await LauncherUtils.isWallpaperSupported;
    if (supported == null) {
      isWallpaperSupported = 'Unknown';
    } else {
      isWallpaperSupported = supported ? "Supported" : "Not Supported";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isWallpaperSupported = isWallpaperSupported;
    });
  }

  Future<void> getWallpaper() async {
    Uint8List bytes;
    try {
      bytes = await LauncherUtils.getWallpaper();
      print(bytes.runtimeType);
    } on PermissionDeniedException catch (e) {
      // open settings or show snackbar
      print(e);
    } on Exception catch (e) {
      print(e);
    }

    if (!mounted) return;
    // setState(() {
    //   // _bytes = bytes;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          // color: Colors.transparent,
          child: Column(
            children: <Widget>[
              Container(
                child: Center(
                  child: Text('Is Wallpaper Supported: $_isWallpaperSupported'),
                ),
              ),
              // (_bytes != null)
              //     ? Image.memory(_bytes)
              //     : CircularProgressIndicator(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            bool isOpened = await PermissionHandler().openAppSettings();
            print("The settings page is open: $isOpened");
          },
          child: Icon(Icons.settings),
        ),
      ),
    );
  }
}
