import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/BrandEventCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../../Data/DataService/Event/EventDataService.dart';
import '../../../../../Data/Models/Event.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class BrandCalendarWeekWidget extends StatefulWidget {
  Brand brand;
  bool isMyBrand = false;
  var height;
  var width;

  BrandCalendarWeekWidget({Key? key, required this.brand, required this.isMyBrand, required this.height, required this.width}) : super(key: key);

  @override
  _BrandCalendarWeekWidgetState createState() => _BrandCalendarWeekWidgetState();
}

class _BrandCalendarWeekWidgetState extends State<BrandCalendarWeekWidget> {

  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  final _eventDataService = EventDataService();
  // Calendar
  final CalendarController _calendarController = CalendarController();
  // Date in the Middle of the Month
  DateTime middleMonthDate = DateTime.now();
  // AlL Events From User
  List<Event> eventsList = [];
  List<Appointment> allAppointments = <Appointment>[];
  // CupertinoSelect Limits for Week
  DateTime now = DateTime.now();
  DateTime startWeek = DateTime.now();
  DateTime endWeek = DateTime.now();

  // Gets the Events Done by the User
  Future<void> getBrandEvents() async {
    var eventListTemp = await _eventDataService.getBrandEventsThisMonth(widget.brand.id!);
    for (var e in eventListTemp) {
      if (e.isPrivate == false) eventsList.add(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  Event getEvent(String eventId) {
    for (var i=0; i < eventsList.length; i++) {
      Event temp = eventsList[i];
      if (temp.id == eventId) return temp;
    }
    return Event();
  }

  List<Event> documentsToEvents(List<DocumentSnapshot> documents) {
    List<Event> events = [];
    for(int i = 0; i < documents.length; i++) {
      events.add(Event.fromObjectOnlyCoverData(documents[i].id, documents[i]));
    }
    return events;
  }

  // Build the Calendar Widget
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
      var subject;
      var color;
      if (event.isPrivate!) {
        subject = "${event.numClients}";
        color = Colors.black;
      } else {
        subject = "${event.numClients}/${event.maxMembers}";
        // Colors
        double numClients = double.parse(event.numClients.toString());
        double maxMembers = double.parse(event.maxMembers.toString());
        double bookedCapacity = numClients/maxMembers;
        if(bookedCapacity <= 0.20) {
          color = Colors.green;
        } else if(bookedCapacity > 0.20 && bookedCapacity <= 0.40) {
          color = const Color(0xFFA8C76C);
        } else if(bookedCapacity > 0.40 && bookedCapacity <= 0.60) {
          color = const Color(0xFFffd966);
        } else if(bookedCapacity > 0.60 && bookedCapacity <= 0.80) {
          color = Colors.orangeAccent;
        } else if(bookedCapacity > 0.80 && bookedCapacity < 1) {
          color = Colors.deepOrangeAccent;
        } else if(bookedCapacity == 1) {
          color = Colors.red;
        }
      }
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

  Widget _buildEventContainer(CalendarAppointmentDetails details) {
    final Appointment appointment = details.appointments.first;
    final DateTime today = DateTime.now();
    bool isCompleted = appointment.endTime.isBefore(today);
    final Event event = getEvent(appointment.id.toString());
    return GestureDetector(
      onTap: () {
        navigateToEventScreen(appointment.id.toString(), isCompleted);
      },
      child: BrandEventCard(
        event: event,
        height: details.bounds.height,
        width: details.bounds.width,
        isMyBrand: true,
        color: appointment.color,
      ),
    );
  }

  // Navigate to Event Screen on Tap
  void navigateToEventScreen(String eventId, bool isCompleted) {
    mixpanel!.track('brand_calendar_weekyl_event_view', properties: {'isCompleted': isCompleted});
    // Navigate to Event Screen
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => EventPage(
            onlyView: widget.isMyBrand == false ? true : null,
            eventId: eventId,
          ),
        )
    );
  }

  @override
  void initState() {
    int day = now.weekday;
    startWeek = now.subtract(Duration(days: day-1));
    endWeek = startWeek.add(const Duration(days: 6));
    getBrandEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _eventDataService.getBrandEventsStream(widget.brand.id!),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return SizedBox(
              height: widget.height*0.8,
              child: Column(
                children: [
                  Expanded(
                      child: Center(
                          child: LoadingView(
                            isSmall: true,
                            hasLogo: false,
                          )
                      )
                  ),
                ],
              ),
            );
          } else {
            eventsList = documentsToEvents(snapshot.data!.docs);
            return Container(
              height: widget.height,
              width: widget.width,
              padding: const EdgeInsets.only(left: 4, right: 12.0),
              child: SfCalendarTheme(
                data: SfCalendarThemeData(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  todayHighlightColor: Theme.of(context).primaryColor,
                  todayBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: SfCalendar(
                  // Controller
                  view: CalendarView.month,
                  // Data
                  //minDate: startWeek,
                  //maxDate: endWeek,
                  initialDisplayDate: DateTime.now(),
                  initialSelectedDate: DateTime.now(),
                  dataSource: _getCalendarDataSource(),
                  // Config
                  cellEndPadding: 0,
                  firstDayOfWeek: 1,
                  showCurrentTimeIndicator: true,
                  cellBorderColor: Colors.transparent,
                  todayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),
                  // Style
                  selectionDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                      border: Border.all(width: 1, color: Theme.of(context).colorScheme.secondary),
                      shape: BoxShape.circle
                  ),
                  headerHeight: 0,
                  headerStyle: CalendarHeaderStyle(
                    textAlign: TextAlign.center,
                    backgroundColor: Colors.transparent,
                    textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.transparent),
                  ),
                  viewHeaderHeight: 30,
                  viewHeaderStyle: ViewHeaderStyle(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    dateTextStyle: Theme.of(context).textTheme.bodyText2,
                    dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                  ),
                  // Monthly View
                  monthViewSettings: MonthViewSettings(
                    appointmentDisplayCount: 3,
                    appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                    navigationDirection: MonthNavigationDirection.horizontal,
                    monthCellStyle: MonthCellStyle(
                      textStyle: Theme.of(context).textTheme.bodyText1,
                      trailingDatesTextStyle: Theme.of(context).textTheme.caption,
                      leadingDatesTextStyle: Theme.of(context).textTheme.caption,
                    ),
                    numberOfWeeksInView: 1,
                    showAgenda: true,
                    agendaViewHeight: widget.height*0.87,
                    agendaItemHeight: MediaQuery.of(context).size.height*0.15,
                    agendaStyle: AgendaStyle(
                      dateTextStyle: Theme.of(context).textTheme.bodyText2,
                      dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                      appointmentTextStyle: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  // On Tap
                  onTap: (CalendarTapDetails details) {
                    setState(() {
                      _calendarController.selectedDate = details.date!;
                    });
                  },
                  appointmentTextStyle: Theme.of(context).textTheme.bodyText2!,
                  appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                    return _buildEventContainer(details);
                  },
                ),
              ),
            );
          }
        }
    );
  }
}



class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
