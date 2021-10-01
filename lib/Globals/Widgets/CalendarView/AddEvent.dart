import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../GlobalVars.dart';

class AddEvent extends StatefulWidget {
  Appointment? oldData;
  bool? update;

  AddEvent({Key? key, this.oldData, @required this.update}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  // Title Controller
  var iDController = TextEditingController();
  var titleController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now().add(Duration(hours: 1));

  DateTime initial = DateTime.now();

  //////////////// form
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

  Future<DateTime> selectSlot(ctx, bool start) {
    if (start) {
      startDate = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
        startDate!.hour,
        0,
      );
      startDateController.text = DateFormat('d/M/y HH:mm').format(startDate!);
    } else {
      endDate = DateTime(
        endDate!.year,
        endDate!.month,
        endDate!.day,
        endDate!.hour,
        0,
      );
      endDateController.text = DateFormat('d/M/y HH:mm').format(endDate!);
    }

    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Material(
              child: Container(
                height: 200,
                color: Color.fromARGB(255, 255, 255, 255),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      start ? 'Select Start Time' : 'Select End Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      height: 100,
                      child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.dateAndTime,
                          initialDateTime: DateTime(initial.year, initial.month,
                              initial.day, initial.hour, 0),
                          maximumDate: DateTime(2025, 12),
                          minimumDate: DateTime(2000, 12),
                          use24hFormat: true,
                          minuteInterval: 60,
                          onDateTimeChanged: (val) {
                            setState(() {
                              if (start) {
                                startDate = val;
                                startDateController.text =
                                    DateFormat('d/M/y HH:mm').format(val);
                              } else {
                                endDate = val;
                                endDateController.text =
                                    DateFormat('d/M/y HH:mm').format(val);
                              }
                            });
                          }),
                    ),

                    // Close the modal
                    CupertinoButton(
                      child: Text('Done'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ),
              ),
            ));

    return Future.value(startDate!);
  }

  @override
  void initState() {
    if (widget.update!) {
      iDController.text = widget.oldData!.id.toString();
      titleController.text = widget.oldData!.subject;
      startDateController.text =
          DateFormat('d/M/y HH:mm').format(widget.oldData!.startTime);
      endDateController.text =
          DateFormat('d/M/y HH:mm').format(widget.oldData!.endTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 150,
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Color(0xFFF4AD1F)),
                      onPressed: () => {Navigator.pop(context)},
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text("Add Event",
                          style: TextStyle(
                              color: Color(0xFFF4AD1F),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Raleway')),
                    ),
                    SizedBox(
                      width: 40,
                    )
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 20, child: Text("ID")),
                            Container(
                                width: 50,
                                child: TextFormField(
                                  textAlignVertical: TextAlignVertical.top,
                                  maxLines: 1,
                                  controller: iDController,
                                  enabled: widget.update! ? false : true,
                                  onFieldSubmitted: (val) {},
                                  validator: (value) =>
                                      value!.isEmpty ? 'Enter an ID' : null,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.only(
                                      top: 20.0,
                                      left: 20,
                                    ),
                                    hintText: 'Enter Id',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 0.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      borderSide: BorderSide(
                                          color: Colors.grey[300]!, width: 0.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      borderSide: BorderSide(
                                          color: Colors.grey[300]!, width: 0.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      borderSide: BorderSide(
                                          color: Colors.grey[300]!, width: 0.0),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                      borderSide: BorderSide(
                                          color: Colors.grey[300]!, width: 0.0),
                                    ),
                                  ),
                                  keyboardType: TextInputType.name,
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  cursorColor: Colors.black,
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 20, child: Text("TITLE")),
                            Container(
                              width: 50,
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.top,
                                maxLines: 1,
                                controller: titleController,
                                onFieldSubmitted: (val) {},
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter a Title' : null,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.only(
                                    top: 20.0,
                                    left: 20,
                                  ),
                                  hintText: 'Enter title',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 0.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                ),
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                cursorColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            child: Text(
                              'START TIME',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              selectSlot(context, true);
                            },
                            child: Container(
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.top,
                                maxLines: 1,
                                enabled: false,
                                controller: startDateController,
                                onFieldSubmitted: (val) {},
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.only(
                                    top: 20.0,
                                    left: 20,
                                  ),
                                  hintText: 'DD/MM/YYYY HH:MM',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                ),
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                cursorColor: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            child: Text(
                              'END TIME',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              selectSlot(context, false);
                            },
                            child: Container(
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.top,
                                maxLines: 1,
                                enabled: false,
                                controller: endDateController,
                                onFieldSubmitted: (val) {},
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.only(
                                    top: 20.0,
                                    left: 20,
                                  ),
                                  hintText: 'DD/MM/YYYY HH:MM',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(
                                        color: Colors.grey[300]!, width: 0.0),
                                  ),
                                ),
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                cursorColor: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                FloatingActionButton(
                  onPressed: _addEvent,
                  backgroundColor: Color(0xFFF4AD1F),
                  tooltip: 'Add Event',
                  child: Icon(
                    Icons.add,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addEvent() {
    // TODO: Create the event given the values in Bottom Sheet.
    // The event needs to be constructed like this example:
    // Event(1,"First", DateTime.now(), DateTime.now().add(Duration(hours: 2)))
    // and then:
    // allEvents.add(Event(1,"First", DateTime.now(), DateTime.now().add(Duration(hours: 2))));

    if (validateAndSave()) {
      if (widget.update!) {
        Event event = allEvents.firstWhere(
            (element) => element.id == int.parse(iDController.text));

        event.updateEvent(
          id: int.parse(iDController.text),
          title: titleController.text,
          start: startDate,
          end: endDate,
        );

        Appointment appointment = allAppointments.firstWhere(
            (element) => element.id == int.parse(iDController.text));

        appointment.subject = titleController.text;
        appointment.startTime = startDate!;
        appointment.endTime = endDate!;
      } else {
        allEvents.add(
          Event(int.parse(iDController.text), titleController.text, startDate,
              endDate),
        );

        setState(() {
          allAppointments.add(Appointment(
            id: int.parse(iDController.text),
            startTime: startDate!,
            endTime: endDate!,
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
