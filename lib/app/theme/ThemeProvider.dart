import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  // Check if is in Dark Mode
  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  // toogleTheme
  void toggleTheme(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (themeMode == ThemeMode.dark) {
      lightModeStatusAndNavigationBar();
    } else {
      darkModeStatusAndNavigationBar();
    }
    notifyListeners();
  }

  void darkModeStatusAndNavigationBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.black,
        systemNavigationBarDividerColor: AppColors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void lightModeStatusAndNavigationBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.black,
        systemNavigationBarDividerColor: AppColors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}
