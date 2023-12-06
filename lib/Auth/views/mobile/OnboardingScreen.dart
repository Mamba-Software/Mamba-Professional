import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Auth/CreateBrand/views/mobile/RegistrarMarca.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Permissions/PermisionsService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'SplashScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Services
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final PermisionsService _permisionsService = PermisionsService();
  NotificationService? _notificationService;
  // Boolean
  bool isLoading = false;
  // Wellcome Pages
  final PageController _pageController = PageController(initialPage: 0);
  final PageController _pageControllerData = PageController(initialPage: 0);
  // Tab Controller
  double addEventTabValue = 0.249;
  // Title Controller
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  FocusNode focusNodeName = FocusNode();
  bool canGoNextName = false;
  // Profile Image
  File? _image;
  String? imageUrl;
  // Date Of Birth
  DateTime startDate = DateTime.now();
  var dayController = TextEditingController();
  var monthController = TextEditingController();
  var yearController = TextEditingController();
  FocusNode focusNodeMonth = FocusNode();
  FocusNode focusNodeYear = FocusNode();
  bool canGoNextDate = false;
  bool confirmAge = false;
  bool errorAge = false;
  // Gender Widget value
  int? gender;
  // GoogleLogIn
  bool isGoogle = false;
  // AppleLogIn
  bool isApple = false;
  bool isLoadingBody = false;

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    mixpanel!.timeEvent("onboarding_userdata_image");
    setState(() {
      isLoadingBody = true;
    });
    try {
      File? temp = await ImageUtils().pickImage();
      setState(() {
        _image = temp;
        isLoadingBody = false;
      });
      mixpanel!.track('onboarding_userdata_image');
    } catch (e) {
      setState(() {
        isLoadingBody = false;
      });
    }
  }

  DateTime? convertToDate(String input, String format, BuildContext context) {
    try {
      final DateTime d =
          DateFormat(format, Localizations.localeOf(context).languageCode)
              .parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  Future<void> addUser() async {
    // Trimming for Names
    String name =
        firstNameController.text.trim() + " " + lastNameController.text.trim();
    String dateString = DateTimeUtils().formatDateTimeToStringDDMMYYYY(
        startDate, Localizations.localeOf(context).languageCode);
    // Update Functions
    await _userDataService.updateUser(
        currentUser.id!,
        name,
        firstNameController.text.trim(),
        lastNameController.text.trim(),
        dateString,
        gender!,
        _image,
        imageUrl,
        true);
    // Notification Service
    _notificationService = NotificationService();
    _notificationService!.wellcomeUser(currentUser.id!);
    sendMixPanelDataUsers();
    // Create Brand
    // Get User Main Data
    currentUser.setBasicData =
        await _userDataService.getUserDetails(currentUser.id!);
    //Check if user has brand
    List<Brand> brands =
        await _brandDataService.getAllBrandsFromUser(currentUser.id!);
    currentUser.setBrandList = brands;
    if (currentUser.brandsList.isNotEmpty) {
      // Setting the Brand to the User
      hasBrand = true;
      //TODO ADD 7DAYS
      await _brandDataService.updateBrandPay(brands[0].id!, 8, '7DAYSTRIAL',
          '7 Days Trial', DateTime.now(), false);
    }
    bool? brandCreated;
    if (dynamicLinkBrandId == null && hasBrand == false) {
      brandCreated = await Navigator.push(
          context,
          CupertinoPageRoute<bool>(
            builder: (context) => RegistrarMarca(
              locale: Localizations.localeOf(context),
            ),
            settings: const RouteSettings(name: 'RegistrarMarca'),
          ));
    }
    if ((brandCreated == null || brandCreated == false) || (hasBrand)) {
      // SplashScreen
      //TODO AFEGIR SUSCRIPCIO GRATIS, COM COMPROVEM???
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute<void>(
            builder: (context) => const SplashScreen(),
            settings: const RouteSettings(name: 'SplashScreen'),
          ));
    }
  }

  void sendMixPanelDataUsers() {
    // Send User Mix Panel Data
    mixpanel!.getPeople().set("email", currentUser.email);
    mixpanel!.getPeople().set("firstLoginDate", DateTime.now().toString());
    String genderString = "";
    if (gender == 0) genderString = "Male";
    if (gender == 1) genderString = "Female";
    if (gender == 2) genderString = "Other";
    mixpanel!.getPeople().set("gender", genderString);
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
    mixpanel!.getPeople().set("dateOfBirth", startDate.toString());
    mixpanel!.getPeople().set("language", currentUser.idioma!);
    mixpanel!.getPeople().set("isPrivate", true);
    mixpanel!.getPeople().set("isTrainer", true);
    mixpanel!.getPeople().set("isProduction", isProduction);
  }

  int calculateAge(DateTime birthDate, DateTime currentDate) {
    int age = currentDate.year - birthDate.year;
    int month1 = birthDate.month;
    int month2 = currentDate.month;
    int day1 = birthDate.day;
    int day2 = currentDate.day;
    // If the current year's month is less than the birth year's month, then decrease year by 1
    if (month2 < month1) {
      age--;
    }
    // If the birth month is this month, but the day is later than the current day, decrease year by 1
    else if (month2 == month1 && day2 < day1) {
      age--;
    }
    return age;
  }

  @override
  void initState() {
    mixpanel!.track('onboarding_find_trainers');
    initGoogleLogIn();
    super.initState();
  }

  Future<void> initGoogleLogIn() async {
    User? firebaseUser = await _userDataService.getCurrentUser();
    try {
      if (firebaseUser!.providerData[0].providerId == "google.com") {
        isGoogle = true;
        if (firebaseUser.displayName != null) {
          firstNameController.text = firebaseUser.displayName!.split(" ")[0];
          int length = firebaseUser.displayName!.split(" ")[0].length;
          lastNameController.text =
              firebaseUser.displayName!.substring(length + 1);
          canGoNextName = true;
        }
        if (firebaseUser.photoURL != null) {
          imageUrl = firebaseUser.photoURL;
        }
      } else if (firebaseUser.providerData[0].providerId == "apple.com") {
        isApple = true;
        if (firebaseUser.displayName != null) {
          firstNameController.text = firebaseUser.displayName!.split(" ")[0];
          int length = firebaseUser.displayName!.split(" ")[0].length;
          lastNameController.text =
              firebaseUser.displayName!.substring(length + 1);
          canGoNextName = true;
        }
      }
    } catch (e) {
      isGoogle = false;
      isApple = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.black,
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
                          child: FaIcon(FontAwesomeIcons.calendarDays,
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
                          AppLocalizations.of(context)!.trainersOnboarding,
                          style: Theme.of(context)
                              .textTheme
                              .headline1
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
                                .bodyText1
                                ?.copyWith(color: AppColors.white, height: 1.5),
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context)!
                                    .trainersOnboardingDesc
                                    .split(" ")[0],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(
                                        color: AppColors.white,
                                        decoration: TextDecoration.underline),
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!
                                    .trainersOnboardingDesc
                                    .substring(AppLocalizations.of(context)!
                                        .trainersOnboardingDesc
                                        .split(" ")[0]
                                        .length),
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
                          child: Text(AppLocalizations.of(context)!.next,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
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
                              .headline3
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
                              .headline1
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
                                .bodyText1
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
                                    .bodyText1
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
                                  .headline3
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
                              .headline3
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
                              .headline1
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
                                .bodyText1
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
                                    .bodyText1
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
                      _permisionsService.askUserNotificationsPermision();
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
                                  .headline3
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
                              .headline3
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
            // Data Info
            GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width * 0.94,
                        lineHeight: 5,
                        percent: addEventTabValue,
                        animation: false,
                        animationDuration: 250,
                        barRadius: const Radius.circular(10),
                        progressColor: AppColors.white,
                        backgroundColor: AppColors.white.withOpacity(0.2),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Expanded(
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _pageControllerData,
                      onPageChanged: (int page) {
                        setState(() {
                          addEventTabValue += 0.25;
                        });
                        if (page == 0) {
                          mixpanel!.track('onboarding_data_name');
                        } else if (page == 1) {
                          mixpanel!.track('onboarding_data_photo');
                        } else if (page == 2) {
                          mixpanel!.track('onboarding_data_birthday');
                        } else if (page == 3) {
                          mixpanel!.track('onboarding_data_gender');
                          mixpanel!.track('onboarding_finish');
                        }
                      },
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.1),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .whatsYourName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(
                                                color: AppColors.white,
                                                fontSize: 30),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .changeLater,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            ?.copyWith(color: AppColors.white),
                                        textAlign: TextAlign.left,
                                      ),
                                      isGoogle
                                          ? FittedBox(
                                              fit: BoxFit.contain,
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.1,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                margin: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.02),
                                                decoration: BoxDecoration(
                                                    color: AppColors.darkGrey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Image(
                                                        image: AssetImage(
                                                            Constants.google)),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.02),
                                                    Flexible(
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .googleInfo,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2
                                                            ?.copyWith(
                                                                color: AppColors
                                                                    .white),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      isApple
                                          ? FittedBox(
                                              fit: BoxFit.contain,
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.1,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                margin: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.02),
                                                decoration: BoxDecoration(
                                                    color: AppColors.darkGrey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.04,
                                                      child: Image(
                                                          image: AssetImage(
                                                              Constants.apple)),
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.02),
                                                    Flexible(
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                    context)!
                                                                .googleInfo
                                                                .split(
                                                                    "Google")[0] +
                                                            " Apple",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2
                                                            ?.copyWith(
                                                                color: AppColors
                                                                    .white),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05),
                                      Material(
                                        elevation: 4,
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                autofocus: true,
                                                controller: firstNameController,
                                                keyboardType:
                                                    TextInputType.name,
                                                onChanged: (value) {
                                                  if (firstNameController
                                                          .text.isNotEmpty &&
                                                      lastNameController
                                                          .text.isNotEmpty) {
                                                    setState(() {
                                                      canGoNextName = true;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      canGoNextName = false;
                                                    });
                                                  }
                                                },
                                                onFieldSubmitted: (val) {
                                                  focusNodeName.requestFocus();
                                                },
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3
                                                    ?.copyWith(
                                                        color: AppColors.black,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                textCapitalization:
                                                    TextCapitalization.words,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: AppColors.white,
                                                    hintText: AppLocalizations
                                                            .of(context)!
                                                        .nameCompletoError,
                                                    hintStyle:
                                                        Theme
                                                                .of(context)
                                                            .textTheme
                                                            .headline3
                                                            ?.copyWith(
                                                                color:
                                                                    AppColors
                                                                        .grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                    errorStyle: Theme
                                                            .of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        ?.copyWith(
                                                            color:
                                                                AppColors.red),
                                                    border: OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                                .fromLTRB(
                                                            12, 8, 12, 8)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      Material(
                                        elevation: 4,
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                focusNode: focusNodeName,
                                                controller: lastNameController,
                                                keyboardType:
                                                    TextInputType.name,
                                                onChanged: (value) {
                                                  if (firstNameController
                                                          .text.isNotEmpty &&
                                                      lastNameController
                                                          .text.isNotEmpty) {
                                                    setState(() {
                                                      canGoNextName = true;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      canGoNextName = false;
                                                    });
                                                  }
                                                },
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3
                                                    ?.copyWith(
                                                        color: AppColors.black,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                textCapitalization:
                                                    TextCapitalization.words,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: AppColors.white,
                                                    hintText: AppLocalizations
                                                            .of(context)!
                                                        .lastNameError,
                                                    hintStyle:
                                                        Theme
                                                                .of(context)
                                                            .textTheme
                                                            .headline3
                                                            ?.copyWith(
                                                                color:
                                                                    AppColors
                                                                        .grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                    errorStyle: Theme
                                                            .of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        ?.copyWith(
                                                            color:
                                                                AppColors.red),
                                                    border: OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                                .fromLTRB(
                                                            12, 8, 12, 8)),
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
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      vertical:
                                          MediaQuery.of(context).size.width *
                                              0.04),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01),
                                      Icon(
                                        Icons.visibility,
                                        color: AppColors.white,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.06,
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .visibleFirstName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              ?.copyWith(
                                                  color: AppColors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: canGoNextName == false
                                            ? null
                                            : () {
                                                FocusScopeNode currentFocus =
                                                    FocusScope.of(context);
                                                if (!currentFocus
                                                    .hasPrimaryFocus) {
                                                  currentFocus.unfocus();
                                                }
                                                _pageControllerData.nextPage(
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.ease,
                                                );
                                              },
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: canGoNextName
                                              ? AppColors.black
                                              : AppColors.white
                                                  .withOpacity(0.2),
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.06,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(15),
                                          primary: canGoNextName
                                              ? AppColors.white
                                              : AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.1),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                                .uploadPhoto
                                                .split(" ")[0] +
                                            " " +
                                            AppLocalizations.of(context)!
                                                .profilePhoto
                                                .toLowerCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(
                                                color: AppColors.white,
                                                fontSize: 30),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .changeLater,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            ?.copyWith(color: AppColors.white),
                                        textAlign: TextAlign.left,
                                      ),
                                      isGoogle
                                          ? FittedBox(
                                              fit: BoxFit.contain,
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.1,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                margin: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.02),
                                                decoration: BoxDecoration(
                                                    color: AppColors.darkGrey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Image(
                                                        image: AssetImage(
                                                            Constants.google)),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.02),
                                                    Flexible(
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .googleInfo,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2
                                                            ?.copyWith(
                                                                color: AppColors
                                                                    .white),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.15,
                                        color: Colors.transparent,
                                        child: _image == null &&
                                                imageUrl == null
                                            ? Center(
                                                child: OutlinedButton(
                                                  onPressed: getImage,
                                                  child: !isLoadingBody
                                                      ? Icon(
                                                          Icons.add,
                                                          color: AppColors.grey,
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.1,
                                                        )
                                                      : SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.1,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.1,
                                                          child: Center(
                                                            child: SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.05,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.05,
                                                              child:
                                                                  const CircularProgressIndicator(
                                                                color: AppColors
                                                                    .grey,
                                                                strokeWidth: 2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.white,
                                                    elevation: 4,
                                                    shape: const CircleBorder(),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            40),
                                                  ),
                                                ),
                                              )
                                            : _image != null
                                                ? GestureDetector(
                                                    onTap: getImage,
                                                    child: Stack(
                                                      children: <Widget>[
                                                        const Center(
                                                            child: CircularProgressIndicator(
                                                                color: AppColors
                                                                    .black)),
                                                        Center(
                                                            child: Material(
                                                          elevation: 4,
                                                          shape:
                                                              const CircleBorder(),
                                                          child: CircularImage(
                                                            size: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.15,
                                                            file: _image,
                                                            borderWidth: 1,
                                                            color:
                                                                AppColors.grey,
                                                          ),
                                                        )),
                                                      ],
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTap: getImage,
                                                    child: Stack(
                                                      children: <Widget>[
                                                        const Center(
                                                            child: CircularProgressIndicator(
                                                                color: AppColors
                                                                    .black)),
                                                        Center(
                                                            child: Material(
                                                          elevation: 4,
                                                          shape:
                                                              const CircleBorder(),
                                                          child: CircularImage(
                                                            size: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.15,
                                                            image: imageUrl,
                                                            borderWidth: 1,
                                                            color:
                                                                AppColors.grey,
                                                          ),
                                                        )),
                                                      ],
                                                    ),
                                                  ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      vertical:
                                          MediaQuery.of(context).size.width *
                                              0.04),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02),
                                      Expanded(
                                        child: Text(
                                          "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              ?.copyWith(
                                                  color: AppColors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _pageControllerData.nextPage(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.ease,
                                          );
                                        },
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.black,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.06,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(15),
                                          primary: AppColors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.1),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .whensYourBday,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(
                                                color: AppColors.white,
                                                fontSize: 30),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .changeLater,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            ?.copyWith(color: AppColors.white),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .day,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.copyWith(
                                                            color: AppColors
                                                                .white),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.15,
                                                child: Material(
                                                  elevation: 4,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: TextFormField(
                                                    autofocus: true,
                                                    controller: dayController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      if (value.length == 2) {
                                                        focusNodeMonth
                                                            .requestFocus();
                                                      }
                                                      if (errorAge) {
                                                        setState(() {
                                                          errorAge = false;
                                                        });
                                                      }
                                                      if (confirmAge) {
                                                        setState(() {
                                                          confirmAge = false;
                                                        });
                                                      }
                                                      //if (dayController.text.length == 2 && monthController.text.length == 2 && yearController.text.length == 4) {
                                                      if (yearController
                                                              .text.length ==
                                                          4) {
                                                        setState(() {
                                                          canGoNextDate = true;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          canGoNextDate = false;
                                                        });
                                                      }
                                                    },
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(
                                                          2), // for mobile
                                                    ],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline3
                                                        ?.copyWith(
                                                            color:
                                                                AppColors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: AppColors
                                                            .white,
                                                        hintText: "DD",
                                                        hintStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .headline3
                                                            ?.copyWith(
                                                                color: AppColors
                                                                    .grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                        errorStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyText2
                                                            ?.copyWith(
                                                                color: AppColors
                                                                    .red),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                12, 8, 12, 8)),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .month,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.copyWith(
                                                            color: AppColors
                                                                .white),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.15,
                                                child: Material(
                                                  elevation: 4,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: TextFormField(
                                                    focusNode: focusNodeMonth,
                                                    controller: monthController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      if (value.length == 2) {
                                                        focusNodeYear
                                                            .requestFocus();
                                                      }
                                                      if (errorAge) {
                                                        setState(() {
                                                          errorAge = false;
                                                        });
                                                      }
                                                      if (confirmAge) {
                                                        setState(() {
                                                          confirmAge = false;
                                                        });
                                                      }
                                                      //if (dayController.text.length == 2 && monthController.text.length == 2 && yearController.text.length == 4) {
                                                      if (yearController
                                                              .text.length ==
                                                          4) {
                                                        setState(() {
                                                          canGoNextDate = true;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          canGoNextDate = false;
                                                        });
                                                      }
                                                    },
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(
                                                          2), // for mobile
                                                    ],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline3
                                                        ?.copyWith(
                                                            color:
                                                                AppColors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: AppColors
                                                            .white,
                                                        hintText: "MM",
                                                        hintStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .headline3
                                                            ?.copyWith(
                                                                color: AppColors
                                                                    .grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                        errorStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyText2
                                                            ?.copyWith(
                                                                color: AppColors
                                                                    .red),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                12, 8, 12, 8)),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(
                                                                context)!
                                                            .year +
                                                        " (*)",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.copyWith(
                                                            color: AppColors
                                                                .white),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.18,
                                                child: Material(
                                                  elevation: 4,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: TextFormField(
                                                    focusNode: focusNodeYear,
                                                    controller: yearController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      if (errorAge) {
                                                        setState(() {
                                                          errorAge = false;
                                                        });
                                                      }
                                                      if (confirmAge) {
                                                        setState(() {
                                                          confirmAge = false;
                                                        });
                                                      }
                                                      //if (dayController.text.length == 2 && monthController.text.length == 2 && yearController.text.length == 4) {
                                                      if (yearController
                                                              .text.length ==
                                                          4) {
                                                        setState(() {
                                                          canGoNextDate = true;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          canGoNextDate = false;
                                                        });
                                                      }
                                                    },
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(
                                                          4), // for mobile
                                                    ],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline3
                                                        ?.copyWith(
                                                            color:
                                                                AppColors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: AppColors
                                                            .white,
                                                        hintText: "YYYY",
                                                        hintStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .headline3
                                                            ?.copyWith(
                                                                color: AppColors
                                                                    .grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                        errorStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyText2
                                                            ?.copyWith(
                                                                color: AppColors
                                                                    .red),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 1.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                12, 8, 12, 8)),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      errorAge
                                          ? Container(
                                              padding: const EdgeInsets.all(8),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              decoration: const BoxDecoration(
                                                color: AppColors.red,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .errorDate,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          ?.copyWith(
                                                              color: AppColors
                                                                  .white),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      AnimatedOpacity(
                                        opacity: confirmAge ? 1.0 : 0.0,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.fastOutSlowIn,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.03),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(
                                                                context)!
                                                            .dateOfBirth +
                                                        ": ",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.copyWith(
                                                            color:
                                                                AppColors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  (dayController.text.length ==
                                                              2 &&
                                                          monthController.text
                                                                  .length ==
                                                              2 &&
                                                          yearController.text
                                                                  .length ==
                                                              4)
                                                      ? Text(
                                                          DateTimeUtils().formatDateTimeToStringDDMMYYYY(
                                                              startDate,
                                                              Localizations
                                                                      .localeOf(
                                                                          context)
                                                                  .languageCode),
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headline3
                                                              ?.copyWith(
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal),
                                                          textAlign:
                                                              TextAlign.left,
                                                        )
                                                      : Text(
                                                          startDate.year
                                                              .toString(),
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headline3
                                                              ?.copyWith(
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01),
                                              Row(
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(
                                                                context)!
                                                            .age +
                                                        ": ",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.copyWith(
                                                            color:
                                                                AppColors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  Text(
                                                    calculateAge(startDate,
                                                            DateTime.now())
                                                        .toStringAsFixed(0),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline3
                                                        ?.copyWith(
                                                            color:
                                                                AppColors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      vertical:
                                          MediaQuery.of(context).size.width *
                                              0.04),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01),
                                      Icon(
                                        Icons.visibility,
                                        color: AppColors.white,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.06,
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .visibleFact,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              ?.copyWith(
                                                  color: AppColors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02),
                                      ElevatedButton(
                                        onPressed: canGoNextDate == false
                                            ? null
                                            : () async {
                                                FocusScopeNode currentFocus =
                                                    FocusScope.of(context);
                                                if (!currentFocus
                                                    .hasPrimaryFocus) {
                                                  currentFocus.unfocus();
                                                }
                                                if (confirmAge == false) {
                                                  // Check if Date is Valid
                                                  DateTime? date;
                                                  if (dayController
                                                              .text.length ==
                                                          2 &&
                                                      monthController
                                                              .text.length ==
                                                          2 &&
                                                      yearController
                                                              .text.length ==
                                                          4) {
                                                    // Full Date
                                                    String dateString =
                                                        yearController.text +
                                                            "-" +
                                                            monthController
                                                                .text +
                                                            "-" +
                                                            dayController.text;
                                                    date = convertToDate(
                                                        dateString,
                                                        "yyyy-MM-dd",
                                                        context);
                                                  } else {
                                                    // Only Year
                                                    dayController.text = "";
                                                    monthController.text = "";
                                                    String dateString =
                                                        yearController.text +
                                                            "-1-1";
                                                    date = convertToDate(
                                                        dateString,
                                                        "yyyy-MM-dd",
                                                        context);
                                                  }
                                                  if (date == null ||
                                                      date.isAfter(
                                                          DateTime.now()) ||
                                                      DateTime.now()
                                                              .difference(date)
                                                              .inDays >
                                                          36500) {
                                                    setState(() {
                                                      errorAge = true;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      startDate = date!;
                                                      confirmAge = true;
                                                      canGoNextDate = false;
                                                    });
                                                    await Future.delayed(
                                                        const Duration(
                                                            seconds: 1));
                                                    setState(() {
                                                      canGoNextDate = true;
                                                    });
                                                  }
                                                } else {
                                                  _pageControllerData.nextPage(
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.ease,
                                                  );
                                                }
                                              },
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: canGoNextDate
                                              ? AppColors.black
                                              : AppColors.white
                                                  .withOpacity(0.2),
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.06,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(15),
                                          primary: canGoNextDate
                                              ? AppColors.white
                                              : AppColors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.1),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .whatsYourGender,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline1
                                              ?.copyWith(
                                                  color: AppColors.white,
                                                  fontSize: 30),
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .changeLater,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              ?.copyWith(
                                                  color: AppColors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05),
                                        Material(
                                          elevation: 4,
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.07,
                                            padding: const EdgeInsets.fromLTRB(
                                                18, 8, 6, 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: AppColors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .female,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline3
                                                        ?.copyWith(
                                                            color:
                                                                AppColors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                Transform.scale(
                                                  scale: 1.5,
                                                  child: Checkbox(
                                                    value: gender == 1,
                                                    onChanged: (boolean) {
                                                      setState(() {
                                                        gender = 1;
                                                      });
                                                    },
                                                    checkColor: AppColors.white,
                                                    activeColor:
                                                        AppColors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    side: const BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02),
                                        Material(
                                          elevation: 4,
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.07,
                                            padding: const EdgeInsets.fromLTRB(
                                                18, 8, 6, 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: AppColors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .male,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline3
                                                        ?.copyWith(
                                                            color:
                                                                AppColors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                Transform.scale(
                                                  scale: 1.5,
                                                  child: Checkbox(
                                                    value: gender == 0,
                                                    onChanged: (boolean) {
                                                      setState(() {
                                                        gender = 0;
                                                      });
                                                    },
                                                    checkColor: AppColors.white,
                                                    activeColor:
                                                        AppColors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    side: const BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02),
                                        Material(
                                          elevation: 4,
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.07,
                                            padding: const EdgeInsets.fromLTRB(
                                                18, 8, 6, 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: AppColors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .transgender,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline3
                                                        ?.copyWith(
                                                            color:
                                                                AppColors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                Transform.scale(
                                                  scale: 1.5,
                                                  child: Checkbox(
                                                    value: gender == 2,
                                                    onChanged: (boolean) {
                                                      setState(() {
                                                        gender = 2;
                                                      });
                                                    },
                                                    checkColor: AppColors.white,
                                                    activeColor:
                                                        AppColors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    side: const BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      vertical:
                                          MediaQuery.of(context).size.width *
                                              0.04),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01),
                                      Icon(
                                        Icons.visibility,
                                        color: AppColors.white,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.06,
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .visibleFact,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              ?.copyWith(
                                                  color: AppColors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: gender == null
                                            ? null
                                            : () async {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                await Future.delayed(
                                                    const Duration(seconds: 1));
                                                addUser();
                                              },
                                        child: !isLoading
                                            ? Icon(
                                                Icons.arrow_forward_ios,
                                                color: gender != null
                                                    ? AppColors.black
                                                    : AppColors.white
                                                        .withOpacity(0.2),
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                              )
                                            : SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                                child: Center(
                                                  child: SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.04,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.04,
                                                    child:
                                                        const CircularProgressIndicator(
                                                      color: AppColors.black,
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(15),
                                          primary: gender != null
                                              ? AppColors.white
                                              : AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
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
      ),
      //bottomSheet: returnCorrectBottomSheet(),
    );
  }
}
