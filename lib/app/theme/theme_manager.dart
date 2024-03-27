import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba/app/theme/AppThemes.dart'; // Ensure correct path

class ThemeState extends Equatable {
  final ThemeData themeData;
  final SystemUiOverlayStyle overlayStyle;
  final bool isDarkMode;

  const ThemeState({
    required this.themeData,
    required this.overlayStyle,
    required this.isDarkMode,
  });

  @override
  List<Object> get props => [themeData, overlayStyle, isDarkMode];
}

class ThemeManager extends Cubit<ThemeState> {
  
  final AppThemes appThemes = AppThemes();
  
  ThemeManager() : super(initialTheme());

  bool get isDarkMode => state.isDarkMode;

  static ThemeState initialTheme() {
    return ThemeState(
      themeData: ThemeData.light(), // Temporary placeholder
          overlayStyle: SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
          isDarkMode: false,
    );
  }
  
  void setInitialState() {
    bool isDarkMode = false; 
    final themeData = appThemes.returnResponsiveLightTheme();
    final overlayStyle = SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);
    emit(ThemeState(
      themeData: themeData,
      overlayStyle: overlayStyle,
      isDarkMode: isDarkMode,
    ));
  }

  void toggleTheme(bool isDark) {
    final themeData = isDark
        ? appThemes.returnResponsiveDarkTheme()
        : appThemes.returnResponsiveLightTheme();
    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light
            .copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.dark
            .copyWith(statusBarColor: Colors.transparent);

    emit(ThemeState(
      themeData: themeData,
      overlayStyle: overlayStyle,
      isDarkMode: isDark,
    ));
  }
}
