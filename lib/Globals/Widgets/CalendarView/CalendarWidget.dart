import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
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
  // Calendar Controller
  final CalendarController _controller = CalendarController();
  // Dies de la semana que el entrenador no treballa
  List<int> nonWorkDays = [];
  // Horari
  double _startHour = currentBrand.workShift[0];
  double _endHour = currentBrand.workShift[1];
  // Descansos
  DateTime dateJoined = DateFormat('dd-MM-yyyy').parse(currentBrand.dateJoined!);

  @override
  void initState() {
    super.initState();
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
      body: Stack(
          children: [
            SfCalendar(
              view: CalendarView.week,
              controller: _controller,
              showDatePickerButton: false,
              headerHeight: 50,
              dataSource: _getCalendarDataSource(),
              specialRegions: _getTimeRegions(),
              firstDayOfWeek: 1,
              showCurrentTimeIndicator: true,
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
                  color: Colors.black,
                )
              ),
              headerStyle: CalendarHeaderStyle(
                textAlign: TextAlign.center,
                backgroundColor: Styles.mainColorTrans,
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 4
                ),
              ),
              onLongPress: (details) {
                _addEvent(dateTimeClicked: details.date);
              },
              onTap: (details) {
                log(details.date.toString());
              },
              appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                return InkWell(
                  onTap: () {
                    _addEvent(appointment: details.appointments.first, updated: true);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    alignment: Alignment.center,
                    width: 80,
                    height: 100,
                    child: Center(
                      child: Text('1/5'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      floatingActionButton: Padding(
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

  AppointmentDataSource _getCalendarDataSource() {
    return AppointmentDataSource(allAppointments);
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
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}