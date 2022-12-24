// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/BrandEventCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserCalendarWidget extends StatefulWidget {

  const UserCalendarWidget({Key? key}) : super(key: key);

  @override
  _UserCalendarWidgetState createState() => _UserCalendarWidgetState();
}

class _UserCalendarWidgetState extends State<UserCalendarWidget> {
  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
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
    mixpanel!.track('user_calendar_view');
    // Init Calendar
    dateJoined = DateFormat('dd-MM-yyyy').parse(currentUser.dateJoined!);
    DateTime now = DateTime.now();
    int currentDay = now.weekday;
    displayDateTimeStart = now.subtract(Duration(days: currentDay-1));
    displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));
    // Calendar View
      _controller.view = CalendarView.month;
      selectedValue = '0';
    // Show Date
    _controller.selectedDate = DateTime.now();
    _controller.displayDate = DateTime.now().subtract(const Duration(hours: 1));
    super.initState();
  }

  Event getEvent(String eventId) {
    for (var i=0; i < eventsList.length; i++) {
      Event temp = eventsList[i];
      if (temp.id == eventId) return temp;
    }
    return Event();
  }

  Widget _buildTitleFromDate(DateTime dateTimeStart, DateTime dateTimeEnd, DateTime middleMonthDate) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              _controller.backward!();
            },
            icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.04,),
            alignment: Alignment.centerLeft,
          ),
          Text(
            StringUtils().toCapitalized(DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode,).format(middleMonthDate)),
            style: Theme.of(context).textTheme.bodyText1,
          ),
          IconButton(
            onPressed: () {
              _controller.forward!();
            },
            icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.04,),
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
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
        isMyEvent: true,
        showEmoji: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Container(
          color: Theme.of(context).backgroundColor,
          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06),
          child: DropdownButton2(
            dropdownWidth: MediaQuery.of(context).size.width*0.5,
            dropdownDecoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            // Initial Value
            value: selectedValue,
            style: Theme.of(context).textTheme.headline1,
            underline: Container(color: Colors.transparent),
            isExpanded: false,
            dropdownElevation: 4,
            offset: const Offset(0, 0),
            // Down Arrow Icon
            icon: FaIcon(
                FontAwesomeIcons.chevronDown,
                size: MediaQuery.of(context).size.width*0.03,
                color: Colors.transparent
            ),
            // Array list of items
            selectedItemBuilder: (BuildContext context) {
              return items.map((String item) {
                return Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      Text(
                        item == '0' ? AppLocalizations.of(context)!.calendar+" " : AppLocalizations.of(context)!.schedule+" ",
                        style: Theme.of(context).textTheme.headline1?.copyWith(fontSize: 25),
                      ),
                      FaIcon(
                          FontAwesomeIcons.chevronDown,
                          size: MediaQuery.of(context).size.width*0.03,
                          color: Theme.of(context).primaryColor
                      ),
                    ],
                  ),
                );
              }).toList();
            },
            items: [
              DropdownMenuItem(
                  value: '0',
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width*0.5,
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      minLeadingWidth: MediaQuery.of(context).size.width * 0.05,
                      leading: FaIcon(
                          FontAwesomeIcons.calendarDays,
                          size: MediaQuery.of(context).size.width*0.04,
                          color: Theme.of(context).primaryColor
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.calendar,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      trailing: FaIcon(
                        FontAwesomeIcons.check,
                        size: MediaQuery.of(context).size.width*0.04,
                        color: selectedValue == '0' ? Theme.of(context).primaryColor : Colors.transparent,
                      ),
                    ),
                  )
              ),
              const DropdownMenuItem<Divider>(enabled: false, child:
              Divider(color: AppColors.grey, height: 2),
              ),
              DropdownMenuItem(
                  value: '1',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    minLeadingWidth: MediaQuery.of(context).size.width * 0.05,
                    leading: FaIcon(
                        FontAwesomeIcons.list,
                        size: MediaQuery.of(context).size.width*0.04,
                        color: Theme.of(context).primaryColor
                    ),
                    title: Text(
                      "Agenda",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    trailing: FaIcon(
                      FontAwesomeIcons.check,
                      size: MediaQuery.of(context).size.width*0.04,
                      color: selectedValue == '1' ? Theme.of(context).primaryColor : Colors.transparent,
                    ),
                  )
              ),
            ],
            customItemsHeights: [
              MediaQuery.of(context).size.height*0.06,
              8,
              MediaQuery.of(context).size.height*0.06,
            ],
            // After selecting the desired option,it will
            // change button value to selected value
            onChanged: (newValue) {
              if (newValue == '0') {
                _controller.view = CalendarView.month;
                //_userDataService.updateUserCalendarView(currentUser.id!, true);
                //currentUser.setCalendarView = true;
              } else if (newValue == '1') {
                _controller.view = CalendarView.schedule;
                //_userDataService.updateUserCalendarView(currentUser.id!, false);
                //currentUser.setCalendarView = false;
              }
              setState(() {
                selectedValue = newValue.toString();
              });
            },
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        titleSpacing: 0,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width*0.15,
            child: TextButton(
              onPressed: () {
                mixpanel!.track('user_calendar_today');
                setState(() {
                  _controller.displayDate = DateTime.now().subtract(const Duration(hours: 1));
                  _controller.selectedDate = DateTime.now();
                });
              },
              child: Text(
                  AppLocalizations.of(context)!.todayString,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width*0.03)
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
          stream: _eventDataService.getUserEventsStream(currentUser.id!),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return LoadingView(
                isSmall: true,
                hasLogo: false,
              );
            } else {
              eventsList = documentsToEvents(snapshot.data!.docs);
              return Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.03, left: MediaQuery.of(context).size.width*0.02),
                child: Column(
                  children: [
                    _controller.view == CalendarView.month ? _buildTitleFromDate(displayDateTimeStart, displayDateTimeEnd, middleMonthDate) : Container(),
                    Expanded(
                      child: SfCalendarTheme(
                        data: SfCalendarThemeData(
                          brightness: Brightness.dark,
                          backgroundColor: Theme.of(context).backgroundColor,
                          todayHighlightColor: Theme.of(context).primaryColor,
                          todayBackgroundColor: Theme.of(context).backgroundColor,
                        ),
                        child: SfCalendar(
                          // Controller
                          controller: _controller,
                          view: CalendarView.month,
                          blackoutDates: [dateJoined.subtract(const Duration(days: 1))],
                          blackoutDatesTextStyle: Theme.of(context).textTheme.headline3?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
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
                            backgroundColor: Theme.of(context).backgroundColor,
                            dateTextStyle: Theme.of(context).textTheme.bodyText2,
                            dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                          ),
                          // Monthly View
                          monthViewSettings: MonthViewSettings(
                            appointmentDisplayCount: 3,
                            numberOfWeeksInView: 6,
                            showTrailingAndLeadingDates: false,
                            appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                            showAgenda: true,
                            agendaViewHeight: MediaQuery.of(context).size.height*0.35,
                            agendaItemHeight: MediaQuery.of(context).size.height*0.15,
                            agendaStyle: AgendaStyle(
                              dateTextStyle: Theme.of(context).textTheme.bodyText2,
                              dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                              appointmentTextStyle: Theme.of(context).textTheme.bodyText2,
                            ),
                            monthCellStyle: MonthCellStyle(
                              textStyle: Theme.of(context).textTheme.bodyText1,
                              trailingDatesTextStyle: Theme.of(context).textTheme.caption,
                              leadingDatesTextStyle: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          // Schedule View
                          scheduleViewSettings: ScheduleViewSettings(
                              hideEmptyScheduleWeek: true,
                              appointmentItemHeight: MediaQuery.of(context).size.height*0.15,
                              appointmentTextStyle: Theme.of(context).textTheme.bodyText2,
                              dayHeaderSettings: DayHeaderSettings(
                                dateTextStyle: Theme.of(context).textTheme.bodyText2,
                                dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                              ),
                              weekHeaderSettings: WeekHeaderSettings(
                                startDateFormat: 'dd/MM',
                                endDateFormat: 'dd/MM/yyyy',
                                textAlign: TextAlign.start,
                                backgroundColor: Theme.of(context).backgroundColor,
                                weekTextStyle: Theme.of(context).textTheme.caption,
                              ),
                              monthHeaderSettings: MonthHeaderSettings(
                                monthFormat: 'MMMM yyyy',
                                height: 70,
                                textAlign: TextAlign.start,
                                backgroundColor: Theme.of(context).backgroundColor,
                                monthTextStyle: Theme.of(context).textTheme.headline1,
                              )
                          ),
                          scheduleViewMonthHeaderBuilder: (BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
                            return Container(
                              color: Theme.of(context).backgroundColor,
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    StringUtils().toCapitalized(DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode,).format(details.date)),
                                    style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.normal, color: AppColors.grey),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            );
                          },
                          onViewChanged: (ViewChangedDetails viewChangedDetails) {
                            Future.delayed(Duration.zero, () async {
                              setState(() {
                                middleMonthDate = viewChangedDetails.visibleDates[viewChangedDetails.visibleDates.length -1];
                                displayDateTimeStart = viewChangedDetails.visibleDates[0];
                                displayDateTimeEnd = viewChangedDetails.visibleDates[viewChangedDetails.visibleDates.length -1];
                              });
                            });
                          },
                          onTap: onTapCalendar,
                          appointmentTextStyle: Theme.of(context).textTheme.bodyText2!,
                          appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                            return _buildEventContainer(details);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
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
          color = const Color(0xFFECE014);
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

  List<Event> documentsToEvents(List<DocumentSnapshot> documents) {
    List<Event> events = [];
    for(int i = 0; i < documents.length; i++) {
      events.add(Event.fromObjectOnlyCoverData(documents[i].id, documents[i]));
    }
    return events;
  }

  void navigateToEventScreen(String eventId, bool isCompleted) {
    mixpanel!.track('user_calendar_event_view', properties: {'Calendar View': _controller.view.toString(), 'isCompleted': isCompleted});
    // Navigate to Event Screen
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => EventPage(
            eventId: eventId,
          ),
        )
    );
  }

  void onTapCalendar(CalendarTapDetails details) {
    if (_controller.view == CalendarView.week) {

    } else {
      setState(() {
        _controller.selectedDate = details.date;
      });
    }
  }

}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
