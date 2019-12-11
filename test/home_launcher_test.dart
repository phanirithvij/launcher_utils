import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_launcher/home_launcher.dart';

void main() {
  const MethodChannel channel = MethodChannel('home_launcher');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await HomeLauncher.platformVersion, '42');
  });
}
