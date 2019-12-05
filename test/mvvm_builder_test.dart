import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_builder/mvvm_builder.dart';

void main() {
  const MethodChannel channel = MethodChannel('mvvm_builder');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await MvvmBuilder.platformVersion, '42');
  });
}
