import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/events/crud_events/read_event/views/mobile/ReadEventPage.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Events/EventPage/UserEventCard.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:mamba/commons/managers/language_manager.dart';

class UserEventHistoryWidget extends StatefulWidget {
  String userId;
  bool isTrainer;
  List<Event> events;

  UserEventHistoryWidget(
      {super.key,
      required this.userId,
      required this.isTrainer,
      required this.events});

  @override
  _UserEventHistoryWidgetState createState() => _UserEventHistoryWidgetState();
}

class _UserEventHistoryWidgetState extends State<UserEventHistoryWidget> {
  // Sesions Controller
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final CalendarController _controller = CalendarController();
  // List of items in our dropdown menu
  String selectedValue = '0';
  var items = ['0', '1', '2'];
  // Events From Brand
  List<Event> eventsList = [];
  List<Appointment> allAppointments = <Appointment>[];
  // Selecte Date Time
  DateTime dateJoined = DateTime.now();
  DateTime displayDateTimeStart = DateTime.now();
  DateTime displayDateTimeEnd = DateTime.now();
  DateTime middleMonthDate = DateTime.now();

  @override
  void initState() {
    // Init Calendar
    dateJoined = DateFormat('dd-MM-yyyy').parse(currentUser.dateJoined!);
    DateTime now = DateTime.now();
    int currentDay = now.weekday;
    displayDateTimeStart = now.subtract(Duration(days: currentDay - 1));
    displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));
    // Calendar View
    _controller.view = CalendarView.schedule;
    // Show Date
    _controller.selectedDate = DateTime.now();
    _controller.displayDate = DateTime.now().subtract(const Duration(hours: 1));
    // Events
    eventsList = widget.events;
    super.initState();
  }

  void navigateToEventScreen(String eventId, bool isCompleted) {
    mixpanel!.track('user_calendar_event_view', properties: {
      'Calendar View': _controller.view.toString(),
      'isCompleted': isCompleted
    });
    // Navigate to Event Screen
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => EventPage(
            eventId: eventId,
          ),
        ));
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
      child: UserEventCard(
        event: event,
        height: details.bounds.height,
        width: details.bounds.width,
        isMyEvent: true,
        showEmoji: !widget.isTrainer,
      ),
    );
  }

  Event getEvent(String eventId) {
    for (var i = 0; i < eventsList.length; i++) {
      Event temp = eventsList[i];
      if (temp.id == eventId) return temp;
    }
    return Event();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.mySessions,
          style: Theme.of(context).appBarTheme.titleTextStyle,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.03,
            left: MediaQuery.of(context).size.width * 0.02),
        child: Column(
          children: [
            Expanded(
              child: SfCalendarTheme(
                data: SfCalendarThemeData(
                  brightness: Brightness.dark,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  todayHighlightColor: Theme.of(context).primaryColor,
                  todayBackgroundColor:
                      Theme.of(context).colorScheme.background,
                ),
                child: SfCalendar(
                  // Controller
                  controller: _controller,
                  view: CalendarView.schedule,
                  blackoutDates: [dateJoined.subtract(const Duration(days: 1))],
                  blackoutDatesTextStyle: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600),
                  // Data
                  minDate: dateJoined.subtract(const Duration(days: 1)),
                  initialDisplayDate: DateTime.now(),
                  initialSelectedDate: DateTime.now(),
                  dataSource: _getCalendarDataSource(),
                  // Config
                  cellEndPadding: 0,
                  firstDayOfWeek: 1,
                  showCurrentTimeIndicator: true,
                  cellBorderColor: Colors.transparent,
                  todayTextStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).primaryColorDark),
                  // Style
                  selectionDecoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.08),
                      border: Border.all(
                          width: 1,
                          color: Theme.of(context).colorScheme.secondary),
                      shape: BoxShape.circle),
                  headerHeight: 0,
                  headerStyle: CalendarHeaderStyle(
                    textAlign: TextAlign.center,
                    backgroundColor: Colors.transparent,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.transparent),
                  ),
                  viewHeaderHeight: 30,
                  viewHeaderStyle: ViewHeaderStyle(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    dateTextStyle: Theme.of(context).textTheme.bodyMedium,
                    dayTextStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 10),
                  ),
                  // Monthly View
                  monthViewSettings: MonthViewSettings(
                    appointmentDisplayCount: 3,
                    numberOfWeeksInView: 6,
                    showTrailingAndLeadingDates: false,
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.indicator,
                    showAgenda: true,
                    agendaViewHeight: MediaQuery.of(context).size.height * 0.35,
                    agendaItemHeight: MediaQuery.of(context).size.height * 0.15,
                    agendaStyle: AgendaStyle(
                      dateTextStyle: Theme.of(context).textTheme.bodyMedium,
                      dayTextStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 10),
                      appointmentTextStyle:
                          Theme.of(context).textTheme.bodyMedium,
                    ),
                    monthCellStyle: MonthCellStyle(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      trailingDatesTextStyle:
                          Theme.of(context).textTheme.bodySmall,
                      leadingDatesTextStyle:
                          Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  // Schedule View
                  scheduleViewSettings: ScheduleViewSettings(
                      hideEmptyScheduleWeek: true,
                      appointmentItemHeight:
                          MediaQuery.of(context).size.height * 0.15,
                      appointmentTextStyle:
                          Theme.of(context).textTheme.bodyMedium,
                      dayHeaderSettings: DayHeaderSettings(
                        dateTextStyle: Theme.of(context).textTheme.bodyMedium,
                        dayTextStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 10),
                      ),
                      weekHeaderSettings: WeekHeaderSettings(
                        startDateFormat: 'dd/MM',
                        endDateFormat: 'dd/MM/yyyy',
                        textAlign: TextAlign.start,
                        backgroundColor:
                            Theme.of(context).colorScheme.background,
                        weekTextStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                      monthHeaderSettings: MonthHeaderSettings(
                        monthFormat: 'MMMM yyyy',
                        height: 70,
                        textAlign: TextAlign.start,
                        backgroundColor:
                            Theme.of(context).colorScheme.background,
                        monthTextStyle:
                            Theme.of(context).textTheme.displayLarge,
                      )),
                  scheduleViewMonthHeaderBuilder: (BuildContext buildContext,
                      ScheduleViewMonthHeaderDetails details) {
                    return Container(
                      color: Theme.of(context).colorScheme.background,
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.03),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            StringUtils().toCapitalized(DateFormat(
                              'MMMM yyyy',
                              Localizations.localeOf(context).languageCode,
                            ).format(details.date)),
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: AppColors.grey),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    );
                  },
                  onViewChanged: (ViewChangedDetails viewChangedDetails) {
                    Future.delayed(Duration.zero, () async {
                      setState(() {
                        middleMonthDate = viewChangedDetails.visibleDates[
                            viewChangedDetails.visibleDates.length - 1];
                        displayDateTimeStart =
                            viewChangedDetails.visibleDates[0];
                        displayDateTimeEnd = viewChangedDetails.visibleDates[
                            viewChangedDetails.visibleDates.length - 1];
                      });
                    });
                  },
                  appointmentTextStyle: Theme.of(context).textTheme.bodyMedium!,
                  appointmentBuilder: (BuildContext context,
                      CalendarAppointmentDetails details) {
                    return _buildEventContainer(details);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppointmentDataSource _getCalendarDataSource() {
    List<Appointment> tempAllAppointments = [];
    for (var i = 0; i < eventsList.length; i++) {
      var event = eventsList[i];
      // Date Time
      var startDate = DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      var hour = event.duration.toString().split(".")[0];
      var min = event.duration!.toStringAsFixed(2).split(".")[1];
      var endDate = startDate
          .add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
      // Subject
      String subject;
      Color color = Colors.black;
      if (event.isPrivate!) {
        subject = "${event.numClients}";
        color = Colors.black;
      } else {
        subject = "${event.numClients}/${event.maxMembers}";
        // Colors
        double numClients = double.parse(event.numClients.toString());
        double maxMembers = double.parse(event.maxMembers.toString());
        double bookedCapacity = numClients / maxMembers;
        if (bookedCapacity <= 0.20) {
          color = Colors.green;
        } else if (bookedCapacity > 0.20 && bookedCapacity <= 0.40) {
          color = const Color(0xFFA8C76C);
        } else if (bookedCapacity > 0.40 && bookedCapacity <= 0.60) {
          color = const Color(0xFFECE014);
        } else if (bookedCapacity > 0.60 && bookedCapacity <= 0.80) {
          color = Colors.orangeAccent;
        } else if (bookedCapacity > 0.80 && bookedCapacity < 1) {
          color = Colors.deepOrangeAccent;
        } else if (bookedCapacity >= 1) {
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
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
