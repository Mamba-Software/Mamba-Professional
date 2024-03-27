import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/app/style/TextStyles.dart';

// Styles contains all the Colors, Themes and TextStyles used in the App.
class AppThemes {
  ThemeData lightTheme() {
    return ThemeData(
      // Primary Colors
      primaryColor: AppColors.black,
      primaryColorDark: AppColors.white,
      primaryColorLight: Colors.grey,
      scaffoldBackgroundColor: AppColors.lightGrey,
      dividerColor: Colors.grey,
      // Brightness
      brightness: Brightness.light,
      // Texts
      textTheme: TextTheme(
        // Headlines for Titles
        displayLarge: textAppColors.blackHeadline1TextStyle(),
        displayMedium: textAppColors.whiteHeadline1TextStyle(),
        // Headline 2 For Subtitles
        displaySmall: textAppColors.blackHeadline2TextStyle(),
        // Body Texts for Descriptions
        bodyLarge: textAppColors.blackBodyText1Style(),
        bodyMedium: textAppColors.blackBodyText2Style(),
        bodySmall: textAppColors.greyBodyTextStyle(),
      ),
      appBarTheme: AppBarTheme(
        elevation: 4.0,
        surfaceTintColor: AppColors.lightGrey,
        backgroundColor: AppColors.lightGrey,
        iconTheme: const IconThemeData(color: Colors.black),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.black,
          systemNavigationBarDividerColor: AppColors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: textAppColors.blackHeadline2TextStyle(),
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
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightGrey,
        surfaceTintColor: AppColors.lightGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.mainColor,
          brightness: Brightness.light,
          background: AppColors.white),
    );
  }

  ThemeData darkTheme() {
    TextStyles textStyles = TextStyles();
    return ThemeData(
      // Primary Colors
      primaryColor: AppColors.white,
      primaryColorDark: AppColors.black,
      scaffoldBackgroundColor: AppColors.darkerGrey,
      dividerColor: Colors.grey,
      // Brightness
      brightness: Brightness.dark,
      // Texts
      textTheme: TextTheme(
        // Headlines for Titles
        displayLarge: textAppColors.whiteHeadline1TextStyle(),
        displayMedium: textAppColors.blackHeadline1TextStyle(),
        // Headline 2 For Subtitles
        displaySmall: textAppColors.whiteHeadline2TextStyle(),
        // Body Texts for Descriptions
        bodyLarge: textAppColors.whiteBodyText1Style(),
        bodyMedium: textAppColors.whiteBodyText2Style(),
        bodySmall: textAppColors.greyBodyTextStyle(),
      ),
      appBarTheme: AppBarTheme(
        elevation: 4.0,
        surfaceTintColor: AppColors.darkerGrey,
        backgroundColor: AppColors.darkerGrey,
        iconTheme: const IconThemeData(
          color: AppColors.white,
        ),
        titleTextStyle: textAppColors.whiteHeadline2TextStyle(),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.black,
          systemNavigationBarDividerColor: AppColors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
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
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkerGrey,
        surfaceTintColor: AppColors.darkerGrey,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      colorScheme: ColorScheme.fromSwatch()
          .copyWith(secondary: AppColors.mainColor, brightness: Brightness.dark)
          .copyWith(background: AppColors.darkGrey),
    );
  }
}
