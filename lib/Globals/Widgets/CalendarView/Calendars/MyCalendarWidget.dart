import 'dart:developer';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DatabaseAccess.dart';
import 'package:mamba_castelldefels/Data/EventDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:page_transition/page_transition.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../Constants.dart';
import '../../../Styles.dart';
import '../Events/AddEvent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyCalendarWidget extends StatefulWidget {
  String brandID;
  MyCalendarWidget({Key? key, required this.brandID}) : super(key: key);

  @override
  _MyCalendarWidgetState createState() => _MyCalendarWidgetState();
}

class _MyCalendarWidgetState extends State<MyCalendarWidget> {
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  // Boolean Loading
  bool isLoading = false;
  // Boolean Loading
  Brand _brand = Brand();
  // Calendar Controller
  final CalendarController _controller = CalendarController();
  // Dies de la semana que el entrenador no treballa
  List<int> nonWorkDays = [];
  // Horari
  double? _startHour;
  double? _endHour;
  // Location of Event
  TextEditingController locationController = TextEditingController();
  // Descansos
  DateTime dateJoined = DateTime.now();
  // Events From Brand
  List<Event> eventsList = [];
  List<Appointment> allAppointments = <Appointment>[];
  // CalendarView
  bool asList = true;

  @override
  void initState() {
    isLoading = true;
    getBrandDetails();
    super.initState();
  }

  void getBrandDetails() async {
    _brand = await _brandDataService.getBrandDetails(widget.brandID);
    initCalendar();
  }

