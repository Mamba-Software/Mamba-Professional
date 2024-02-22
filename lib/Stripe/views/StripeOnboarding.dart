import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
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
  int _currentPage = 0;
  final int _numPages = 4;
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
            setState(() {
              _currentPage = page;
            });
          },
          children: <Widget>[
            // 1. Pagos In App
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.33),
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.04),
                      height: MediaQuery.of(context).size.height * 0.23,
                      child: Lottie.asset(
                        Constants.stripeOnboardingOne,
                        fit: BoxFit.fill,
                      ),
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
                                  "Pagos In-App",
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
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeIn,
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
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(30)),
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
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: null,
                                      child: Text(
                                        AppLocalizations.of(context)!.back,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              color: Colors.transparent,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 2. Payment Options
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.33),
                  child: Center(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Lottie.asset(
                        Constants.stripeOnboardingTwo,
                        fit: BoxFit.fill,
                      ),
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
                                  "Payment Method",
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
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeIn,
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
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(30)),
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
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeIn,
                                        );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.back,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 3. Pay to Bank
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.33),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Lottie.asset(
                        Constants.stripeOnboardingThree,
                        fit: BoxFit.fill,
                      ),
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
                                  "Banc Transfer",
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
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeIn,
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
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(30)),
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
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeIn,
                                        );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.back,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 4. Stripe
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  color: AppColors.stripeColor.withOpacity(0.33),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.2,
                          color: AppColors.white,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Lottie.asset(
                            Constants.stripeOnboardingFour,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: AppColors.stripeColor.withOpacity(0.33),
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
                                  "Stripe",
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
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeIn,
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
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(30)),
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
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeIn,
                                        );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.back,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 5. Comisión
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  color: AppColors.stripeColor.withOpacity(0.33),
                  child: Center(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Lottie.asset(
                        Constants.stripeOnboardingFive,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: AppColors.stripeColor.withOpacity(0.33),
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
                                  "Comisiones",
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
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeIn,
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
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(30)),
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
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeIn,
                                        );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.back,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 6. Resumen
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.33),
                  child: Center(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Lottie.asset(
                        Constants.stripeOnboardingOne,
                        fit: BoxFit.fill,
                      ),
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
                                  "Resumen",
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
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeIn,
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
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(30)),
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
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeIn,
                                        );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.back,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      //bottomSheet: returnCorrectBottomSheet(),
    );
  }
}
