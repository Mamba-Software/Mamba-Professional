import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba/commons/mixins/color.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/styles/AppThemeData.dart';
import 'package:mamba/commons/constants/constants.dart';

// Styles contains all the Colors, Themes and TextStyles used in the App.
class AppThemes with ColorMixin {
  ThemeData lightTheme([Color? specificHighlghtColor]) {
    // Define Colors
    Color brandColor = specificHighlghtColor ?? AppColors.mamba;
    Color complementaryColor = specificHighlghtColor != null ? complementaryMonochromaticColor(specificHighlghtColor) : AppColors.mamba;
    Color primaryColor = AppColors.black;
    Color primaryColorDark = AppColors.darkerGrey;
    Color primaryColorLight = AppColors.grey;
    Color invertedPrimaryColor = AppColors.white;
    Color disabledColor = AppColors.grey;
    Color dividerColor = Colors.black12;
    Color backgroundColor = AppColors.white;
    Color scaffoldBackgroundColor = AppColors.lightGrey;
    Color successColor = AppColors.green;
    Color errorColor = AppColors.red;

    // Return Theme Data
    return ThemeData(
      // Brightness
      brightness: Brightness.light,
      // Primary Color
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
      primaryColorLight: primaryColorLight,
      // Background Colors
      cardColor: backgroundColor,
      canvasColor: scaffoldBackgroundColor,
      dialogBackgroundColor: backgroundColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      // applyElevationOverlayColor: true -- A boolean that determines whether an overlay color will be applied to indicate elevation for dark themes. This is typically only applied in dark themes.
      // Hint / Divider / Disabled / Unselected
      hintColor: disabledColor,
      dividerColor: dividerColor,
      disabledColor: disabledColor,
      unselectedWidgetColor: disabledColor,
      // Highlight Colors
      highlightColor: complementaryColor,
      indicatorColor: primaryColor,      
      // Button Colors
      splashColor: primaryColor.withOpacity(0.5),
      shadowColor: primaryColor.withOpacity(0.5),
      focusColor: scaffoldBackgroundColor,
      hoverColor: scaffoldBackgroundColor,
      // Color Scheme
      colorScheme: ColorScheme(
        primary: primaryColor,
        secondary: complementaryColor,
        tertiary: brandColor,
        surface: backgroundColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: invertedPrimaryColor,
        onSecondary: AppColors.white,
        onSurface: primaryColor,
        onBackground: primaryColor,
        onError: AppColors.white,
        brightness: Brightness.light,
      ),
      // Text Theme
      textTheme: TextTheme(
        // DISPLAY:
        // - For large, expressive text
        displayLarge: AppThemeData.textStyle(
            primaryColor, display1, FontWeight.w800, displayFontFamily),
        // Headline:
        // - Primary title, more prominent
        // - Secondary title, slightly less prominent
        // - Tertiary title, useful for widget titles or modal headers
        headlineLarge: AppThemeData.textStyle(
          primaryColor,
          headline1,
          FontWeight.w800,
          mainFontFamily,
        ),
        headlineMedium: AppThemeData.textStyle(
          primaryColor,
          headline2,
          FontWeight.w800,
          mainFontFamily,
        ),
        headlineSmall: AppThemeData.textStyle(
          primaryColor,
          headline3,
          FontWeight.w800,
          mainFontFamily,
        ),
        // TITLE
        // - For subtitles under headlines or titles
        // - Smaller subtitles, for less emphasis
        titleLarge: AppThemeData.textStyle(
          primaryColor,
          title1,
          FontWeight.w600,
          mainFontFamily,
        ),
        titleMedium: AppThemeData.textStyle(
          primaryColor,
          body1,
          FontWeight.w600,
          mainFontFamily,
        ),
        titleSmall: AppThemeData.textStyle(
          primaryColor,
          body2,
          FontWeight.w600,
          mainFontFamily,
        ),
        // Text
        // - Main body text, improved for readability
        // - Secondary body text
        // - Tertiary body text
        bodyLarge: AppThemeData.textStyle(
          primaryColor,
          body1,
          FontWeight.w400,
          mainFontFamily,
        ),
        bodyMedium: AppThemeData.textStyle(
          primaryColor,
          body2,
          FontWeight.w400,
          mainFontFamily,
        ),
        bodySmall: AppThemeData.textStyle(
          primaryColor,
          body3,
          FontWeight.w200,
          mainFontFamily,
        ),
        // Label
        // - Same as text but in Grey
        labelLarge: AppThemeData.textStyle(
          disabledColor,
          body1,
          FontWeight.w400,
          mainFontFamily,
        ),
        labelMedium: AppThemeData.textStyle(
          disabledColor,
          body2,
          FontWeight.w400,
          mainFontFamily,
        ),
        labelSmall: AppThemeData.textStyle(
          disabledColor,
          body3,
          FontWeight.w200,
          mainFontFamily,
        ),
      ),
      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleSpacing: 0.0,
        elevation: 4.0,
        scrolledUnderElevation: 2.0,
        foregroundColor: primaryColor,
        backgroundColor: scaffoldBackgroundColor,
        surfaceTintColor: scaffoldBackgroundColor,
        iconTheme: AppThemeData.icon(primaryColor, iconSize),
        actionsIconTheme: AppThemeData.icon(primaryColor, iconSize),
        toolbarTextStyle: AppThemeData.textStyle(
          primaryColor,
          title1,
          FontWeight.w600,
          mainFontFamily,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.black,
          systemNavigationBarDividerColor: AppColors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ), // For light icons on dark background
      ),
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        modalElevation: 4,
        showDragHandle: true,
        dragHandleColor: disabledColor,
        modalBarrierColor: AppColors.lightGrey,
        modalBackgroundColor: AppColors.white,
        backgroundColor: AppColors.lightGrey,
        surfaceTintColor: AppColors.lightGrey,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(borderRadiusSmall)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      // Your other theme configurations
      textSelectionTheme: TextSelectionThemeData(
        selectionColor:
            complementaryColor.withOpacity(0.5), // Color for text selection
        selectionHandleColor:
            complementaryColor, // Color for the handles used to adjust the selection
        // Color for the cursor
      ),
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        hintStyle: AppThemeData.textStyle(
          disabledColor,
          body2,
          FontWeight.w400,
          mainFontFamily,
        ),
        errorStyle: AppThemeData.textStyle(
          errorColor,
          body2,
          FontWeight.w400,
          mainFontFamily,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: disabledColor, width: 0.5),
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      ),
      // Dialog Theme
      dialogTheme: DialogTheme(
        surfaceTintColor: AppColors.lightGrey,
        titleTextStyle: AppThemeData.textStyle(
          primaryColor,
          title1,
          FontWeight.w400,
          mainFontFamily,
        ),
        contentTextStyle: AppThemeData.textStyle(
          primaryColor,
          body2,
          FontWeight.w400,
          mainFontFamily,
        ),
        shape: const StadiumBorder(),
      ),
      // Button Theme
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        layoutBehavior: ButtonBarLayoutBehavior.padded,
        textTheme: ButtonTextTheme.normal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        shape: const StadiumBorder(),
        alignedDropdown: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        iconSize: iconSize,
        enableFeedback: true,
        elevation: 6.0,
        focusElevation: 8.0,
        hoverElevation: 8.0,
        disabledElevation: 0.0,
        highlightElevation: 12.0,
        foregroundColor: AppColors.white,
        backgroundColor: complementaryColor,
        shape: const StadiumBorder(),
      ),
      // CheckBox, Radio, Switch
      checkboxTheme: CheckboxThemeData(
        fillColor: AppThemeData.controlColorProperty(complementaryColor),
      ),
      radioTheme: RadioThemeData(
        fillColor: AppThemeData.controlColorProperty(complementaryColor),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: AppThemeData.controlColorProperty(complementaryColor),
        trackColor: AppThemeData.controlColorProperty(complementaryColor),
      ),
    );
  }

  ThemeData darkTheme([Color? specificHighlghtColor]) {
    // Define Colors
    Color brandColor = specificHighlghtColor ?? AppColors.mamba;
    Color complementaryColor = specificHighlghtColor != null ? complementaryMonochromaticColor(specificHighlghtColor) : AppColors.mamba;
    Color primaryColor = AppColors.white;
    Color primaryColorDark = AppColors.lightGrey;
    Color primaryColorLight = AppColors.grey;
    Color invertedPrimaryColor = AppColors.black;
    Color disabledColor = AppColors.grey;
    Color dividerColor = AppColors.lightGrey;
    Color backgroundColor = AppColors.darkGrey;
    Color scaffoldBackgroundColor = AppColors.darkerGrey;
    Color successColor = AppColors.green;
    Color errorColor = AppColors.red;

    // Return Theme Data
    return ThemeData(
      // Brightness
      brightness: Brightness.light,
      // Primary Color
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
      primaryColorLight: primaryColorLight,
      // Background Colors
      cardColor: backgroundColor,
      canvasColor: scaffoldBackgroundColor,
      dialogBackgroundColor: backgroundColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      applyElevationOverlayColor: true,
      // Hint / Divider / Disabled / Unselected
      hintColor: disabledColor,
      dividerColor: dividerColor,
      disabledColor: disabledColor,
      unselectedWidgetColor: disabledColor,
      // Highlight Colors
      highlightColor: complementaryColor,
      indicatorColor: primaryColor,
      // Button Colors
      splashColor: primaryColor.withOpacity(0.5),
      shadowColor: primaryColor.withOpacity(0.5),
      focusColor: scaffoldBackgroundColor,
      hoverColor: scaffoldBackgroundColor,
      // Color Scheme
      colorScheme: ColorScheme(
        primary: primaryColor,
        secondary: complementaryColor,
        tertiary: brandColor,
        surface: backgroundColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: invertedPrimaryColor,
        onSecondary: AppColors.white,
        onTertiary: AppColors.white,
        onSurface: primaryColor,
        onBackground: primaryColor,
        onError: AppColors.white,
        brightness: Brightness.light,        
      ),
      // Text Theme
      textTheme: TextTheme(
        // DISPLAY:
        // - For large, expressive text
        displayLarge: AppThemeData.textStyle(
            primaryColor, display1, FontWeight.w800, displayFontFamily),
        // Headline:
        // - Primary title, more prominent
        // - Secondary title, slightly less prominent
        // - Tertiary title, useful for widget titles or modal headers
        headlineLarge: AppThemeData.textStyle(
          primaryColor,
          headline1,
          FontWeight.w800,
          mainFontFamily,
        ),
        headlineMedium: AppThemeData.textStyle(
          primaryColor,
          headline2,
          FontWeight.w800,
          mainFontFamily,
        ),
        headlineSmall: AppThemeData.textStyle(
          primaryColor,
          headline3,
          FontWeight.w800,
          mainFontFamily,
        ),
        // TITLE
        // - For subtitles under headlines or titles
        // - Smaller subtitles, for less emphasis
        titleLarge: AppThemeData.textStyle(
          primaryColor,
          title1,
          FontWeight.w600,
          mainFontFamily,
        ),
        titleMedium: AppThemeData.textStyle(
          primaryColor,
          body1,
          FontWeight.w600,
          mainFontFamily,
        ),
        titleSmall: AppThemeData.textStyle(
          primaryColor,
          body2,
          FontWeight.w600,
          mainFontFamily,
        ),
        // Text
        // - Main body text, improved for readability
        // - Secondary body text
        // - Tertiary body text
        bodyLarge: AppThemeData.textStyle(
          primaryColor,
          body1,
          FontWeight.w400,
          mainFontFamily,
        ),
        bodyMedium: AppThemeData.textStyle(
          primaryColor,
          body2,
          FontWeight.w400,
          mainFontFamily,
        ),
        bodySmall: AppThemeData.textStyle(
          primaryColor,
          body3,
          FontWeight.w200,
          mainFontFamily,
        ),
        // Label
        // - Same as text but in Grey
        labelLarge: AppThemeData.textStyle(
          disabledColor,
          body1,
          FontWeight.w400,
          mainFontFamily,
        ),
        labelMedium: AppThemeData.textStyle(
          disabledColor,
          body2,
          FontWeight.w400,
          mainFontFamily,
        ),
        labelSmall: AppThemeData.textStyle(
          disabledColor,
          body3,
          FontWeight.w200,
          mainFontFamily,
        ),
      ),
      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleSpacing: 0.0,
        elevation: 4.0,
        scrolledUnderElevation: 2.0,
        foregroundColor: primaryColor,
        backgroundColor: scaffoldBackgroundColor,
        surfaceTintColor: scaffoldBackgroundColor,
        iconTheme: AppThemeData.icon(primaryColor, iconSize),
        actionsIconTheme: AppThemeData.icon(primaryColor, iconSize),
        toolbarTextStyle: AppThemeData.textStyle(
          primaryColor,
          title1,
          FontWeight.w600,
          mainFontFamily,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.black,
          systemNavigationBarDividerColor: AppColors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ), // For light icons on dark background
      ),
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        modalElevation: 4,
        showDragHandle: true,
        dragHandleColor: disabledColor,
        modalBarrierColor: AppColors.lightGrey,
        modalBackgroundColor: AppColors.white,
        backgroundColor: AppColors.lightGrey,
        surfaceTintColor: AppColors.lightGrey,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(borderRadiusSmall)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      // Your other theme configurations
      textSelectionTheme: TextSelectionThemeData(
        selectionColor:
            complementaryColor.withOpacity(0.5), // Color for text selection
        selectionHandleColor:
            complementaryColor, // Color for the handles used to adjust the selection
        // Color for the cursor
      ),
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        hintStyle: AppThemeData.textStyle(
          disabledColor,
          body2,
          FontWeight.w400,
          mainFontFamily,
        ),
        errorStyle: AppThemeData.textStyle(
          errorColor,
          body2,
          FontWeight.w400,
          mainFontFamily,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: disabledColor, width: 0.5),
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      ),
      // Dialog Theme
      dialogTheme: DialogTheme(
        surfaceTintColor: AppColors.lightGrey,
        titleTextStyle: AppThemeData.textStyle(
          primaryColor,
          title1,
          FontWeight.w400,
          mainFontFamily,
        ),
        contentTextStyle: AppThemeData.textStyle(
          primaryColor,
          body2,
          FontWeight.w400,
          mainFontFamily,
        ),
        shape: const StadiumBorder(),
      ),
      // Button Theme
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        layoutBehavior: ButtonBarLayoutBehavior.padded,
        textTheme: ButtonTextTheme.normal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        shape: const StadiumBorder(),
        alignedDropdown: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        iconSize: iconSize,
        enableFeedback: true,
        elevation: 6.0,
        focusElevation: 8.0,
        hoverElevation: 8.0,
        disabledElevation: 0.0,
        highlightElevation: 12.0,
        foregroundColor: AppColors.white,
        backgroundColor: complementaryColor,
        shape: const StadiumBorder(),
      ),
      // CheckBox, Radio, Switch
      checkboxTheme: CheckboxThemeData(
        fillColor: AppThemeData.controlColorProperty(complementaryColor),
      ),
      radioTheme: RadioThemeData(
        fillColor: AppThemeData.controlColorProperty(complementaryColor),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: AppThemeData.controlColorProperty(complementaryColor),
        trackColor: AppThemeData.controlColorProperty(complementaryColor),
      ),
    );
  }
}
