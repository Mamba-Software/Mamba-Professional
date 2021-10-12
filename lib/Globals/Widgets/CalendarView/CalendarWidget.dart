import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../GlobalVars.dart';
import '../../Styles.dart';
import 'AddEvent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarWidget extends StatefulWidget {
  CalendarWidget({Key? key}) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // Calendar Controller
  final CalendarController _controller = CalendarController();
  // Dies de la semana que el entrenador no treballa
  List<int> nonWorkDays = [];
  // Horari
  double _startHour = currentBrand.workShift[0];
  double _endHour = currentBrand.workShift[1];
  // Descansos
  DateTime dateJoined = DateFormat('dd-MM-yyyy').parse(currentBrand.dateJoined!);
  // Events From Brand
  List<Event> eventsList = [];
  List<Appointment> allAppointments = <Appointment>[];

  @override
  void initState() {
    isLoading = true;
    getAllEventsFromCurrentBrand();
    super.initState();
  }

  Future<void> getAllEventsFromCurrentBrand() async {
    Stream<QuerySnapshot> snapshot = await _accessDatabase.getAllEventsFromBrand();
    await snapshot.forEach((field) async {
      field.docs.asMap().forEach((index, value) {
        eventsList.add(Event.fromObject(field.docs[index], field.docs[index].id));
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calendar, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22),),
        centerTitle: true,
        elevation: 8,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 25,),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: 'Back',
        ),
      ),
      body: isLoading ?
        LoadingViewPurple()
          :
        Stack(
            children: [
              SfCalendar(
                view: CalendarView.week,
                controller: _controller,
                // Per tenir el botó de back to today
                showDatePickerButton: false,
                headerHeight: 50,
                dataSource: _getCalendarDataSource(),
                specialRegions: _getTimeRegions(),
                timeRegionBuilder: timeRegionBuilder,
                firstDayOfWeek: 1,
                showCurrentTimeIndicator: true,
                viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: Color(0xFFF5F5F5),
                  dateTextStyle: Styles.purpleTextStyle.copyWith(fontSize: 14),
                  dayTextStyle: Styles.purpleTextStyle.copyWith(fontSize: 14),
                ),
                selectionDecoration: BoxDecoration(
                  border: Border.all(width: 0.1, color: Colors.transparent)
                ),
                timeSlotViewSettings: TimeSlotViewSettings(
                  timelineAppointmentHeight: 60,
                  timeIntervalHeight: 60,
                  startHour: _startHour-1,
                  endHour:  _endHour+1,
                  timeFormat: 'HH:mm',
                  dayFormat: 'E',
                  dateFormat: 'd',
                  timeRulerSize: 45,
                  nonWorkingDays: nonWorkDays,
                  //minimumAppointmentDuration: Duration(hours: 1),
                  timeTextStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Theme.of(context).accentColor,
                  )
                ),
                headerStyle: CalendarHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor: Color(0xFFF5F5F5),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 4,
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onLongPress: (details) {
                  _addEvent(dateTimeClicked: details.date);
                },
                onTap: (details) {
                  log(details.date.toString());
                },
                appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                  final Appointment appointment = details.appointments.first;
                  return GestureDetector(
                    onTap: () {
                      _addEvent(appointment: appointment, updated: true);
                    },
                    child: Center(
                      child: Material(
                        elevation: 2,
                        child: Container(
                          width: details.bounds.width,
                          height: details.bounds.height,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: Center(
                            child: Text(appointment.subject, textAlign: TextAlign.center, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 15),),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
      floatingActionButton: isLoading ?
        Container()
            :
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 65,
            width: 65,
            child: FloatingActionButton(
              onPressed: _addEvent,
              backgroundColor: Color(0xFFF4AD1F),
              tooltip: 'Add Event',
              child: Icon(
                Icons.more_time,
                size: 30,
              ),
            ),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget timeRegionBuilder(BuildContext context, TimeRegionDetails timeRegionDetails) {
    return Container(
      color: Color(0x40B5B5B5),
    );
  }

  List<TimeRegion> _getTimeRegions() {
    final List<TimeRegion> regions = <TimeRegion>[];
    for (var i=2; i < currentBrand.workShift.length ; i+=2) {
      var start = currentBrand.workShift[i];
      var startHour = int.parse(start.toString().split(".")[0]);
      var startMin = int.parse(start.toString().split(".")[1]);
      var end = currentBrand.workShift[i+1];
      var endHour = int.parse(end.toString().split(".")[0]);
      var endMin = int.parse(end.toString().split(".")[1]);
      DateTime inActiveHoursStart = DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, startHour, startMin, 0);
      DateTime inActiveHoursEnd = DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, endHour, endMin, 0);
      regions.add(TimeRegion(
        enablePointerInteraction: false,
        startTime: inActiveHoursStart,
        endTime: inActiveHoursEnd,
        color: Colors.grey.withOpacity(0.3),
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
      ));
    }
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, _startHour.toInt()-1, 0, 0),
      endTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, _startHour.toInt(), 0, 0),
      color: Colors.grey.withOpacity(0.3),
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
    ));
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, _endHour.toInt(), 0, 0),
      endTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, _endHour.toInt()+1, 0, 0),
      color: Colors.grey.withOpacity(0.3),
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
    ));
    return regions;
  }

  void _addEvent({Appointment? appointment, bool? updated, DateTime? dateTimeClicked}) {
    log(allAppointments.toString());
    showModalBottomSheet<bool>(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return AddEvent(
          oldData: appointment,
          update: updated ?? false,
          initialDateTime: dateTimeClicked ?? null,
        );
      }).then((value) {
      setState(() {});
    });
  }

  AppointmentDataSource _getCalendarDataSource() {
    for (var i=0; i < eventsList.length; i++) {
      var event = eventsList[i];
      // Date Time
      var startDate =  DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        0,
      );
      var endDate =  startDate.add(Duration(hours: event.duration!.toInt()));
      // Subject
      var subject = "${event.joinedMembers.length}/${event.maxMembers}";
      // Colors
      // Afegir percentatges de ple.
      allAppointments.add(Appointment(
        id: event.id,
        startTime: startDate,
        endTime: endDate,
        subject: subject,
        color: Colors.green,
        startTimeZone: '',
        endTimeZone: '',
      ));
    }
    return AppointmentDataSource(allAppointments);
  }

}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}