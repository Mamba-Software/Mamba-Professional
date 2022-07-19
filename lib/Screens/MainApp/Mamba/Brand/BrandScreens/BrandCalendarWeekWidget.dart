import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Sesions/SesionsScreens/UserEventHistoryPage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../../Data/Models/Event.dart';
import '../../../../../Globals/Utils/Strings/StringUtils.dart';
import '../../../../../Globals/Widgets/GroupOfComponents/Calendars/UserCalendarWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrandCalendarWeekWidget extends StatefulWidget {
  String brandId;
  var height;
  var width;

  BrandCalendarWeekWidget({Key? key, required this.brandId, required this.height, required this.width}) : super(key: key);

  @override
  _BrandCalendarWeekWidgetState createState() => _BrandCalendarWeekWidgetState();
}

class _BrandCalendarWeekWidgetState extends State<BrandCalendarWeekWidget> {

  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  var _eventDataService = new EventDataService();
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
    eventsList = await _eventDataService.getBrandEventsThisMonth(widget.brandId);
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
      var subject = "${event.numClients}/${event.maxMembers}";
      // Colors
      var color;
      double numClients = double.parse(event.numClients.toString());
      double maxMembers = double.parse(event.maxMembers.toString());
      double bookedCapacity = numClients/maxMembers;
      if(bookedCapacity <= 0.20) color = Colors.green;
      else if(bookedCapacity > 0.20 && bookedCapacity <= 0.40) color = Color(0xFFA8C76C);
      else if(bookedCapacity > 0.40 && bookedCapacity <= 0.60) color = Color(0xFFECE014);
      else if(bookedCapacity > 0.60 && bookedCapacity <= 0.80) color = Colors.orangeAccent;
      else if(bookedCapacity > 0.80 && bookedCapacity < 1) color = Colors.deepOrangeAccent;
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

  // Navigate to Event Screen on Tap
  void navigateToEventScreen(String eventId) {
    // Navigate to Event Screen
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => EventPage(
            eventId: eventId,
          ),
        )
    );
  }

  @override
  void initState() {
    int day = now.weekday;
    startWeek = now.subtract(Duration(days: day-1));
    endWeek = startWeek.add(Duration(days: 6));
    getBrandEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      decoration: new BoxDecoration(
        color: Colors.transparent,
        //border: Border.all(color: AppColors.grey, width: 1),
        borderRadius: new BorderRadius.all(
          const Radius.circular(10.0),
        ),
      ),
      child: SfCalendar(
        view: CalendarView.month,
        controller: _calendarController,
        dataSource: _getCalendarDataSource(),
        firstDayOfWeek: 1,
        minDate: startWeek,
        maxDate: endWeek,
        initialSelectedDate: DateTime.now(),
        initialDisplayDate: DateTime.now(),
        showDatePickerButton: false,
        showCurrentTimeIndicator: false,
        showNavigationArrow: false,
        todayHighlightColor: Theme.of(context).accentColor,
        viewHeaderHeight: widget.height*0.13,
        viewHeaderStyle: ViewHeaderStyle(
          dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
        ),
        headerHeight: 0,
        headerDateFormat: "MMMM yyyy",
        headerStyle: CalendarHeaderStyle(
          textAlign: TextAlign.center,
          backgroundColor: Colors.transparent,
          textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.transparent),
        ),
        cellBorderColor: Colors.transparent,
        monthViewSettings: MonthViewSettings(
          navigationDirection: MonthNavigationDirection.horizontal,
          monthCellStyle: MonthCellStyle(
            textStyle: Theme.of(context).textTheme.bodyText1,
            trailingDatesTextStyle: Theme.of(context).textTheme.caption,
            leadingDatesTextStyle: Theme.of(context).textTheme.caption,
          ),
          numberOfWeeksInView: 1,
          showAgenda: true,
          agendaViewHeight: widget.height*0.75,
          agendaItemHeight: widget.height*0.14,
          agendaStyle: AgendaStyle(
            appointmentTextStyle: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        selectionDecoration: BoxDecoration(
          border: Border.all(width: 0.5, color: Theme.of(context).accentColor),
          borderRadius: new BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
        onTap: (CalendarTapDetails details) {
          setState(() {
            _calendarController.selectedDate = details.date!;
          });
        },
        appointmentTextStyle: Theme.of(context).textTheme.bodyText2!,
        appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
          final Appointment appointment = details.appointments.first;
          final DateTime today = DateTime.now();
          bool isCompleted = appointment.endTime.isBefore(today);
          final Event event = getEvent(appointment.id.toString());
          if (isCompleted) {
            return GestureDetector(
              onTap: () {
                navigateToEventScreen(appointment.id.toString());
              },
              child: Center(
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(
                      const Radius.circular(5.0),
                    ),
                  ),
                  elevation: 2,
                  child: Container(
                    height: widget.height*0.14,
                    width: details.bounds.width,
                    padding: EdgeInsets.symmetric(horizontal: details.bounds.width*0.05, vertical: widget.height*0.01),
                    decoration: BoxDecoration(
                      color: appointment.color.withOpacity(0.15),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              event.title!,
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start,
                            ),

                          ],
                        ),
                        Text(
                          DateFormat('Hm', Localizations.localeOf(context).languageCode).format(appointment.startTime) + " - " + DateFormat('Hm', Localizations.localeOf(context).languageCode).format(appointment.endTime),
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return GestureDetector(
              onTap: () {
                navigateToEventScreen(appointment.id.toString());
              },
              child: Center(
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(
                      const Radius.circular(5.0),
                    ),
                  ),
                  elevation: 2,
                  child: Container(
                    height: widget.height*0.14,
                    width: details.bounds.width,
                    padding: EdgeInsets.symmetric(horizontal: details.bounds.width*0.05, vertical: widget.height*0.01),
                    decoration: BoxDecoration(
                      color: appointment.color,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title!,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('Hm', Localizations.localeOf(context).languageCode).format(appointment.startTime) + " - " + DateFormat('Hm', Localizations.localeOf(context).languageCode).format(appointment.endTime),
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              "("+appointment.subject+")",
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
