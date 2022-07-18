import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/LocationDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDateAndTimeDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDurationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectMembersDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LocationAutoComplete/MyLocationsSelect.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandScreens/SelectClientsEvent.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddEvent extends StatefulWidget {
  Locale locale;
  DateTime? initialDateTime;

  AddEvent({Key? key, required this.locale, this.initialDateTime}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> with SingleTickerProviderStateMixin{
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  var _locationDataService = new LocationDataService();
  // Boolean Loading
  bool isLoading = false;
  // Boolean isUpdated
  bool isUpdated = false;
  // Tab Controller
  double addEventTabValue = 0.33;
  double updateEventTabValue = 0.50;
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false];
  // Title Controller
  var titleController = TextEditingController();
  String? titleString;
  // Description Controller
  var descriptionController = TextEditingController();
  String? descriptionString;
  // Location
  Location location = Location();
  // Starting Date and Time
  DateTime? startDate;
  TextEditingController startDateController = TextEditingController();
  bool errorDate = false;
  Timestamp? doneAt;
  // Duration
  String duration = "1.00";
  List<String> durations = ["0.30","0.45","1.00","1.15","1.30","1.45","2.00","2.15","2.30","2.45","3.00"];
  TextEditingController durationController = TextEditingController();
  // Ubicació
  var ubicacionController =  TextEditingController();
  // Participants
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = currentBrand.maxMembers!;
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
  bool errorClientsSelected = false;
  List<Usuario> brandClientsSelected = [];
  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Retrieved From BD
  var event;
  var placeDetails;

  Future selectDateAndTime() async {
    if (startDate == null) {
      startDate = DateTime.now();
      startDate = DateTime(startDate!.year, startDate!.month, startDate!.day, startDate!.hour+1, 0);
    }
    var pickedDateTemp =  await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectDateAndTimeDialog(
          title: AppLocalizations.of(context)!.selectDayTime,
          startDate: startDate!,
          onlyFuture: true,
        )
    );
    if (pickedDateTemp != null) {
      setState(() {
        startDate = pickedDateTemp;
        startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(pickedDateTemp);
        startDateController.text = StringUtils().toCapitalized(startDateController.text);
        oneWeek = pickedDateTemp.add(Duration(days: 7));
        twoWeek = pickedDateTemp.add(Duration(days: 14));
        oneMonth= pickedDateTemp.add(Duration(days: 30));
      });
    }
  }

  Future selectDuration() async {
    String? pickedDuration =  await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectDurationDialog(
          title: AppLocalizations.of(context)!.selectDuration,
          initialDuration: duration,
        )
    );
    if (pickedDuration != null) {
      setState(() {
        var hour = pickedDuration.split(".")[0];
        var min = pickedDuration.split(".")[1];
        duration = pickedDuration;
        durationController.text = "${hour}h ${min}min";
      });
    }
  }

  Future selectNumberOfMembers() async {
    int? pickedMembers =  await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectMembersDialog(
          title: AppLocalizations.of(context)!.selectMembers,
          initialMembers: members-1,
        )
    );
    if (pickedMembers != null) {
      setState(() {
        members = pickedMembers;
        membersController.text = "${members.toString()}";
      });
    }
  }


  @override
  initState() {
    isLoading = true;
    _tabController = TabController(length: 3, vsync: this);
    if (widget.initialDateTime != null) {
      startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(widget.initialDateTime!);
      startDateController.text = StringUtils().toCapitalized(startDateController.text);
      oneWeek = widget.initialDateTime!.add(Duration(days: 7));
      twoWeek = widget.initialDateTime!.add(Duration(days: 14));
      oneMonth= widget.initialDateTime!.add(Duration(days: 30));
      doneAt = Timestamp.fromDate(widget.initialDateTime!);
    } else {
      var startDate = DateTime.now();
      doneAt = Timestamp.fromDate(startDate);
      startDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        startDate.hour+1,
        0,
      );
      startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(startDate);
      startDateController.text = StringUtils().toCapitalized(startDateController.text);
      oneWeek = startDate.add(Duration(days: 7));
      twoWeek = startDate.add(Duration(days: 14));
      oneMonth= startDate.add(Duration(days: 30));
    }
    titleController.text = "${currentBrand.name!.replaceAll(RegExp(r"\s+"), "")}";
    titleString = titleController.text;
    var hour = durations[2].split(".")[0];
    var min = durations[2].split(".")[1];
    durationController.text = "${hour}h ${min}min";
    membersController.text = "${members.toString()}";
    getAllTrainersFromBrand();
    getLocation(currentBrand.baseLocation!);
  }

  Future<void> getAllTrainersFromBrand() async {
    brandTrainers = await _brandDataService.getBrandTrainers(currentBrand.id!);
    print(brandTrainers.length);
    for (var i=0; i < brandTrainers.length; i++) {
      Usuario trainer = brandTrainers[i];
      if (trainer.id == currentUser.id) {
        brandTrainersSelected.add(true);
      } else {
        brandTrainersSelected.add(false);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getLocation(String locationId) async {
    location = await _locationDataService.getSingleLocation(locationId);
    setState(() {
      isLoading = false;
    });
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
        title: Text(AppLocalizations.of(context)!.addEvent, style: Theme.of(context).appBarTheme.titleTextStyle,),
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
                            Icon(Icons.info_outlined, color: tabs[0] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
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
                            Icon(Icons.calendar_today_outlined, color: tabs[1] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
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
                            Icon(Icons.group, color: tabs[2] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
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
                  body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Form(
                              key: formKeyInfo,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  new Text(
                                                    AppLocalizations.of(context)!.title,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(top: 0),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Flexible(
                                                child: new TextFormField(
                                                  controller: titleController,
                                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.titleError : null,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      titleString = val;
                                                    });
                                                  },
                                                  style: Theme.of(context).textTheme.bodyText2,
                                                  decoration: InputDecoration(
                                                    hintStyle: Theme.of(context).textTheme.caption,
                                                    hintText: AppLocalizations.of(context)!.titleHint,
                                                    border: InputBorder.none,
                                                    focusedBorder: InputBorder.none,
                                                    enabledBorder: InputBorder.none,
                                                    errorBorder: InputBorder.none,
                                                    disabledBorder: InputBorder.none,
                                                  ),
                                                  enabled: true,
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  new Text(
                                                    AppLocalizations.of(context)!.description,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(top: 0.0),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Flexible(
                                                child: new TextFormField(
                                                  keyboardType: TextInputType.visiblePassword,
                                                  controller: descriptionController,
                                                  minLines: 1,
                                                  maxLines: 4,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      descriptionString = val;
                                                    });
                                                  },
                                                  style: Theme.of(context).textTheme.bodyText2,
                                                  decoration: InputDecoration(
                                                    hintStyle: Theme.of(context).textTheme.caption,
                                                    hintText:AppLocalizations.of(context)!.descriptionError,
                                                    border: InputBorder.none,
                                                    focusedBorder: InputBorder.none,
                                                    enabledBorder: InputBorder.none,
                                                    errorBorder: InputBorder.none,
                                                    disabledBorder: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  new Text(
                                                    AppLocalizations.of(context)!.location,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 15.0),
                                        child: ListTile(
                                          leading: Icon(location.isBaseLocation! ? Icons.home_filled : Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.06,),
                                          title: Text(
                                              location.description!,
                                            style: Theme.of(context).textTheme.bodyText2,
                                          ),
                                          trailing: Icon(Icons.swap_horiz, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.06,),
                                          onTap: () async {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            var result = await Navigator.push(
                                                context,
                                              CupertinoPageRoute<String>(
                                                builder: (context) => MyLocationsSelect(
                                                    brandId: currentBrand.id!,
                                                  ),
                                                )
                                            );
                                            if (result != null) {
                                              getLocation(result);
                                            } else {
                                              setState(() {
                                                isLoading = false;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ]
                                ),
                              ),
                            ),
                        ],
                      )
                  ),
                  resizeToAvoidBottomInset: true,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.05),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.20,
                                        width: MediaQuery.of(context).size.width * 0.90,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).backgroundColor,
                                            borderRadius: BorderRadius.all(Radius.circular(15.0))
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.05, horizontal: MediaQuery.of(context).size.width*0.05),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Icon(Icons.calendar_today_outlined, color: Theme.of(context).accentColor,size: MediaQuery.of(context).size.width*0.05,),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                                    width: MediaQuery.of(context).size.width*0.70,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          selectDateAndTime();
                                                        },
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.max,
                                                          children: <Widget>[
                                                            new Flexible(
                                                              child: TextFormField(
                                                                controller: startDateController,
                                                                readOnly: true,
                                                                enabled: false,
                                                                style: Theme.of(context).textTheme.bodyText2,
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
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Icon(Icons.timer, color: Theme.of(context).accentColor,size: MediaQuery.of(context).size.width*0.05,),
                                                  Container(
                                                    padding: EdgeInsets.only(left: 20),
                                                    width: MediaQuery.of(context).size.width*0.30,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          selectDuration();
                                                        },
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.max,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: <Widget>[
                                                            new Flexible(
                                                              child: TextFormField(
                                                                controller: durationController,
                                                                readOnly: true,
                                                                enabled: false,
                                                                style: Theme.of(context).textTheme.bodyText2,
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
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      errorDate ? Padding(
                                        padding: EdgeInsets.only(left: 25, right: 25, top: 10.0),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(context)!.errorDate,
                                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ) : Container(),
                                      Padding(
                                          padding: EdgeInsets.only(top: 15,),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!.recurrentEvent,
                                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(width: 10,),
                                              Checkbox(
                                                checkColor: Colors.white,
                                                fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                                                value: isRecurrent,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    isRecurrent = value!;
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                      ),
                                      isRecurrent ? Column(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(top: 0),
                                              child: new Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Text(
                                                      AppLocalizations.of(context)!.days,
                                                      style: Theme.of(context).textTheme.bodyText2,
                                                    ),
                                                  ),
                                                  WeekdaySelector(
                                                    fillColor: Colors.white,
                                                    selectedFillColor: Theme.of(context).accentColor,
                                                    textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.black),
                                                    selectedTextStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white),
                                                    firstDayOfWeek: 0,
                                                    shortWeekdays: [
                                                      AppLocalizations.of(context)!.mondayLetter,
                                                      AppLocalizations.of(context)!.tuesdarLetter,
                                                      AppLocalizations.of(context)!.wednesdayLetter,
                                                      AppLocalizations.of(context)!.thursdayLetter,
                                                      AppLocalizations.of(context)!.fridayLetter,
                                                      AppLocalizations.of(context)!.saturadayLetter,
                                                      AppLocalizations.of(context)!.sundayLetter,
                                                    ],
                                                    // Working Days disabledFillColor: Colors.red,
                                                    onChanged: (v) {
                                                      print(v);
                                                      setState(() {
                                                        values[v % 7] = !values[v % 7]!;
                                                      });
                                                    },
                                                    selectedElevation: 15,
                                                    elevation: 5,
                                                    disabledElevation: 0,
                                                    values: values,
                                                  ),
                                                ],
                                              )
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(top: 10),
                                              child: new Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Text(
                                                      AppLocalizations.of(context)!.during,
                                                      style: Theme.of(context).textTheme.bodyText2,
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      ListTile(
                                                        dense: true,
                                                        contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                                                        title: Text(
                                                          AppLocalizations.of(context)!.thisWeek,
                                                          style: Theme.of(context).textTheme.bodyText2,
                                                        ),
                                                        subtitle: Text(
                                                          AppLocalizations.of(context)!.until(StringUtils().toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(oneWeek))),
                                                          style: Theme.of(context).textTheme.caption,
                                                          textAlign: TextAlign.left,
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
                                                      ),
                                                      ListTile(
                                                        dense: true,
                                                        contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                                                        title: Text(
                                                          AppLocalizations.of(context)!.nextTwoWeek,
                                                          style: Theme.of(context).textTheme.bodyText2,
                                                        ),
                                                        subtitle: Text(
                                                          AppLocalizations.of(context)!.until(StringUtils().toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(twoWeek))),
                                                          style: Theme.of(context).textTheme.caption,
                                                          textAlign: TextAlign.left,
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
                                                      ),
                                                      ListTile(
                                                        dense: true,
                                                        contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                                                        title: Text(
                                                          AppLocalizations.of(context)!.wholeMonth,
                                                          style: Theme.of(context).textTheme.bodyText2,
                                                        ),
                                                        subtitle: Text(
                                                          AppLocalizations.of(context)!.until(StringUtils().toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(oneMonth))),
                                                          style: Theme.of(context).textTheme.caption,
                                                          textAlign: TextAlign.left,
                                                        ),
                                                        leading: Radio(
                                                          value: 3,
                                                          groupValue: _value,
                                                          activeColor: Theme.of(context).accentColor,
                                                          fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _value = int.parse(value.toString());
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                          ),
                                        ],
                                      ) : Container(),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.10)
                                    ]
                                )
                            ),
                        ],
                      )
                  ),
                  resizeToAvoidBottomInset: true,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  new Text(
                                                    AppLocalizations.of(context)!.designatedTrainers,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context).size.height*0.15,
                                              width: MediaQuery.of(context).size.width,
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: BouncingScrollPhysics(),
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: brandTrainers.length,
                                                  itemBuilder: (context, int index) {
                                                    var trainer = brandTrainers[index];
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          brandTrainersSelected[index] = !brandTrainersSelected[index];
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: !(index == 0 || index == brandTrainers.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: brandTrainers.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CircularImage(
                                                              size: MediaQuery.of(context).size.width*0.17,
                                                              image: trainer.imageUrl,
                                                              color: Theme.of(context).primaryColor,
                                                              borderWidth: 1,
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(context).size.width*0.2,
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    trainer.firstName!,
                                                                    style: Theme.of(context).textTheme.bodyText2,
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context).size.width*0.01,
                                                                  ),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context).size.width*0.05,
                                                                    child: Checkbox(
                                                                      checkColor: Colors.white,
                                                                      fillColor: MaterialStateProperty.resolveWith(getColor),
                                                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                      value: brandTrainersSelected[index],
                                                                      shape: CircleBorder(
                                                                          side: BorderSide.none
                                                                      ),
                                                                      onChanged: (bool? value) {
                                                                        setState(() {
                                                                          brandTrainersSelected[index] = !brandTrainersSelected[index];
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                              ),
                                            ),
                                          ],
                                        ),
                                        /*
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context).size.height*0.18,
                                              width: MediaQuery.of(context).size.width*0.87,
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: AlwaysScrollableScrollPhysics(),
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: brandTrainers!.length,
                                                  itemBuilder: (context, int index) {
                                                    var trainer = brandTrainers![index];
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          brandTrainersSelected[index] = !brandTrainersSelected[index];
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CircularImage (
                                                              size: MediaQuery.of(context).size.width*0.2,
                                                              image: trainer.imageUrl,
                                                              color: Theme.of(context).primaryColor,
                                                    borderWidth: 1,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  trainer.name!,
                                                                  style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(context).size.width*0.01,
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(context).size.width*0.05,
                                                                  child: Checkbox(
                                                                    checkColor: Colors.white,
                                                                    fillColor: MaterialStateProperty.resolveWith(getColor),
                                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                    value: brandTrainersSelected[index],
                                                                    shape: CircleBorder(
                                                                        side: BorderSide.none
                                                                    ),
                                                                    onChanged: (bool? value) {
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                              ),
                                            ),
                                          ],
                                        ),
                                         */
                                      ),
                                      errorNoTrainerSelected ? Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(context)!.noTrainerSelectedError,
                                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ) : Container(),
                                      Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  new Text(
                                                    AppLocalizations.of(context)!.maxNumberClients,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                        child: GestureDetector(
                                          onTap: () {
                                            selectNumberOfMembers();
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Icon(Icons.person, color: Theme.of(context).accentColor, size: MediaQuery.of(context).size.width*0.05,),
                                              Container(
                                                padding: EdgeInsets.only(left: 20),
                                                width: MediaQuery.of(context).size.width*0.11,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    new Flexible(
                                                      child: TextFormField(
                                                        controller: membersController,
                                                        readOnly: true,
                                                        enabled: false,
                                                        style: Theme.of(context).textTheme.bodyText2,
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
                                                ),
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!.members.toLowerCase(),
                                                style: Theme.of(context).textTheme.bodyText2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02, left: MediaQuery.of(context).size.width*0.03, right: MediaQuery.of(context).size.width*0.05),
                                        child: TextButton(
                                          onPressed: brandClientsSelected.length < members ? () async {
                                            List<Usuario>? selectedClients = await Navigator.push(
                                                context,
                                                CupertinoPageRoute<List<Usuario>>(
                                                  builder: (context) => SelectClientsEvent(
                                                    selectedUsers: brandClientsSelected,
                                                    maxClients: members,
                                                  ),
                                                )
                                            );
                                            if (selectedClients != null) {
                                              setState(() {
                                                brandClientsSelected = selectedClients;
                                                errorClientsSelected = false;
                                              });
                                            }
                                          } : null,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Icon(Icons.person_add_alt_1, color: brandClientsSelected.length < members ? Theme.of(context).accentColor : Theme.of(context).primaryColor.withOpacity(0.2), size: MediaQuery.of(context).size.width*0.05),
                                              SizedBox(width: 10),
                                              Text(
                                                AppLocalizations.of(context)!.addDesignatedClients,
                                                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: brandClientsSelected.length != members ? Theme.of(context).accentColor : Theme.of(context).primaryColor.withOpacity(0.2), fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      brandClientsSelected.length > 0 ? Column(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                              child: new Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  new Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      new Text(
                                                        AppLocalizations.of(context)!.clients,
                                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width*0.03,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "( "+brandClientsSelected.length.toString(),
                                                        style: Theme.of(context).textTheme.bodyText2,
                                                      ),
                                                      Text(
                                                        " / ",
                                                        style: Theme.of(context).textTheme.bodyText2,
                                                      ),
                                                      Text(
                                                        members.toString()+" )",
                                                        style: Theme.of(context).textTheme.bodyText2,
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.005),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context).size.height*0.15,
                                                  width: MediaQuery.of(context).size.width,
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics: BouncingScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: brandClientsSelected.length,
                                                      itemBuilder: (context, int index) {
                                                        var trainer = brandClientsSelected[index];
                                                        return GestureDetector(
                                                          onTap: () {
                                                            var temp = brandClientsSelected;
                                                            temp.remove(trainer);
                                                            setState(() {
                                                              brandClientsSelected = temp;
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding: !(index == 0 || index == brandTrainers.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: brandTrainers.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Stack(
                                                                  alignment: Alignment.topRight,
                                                                  children: [
                                                                    CircularImage(
                                                                      size: MediaQuery.of(context).size.width*0.17,
                                                                      image: trainer.imageUrl,
                                                                      color: Theme.of(context).primaryColor,
                                                                      borderWidth: 1,
                                                                    ),
                                                                    Positioned(
                                                                      top: 0,
                                                                      left: MediaQuery.of(context).size.width*0.12,
                                                                      child: CircleAvatar(
                                                                        backgroundColor: AppColors.red,
                                                                        radius: MediaQuery.of(context).size.width*0.025,
                                                                        child: Icon(Icons.clear, color: AppColors.white, size: MediaQuery.of(context).size.width*0.035,),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: MediaQuery.of(context).size.width*0.02,
                                                                ),
                                                                Container(
                                                                  width: MediaQuery.of(context).size.width*0.2,
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Text(
                                                                        trainer.firstName!,
                                                                        style: Theme.of(context).textTheme.bodyText2,
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                /*
                                                                Container(
                                                                  width: MediaQuery.of(context).size.width*0.2,
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Text(
                                                                        trainer.firstName!,
                                                                        style: Theme.of(context).textTheme.bodyText2,
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width*0.01,
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width*0.05,
                                                                        child: IconButton(
                                                                          icon: Icon(Icons.remove_circle, color: Theme.of(context).accentColor,),
                                                                          onPressed: () {

                                                                          },
                                                                        ),

                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),

                                                                 */
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                  ),
                                                ),
                                              ],
                                            ),
                                            /*
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context).size.height*0.18,
                                              width: MediaQuery.of(context).size.width*0.87,
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: AlwaysScrollableScrollPhysics(),
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: brandTrainers!.length,
                                                  itemBuilder: (context, int index) {
                                                    var trainer = brandTrainers![index];
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          brandTrainersSelected[index] = !brandTrainersSelected[index];
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CircularImage (
                                                              size: MediaQuery.of(context).size.width*0.2,
                                                              image: trainer.imageUrl,
                                                              color: Theme.of(context).primaryColor,
                                                    borderWidth: 1,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  trainer.name!,
                                                                  style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(context).size.width*0.01,
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(context).size.width*0.05,
                                                                  child: Checkbox(
                                                                    checkColor: Colors.white,
                                                                    fillColor: MaterialStateProperty.resolveWith(getColor),
                                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                    value: brandTrainersSelected[index],
                                                                    shape: CircleBorder(
                                                                        side: BorderSide.none
                                                                    ),
                                                                    onChanged: (bool? value) {
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                              ),
                                            ),
                                          ],
                                        ),
                                         */
                                          ),
                                          errorClientsSelected ? Padding(
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                            child: Center(
                                              child: Text(
                                                AppLocalizations.of(context)!.clientsSelectedError,
                                                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ) : Container(),
                                        ],
                                      ) : Container(),
                                    ]
                                )
                            ),
                        ],
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
                    heroTag: "4",
                    onPressed: () {
                      if (_selectedIndex == 1) {
                        setState(() {
                          tabs[1] = false;
                        });
                      } else if (_selectedIndex == 2) {
                        setState(() {
                          tabs[2] = false;
                        });
                      }
                      _tabController!.animateTo(_selectedIndex -= 1);
                      setState(() {
                        addEventTabValue -= 0.33;
                      });

                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    icon: Container(),
                    label: Text(AppLocalizations.of(context)!.back, style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColorDark),),
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
                    heroTag: "5",
                    onPressed: () {
                      if (_selectedIndex == 0) {
                        if (formKeyInfo.currentState!.validate()){
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            addEventTabValue += 0.33;
                            tabs[1] = true;
                          });
                        }
                      } else if (_selectedIndex == 1) {
                        setState(() {
                          errorDate = false;
                        });
                        var startDate = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).parse(StringUtils().undoCapitalized(startDateController.text));
                        if (validateDateAndTime(startDate, double.parse(duration))) {
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            addEventTabValue += 0.33;
                            tabs[2] = true;
                          });
                        } else {
                          setState(() {
                            errorDate = true;
                          });
                        }
                      } else if (_selectedIndex == 2) {
                        if (!brandTrainersSelected.contains(true)) {
                          setState(() {
                            errorNoTrainerSelected = true;
                          });
                        } else if (brandClientsSelected.length > members) {
                          setState(() {
                            errorClientsSelected = true;
                          });
                        } else {
                          _addEvent();
                        }
                      }
                    },
                    backgroundColor: _selectedIndex == 2 ? Colors.green : Theme.of(context).accentColor,
                    icon: Container(),
                    label: Text(
                      _selectedIndex == 2 ? AppLocalizations.of(context)!.createEvent : AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.white),),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  bool validateDateAndTime(DateTime startTime, double duration) {
    // Calculating the Time to check
    var hour = duration.toString().split(".")[0];
    var min = duration.toStringAsFixed(2).split(".")[1];
    var endTime =  startTime.add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
    // Computing the workshift
    var workshift1 = currentBrand.workShift[0];
    var workshift2 = currentBrand.workShift[1];
    var startWorkHour = workshift1.toStringAsFixed(2).split(".")[0];
    var startWorkMin = workshift1.toStringAsFixed(2).split(".")[1];
    var endWorkHour = workshift2.toStringAsFixed(2).split(".")[0];
    var endWorkMin = workshift2.toStringAsFixed(2).split(".")[1];
    var startWorkDay =  DateTime(startTime.year, startTime.month, startTime.day, int.parse(startWorkHour),int.parse(startWorkMin));
    var endWorkDay =  DateTime(startTime.year, startTime.month, startTime.day, int.parse(endWorkHour),int.parse(endWorkMin));
    if ( // Can´t create event in the past
       startTime.isBefore(DateTime.now())|| startTime.isAtSameMomentAs(DateTime.now()) || endTime.isBefore(DateTime.now()) || endTime.isAtSameMomentAs(DateTime.now())
      // Can´t create event outside of working hours
      || startTime.isBefore(startWorkDay) || endTime.isBefore(startWorkDay)
      || startTime.isAfter(endWorkDay) || endTime.isAfter(endWorkDay)
    ) {
      return false;
    } else {
      // Can´t create event in break period of working hours
      for (var i=2; i<currentBrand.workShift.length; i+=2) {
        // Breaks
        var break1 = currentBrand.workShift[i];
        var break2 = currentBrand.workShift[i+1];
        // Take the minute and the hour
        var startBreakHour = break1.toStringAsFixed(2).split(".")[0];
        var startBreakMin = break1.toStringAsFixed(2).split(".")[1];
        var endBreakHour = break2.toStringAsFixed(2).split(".")[0];
        var endBreakMin = break2.toStringAsFixed(2).split(".")[1];
        // Date Time formatted
        var startBreak =  DateTime(startTime.year, startTime.month, startTime.day, int.parse(startBreakHour), int.parse(startBreakMin));
        var endBreak =  DateTime(startTime.year, startTime.month, startTime.day, int.parse(endBreakHour), int.parse(endBreakMin));
        // Condition check
        if ( ((startTime.isAfter(startBreak) || startTime.isAtSameMomentAs(startBreak)) && (startTime.isBefore(endBreak))) ||
            ((endTime.isAfter(startBreak)) && (endTime.isBefore(endBreak) || endTime.isAtSameMomentAs(endBreak)))) {
          return false;
        }
      }
      return true;
    }
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

  Future<void> _addEvent() async {
    setState(() {
      isLoading = true;
    });
    var startDate = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).parse(StringUtils().undoCapitalized(startDateController.text));
    var selectedTrainerId = [];
    for (var i=0; i< brandTrainers.length; i++) {
      if (brandTrainersSelected[i]) {
        selectedTrainerId.add(brandTrainers[i].id);
      }
    }
    // EVENT IS NOT RECURRENT
    if (!isRecurrent) {
      String eid = await _eventDataService.addEvent(currentBrand.id, titleController.text, descriptionController.text, doneAt!, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), location.id, members, selectedTrainerId);
      await Future.delayed(const Duration(milliseconds: 2000));
      for (var i=0; i<brandClientsSelected.length; i++) {
        var client = brandClientsSelected[i];
        await _eventDataService.addUserToEvent(eid, client.id!, true);
        NotificationService().userJoinEvent(client.id!, currentBrand.id!, eid);
      }
    } else {
      // EVENT IS RECURRENT
      String eid = await _eventDataService.addEvent(currentBrand.id, titleController.text, descriptionController.text, doneAt!, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), location.id, members, selectedTrainerId);
      await Future.delayed(const Duration(milliseconds: 2000));
      for (var i=0; i<brandClientsSelected.length; i++) {
        var client = brandClientsSelected[i];
        await _eventDataService.addUserToEvent(eid, client.id!, true);
        NotificationService().userJoinEvent(client.id!, currentBrand.id!, eid);
      }
      var tempDate = startDate.add(Duration(days: 1));
      var tempTimestamp = Timestamp.fromDate(tempDate);
      var weekDay = tempDate.weekday;
      if (_value == 1) {
        // One Week
        for (var i=0; i<6; i++) {
          if(values[weekDay-1]!) {
            String eid = await _eventDataService.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempTimestamp, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), location.id, members, selectedTrainerId);
            await Future.delayed(const Duration(milliseconds: 1000));
            for (var i=0; i<brandClientsSelected.length; i++) {
              var client = brandClientsSelected[i];
              await _eventDataService.addUserToEvent(eid, client.id!, true);
              NotificationService().userJoinEvent(client.id!, currentBrand.id!, eid);
            }
          }
          tempDate = tempDate.add(Duration(days: 1));
          tempTimestamp = Timestamp.fromDate(tempDate);
          weekDay = tempDate.weekday;
        }
      } else if (_value == 2) {
        // Two Weeks
        for (var i=0; i<13; i++) {
          if(values[weekDay-1]!) {
            String eid = await _eventDataService.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempTimestamp, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), location.id, members, selectedTrainerId);
            await Future.delayed(const Duration(milliseconds: 1000));
            for (var i=0; i<brandClientsSelected.length; i++) {
              var client = brandClientsSelected[i];
              await _eventDataService.addUserToEvent(eid, client.id!, true);
              NotificationService().userJoinEvent(client.id!, currentBrand.id!, eid);
            }
          }
          tempDate = tempDate.add(Duration(days: 1));
          tempTimestamp = Timestamp.fromDate(tempDate);
          weekDay = tempDate.weekday;
        }
      } else if (_value == 3) {
        // One Month
        for (var i=0; i<29; i++) {
          if(values[weekDay-1]!) {
            await Future.delayed(const Duration(milliseconds: 1000));
            String eid = await _eventDataService.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempTimestamp, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), location.id, members, selectedTrainerId);
            for (var i=0; i<brandClientsSelected.length; i++) {
              var client = brandClientsSelected[i];
              await _eventDataService.addUserToEvent(eid, client.id!, true);
              NotificationService().userJoinEvent(client.id!, currentBrand.id!, eid);
            }
          }
          tempDate = tempDate.add(Duration(days: 1));
          tempTimestamp = Timestamp.fromDate(tempDate);
          weekDay = tempDate.weekday;
        }
      }
    }
    Navigator.pop(context);
  }
}
