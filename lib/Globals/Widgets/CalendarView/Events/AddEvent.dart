import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/LocationDataService.dart';

import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/MyLocationsSelect.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weekday_selector/weekday_selector.dart';
import '../../../GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../Styles/Styles.dart';
import '../../Images/CircularImage.dart';


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
  TextEditingController startDateController = TextEditingController();
  bool errorDate = false;
  // Duration
  TextEditingController durationController = TextEditingController();
  String duration = "1.00";
  List<String> durations = ["0.30","0.45","1.00","1.15","1.30","1.45","2.00","2.15","2.30","2.45","3.00"];
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
  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Retrieved From BD
  var event;
  var placeDetails;

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';
  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';

  Future<void> selectSlot(ctx, type) {
    // Initial Vars
    var startDate = DateTime.now();
    var minimumDate = DateTime.now().subtract(Duration(days: 365));
    var maximumDate = DateTime.now().add(Duration(days: 365));
    var title;
    var initialDuration = 2;
    var initialMembers = 1;
    var widgetPicker;
    // Init for differnt types
    if (type == 0) {
      startDate = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).parse(undoCapitalized(startDateController.text));
      // Calcular el horari de la marca
      // Hora Inactiva Matí
      var startHourWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
      var startMinWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
      minimumDate = DateTime(startDate.year, startDate.month, startDate.day, startHourWS, startMinWS);
      // Hora Inactiva Nit
      var endHourWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
      var endMinWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
      var temp = DateTime(startDate.year, startDate.month, startDate.day, endHourWS, endMinWS);
      maximumDate = temp.add(Duration(days: 365));
    } else if (type == 1) {
      initialDuration = durations.indexWhere((element) => element == duration);
    } else if (type == 2) {
      initialMembers = members-1;
    }
    // Different types of pickers
    Widget dateTimePicker = CupertinoDatePicker(
      mode: CupertinoDatePickerMode.dateAndTime,
      initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour, 0),
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      use24hFormat: true,
      minuteInterval: 15,
      onDateTimeChanged: (val) {
        setState(() {
          startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(val);
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
    if (type == 0) {
      title = AppLocalizations.of(context)!.selectDayTime;
      widgetPicker = dateTimePicker;
    } else if (type == 1) {
      title = AppLocalizations.of(context)!.selectDuration;
      widgetPicker = durationPicker;
    } else if (type == 2) {
      title = AppLocalizations.of(context)!.selectMembers;
      widgetPicker = membersPicker;
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
              SizedBox(height: MediaQuery.of(context).size.height*0.02),
            ],
          ),
        ),
      )
    );
    return Future.value("");
  }

  @override
  initState() {
    isLoading = true;
    _tabController = TabController(length: 3, vsync: this);
    if (widget.initialDateTime != null) {
      startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(widget.initialDateTime!);
      startDateController.text = toCapitalized(startDateController.text);
      oneWeek = widget.initialDateTime!.add(Duration(days: 7));
      twoWeek = widget.initialDateTime!.add(Duration(days: 14));
      oneMonth= widget.initialDateTime!.add(Duration(days: 30));
    } else {
      var startDate = DateTime.now();
      startDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        startDate.hour+1,
        0,
      );
      startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(startDate);
      startDateController.text = toCapitalized(startDateController.text);
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

  void getLocation(String locationId) async {
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
          icon: Icon(Icons.arrow_back, color: Styles.accent),
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
                            Icon(Icons.info_outlined, color: tabs[0] ? Theme.of(context).accentColor : Colors.grey)
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
                            Icon(Icons.calendar_today_outlined, color: tabs[1] ? Theme.of(context).accentColor : Colors.grey.withOpacity(0.2))
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
                            Icon(Icons.group, color: tabs[2] ? Theme.of(context).accentColor : Colors.grey.withOpacity(0.2))
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
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(top: 2.0),
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
                                                  decoration: InputDecoration(
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
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(top: 15.0),
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
                                                  decoration: InputDecoration(
                                                    labelStyle: Styles.purpleTextStyle,
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
                                          padding: EdgeInsets.only(top: 15),
                                          child: new Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              new Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  new Text(
                                                    AppLocalizations.of(context)!.location,
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 15.0),
                                        child: ListTile(
                                          leading: Icon(location.isBaseLocation! ? Icons.home_filled : Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: 25,),
                                          title: Text(
                                              location.description!,
                                              style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor)
                                          ),
                                          trailing: Icon(Icons.swap_horiz, color: Theme.of(context).primaryColor, size: 25,),
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
                  resizeToAvoidBottomInset: false,
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
                                                  Icon(Icons.calendar_today_outlined, color: Theme.of(context).accentColor,),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                                    width: MediaQuery.of(context).size.width*0.70,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          selectSlot(context, 0);
                                                        },
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.max,
                                                          children: <Widget>[
                                                            new Flexible(
                                                              child: TextFormField(
                                                                controller: startDateController,
                                                                readOnly: true,
                                                                enabled: false,
                                                                style: Styles.purpleTextStyle,
                                                                decoration: InputDecoration(
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
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Icon(Icons.timer, color: Theme.of(context).accentColor,),
                                                  Container(
                                                    padding: EdgeInsets.only(left: 20),
                                                    width: MediaQuery.of(context).size.width*0.30,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          selectSlot(context, 1);
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
                                                                style: Styles.purpleTextStyle,
                                                                decoration: InputDecoration(
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
                                            style: Styles.redTextStyle.copyWith(fontSize: 16),
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
                                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
                                                      style: Styles.purpleTextStyle.copyWith(fontSize: 14),
                                                    ),
                                                  ),
                                                  WeekdaySelector(
                                                    fillColor: Colors.white,
                                                    selectedFillColor: Theme.of(context).accentColor,
                                                    textStyle: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                    selectedTextStyle: Styles.whiteTextStyle.copyWith(fontSize: 15),
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
                                                      style: Styles.purpleTextStyle.copyWith(fontSize: 14),
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
                                                          style: Styles.purpleTextStyle,
                                                        ),
                                                        subtitle: Text(
                                                          AppLocalizations.of(context)!.until(toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(oneWeek))),
                                                          style: Styles.purpleTextStyle.copyWith(fontSize: 14), textAlign: TextAlign.left,
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
                                                          style: Styles.purpleTextStyle,
                                                        ),
                                                        subtitle: Text(
                                                          AppLocalizations.of(context)!.until(toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(twoWeek))),
                                                          style: Styles.purpleTextStyle.copyWith(fontSize: 14), textAlign: TextAlign.left,
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
                                                          style: Styles.purpleTextStyle,
                                                        ),
                                                        subtitle: Text(
                                                          AppLocalizations.of(context)!.until(toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(oneMonth))),
                                                          style: Styles.purpleTextStyle.copyWith(fontSize: 14), textAlign: TextAlign.left,
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
                  resizeToAvoidBottomInset: false,
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
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
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
                                                              size: MediaQuery.of(context).size.width*0.2,
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
                                            style: Styles.redTextStyle.copyWith(fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ) : Container(),
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
                                                    AppLocalizations.of(context)!.maxNumberClients,
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
                                            selectSlot(context, 2);
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Icon(Icons.person, color: Theme.of(context).accentColor,),
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
                                                        style: Styles.purpleTextStyle,
                                                        decoration: InputDecoration(
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
                                                ),
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!.members.toLowerCase(),
                                                style: Styles.purpleTextStyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]
                                )
                            ),
                        ],
                      )
                  ),
                  resizeToAvoidBottomInset: false,
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
                        var startDate = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).parse(undoCapitalized(startDateController.text));
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
                        } else {
                          _addEvent();
                        }
                      }
                    },
                    backgroundColor: _selectedIndex == 2 ? Colors.green : Theme.of(context).accentColor,
                    icon: Container(),
                    label: Text(
                      _selectedIndex == 2 ? AppLocalizations.of(context)!.createEvent : AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  String splitCommonName(String name) {
    List<String> aux = name.split(" ");
    return aux[0];
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
    var startDate = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).parse(undoCapitalized(startDateController.text));
    var selectedTrainerId = [];
    for (var i=0; i< brandTrainers.length; i++) {
      if (brandTrainersSelected[i]) {
        selectedTrainerId.add(brandTrainers[i].id);
      }
    }
    // EVENT IS NOT RECURRENT
    if (!isRecurrent) {
      await _eventDataService.addEvent(currentBrand.id, titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), location.id, members, selectedTrainerId);
    } else {
      // EVENT IS RECURRENT
      await _eventDataService.addEvent(currentBrand.id, titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), location.id, members, selectedTrainerId);
      var tempDate = startDate.add(Duration(days: 1));
      var weekDay = tempDate.weekday;
      if (_value == 1) {
        // One Week
        for (var i=0; i<6; i++) {
          if(values[weekDay-1]!) {
            await _eventDataService.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), location.id, members, selectedTrainerId);
          }
          tempDate = tempDate.add(Duration(days: 1));
          weekDay = tempDate.weekday;
        }
      } else if (_value == 2) {
        // Two Weeks
        for (var i=0; i<13; i++) {
          if(values[weekDay-1]!) {
            await _eventDataService.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), location.id, members, selectedTrainerId);
          }
          tempDate = tempDate.add(Duration(days: 1));
          weekDay = tempDate.weekday;
        }
      } else if (_value == 3) {
        // One Month
        for (var i=0; i<29; i++) {
          if(values[weekDay-1]!) {
            await _eventDataService.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), location.id, members, selectedTrainerId);
          }
          tempDate = tempDate.add(Duration(days: 1));
          weekDay = tempDate.weekday;
        }
      }
    }
    await Future.delayed(const Duration(milliseconds: 3000));
    Navigator.pop(context);
  }
}
