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
      accentColor:  AppColors.mainColor,
      // BackGround Colors
      backgroundColor: AppColors.lightGrey,
      scaffoldBackgroundColor: AppColors.white,
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
      fontFamily: "Helvetica",
      appBarTheme: AppBarTheme(
        elevation: 4.0,
        backgroundColor: AppColors.white,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        brightness: Brightness.dark,
        titleTextStyle: _textStyles.blackHeadline2TextStyle(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
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
      accentColor:  AppColors.mainColor,
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
      fontFamily: "Helvetica",
      appBarTheme: AppBarTheme(
        elevation: 4.0,
        backgroundColor: AppColors.darkerGrey,
        iconTheme: IconThemeData(
            color: AppColors.white,
        ),
        titleTextStyle: _textStyles.whiteHeadline2TextStyle(),
        brightness: Brightness.light,
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
