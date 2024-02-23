import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';

class StripeOnboarding extends StatefulWidget {
  const StripeOnboarding({super.key});

  @override
  _StripeOnboardingState createState() => _StripeOnboardingState();
}

class _StripeOnboardingState extends State<StripeOnboarding> {
  // Acceso a Base de Datos
  final _locationDataService = LocationDataService();
  // Wellcome Pages
  int _currentPage = 0;
  final int _numPages = 4;
  final PageController _pageController = PageController(initialPage: 0);
  // Brand Location
  Location location = Location();

  @override
  void initState() {
    mixpanel!.track('onboarding_find_trainers');
    getLocationFromId(currentBrand.baseLocation!);
    super.initState();
  }

  Future<void> getLocationFromId(String locationId) async {
    location = await _locationDataService.getSingleLocation(locationId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.lightGrey,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (int page) async {
          if (page == 0) {
            mixpanel!.track('onboarding_find_trainers');
          } else if (page == 1) {
            mixpanel!.track('onboarding_notifications_sessions');
          } else if (page == 2) {
            mixpanel!.track('onboarding_stats_letsgo');
          } else if (page == 3) {
            mixpanel!.track('onboarding_data_name');
          } else if (page == 4) {
            mixpanel!.track('onboarding_data_name');
          } else if (page == 5) {
            mixpanel!.track('onboarding_data_name');
          } else if (page == 6) {
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
                height: MediaQuery.of(context).size.height * 0.23,
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
                        bottom: MediaQuery.of(context).size.width * 0.025,
                        right: MediaQuery.of(context).size.width * 0.1,
                        left: MediaQuery.of(context).size.width * 0.1,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        /*
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                        ),
                        */
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Page Title
                              Text(
                                AppLocalizations.of(context)!.stripeAccountText,
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.height * 0.07,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.20),
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
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!.bonoSimpleText,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              // Page Content
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.height * 0.07,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.20),
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
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!
                                      .bonoRecurrentText,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                                    duration: const Duration(milliseconds: 500),
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
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
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
                height: MediaQuery.of(context).size.height * 0.23,
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
                        bottom: MediaQuery.of(context).size.width * 0.025,
                        right: MediaQuery.of(context).size.width * 0.1,
                        left: MediaQuery.of(context).size.width * 0.1,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.height * 0.07,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.20),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0))),
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsets.all(5),
                                      child: Image(
                                        image: AssetImage(Constants.imageCard),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .cardPaymentMethod,
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.height * 0.07,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.20),
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
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.height * 0.07,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.20),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0))),
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsets.all(10),
                                      child: Image(
                                        color: Theme.of(context).primaryColor,
                                        image: AssetImage(Constants.apple),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .applePayPaymentMethod,
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                                    duration: const Duration(milliseconds: 500),
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
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
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
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all(
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1)),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.back,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
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
                height: MediaQuery.of(context).size.height * 0.23,
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
                        bottom: MediaQuery.of(context).size.width * 0.025,
                        right: MediaQuery.of(context).size.width * 0.1,
                        left: MediaQuery.of(context).size.width * 0.1,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.height * 0.07,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.20),
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
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!
                                      .stripeBankTransferDailyDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              // Page Content
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.height * 0.07,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.20),
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
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!
                                      .stripeBankTransferTransitDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                                    duration: const Duration(milliseconds: 500),
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
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
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
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all(
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1)),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.back,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
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
          // 4. Stripe Desc
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.23,
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
                        bottom: MediaQuery.of(context).size.width * 0.025,
                        right: MediaQuery.of(context).size.width * 0.1,
                        left: MediaQuery.of(context).size.width * 0.1,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
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
                                          borderRadius: const BorderRadius.all(
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
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!
                                      .stripePlatformLeaderDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                                          borderRadius: const BorderRadius.all(
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
                                      .stripePlatformSecurity,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!
                                      .stripePlatformSecurityDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5.0))),
                                      child: const Center(
                                        child: Icon(
                                          Icons.list_alt_outlined,
                                          color: AppColors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .stripePlatformIntegrado,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!
                                      .stripePlatformIntegradoDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                                    duration: const Duration(milliseconds: 500),
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
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
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
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all(
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1)),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.back,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
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
                height: MediaQuery.of(context).size.height * 0.23,
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
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.1,
                        bottom: MediaQuery.of(context).size.width * 0.025,
                        right: MediaQuery.of(context).size.width * 0.1,
                        left: MediaQuery.of(context).size.width * 0.1,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Page Title
                              Text(
                                AppLocalizations.of(context)!.stripeComissions,
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
                                    .stripeComissionsDesc,
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
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5.0))),
                                      child: const Center(
                                        child: Icon(
                                          Icons.credit_card_outlined,
                                          color: AppColors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .stripeComissionsPayment,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!
                                      .stripeComissionsPaymentDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5.0))),
                                      child: const Center(
                                        child: Icon(
                                          Icons.account_balance,
                                          color: AppColors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .stripeComissionsTransfer,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!
                                      .stripeComissionsTransferDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              // Page Content
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.height * 0.07,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.20),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0))),
                                  child: Center(
                                    child: Icon(
                                      Icons.send_to_mobile_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .stripeComissionsMamba,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!
                                      .stripeComissionsMambaDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                                    duration: const Duration(milliseconds: 500),
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
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
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
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all(
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1)),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.back,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
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
          // 6. Stripe Info
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.23,
                width: double.infinity,
                color: AppColors.stripeColor.withOpacity(0.33),
                child: Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: Lottie.asset(
                      Constants.stripeOnboardingSix,
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
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.1,
                        bottom: MediaQuery.of(context).size.width * 0.025,
                        right: MediaQuery.of(context).size.width * 0.1,
                        left: MediaQuery.of(context).size.width * 0.1,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Page Title
                              Text(
                                AppLocalizations.of(context)!.stripeYourAccount,
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
                                    .stripeYourAccountDesc,
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.height * 0.07,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.20),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(
                                          currentUser.imageUrl!),
                                      opacity: 1,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  currentUser.name!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentUser.email!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      currentUser.dateOfBirth!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                              // Page Content
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.height * 0.07,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.20),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(
                                          currentBrand.logoUrl!),
                                      opacity: 1,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  currentBrand.name!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location.id == null
                                          ? "${currentBrand.city!}, ${currentBrand.zipCode!}"
                                          : location.description!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
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
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5.0))),
                                      child: const Center(
                                        child: Icon(
                                          Icons.phone,
                                          color: AppColors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .stripePhoneNumber,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!
                                      .stripePhoneNumberDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5.0))),
                                      child: const Center(
                                        child: Icon(
                                          Icons.account_balance,
                                          color: AppColors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .stripeBankAccount,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  AppLocalizations.of(context)!
                                      .stripeBankAccountDesc,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                                    duration: const Duration(milliseconds: 500),
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
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
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
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all(
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1)),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.back,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
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
          // 7. Resumen
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                height: _currentPage != 6
                    ? MediaQuery.of(context).size.height * 0.25
                    : MediaQuery.of(context).size.height * 0.08,
                curve: Curves.bounceOut,
                width: double.infinity,
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.33),
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
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Resumen
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.1,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.stripeSummary,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 30),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width * 0.1,
                                left: MediaQuery.of(context).size.width * 0.1,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pagos In App
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .stripeAccountDescription,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04),
                                        // Page Title
                                        Text(
                                          AppLocalizations.of(context)!
                                              .stripeAccountText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          textAlign: TextAlign.left,
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.06,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.20),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: Center(
                                                child: Icon(
                                                  FontAwesomeIcons.one,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .bonoSimple,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .bonoSimpleText,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.06,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.20),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: Center(
                                                child: Icon(
                                                  Icons.repeat,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .bonoRecurrent,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .bonoRecurrentText,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Métodos de Pago
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04),
                                        // Page Title
                                        Text(
                                          "${AppLocalizations.of(context)!.paymentMethod.split(" ")[0]} ${AppLocalizations.of(context)!.paymentMethod.split(" ")[1]} ${StringUtils().toCapitalized(AppLocalizations.of(context)!.paymentMethod.split(" ")[2])}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.005),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.06,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.20),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: Center(
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  child: Image(
                                                    image: AssetImage(
                                                        Constants.imageCard),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .cardPaymentMethod,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.06,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.20),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: Center(
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  child: Image(
                                                    image: AssetImage(
                                                        Constants.google),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .googlePayPaymentMethod,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.06,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.20),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: Center(
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  child: Image(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    image: AssetImage(
                                                        Constants.apple),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .applePayPaymentMethod,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Bank Transfer
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Page Title
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.03),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .stripeBankTransfer,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          textAlign: TextAlign.left,
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.06,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.20),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: Center(
                                                child: Icon(
                                                  Icons.cached,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeBankTransferDaily,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeBankTransferDailyDesc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.06,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.20),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: Center(
                                                child: Icon(
                                                  Icons.east,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeBankTransferTransit,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeBankTransferTransitDesc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Stripe
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                        ),
                                        // Page Title
                                        Text(
                                          AppLocalizations.of(context)!
                                              .stripePlatform,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          textAlign: TextAlign.left,
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.lightGrey,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration: BoxDecoration(
                                                      color: AppColors
                                                          .stripeColor
                                                          .withOpacity(0.33),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  5.0))),
                                                  child: const Center(
                                                    child: Icon(
                                                      FontAwesomeIcons.one,
                                                      color: AppColors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .stripePlatformLeader,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .stripePlatformLeaderDesc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.lightGrey,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration: BoxDecoration(
                                                      color: AppColors
                                                          .stripeColor
                                                          .withOpacity(0.33),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  5.0))),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.lock_outlined,
                                                      color: AppColors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .stripePlatformSecurity,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .stripePlatformSecurityDesc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.lightGrey,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration: BoxDecoration(
                                                      color: AppColors
                                                          .stripeColor
                                                          .withOpacity(0.33),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  5.0))),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.list_alt_outlined,
                                                      color: AppColors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .stripePlatformIntegrado,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .stripePlatformIntegradoDesc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Comisiones
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.03,
                                        ),
                                        // Page Title
                                        Text(
                                          AppLocalizations.of(context)!
                                              .stripeComissions,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          textAlign: TextAlign.left,
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.lightGrey,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration: BoxDecoration(
                                                      color: AppColors
                                                          .stripeColor
                                                          .withOpacity(0.33),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  5.0))),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons
                                                          .credit_card_outlined,
                                                      color: AppColors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeComissionsPayment,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeComissionsPaymentDesc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.lightGrey,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration: BoxDecoration(
                                                      color: AppColors
                                                          .stripeColor
                                                          .withOpacity(0.33),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  5.0))),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.account_balance,
                                                      color: AppColors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeComissionsTransfer,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeComissionsTransferDesc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.20),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: Center(
                                                child: Icon(
                                                  Icons.send_to_mobile_outlined,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeComissionsMamba,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeComissionsMambaDesc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Cuenta Stripe
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.03), // Page Title
                                        Text(
                                          AppLocalizations.of(context)!
                                              .stripeYourAccount,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          textAlign: TextAlign.left,
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.05,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.05,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                          .withOpacity(0.20),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                        Radius.circular(5.0),
                                                      ),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image:
                                                            CachedNetworkImageProvider(
                                                                currentUser
                                                                    .imageUrl!),
                                                        opacity: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                            title: Text(
                                              currentUser.name!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  currentUser.dateOfBirth!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  textAlign: TextAlign.left,
                                                ),
                                                Text(
                                                  currentUser.email!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.20),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(5.0),
                                                ),
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          currentBrand
                                                              .logoUrl!),
                                                  opacity: 1,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              currentBrand.name!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  location.id == null
                                                      ? "${currentBrand.city!}, ${currentBrand.zipCode!}"
                                                      : location.description!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.lightGrey,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration: BoxDecoration(
                                                      color: AppColors
                                                          .stripeColor
                                                          .withOpacity(0.33),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  5.0))),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.phone,
                                                      color: AppColors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .stripePhoneNumber,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .stripePhoneNumberDesc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        // Page Content
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.lightGrey,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  decoration: BoxDecoration(
                                                      color: AppColors
                                                          .stripeColor
                                                          .withOpacity(0.33),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  5.0))),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.account_balance,
                                                      color: AppColors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            title: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeBankAccount,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            subtitle: Text(
                                              AppLocalizations.of(context)!
                                                  .stripeBankAccountDesc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Botones
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            _pageController.nextPage(
                                              duration: const Duration(
                                                  milliseconds: 500),
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
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.07,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                              child: Center(
                                                child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .next,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                _pageController.previousPage(
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.easeIn,
                                                );
                                              },
                                              style: ButtonStyle(
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                        Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.1)),
                                              ),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .back,
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
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05),
                                      ],
                                    ),
                                  ],
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
        ],
      ),
      //bottomSheet: returnCorrectBottomSheet(),
    );
  }
}
