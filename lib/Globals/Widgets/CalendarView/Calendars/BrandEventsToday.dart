import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';

import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class BrandEventsToday extends StatefulWidget {
  String brandId;
  BrandEventsToday({Key? key, required this.brandId}) : super(key: key);

  @override
  _BrandEventsTodayState createState() => _BrandEventsTodayState();
}

class _BrandEventsTodayState extends State<BrandEventsToday> {

  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  // Boolean Loading
  bool isLoading = false;
  // Brand Object
  Brand _brand = Brand();
  // Calendar Controller
  final CalendarController _controller = CalendarController();
  // Dies de la semana que el entrenador no treballa
  List<int> nonWorkDays = [];
  // Horari
  double? _startHour;
  double? _endHour;
  // Descansos
  DateTime dateJoined = DateTime.now();
  // Brand Events Today
  List<Event> todayEvents = [];
  // Events From Brand
  List<Appointment> allAppointments = <Appointment>[];

  @override
  void initState() {
    isLoading = true;
    getBrandDetails();
    super.initState();
  }

  void getBrandDetails() async {
    _brand = await _brandDataService.getBrandDetails(widget.brandId);
    initListEvents();
  }

  Future<void> initListEvents() async {
    _startHour = double.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    _endHour = double.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';

  durationToString(double duration) {
    String temp = "";
    temp = duration.toStringAsFixed(2);
    var hour = temp.split(".")[0];
    var min = temp.split(".")[1];
    return "${hour}h ${min}m ";
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    Scaffold(
      appBar: AppBar(
        //elevation: 0,
        title: Text(AppLocalizations.of(context)!.today(toCapitalized(DateFormat('EEEE d/M/yy', Localizations.localeOf(context).languageCode).format(DateTime.now()))), style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
        centerTitle: true,
      ),
      body: LoadingViewPurple(),
    )
        :
    Scaffold(
      appBar: AppBar(
        //elevation: 0,
        title: Text(AppLocalizations.of(context)!.today(toCapitalized(DateFormat('EEEE d/M/yy', Localizations.localeOf(context).languageCode).format(DateTime.now()))), style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _eventDataService.getBrandsEventsTodayStream(_brand.id!),
          builder: (context, snapshot) {
            if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
              return LoadingViewPurple();
            } else {
              todayEvents = documentsToEvents(snapshot.data!.docs);
              return SfCalendar(
                view: CalendarView.day,
                minDate: DateTime(dateJoined.year, dateJoined.month, dateJoined.day, _startHour!.toInt()-1,0),
                maxDate: DateTime(dateJoined.year, dateJoined.month, dateJoined.day, _endHour!.toInt()+1,0),
                headerHeight: 0,
                viewHeaderHeight: 0,
                dataSource: _getCalendarDataSource(),
                specialRegions: _getTimeRegions(),
                todayHighlightColor: Theme.of(context).accentColor,
                selectionDecoration: BoxDecoration(
                    border: Border.all(width: 0.1, color: Colors.transparent)
                ),
                timeSlotViewSettings: TimeSlotViewSettings(
                    timeIntervalHeight: MediaQuery.of(context).size.height*0.07,
                    timeIntervalWidth: 60,
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
                appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                  final Appointment appointment = details.appointments.first;
                  final Event event = getEvent(appointment.id.toString());
                  return GestureDetector(
                    onTap: () {
                      _viewEvent(appointment.id.toString(), appointment.startTime);
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
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(child: Text(event.title!, textAlign: TextAlign.center, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),)),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                  Text(
                                    "-",
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                  Icon(
                                    Icons.record_voice_over,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                  Text(
                                    event.numTrainers.toString(),
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  Container(
                                      height: 16,
                                      width: 32,
                                      child: VerticalDivider(color: Colors.white, width: 10, thickness: 2,)
                                  ),
                                  Icon(
                                    Icons.directions_run,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                  Text(
                                    event.numClients.toString(),
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  Text(
                                    " / ",
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  Text(
                                    event.maxMembers.toString(),
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }

  List<Event> documentsToEvents(List<DocumentSnapshot> documents) {
    List<Event> events = [];
    for(int i = 0; i < documents.length; i++) {
      events.add(Event.fromObjectOnlyCoverData(documents[i].id, documents[i]));
    }
    return events;
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
    for (var i=0; i < todayEvents.length; i++) {
      var event = todayEvents[i];
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

  Event getEvent(String eventId) {
    for (var i=0; i < todayEvents.length; i++) {
      Event temp = todayEvents[i];
      if (temp.id == eventId) return temp;
    }
    return Event();
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
