import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:mamba/app/style/AppThemes.dart';
import 'package:mamba/commons/mixins/platform.dart'; // Ensure correct path

class ThemeState extends Equatable {
  final bool isDarkMode;
  final ThemeData themeData;

  const ThemeState({
    required this.isDarkMode,
    required this.themeData,
  });

  @override
  List<Object> get props => [isDarkMode, themeData];
}

class ThemeManager extends Cubit<ThemeState> with PlatformMixin {
  final AppThemes appThemes = AppThemes();

  ThemeManager()
      : super(
          ThemeState(
            isDarkMode: false,
            themeData:
                AppThemes().lightTheme(), // Use your AppThemes class here
          ),
        );

  bool get isDarkMode => state.isDarkMode;

  /*
  Brightness getSystemPreference(BuildContext context) {
    if (isWeb) {
      final isDarkMode =
          html.window.matchMedia('(prefers-color-scheme: dark)').matches;
      return isDarkMode ? Brightness.dark : Brightness.light;
    } else {
      return MediaQuery.of(context).platformBrightness;
    }    
  }
  */

  void toggleTheme(bool isDark) {
    final themeData = isDark ? appThemes.darkTheme() : appThemes.lightTheme();
    emit(
      ThemeState(
        isDarkMode: isDark,
        themeData: themeData,
      ),
    );
  }
}
