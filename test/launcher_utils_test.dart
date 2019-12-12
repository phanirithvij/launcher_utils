import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launcher_utils/launcher_utils.dart';

void main() {
  const MethodChannel channel = MethodChannel('launcher_utils');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await LauncherUtils.platformVersion, '42');
  });
}
