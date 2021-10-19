import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:weekday_selector/weekday_selector.dart';
import '../../Constants.dart';
import '../../GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../Styles.dart';
import '../CircularImage.dart';


class AddEvent extends StatefulWidget {
  Appointment? oldData;
  bool update;
  Locale locale;
  DateTime? initialDateTime;

  AddEvent({Key? key, this.oldData, required this.update, required this.locale, this.initialDateTime}) : super(key: key);

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
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, true, true];
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
      if (widget.update){
        initialDuration = durations.indexWhere((element) => element == event.duration.toStringAsFixed(2));
      } else {
        initialDuration = durations.indexWhere((element) => element == duration);
      }
    } else if (type == 2) {
      if (widget.update){
        initialMembers = event.maxMembers - 1;
      } else {
        initialMembers = members-1;
      }
    }
    // Different types of pickers
    Widget dateTimePicker = CupertinoDatePicker(
      mode: CupertinoDatePickerMode.dateAndTime,
      initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
      minimumDate: startDate.subtract(Duration(days: 1)),
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
            if (widget.update) {
              membersController.text = "${event.joinedMembers.length.toString()} / ${members.toString()}";
            } else {
              membersController.text = "${members.toString()}";
            }
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
    if (widget.update) {
      getEventInfo(widget.oldData!.id!.toString());
    } else {
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
      getPlaceFullAddress();
    }
  }

  void getEventInfo(String id) async {
    event = await _accessDatabase.getSingleEvent(id);
    titleController.text = "${event.title}";
    titleString = "${event.title}";
    descriptionController.text = "${event.description}";
    descriptionString = "${event.description}";
    var startDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );
    startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(startDate);
    startDateController.text = toCapitalized(startDateController.text);
    var hour = event.duration.toString().split(".")[0];
    var min = event.duration!.toStringAsFixed(2).split(".")[1];
    durationController.text = "${hour}h ${min}min";
    membersController.text = "${event.joinedMembers.length.toString()} / ${event.maxMembers.toString()}";
    getAllTrainersFromBrand();
    getPlaceFullAddress();
  }

  void getPlaceFullAddress() async {
    placeDetails = await LocationPlacesSearch().getPlaceDetailFromId(placeId);
    ubicacionController.text = placeDetails.fullAddress!;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getAllTrainersFromBrand() async {
    brandTrainers = await _accessDatabase.getAllTrainersFromBrand(currentBrand.id!);
    print(brandTrainers);
  }



  @override
  Widget build(BuildContext context) {
    // Check if something has changed
    if(widget.update && event != null) {
      var startDate = DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      var hour = event.duration.toString().split(".")[0];
      var min = event.duration!.toStringAsFixed(2).split(".")[1];
      if (titleController.text != "${event.title}" || (titleString != "${event.title}" && titleString != null)) {
        setState(() {
          isUpdated = true;
        });
      } else if (descriptionController.text != "${event.description}" || (descriptionString != "${event.description}" && descriptionString != null)) {
        setState(() {
          isUpdated = true;
        });
      } else if (undoCapitalized(startDateController.text) != DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(startDate)) {
        setState(() {
          isUpdated = true;
        });
      } else if (durationController.text != "${hour}h ${min}min") {
        setState(() {
          isUpdated = true;
        });
      } else if (membersController.text != "${event.joinedMembers.length.toString()} / ${event.maxMembers.toString()}") {
        setState(() {
          isUpdated = true;
        });
      } else if (ubicacionController.text != placeDetails.fullAddress!) {
        setState(() {
          isUpdated = true;
        });
      } else {
        setState(() {
          isUpdated = false;
        });
      }
    }

    return isLoading ?
      Container(
        height: MediaQuery.of(context).size.height*0.75,
        child: LoadingViewPurple()
      )
        :
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height*0.75,
        ),
        //padding: MediaQuery.of(context).viewInsets,
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              toolbarHeight: MediaQuery.of(context).size.height*0.15,
              title: Text(!widget.update ? AppLocalizations.of(context)!.addEvent : AppLocalizations.of(context)!.editEvent, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
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
                  child: TabBar(
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
                              Icon(Icons.info_outlined, color: tabs[0] ? Theme.of(context).accentColor : Colors.transparent)
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
                              Icon(Icons.calendar_today_outlined, color: tabs[1] ? Theme.of(context).accentColor : Colors.transparent)
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
                              Icon(Icons.group, color: tabs[2] ? Theme.of(context).accentColor : Colors.transparent)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ),
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Column(
                children: [
                  LinearProgressIndicator(
                    value: addEventTabValue,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    color: Theme.of(context).accentColor,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Scaffold(
                          body: SingleChildScrollView(
                            child: Column(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      minHeight: MediaQuery.of(context).size.height*0.50,
                                    ),
                                    child: Form(
                                      key: formKeyInfo,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 25.0, right: 25.0),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.only(top: 25),
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
                                                  padding: EdgeInsets.only(top: 15),
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
                                                padding: EdgeInsets.only(bottom: 0),
                                                child: new Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: ubicacionController,
                                                        validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.enterAddressError : null,
                                                        readOnly: true,
                                                        maxLines: 2,
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
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                      height: 120,
                                                      child: Image.asset(Constants.locationImage)
                                                  ),
                                                ],
                                              ),
                                            ]
                                        ),
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
                                  Container(
                                    constraints: BoxConstraints(
                                      minHeight: MediaQuery.of(context).size.height*0.50,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 25.0, right: 25.0),
                                      child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15.0),
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
                                            ) : new Container(),
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
                                  Container(
                                    constraints: BoxConstraints(
                                      minHeight: MediaQuery.of(context).size.height*0.50,
                                    ),
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 25.0, right: 25.0),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.only(top: 25),
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
                                                padding: EdgeInsets.only(top: 10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: MediaQuery.of(context).size.height*0.18,
                                                      child: ListView.builder(
                                                          shrinkWrap: true,
                                                          scrollDirection: Axis.horizontal,
                                                          itemCount: brandTrainers!.length,
                                                          itemBuilder: (context, int index) {
                                                            var trainer = brandTrainers![index];
                                                            return GestureDetector(
                                                              onTap: null,
                                                              child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Padding(
                                                                        padding: const EdgeInsets.all(4.0),
                                                                        child: CircularImage (
                                                                          size: MediaQuery.of(context).size.width*0.20,
                                                                          image: trainer.imageUrl,
                                                                          color: Theme.of(context).accentColor,
                                                                          borderWidth: 1.5,
                                                                        ),
                                                                      ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.all(4.0),
                                                                      child: Text(
                                                                        trainer.name!,
                                                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                            );
                                                            /*
                                                            return GestureDetector(
                                                              onTap: null,
                                                              child: Container(
                                                                constraints: BoxConstraints(
                                                                  maxHeight: MediaQuery.of(context).size.height*0.15,
                                                                ),
                                                                padding: EdgeInsets.all(8),
                                                                child: Column(
                                                                  children: [
                                                                    CircularImage (
                                                                      size: MediaQuery.of(context).size.width*0.10,
                                                                      image: trainer.imageUrl,
                                                                      color: Theme.of(context).accentColor,
                                                                    ),
                                                                    Text(
                                                                      trainer.name!,
                                                                      style: Styles.purpleTextStyle.copyWith(fontSize: 16),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                             */
                                                          }
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(top: 25),
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
                                                padding: EdgeInsets.only(top: 10),
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
                                  ),
                                ],
                              )
                          ),
                          resizeToAvoidBottomInset: false,
                        ),
                      ],
                    ),
                  ),
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
                            if (_selectedIndex == 2) {
                              _addEvent();
                            } else {
                              if (_selectedIndex == 0) {
                                if (formKeyInfo.currentState!.validate()){
                                  _tabController!.animateTo(_selectedIndex += 1);
                                  setState(() {
                                    addEventTabValue += 0.33;
                                  });
                                }
                              } else if (_selectedIndex == 1) {
                                var startDate = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).parse(undoCapitalized(startDateController.text));
                                if (validateDateAndTime(startDate, double.parse(duration))) {
                                  setState(() {
                                    errorDate = false;
                                  });
                                  _tabController!.animateTo(_selectedIndex += 1);
                                  setState(() {
                                    addEventTabValue += 0.33;
                                  });
                                } else {
                                  setState(() {
                                    errorDate = true;
                                  });
                                }
                              }
                            }
                          },
                          backgroundColor: _selectedIndex == 2 ? Colors.green : Theme.of(context).accentColor,
                          icon: Container(),
                          label: Text(_selectedIndex == 2 ? AppLocalizations.of(context)!.createEvent : AppLocalizations.of(context)!.next, style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      );
  }

  /*
  Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height*0.86,
        ),
        padding: MediaQuery.of(context).viewInsets,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Styles.accent),
                        onPressed: () => {
                          Navigator.pop(context)
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, right: 10),
                        child: Text(!widget.update ? "Añadir Evento" : "Editar Evento", style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                      ),
                      widget.update ? MaterialButton(
                        onPressed: isUpdated ? () => {
                          _addEvent(),
                        } : null,
                        color: isUpdated ? Colors.green : Colors.transparent,
                        child: Icon(Icons.save, color: isUpdated ? Colors.white : Styles.accentLight),
                        padding: EdgeInsets.all(15),
                        shape: CircleBorder(),
                      ) : SizedBox(width: 40),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 25),
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
                            )),
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
                                      AppLocalizations.of(context)!.description,
                                      style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 2.0),
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
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
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
                          padding: EdgeInsets.only(top: 10),
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
                        Padding(
                          padding: EdgeInsets.only(top: 0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  controller: ubicacionController,
                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.enterAddressError : null,
                                  readOnly: true,
                                  onTap: () async {
                                    final Suggestion? result = await showSearch(
                                      context: context,
                                      delegate: AddressSearch(),
                                    );
                                    if (result != null) {
                                      //final placeDetails = await LocationPlacesSearch().getPlaceDetailFromId(result.placeId);
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
                                        size: 25,
                                      ),
                                    ),
                                    hintText: AppLocalizations.of(context)!.enterAddress,
                                    hintStyle: Styles.purpleTextStyle,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 18.0, top: 8),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
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
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  "Crear evento recurrente",
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
                                padding: EdgeInsets.only(top: 10),
                                child: new Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        "Días",
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 14),
                                      ),
                                    ),
                                    WeekdaySelector(
                                      fillColor: Colors.white,
                                      selectedFillColor: Theme.of(context).accentColor,
                                      textStyle: Styles.purpleTextStyle,
                                      selectedTextStyle: Styles.whiteTextStyle,
                                      // Working Days disabledFillColor: Colors.red,
                                      onChanged: (v) {
                                        printIntAsDay(v);
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
                                        "Durante",
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
                                            'Solo esta semana',
                                            style: Styles.purpleTextStyle,
                                          ),
                                          subtitle: Text(
                                            "Hasta el ${toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(DateTime.now()))}",
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
                                            'Dos semanas',
                                            style: Styles.purpleTextStyle,
                                          ),
                                          subtitle: Text(
                                            "Hasta el ${toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(DateTime.now()))}",
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
                                            'Todo el mes',
                                            style: Styles.purpleTextStyle,
                                          ),
                                          subtitle: Text(
                                            "Hasta el ${toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(DateTime.now()))}",
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
                      ],
                    ),
                  ),
                  !widget.update ? Padding(
                    padding: EdgeInsets.only(bottom: 25.0, top: 15),
                    child: FloatingActionButton.extended(
                      onPressed: _addEvent,
                      label: Text("Añadir", style: Styles.whiteTextStyle.copyWith(fontSize: 20),),
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 35,
                      ),
                      backgroundColor: Theme.of(context).accentColor,
                    ),
                  )
                    :
                  Padding(
                    padding: EdgeInsets.only(bottom: 25.0, top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton.extended(
                          label: Text("Eliminar", style: Styles.whiteTextStyle.copyWith(fontSize: 18),),
                          icon: Icon(Icons.delete_outline),
                          backgroundColor: Colors.red,
                          foregroundColor: Styles.white,
                          onPressed: () async {
                            // Delete Function
                            _accessDatabase.deleteEvent(widget.oldData!.id!.toString());
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
   */

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
    if (widget.update) {
      if(isUpdated) await _accessDatabase.updateEvent(widget.oldData!.id.toString(), titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), placeId, members);
    } else {
      if (!isRecurrent) {
        await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), placeId, members);
      } else {
        await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), placeId, members);
        var tempDate = startDate.add(Duration(days: 1));
        var weekDay = tempDate.weekday;
        if (_value == 1) {
          // One Week
          for (var i=0; i<6; i++) {
            if(values[weekDay-1]!) {
              await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), placeId, members);
            }
            tempDate = tempDate.add(Duration(days: 1));
            weekDay = tempDate.weekday;
          }
        } else if (_value == 2) {
          // Two Weeks
          for (var i=0; i<13; i++) {
            if(values[weekDay-1]!) {
              await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), placeId, members);
            }
            tempDate = tempDate.add(Duration(days: 1));
            weekDay = tempDate.weekday;
          }
        } else if (_value == 3) {
          // One Month
          for (var i=0; i<29; i++) {
            if(values[weekDay-1]!) {
              await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, tempDate.year.toString(),tempDate.month.toString(),tempDate.day.toString(),tempDate.hour.toString(), tempDate.minute.toString(), double.parse(duration), placeId, members);
            }
            tempDate = tempDate.add(Duration(days: 1));
            weekDay = tempDate.weekday;
          }
        }
      }
    }
    Navigator.pop(context);
  }
}
