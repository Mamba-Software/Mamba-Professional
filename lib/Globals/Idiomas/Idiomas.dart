import 'package:flutter/material.dart';

class Idiomas {
  static final all = [
    const Locale('es', ''),
    const Locale('ca', ''),
  ];

  static String getFlag(String code) {
    switch (code) {
      case 'ca':
        return '🇦🇪';
      case 'en':
      default:
        return '🇪🇸';
    }
  }
}