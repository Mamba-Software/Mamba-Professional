import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class StripeOnboarding extends StatefulWidget {
  const StripeOnboarding({super.key});

  @override
  _StripeOnboardingState createState() => _StripeOnboardingState();
}

class _StripeOnboardingState extends State<StripeOnboarding> {
  // Variables
  bool isDark = false;
  // Wellcome Pages
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    mixpanel!.track('onboarding_find_trainers');
    isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor:
            Theme.of(context).colorScheme.secondary.withOpacity(0.33),
        systemOverlayStyle: Platform.isIOS
            ? isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark
            : isDark
                ? SystemUiOverlayStyle(
                    statusBarBrightness: Brightness.light,
                    statusBarColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.05),
                    statusBarIconBrightness: Brightness.light,
                  )
                : SystemUiOverlayStyle(
                    statusBarBrightness: Brightness.dark,
                    statusBarColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.05),
                    statusBarIconBrightness: Brightness.dark,
                  ),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.lightGrey,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (int page) {
            if (page == 0) {
              mixpanel!.track('onboarding_find_trainers');
            } else if (page == 1) {
              mixpanel!.track('onboarding_notifications_sessions');
            } else if (page == 2) {
              mixpanel!.track('onboarding_stats_letsgo');
            } else if (page == 3) {
              mixpanel!.track('onboarding_data_name');
            }
          },
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.33),
                  child: Center(
                    child: Image.asset(
                      Constants.stripeOnboardingOne,
                      width: MediaQuery.of(context).size.width * 0.5,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.33),
                      ),
                      Container(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.1),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .trainersOnboarding,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontSize: 30),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(height: 1.5),
                                    children: [
                                      TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .trainersOnboardingDesc
                                            .split(" ")[0],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                decoration:
                                                    TextDecoration.underline),
                                      ),
                                      TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .trainersOnboardingDesc
                                            .substring(
                                                AppLocalizations.of(context)!
                                                    .trainersOnboardingDesc
                                                    .split(" ")[0]
                                                    .length),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              child: Material(
                                elevation: 4,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                ),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!.next,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                            color: AppColors.white, shape: BoxShape.circle),
                        child: Center(
                          child: FaIcon(FontAwesomeIcons.creditCard,
                              color: AppColors.black,
                              size: MediaQuery.of(context).size.width * 0.1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .trainersOnboardingSecond,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(color: AppColors.white, fontSize: 30),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.white, height: 1.5),
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context)!
                                    .trainersOnboardingSecondDesc1,
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!
                                    .trainersOnboardingSecondDesc2
                                    .toLowerCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        color: AppColors.white,
                                        decoration: TextDecoration.underline),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!
                                    .trainersOnboardingSecondDesc3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                    child: Material(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                          child: Text(AppLocalizations.of(context)!.next,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(color: AppColors.black)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: null,
                        child: Text(
                          AppLocalizations.of(context)!.skip,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: AppColors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                            color: AppColors.white, shape: BoxShape.circle),
                        child: Center(
                          child: FaIcon(FontAwesomeIcons.chartLine,
                              color: AppColors.black,
                              size: MediaQuery.of(context).size.width * 0.1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.trainersOnboardingThird,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(color: AppColors.white, fontSize: 30),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.white, height: 1.5),
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context)!
                                    .trainersOnboardingThirdDesc1,
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!
                                    .trainersOnboardingThirdDesc2,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        color: AppColors.white,
                                        decoration: TextDecoration.underline),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!
                                    .trainersOnboardingThirdDesc3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                    child: Material(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                          child: Text(
                              AppLocalizations.of(context)!
                                  .notificationsPermision,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(color: AppColors.black)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.next,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: AppColors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                ],
              ),
            ),
          ],
        ),
      ),
      //bottomSheet: returnCorrectBottomSheet(),
    );
  }
}
