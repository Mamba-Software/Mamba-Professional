import 'dart:developer';
import 'dart:ffi';
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
import 'AddEventDelete.dart';
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
  double? _startHour;
  double? _endHour;
  // Descansos
  DateTime dateJoined = DateFormat('dd-MM-yyyy').parse(currentBrand.dateJoined!);
  // Events From Brand
  List<Event> eventsList = [];
  List<Appointment> allAppointments = <Appointment>[];

  @override
  void initState() {
    _startHour = double.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
    _endHour = double.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calendar, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 25,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _accessDatabase.getAllEventsFromBrand(),
          builder: (context, snapshot) {
            if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
              return LoadingViewPurple();
            }
            else {
              eventsList = documentsToEvents(snapshot.data!.docs);
              return SfCalendar(
                cellEndPadding: 0,
                view: CalendarView.week,
                controller: _controller,
                // Per tenir el botó de back to today
                showDatePickerButton: false,
                headerHeight: 45,
                headerDateFormat: null,
                dataSource: _getCalendarDataSource(),
                specialRegions: _getTimeRegions(),
                timeRegionBuilder: timeRegionBuilder,
                firstDayOfWeek: 1,
                showCurrentTimeIndicator: true,
                viewHeaderHeight: 50,
                viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: Theme.of(context).backgroundColor,
                  dateTextStyle: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                  dayTextStyle: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                selectionDecoration: BoxDecoration(
                    border: Border.all(width: 0.1, color: Colors.transparent)
                ),
                timeSlotViewSettings: TimeSlotViewSettings(
                    timelineAppointmentHeight: 50,
                    timeIntervalHeight: 60,
                    timeIntervalWidth: 55,
                    startHour: _startHour!-1,
                    endHour:  _endHour!+1,
                    timeFormat: 'HH',
                    dayFormat: 'E',
                    dateFormat: 'd',
                    timeRulerSize: 25,
                    nonWorkingDays: nonWorkDays,
                    minimumAppointmentDuration: Duration(minutes: 30),
                    timeTextStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                    )
                ),
                headerStyle: CalendarHeaderStyle(
                  textAlign: TextAlign.justify,
                  backgroundColor: Color(0xFFF5F5F5),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 4,
                    color: Theme.of(context).accentColor,
                  ),
                ),
                onLongPress: (details) {
                  if(details.date!.isAfter(DateTime.now())) {
                    _addEvent(dateTimeClicked: details.date);
                  }
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
                            color: appointment.color,
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
              );
            }
          }
      ),
      floatingActionButton: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 65,
            width: 65,
            child: FloatingActionButton(
              onPressed: _addEvent,
              backgroundColor: Theme.of(context).accentColor,
              child: Icon(
                Icons.more_time,
                size: 30,
                color: Theme.of(context).backgroundColor,
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
    // Breaks
    for (var i=2; i < currentBrand.workShift.length ; i+=2) {
      var start = currentBrand.workShift[i];
      var startHour = int.parse(start.toStringAsFixed(2).split(".")[0]);
      var startMin = int.parse(start.toStringAsFixed(2).split(".")[1]);
      var end = currentBrand.workShift[i+1];
      var endHour = int.parse(end.toStringAsFixed(2).split(".")[0]);
      var endMin = int.parse(end.toStringAsFixed(2).split(".")[1]);
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
    // Hora Inactiva Matí
    var startHourWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
    var startMinWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, startHourWS-1, 0, 0),
      endTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, startHourWS, startMinWS, 0),
      color: Colors.grey.withOpacity(0.3),
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
    ));
    // Hora Inactiva Nit
    var endHourWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
    var endMinWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, endHourWS, endMinWS, 0),
      endTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, endHourWS+1, 0, 0),
      color: Colors.grey.withOpacity(0.3),
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
    ));
    return regions;
  }

  List<Event> documentsToEvents(List<DocumentSnapshot> documents) {
    List<Event> events = [];
    for(int i = 0; i < documents.length; i++) {
      events.add(Event.fromObject(documents[i], documents[i].id));
    }
    return events;
  }

  AppointmentDataSource _getCalendarDataSource() {
    List<Appointment> tempAllAppointments = [];
    for (var i=0; i < eventsList.length; i++) {
      var event = eventsList[i];
      // Date Time
      var startDate =  DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      var hour = event.duration.toString().split(".")[0];
      var min = event.duration!.toStringAsFixed(2).split(".")[1];
      var endDate =  startDate.add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
      // Subject
      var subject = "${event.joinedMembers.length}/${event.maxMembers}";
      // Colors
      var color;
      double bookedCapacity = event.joinedMembers.length/event.maxMembers;
      if(bookedCapacity < 0.20) color = Colors.green;
      else if(bookedCapacity > 0.20 && bookedCapacity < 0.40) color = Color(0xFFECE014);
      else if(bookedCapacity > 0.40 && bookedCapacity < 0.60) color = Colors.orangeAccent;
      else if(bookedCapacity > 0.60 && bookedCapacity < 0.80) color = Colors.deepOrangeAccent;
      else if(bookedCapacity == 1) color = Colors.red;
      // Afegir percentatges de members al Event.
      tempAllAppointments.add(Appointment(
        id: event.id,
        startTime: startDate,
        endTime: endDate,
        subject: subject,
        color: color,
        startTimeZone: '',
        endTimeZone: '',
      ));
    }
    allAppointments = tempAllAppointments;
    return AppointmentDataSource(allAppointments);
  }

  void _addEvent({Appointment? appointment, bool? updated, DateTime? dateTimeClicked}) {
    showModalBottomSheet<bool>(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
      ),
      isScrollControlled: true,
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height*0.88,
          ),
          padding: MediaQuery.of(context).viewInsets,
          child: AddEvent(
            oldData: appointment,
            update: updated ?? false,
            locale: Localizations.localeOf(context),
            initialDateTime: dateTimeClicked ?? null,
          ),
        );
      });
  }

}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
