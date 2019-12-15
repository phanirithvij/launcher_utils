import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:developer' as developer;

import 'package:launcher_utils/launcher_utils.dart';
import 'package:launcher_utils_example/utils.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var launcherApi = LauncherUtils(
    initColors: true,
    pageCount: 8,
    subscribeWallpaperChanges: true,
  );

  @override
  void initState() {
    super.initState();
    launcherApi.updateScrollEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    launcherApi.updateScrollEvents();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildAmoledTheme(),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: HomePage(launcherApi: launcherApi),
        floatingActionButton: FloatButtons(launcherApi: launcherApi),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    Key key,
    @required this.launcherApi,
  }) : super(key: key);

  final LauncherUtils launcherApi;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ColorWidgets(launcherApi: launcherApi),
        GestureDetector(
          child: SizedBox.expand(
            child: Container(
              child: PageView(
                controller: launcherApi.scrollController,
                children: _getPages(launcherApi.pageCount),
              ),
            ),
          ),
          onTapDown: (ev) => launcherApi.sendWallpaperCommand(ev),
        ),
      ],
    );
  }

  List<Widget> _getPages(int pageCount) {
    var pages = <Widget>[];
    for (int i = 0; i < pageCount; i++) {
      pages.add(
        Container(
          child: Center(
            child: Text(
              "Page ${i + 1}",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
      );
    }
    return pages;
  }
}

class FloatButtons extends StatelessWidget {
  const FloatButtons({
    Key key,
    @required this.launcherApi,
  }) : super(key: key);

  final LauncherUtils launcherApi;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          onPressed: () => launcherApi.openLiveWallpaperSettings(),
          child: Icon(Icons.settings_brightness),
        ),
        SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () => LauncherUtils.getWallpaper(),
          child: Icon(Icons.wallpaper),
        ),
        SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () => launcherApi.openLiveWallpaperChooser(),
          child: Icon(Icons.image),
        ),
        SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () => LauncherUtils.setWallpaper(useChooser: true),
          // onPressed: () {
          //   LauncherUtils.setWallpaper(image: AssetImage("assets/test.jpg"));
          // },
          child: Icon(Icons.photo_size_select_actual),
        ),
        SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () async {
            bool isOpened = await PermissionHandler().openAppSettings();
            developer.log("The settings page is open: $isOpened");
          },
          child: Icon(Icons.settings),
        ),
        SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () {
            launcherApi.getWallpaperColors();
          },
          child: Icon(Icons.palette),
        ),
      ],
    );
  }
}

class ColorWidgets extends StatelessWidget {
  const ColorWidgets({
    Key key,
    @required this.launcherApi,
  }) : super(key: key);

  final LauncherUtils launcherApi;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: 100,
            height: 100,
            color: launcherApi.colors[0],
          ),
          Container(
            width: 100,
            height: 100,
            color: launcherApi.colors[1],
          ),
          Container(
            width: 100,
            height: 100,
            color: launcherApi.colors[2],
          ),
        ],
      ),
    );
  }
}
