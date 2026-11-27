import 'package:flutter/material.dart';

const String kAppFontFamily = 'Vazirmatn';

abstract class AppTextTheme {
  AppTextTheme._();
  static TextTheme build(TextTheme base, Color onSurface) {
    return base.apply(fontFamily: kAppFontFamily, bodyColor: onSurface, displayColor: onSurface);
  }
}
