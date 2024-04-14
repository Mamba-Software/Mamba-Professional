import 'dart:io';
import 'package:flutter/foundation.dart';

mixin PlatformMixin {
  bool get isWeb => kIsWeb;

  bool get isAndroid => !isWeb && Platform.isAndroid;

  bool get isIOS => !isWeb && Platform.isIOS;
}
