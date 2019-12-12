import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launcher_utils/launcher_utils.dart';

void main() {
  const MethodChannel channel = MethodChannel('launcher_utils');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getWallpaperSupported', () async {
    expect(await LauncherUtils.isWallpaperSupported, true);
  });
}
