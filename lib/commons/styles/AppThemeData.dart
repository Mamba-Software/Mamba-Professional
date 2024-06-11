import 'package:flutter/material.dart';

class AppThemeData {
  static TextStyle textStyle(
    Color color,
    double fontSize,
    FontWeight fontWeight,
    String fontFamily,
  ) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      overflow: TextOverflow.visible,
    );
  }

  static IconThemeData icon(Color color, double iconSize) {
    return IconThemeData(
      color: color,
      size: iconSize,
    );
  }

  static MaterialStateProperty<Color?> controlColorProperty(Color color) {
    return MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return null;
      }
      if (states.contains(MaterialState.selected)) {
        return color;
      }
      return null;
    });
  }
}
