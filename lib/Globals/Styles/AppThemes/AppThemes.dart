import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/WidgetStyles/Text/TextStyles.dart';

// Styles contains all the Colors, Themes and TextStyles used in the App.
class AppThemes {
  ThemeData returnResponsiveLightTheme(double screenHeight) {
    TextStyles textStyles = TextStyles(screenHeight);
    return ThemeData(
      // Primary Colors
      primaryColor: AppColors.black,
      primaryColorDark: AppColors.white,
      primaryColorLight: Colors.grey,
      scaffoldBackgroundColor: AppColors.lightGrey,      
      // Brightness
      brightness: Brightness.light,
      // Texts
      textTheme: TextTheme(
        // Headlines for Titles
        displayLarge: textStyles.blackHeadline1TextStyle(),
        displayMedium: textStyles.whiteHeadline1TextStyle(),
        // Headline 2 For Subtitles
        displaySmall: textStyles.blackHeadline2TextStyle(),
        // Body Texts for Descriptions
        bodyLarge: textStyles.blackBodyText1Style(),
        bodyMedium: textStyles.blackBodyText2Style(),
        bodySmall: textStyles.greyBodyTextStyle(),
      ),
      appBarTheme: AppBarTheme(
        elevation: 4.0,
        surfaceTintColor: AppColors.lightGrey,
        backgroundColor: AppColors.lightGrey,
        iconTheme: const IconThemeData(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: textStyles.blackHeadline2TextStyle(),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: StadiumBorder(), // Customize shape
        backgroundColor: AppColors.mainColor, // Customize color
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 40,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        showUnselectedLabels: false,
        showSelectedLabels: true,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.mainColor,
          brightness: Brightness.light,
          background: AppColors.white),
    );
  }

  ThemeData returnResponsiveDarkTheme(double screenHeight) {
    TextStyles textStyles = TextStyles(screenHeight);
    return ThemeData(
      // Primary Colors
      primaryColor: AppColors.white,
      primaryColorDark: AppColors.black,
      scaffoldBackgroundColor: AppColors.darkerGrey,
      // Brightness
      brightness: Brightness.dark,
      // Texts
      textTheme: TextTheme(
          // Headlines for Titles
          displayLarge: textStyles.whiteHeadline1TextStyle(),
          displayMedium: textStyles.blackHeadline1TextStyle(),
          // Headline 2 For Subtitles
          displaySmall: textStyles.whiteHeadline2TextStyle(),
          // Body Texts for Descriptions
          bodyLarge: textStyles.whiteBodyText1Style(),
          bodyMedium: textStyles.whiteBodyText2Style(),
          bodySmall: textStyles.greyBodyTextStyle()),
      appBarTheme: AppBarTheme(
        elevation: 4.0,
        surfaceTintColor: AppColors.darkerGrey,
        backgroundColor: AppColors.darkerGrey,
        iconTheme: const IconThemeData(
          color: AppColors.white,
        ),
        titleTextStyle: textStyles.whiteHeadline2TextStyle(),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: StadiumBorder(), // Customize shape
        backgroundColor: AppColors.mainColor, // Customize color
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 40,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.darkerGrey,
        showUnselectedLabels: false,
        showSelectedLabels: true,
      ),
      colorScheme: ColorScheme.fromSwatch()
          .copyWith(secondary: AppColors.mainColor, brightness: Brightness.dark)
          .copyWith(background: AppColors.darkGrey),
    );
  }
}
