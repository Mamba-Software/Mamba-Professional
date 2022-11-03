import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDateDialog.dart';
import '../../Data/DataService/User/UserDataService.dart';
import '../../Globals/GlobalVars.dart';
import '../../Globals/NotificationService/NotificationService.dart';
import '../../Globals/Utils/Images/ImageUtils.dart';
import '../../Globals/Widgets/Components/Gender/GenderWidget.dart';
import '../../Globals/Widgets/Components/Images/CircularImage.dart';
import 'SplashScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  // Geolocator
  final Geolocator geolocator = Geolocator();
  bool locatorDialog = false;
  // Acceso a Base de Datos
  NotificationService? _notificationService;
  // Boolean Loading
  bool isLoading = false;
  // Wellcome Pages
  int _currentPage = 0;
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  // Page 1: OnBoarding
  // Form Key
  final _formKey = GlobalKey<FormState>();
  // Title Controller
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  // Profile Image
  File? _image;
  // Nick Controller
  var nickController = TextEditingController();
  String nick = "";
  bool isSearchAlias = false;
  bool nickOkay = false;
  bool nickUsed = false;
  // Date Of Birth
  DateTime startDate = DateTime(DateTime.now().year,DateTime.now().month, DateTime.now().day, 0, 0);
  TextEditingController startDateController = TextEditingController();
  String nullDate = "";
  bool errorDate = false;
  // Gender Widget value
  int? gender;
  bool errorGender = false;
  void updateGender(int newGender) {
    setState(() {
      gender = newGender;
    });
  }
  // Page 2: Type
  // Type of Users
  int _value = 0;
  bool errorType = false;

  Future selectDate() async {
    var pickedDateTemp =  await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectDateDialog(
          title: AppLocalizations.of(context)!.selectDateOfBirth,
          startDate: startDate,
          onlyFuture: false,
          dateOfWeek: false,
        )
    );
    if (pickedDateTemp != null) {
      setState(() {
        startDate = pickedDateTemp;
        startDateController.text = DateTimeUtils().formatDateTimeToStringDDMMYYYY(pickedDateTemp, Localizations.localeOf(context).languageCode);
      });
    }
  }

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    mixpanel!.timeEvent("onboarding_userdata_image");
    File? temp = await ImageUtils().pickImage();
    setState(() {
      _image = temp;
    });
    mixpanel!.track('onboarding_userdata_image');
  }

  Future<void> checkIfNickExists(String nick) async {
    setState(() {
      isSearchAlias = true;
    });
    bool result = await _userDataService.checkIfNicknameExists(nick);
    if (result) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        setState(() {
          nickOkay = true;
          nickUsed = false;
          isSearchAlias = false;
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500), () async {
        setState(() {
          nickOkay = false;
          nickUsed = true;
          isSearchAlias = false;
        });
      });
    }
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : AppColors.whiteTrans,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Future<void> addUser() async {
    mixpanel!.track('onboarding_finish');
    _notificationService = NotificationService();
    String name = firstNameController.text.trim()+" "+lastNameController.text.trim();
    await _userDataService.updateUser(currentUser.id!, name,firstNameController.text.trim(), lastNameController.text.trim(), nick, startDateController.text, gender!, _image, true);
    await _userDataService.addUserNickname(currentUser.id!, nick);
    _notificationService!.wellcomeUser(currentUser.id!);
    sendMixPanelDataUsers();
    Navigator.pushReplacement(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => SplashScreen(),
          settings: const RouteSettings(name: 'SplashScreen'),
        )
    );
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

  @override
  void initState() {
    mixpanel!.track('onboarding_wellcome');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height*0.90,
            decoration: const BoxDecoration(
                color: AppColors.black
              /*
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.1, 0.4, 0.7, 0.9],
                  colors: [
                    AppColors.mainColor,
                    AppColors.mainColorGrad1,
                    AppColors.mainColorGrad1,
                    AppColors.mainColorGrad2,
                  ],
                ),
                 */
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.05),
              child: PageView(
                physics: const ClampingScrollPhysics(),
                controller: _pageController,
                onPageChanged: (int page) {
                  if (page == 0) {
                    mixpanel!.track('onboarding_wellcome');
                  } else if (page == 1) {
                    mixpanel!.track('onboarding_trainers');
                  } else if (page == 2) {
                    mixpanel!.track('onboarding_userdata');
                  }
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center                      ,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height*0.17),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(Constants.logoExtended),
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.05),
                            Text(
                              AppLocalizations.of(context)!.wellcomeMessage,
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.1),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height*0.17),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(Constants.themeSystemImage),
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.05),
                            Text(
                              AppLocalizations.of(context)!.trainersOnboarding,
                              style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                            ),
                            const SizedBox(height: 15.0),
                            Text(
                              AppLocalizations.of(context)!.trainersOnboardingDesc,
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.1),
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height*0.07),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.beforeMovingOn,
                                style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.05),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.45,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.45,
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.firstName,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ],
                                              ),

                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.45,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: firstNameController,
                                                        keyboardType: TextInputType.name,
                                                        validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError : null,
                                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white,),
                                                        textCapitalization: TextCapitalization.words,
                                                        decoration: InputDecoration(
                                                          hintText: AppLocalizations.of(context)!.nameCompletoError,
                                                          hintStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.white,),
                                                          errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                          border: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.white,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          enabledBorder: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.white,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          focusedBorder: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.white,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          errorBorder: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.red,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          disabledBorder: InputBorder.none,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.45,
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.lastName,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.85,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: lastNameController,
                                                        keyboardType: TextInputType.name,
                                                        validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.lastNameError : null,
                                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white,),
                                                        textCapitalization: TextCapitalization.words,
                                                        decoration: InputDecoration(
                                                          hintStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.white,),
                                                          hintText: AppLocalizations.of(context)!.lastNameError,
                                                          errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                          border: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.white,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          enabledBorder: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.white,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          focusedBorder: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.white,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          errorBorder: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.red,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          disabledBorder: InputBorder.none,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.25,
                                    child: Center(
                                        child: _image == null ?
                                        GestureDetector(
                                          onTap: () {
                                            getImage();
                                            FocusScopeNode currentFocus = FocusScope.of(context);
                                            if (!currentFocus.hasPrimaryFocus) {
                                              currentFocus.unfocus();
                                            }
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              CircularImage(
                                                size: MediaQuery.of(context).size.width * 0.25,
                                                image: "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53",
                                                borderWidth: 1.5,
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: MediaQuery.of(context).size.width*0.02),
                                              FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(context)!.uploadPhoto,
                                                      style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    SizedBox(width: MediaQuery.of(context).size.width*0.005),
                                                    Icon(Icons.insert_photo, size: MediaQuery.of(context).size.width*0.04, color: Colors.white,),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ) :
                                        GestureDetector(
                                          onTap: getImage,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              CircularImage(
                                                size: MediaQuery.of(context).size.width * 0.25,
                                                file: _image,
                                                borderWidth: 1,
                                                color: AppColors.white,
                                              ),
                                              SizedBox(height: MediaQuery.of(context).size.width*0.02),
                                              FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(context)!.uploadPhoto,
                                                      style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    SizedBox(width: MediaQuery.of(context).size.width*0.005),
                                                    Icon(Icons.edit, size: MediaQuery.of(context).size.width*0.04, color: Colors.white,),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )

                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.42,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.dateOfBirth,
                                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                        GestureDetector(
                                            onTap: () {
                                              FocusScopeNode currentFocus = FocusScope.of(context);
                                              if (!currentFocus.hasPrimaryFocus) {
                                                currentFocus.unfocus();
                                              }
                                              selectDate();
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Flexible(
                                                  child: TextFormField(
                                                    controller: startDateController,
                                                    readOnly: true,
                                                    enabled: false,
                                                    style: startDateController.text == nullDate ? Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red) : Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white,),
                                                    decoration: InputDecoration(
                                                      hintStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.white,),
                                                      hintText: AppLocalizations.of(context)!.noDateOfBirth,
                                                      errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                      border: const UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors.white,
                                                              width: 1.0
                                                          )
                                                      ),
                                                      enabledBorder: const UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors.white,
                                                              width: 1.0
                                                          )
                                                      ),
                                                      focusedBorder: const UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors.white,
                                                              width: 1.0
                                                          )
                                                      ),
                                                      errorBorder: const UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors.red,
                                                              width: 1.0
                                                          )
                                                      ),
                                                      disabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: errorDate ? Colors.red : Colors.white,
                                                              width: 1.0
                                                          )
                                                      ),
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                        errorDate ? Column(
                                          children: [
                                            SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width * 0.4,
                                                  child: Text(
                                                    AppLocalizations.of(context)!.selectDateOfBirth,
                                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                    textAlign: TextAlign.left,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ) : Container(),
                                        SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.35,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.user,
                                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                FocusScopeNode currentFocus = FocusScope.of(context);
                                                if (!currentFocus.hasPrimaryFocus) {
                                                  currentFocus.unfocus();
                                                }
                                              },
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.35,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: nickController,
                                                        keyboardType: TextInputType.name,
                                                        validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nicknameError : null,
                                                        onChanged: (val) {
                                                          nick = val.replaceAll(' ', '');
                                                          nickController.text = nick;
                                                          nickController.selection = TextSelection.fromPosition(TextPosition(offset: nickController.text.length));
                                                          checkIfNickExists(nick);
                                                        },
                                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white,),
                                                        decoration: InputDecoration(
                                                          hintStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.white,),
                                                          hintText: AppLocalizations.of(context)!.nicknameError,
                                                          errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                          border: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.white,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          enabledBorder: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.white,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          focusedBorder: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.white,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          errorBorder: const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.red,
                                                                  width: 1.0
                                                              )
                                                          ),
                                                          disabledBorder: InputBorder.none,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        nickOkay && !nickUsed && nickController.text.isNotEmpty ? Column(
                                          children: [
                                            SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!.nicknameAvailable,
                                                  style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.green),
                                                  textAlign: TextAlign.left,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                                const Icon(Icons.check, size: 25, color: Colors.green,),
                                              ],
                                            ),
                                          ],
                                        ) : Container(),
                                        !nickOkay && nickUsed && nickController.text.isNotEmpty ? Column(
                                          children: [
                                            SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!.nicknameOcuppied,
                                                  style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.red),
                                                  textAlign: TextAlign.left,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                                const Icon(Icons.close, size: 25, color: Colors.red,),
                                              ],
                                            ),
                                          ],
                                        ) : Container(),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.gender,
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                  GenderWidget(
                                      genderTemp: gender,
                                      selectedGenderChanged: (gender) {
                                        updateGender(gender);
                                        setState(() {
                                          errorGender = false;
                                        });
                                      }
                                  ),
                                  errorGender ? Column(
                                    children: [
                                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.registerGenderError,
                                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ) : Container(),
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
          ),
        ),
      ),
      bottomSheet: returnCorrectBottomSheet(),
    );
  }

  bool validateInformation() {
    bool result = true;
    if (!_formKey.currentState!.validate()) {
      result = false;
    }
    if (nickUsed) {
      result = false;
    }
    if (startDateController.text == nullDate) {
      setState(() {
        errorDate = true;
      });
      result = false;
    } else {
      if (DateTimeUtils().formatStringToDateTimeDDMMYYYY(startDateController.text, Localizations.localeOf(context).languageCode).isAfter(DateTime.now())) {
        setState(() {
          errorDate = true;
        });
        result = false;
      } else {
        setState(() {
          errorDate = false;
        });
      }
    }
    if (gender == null) {
      setState(() {
        errorGender = true;
      });
      result = false;
    }
    if (gender != null) {
      setState(() {
        errorGender = false;
      });
    }
    return result;
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return AppColors.white;
  }

  Widget returnCorrectBottomSheet() {
    return _currentPage != _numPages - 1 ? Container(
      height: MediaQuery.of(context).size.height*0.12,
      width: double.infinity,
      color: AppColors.black,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildPageIndicator(),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.01),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Align(
              alignment: FractionalOffset.centerRight,
              child: TextButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(width: 10.0),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.height*0.05,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ) : !isLoading ? GestureDetector(
      onTap: () {
        if (validateInformation()) {
          setState(() {
            isLoading = true;
          });
          addUser();
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height*0.12,
        width: double.infinity,
        color: Colors.white,
        child: Align(
          alignment: FractionalOffset.center,
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.02),
            child: Text(
                AppLocalizations.of(context)!.letsGo,
                style: Theme.of(context).textTheme.headline1!.copyWith(color: AppColors.black)
            ),
          ),
        ),
      ),
    ) : Container(
      height: MediaQuery.of(context).size.height*0.1,
      width: double.infinity,
      color: Colors.white,
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.06,
            height: MediaQuery.of(context).size.height * 0.03,
            child: const CircularProgressIndicator(
              color: AppColors.black,
              strokeWidth: 2.5,
            ),
          ),
    ),
      );
  }
}
