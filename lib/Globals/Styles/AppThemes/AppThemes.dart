import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/WidgetStyles/Text/TextStyles.dart';

// Styles contains all the Colors, Themes and TextStyles used in the App.
class AppThemes {

  ThemeData returnResponsiveLightTheme(double screenHeight) {
    TextStyles _textStyles = TextStyles(screenHeight);
    return ThemeData(
      // Primary Colors
      primaryColor: AppColors.black,
      primaryColorDark: AppColors.white,
      primaryColorLight: Colors.grey,
      // Accent Color
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.mainColor, brightness: Brightness.light),
      // BackGround Colors
      backgroundColor: AppColors.white,
      scaffoldBackgroundColor: AppColors.lightGrey,
      // Brightness
      brightness: Brightness.light,
      // Texts
      textTheme: TextTheme(
        // Headlines for Titles
        headline1: _textStyles.blackHeadline1TextStyle(),
        headline2: _textStyles.whiteHeadline1TextStyle(),
        // Headline 2 For Subtitles
        headline3: _textStyles.blackHeadline2TextStyle(),
        // Body Texts for Descriptions
        bodyText1: _textStyles.blackBodyText1Style(),
        bodyText2: _textStyles.blackBodyText2Style(),
        caption: _textStyles.greyBodyTextStyle()
      ),
      appBarTheme: AppBarTheme(
        elevation: 4.0,
        backgroundColor: AppColors.lightGrey,
        iconTheme: const IconThemeData(
            color: Colors.black
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: _textStyles.blackHeadline2TextStyle(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 40,
        type: BottomNavigationBarType.fixed,
        backgroundColor:  AppColors.white,
        showUnselectedLabels: false,
        showSelectedLabels: true,
      ),
    );
  }

  ThemeData returnResponsiveDarkTheme(double screenHeight) {
    TextStyles _textStyles = TextStyles(screenHeight);
    return ThemeData(
      // Primary Colors
      primaryColor: AppColors.white,
      primaryColorDark: AppColors.black,
      // Accent Color
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.mainColor, brightness: Brightness.dark),
      // BackGround Colors
      backgroundColor: AppColors.darkGrey,
      scaffoldBackgroundColor: AppColors.darkerGrey,
      // Brightness
      brightness: Brightness.dark,
      // Texts
      textTheme: TextTheme(
        // Headlines for Titles
        headline1: _textStyles.whiteHeadline1TextStyle(),
        headline2: _textStyles.blackHeadline1TextStyle(),
        // Headline 2 For Subtitles
        headline3: _textStyles.whiteHeadline2TextStyle(),
        // Body Texts for Descriptions
        bodyText1: _textStyles.whiteBodyText1Style(),
        bodyText2: _textStyles.whiteBodyText2Style(),
        caption: _textStyles.greyBodyTextStyle()
      ),
      appBarTheme: AppBarTheme(
        elevation: 4.0,
        backgroundColor: AppColors.darkerGrey,
        iconTheme: const IconThemeData(
            color: AppColors.white,
        ),
        titleTextStyle: _textStyles.whiteHeadline2TextStyle(),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 40,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.darkerGrey,
        showUnselectedLabels: false,
        showSelectedLabels: true,
      ),
    );
  }

}
