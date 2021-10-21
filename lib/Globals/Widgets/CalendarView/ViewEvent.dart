import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../Constants.dart';
import '../../GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../Styles.dart';
import '../CircularImage.dart';


class ViewEvent extends StatefulWidget {
  Appointment? oldData;
  bool update;
  Locale locale;
  DateTime? initialDateTime;

  ViewEvent({Key? key, this.oldData, required this.update, required this.locale, this.initialDateTime}) : super(key: key);

  @override
  _ViewEventState createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> with SingleTickerProviderStateMixin{
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
  List<bool> brandTrainersSelected = [];
  bool errorNoTrainerSelected = false;
  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Retrieved From BD
  Event? event;
  var placeDetails;

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';
  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';


  @override
  initState() {
    isLoading = true;
    _tabController = TabController(length: 2, vsync: this);
  }

  void getEventInfo() async {
    titleController.text = "${event!.title}";
    titleString = "${event!.title}";
    descriptionController.text = "${event!.description}";
    descriptionString = "${event!.description}";
    var startDate = DateTime(
      int.parse(event!.year!),
      int.parse(event!.month!),
      int.parse(event!.day!),
      int.parse(event!.hour!),
      int.parse(event!.minute!),
    );
    startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(startDate);
    startDateController.text = toCapitalized(startDateController.text);
    var hour = event!.duration.toString().split(".")[0];
    var min = event!.duration!.toStringAsFixed(2).split(".")[1];
    durationController.text = "${hour}h ${min}min";
    membersController.text = "${event!.joinedMembers.length.toString()} / ${event!.maxMembers.toString()}";
    getAllTrainersFromBrand();
    getPlaceFullAddress();
  }

  Future<void> getAllTrainersFromBrand() async {
    brandTrainers = await _accessDatabase.getAllTrainersFromBrand(currentBrand.id!);
    if (brandTrainers!.length == 1) {
      brandTrainersSelected.add(true);
    } else {
      if (widget.update) {
        for (var i=0; i < brandTrainers!.length; i++) {
          var trainer = brandTrainers![i];
          if (event!.selectedTrainers.contains(trainer.id)) {
            brandTrainersSelected.add(true);
          } else {
            brandTrainersSelected.add(false);
          }
        }
      } else {
        for (var i=0; i < brandTrainers!.length; i++) {
          brandTrainersSelected.add(false);
        }
      }
    }
  }

  void getPlaceFullAddress() async {
    placeDetails = await LocationPlacesSearch().getPlaceDetailFromId(placeId);
    ubicacionController.text = placeDetails.fullAddress!;
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _accessDatabase.getSingleEventStream(widget.oldData!.id.toString()),
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data == null ) {
            return LoadingViewPurple();
          } else {
            event = Event.fromObject(snapshot.data!, snapshot.data!.id);
            getEventInfo();
            return isLoading ? LoadingViewPurple() :
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
                  title: Text(titleController.text, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
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
                  bottom: TabBar(
                        controller: _tabController,
                        indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(width: 3.0, color:Theme.of(context).accentColor, ),
                        ),
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
                                  Icon(Icons.group, color: tabs[2] ? Theme.of(context).accentColor : Colors.transparent)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                ),
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    Expanded(
                        child: TabBarView(
                          controller: _tabController,
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
                                                      padding: EdgeInsets.only(top: 5.0),
                                                      child: new Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        children: <Widget>[
                                                          new Flexible(
                                                            child: new TextFormField(
                                                              keyboardType: TextInputType.visiblePassword,
                                                              controller: descriptionController,
                                                              minLines: 1,
                                                              maxLines: 5,
                                                              onChanged: (val) {
                                                                setState(() {
                                                                  descriptionString = val;
                                                                });
                                                              },
                                                              style: Styles.purpleTextStyle,
                                                              decoration: InputDecoration(
                                                                labelStyle: Styles.purpleTextStyle,
                                                                hintText:AppLocalizations.of(context)!.descriptionError,
                                                                border: InputBorder.none,
                                                                focusedBorder: InputBorder.none,
                                                                enabledBorder: InputBorder.none,
                                                                errorBorder: InputBorder.none,
                                                                disabledBorder: InputBorder.none,
                                                              ),
                                                              textAlign: TextAlign.justify,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 5.0),
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
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
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
                                                            onTap: null,
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
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(width: MediaQuery.of(context).size.width*0.05,),
                                                      FloatingActionButton(
                                                        child: Icon(Icons.copy),
                                                        elevation: 0,
                                                        backgroundColor: Theme.of(context).accentColor,
                                                        foregroundColor: Styles.white,
                                                        onPressed: () async {
                                                          Clipboard.setData(new ClipboardData(text: ubicacionController.text)).then((_){
                                                            showTopSnackBar(
                                                              context,
                                                              CustomSnackBar.info(
                                                                icon: Container(),
                                                                iconRotationAngle: 0,
                                                                backgroundColor: Theme.of(context).primaryColor,
                                                                message: AppLocalizations.of(context)!.copyCorrectCode,
                                                                textStyle: Styles.whiteTextStyle,
                                                              ),
                                                            );
                                                          });
                                                        },
                                                      ),
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
                                                      padding: EdgeInsets.only(top: 20),
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
                                                    padding: EdgeInsets.only(top: 15),
                                                    child: Row(
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
                                                                return Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        CircularImage(
                                                                          size: MediaQuery.of(context).size.width*0.2,
                                                                          image: trainer.imageUrl,
                                                                          color: Theme.of(context).accentColor,
                                                                          borderWidth: 1.5,
                                                                        ),
                                                                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              trainer.name!,
                                                                              style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                              }
                                                          ),
                                                        ),
                                                      ],
                                                    ),
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
                        )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: FloatingActionButton.extended(
                            onPressed: () {
                            },
                            backgroundColor: Colors.red,
                            icon: Icon(Icons.delete_outline, color: Colors.white,),
                            label: Text("Borrar", style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width*0.05,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                          child: FloatingActionButton.extended(
                            onPressed: () {

                            },
                            backgroundColor: Colors.green,
                            icon: Icon(Icons.edit, color: Colors.white,),
                            label: Text("Editar",
                              style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
    );
  }
  /*
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
    if (widget.update) {
      //if(isUpdated) await _accessDatabase.updateEvent(widget.oldData!.id.toString(), titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), placeId, members, selectedTrainerId);
      await _accessDatabase.updateEvent(widget.oldData!.id.toString(), titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), placeId, members, selectedTrainerId);
    } else {
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
    }
    Navigator.pop(context);
  }
   */
}
