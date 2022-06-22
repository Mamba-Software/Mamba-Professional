import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Permissions/PermisionsService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/DateTime/SelectDateTimeDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import '../../Data/DataService/BrandDataService.dart';
import '../../Data/DataService/UserDataService.dart';
import '../../Globals/GlobalVars.dart';
import '../../Globals/NotificationService/NotificationService.dart';
import '../../Globals/Utils/Images/ImageUtils.dart';
import '../../Globals/Widgets/Components/Gender/GenderWidget.dart';
import '../../Globals/Widgets/Components/Images/CircularImage.dart';
import '../../Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewWhite.dart';
import '../Authentication/SplashScreen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
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
  final ScrollController _scrollController = ScrollController();
  bool getStarted = false;
  // Onboarding Process
  int _currentPageOnboarding = 0;
  final int _numPagesOnboarding = 3;
  final PageController _pageControllerOnboarding = PageController(initialPage: 0);
  // Page 1: OnBoarding
  // Form Key
  final _formKey = GlobalKey<FormState>();
  // Tab Controller
  double addEventTabValue = 0.33;
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false, false, false, false];
  // Title Controller
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  // Profile Image
  var _image;
  // Nick Controller
  var nickController = TextEditingController();
  String nick = "";
  bool isSearchAlias = false;
  bool nickOkay = false;
  bool nickUsed = false;
  // Date Of Birth
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

  @override
  initState() {
    //isLoading = true;
  }

  Future getDate() async {
    var pickedDateTemp =  await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectDateTimeDialog(
            title: AppLocalizations.of(context)!.selectDateOfBirth,
        )
    );
    if (pickedDateTemp != null) {
      setState(() {
        startDateController.text = DateTimeUtils().formatDateTimeToStringDDMMYYYY(pickedDateTemp, Localizations.localeOf(context).languageCode);
      });
    }
  }

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    File? temp = await ImageUtils().pickImage();
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.easeIn
    );
    setState(() {
      _image = temp;
    });
  }

  Future<void> checkIfNickExists(String nick) async {
    setState(() {
      isSearchAlias = true;
    });
    bool result = await _userDataService.checkIfNicknameExists(nick);
    if (result) {
      Future.delayed(Duration(milliseconds: 500), () async {
        setState(() {
          nickOkay = true;
          nickUsed = false;
          isSearchAlias = false;
        });
      });
    } else {
      Future.delayed(Duration(milliseconds: 500), () async {
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
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : AppColors.whiteTrans,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Future<void> addUser() async {
    setState(() {
      isLoading = true;
    });
    _notificationService = NotificationService();
    String name = firstNameController.text.trim()+" "+lastNameController.text.trim();
    bool isTrainer = false;
    int role = 0;
    if (_value == 1) {
      isTrainer = true;
      role = 5;
    }
    await _userDataService.updateUser(currentUser.id!, name,firstNameController.text.trim(), lastNameController.text.trim(), nick, startDateController.text, gender!, _image, isTrainer);
    await _userDataService.addUserNickname(currentUser.id!, nick);
    _notificationService!.wellcomeUser(currentUser.id!);
    Navigator.pushReplacement(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => SplashScreen(),
          settings: RouteSettings(name: 'SplashScreen'),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.mainColor,
      body: isLoading ?
      LoadingViewWhite()
        :
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.mainColor
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
              physics: getStarted ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: <Widget>[
                Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height*0.1),
                    Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Image(
                              image: AssetImage(Constants.onboardingApp),
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Text(
                            'Connect people\naround the world',
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height*0.1),
                    Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Image(
                              image: AssetImage(Constants.onboardingApp),
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Text(
                            'Connect people\naround the world',
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _scrollController,
                  child: Container(
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height*0.1),
                        Padding(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Image(
                                  image: AssetImage(Constants.onboardingApp),
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.05),
                              Text(
                                'Connect people\naround the world',
                                style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                              ),
                              SizedBox(height: 15.0),
                              Text(
                                'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildPageIndicator(),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height),
                        Container(
                          height: MediaQuery.of(context).size.height*0.7,
                          child: PageView(
                            physics: NeverScrollableScrollPhysics(),
                            controller: _pageControllerOnboarding,
                            onPageChanged: (int page) {
                              setState(() {
                                _currentPageOnboarding = page;
                              });
                            },
                            children: <Widget>[
                              Container(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.1),
                                    child: Center(
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.yourInfo,
                                              style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                                            ),
                                            SizedBox(height: MediaQuery.of(context).size.height*0.05),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context).size.width * 0.45,
                                                  child: Column(
                                                    children: [
                                                      Container(
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

                                                            Container(
                                                              width: MediaQuery.of(context).size.width * 0.45,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: TextFormField(
                                                                      controller: firstNameController,
                                                                      keyboardType: TextInputType.name,
                                                                      validator: (val) => val!.length < 1 ? AppLocalizations.of(context)!.nameCompletoError : null,
                                                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.black),
                                                                      textCapitalization: TextCapitalization.words,
                                                                      decoration: InputDecoration(
                                                                        hintText: AppLocalizations.of(context)!.nameCompletoError,
                                                                        hintStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.black),
                                                                        errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                                        border: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: Colors.black,
                                                                                width: 1.0
                                                                            )
                                                                        ),
                                                                        enabledBorder: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: Colors.black,
                                                                                width: 1.0
                                                                            )
                                                                        ),
                                                                        focusedBorder: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: Colors.black,
                                                                                width: 1.0
                                                                            )
                                                                        ),
                                                                        errorBorder: UnderlineInputBorder(
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
                                                      Container(
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
                                                            Container(
                                                              width: MediaQuery.of(context).size.width * 0.85,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: TextFormField(
                                                                      controller: lastNameController,
                                                                      keyboardType: TextInputType.name,
                                                                      validator: (val) => val!.length < 1 ? AppLocalizations.of(context)!.lastNameError : null,
                                                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.black),
                                                                      textCapitalization: TextCapitalization.words,
                                                                      decoration: InputDecoration(
                                                                        hintStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.black),
                                                                        hintText: AppLocalizations.of(context)!.lastNameError,
                                                                        errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                                        border: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: Colors.black,
                                                                                width: 1.0
                                                                            )
                                                                        ),
                                                                        enabledBorder: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: Colors.black,
                                                                                width: 1.0
                                                                            )
                                                                        ),
                                                                        focusedBorder: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: Colors.black,
                                                                                width: 1.0
                                                                            )
                                                                        ),
                                                                        errorBorder: UnderlineInputBorder(
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
                                                Container(
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
                                                              color: Colors.black,
                                                            ),
                                                            SizedBox(height: MediaQuery.of(context).size.width*0.02),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  AppLocalizations.of(context)!.uploadPhoto,
                                                                  style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.black),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                                                Icon(Icons.insert_photo, size: MediaQuery.of(context).size.width*0.04, color: Colors.black,),
                                                              ],
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
                                                              color: AppColors.black,
                                                            ),
                                                            SizedBox(height: MediaQuery.of(context).size.width*0.02),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  AppLocalizations.of(context)!.uploadPhoto,
                                                                  style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.black),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                                                Icon(Icons.edit, size: MediaQuery.of(context).size.width*0.04, color: Colors.black,),
                                                              ],
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
                                                Container(
                                                  width: MediaQuery.of(context).size.width * 0.4,
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
                                                            getDate();
                                                          },
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            children: <Widget>[
                                                              new Flexible(
                                                                child: TextFormField(
                                                                  controller: startDateController,
                                                                  readOnly: true,
                                                                  enabled: false,
                                                                  style: startDateController.text == nullDate ? Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red) : Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.black),
                                                                  decoration: InputDecoration(
                                                                    hintStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.black),
                                                                    hintText: AppLocalizations.of(context)!.noDateOfBirth,
                                                                    errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                                    border: UnderlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: Colors.black,
                                                                            width: 1.0
                                                                        )
                                                                    ),
                                                                    enabledBorder: UnderlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: Colors.black,
                                                                            width: 1.0
                                                                        )
                                                                    ),
                                                                    focusedBorder: UnderlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: Colors.black,
                                                                            width: 1.0
                                                                        )
                                                                    ),
                                                                    errorBorder: UnderlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: Colors.red,
                                                                            width: 1.0
                                                                        )
                                                                    ),
                                                                    disabledBorder: UnderlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: Colors.black,
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
                                                              Container(
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
                                                Container(
                                                  width: MediaQuery.of(context).size.width * 0.35,
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            AppLocalizations.of(context)!.nickname,
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
                                                            child: Container(
                                                              width: MediaQuery.of(context).size.width * 0.35,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: TextFormField(
                                                                      controller: nickController,
                                                                      keyboardType: TextInputType.name,
                                                                      validator: (val) => val!.length < 1 ? AppLocalizations.of(context)!.nicknameError : null,
                                                                      onChanged: (val) {
                                                                        nick = val.replaceAll(' ', '');
                                                                        nickController.text = nick;
                                                                        nickController.selection = TextSelection.fromPosition(TextPosition(offset: nickController.text.length));
                                                                        checkIfNickExists(nick);
                                                                      },
                                                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.black),
                                                                      decoration: InputDecoration(
                                                                        hintStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.black),
                                                                        hintText: "${AppLocalizations.of(context)!.nicknameError}",
                                                                        errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                                        border: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: Colors.black,
                                                                                width: 1.0
                                                                            )
                                                                        ),
                                                                        enabledBorder: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: Colors.black,
                                                                                width: 1.0
                                                                            )
                                                                        ),
                                                                        focusedBorder: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color: Colors.black,
                                                                                width: 1.0
                                                                            )
                                                                        ),
                                                                        errorBorder: UnderlineInputBorder(
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
                                                              Icon(Icons.check, size: 25, color: Colors.green,),
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
                                                              Icon(Icons.close, size: 25, color: Colors.red,),
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
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.1),
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.typeProfile,
                                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                                          ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                                            title: Padding(
                                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.01),
                                              child: Text(
                                                AppLocalizations.of(context)!.client,
                                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            subtitle: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    AppLocalizations.of(context)!.clientDescription,
                                                    style: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.black),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: Transform.scale(
                                              scale: 1.5,
                                              child: Radio(
                                                value: 2,
                                                groupValue: _value,
                                                activeColor: AppColors.black,
                                                fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _value = int.parse(value.toString());
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  height: MediaQuery.of(context).size.height*0.20,
                                                  child: Image.asset(Constants.clientImage)
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                          ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                                            title: Padding(
                                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.01),
                                              child: Text(
                                                AppLocalizations.of(context)!.trainer,
                                                style: Theme.of(context).textTheme.headline3?.copyWith( color: AppColors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            subtitle: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    AppLocalizations.of(context)!.trainerDescription,
                                                    style: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.black),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: Transform.scale(
                                              scale: 1.5,
                                              child: Radio(
                                                value: 1,
                                                groupValue: _value,
                                                activeColor: AppColors.black,
                                                fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _value = int.parse(value.toString());
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  height: MediaQuery.of(context).size.height*0.17,
                                                  child: Image.asset(Constants.personalTrainerImage)
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.15),
                      ],
                    ),
                  ),
                ),
              ],
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
    return AppColors.black;
  }

  Widget returnCorrectBottomSheet() {
    if (!getStarted) {
      return _currentPage != _numPages - 1 ? Container(
        height: MediaQuery.of(context).size.height*0.1,
        width: double.infinity,
        color: AppColors.mainColor,
        child: Align(
          alignment: FractionalOffset.centerRight,
          child: FlatButton(
            onPressed: () async {

              if (_currentPage == 1) {
                  await PermisionsService().getUserLocation();
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
              } else {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              }

            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                    AppLocalizations.of(context)!.next,
                    style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                ),
                SizedBox(width: 10.0),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.height*0.05,
                ),
              ],
            ),
          ),
        ),
      ) : GestureDetector(
        onTap: () {
          setState(() {
            getStarted = true;
          });
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(seconds: 1),
              curve: Curves.easeIn
          );
        },
        child: Container(
          height: MediaQuery.of(context).size.height*0.1,
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
      );
    } else {
      if (_currentPageOnboarding == 0) {
        return Container(
          height: MediaQuery.of(context).size.height*0.1,
          width: double.infinity,
          color: AppColors.mainColor,
          child: Align(
            alignment: FractionalOffset.centerRight,
            child: FlatButton(
              onPressed: () {
                if (validateInformation()) {
                  setState(() {
                    addEventTabValue += 0.33;
                  });
                  _pageControllerOnboarding.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                      AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                  ),
                  SizedBox(width: 10.0),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.height*0.05,
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        if (_value == 0) {
          return Container(
            height: MediaQuery.of(context).size.height*0.1,
            width: double.infinity,
            color: AppColors.mainColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: FractionalOffset.centerLeft,
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        addEventTabValue -= 0.33;
                      });
                      _pageControllerOnboarding.previousPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: MediaQuery.of(context).size.height*0.05,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          AppLocalizations.of(context)!.back,
                          style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            height: MediaQuery.of(context).size.height*0.1,
            width: double.infinity,
            color: AppColors.mainColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: FractionalOffset.centerLeft,
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        addEventTabValue -= 0.33;
                      });
                      _pageControllerOnboarding.previousPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: MediaQuery.of(context).size.height*0.05,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          AppLocalizations.of(context)!.back,
                          style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: FractionalOffset.centerRight,
                  child: FlatButton(
                    onPressed: () {
                      addUser();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                            AppLocalizations.of(context)!.start,
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.black)
                        ),
                        SizedBox(width: 10.0),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: MediaQuery.of(context).size.height*0.05,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }



      }

    }

  }
}
