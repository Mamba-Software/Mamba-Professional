import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../Styles.dart';


class AddEvent extends StatefulWidget {
  Appointment? oldData;
  bool update;
  Locale locale;
  DateTime? initialDateTime;

  AddEvent({Key? key, this.oldData, required this.update, required this.locale, this.initialDateTime}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // Boolean isUpdated
  bool isUpdated = false;
  // Title Controller
  var titleController = TextEditingController();
  // Description Controller
  var descriptionController = TextEditingController();
  // Starting Date and Time
  TextEditingController startDateController = TextEditingController();
  // Duration
  TextEditingController durationController = TextEditingController();
  String duration = "1.0";
  List<String> durations = ["0.30","1.00","1.30","2.00","2.30","3.00","3.30","4.00"];
  // Ubicació
  var ubicacionController =  TextEditingController();
  var placeId =  currentBrand.placeId!;
  // Participants
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 15;
  // Form To Validate User
  final formKey = GlobalKey<FormState>();
  // Event Retrieved From BD
  var event;
  var placeDetails;

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';
  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';

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
      minimumDate: startDate.subtract(Duration(days: 365)),
      maximumDate: startDate.add(Duration(days: 365)),
      use24hFormat: true,
      minuteInterval: 30,
      onDateTimeChanged: (val) {
        setState(() {
          startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(val);
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
    if (widget.update) {
      getEventInfo(widget.oldData!.id!.toString());
    } else {
      if (widget.initialDateTime != null) {
        startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(widget.initialDateTime!);
        startDateController.text = toCapitalized(startDateController.text);
      } else {
        var startDate = DateTime.now();
        startDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          startDate.hour,
          0,
        );
        startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(startDate);
        startDateController.text = toCapitalized(startDateController.text);

      }
      titleController.text = "Sesión #${currentBrand.name}";
      var hour = durations[1].split(".")[0];
      var min = durations[1].split(".")[1];
      durationController.text = "${hour}h ${min}min";
      membersController.text = "${members.toString()}";
      getPlaceFullAddress();
    }
  }

  void getEventInfo(String id) async {
    event = await _accessDatabase.getSingleEvent(id);
    titleController.text = "${event.title}";
    descriptionController.text = "${event.description}";
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
    getPlaceFullAddress();
  }

  void getPlaceFullAddress() async {
    placeDetails = await LocationPlacesSearch().getPlaceDetailFromId(placeId);
    ubicacionController.text = placeDetails.fullAddress!;
    setState(() {
      isLoading = false;
    });
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
      if (titleController.text != "${event.title}") {
        setState(() {
          isUpdated = true;
        });
      } else if (descriptionController.text != "${event.description}") {
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
                        child: Text(!widget.update ? "Añadir Evento" : "Editar Evento", style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                      ),
                      SizedBox(
                        width: 40,
                      )
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
                      ],
                    ),
                  ),
                  !widget.update ? Padding(
                    padding: EdgeInsets.only(bottom: 25.0),
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
                    padding: EdgeInsets.only(bottom: 25.0),
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
                        FloatingActionButton.extended(
                          icon: Icon(Icons.save),
                          label: Text("Guardar", style: Styles.whiteTextStyle.copyWith(fontSize: 18),),
                          backgroundColor: isUpdated ? Colors.green : Colors.green[100],
                          foregroundColor: Styles.white,
                          onPressed: isUpdated ? () {
                            _addEvent();
                          } : null,
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
  }

  Future<void> _addEvent() async {
    if (validateAndSave()) {
      var startDate = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).parse(undoCapitalized(startDateController.text));
      if (widget.update) {
        if(isUpdated) await _accessDatabase.updateEvent(widget.oldData!.id.toString(), titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), placeId, members);
      } else {
        await _accessDatabase.addEvent(currentBrand.id, titleController.text, descriptionController.text, startDate.year.toString(),startDate.month.toString(),startDate.day.toString(),startDate.hour.toString(), startDate.minute.toString(), double.parse(duration), placeId, members);
      }
      Navigator.pop(context);
    }
  }
}
