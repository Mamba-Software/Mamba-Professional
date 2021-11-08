import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/InformationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:uuid/uuid.dart';

class RegistrarMarca extends StatefulWidget {
  Locale? locale;
  RegistrarMarca({Key? key, this.locale}) : super(key: key);

  @override
  _RegistrarMarcaState createState() => _RegistrarMarcaState();
}

class _RegistrarMarcaState extends State<RegistrarMarca> with SingleTickerProviderStateMixin {
  // DataBase Access
  var _accessDatabase = new DatabaseAccess();
  // Google APIS
  googlePlace.GooglePlace? gPlace;
  googlePlace.DetailsResult? detailsResult;
  // Boolean Basic Info
  bool basicInfo = true;
  bool editInfo = true;
  bool isLoading = false;
  // Form Values
  final _formBasicInfoKey = GlobalKey<FormState>();
  String nameBrand = "";
  String description = "";
  var nameBrandController = TextEditingController();
  //var ubicacionController =  TextEditingController();
  //var descriptionController =  TextEditingController();
  // Image Picker
  bool errorImage = false;
  var _image;
  // Ubicación
  Location location = Location();
  bool hasLocation = false;
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';
  String address = '';
  double latitude = 0;
  double longitude = 0;
  // Time Picker Horari de Trabajo
  int? errorTime;
  bool errorBreakTime = false;
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  List<double> _workShift = [];
  // Descansos
  TextEditingController breakStartTimeController = TextEditingController();
  TextEditingController breakEndTimeController = TextEditingController();
  TimeOfDay _breakStartTime = TimeOfDay(hour: 13, minute: 00);
  TimeOfDay _breakEndTime = TimeOfDay(hour: 14, minute: 00);
  List<TimeOfDay> _breakList = [];
  List<int> removedIndex = [];
  int breakLimit = 6;

