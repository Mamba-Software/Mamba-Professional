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
  final double screenHeight;

  ThemeManager({required this.screenHeight})
      : super(ThemeState(
          themeData: ThemeData.light(), // Temporary placeholder
          overlayStyle: SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
          isDarkMode: false,
        )) {
    _setInitialState(screenHeight);
  }

  bool get isDarkMode => state.isDarkMode;

  void _setInitialState(double screenHeight) {
    bool isDarkMode =
        false; // You might want to adjust this based on actual conditions
    final themeData = appThemes.returnResponsiveLightTheme(screenHeight);
    final overlayStyle =
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

    emit(ThemeState(
      themeData: themeData,
      overlayStyle: overlayStyle,
      isDarkMode: isDarkMode,
    ));
  }

  void toggleTheme(bool isDark) {
    final themeData = isDark
        ? appThemes.returnResponsiveDarkTheme(screenHeight)
        : appThemes.returnResponsiveLightTheme(screenHeight);
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
