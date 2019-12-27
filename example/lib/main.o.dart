import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:developer' as developer;

import 'package:launcher_utils/launcher_utils.dart';
import 'package:launcher_utils_example/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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
  // Initialized in the changeNotifierProvider

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        LauncherUtils launcherApi;
        launcherApi = LauncherUtils(
          initColors: true,
          pageCount: 8,
          subscribeWallpaperChanges: true,
          eventCallback: (event) {
            print('Received an event: $event');
          },
        );
        // Scroll the wallpaper to page 0 immediately
        launcherApi.performScroll(page: 0);
        return launcherApi;
      },
      child: MaterialApp(
        theme: buildAmoledTheme(),
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: Consumer<LauncherUtils>(
            builder: (_, __, ___) => HomePage(),
          ),
          floatingActionButton: FloatButtons(),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Provider.of<LauncherUtils>(context).updateScrollEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // TODO: GestureDetector should be in the last layer of the stack
        // But gestures doesn't work
        GestureDetector(
          child: Container(
            color: Colors.blue[100].withOpacity(0.4),
          ),
          onTapDown: (ev) => Provider.of<LauncherUtils>(context)
              .sendWallpaperCommand(details: ev),
        ),
        IgnorePointer(
          child: Container(
            // color: Colors.blue[100].withOpacity(0.4),
            child: Center(
              child:
                  (Provider.of<LauncherUtils>(context).wallpaperImage != null)
                      ? Image.memory(
                          Provider.of<LauncherUtils>(context).wallpaperImage,
                          height: 200,
                        )
                      : Container(
                          height: 200,
                          color: Colors.pink[100].withOpacity(0.4),
                        ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => print("page view"),
          behavior: HitTestBehavior.translucent,
          child: PageView(
            controller: Provider.of<LauncherUtils>(context).scrollController,
            children: _getPages(Provider.of<LauncherUtils>(context).pageCount),
          ),
        ),
        ColorWidgets(),
      ],
    );
  }

  List<Widget> _getPages(int pageCount) {
    var pages = <Widget>[];
    for (int i = 0; i < pageCount; i++) {
      pages.add(
        Container(
          width: 50,
          height: 60,
          color: Color.fromRGBO(
            Random().nextInt(255),
            Random().nextInt(255),
            Random().nextInt(255),
            .5,
          ),
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
  const FloatButtons({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          onPressed: () =>
              Provider.of<LauncherUtils>(context).openLiveWallpaperSettings(),
          child: Icon(Icons.settings_brightness),
        ),
        FloatingActionButton(
          onPressed: () => Provider.of<LauncherUtils>(context)
              .getWallpaperImage(context: context),
          child: Icon(Icons.wallpaper),
        ),
        FloatingActionButton(
          onPressed: () =>
              Provider.of<LauncherUtils>(context).openLiveWallpaperChooser(),
          child: Icon(Icons.image),
        ),
        FloatingActionButton(
          onPressed: () => Provider.of<LauncherUtils>(context)
              .setWallpaper(useChooser: true),
          // onPressed: () {
          //   LauncherUtils.setWallpaper(
          //       image: AssetImage("assets/images/warrior.jpg"));
          // },
          child: Icon(Icons.photo_size_select_actual),
        ),
        FloatingActionButton(
          onPressed: () async {
            bool isOpened = await PermissionHandler().openAppSettings();
            developer.log("The settings page is open: $isOpened");
          },
          child: Icon(Icons.settings),
        ),
        FloatingActionButton(
          onPressed: () {
            Provider.of<LauncherUtils>(context).getWallpaperColors();
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LauncherUtils>(
      builder: (context, value, _) {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                color: Provider.of<LauncherUtils>(context)
                    .colors[0]
                    ?.withOpacity(0.8),
              ),
              Container(
                width: 50,
                height: 50,
                color: Provider.of<LauncherUtils>(context)
                    .colors[1]
                    ?.withOpacity(0.8),
              ),
              Container(
                width: 50,
                height: 50,
                color: Provider.of<LauncherUtils>(context)
                    .colors[2]
                    ?.withOpacity(0.8),
              ),
              Container(
                width: 50,
                height: 50,
                color: Provider.of<LauncherUtils>(context)
                    .colors[1]
                    ?.withOpacity(0.8),
              ),
              Container(
                width: 50,
                height: 50,
                color: Provider.of<LauncherUtils>(context)
                    .colors[0]
                    ?.withOpacity(0.8),
              ),
            ],
          ),
        );
      },
    );
  }
}
