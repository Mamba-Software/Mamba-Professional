import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Styles.dart';
import '../LoadingView.dart';

class AddEvent extends StatefulWidget {
  Appointment? oldData;
  bool? update;
  DateTime? initialDateTime;

  AddEvent({Key? key, this.oldData, @required this.update, this.initialDateTime}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // ID Controller
  var idController = TextEditingController();
  // Title Controller
  var titleController = TextEditingController();
  // Description Controller
  var descriptionController = TextEditingController();
  // Starting Date and Time
  TextEditingController startDateController = TextEditingController();
  // Duration
  TextEditingController durationController = TextEditingController();
  String duration = "1.0";
  List<String> durations = ["0.30","1.0","1.30","2.0","2.30","3.0","3.30","4.0"];
  // Ubicació
  var ubicacionController =  TextEditingController();
  var placeId =  currentBrand.placeId!;
  // Participants
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 15;

  // Form To Validate User
  final formKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future<void> selectSlot(ctx, type) {
    // Initial Vars
    var startDate = DateTime.now();
    var title;
    var initialDuration = 1;
    var initialMembers = 1;
    var widgetPicker;
    // Init for differnt types
    if (type == 0) {
      startDate = DateFormat('E d/M/y - HH:mm').parse(startDateController.text);
    } else if (type == 1) {
      initialDuration = durations.indexWhere((element) => element == duration);
    } else if (type == 2) {
      initialMembers = members-1;
    }
    // Different types of pickers
    Widget dateTimePicker = CupertinoDatePicker(
      mode: CupertinoDatePickerMode.dateAndTime,
      initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
      maximumDate: DateTime(2025, 12),
      minimumDate: DateTime(2000, 12),
      use24hFormat: true,
      minuteInterval: 60,
      onDateTimeChanged: (val) {
        setState(() {
          startDateController.text = DateFormat('E d/M/y - HH:mm').format(val);
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
      title = "Selecciona día y hora";
      widgetPicker = dateTimePicker;
    } else if (type == 1) {
      title = "Selecciona la duración";
      widgetPicker = durationPicker;
    } else if (type == 2) {
      title = "Selecciona el número de miembros";
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
    if (widget.update!) {
      idController.text = widget.oldData!.id.toString();
      titleController.text = widget.oldData!.subject;
      startDateController.text = DateFormat('E d/M/y - HH:mm').format(widget.oldData!.startTime);
      setState(() {
        isLoading = false;
      });
    } else {
      if (widget.initialDateTime != null) {
        startDateController.text = DateFormat('E d/M/y - HH:mm').format(widget.initialDateTime!);
      } else {
        var startDate = DateTime.now();
        startDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          startDate.hour,
          0,
        );
        startDateController.text = DateFormat('E d/M/y - HH:mm').format(startDate);
      }
      idController.text = getLastId().toString();
      titleController.text = "Sesión #${getLastId()}";
      var hour = durations[1].split(".")[0];
      var min = durations[1].split(".")[1];
      durationController.text = "${hour}h ${min}min";
      membersController.text = "${members.toString()}";
      getPlaceFullAddress();
    }
  }

  void getPlaceFullAddress() async {
    final placeDetails = await LocationPlacesSearch().getPlaceDetailFromId(placeId);
    ubicacionController.text = placeDetails.fullAddress!;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: LoadingViewPurple()
      )
        :
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
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Text("Añadir Evento", style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                      ),
                      SizedBox(
                        width: 40,
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25),
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
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: new TextFormField(
                                    controller: titleController,
                                    validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.titleError : null,
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
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 15.0),
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
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: new TextFormField(
                                    controller: descriptionController,
                                    minLines: 1,
                                    maxLines: 4,
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
                          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.calendar_today_outlined, color: Theme.of(context).accentColor,),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                width: MediaQuery.of(context).size.width*0.70,
                                child: InkWell(
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
                          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.timer, color: Theme.of(context).accentColor,),
                              Container(
                                padding: EdgeInsets.only(left: 20),
                                width: MediaQuery.of(context).size.width*0.30,
                                child: InkWell(
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
                          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 0),
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
                                        color: Styles.accent,
                                        size: 25,
                                      ),
                                    ),
                                    hintText: AppLocalizations.of(context)!.enterAddress,
                                    hintStyle: Styles.purpleTextStyle,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 18.0, top: 15.0),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.person, color: Theme.of(context).accentColor,),
                              Container(
                                padding: EdgeInsets.only(left: 20),
                                width: MediaQuery.of(context).size.width*0.30,
                                child: InkWell(
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 25.0),
                    child: FloatingActionButton.extended(
                      onPressed: _addEvent,
                      label: Text("Añadir", style: Styles.whiteTextStyle.copyWith(fontSize: 20),),
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 35,
                      ),
                      backgroundColor: Styles.accent,
                      tooltip: 'Add Event',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Future<void> _addEvent() async {
    if (validateAndSave()) {
      var startDate = DateFormat('E d/M/y - HH:mm').parse(startDateController.text);
      print(double.parse(duration));
      var temp  = double.parse(duration);
      var endDate =  startDate.add(Duration(hours: temp.toInt()));
      if (widget.update!) {
        /*
        Event event = allEvents.firstWhere((element) => element.id == int.parse(idController.text));
        event.updateEvent(
          id: int.parse(idController.text),
          creatorID: currentUser.id,
          brandID: currentBrand.id,
          title: titleController.text,
          description: titleController.text,
          start: startDate,
          duration: double.parse(duration),
          placeId: placeId,
          maxMembers: members
        );

        Appointment appointment = allAppointments.firstWhere((element) => element.id == int.parse(idController.text));
        appointment.subject = titleController.text;
        appointment.startTime = startDate;
        appointment.endTime = endDate;
        */
      } else {
        var eventID = await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), double.parse(duration), placeId, members);
        print(eventID);
        setState(() {
          allAppointments.add(Appointment(
            id: int.parse(idController.text),
            startTime: startDate,
            endTime: endDate,
            subject: titleController.text,
            color: Colors.green,
            startTimeZone: '',
            endTimeZone: '',
          ));
        });
      }
      Navigator.pop(context);
    }
  }

  int getLastId() {
    return allEvents.length + 1;
  }
}
