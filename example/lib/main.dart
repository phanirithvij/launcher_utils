import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        Comment(
            /*
              // TODO: A GestureDetector which sends the wallpaper command should be in the last layer of the stack
              // But won't doesn't work
              // https://github.com/flutter/flutter/issues/47119
              // A workaround for now is to make each page a stack
              // And have a background gesture detector for each page to send the wallpaper command
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (ev) => Provider.of<LauncherUtils>(context)
                    .sendWallpaperCommand(event: ev),
              ),
            */
            ),
        Center(
          child: Container(
            child: (Provider.of<LauncherUtils>(context).wallpaperImage != null)
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
        // IgnorePointer(
        PageView(
          controller: Provider.of<LauncherUtils>(context).scrollController,
          children: _getPages(Provider.of<LauncherUtils>(context).pageCount),
        ),
        ColorWidgets(),
      ],
    );
  }

  List<Widget> _getPages(int pageCount) {
    var pages = <Widget>[];
    for (int i = 0; i < pageCount; i++) {
      pages.add(
        Stack(
          children: <Widget>[
            Listener(
              onPointerDown: (ev) {
                Provider.of<LauncherUtils>(context)
                    .sendWallpaperCommand(event: ev);
              },
              child: Container(color: Colors.transparent),
            ),
            Listener(
              behavior: HitTestBehavior.translucent,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    child: Text(
                      "Page ${i + 1}",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
          // onPressed: () => Provider.of<LauncherUtils>(context)
          //     .setWallpaper(useChooser: true),
          onPressed: () {
            Provider.of<LauncherUtils>(context)
                .setWallpaper(image: AssetImage("assets/images/warrior.jpg"));
          },
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

class Comment extends StatelessWidget {
  // TODO: Make a feature request on vscode to allow multi-line comments to be collapsed from the left side bar
  /// Just an empty container that can be minimized in vs code
  Comment({Key key}) : super(key: key);

  @override
  build(context) => Container(width: 0, height: 0);
}