  void initCalendar() {
    dateJoined = DateFormat('dd-MM-yyyy').parse(_brand.dateJoined!);
    _startHour = double.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    _endHour = double.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Event getEvent(String eventId) {
    for (var i=0; i < eventsList.length; i++) {
      Event temp = eventsList[i];
      if (temp.id == eventId) return temp;
    }
    return Event();
  }

  durationToString(double duration) {
    String temp = "";
    temp = duration.toStringAsFixed(2);
    var hour = temp.split(".")[0];
    var min = temp.split(".")[1];
    return "${hour}h ${min}m ";
  }

  // Return bade on events Today
  Widget returnBadge(Event event) {
    int label = 0;
    DateTime now = DateTime.now();
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
    if (startDate.isBefore(now) && endDate.isBefore(now)) {
      // Done
      label = 2;
    }
    if (startDate.isBefore(now) && endDate.isAfter(now)) {
      // Doing
      label = 1;
    }
    if (startDate.isAfter(now) && endDate.isAfter(now)) {
      // To Do
      label = 0;
    }
    switch (label) {
      default:
        return Material(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              const Radius.circular(5.0),
            ),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height*0.015,
            width: MediaQuery.of(context).size.width*0.05,
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(5)
            ),
            child: Icon(
              Icons.done_outline_outlined,
              color: Colors.white,
              size: 10,
            ),
          ),
        );
    }
  }

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.mySessions, style: Theme.of(context).appBarTheme.titleTextStyle,),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 25,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: LoadingViewPurple(),
      )
        :
      Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.mySessions, style: Theme.of(context).appBarTheme.titleTextStyle,),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 25,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: Icon(!asList ? Icons.list : Icons.calendar_today_outlined , size: 25,),
                onPressed: () {
                  if (!asList) {
                    _controller.view = CalendarView.schedule;
                  } else {
                    _controller.view = CalendarView.week;
                  }
                  setState(() {
                    asList = !asList;
                  });
                },
              ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
              stream: _eventDataService.getUserEventsStream(currentUser.id!),
              builder: (context, snapshot) {
                if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                  return LoadingViewPurple();
                } else {
                  eventsList = documentsToEvents(snapshot.data!.docs);
                  return SfCalendar(
                      cellEndPadding: 0,
                      view: CalendarView.schedule,
                      controller: _controller,
                      showDatePickerButton: true,
                      dataSource: _getCalendarDataSource(),
                      specialRegions: _getTimeRegions(),
                      timeRegionBuilder: timeRegionBuilder,
                      firstDayOfWeek: 1,
                      todayHighlightColor: Theme.of(context).accentColor,
                      showCurrentTimeIndicator: true,
                      selectionDecoration: BoxDecoration(
                          border: Border.all(width: 0.1, color: Colors.transparent)
                      ),
                    headerHeight: MediaQuery.of(context).size.height*0.05,
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
                      viewHeaderHeight: 50,
                      viewHeaderStyle: ViewHeaderStyle(
                        backgroundColor: Theme.of(context).backgroundColor,
                        dateTextStyle: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                        dayTextStyle: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
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
                      scheduleViewSettings: ScheduleViewSettings(
                          hideEmptyScheduleWeek: true,
                          appointmentItemHeight: -1,
                          monthHeaderSettings: MonthHeaderSettings(
                            height: MediaQuery.of(context).size.height*0.05,
                          ),
                          weekHeaderSettings: WeekHeaderSettings(
                              startDateFormat: 'dd/MM',
                              endDateFormat: 'dd/MM/yy',
                              height: MediaQuery.of(context).size.height*0.03,
                              textAlign: TextAlign.start,
                              weekTextStyle: Styles.purpleTextStyle.copyWith(color: Colors.grey)
                          ),
                      ),
                      scheduleViewMonthHeaderBuilder: (BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
                        return Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  toCapitalized(DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode,).format(details.date)),
                                  style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                        final Appointment appointment = details.appointments.first;
                        final DateTime today = DateTime.now();
                        bool isCompleted = appointment.endTime.isBefore(today);
                        final Event event = getEvent(appointment.id.toString());
                        if (_controller.view == CalendarView.schedule) {
                          if (isCompleted) {
                            return GestureDetector(
                              onTap: () {
                                _viewEvent(appointment.id.toString(), appointment.startTime);
                              },
                              child: Material(
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.all(
                                    const Radius.circular(5.0),
                                  ),
                                ),
                                elevation: 2,
                                child: Container(
                                  width: details.bounds.width,
                                  height: details.bounds.height,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    border: Border.all(width: 1, color: Colors.black),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: MediaQuery.of(context).size.height*0.006,),
                                        Row(
                                          children: [
                                            Flexible(
                                                child: Text(event.title!,
                                                  textAlign: TextAlign.start,
                                                  style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 14),)
                                            ),
                                            /*
                                            SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                            returnBadge(event),
                                             */
                                          ],
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height*0.006,),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.schedule,
                                                  color: Colors.black,
                                                  size: 15,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                Text(
                                                  event.hour.toString(),
                                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                                ),
                                                Text(
                                                  ":",
                                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                                ),
                                                Text(
                                                  event.minute=="0" ? "00" : event.minute.toString(),
                                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                                ),
                                                Container(
                                                    height: 8,
                                                    width: 32,
                                                    child: VerticalDivider(color: Colors.black, width: 10, thickness: 1,)
                                                ),
                                                Icon(
                                                  Icons.timer,
                                                  color: Colors.black,
                                                  size: 15,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                Text(
                                                  durationToString(event.duration!),
                                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                                ),
                                                Container(
                                                    height: 8,
                                                    width: 32,
                                                    child: VerticalDivider(color: Colors.black, width: 10, thickness: 1,)
                                                ),
                                                Icon(
                                                  Icons.record_voice_over,
                                                  color: Colors.black,
                                                  size: 15,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                Text(
                                                  event.numTrainers.toString(),
                                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                                ),
                                                Container(
                                                    height: 8,
                                                    width: 32,
                                                    child: VerticalDivider(color: Colors.black, width: 10, thickness: 1,)
                                                ),
                                                Icon(
                                                  Icons.directions_run,
                                                  color: Colors.black,
                                                  size: 15,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                Text(
                                                  event.numClients.toString(),
                                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: MediaQuery.of(context).size.height*0.003,),
                                          ],
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
                                _viewEvent(appointment.id.toString(), appointment.startTime);
                              },
                              child: Material(
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.all(
                                    const Radius.circular(5.0),
                                  ),
                                ),
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
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: MediaQuery.of(context).size.height*0.006,),
                                        Row(
                                          children: [
                                            Flexible(
                                                child: Text(event.title!,
                                                  textAlign: TextAlign.start,
                                                  style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 14),)
                                            ),
                                            /*
                                            SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                            returnBadge(event),
                                             */
                                          ],
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height*0.006,),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.schedule,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                Text(
                                                  event.hour.toString(),
                                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                                Text(
                                                  ":",
                                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                                Text(
                                                  event.minute=="0" ? "00" : event.minute.toString(),
                                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                                Container(
                                                    height: 8,
                                                    width: 32,
                                                    child: VerticalDivider(color: Colors.white, width: 10, thickness: 1,)
                                                ),
                                                Icon(
                                                  Icons.timer,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                Text(
                                                  durationToString(event.duration!),
                                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                                Container(
                                                    height: 8,
                                                    width: 32,
                                                    child: VerticalDivider(color: Colors.white, width: 10, thickness: 1,)
                                                ),
                                                Icon(
                                                  Icons.record_voice_over,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                Text(
                                                  event.numTrainers.toString(),
                                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                                Container(
                                                    height: 8,
                                                    width: 32,
                                                    child: VerticalDivider(color: Colors.white, width: 10, thickness: 1,)
                                                ),
                                                Icon(
                                                  Icons.directions_run,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                Text(
                                                  event.numClients.toString(),
                                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: MediaQuery.of(context).size.height*0.003,),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        } else {
                          if (isCompleted) {
                            return GestureDetector(
                              onTap: () {
                                _viewEvent(appointment.id.toString(), appointment.startTime);
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
                                    width: details.bounds.width,
                                    height: details.bounds.height,
                                    padding: EdgeInsets.all(details.bounds.width*0.1),
                                    decoration: BoxDecoration(
                                      color: Styles.lightGrey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        AutoSizeText(
                                          event.title!,
                                          style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.w800),
                                          textAlign: TextAlign.center,
                                          wrapWords: false,
                                          minFontSize: 1,
                                          maxFontSize: 16,
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
                                _viewEvent(appointment.id.toString(), appointment.startTime);
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
                                    width: details.bounds.width,
                                    height: details.bounds.height,
                                    padding: EdgeInsets.all(details.bounds.width*0.1),
                                    decoration: BoxDecoration(
                                      color: appointment.color,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        AutoSizeText(
                                          event.title!,
                                          style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.w800),
                                          textAlign: TextAlign.center,
                                          wrapWords: false,
                                          minFontSize: 1,
                                          maxFontSize: 16,
                                        ),
                                        SizedBox(
                                          width: details.bounds.width*0.4,
                                          child: AutoSizeText(
                                            appointment.subject,
                                            style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.w500),
                                            textAlign: TextAlign.center,
                                            wrapWords: false,
                                            minFontSize: 1,
                                            maxFontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      },
                    );
                }
              }
          ), // This trailing comma makes auto-formatting nicer for build methods.
      );
  }

  List<TimeRegion> _getTimeRegions() {
    final List<TimeRegion> regions = <TimeRegion>[];
    // Breaks
    for (var i=2; i < _brand.workShift.length ; i+=2) {
      var start = _brand.workShift[i];
      var startHour = int.parse(start.toStringAsFixed(2).split(".")[0]);
      var startMin = int.parse(start.toStringAsFixed(2).split(".")[1]);
      var end = _brand.workShift[i+1];
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
    var startHourWS = int.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    var startMinWS = int.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[1]);
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, startHourWS-1, 0, 0),
      endTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, startHourWS, startMinWS, 0),
      color: Colors.grey.withOpacity(0.3),
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
    ));
    // Hora Inactiva Nit
    var endHourWS = int.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);
    var endMinWS = int.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[1]);
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, endHourWS, endMinWS, 0),
      endTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day-7, endHourWS+1, 0, 0),
      color: Colors.grey.withOpacity(0.3),
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
    ));
    return regions;
  }

  Widget timeRegionBuilder(BuildContext context, TimeRegionDetails timeRegionDetails) {
    return Container(
      color: Color(0x40B5B5B5),
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

  List<Event> documentsToEvents(List<DocumentSnapshot> documents) {
    List<Event> events = [];
    for(int i = 0; i < documents.length; i++) {
      events.add(Event.fromObjectOnlyCoverData(documents[i].id, documents[i]));
    }
    return events;
  }

  void _viewEvent(String eventId, DateTime startDate) {
      bool canAction = true;
      if (startDate.isBefore(DateTime.now())) {
        canAction = false;
      }
      if (currentUser.isTrainer!) {
        Navigator.push(
            context,
            CupertinoPageRoute<Null>(
                                  builder: (context) => ViewEventTrainer(
                  eventId: eventId,
                  canEdit: canAction,
                  locale: Localizations.localeOf(context),
                )
            )
        );
      } else {
        Navigator.push(
            context,
            CupertinoPageRoute<Null>(
                                  builder: (context) => ViewEventClient(
                  eventId: eventId,
                  canJoin: canAction,
                  locale: Localizations.localeOf(context),
                )
            )
        );
      }
  }

}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
