import 'dart:async';

import 'package:flutter/services.dart';

export 'component_builder.dart';
export 'presenter_builder.dart';
export 'mvvm_model.dart';

class MvvmBuilder {
  static const MethodChannel _channel = const MethodChannel('mvvm_builder');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
