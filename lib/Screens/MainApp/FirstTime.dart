import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:provider/provider.dart';

import '../../Globals/Providers/FirebaseAnalyticsProvider.dart';

class FirstTime extends StatefulWidget {
  Locale locale;

  FirstTime({Key? key, required this.locale}) : super(key: key);

  @override
  _FirstTimeState createState() => _FirstTimeState();
}

class _FirstTimeState extends State<FirstTime> with SingleTickerProviderStateMixin{
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
  // Form Key
  final _formKey = GlobalKey<FormState>();
  // Tab Controller
  double addEventTabValue = 0.166;
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false, false, false, false];
  // Title Controller
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
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
  bool errorGender = true;
  void updateGender(int newGender) {
    setState(() {
      gender = newGender;
    });
  }
  // Profile Image
  var _image;
  bool errorImage = false;
  // Type of Users
  int _value = 0;
  bool errorType = false;
  // Invite Code
  bool? hasCode;
  var codeController = TextEditingController();
  String code = "";
  bool isSearchBrand = false;
  Brand brand = Brand();
  bool brandOkay = false;
  bool brandNotFound = false;

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';
  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';

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

  Future<void> checkIfBrandExists(String brandId) async {
    bool result = false;
    setState(() {
      isSearchBrand = true;
    });
    if (brandId.isNotEmpty) {
      result = await _brandDataService.checkIfBrandExists(brandId);
    }
    if (result) {
      brand = await _brandDataService.getBrandDetails(brandId);
      Future.delayed(Duration(milliseconds: 500), () async {
        setState(() {
          brandOkay = true;
          brandNotFound = false;
          isSearchBrand = false;
        });
      });
    } else {
      Future.delayed(Duration(milliseconds: 500), () async {
        setState(() {
          brandOkay = false;
          brandNotFound = true;
          isSearchBrand = false;
        });
      });
    }
  }

  Future<void> selectSlot(ctx, type) {
    // Initial Vars
    var startDate = DateTime.now();
    var title;
    var widgetPicker;
    // Different types of pickers
    Widget dateTimePicker = CupertinoTheme(
      data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText1,
          )
      ),
      child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, 0, 0),
          minimumDate: startDate.subtract(Duration(days: 365*80)),
          maximumDate: DateTime(startDate.year, startDate.month, 31, 0, 0),
          minimumYear: 1941,
          maximumYear: startDate.year,
          use24hFormat: true,
          onDateTimeChanged: (val) {
            setState(() {
              startDateController.text = DateFormat('dd-MM-yyyy', widget.locale.languageCode).format(val);
              errorDate = false;
            });
          }
      ),
    );
    if (type == 0) {
      title = AppLocalizations.of(context)!.selectDateOfBirth;
      widgetPicker = dateTimePicker;
    }
    showCupertinoModalPopup(
      context: ctx,
      builder: (_) => Material(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height*0.40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      child: Text(title,
                        style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,)
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.01),
                  child: widgetPicker,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: TextButton(
                      child: Text(AppLocalizations.of(context)!.entendido,
                          style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      }
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02),
            ],
          ),
        ),
      )
    );
    return Future.value("");
  }

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    File? temp = await ImageUtils().pickImage();
    setState(() {
      _image = temp;
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error(
            'Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return Geolocator.getCurrentPosition(forceAndroidLocationManager: true, desiredAccuracy: LocationAccuracy.best);
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

  bool validateTypeOfUser() {
    bool result = true;
    if (_value == 0) {
      setState(() {
        errorType = true;
      });
      result = false;
    }
    if (_value != 0) {
      setState(() {
        errorType = false;
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
    return Theme.of(context).accentColor;
  }

  Widget getTitle() {
    if (tabs[0] && !tabs[1] && !tabs[2] && !tabs[3] && !tabs[4] && !tabs[5]) {
      return Text(
        AppLocalizations.of(context)!.wellcome,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      );
    } else if (tabs[0] && tabs[1] && !tabs[2] && !tabs[3] && !tabs[4] && !tabs[5]) {
      return Text(
        AppLocalizations.of(context)!.yourInfo,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      );
    } else if (tabs[0] && tabs[1] && tabs[2] && !tabs[3] && !tabs[4] && !tabs[5]) {
      return Text(
        AppLocalizations.of(context)!.uploadPhoto,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      );
    } else if (tabs[0] && tabs[1] && tabs[2] && tabs[3] && !tabs[4] && !tabs[5]) {
      return Text(
        AppLocalizations.of(context)!.location,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      );
    } else if (tabs[0] && tabs[1] && tabs[2] && tabs[3] && tabs[4] && !tabs[5]) {
      return Text(
        AppLocalizations.of(context)!.typeProfile,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      );
    } else if (tabs[0] && tabs[1] && tabs[2] && tabs[3] && tabs[4] && tabs[5]) {
      return Text(
        AppLocalizations.of(context)!.inviteCode,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      );
    } else {
      return Text(AppLocalizations.of(context)!.wellcome, style: Theme.of(context).appBarTheme.titleTextStyle,);
    }
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
    if (brandOkay && !brandNotFound) {
      _notificationService!.userJoinsBrand(currentUser.id!, brand.id!);
      // New DataBase
      await _brandDataService.addUserToBrand(currentUser.id!, brand.id!, role);
      hasBrand = true;
    }
    Navigator.pushReplacement(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => SplashScreen(),
          settings: RouteSettings(name: 'SplashScreen'),
        )
    );
  }

  @override
  initState() {
    //isLoading = true;
    _tabController = TabController(length: 6, vsync: this);
    var startDate = DateTime.now();
    startDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      0,
      0,
    );
    startDateController.text = DateFormat('dd-MM-yyyy', widget.locale.languageCode).format(startDate);
    nullDate = startDateController.text;
    if(brandPath != null) {
      if (brandPath.queryParameters.containsKey('id')) {
        codeController.text = brandPath.queryParameters['id'];
        hasCode = true;
        checkIfBrandExists(codeController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Scaffold(
      appBar: null,
      body: LoadingViewPurple(),
    ) :
    Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.14,
        title: getTitle(),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: IgnorePointer(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.transparent,
                  onTap: (index) {
                    _selectedIndex = index;
                  },
                  tabs: [
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_outlined, color: tabs[0] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor)
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outlined, color: tabs[1] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor)
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, color: tabs[2] ? Theme.of(context).accentColor :  Theme.of(context).scaffoldBackgroundColor)
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on_outlined, color: tabs[3] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor)
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.groups, color: tabs[4] ? Theme.of(context).accentColor :  Theme.of(context).scaffoldBackgroundColor)
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_outlined, color: tabs[5] ? Theme.of(context).accentColor :  Theme.of(context).scaffoldBackgroundColor)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: addEventTabValue,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  color: Theme.of(context).accentColor,
                ),
              ],
            )
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Scaffold(
                  resizeToAvoidBottomInset: true,
                  body: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.04),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.thankyouDownload,
                                    style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.wellcomeMessage,
                                    style: Theme.of(context).textTheme.bodyText1,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    height: MediaQuery.of(context).size.height*0.20,
                                    child: Image.asset(Constants.wellcomeImage)
                                ),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.04),
                          ],
                        ),
                      )
                  ),
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height*0.04),
                              Row(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.42,
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
                                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.42,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: firstNameController,
                                                  keyboardType: TextInputType.name,
                                                  validator: (val) => val!.length < 1 ? AppLocalizations.of(context)!.nameCompletoError : null,
                                                  style: Theme.of(context).textTheme.bodyText2,
                                                  textCapitalization: TextCapitalization.words,
                                                  decoration: InputDecoration(
                                                    hintText: AppLocalizations.of(context)!.nameCompletoError,
                                                    hintStyle: Theme.of(context).textTheme.caption,
                                                    errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                    border: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey,
                                                            width: 1.0
                                                        )
                                                    ),
                                                    enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey,
                                                            width: 1.0
                                                        )
                                                    ),
                                                    focusedBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey,
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
                                  SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.42,
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
                                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.85,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: lastNameController,
                                                  keyboardType: TextInputType.name,
                                                  validator: (val) => val!.length < 1 ? AppLocalizations.of(context)!.lastNameError : null,
                                                  style: Theme.of(context).textTheme.bodyText2,
                                                  textCapitalization: TextCapitalization.words,
                                                  decoration: InputDecoration(
                                                    hintStyle: Theme.of(context).textTheme.caption,
                                                    hintText: AppLocalizations.of(context)!.lastNameError,
                                                    errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                    border: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey,
                                                            width: 1.0
                                                        )
                                                    ),
                                                    enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey,
                                                            width: 1.0
                                                        )
                                                    ),
                                                    focusedBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey,
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
                                      width: MediaQuery.of(context).size.width * 0.87,
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
                                              style: Theme.of(context).textTheme.bodyText2,
                                              decoration: InputDecoration(
                                                hintStyle: Theme.of(context).textTheme.caption,
                                                hintText: "${AppLocalizations.of(context)!.nicknameError}",
                                                errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                border: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey,
                                                        width: 1.0
                                                    )
                                                ),
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey,
                                                        width: 1.0
                                                    )
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey,
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
                                  isSearchAlias ? Center(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.03,
                                      height: MediaQuery.of(context).size.width * 0.03,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).primaryColor,
                                        strokeWidth: 1,
                                      ),
                                    ),
                                  ) : Container(),
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
                                        style: Theme.of(context).textTheme.caption,
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
                                        style: Theme.of(context).textTheme.caption,
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                      Icon(Icons.close, size: 25, color: Colors.red,),
                                    ],
                                  ),
                                ],
                              ) : Container(),
                              SizedBox(height: MediaQuery.of(context).size.height*0.03),
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
                                    selectSlot(context, 0);
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
                                          style: startDateController.text == nullDate ? Theme.of(context).textTheme.bodyText2 : Theme.of(context).textTheme.bodyText1,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
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
                                      Text(
                                        AppLocalizations.of(context)!.selectDateOfBirth,
                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ],
                              ) : Container(),
                              SizedBox(height: MediaQuery.of(context).size.height*0.03),
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
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
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
                              SizedBox(height: MediaQuery.of(context).size.height*0.15),
                            ],
                          ),
                        ),
                      )
                  ),
                  resizeToAvoidBottomInset: true,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.04),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.profilePhoto,
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.01),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.30,
                              child: Center(
                                child: _image == null ?
                                OutlinedButton(
                                  onPressed: getImage,
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      new Icon(
                                        Icons.face,
                                        color: Theme.of(context).primaryColor,
                                        size: 30.0,
                                      ),
                                    ],
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 1.5
                                    ),
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    elevation: 10,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.10, right: MediaQuery.of(context).size.height * 0.10, top: MediaQuery.of(context).size.height * 0.13),
                                  ),
                                ) :
                                GestureDetector(
                                    onTap: getImage,
                                    child: CircularImage(
                                      size: MediaQuery.of(context).size.height * 0.25,
                                      file: _image,
                                      borderWidth: 1,
                                      color: Theme.of(context).primaryColor,
                                     ),
                                ),
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.profilePhotoOptional,
                                    style: Theme.of(context).textTheme.caption,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.04),
                          ],
                        ),
                      )
                  ),
                  resizeToAvoidBottomInset: true,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.04),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.location,
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.locationPermision,
                                    style: Theme.of(context).textTheme.bodyText1,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
                            Center(
                              child: Container(
                                  height: MediaQuery.of(context).size.height *0.25,
                                  child: Image.asset(Constants.currentLocation)
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.04),
                          ],
                        ),
                      )
                  ),
                  resizeToAvoidBottomInset: true,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.04),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                              title: Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.01),
                                child: Text(
                                  AppLocalizations.of(context)!.trainer,
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!.trainerDescription,
                                      style: Theme.of(context).textTheme.caption,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                              leading: Radio(
                                value: 1,
                                groupValue: _value,
                                activeColor: Theme.of(context).accentColor,
                                fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                                onChanged: (value) {
                                  setState(() {
                                    _value = int.parse(value.toString());
                                  });
                                },
                              ),
                              trailing: Icon(
                                Icons.record_voice_over,
                                size: 30,
                                color: _value == 1 ? Theme.of(context).accentColor : Theme.of(context).primaryColor,
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
                            SizedBox(height: MediaQuery.of(context).size.height*0.04),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                              title: Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.01),
                                child: Text(
                                  AppLocalizations.of(context)!.client,
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!.clientDescription,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                ],
                              ),
                              leading: Radio(
                                value: 2,
                                groupValue: _value,
                                activeColor: Theme.of(context).accentColor,
                                fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                                onChanged: (value) {
                                  setState(() {
                                    _value = int.parse(value.toString());
                                  });
                                },
                              ),
                              trailing: Icon(
                                Icons.directions_run,
                                size: 30,
                                color: _value == 2 ? Theme.of(context).accentColor : Theme.of(context).primaryColor,
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
                            errorType ? Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.registerTypeError,
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ],
                            ) : Container(),
                            SizedBox(height: MediaQuery.of(context).size.height*0.04),
                          ],
                        ),
                      )
                  ),
                  resizeToAvoidBottomInset: true,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.04),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.alreadyCreatedFirm,
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.03),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FloatingActionButton.extended(
                                  heroTag: "10",
                                  label: Text(
                                    AppLocalizations.of(context)!.yes,
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),
                                  ),
                                  icon: Icon(Icons.check_circle_outline),
                                  backgroundColor: hasCode != null && hasCode == false ? Colors.green[200] : Colors.green,
                                  foregroundColor: Styles.white,
                                  onPressed: () {
                                    setState(() {
                                      hasCode = true;
                                    });
                                  },
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width*0.05),
                                FloatingActionButton.extended(
                                  heroTag: "11",
                                  label: Text(
                                    AppLocalizations.of(context)!.no,
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),
                                  ),
                                  icon: Icon(Icons.highlight_off),
                                  backgroundColor: hasCode != null && hasCode == true ? Colors.red[200] : Colors.red,
                                  foregroundColor: Styles.white,
                                  onPressed: ()  {
                                    setState(() {
                                      hasCode = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.03),
                            hasCode != null && hasCode == true ? Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.83,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: codeController,
                                              keyboardType: TextInputType.name,
                                              validator: (val) => val!.length < 1 ? AppLocalizations.of(context)!.inviteCodeError : null,
                                              onChanged: (val) {
                                                code = val;
                                                checkIfBrandExists(code);
                                              },
                                              style: Theme.of(context).textTheme.bodyText2,
                                              decoration: InputDecoration(
                                                hintStyle: Theme.of(context).textTheme.caption,
                                                hintText: AppLocalizations.of(context)!.inviteCodeError,
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.grey)
                                                ),
                                                errorBorder: InputBorder.none,
                                                disabledBorder: InputBorder.none,
                                                focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.grey)
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                    isSearchBrand ? Center(
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.05,
                                        height: MediaQuery.of(context).size.height * 0.025,
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context).primaryColor,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    ) : Container(),
                                  ],
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height*0.19,
                                  child: Column(
                                    children: [
                                      brandOkay && !brandNotFound && codeController.text.isNotEmpty ? Column(
                                        children: [
                                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!.brandFound,
                                                style: Theme.of(context).textTheme.bodyText2,
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                              Icon(Icons.check, size: 25, color: Colors.green,),
                                            ],
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              CircularImage(
                                                size: MediaQuery.of(context).size.width*0.2,
                                                image: brand.logoUrl,
                                                color: Theme.of(context).primaryColor,
                                                borderWidth: 1,
                                              ),
                                              SizedBox(width: MediaQuery.of(context).size.width*0.04),
                                              Expanded(
                                                child: Text(
                                                  brand.name!,
                                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ) : Container(),
                                      !brandOkay && brandNotFound && codeController.text.isNotEmpty ? Column(
                                        children: [
                                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.90,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    AppLocalizations.of(context)!.brandNotFound,
                                                    style: Theme.of(context).textTheme.bodyText2,
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                                Icon(Icons.close, size: 25, color: Colors.red,),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ) : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ) : Container(),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
                            hasCode != null && hasCode == false ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.inviteCodeOptional,
                                    style: Theme.of(context).textTheme.bodyText2,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ) : Container(),
                            SizedBox(height: MediaQuery.of(context).size.height*0.04),
                          ],
                        ),
                      )
                  ),
                  resizeToAvoidBottomInset: true,
                ),
              ],
            )
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.01),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _selectedIndex != 0 ? Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01, left: MediaQuery.of(context).size.width*0.09),
                child: Container(
                  height: 50,
                  child: FloatingActionButton.extended(
                    heroTag: "21",
                    onPressed: () {
                      if (_selectedIndex == 1) {
                        setState(() {
                          tabs[1] = false;
                        });
                      } else if (_selectedIndex == 2) {
                        setState(() {
                          tabs[2] = false;
                        });
                      } else if (_selectedIndex == 3) {
                        setState(() {
                          tabs[3] = false;
                        });
                      } else if (_selectedIndex == 4) {
                        setState(() {
                          tabs[4] = false;
                        });
                      } else if (_selectedIndex == 5) {
                          setState(() {
                            tabs[5] = false;
                          });

                        //validateTypeOfUser();
                      }
                      _tabController!.animateTo(_selectedIndex -= 1);
                      setState(() {
                        addEventTabValue -= 0.166;
                      });

                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    icon: Container(),
                    label: Text(
                      AppLocalizations.of(context)!.back,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark)),
                  ),
                ),
              ) :  Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01, left: MediaQuery.of(context).size.width*0.09),
                child: Container(
                  height: 50,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.01),
                child: Container(
                  height: 50,
                  child: FloatingActionButton.extended(
                    heroTag: "22",
                    onPressed: () async {
                      if (_selectedIndex == 0) {
                        _tabController!.animateTo(_selectedIndex += 1);
                        setState(() {
                          addEventTabValue += 0.166;
                          tabs[1] = true;
                        });
                        Provider.of<FirebaseAnalyticsProvider>(context, listen: false).sendAnalyticsEventOnboardUserData();
                      } else if (_selectedIndex == 1) {
                        if (validateInformation()) {
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            addEventTabValue += 0.166;
                            tabs[2] = true;
                          });
                          Provider.of<FirebaseAnalyticsProvider>(context, listen: false).sendAnalyticsEventOnboardUserPicture();
                          if (_image != null) {
                            Provider.of<FirebaseAnalyticsProvider>(context, listen: false).sendAnalyticsEventOnboardUserPictureSelected();
                          }
                        }
                      } else if (_selectedIndex == 2) {
                        _tabController!.animateTo(_selectedIndex += 1);
                        setState(() {
                          addEventTabValue += 0.166;
                          tabs[3] = true;
                        });
                        Provider.of<FirebaseAnalyticsProvider>(context, listen: false).sendAnalyticsEventOnboardUserLocation();
                      } else if (_selectedIndex == 3) {
                        _tabController!.animateTo(_selectedIndex += 1);
                        setState(() {
                          addEventTabValue += 0.166;
                          tabs[4] = true;
                        });
                        currentPosition = await _determinePosition();
                        Provider.of<FirebaseAnalyticsProvider>(context, listen: false).sendAnalyticsEventOnboardUserType();
                      } else if (_selectedIndex == 4) {
                        if (validateTypeOfUser()) {
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            addEventTabValue +=0.166;
                            tabs[5] = true;
                          });
                          Provider.of<FirebaseAnalyticsProvider>(context, listen: false).sendAnalyticsEventOnboardUserBrand();
                        }
                      } else if (_selectedIndex == 5) {
                        addUser();
                        Provider.of<FirebaseAnalyticsProvider>(context, listen: false).sendAnalyticsEventOnboardUserFinished();
                      }
                    },
                    backgroundColor: _selectedIndex == 5 ? Colors.green : Theme.of(context).accentColor,
                    icon: Container(),
                    label: Text(
                      _selectedIndex == 5 ? AppLocalizations.of(context)!.finish : AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.white),),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
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
      size: Size(90, 90), // button width and height
      child: ClipOval(
        child: Material(
          color: gender == index ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor,
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
                    style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold),)
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