  // ADAPTAR CREAR MARCA
  // Tab Controller
  double addEventTabValue = 0.25;
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false, false];
  // Title Controller
  var titleController = TextEditingController();
  String? titleString;
  // Description Controller
  var descriptionController = TextEditingController();
  String? descriptionString;
  // Starting Date and Time
  TextEditingController startDateController = TextEditingController();
  bool errorDate = false;
  // Duration
  TextEditingController durationController = TextEditingController();
  String duration = "1.00";
  List<String> durations = ["0.30","1.00","1.30","2.00","2.30","3.00","3.30","4.00"];
  // Ubicació
  var ubicacionController =  TextEditingController();
  //var placeId =  currentBrand.placeId!;
  // Participants
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 30;
  // Evento Recurrente
  bool isRecurrent = false;
  var oneWeek;
  var twoWeek;
  var oneMonth;
  final values = <bool?>[false, false, false, false, false, false, false];
  int _value = 1;
  // Members Page
  List<Usuario> brandTrainers = [];
  List<bool> brandTrainersSelected = [];
  bool errorNoTrainerSelected = false;
  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Retrieved From BD
  var event;
  var placeDetails;

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';
  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';

  Future<void> selectSlot(ctx, type, bool? isStart) {
    // Initial Vars
    var startDate = DateTime.now();
    var title;
    var initialDuration = 1;
    var initialMembers = 1;
    var widgetPicker;
    // Init for differnt types
    if (type == 0) {
      startDate = DateFormat('EEEE d/M/y - HH:mm', widget.locale!.languageCode).parse(undoCapitalized(startDateController.text));
    } else if (type == 1) {
      initialDuration = durations.indexWhere((element) => element == duration);
    } else if (type == 2) {
      initialMembers = members-1;
    } else if (type == 3) {
      // No changes needed at the moment
    }
    // Different types of pickers
    Widget dateTimePicker = CupertinoDatePicker(
        mode: CupertinoDatePickerMode.dateAndTime,
        initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
        minimumDate: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
        maximumDate: startDate.add(Duration(days: 365)),
        use24hFormat: true,
        minuteInterval: 30,
        onDateTimeChanged: (val) {
          setState(() {
            startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale!.languageCode).format(val);
            startDateController.text = toCapitalized(startDateController.text);
            oneWeek = val.add(Duration(days: 7));
            twoWeek = val.add(Duration(days: 14));
            oneMonth= val.add(Duration(days: 30));
          });
        }
    );
    Widget durationPicker = CupertinoPicker(
        scrollController: new FixedExtentScrollController(
            initialItem: initialDuration
        ),
        itemExtent: 40.0,
        backgroundColor: Colors.transparent,
        onSelectedItemChanged: (int index) {
          setState(() {
            duration = durations[index];
            var hour = durations[index].split(".")[0];
            var min = durations[index].split(".")[1];
            durationController.text = "${hour}h ${min}min";
          });
        },
        children: new List<Widget>.generate(
            durations.length, (int index) {
          var item = durations[index];
          var hour = item.split(".")[0];
          var min = item.split(".")[1];
          return new Center(
            child: new Text(
                "${hour}h ${min}min"
            ),
          );
        }
        )
    );
    Widget membersPicker = CupertinoPicker(
        scrollController: new FixedExtentScrollController(
            initialItem: initialMembers
        ),
        itemExtent: 40.0,
        backgroundColor: Colors.transparent,
        onSelectedItemChanged: (int index) {
          setState(() {
            members = index+1;
            membersController.text = "${members.toString()}";
          });
        },
        children: new List<Widget>.generate(
            membersMax, (int index) {
          var member = index+1;
          return new Center(
            child: new Text(
                "${member.toString()}"
            ),
          );
        }
        )
    );
    Widget workdayTimePicker = CupertinoDatePicker(
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
    );
    Widget breakTimePicker = CupertinoDatePicker(
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
    );
    if (type == 0) {
      title = AppLocalizations.of(context)!.selectDayTime;
      widgetPicker = dateTimePicker;
    } else if (type == 1) {
      title = AppLocalizations.of(context)!.selectDuration;
      widgetPicker = durationPicker;
    } else if (type == 2) {
      title = AppLocalizations.of(context)!.selectMembers;
      widgetPicker = membersPicker;
    } else if (type == 3) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(title, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                  ],
                ),
                Expanded(
                    child: widgetPicker
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: TextButton(
                          child: Text(AppLocalizations.of(context)!.entendido, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          }
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
    );
    return Future.value("");
  }

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
    retrieveLostData();
  }
  // Retrieve lost data of Gallery if it crashes becasue of Android.
  Future<void> retrieveLostData() async {
    final LostDataResponse response =
    await ImagePicker().retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = response.file;
      });
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    gPlace = googlePlace.GooglePlace(Platform.isAndroid ? placesAPIAndroid : placesAPIIOS);
    startTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0,));
    endTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 0,));
    breakStartTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13, 0,));
    breakEndTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0,));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createBrand, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22),),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 25,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LoadingViewPurple(),
    ) :
    Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.13,
        title: Column(
          children: [
            Text(AppLocalizations.of(context)!.createBrand, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => {
            Navigator.pop(context)
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: IgnorePointer(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                    tabs: [
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, color: tabs[0] ? Theme.of(context).accentColor : Colors.grey)
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
                              Icon(Icons.info_outlined, color: tabs[1] ? Theme.of(context).accentColor : Colors.grey.withOpacity(0.2))
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
                              Icon(Icons.location_on_outlined, color: tabs[2] ? Theme.of(context).accentColor : Colors.grey.withOpacity(0.2))
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
                              Icon(Icons.calendar_today_outlined, color: tabs[3] ? Theme.of(context).accentColor : Colors.grey.withOpacity(0.2))
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
      resizeToAvoidBottomInset: false,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.logo,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              Container(
                                height: MediaQuery.of(context).size.height * 0.30,
                                child: Center(
                                  child: _image == null ?
                                  OutlinedButton(
                                    onPressed: getImage,
                                    child: Column(
                                      children: [
                                        new Icon(
                                          Icons.image,
                                          color: Theme.of(context).primaryColor,
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: errorImage ? Colors.red : Theme.of(context).primaryColor,
                                          width: 1.5
                                      ),
                                      backgroundColor: Colors.white,
                                      elevation: 10,
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.10, right: MediaQuery.of(context).size.height * 0.10, top: MediaQuery.of(context).size.height * 0.125),
                                    ),
                                  ) :
                                  GestureDetector(
                                    onTap: getImage,
                                    child: Container(
                                        height: MediaQuery.of(context).size.height * 0.26,
                                        decoration: new BoxDecoration(
                                          border: Border.all(
                                            width: 1.5,
                                            color: Styles.accent,
                                            style: BorderStyle.solid,
                                          ),
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                            image: FileImage(_image),
                                            fit: BoxFit.fitHeight,
                                          ),
                                        )
                                    )
                                  ),
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.02),
                              Text(
                                AppLocalizations.of(context)!.name,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              Flexible(
                                child: new TextFormField(
                                  controller: nameBrandController,
                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError : null,
                                  style: Styles.purpleTextStyle.copyWith(fontSize: 26, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintStyle: Styles.purpleTextStyle.copyWith(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.normal),
                                    hintText: AppLocalizations.of(context)!.nameBrandError,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
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
                              Text(
                                AppLocalizations.of(context)!.description,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              Flexible(
                                child: new TextFormField(
                                    controller: descriptionController,
                                    validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.descriptionError : null,
                                    minLines: 1,
                                    maxLines: 6,
                                    decoration: InputDecoration(
                                      hintStyle: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Colors.grey),
                                      hintText: AppLocalizations.of(context)!.descriptionError,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.02),
                              Text(
                                AppLocalizations.of(context)!.maxNumberClients,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              GestureDetector(
                                  onTap: () {
                                    selectSlot(context, 2, null);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      new Flexible(
                                        child: TextFormField(
                                          controller: membersController,
                                          maxLines: 2,
                                          readOnly: true,
                                          enabled: false,
                                          style: Styles.purpleTextStyle,
                                          decoration: InputDecoration(
                                            hintStyle: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Colors.grey),
                                            hintText: AppLocalizations.of(context)!.maxNumberClientsError,
                                            labelStyle: Styles.purpleTextStyle,
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
                              Text(
                                AppLocalizations.of(context)!.baseLocation,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              ListTile(
                                onTap: () async {
                                  // Generate a new token here
                                  final sessionToken = Uuid().v4();
                                  final Suggestion? result = await showSearch(
                                    context: context,
                                    delegate: AddressSearch(sessionToken),
                                  );
                                  // We have a result for our locations search
                                  if (result != null) {
                                    location.placeId = result.placeId;
                                    final placeDetails = await LocationPlacesSearch(sessionToken).getPlaceDetailFromId(location.placeId!);
                                    // Get the information on Strings
                                    if(placeDetails.street!=null) location.street = placeDetails.street!;
                                    if(placeDetails.streetNumber!=null) location.streetNumber = placeDetails.streetNumber!; else location.streetNumber="N/A";
                                    if(placeDetails.city!=null) location.city = placeDetails.city!;
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
                                    });
                                    // Save location to DataBase
                                    //bool isOkay = await _accessDatabase.addLocation(widget.brandId, location.placeId!, location.description!, location.street!, location.streetNumber!, location.city!, location.zipCode!, location.latitude!, location.longitude!);
                                    //print(isOkay);
                                  } else {
                                    setState(() {
                                      hasLocation = false;
                                    });
                                  }
                                },
                                title: hasLocation ? Text(
                                  location.description!,
                                  style: Styles.purpleTextStyle.copyWith(fontSize: 16),
                                ) : Text(
                                  AppLocalizations.of(context)!.enterAddressError,
                                  style: Styles.purpleTextStyle.copyWith(fontSize: 16),
                                ),

                                leading: Icon(
                                  Icons.add_location,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.04),
                              hasLocation ?
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.streetName,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(location.street!, style: Styles.purpleTextStyle.copyWith(fontSize: 16),)
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.streetNumber,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(location.streetNumber!, style: Styles.purpleTextStyle.copyWith(fontSize: 16),)
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.city,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(location.city!, style: Styles.purpleTextStyle.copyWith(fontSize: 16),)
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.zipCode,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(location.zipCode!, style: Styles.purpleTextStyle.copyWith(fontSize: 16),)
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.latitude}: ",
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(location.latitude!.toString(), style: Styles.purpleTextStyle.copyWith(fontSize: 16),)
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.longitud}: ",
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(location.longitude!.toString(), style: Styles.purpleTextStyle.copyWith(fontSize: 16),)
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
                              Text(
                                AppLocalizations.of(context)!.workingHours,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
                                        border: Border.all(color: Styles.accent, width: 1.0),
                                        color: Colors.transparent,
                                      ),
                                      child: Text(
                                        startTimeController.text,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                                      ),
                                    ),
                                  ),
                                  Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30),),
                                  TextButton(
                                    onPressed: () async {
                                      selectSlot(context, 3, false);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        border: Border.all(color: Styles.accent, width: 1.0),
                                        color: Colors.transparent,
                                      ),
                                      child: Text(
                                        endTimeController.text,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.04),
                              Text(
                                AppLocalizations.of(context)!.lunchBreak,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.53,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            selectSlot(context, 4, true);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                              border: Border.all(color: Styles.accent, width: 1.0),
                                              color: Colors.transparent,
                                            ),
                                            child: Text(
                                              breakStartTimeController.text,
                                              style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                                            ),
                                          ),
                                        ),
                                        Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30),),
                                        TextButton(
                                          onPressed: () async {
                                            selectSlot(context, 4, false);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                              border: Border.all(color: Styles.accent, width: 1.0),
                                              color: Colors.transparent,
                                            ),
                                            child: Text(
                                              breakEndTimeController.text,
                                              style: Styles.purpleTextStyle.copyWith(fontSize: 25),
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
                                          width: MediaQuery.of(context).size.width * 0.53,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              TextButton(
                                                onPressed: () async {
                                                  TimeOfDay temp = await _selectTime(_breakList[index]);
                                                  setState(() {
                                                    _breakList[index] = temp;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                                    border: Border.all(color: Colors.green, width: 1.0),
                                                    color: Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    '${_breakList[index].format(context)}',
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 25, color: Colors.green),
                                                  ),
                                                ),
                                              ),
                                              Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30, color: Colors.green),),
                                              TextButton(
                                                onPressed: () async {
                                                  TimeOfDay temp = await _selectTime(_breakList[index+1]);
                                                  setState(() {
                                                    _breakList[index+1] = temp;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                                    border: Border.all(color: Colors.green, width: 1.0),
                                                    color: Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    '${_breakList[index+1].format(context)}',
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 25, color: Colors.green),
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
                                          child: Text(AppLocalizations.of(context)!.lunchBreakAdded, style: Styles.purpleTextStyle.copyWith(fontSize: 13,fontStyle: FontStyle.italic, color: Colors.green), textAlign: TextAlign.center,),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                                shrinkWrap: true,
                              ),
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
                  heroTag: null,
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
                  label: Text(AppLocalizations.of(context)!.back, style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
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
                  heroTag: null,
                  onPressed: () {
                    if (_selectedIndex == 0) {
                        _tabController!.animateTo(_selectedIndex += 1);
                        setState(() {
                          addEventTabValue += 0.25;
                          tabs[1] = true;
                        });
                    } else if (_selectedIndex == 1) {
                      _tabController!.animateTo(_selectedIndex += 1);
                      setState(() {
                        addEventTabValue += 0.25;
                        tabs[2] = true;
                      });
                    } else if (_selectedIndex == 2) {
                      _tabController!.animateTo(_selectedIndex += 1);
                      setState(() {
                        addEventTabValue += 0.25;
                        tabs[3] = true;
                      });
                    } else if (_selectedIndex == 3) {

                    }
                  },
                  backgroundColor: _selectedIndex == 3 ? Colors.green : Theme.of(context).accentColor,
                  icon: Container(),
                  label: Text(
                    _selectedIndex == 3 ? AppLocalizations.of(context)!.createBrand : AppLocalizations.of(context)!.next,
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<TimeOfDay> _selectTime(TimeOfDay time) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: time,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light().copyWith(
              primary: Colors.amber,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // Using 12-Hour format
                alwaysUse24HourFormat: true),
            // If you want 24-Hour format, just change alwaysUse24HourFormat to true
            child: child!)
        );
      }
    );
    if (newTime != null) {
      return newTime;
    } else {
      return time;
    }
  }

}

/*
Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Container(
                                  height: 50,
                                  width: 250,
                                  decoration: BoxDecoration(
                                      color: Colors.green, borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      if (_image==null) {
                                        setState(() {
                                          errorImage = true;
                                        });
                                      } else {
                                        setState(() {
                                          errorImage = false;
                                        });
                                      }
                                      if (_startTime == TimeOfDay(hour: 0, minute: 00) && _endTime == TimeOfDay(hour: 23, minute: 00)) {
                                        setState(() {
                                          errorTime = 1;
                                        });
                                      } else {
                                        double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;
                                        if (toDouble(_startTime) > toDouble(_endTime)){
                                          setState(() {
                                            errorTime = 2;
                                          });
                                        } else {
                                          setState(() {
                                            errorTime = null;
                                          });
                                        }
                                      }
                                      if(_formBasicInfoKey.currentState!.validate()) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;
                                        _workShift.add(toDouble(_startTime));
                                        _workShift.add(toDouble(_endTime));
                                        for (var i=0; i < _breakList.length; i+=2) {
                                          if(!removedIndex.contains(i)) {
                                            _workShift.add(toDouble(_breakList[i]));
                                            _workShift.add(toDouble(_breakList[i+1]));
                                          }
                                        }
                                        var result = await _accessDatabase.addBrand(nameBrand, _image, description, detailsResult!.placeId!, address, latitude, longitude, _workShift);
                                        await _accessDatabase.updateCurrentUserBrand(result);
                                        Navigator.pop(context);
                                        Navigator.pushReplacement(
                                            context,
                                            CupertinoPageRoute<Null>(
                                              builder: (context) => SplashScreen(),
                                              settings: RouteSettings(name: 'SplashScreen'),
                                            )
                                        );
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.createBrand,
                                          style: Styles.whiteTextStyle,
                                        ),
                                        SizedBox(width: 10),
                                        Icon(Icons.add_circle_outline, color: Styles.white, size: 30,),
                                      ],
                                    ),
                                  ),
                                ),
                              ),



return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createBrand, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22),),
          centerTitle: true,
          elevation: 8,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 25,),
            onPressed: () {
              if (basicInfo) {
                Navigator.pop(context);
              } else {
                setState(() {
                  basicInfo = !basicInfo;
                });
              }
            },
            tooltip: 'Back',
          ),
        ),
        backgroundColor: Styles.white,
        body: isLoading ?
        LoadingView()
          :
        SingleChildScrollView(
          child: Form(
            key: _formBasicInfoKey,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
                            child: new Text(
                              AppLocalizations.of(context)!.basicInfo,
                              style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            height: MediaQuery.of(context).size.height * 0.20,
                            child: Center(
                              child: _image == null ?
                              OutlinedButton(
                                onPressed: getImage,
                                child: Column(
                                  children: [
                                    new Icon(
                                      Icons.image,
                                      color: Styles.accent,
                                      size: 35.0,
                                    ),
                                  ],
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: errorImage ? Colors.red : Styles.accent,
                                    width: 1.5
                                  ),
                                  backgroundColor: Colors.white,
                                  elevation: 10,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.only(left: 50, right: 50, top: 63),
                                ),
                              ) :
                              GestureDetector(
                                onTap: getImage,
                                child: Stack(
                                  children: <Widget>[
                                    Center(
                                        child: Container(
                                            width: MediaQuery.of(context).size.width*0.35,
                                            decoration: new BoxDecoration(
                                                border: Border.all(
                                                width: 1.5,
                                                color: Styles.accent,
                                                style: BorderStyle.solid,
                                              ),
                                              shape: BoxShape.circle,
                                              image: new DecorationImage(
                                                image: FileImage(_image),
                                                fit: BoxFit.fitWidth,
                                              ),
                                            )
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          new Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              new Text(
                                                AppLocalizations.of(context)!.name,
                                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(left: 10, right: 20),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          new Flexible(
                                            child: new TextFormField(
                                              controller: nameBrandController,
                                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError : null,
                                              onChanged: (val) {
                                                setState(() => {
                                                  nameBrand = val
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: AppLocalizations.of(context)!.nameCompletoError,
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Styles.accent),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Styles.accent),
                                                ),

                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                        child: new Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            new Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  AppLocalizations.of(context)!.baseLocation,
                                                  style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 0),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(Icons.info_outline, color: Styles.accent, size: 20),
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return InformationDialog(text: AppLocalizations.of(context)!.baseLocationDescription);
                                                      }
                                                  );
                                                },
                                              )
                                            ),
                                          ],
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10,),
                                        child: new Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                          Expanded(
                                            child: TextFormField(
                                              controller: ubicacionController,
                                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.enterAddressError : null,
                                              readOnly: true,
                                              onTap: () async {
                                                // generate a new token here
                                                final sessionToken = Uuid().v4();
                                                final Suggestion? result = await showSearch(
                                                  context: context,
                                                  delegate: AddressSearch(sessionToken),
                                                );
                                                // This will change the text displayed in the TextFormField
                                                if (result != null) {
                                                  final placeDetails = await LocationPlacesSearch(sessionToken).getPlaceDetailFromId(result.placeId);
                                                  getDetails(result.placeId);
                                                  setState(() {
                                                    ubicacionController.text = result.description;
                                                    if(placeDetails.street!=null) _street = placeDetails.street!; else _street="N/A";
                                                    if(placeDetails.streetNumber!=null) _streetNumber = placeDetails.streetNumber!; else _streetNumber="N/A";
                                                    if(placeDetails.city!=null) _city = placeDetails.city!; else _city="N/A";
                                                    if(placeDetails.zipCode!=null) _zipCode = placeDetails.zipCode!; else _zipCode="N/A";
                                                  });
                                                  address =_street+" "+_streetNumber+", "+_city;
                                                  if(placeDetails.city!=null) address +=", "+_zipCode;
                                                }
                                              },
                                              decoration: InputDecoration(
                                                icon: Container(
                                                  width: 10,
                                                  height: 10,
                                                  child: Icon(
                                                    Icons.location_on_outlined,
                                                    color: Styles.accent,
                                                    size: 35,
                                                  ),
                                                ),
                                                hintText: AppLocalizations.of(context)!.enterAddress,
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.only(left: 18.0, top: 25.0),
                                              ),
                                        ),
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _street != "" ?
                      Padding(
                          padding: EdgeInsets.only(left: 15, right: 10, top: 10, bottom: 10),
                          child: new Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.streetName, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_street, style: Styles.purpleTextStyle,),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.streetNumber, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_streetNumber, style: Styles.purpleTextStyle,),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.city, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_city, style: Styles.purpleTextStyle,),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.zipCode, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_zipCode, style: Styles.purpleTextStyle,),
                                ],
                              ),
                            ],
                          )
                      ) : Container(),
                      Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)!.description,
                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.info_outline, color: Styles.accent, size: 20),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (_) {
                                            return InformationDialog(text: AppLocalizations.of(context)!.brandDescription);
                                          }
                                      );
                                    },
                                  )
                              ),
                            ],
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextFormField(
                                    controller: descriptionController,
                                    validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.descriptionError : null,
                                    onChanged: (val) {
                                      setState(() => description = val);
                                    },
                                    maxLines: 6,
                                    decoration: Styles.textFromInputDecoration.copyWith(hintText:AppLocalizations.of(context)!.descriptionError)
                                ),
                              ),
                            ],
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 30),
                            child: new Text(
                              AppLocalizations.of(context)!.disponibilidad,
                              style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          new Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                AppLocalizations.of(context)!.workingHours,
                                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(left: 0),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(Icons.info_outline, color: Styles.accent, size: 20),
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return InformationDialog(text: AppLocalizations.of(context)!.workingHoursDescription);
                                                      }
                                                  );
                                                },
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5,),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextButton(
                                          onPressed: () async {
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            TimeOfDay temp = await _selectTime(_startTime);
                                            setState(() {
                                              _startTime = temp;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                              border: Border.all(color: Styles.accent, width: 1.0),
                                              color: Colors.transparent,
                                            ),
                                            child: Text(
                                              '${_startTime.format(context)}',
                                              style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                                            ),
                                          ),
                                        ),
                                        Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30),),
                                        TextButton(
                                          onPressed: () async {
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            TimeOfDay temp = await _selectTime(_endTime);
                                            setState(() {
                                              _endTime = temp;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                              border: Border.all(color: Styles.accent, width: 1.0),
                                              color: Colors.transparent,
                                            ),
                                            child: Text(
                                              '${_endTime.format(context)}',
                                              style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  errorTime != null ? Padding(
                                    padding: EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                                    child: Text(
                                        errorTime == 1 ? AppLocalizations.of(context)!.workingHoursError : AppLocalizations.of(context)!.workingHoursError1,
                                        style: Styles.redTextStyle.copyWith(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                  ) : new Container(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          new Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                AppLocalizations.of(context)!.lunchBreak,
                                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(left: 0),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(Icons.info_outline, color: Styles.accent, size: 20),
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return InformationDialog(text: AppLocalizations.of(context)!.lunchBreakDescription);
                                                      }
                                                  );
                                                },
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5,),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.53,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              TextButton(
                                                onPressed: () async {
                                                  FocusScope.of(context).requestFocus(new FocusNode());
                                                  TimeOfDay temp = await _selectTime(_breakStartTime);
                                                  setState(() {
                                                    _breakStartTime = temp;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                                    border: Border.all(color: Styles.accent, width: 1.0),
                                                    color: Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    '${_breakStartTime.format(context)}',
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                                                  ),
                                                ),
                                              ),
                                              Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30),),
                                              TextButton(
                                                onPressed: () async {
                                                  FocusScope.of(context).requestFocus(new FocusNode());
                                                  TimeOfDay temp = await _selectTime(_breakEndTime);
                                                  setState(() {
                                                    _breakEndTime = temp;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                                    border: Border.all(color: Styles.accent, width: 1.0),
                                                    color: Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    '${_breakEndTime.format(context)}',
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 25),
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
                                              double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;
                                              if (toDouble(_breakStartTime) > toDouble(_breakEndTime)){
                                                setState(() {
                                                  errorBreakTime = true;
                                                });
                                              } else {
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
                                              backgroundColor: Styles.accent,
                                              elevation: 3,
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(5),
                                            ),
                                          ),
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                  errorBreakTime ? Padding(
                                    padding: EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                                    child: Text(
                                      AppLocalizations.of(context)!.workingHoursError1,
                                      style: Styles.redTextStyle.copyWith(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ) : new Container(),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _breakList.length,
                                    itemBuilder: (context, int index) {
                                      if(index.isEven && !removedIndex.contains(index)) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5,),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.53,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        TimeOfDay temp = await _selectTime(_breakList[index]);
                                                        setState(() {
                                                          _breakList[index] = temp;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                                          border: Border.all(color: Colors.green, width: 1.0),
                                                          color: Colors.transparent,
                                                        ),
                                                        child: Text(
                                                          '${_breakList[index].format(context)}',
                                                          style: Styles.purpleTextStyle.copyWith(fontSize: 25, color: Colors.green),
                                                        ),
                                                      ),
                                                    ),
                                                    Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30, color: Colors.green),),
                                                    TextButton(
                                                      onPressed: () async {
                                                        TimeOfDay temp = await _selectTime(_breakList[index+1]);
                                                        setState(() {
                                                          _breakList[index+1] = temp;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                                          border: Border.all(color: Colors.green, width: 1.0),
                                                          color: Colors.transparent,
                                                        ),
                                                        child: Text(
                                                          '${_breakList[index+1].format(context)}',
                                                          style: Styles.purpleTextStyle.copyWith(fontSize: 25, color: Colors.green),
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
                                                child: Text(AppLocalizations.of(context)!.lunchBreakAdded, style: Styles.purpleTextStyle.copyWith(fontSize: 13,fontStyle: FontStyle.italic, color: Colors.green), textAlign: TextAlign.center,),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                    shrinkWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Container(
                          height: 50,
                          width: 250,
                          decoration: BoxDecoration(
                              color: Colors.green, borderRadius: BorderRadius.circular(20)
                          ),
                          child: TextButton(
                            onPressed: () async {
                              if (_image==null) {
                                setState(() {
                                  errorImage = true;
                                });
                              } else {
                                setState(() {
                                  errorImage = false;
                                });
                              }
                              if (_startTime == TimeOfDay(hour: 0, minute: 00) && _endTime == TimeOfDay(hour: 23, minute: 00)) {
                                setState(() {
                                  errorTime = 1;
                                });
                              } else {
                                double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;
                                if (toDouble(_startTime) > toDouble(_endTime)){
                                  setState(() {
                                    errorTime = 2;
                                  });
                                } else {
                                  setState(() {
                                    errorTime = null;
                                  });
                                }
                              }
                              if(_formBasicInfoKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;
                                _workShift.add(toDouble(_startTime));
                                _workShift.add(toDouble(_endTime));
                                for (var i=0; i < _breakList.length; i+=2) {
                                  if(!removedIndex.contains(i)) {
                                    _workShift.add(toDouble(_breakList[i]));
                                    _workShift.add(toDouble(_breakList[i+1]));
                                  }
                                }
                                var result = await _accessDatabase.addBrand(nameBrand, _image, description, detailsResult!.placeId!, address, latitude, longitude, _workShift);
                                await _accessDatabase.updateCurrentUserBrand(result);
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute<Null>(
                                      builder: (context) => SplashScreen(),
                                      settings: RouteSettings(name: 'SplashScreen'),
                                    )
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.createBrand,
                                  style: Styles.whiteTextStyle,
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.add_circle_outline, color: Styles.white, size: 30,),
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
          )
        )
    );



editInfo ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      color: Styles.accent
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(Icons.edit, color: Colors.white, size: 30,),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                AppLocalizations.of(context)!.canEdit,
                                style: Styles.whiteTextStyle.copyWith(fontSize: 16,),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                            child: TextButton(
                                child: Text(AppLocalizations.of(context)!.entendido, style: Styles.whiteTextStyle.copyWith(fontSize: 16, decoration: TextDecoration.underline)),
                                onPressed: () {
                                  setState(() {
                                    editInfo = false;
                                  });
                                }
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ) : Container(),
 */