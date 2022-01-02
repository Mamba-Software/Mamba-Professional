import 'dart:math';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/MyLocationsSelect.dart';
import 'package:mamba_castelldefels/Globals/Widgets/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../../Constants.dart';
import '../../../GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../Styles.dart';
import '../../Images/CircularImage.dart';


class ViewEventTrainer extends StatefulWidget {
  String eventId;
  bool canEdit;
  Locale locale;
  ViewEventTrainer({Key? key, required this.eventId, required this.canEdit, required this.locale}) : super(key: key);

  @override
  _ViewEventTrainerState createState() => _ViewEventTrainerState();
}

class _ViewEventTrainerState extends State<ViewEventTrainer> with SingleTickerProviderStateMixin {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  bool isLoadingBody = false;
  // Boolean isUpdated
  bool isEditing = false;
  // Title Controller
  var titleController = TextEditingController();
  String? titleString;
  // Description Controller
  var descriptionController = TextEditingController();
  String? descriptionString;
  // Starting Date and Time
  String datetitle = "";
  TextEditingController startDateController = TextEditingController();
  bool errorDate = false;
  // Duration
  TextEditingController durationController = TextEditingController();
  String duration = "1.00";
  List<String> durations = ["0.30","1.00","1.30","2.00","2.30","3.00","3.30","4.00"];
  // Location
  Location location = Location();
  // Participants
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = currentBrand.maxMembers!;
  // Members Page
  bool isFull = false;
  List<Usuario> allTrainers = [];
  List<Usuario> brandTrainersSelected = [];
  List<bool> brandTrainersSelectedBool = [];
  bool errorNoTrainerSelected = false;
  List<Usuario> brandClientsJoining = [];
  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Retrieved From BD
  Event? event;
  var placeDetails;
  // BackGround image
  Image? theImage;
  // String Deleted Photo
  String deletedObject = "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/not-found-image.jpg?alt=media&token=70687295-6a17-4735-9c0a-e5749c777319";


  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';
  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';

  @override
  initState() {
    super.initState();
    isLoading = true;
    theImage = returnRandomImage();
    getEventInfo();
  }

