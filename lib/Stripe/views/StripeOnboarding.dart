import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
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
                  height: MediaQuery.of(context).size.height * 0.25,
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
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.1,
                          bottom: MediaQuery.of(context).size.width * 0.05,
                          right: MediaQuery.of(context).size.width * 0.1,
                          left: MediaQuery.of(context).size.width * 0.1,
                        ),
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
                                // Page Title
                                Text(
                                  AppLocalizations.of(context)!
                                      .stripeAccountText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontSize: 30),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                // Page Description
                                Text(
                                  AppLocalizations.of(context)!
                                      .stripeAccountDescription,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                // Page Content
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width: MediaQuery.of(context).size.height *
                                        0.07,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.08),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Center(
                                      child: Icon(
                                        FontAwesomeIcons.one,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!.bonoSimple,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
                                  ),
                                  subtitle: Text(
                                    AppLocalizations.of(context)!
                                        .bonoSimpleText,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.left,
                                  ),
                                ),

                                // Page Content
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width: MediaQuery.of(context).size.height *
                                        0.07,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.08),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Center(
                                      child: Icon(
                                        Icons.repeat,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!.bonoRecurrent,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
                                  ),
                                  subtitle: Text(
                                    AppLocalizations.of(context)!
                                        .bonoRecurrentText,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.left,
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
                  height: MediaQuery.of(context).size.height * 0.25,
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
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.1,
                          bottom: MediaQuery.of(context).size.width * 0.05,
                          right: MediaQuery.of(context).size.width * 0.1,
                          left: MediaQuery.of(context).size.width * 0.1,
                        ),
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
                                // Page Title
                                Text(
                                  "${AppLocalizations.of(context)!.paymentMethod.split(" ")[0]} ${AppLocalizations.of(context)!.paymentMethod.split(" ")[1]} ${StringUtils().toCapitalized(AppLocalizations.of(context)!.paymentMethod.split(" ")[2])}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontSize: 30),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                // Page Description
                                Text(
                                  AppLocalizations.of(context)!
                                      .stripePaymentMethodDescription,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03),
                                // Page Content
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width: MediaQuery.of(context).size.height *
                                        0.07,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.08),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Center(
                                      child: Container(
                                        margin: const EdgeInsets.all(5),
                                        child: Image(
                                          image:
                                              AssetImage(Constants.imageCard),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .cardPaymentMethod,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                // Page Content
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width: MediaQuery.of(context).size.height *
                                        0.07,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.08),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Center(
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        child: Image(
                                          image: AssetImage(Constants.google),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .googlePayPaymentMethod,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                // Page Content
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width: MediaQuery.of(context).size.height *
                                        0.07,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.08),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Center(
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        child: Image(
                                          image: AssetImage(Constants.apple),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .applePayPaymentMethod,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
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
                  height: MediaQuery.of(context).size.height * 0.25,
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
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.1,
                          bottom: MediaQuery.of(context).size.width * 0.05,
                          right: MediaQuery.of(context).size.width * 0.1,
                          left: MediaQuery.of(context).size.width * 0.1,
                        ),
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
                                // Page Title
                                Text(
                                  AppLocalizations.of(context)!
                                      .stripeBankTransfer,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontSize: 30),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                // Page Description
                                Text(
                                  AppLocalizations.of(context)!
                                      .stripeBankTransferDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                // Page Content
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width: MediaQuery.of(context).size.height *
                                        0.07,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.08),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Center(
                                      child: Icon(
                                        Icons.cached,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .stripeBankTransferDaily,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
                                  ),
                                  subtitle: Text(
                                    AppLocalizations.of(context)!
                                        .stripeBankTransferDailyDesc,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                // Page Content
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width: MediaQuery.of(context).size.height *
                                        0.07,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.08),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Center(
                                      child: Icon(
                                        Icons.east,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .stripeBankTransferTransit,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
                                  ),
                                  subtitle: Text(
                                    AppLocalizations.of(context)!
                                        .stripeBankTransferTransitDesc,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.left,
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
                  height: MediaQuery.of(context).size.height * 0.25,
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
                          height: MediaQuery.of(context).size.height * 0.25,
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
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.1,
                          bottom: MediaQuery.of(context).size.width * 0.05,
                          right: MediaQuery.of(context).size.width * 0.1,
                          left: MediaQuery.of(context).size.width * 0.1,
                        ),
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
                                // Page Title
                                Text(
                                  AppLocalizations.of(context)!.stripePlatform,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontSize: 30),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                // Page Description
                                Text(
                                  AppLocalizations.of(context)!
                                      .stripePlatformDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                // Page Content
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        decoration: const BoxDecoration(
                                          color: AppColors.lightGrey,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        decoration: BoxDecoration(
                                            color: AppColors.stripeColor
                                                .withOpacity(0.33),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5.0))),
                                        child: const Center(
                                          child: Icon(
                                            FontAwesomeIcons.one,
                                            color: AppColors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .stripePlatformLeader,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
                                  ),
                                  subtitle: Text(
                                    AppLocalizations.of(context)!
                                        .stripePlatformLeaderDesc,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                // Page Content
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        decoration: const BoxDecoration(
                                          color: AppColors.lightGrey,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        decoration: BoxDecoration(
                                            color: AppColors.stripeColor
                                                .withOpacity(0.33),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5.0))),
                                        child: const Center(
                                          child: Icon(
                                            Icons.lock_outlined,
                                            color: AppColors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .stripePlatformLeader,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
                                  ),
                                  subtitle: Text(
                                    AppLocalizations.of(context)!
                                        .stripePlatformLeaderDesc,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.left,
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
                  height: MediaQuery.of(context).size.height * 0.25,
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
                  height: MediaQuery.of(context).size.height * 0.25,
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
