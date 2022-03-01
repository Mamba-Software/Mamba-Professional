import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';

// Text Styles contains all the TextStyles used in the App.
class TextStyles {

  // Scale Factors vs Screen Height
  double factorHeadline1 = 0.027;
  double factorHeadline2 = 0.021;
  double factorBodyText1 = 0.019;
  double factorBodyText2 = 0.017;

  // Headlines or Titles
  double headline1 = 0;
  double headline2 = 0;
  // Body Text
  double bodyText1 = 0;
  double bodyText2 = 0;

  TextStyles (double screenHeight) {
    headline1 = screenHeight * factorHeadline1;
    headline2 = screenHeight * factorHeadline2;
    bodyText1 = screenHeight * factorBodyText1;
    bodyText2 = screenHeight * factorBodyText2;
    if (screenHeight < 700) {
      headline1 += 2;
      headline2 += 2;
      bodyText1 += 2;
      bodyText2 += 2;
    } else if (screenHeight < 800) {
      headline1 += 1;
      headline2 += 1;
      bodyText1 += 1;
      bodyText2 += 1;
    }
    print("\n");
    print("Text Styles for Screen Height = "+screenHeight.toString());
    print("\n");
    print("Headline 1 = "+headline1.toString());
    print("Headline 2 = "+headline2.toString());
    print("Body Text 1 = "+bodyText1.toString());
    print("Body Text 2 = "+bodyText2.toString());
  }

  TextStyle blackHeadline1TextStyle() {
    return TextStyle(color: AppColors.black, fontSize: headline1, fontWeight: FontWeight.w500);
  }

  TextStyle whiteHeadline1TextStyle() {
    return TextStyle(color: AppColors.white, fontSize: headline1, fontWeight: FontWeight.w500);
  }

  TextStyle blackHeadline2TextStyle() {
    return TextStyle(color: AppColors.black, fontSize: headline2, fontWeight: FontWeight.w500);
  }

  TextStyle whiteHeadline2TextStyle() {
    return TextStyle(color: AppColors.white, fontSize: headline2, fontWeight: FontWeight.w500);
  }

  TextStyle blackBodyText1Style() {
    return TextStyle(color: AppColors.black, fontSize: bodyText1, fontWeight: FontWeight.w400);
  }

  TextStyle whiteBodyText1Style() {
    return TextStyle(color: AppColors.white, fontSize: bodyText1, fontWeight: FontWeight.w400);
  }

  TextStyle blackBodyText2Style() {
    return TextStyle(color: AppColors.black, fontSize: bodyText2, fontWeight: FontWeight.w400);
  }

  TextStyle whiteBodyText2Style() {
    return TextStyle(color: AppColors.white, fontSize: bodyText2, fontWeight: FontWeight.w400);
  }

  TextStyle greyBodyTextStyle() {
    return TextStyle(color: AppColors.grey, fontSize: bodyText2, fontWeight: FontWeight.w400);
  }



}
