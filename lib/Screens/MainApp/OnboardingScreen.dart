import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import '../../Data/DataService/BrandDataService.dart';
import '../../Data/DataService/UserDataService.dart';
import '../../Globals/NotificationService/NotificationService.dart';
import '../../Globals/Utils/Images/ImageUtils.dart';
import '../../Globals/Widgets/Components/Images/CircularImage.dart';

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
  bool errorDate = true;
  // Gender Widget value
  int? gender;
  bool errorGender = false;
  void updateGender(int newGender) {
    setState(() {
      gender = newGender;
    });
  }

  @override
  initState() {
    //isLoading = true;
  }

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    File? temp = await ImageUtils().pickImage();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
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
              physics: NeverScrollableScrollPhysics(),
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
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                            style: Theme.of(context).textTheme.bodyText1,
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
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                            style: Theme.of(context).textTheme.bodyText1,
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
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                              style: Theme.of(context).textTheme.bodyText1,
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
                                              style: Theme.of(context).textTheme.headline1
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
                                                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
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
                                                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
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
                                                    onTap: getImage,
                                                    child: CircularImage(
                                                      size: MediaQuery.of(context).size.width * 0.25,
                                                      image: "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53",
                                                      borderWidth: 1.5,
                                                      color: Colors.black,
                                                    ),
                                                  ) :
                                                  GestureDetector(
                                                    onTap: getImage,
                                                    child: CircularImage(
                                                      size: MediaQuery.of(context).size.width * 0.25,
                                                      file: _image,
                                                      borderWidth: 1,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                  ),
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
                                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.left,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                    GestureDetector(
                                                        onTap: () {
                                                          DateTimeUtils().selectDate(context);
                                                          FocusScopeNode currentFocus = FocusScope.of(context);
                                                          if (!currentFocus.hasPrimaryFocus) {
                                                            currentFocus.unfocus();
                                                          }
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
                                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
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
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
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
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                              child: Container(
                                color: AppColors.black,
                                height: MediaQuery.of(context).size.height*0.6,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                              child: Container(
                                color: AppColors.white,
                                height: MediaQuery.of(context).size.height*0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.12),
                    ],
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
    }
    if (startDateController.text != nullDate) {
      setState(() {
        errorDate = false;
      });
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

  Widget returnCorrectBottomSheet() {
    if (!getStarted) {
      return _currentPage != _numPages - 1 ? Container(
        height: MediaQuery.of(context).size.height*0.1,
        width: double.infinity,
        color: AppColors.mainColor,
        child: Align(
          alignment: FractionalOffset.topRight,
          child: FlatButton(
            onPressed: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                    AppLocalizations.of(context)!.next,
                    style: Theme.of(context).textTheme.headline1
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
            alignment: FractionalOffset.topCenter,
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
            alignment: FractionalOffset.topRight,
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
                      style: Theme.of(context).textTheme.headline1
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
      } else if (_currentPageOnboarding == 2) {
        return Container(
          height: MediaQuery.of(context).size.height*0.1,
          width: double.infinity,
          color: AppColors.mainColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: FractionalOffset.topLeft,
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
                          style: Theme.of(context).textTheme.headline1
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: FractionalOffset.topRight,
                child: FlatButton(
                  onPressed: () {
                    print("REGISTER");
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
      } else {
        return Container(
          height: MediaQuery.of(context).size.height*0.1,
          width: double.infinity,
          color: AppColors.mainColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: FractionalOffset.topLeft,
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
                          style: Theme.of(context).textTheme.headline1
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: FractionalOffset.topRight,
                child: FlatButton(
                  onPressed: () {
                    setState(() {
                      addEventTabValue += 0.33;
                    });
                    _pageControllerOnboarding.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                          AppLocalizations.of(context)!.next,
                          style: Theme.of(context).textTheme.headline1
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
            ],
          ),
        );
      }

    }

  }
}

class GenderWidget extends StatefulWidget {
  final ValueChanged<int> selectedGenderChanged;
  final int? genderTemp;
  GenderWidget({Key? key, required this.selectedGenderChanged, required this.genderTemp}) : super(key: key);

  @override
  _GenderWidgetState createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  bool firstBuild = true;
  var gender;

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      if(widget.genderTemp != null) gender = widget.genderTemp;
      firstBuild = false;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _icon(0, text: AppLocalizations.of(context)!.male, icon: Icons.male_outlined),
        _icon(1, text: AppLocalizations.of(context)!.female, icon: Icons.female_outlined),
        _icon(2, text: AppLocalizations.of(context)!.transgender, icon: Icons.transgender_outlined),
      ],
    );
  }
  Widget _icon(int index, {required String text, required IconData icon}) {
    return SizedBox.fromSize(
      size: Size(85, 85), // button width and height
      child: ClipOval(
        child: Material(
          shape: CircleBorder(
            side: BorderSide(color: gender == index ? Colors.black : Theme.of(context).accentColor, width: 1),
          ),
          color: Theme.of(context).accentColor,
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(text,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),)
                ),
              ],
            ),
            onTap: () => {
              setState(() {
                gender = index;
                widget.selectedGenderChanged(gender);
              }),
            },
          ),
        ),
      ),
    );
  }
}