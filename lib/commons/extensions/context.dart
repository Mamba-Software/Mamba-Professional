import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  // Existing size getter
  Size get size => MediaQuery.of(this).size;

  // MediaQuery data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  // Access to the app theme
  ThemeData get theme => Theme.of(this);
  // Access to the app theme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  // Access to the primary TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Check if the device is a mobile (Assuming width < 600 is a mobile)
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  // Check if the device is a tablet (Assuming width between 600 and 1200 is a tablet)
  bool get isTablet => MediaQuery.of(this).size.width >= 600 && MediaQuery.of(this).size.width < 1200;
  // Check if the device is a desktop (Assuming width >= 1200 is a desktop)
  bool get isDesktop => MediaQuery.of(this).size.width >= 1200;
  
}
