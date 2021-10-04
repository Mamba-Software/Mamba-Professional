import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../GlobalVars.dart';
import 'AddEvent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarWidget extends StatefulWidget {
  CalendarWidget({Key? key}) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final CalendarController _controller = CalendarController();


  DateTime inActiveHoursStartRange1 = DateTime(2020, 09, 19, 0, 0, 0);
  DateTime inActiveHoursEndRange1 = DateTime(2020, 09, 19, 7, 0, 0);

  DateTime inActiveHoursStartRange2 = DateTime(2020, 09, 19, 14, 0, 0);
  DateTime inActiveHoursEndRange2 = DateTime(2020, 09, 19, 16, 0, 0);


  bool showOneDayView = false;
  bool showThreeDayView = false;

  List<int> nonWorkDays = [];

  DateTime prevDay = DateTime.now().add(Duration(days: -1));
  DateTime currDay = DateTime.now();
  DateTime nextDay = DateTime.now().add(Duration(days: 1));

  filterSlots(DateTime _prev, DateTime _curr, DateTime _next) {
    nonWorkDays = [];
    for (int i = 1; i <= 7; i++) {
      if (i != _prev.weekday && i != _curr.weekday && i != _next.weekday) {
        nonWorkDays.add(i);
      }
    }
    log(nonWorkDays.toString());
  }

  @override
  void initState() {
    filterSlots(prevDay, currDay, nextDay);

    log(nonWorkDays.toString());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: 10,
        ),
        child: Stack(
          children: [
            SfCalendar(
              view: CalendarView.week,
              controller: _controller,
              showDatePickerButton: true,
              headerHeight: 30,
              dataSource: _getCalendarDataSource(),
              specialRegions: _getTimeRegions(),
              firstDayOfWeek: 1,
              showCurrentTimeIndicator: false,
              timeSlotViewSettings: TimeSlotViewSettings(
                timelineAppointmentHeight: 60,
                timeIntervalHeight: 60,
                startHour: 0,
                endHour:  24,
                timeFormat: 'h:mm',
                dayFormat: 'E',
                dateFormat: 'dd',
                timeRulerSize: 45,
                nonWorkingDays: [],
                //minimumAppointmentDuration: Duration(hours: 1),
                timeTextStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black,
                )
              ),
              headerStyle: CalendarHeaderStyle(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              onLongPress: (details) {
                _addEvent();
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
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: inActiveHoursStartRange1,
      endTime: inActiveHoursEndRange1,
      color: Colors.grey.withOpacity(0.3),
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
    ));
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: inActiveHoursStartRange2,
      endTime: inActiveHoursEndRange2,
      color: Colors.grey.withOpacity(0.3),
      recurrenceRule: 'DAILY;INTERVAL=1',
    ));

    return regions;
  }

  double _getCalendarHeight() {
    return 60;
  }

  AppointmentDataSource _getCalendarDataSource() {
    return AppointmentDataSource(allAppointments);
  }

  void _addEvent({Appointment? appointment, bool? updated}) {
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