  // Did Change Dependencies
  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(theImage!.image, context);
  }

  Image returnRandomImage() {
    Random random = new Random();
    int randomNumber = random.nextInt(15);

    switch(randomNumber) {
      case 0: {
        return Image.asset(Constants.eventBackground);
      }
      case 1: {
        return Image.asset(Constants.eventBackground1);
      }
      case 2: {
        return Image.asset(Constants.eventBackground2);
      }
      case 3: {
        return Image.asset(Constants.eventBackground3);
      }
      case 4: {
        return Image.asset(Constants.eventBackground4);
      }
      case 5: {
        return Image.asset(Constants.eventBackground5);
      }
      case 6: {
        return Image.asset(Constants.eventBackground6);
      }
      case 7: {
        return Image.asset(Constants.eventBackground7);
      }
      case 8: {
        return Image.asset(Constants.eventBackground8);
      }
      case 9: {
        return Image.asset(Constants.eventBackground9);
      }
      case 10: {
        return Image.asset(Constants.eventBackground10);
      }
      case 11: {
        return Image.asset(Constants.eventBackground11);
      }
      case 12: {
        return Image.asset(Constants.eventBackground12);
      }
      case 13: {
        return Image.asset(Constants.eventBackground13);
      }
      case 14: {
        return Image.asset(Constants.eventBackground14);
      }
      case 15: {
        return Image.asset(Constants.eventBackground15);
      }
      default: {
        return Image.asset(Constants.eventBackground);
      }
    }
  }

  void getEventInfo() async {
    event = await _accessDatabase.getSingleEvent(widget.eventId);
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
    datetitle = DateFormat('EEEE d MMMM', widget.locale.languageCode).format(startDate);
    startDateController.text = toCapitalized(startDateController.text);
    duration = event!.duration!.toStringAsFixed(2);
    var hour = event!.duration.toString().split(".")[0];
    var min = event!.duration!.toStringAsFixed(2).split(".")[1];
    durationController.text = "${hour}h ${min}min";
    members = event!.maxMembers!;
    membersController.text = "${event!.joinedMembers.length.toString()} / ${event!.maxMembers.toString()}";
    isFull = (event!.joinedMembers!.length/event!.maxMembers == 1);
    getAllTrainersFromBrand();
    getAllClientsFromBrand();
    await getLocation(event!.locationId!);
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          isLoading = false;
          isLoadingBody = false;
          isEditing = false;
        });
      });
    }
  }

  Future<void> getAllTrainersFromBrand() async {
    allTrainers = await _accessDatabase.getAllTrainersFromBrand(currentBrand.id!);
    brandTrainersSelectedBool = [];
    List<Usuario> temp = [];
    for (var i=0; i < allTrainers.length; i++) {
      var trainer = allTrainers[i];
      if (event!.selectedTrainers.contains(trainer.id)) {
        temp.add(trainer);
        brandTrainersSelectedBool.add(true);
      } else {
        brandTrainersSelectedBool.add(false);
      }
    }
    for (var i=0; i < event!.selectedTrainers.length; i++) {
      String user = event!.selectedTrainers[i];
      if (user == "notfound") {
        temp.add(Usuario(name: AppLocalizations.of(context)!.notFoundUser, imageUrl: deletedObject));
      }
    }
    if (mounted) {
      setState(() {
        brandTrainersSelected = temp;
      });
    }
  }

  Future<void> getAllClientsFromBrand() async {
    List<Usuario> allClients = await _accessDatabase.getAllClientsFromBrand(currentBrand.id!);
    List<Usuario> temp = [];
    for (var i=0; i < allClients.length; i++) {
      var client = allClients[i];
      if (event!.joinedMembers.contains(client.id)) {
        temp.add(client);
      }
    }
    for (var i=0; i < event!.joinedMembers.length; i++) {
      String user = event!.joinedMembers[i];
      if (user == "notfound") {
        temp.add(Usuario(name: AppLocalizations.of(context)!.notFoundUser, imageUrl: deletedObject));
      }
    }
    setState(() {
      brandClientsJoining = temp;
    });
  }

  Future<void> getLocation(String locationId) async {
    location = await _accessDatabase.getSingleLocation(locationId);
    var temp = location;
    setState(() {
      location = temp;
    });
  }

  Future<void> selectSlot(ctx, type) {
    // Initial Vars
    var startDate = DateTime.now();
    var minimumDate = DateTime.now().subtract(Duration(days: 365));
    var maximumDate = DateTime.now().add(Duration(days: 365));
    var title;
    var initialDuration = 1;
    var initialMembers = 1;
    var totalMembers = (membersMax) - event!.joinedMembers.length;
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
      initialMembers = 0;
    }
    // Different types of pickers
    Widget dateTimePicker = CupertinoDatePicker(
        mode: CupertinoDatePickerMode.dateAndTime,
        initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        use24hFormat: true,
        minuteInterval: 30,
        onDateTimeChanged: (val) {
          setState(() {
            startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(val);
            startDateController.text = toCapitalized(startDateController.text);
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
            members = event!.joinedMembers.length+index;
            membersController.text = "${event!.joinedMembers.length.toString()} / ${members.toString()}";
          });
        },
        children: new List<Widget>.generate(totalMembers.toInt(), (int index) {
          var member = event!.joinedMembers.length+index;
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
    if (
    // Can´t create event in the past
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

  String splitCommonName(String name) {
    List<String> aux = name.split(" ");
    return aux[0];
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

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    Scaffold(
      appBar: null,
      body: LoadingViewPurple(),
    )
        :
    Scaffold(
      appBar: null,
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.26,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: theImage!.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.26,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  gradient: LinearGradient(
                      begin: FractionalOffset.bottomCenter,
                      end: FractionalOffset.topCenter,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.9),
                      ],
                      stops: [
                        0.8,
                        1
                      ]
                  ),
                ),
                child: Center(),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.23,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height*0.10,
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
                    ),
                    elevation: 4,
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: !isEditing ? Theme.of(context).primaryColor : Colors.white),
                              onPressed: !isEditing ? () {
                               Navigator.pop(context);
                              } : null,
                            ),
                          ),
                          isEditing ? Text(AppLocalizations.of(context)!.editEvent, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)) : Text(datetitle, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                          !widget.canEdit ? Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.06, left: MediaQuery.of(context).size.width*0.06),
                            child: Container(),
                          ) :
                          Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05, left: MediaQuery.of(context).size.width*0.05),
                            child: Column(
                              children: [
                                !isEditing ? Icon(isFull ? Icons.lock_outline : Icons.lock_open, color: isFull ? Colors.red : Color(0xFFA8C76C)) : Icon(Icons.lock_open, color: Colors.white),
                                !isEditing ? Text(isFull ? AppLocalizations.of(context)!.full : AppLocalizations.of(context)!.available, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 12, color: isFull ? Colors.red : Color(0xFFA8C76C))) : Text(AppLocalizations.of(context)!.full, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.32,
            bottom: 0,
            left: 0,
            right: 0,
            child: !isLoadingBody ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Form(
                              key: formKeyInfo,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      isEditing ? new Expanded(
                                        child: new TextFormField(
                                          controller: titleController,
                                          validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.titleError : null,
                                          style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 24),
                                          decoration: InputDecoration(
                                              labelStyle: Styles.purpleTextStyle.copyWith(fontSize: 16),
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
                                              contentPadding: EdgeInsets.all(0)
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ) : new Expanded(
                                        child: new TextField(
                                          controller: titleController,
                                          readOnly: true,
                                          style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 22),
                                          decoration: InputDecoration(
                                            labelStyle: Styles.purpleTextStyle.copyWith(fontSize: 16),
                                            hintText:AppLocalizations.of(context)!.noDescription,
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 0),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          isEditing ? new Flexible(
                                            child: new TextFormField(
                                              controller: descriptionController,
                                              minLines: 1,
                                              maxLines: 6,
                                              style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                              decoration: InputDecoration(
                                                labelStyle: Styles.purpleTextStyle.copyWith(fontSize: 16),
                                                hintText:AppLocalizations.of(context)!.noDescription,
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
                                              textAlign: TextAlign.justify,
                                            ),
                                          ) : new Flexible(
                                            child: new TextFormField(
                                              controller: descriptionController,
                                              readOnly: true,
                                              minLines: 1,
                                              maxLines: 4,
                                              style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                              decoration: InputDecoration(
                                                labelStyle: Styles.purpleTextStyle.copyWith(fontSize: 16),
                                                hintText:AppLocalizations.of(context)!.noDescription,
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder: InputBorder.none,
                                                contentPadding: EdgeInsets.all(0),
                                              ),
                                              textAlign: TextAlign.justify,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.035),
                            errorDate ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.errorDate,
                                    style: Styles.redTextStyle.copyWith(fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ): Container(),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.30,
                              width: MediaQuery.of(context).size.width * 0.90,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).backgroundColor,
                                  borderRadius: BorderRadius.all(Radius.circular(15.0))
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.05),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(Icons.calendar_today_outlined, color: Theme.of(context).accentColor,),
                                        Container(
                                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05),
                                            width: MediaQuery.of(context).size.width*0.70,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                isEditing ? new Flexible(
                                                  child: TextFormField(
                                                    controller: startDateController,
                                                    readOnly: true,
                                                    onTap: () {
                                                      if (isEditing) selectSlot(context, 0);
                                                    },
                                                    style: Styles.purpleTextStyle,
                                                    decoration: InputDecoration(
                                                      labelStyle: Styles.purpleTextStyle,
                                                      border: InputBorder.none,
                                                      enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: errorDate ? Colors.red : Colors.grey,
                                                              width: 1.0
                                                          )
                                                      ),
                                                      focusedBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: errorDate ? Colors.red : Colors.grey,
                                                              width: 1.0
                                                          )
                                                      ),
                                                      disabledBorder: InputBorder.none,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ) : new Flexible(
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
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(Icons.timer, color: Theme.of(context).accentColor,),
                                        Container(
                                            padding: EdgeInsets.only(left: 20),
                                            width: MediaQuery.of(context).size.width*0.70,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                isEditing ? new Flexible(
                                                  child: TextFormField(
                                                    controller: durationController,
                                                    onTap: () {
                                                      if (isEditing) selectSlot(context, 1);
                                                    },
                                                    readOnly: true,
                                                    style: Styles.purpleTextStyle,
                                                    decoration: InputDecoration(
                                                      labelStyle: Styles.purpleTextStyle,
                                                      border: InputBorder.none,
                                                      enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: errorDate ? Colors.red : Colors.grey,
                                                              width: 1.0
                                                          )
                                                      ),
                                                      focusedBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: errorDate ? Colors.red : Colors.grey,
                                                              width: 1.0
                                                          )
                                                      ),
                                                      disabledBorder: InputBorder.none,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ) : new Flexible(
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
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.location_on_outlined, color: Theme.of(context).accentColor, size: 30,),
                                            Container(
                                              padding: EdgeInsets.only(left: 15),
                                              width: MediaQuery.of(context).size.width*0.70,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.all(0),
                                                title: Text(
                                                    location.description!,
                                                    style: Styles.purpleTextStyle.copyWith(color: Theme.of(context).primaryColor)
                                                ),
                                                trailing: !isEditing ? IconButton(
                                                  onPressed: () async {
                                                    Clipboard.setData(new ClipboardData(text: location.description!)).then((_){
                                                      showTopSnackBar(
                                                        context,
                                                        CustomSnackBar.info(
                                                          icon: Container(),
                                                          iconRotationAngle: 0,
                                                          backgroundColor: Theme.of(context).accentColor,
                                                          message: AppLocalizations.of(context)!.copyCorrectLocation,
                                                          textStyle: Styles.whiteTextStyle,
                                                        ),
                                                      );
                                                    });
                                                  },
                                                  icon: Icon(Icons.copy, color: Theme.of(context).accentColor, size: 25,),
                                                ) : Icon(Icons.edit_location_outlined, color: Theme.of(context).accentColor, size: 25,),
                                                onTap: isEditing ? () async {
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
                                                  print("result");
                                                  print(result);
                                                  if (result != null) {
                                                    await getLocation(result);
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  }
                                                } : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                        isEditing ? Padding(
                                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.1, top:MediaQuery.of(context).size.width*0.01),
                                          child: Container(
                                            height: 1,
                                            width: MediaQuery.of(context).size.width*0.64,
                                            color: Colors.grey,
                                          ),
                                        ) : Container(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.0),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.03),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 10),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Text(
                                          AppLocalizations.of(context)!.numberClientJoining,
                                          style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Icon(
                                      Icons.record_voice_over,
                                      color: Theme.of(context).accentColor,
                                      size: 25,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.trainers,
                                      style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                                    ),
                                  ],
                                ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  isEditing ? Container(
                                    height: MediaQuery.of(context).size.height*0.15,
                                    width: MediaQuery.of(context).size.width*0.99,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: AlwaysScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: allTrainers.length,
                                        itemBuilder: (context, int index) {
                                          var trainer = allTrainers[index];
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                brandTrainersSelectedBool[index] = !brandTrainersSelectedBool[index];
                                              });
                                            },
                                            child: Padding(
                                              padding: !(index == 0 || index == allTrainers.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: allTrainers.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
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
                                                            value: brandTrainersSelectedBool[index],
                                                            shape: CircleBorder(
                                                                side: BorderSide.none
                                                            ),
                                                            onChanged: (bool? value) {
                                                              setState(() {
                                                                brandTrainersSelectedBool[index] = !brandTrainersSelectedBool[index];
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
                                  ) :
                                  Container(
                                    height: MediaQuery.of(context).size.height*0.15,
                                    width: MediaQuery.of(context).size.width*0.99,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: brandTrainersSelected.length,
                                        itemBuilder: (context, int index) {
                                          var trainer = brandTrainersSelected[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(context, CupertinoPageRoute<Null>(
                                                builder: (context) => ProfileViewUser(userID: trainer.id!, viewOnly: false)));
                                            },
                                            child: Padding(
                                              padding: !(index == 0 || index == brandTrainersSelected.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: brandTrainersSelected.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  CircularImage(
                                                    size: MediaQuery.of(context).size.width*0.2,
                                                    image: trainer.imageUrl,
                                                    color: Theme.of(context).primaryColor,
                                                    borderWidth: 1,
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.2,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            trainer.name! != AppLocalizations.of(context)!.notFoundUser ? splitCommonName(trainer.name!) : trainer.name!,
                                                            style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                            textAlign: TextAlign.center,
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
                            SizedBox(height: MediaQuery.of(context).size.height*0.01),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 10),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Icon(
                                    Icons.directions_run,
                                    color: Theme.of(context).accentColor,
                                    size: 25,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(context)!.clients,
                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                                  ),
                                  SizedBox(width: 16),
                                  !isEditing ? Row(
                                    children: [
                                      Text(
                                        "( "+event!.joinedMembers.length.toString(),
                                        style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16),
                                      ),
                                      Text(
                                        " / ",
                                        style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16),
                                      ),
                                      Text(
                                        event!.maxMembers.toString()+" )",
                                        style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16),
                                      ),
                                    ],
                                  ) : Container(),
                                ],
                              ),
                            ),
                            isEditing ? Padding(
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
                                      width: MediaQuery.of(context).size.width*0.18,
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
                                    Text(
                                      AppLocalizations.of(context)!.members.toLowerCase(),
                                      style: Styles.purpleTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ) : Padding(
                              padding: EdgeInsets.only(top: 0),
                              child:
                              brandClientsJoining.isEmpty ?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                          height: 100,
                                          child: Image.asset(Constants.emptyPeople)
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.noClientJoining,
                                        style: Styles.purpleTextStyle.copyWith(color: Color(0xFF808080), fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ) :
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height*0.15,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: brandClientsJoining.length,
                                        itemBuilder: (context, int index) {
                                          var client = brandClientsJoining[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(context, CupertinoPageRoute<Null>(
                                                builder: (context) => ProfileViewUser(userID: client.id!, viewOnly: false)));
                                            },
                                            child: Padding(
                                              padding: !(index == 0 || index == brandClientsJoining.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: brandClientsJoining.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  CircularImage(
                                                    size: MediaQuery.of(context).size.width*0.2,
                                                    image: client.imageUrl,
                                                    color: Theme.of(context).primaryColor,
                                                    borderWidth: 1,
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.2,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            client.name! != AppLocalizations.of(context)!.notFoundUser ? splitCommonName(client.name!) : client.name!,
                                                            style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                            textAlign: TextAlign.center,
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
                            ),
                            isEditing ? SizedBox(height: MediaQuery.of(context).size.height*0.10) : SizedBox(height: MediaQuery.of(context).size.height*0.05),
                            widget.canEdit ? SizedBox(height: MediaQuery.of(context).size.height*0.17) : SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
            ) : Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.13),
                child: LoadingViewPurple()),
          ),
        ],
      ),
      floatingActionButton: whichFloatingActionButton(),
    );
  }

  Widget whichFloatingActionButton() {
    if (isLoadingBody) {
      return Container();
    } else {
      if (widget.canEdit) {
        if (isEditing) {
          return Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
            child: Container(
              width: MediaQuery.of(context).size.width*0.70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: "8",
                        onPressed: () async {
                          bool hasError = false;
                          setState(() {
                            errorDate = false;
                            errorNoTrainerSelected = false;
                          });
                          var startDate = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).parse(undoCapitalized(startDateController.text));
                          if (!formKeyInfo.currentState!.validate()) {
                            hasError = true;
                          }
                          if (!validateDateAndTime(startDate, double.parse(duration))) {
                            hasError = true;
                            setState(() {
                              errorDate = true;
                            });
                          }
                          if (!brandTrainersSelectedBool.contains(true)) {
                            hasError = true;
                            setState(() {
                              errorNoTrainerSelected = true;
                            });
                          }
                          if (!hasError) {
                            setState(() {
                              isLoadingBody = true;
                            });
                            var selectedTrainerId = [];
                            for (var i=0; i< allTrainers.length; i++) {
                              if (brandTrainersSelectedBool[i]) {
                                selectedTrainerId.add(allTrainers[i].id);
                              }
                            }
                            await _accessDatabase.updateEvent(widget.eventId, titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), location.id, members, selectedTrainerId);
                            getEventInfo();
                          }
                        },
                        backgroundColor: Colors.green,
                        icon: Icon(Icons.save_rounded, color: Colors.white,),
                        label: Text(AppLocalizations.of(context)!.save,
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                      FloatingActionButton.extended(
                        heroTag: "75",
                        icon: SizedBox(width: MediaQuery.of(context).size.width*0.001,),
                        label: Padding(
                          padding: EdgeInsets.only(right:MediaQuery.of(context).size.width*0.011,),
                          child: Icon(Icons.cancel_outlined, size: 35,),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Styles.white,
                        onPressed: () async {
                          setState(() {
                            isLoadingBody = true;
                          });
                          getEventInfo();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                  FloatingActionButton.extended(
                    heroTag: "7",
                    onPressed: () async {
                      // DeleteDialog
                      var result = await showDialog(
                          context: context,
                          builder: (_) {
                            return DeleteConfirmationDialog(text: AppLocalizations.of(context)!.deleteEventConfirmation);
                          }
                      );
                      if (result) {
                        setState(() {
                          isLoadingBody = true;
                        });
                        await _accessDatabase.deleteEvent(widget.eventId);
                        Navigator.pop(context);
                      }
                    },
                    backgroundColor: Colors.red,
                    icon: Icon(Icons.delete_outline, color: Colors.white,),
                    label: Text(AppLocalizations.of(context)!.delete,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
            child: Container(
              width: MediaQuery.of(context).size.width*0.25,
              child: FloatingActionButton.extended(
                heroTag: "9",
                onPressed: () {
                  setState(() {
                    isEditing = true;
                  });
                },
                backgroundColor: Colors.green,
                icon: Icon(Icons.edit, color: Colors.white,),
                label: Text(AppLocalizations.of(context)!.edit,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
              ),
            ),
          );
        }
      } else {
        return Container();
      }
    }
  }
}

