import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:weekday_selector/weekday_selector.dart';
import '../../../GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../Styles.dart';
import '../../CircularImage.dart';


class AddEvent extends StatefulWidget {
  Locale locale;
  DateTime? initialDateTime;

  AddEvent({Key? key, required this.locale, this.initialDateTime}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> with SingleTickerProviderStateMixin{
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
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
  // Starting Date and Time
  TextEditingController startDateController = TextEditingController();
  bool errorDate = false;
  // Duration
  TextEditingController durationController = TextEditingController();
  String duration = "1.00";
  List<String> durations = ["0.30","1.00","1.30","2.00","2.30","3.00","3.30","4.00"];
  // Ubicació
  var ubicacionController =  TextEditingController();
  var placeId =  currentBrand.placeId!;
  // Participants
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 15;
  // Evento Recurrente
  bool isRecurrent = false;
  var oneWeek;
  var twoWeek;
  var oneMonth;
  final values = <bool?>[false, false, false, false, false, false, false];
  int _value = 1;
  // Members Page
  List<Usuario>? brandTrainers;
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
    var title;
    var initialDuration = 1;
    var initialMembers = 1;
    var widgetPicker;
    // Init for differnt types
    if (type == 0) {
      startDate = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).parse(undoCapitalized(startDateController.text));
    } else if (type == 1) {
        initialDuration = durations.indexWhere((element) => element == duration);
    } else if (type == 2) {
      initialMembers = members-1;
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
    var hour = durations[1].split(".")[0];
    var min = durations[1].split(".")[1];
    durationController.text = "${hour}h ${min}min";
    membersController.text = "${members.toString()}";
    getAllTrainersFromBrand();
    getPlaceFullAddress(currentBrand.placeId!);
  }

  Future<void> getAllTrainersFromBrand() async {
    brandTrainers = await _accessDatabase.getAllTrainersFromBrand(currentBrand.id!);
    if (brandTrainers!.length == 1) {
      brandTrainersSelected.add(true);
    } else {
      for (var i=0; i < brandTrainers!.length; i++) {
        brandTrainersSelected.add(false);
      }
    }
  }

  void getPlaceFullAddress(String placeid) async {
    //placeDetails = await LocationPlacesSearch().getPlaceDetailFromId(placeid);
    //ubicacionController.text = placeDetails.fullAddress!;
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
        toolbarHeight: MediaQuery.of(context).size.height*0.11,
        title: Text(AppLocalizations.of(context)!.addEvent, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
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
                                      /*
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 0),
                                        child: new Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Expanded(
                                              child: TextFormField(
                                                controller: ubicacionController,
                                                validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.enterAddressError : null,
                                                readOnly: true,
                                                minLines: 1,
                                                maxLines: 3,
                                                onTap: () async {
                                                  final Suggestion? result = await showSearch(
                                                    context: context,
                                                    delegate: AddressSearch(),
                                                  );
                                                  if (result != null && result.description != "") {
                                                    setState(() {
                                                      ubicacionController.text = result.description;
                                                    });
                                                    placeId = result.placeId;
                                                  }
                                                },
                                                style: Styles.purpleTextStyle,
                                                decoration: InputDecoration(
                                                  icon: Container(
                                                    width: 10,
                                                    height: 10,
                                                    child: Icon(
                                                      Icons.location_on_outlined,
                                                      color: Theme.of(context).accentColor,
                                                      size: 28,
                                                    ),
                                                  ),
                                                  hintText: AppLocalizations.of(context)!.enterAddress,
                                                  hintStyle: Styles.purpleTextStyle,
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.only(left: 18.0, top: 18),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                       */
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
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height * 0.15,
                                          width: MediaQuery.of(context).size.width * 0.90,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context).backgroundColor,
                                              borderRadius: BorderRadius.all(Radius.circular(15.0))
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(left:18, top: 10.0),
                                                child: Row(
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
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left:18, top: 10.0),
                                                child: Row(
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
                                              height: MediaQuery.of(context).size.height*0.16,
                                              width: MediaQuery.of(context).size.width,
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
                                                        padding: !(index == 0 || index == brandTrainers!.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: brandTrainers!.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            CircularImage(
                                                              size: MediaQuery.of(context).size.width*0.2,
                                                              image: trainer.imageUrl,
                                                              color: Theme.of(context).accentColor,
                                                              borderWidth: 1.5,
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(context).size.width*0.2,
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    splitCommonName(trainer.name!),
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
                                                              color: Theme.of(context).accentColor,
                                                              borderWidth: 1.5,
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
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.person, color: Theme.of(context).accentColor,),
                                            Container(
                                              padding: EdgeInsets.only(left: 20),
                                              width: MediaQuery.of(context).size.width*0.30,
                                              child: GestureDetector(
                                                  onTap: () {
                                                    selectSlot(context, 2);
                                                  },
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.max,
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
                                                  )
                                              ),
                                            ),
                                          ],
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
                    heroTag: null,
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

  /*
  Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _selectedIndex != 0 ? Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    _tabController!.animateTo(_selectedIndex -= 1);
                    setState(() {
                      addEventTabValue -= 0.33;
                    });
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  icon: Container(),
                  label: Text(AppLocalizations.of(context)!.back, style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                ),
              ) : Container(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    if (_selectedIndex == 0) {
                      if (formKeyInfo.currentState!.validate()){
                        _tabController!.animateTo(_selectedIndex += 1);
                        setState(() {
                          addEventTabValue += 0.33;
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
            ],
          ),
   */

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
        var break2 = currentBrand.workShift[i];
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
    for (var i=0; i< brandTrainers!.length; i++) {
      if (brandTrainersSelected[i]) {
        selectedTrainerId.add(brandTrainers![i].id);
      }
    }
    if (!isRecurrent) {
      await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), placeId, members, selectedTrainerId);
    } else {
      await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), placeId, members, selectedTrainerId);
      var tempDate = startDate.add(Duration(days: 1));
      var weekDay = tempDate.weekday;
      if (_value == 1) {
        // One Week
        for (var i=0; i<6; i++) {
          if(values[weekDay-1]!) {
            await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), placeId, members, selectedTrainerId);
          }
          tempDate = tempDate.add(Duration(days: 1));
          weekDay = tempDate.weekday;
        }
      } else if (_value == 2) {
        // Two Weeks
        for (var i=0; i<13; i++) {
          if(values[weekDay-1]!) {
            await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), placeId, members, selectedTrainerId);
          }
          tempDate = tempDate.add(Duration(days: 1));
          weekDay = tempDate.weekday;
        }
      } else if (_value == 3) {
        // One Month
        for (var i=0; i<29; i++) {
          if(values[weekDay-1]!) {
            await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), placeId, members, selectedTrainerId);
          }
          tempDate = tempDate.add(Duration(days: 1));
          weekDay = tempDate.weekday;
        }
      }
    }
    Navigator.pop(context);
  }
}
