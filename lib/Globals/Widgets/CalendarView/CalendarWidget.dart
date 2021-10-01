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
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.calendar,
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Raleway',
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        elevation: 10,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 25,
          ),
          onPressed: () {},
          tooltip: 'Back',
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.view_day, size: 25),
                    onPressed: () {
                      print("Switch to 1-Day View");
                      _controller.view = CalendarView.day;
                      setState(() {
                        showOneDayView = true;
                        showThreeDayView = false;
                      });
                    },
                    tooltip: 'Go to 1-Day View',
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_view_day, size: 25),
                    onPressed: () {
                      print("Switch to 3-Day View");
                      filterSlots(prevDay, _controller.displayDate!, nextDay);
                      _controller.view = CalendarView.workWeek;
                      setState(() {
                        showOneDayView = true;
                        showThreeDayView = true;
                      });
                    },
                    tooltip: 'Go to 3-Day View',
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_view_week, size: 25),
                    onPressed: () {
                      print("Switch to Week View");
                      _controller.view = CalendarView.week;
                      setState(() {
                        showOneDayView = false;
                        showThreeDayView = false;
                      });
                    },
                    tooltip: 'Go to Week View',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
//              onViewChanged: (details) {
//                SchedulerBinding.instance!.addPostFrameCallback((duration) {
//                  setState(() {
//                    nextDay = _controller.displayDate!.add(Duration(days: 1));
//                    prevDay = _controller.displayDate!.add(Duration(days: -1));
//
//                    if (showThreeDayView) {
//                      filterSlots(prevDay, _controller.displayDate!, nextDay);
//                    }
//                  });
//                });
//              },
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
              headerHeight: _controller.view == CalendarView.day ? 5 : 5,
              specialRegions: _getTimeRegions(),
              dataSource: _getCalendarDataSource(),
              firstDayOfWeek: 1,
              timeSlotViewSettings: TimeSlotViewSettings(
                  timelineAppointmentHeight: 60,
                  timeIntervalHeight: 60,
                  dayFormat: '',
                  startHour: 6,
                  nonWorkingDays: showThreeDayView ? nonWorkDays : [],
                  minimumAppointmentDuration: Duration(hours: 1),
                  timeTextStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  )),
              headerStyle: CalendarHeaderStyle(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onLongPress: (details) {
                _addEvent();
              },
              onTap: (details) {
                log(details.date.toString());
              },
            ),
            showOneDayView
                ? Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          left: showThreeDayView ? 20 : 10,
                        ),
                        height: showThreeDayView ? 20 : 10,
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                  child: Text(
                                    '${prevDay.day}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                            ),
                            InkWell(
                              onTap: () {
                                log(_controller.displayDate!.day.toString());
                              },
                              child: Container(
                                width: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orange,
                                ),
                                child: Center(
                                    child: Text(
                                      '${_controller.displayDate!.day}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ),
                            ),
                            Container(
                              width: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                  child: Text(
                                    '${nextDay.day}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: InkWell(
                          onTap: () {
                            _controller.displayDate = DateTime.now();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: Icon(
                              Icons.today,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
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