import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/RoomDataService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class RegistrarMarca extends StatefulWidget {
  Locale? locale;
  RegistrarMarca({Key? key, this.locale}) : super(key: key);

  @override
  _RegistrarMarcaState createState() => _RegistrarMarcaState();
}

class _RegistrarMarcaState extends State<RegistrarMarca> with SingleTickerProviderStateMixin {
  // DataBase Access
  var _brandDataService = new BrandDataService();
  var _locationDataService = new LocationDataService();
  var _roomDataService = new RoomDataService();
  // Boolean isLoading
  bool isLoading = false;
  bool isFirstTime = false;
  // Tab Controller
  double addEventTabValue = 0.25;
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false, false];

  // 1st TAB: Portada
  // Logo Image
  var _image;
  bool errorImage = false;
  // Name Brand Controller
  var nameBrandController = TextEditingController();
  // Form To Validate
  final formKeyInfo = GlobalKey<FormState>();

  // 2nd TAB: Information
  // Description Controller
  var descriptionController = TextEditingController();
  // Max Members Brand
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 100;
  // Form To Validate
  final formKeyMembers = GlobalKey<FormState>();

  // 3rd TAB: Location
  // Google APIS
  googlePlace.GooglePlace? gPlace;
  googlePlace.DetailsResult? detailsResult;
  // Ubicación
  Location location = Location();
  var ubicacionController =  TextEditingController();
  bool hasLocation = false;
  bool errorLocation = false;

  // 4th TAB: Time
  // Time Picker Horari de Trabajo
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  List<double> _workShift = [];
  int? errorTime;
  // Descansos
  TextEditingController breakStartTimeController = TextEditingController();
  TextEditingController breakEndTimeController = TextEditingController();
  TimeOfDay _breakStartTime = TimeOfDay(hour: 13, minute: 00);
  TimeOfDay _breakEndTime = TimeOfDay(hour: 14, minute: 00);
  List<TimeOfDay> _breakList = [];
  List<int> removedIndex = [];
  int breakLimit = 2;
  bool errorBreakTime = false;

  Map<String, dynamic> toMap(String? id) {
    return {
      'uid': id,
    };
  }

  Map<String, dynamic> toMapisMessageRead(String? id, bool? isMessageRead) {
    return {
      'uid': id,
      'isMessageRead': isMessageRead,
    };
  }

  // Cupertino Picker
  Future<void> selectSlot(ctx, type, bool? isStart) {
    // Initial Vars
    var startDate = DateTime.now();
    var title;
    var initialDuration = 1;
    var initialMembers = 1;
    var widgetPicker;
    // Init for differnt types
    if (type == 0) {

    } else if (type == 1) {

    } else if (type == 2) {
      initialMembers = members-1;
    } else if (type == 3) {
      // No changes needed at the moment
    }

    Widget workdayTimePicker = CupertinoTheme(
      data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText1,
          )
      ),
      child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
          minimumDate: DateTime(startDate.year, startDate.month, startDate.day, 0, 0),
          maximumDate: DateTime(startDate.year, startDate.month, startDate.day, 23, 0),
          use24hFormat: true,
          minuteInterval: 30,
          onDateTimeChanged: (val) {
            if (isStart!) {
              setState(() {
                startTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(val);
              });
            } else {
              setState(() {
                endTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(val);
              });
            }
          }
      ),
    );
    Widget breakTimePicker = CupertinoTheme(
      data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText1,
          )
      ),
      child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
          minimumDate: DateTime(startDate.year, startDate.month, startDate.day, 0, 0),
          maximumDate: DateTime(startDate.year, startDate.month, startDate.day, 23, 0),
          use24hFormat: true,
          minuteInterval: 30,
          onDateTimeChanged: (val) {
            if (isStart!) {
              setState(() {
                breakStartTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(val);
              });
            } else {
              setState(() {
                breakEndTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(val);
              });
            }
          }
      ),
    );

    if (type == 3) {
      title = AppLocalizations.of(context)!.selectTime;
      widgetPicker = workdayTimePicker;
    } else if (type == 4) {
      title = AppLocalizations.of(context)!.selectTime;
      widgetPicker = breakTimePicker;
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

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    gPlace = googlePlace.GooglePlace(Platform.isAndroid ? placesAPIAndroid : placesAPIIOS);
    startTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0,));
    endTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 0,));
    breakStartTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13, 0,));
    breakEndTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0,));
    isFirstTime = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createBrand, style: Theme.of(context).appBarTheme.titleTextStyle,),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: LoadingViewPurple(),
    )
        :
      isFirstTime ?
      Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createBrand, style: Theme.of(context).appBarTheme.titleTextStyle,),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.createBrandTitle,
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  ListTile(
                    leading: Icon(
                      Icons.image_outlined,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.createBrandPortada,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info_outlined,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.createBrandInfo,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.createBrandLocation,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.calendar_today_outlined,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.createBrandTime,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ],
              ),
            ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.01, horizontal: MediaQuery.of(context).size.width*0.01),
          child: FloatingActionButton.extended(
            heroTag: "73",
            onPressed: () {
              setState(() {
                isFirstTime = false;
              });
            },
            backgroundColor: _selectedIndex == 3 ? Colors.green : Theme.of(context).accentColor,
            icon: Container(),
            label: Text(
              AppLocalizations.of(context)!.next,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white),),
          ),
        ),
      )
        :
      Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height*0.13,
          title: getTitle(),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: IgnorePointer(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_outlined, color: tabs[0] ? Theme.of(context).accentColor : Colors.grey, size: MediaQuery.of(context).size.width*0.06,)
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
                                Icon(Icons.info_outlined, color: tabs[1] ? Theme.of(context).accentColor : Colors.grey.withOpacity(0.2), size: MediaQuery.of(context).size.width*0.06,)
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
                                Icon(Icons.location_on_outlined, color: tabs[2] ? Theme.of(context).accentColor : Colors.grey.withOpacity(0.2), size: MediaQuery.of(context).size.width*0.06,)
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
                                Icon(Icons.calendar_today_outlined, color: tabs[3] ? Theme.of(context).accentColor : Colors.grey.withOpacity(0.2), size: MediaQuery.of(context).size.width*0.06,)
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
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
                            child: Form(
                              key: formKeyInfo,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!.createBrandCoverDescription,
                                          style: Theme.of(context).textTheme.caption,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                                  Text(
                                    AppLocalizations.of(context)!.logo,
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
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
                                              Icons.photo_library_outlined,
                                              color: Theme.of(context).primaryColor,
                                              size: MediaQuery.of(context).size.width * 0.08,
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
                                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.11, right: MediaQuery.of(context).size.height * 0.11, top: MediaQuery.of(context).size.height * 0.13),
                                        ),
                                      )
                                          :
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
                                  Text(
                                    AppLocalizations.of(context)!.nameBrand,
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Flexible(
                                    child: new TextFormField(
                                      controller: nameBrandController,
                                      validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameBrandError : null,
                                      style: Theme.of(context).textTheme.headline1,
                                      textAlign: TextAlign.center,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: InputDecoration(
                                        hintStyle: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey),
                                        hintText: AppLocalizations.of(context)!.nameBrandError,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.1),
                                ],
                              ),
                            )
                        ),
                      ),
                    ),
                    Scaffold(
                      resizeToAvoidBottomInset: true,
                      body: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
                            child: Form(
                              key: formKeyMembers,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!.createBrandDescDescription,
                                          style: Theme.of(context).textTheme.caption,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                                  Text(
                                    AppLocalizations.of(context)!.description,
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Flexible(
                                    child: new TextFormField(
                                        keyboardType: TextInputType.text,
                                        controller: descriptionController,
                                        textCapitalization: TextCapitalization.sentences,
                                        validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.descriptionError : null,
                                        minLines: 1,
                                        maxLines: 5,
                                        maxLength: 250,
                                        style: Theme.of(context).textTheme.bodyText2,
                                        decoration: InputDecoration(
                                          hintStyle: Theme.of(context).textTheme.caption,
                                          hintText: AppLocalizations.of(context)!.descriptionError,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                ],
                              ),
                            )
                        ),
                      ),
                    ),
                    Scaffold(
                      resizeToAvoidBottomInset: true,
                      body: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!.createBrandLocationDescription,
                                        style: Theme.of(context).textTheme.caption,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                Text(
                                  AppLocalizations.of(context)!.createBrandBaseLocation,
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                ListTile(
                                  onTap: () async {
                                    // Generate a new token here
                                    final sessionToken = Uuid().v4();
                                    final language = currentUser.idioma;
                                    final Suggestion? result = await showSearch(
                                      context: context,
                                      delegate: AddressSearch(sessionToken, language!),
                                    );
                                    // We have a result for our locations search
                                    if (result != null) {
                                      location.placeId = result.placeId;
                                      final placeDetails = await LocationPlacesSearch(sessionToken, language).getPlaceDetailFromId(location.placeId!);
                                      // Get the information on Strings
                                      if(placeDetails.street!=null) location.street = placeDetails.street!; else location.street="N/A";
                                      if(placeDetails.streetNumber!=null) location.streetNumber = placeDetails.streetNumber!; else location.streetNumber="N/A";
                                      if(placeDetails.city!=null) location.city = placeDetails.city!; else location.city="N/A";
                                      if(placeDetails.zipCode!=null) location.zipCode = placeDetails.zipCode!; else location.zipCode="N/A";
                                      //if(placeDetails.fullAddress!=null) location.description = placeDetails.fullAddress!;
                                      // Build Correct Description
                                      location.description = "${location.street} ${location.streetNumber}, ${location.city}, ${location.zipCode}";
                                      // Get Latitude/Longitude
                                      var temp = await gPlace!.details.get(location.placeId!);
                                      if (temp != null && temp.result != null && mounted) {
                                        detailsResult = temp.result;
                                        location.latitude = detailsResult!.geometry!.location!.lat!;
                                        location.longitude = detailsResult!.geometry!.location!.lng!;
                                      }
                                      setState(() {
                                        hasLocation = true;
                                        errorLocation = false;
                                      });
                                    } else {
                                      setState(() {
                                        hasLocation = false;
                                      });
                                    }
                                  },
                                  title: hasLocation ? Text(
                                    location.description!,
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ) : Text(
                                    AppLocalizations.of(context)!.enterAddressError,
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ),

                                  leading: Icon(
                                    Icons.add_location,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                errorLocation ? Padding(
                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                                  child: Text(
                                    AppLocalizations.of(context)!.enterAddressError,
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                  ),
                                ) : new Container(),
                                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                hasLocation ? Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.streetName,
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.street!, style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.streetNumber,
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.streetNumber!, style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.city,
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.city!, style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.zipCode,
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.zipCode!, style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${AppLocalizations.of(context)!.latitude}: ",
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.latitude!.toString(), style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${AppLocalizations.of(context)!.longitud}: ",
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.longitude!.toString(), style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                  ],
                                ) : Container(),
                              ],
                            )
                        ),
                      ),
                    ),
                    Scaffold(
                      resizeToAvoidBottomInset: true,
                      body: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!.createBrandWorkshiftDescription,
                                        style: Theme.of(context).textTheme.caption,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                Text(
                                  AppLocalizations.of(context)!.workingHours,
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    TextButton(
                                      onPressed: () async {
                                        selectSlot(context, 3, true);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                          color: Colors.transparent,
                                        ),
                                        child: Text(
                                          startTimeController.text,
                                          style: Theme.of(context).textTheme.headline3,
                                        ),
                                      ),
                                    ),
                                    Text("-",
                                        style: Theme.of(context).textTheme.headline3),
                                    TextButton(
                                      onPressed: () async {
                                        selectSlot(context, 3, false);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                          color: Colors.transparent,
                                        ),
                                        child: Text(
                                            endTimeController.text,
                                            style: Theme.of(context).textTheme.headline3
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                errorTime != null ? Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                                  child: Text(
                                    errorTime == 1 ? AppLocalizations.of(context)!.workingHoursError : AppLocalizations.of(context)!.workingHoursError1,
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ) : new Container(),
                                SizedBox(height: MediaQuery.of(context).size.height*0.04),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!.createBrandBreakDescription,
                                        style: Theme.of(context).textTheme.caption,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                Text(
                                  AppLocalizations.of(context)!.lunchBreak,
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.43,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          TextButton(
                                            onPressed: _breakList.length < breakLimit ? () {
                                              selectSlot(context, 4, true);
                                            } : null,
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                                border: Border.all(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                                color: Colors.transparent,
                                              ),
                                              child: Text(
                                                breakStartTimeController.text,
                                                style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),
                                              ),
                                            ),
                                          ),
                                          Text("-", style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),),
                                          TextButton(
                                            onPressed: _breakList.length < breakLimit ? () {
                                              selectSlot(context, 4, false);
                                            } : null,
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                                border: Border.all(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                                color: Colors.transparent,
                                              ),
                                              child: Text(
                                                breakEndTimeController.text,
                                                style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _breakList.length < breakLimit ? Padding(
                                      padding: const EdgeInsets.only(left: 0.0),
                                      child: OutlinedButton(
                                        onPressed: () {
                                          double toDouble(DateTime myTime) => myTime.hour + myTime.minute/60.0;
                                          if (toDouble(DateFormat('HH:mm', widget.locale!.languageCode).parse(breakStartTimeController.text)) > toDouble(DateFormat('HH:mm', widget.locale!.languageCode).parse(breakEndTimeController.text))){
                                            setState(() {
                                              errorBreakTime = true;
                                            });
                                          } else {
                                            DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(breakStartTimeController.text);
                                            DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(breakEndTimeController.text);
                                            _breakStartTime = TimeOfDay(hour: start.hour, minute: start.minute);
                                            _breakEndTime = TimeOfDay(hour: end.hour, minute: end.minute);
                                            setState(() {
                                              errorBreakTime = false ;
                                              _breakList.add(_breakStartTime);
                                              _breakList.add(_breakEndTime);
                                            });
                                          }
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon( Icons.add, color: Colors.white, size: 30,),
                                          ],
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          elevation: 3,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(5),
                                        ),
                                      ),
                                    ) : Container(),
                                  ],
                                ),
                                errorBreakTime ? Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                                  child: Text(
                                    AppLocalizations.of(context)!.workingHoursError1,
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ) : new Container(),
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _breakList.length,
                                  itemBuilder: (context, int index) {
                                    if(index.isEven && !removedIndex.contains(index)) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.43,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                TextButton(
                                                  onPressed: false ? () {

                                                  } : null,
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                                      border: Border.all(color: Colors.green, width: 1.0),
                                                      color: Colors.transparent,
                                                    ),
                                                    child: Text(
                                                      '${_breakList[index].format(context)}',
                                                      style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),
                                                    ),
                                                  ),
                                                ),
                                                Text("-", style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),),
                                                TextButton(
                                                  onPressed: false ? () {

                                                  } : null,
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                                      border: Border.all(color: Colors.green, width: 1.0),
                                                      color: Colors.transparent,
                                                    ),
                                                    child: Text(
                                                      '${_breakList[index+1].format(context)}',
                                                      style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 0.0),
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  removedIndex.add(index);
                                                  removedIndex.add(index+1);
                                                  breakLimit += 2;
                                                });
                                              },
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon( Icons.remove, color: Colors.white, size: 30,),
                                                ],
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                elevation: 3,
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(5),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(AppLocalizations.of(context)!.lunchBreakAdded, style: Theme.of(context).textTheme.bodyText2?.copyWith(fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                  shrinkWrap: true,
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                _breakList.length < breakLimit ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!.createBrandAddDescription,
                                        style: Theme.of(context).textTheme.bodyText2,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ) : Container(),
                                SizedBox(height: MediaQuery.of(context).size.height*0.04),
                              ],
                            )
                        ),
                      ),
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
                    heroTag: "72",
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
                      }
                      _tabController!.animateTo(_selectedIndex -= 1);
                      setState(() {
                        addEventTabValue -= 0.25;
                      });
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    icon: Container(),
                    label: Text(
                      AppLocalizations.of(context)!.back,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColorDark),),
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
                    heroTag: "27",
                    onPressed: () async {
                      if (_selectedIndex == 0) {
                          if (validatePortada()) {
                            _tabController!.animateTo(_selectedIndex += 1);
                            setState(() {
                              errorImage = false;
                              addEventTabValue += 0.25;
                              tabs[1] = true;
                            });
                          }
                      } else if (_selectedIndex == 1) {
                        if (validateInfo()) {
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            addEventTabValue += 0.25;
                            tabs[2] = true;
                          });
                        }
                      } else if (_selectedIndex == 2) {
                        if (validateLocation()) {
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            errorLocation = false;
                            addEventTabValue += 0.25;
                            tabs[3] = true;
                          });
                        }
                      } else if (_selectedIndex == 3) {
                        if (validateTime()) {
                          setState(() {
                            isLoading = true;
                          });
                          await registerBrand();
                        }
                      }
                    },
                    backgroundColor: _selectedIndex == 3 ? Colors.green : Theme.of(context).accentColor,
                    icon: Container(),
                    label: Text(
                      _selectedIndex == 3 ? AppLocalizations.of(context)!.createBrand : AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget getTitle() {
    if (tabs[0] && !tabs[1] && !tabs[2] && !tabs[3]) {
      return Text(
        AppLocalizations.of(context)!.createBrandCover,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      );
    } else if (tabs[0] && tabs[1] && !tabs[2] && !tabs[3]) {
      return Text(
        AppLocalizations.of(context)!.createBrandDesc,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      );
    } else if (tabs[0] && tabs[1] && tabs[2] && !tabs[3]) {
      return Text(
        AppLocalizations.of(context)!.createBrandBaseLocation,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      );
    } else if (tabs[0] && tabs[1] && tabs[2] && tabs[3]) {
      return Text(
        AppLocalizations.of(context)!.createBrandWorkshift,
        style: Theme.of(context).appBarTheme.titleTextStyle,
      );
    } else {
      return Text(AppLocalizations.of(context)!.createBrand, style: Theme.of(context).appBarTheme.titleTextStyle,);
    }
  }

  bool validatePortada() {
    if (!formKeyInfo.currentState!.validate() || _image==null) {
      setState(() {
        errorImage = true;
      });
      return false;
    }
    setState(() {
      errorImage = false;
    });
    return true;
  }

  bool validateInfo() {
    if (!formKeyMembers.currentState!.validate()) {
      return false;
    }
    return true;
  }

  bool validateLocation() {
    if (!hasLocation) {
      setState(() {
        errorLocation = true;
      });
      return false;
    }
    setState(() {
      errorLocation = false;
    });
    return true;
  }

  bool validateTime() {
    DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(
        startTimeController.text);
    DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(
        endTimeController.text);
    double toDouble(DateTime myTime) => myTime.hour + myTime.minute / 60.0;
    if (TimeOfDay(hour: start.hour, minute: start.minute) ==
        TimeOfDay(hour: 0, minute: 00) &&
        TimeOfDay(hour: end.hour, minute: end.minute) ==
            TimeOfDay(hour: 23, minute: 00)) {
      setState(() {
        errorTime = 1;
      });
      return false;
    }
    if (toDouble(start) > toDouble(end)) {
      setState(() {
        errorTime = 2;
      });
      return false;
    }
    return true;
  }

  Future<void> registerBrand() async {
    // Get Data About The Times Of The Brand
    DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(startTimeController.text);
    DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(endTimeController.text);
    double toDouble(DateTime myTime) => myTime.hour + myTime.minute/60.0;
    double toDouble2(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;
    _workShift.add(toDouble(start));
    _workShift.add(toDouble(end));
    for (var i=0; i < _breakList.length; i+=2) {
      if(!removedIndex.contains(i)) {
        _workShift.add(toDouble2(_breakList[i]));
        _workShift.add(toDouble2(_breakList[i+1]));
      }
    }
    // Create Brand
    var result = await _brandDataService.addBrand(nameBrandController.text.trim(), _image, descriptionController.text.trim(), _workShift, membersMax);
    // Add User To Brand
    // New Database
    await _brandDataService.addUserToBrand(currentUser.id!,result, 1);
    // Add Location
    String baseLocation = await _locationDataService.addLocation(result, true, location.placeId!, location.description!, location.street!, location.streetNumber!, location.city!, location.zipCode!, location.latitude!, location.longitude!);
    await _brandDataService.updateBrandBaseLocation(result, baseLocation);
    // Update Current User Brand
    NotificationService().userCreatesBrand(currentUser.id!, result);
    // Create Group Chat
    String logoUrl = await _brandDataService.getBrandLogoUrl(result);
    final room = await FirebaseChatCore.instance.createGroupRoom(imageUrl: logoUrl, metadata: {
      "trainer" + currentUser.id!: currentUser.isTrainer,
      "active" + currentUser.id!: false,
    }, name: nameBrandController.text.trim(), users: []);
    await _brandDataService.updateBrandRoom(result, room.id);
    // Pushing to Splash Screen
    setState(() {
      currentIndex = 1;
    });
    await Future.delayed(const Duration(seconds: 2)); // Ensure listener fires
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute<Null>(
        builder: (context) => SplashScreen(),
        settings: RouteSettings(name: 'SplashScreen'),
      ),
      (_) => false,
    );
  }
}
