import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/AddEditEventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../Events/AddEvent.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarWidgetTrainer extends StatefulWidget {
  String brandID;
  bool canEdit;
  CalendarWidgetTrainer({Key? key, required this.brandID, required this.canEdit }) : super(key: key);

  @override
  _CalendarWidgetTrainerState createState() => _CalendarWidgetTrainerState();
}

class _CalendarWidgetTrainerState extends State<CalendarWidgetTrainer> {
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  // Boolean Loading
  Brand _brand = Brand();
  // Sesions Controller
  final CalendarController _controller = CalendarController();
  // Dies de la semana que el entrenador no treballa
  List<int> nonWorkDays = [];
  // Horari
  double? _startHour;
  double? _endHour;
  // Descansos
  DateTime dateJoined = DateTime.now();
  // Events From Brand
  List<Event> eventsList = [];
  List<Appointment> allAppointments = <Appointment>[];

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
            title: Text(AppLocalizations.of(context)!.calendar, style: Theme.of(context).appBarTheme.titleTextStyle,),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
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
            title: Text(AppLocalizations.of(context)!.calendar, style: Theme.of(context).appBarTheme.titleTextStyle,),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
            child: StreamBuilder<QuerySnapshot>(
                stream: _brandDataService.getAllEventsFromBrand(_brand.id!),
                builder: (context, snapshot) {
                  if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                    return LoadingViewPurple();
                  } else {
                    eventsList = documentsToEvents(snapshot.data!.docs);
                    return SfCalendar(
                      cellEndPadding: 0,
                      view: CalendarView.week,
                      controller: _controller,
                      showDatePickerButton: true,
                      headerDateFormat: null,
                      dataSource: _getCalendarDataSource(),
                      specialRegions: _getTimeRegions(),
                      timeRegionBuilder: timeRegionBuilder,
                      firstDayOfWeek: 1,
                      todayHighlightColor: Theme.of(context).accentColor,
                      showCurrentTimeIndicator: true,
                      viewHeaderHeight: 50,
                      viewHeaderStyle: ViewHeaderStyle(
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        dateTextStyle: Theme.of(context).textTheme.bodyText2,
                        dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 8),
                      ),
                      selectionDecoration: BoxDecoration(
                          border: Border.all(width: 0.1, color: Colors.transparent)
                      ),
                      timeSlotViewSettings: TimeSlotViewSettings(
                          timelineAppointmentHeight: -1,
                          timeIntervalHeight: -1,
                          timeIntervalWidth: 55,
                          startHour: _startHour!-1,
                          endHour:  _endHour!+1,
                          timeFormat: 'HH',
                          dayFormat: 'E',
                          dateFormat: 'd',
                          timeRulerSize: 25,
                          nonWorkingDays: nonWorkDays,
                          minimumAppointmentDuration: Duration(minutes: 30),
                          timeTextStyle: Theme.of(context).textTheme.bodyText2,
                      ),
                      headerHeight: MediaQuery.of(context).size.height*0.05,
                      headerStyle: CalendarHeaderStyle(
                        textAlign: TextAlign.justify,
                        backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
                        textStyle: Theme.of(context).textTheme.bodyText1,
                      ),
                      onLongPress: (details) {
                        if (widget.canEdit) {
                          if(details.date!.isAfter(DateTime.now())) {
                            _addEvent(dateTimeClicked: details.date);
                          }
                        }
                      },
                      onTap: (details) {
                        // Just for Development
                        log(details.date.toString());
                      },
                      appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                        final Appointment appointment = details.appointments.first;
                        final DateTime today = DateTime.now();
                        final Event event = getEvent(appointment.id.toString());
                        bool isCompleted = appointment.endTime.isBefore(today);
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
                                    color: AppColors.lightGrey,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AutoSizeText(
                                        event.title!,
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black),
                                        textAlign: TextAlign.center,
                                        wrapWords: false,
                                        minFontSize: 1,
                                        maxFontSize: 14,
                                      ),
                                      /*
                                      event.selectedTrainers.contains(currentUser.id!) ? Column(
                                        children: [
                                          SizedBox(height: details.bounds.height*0.1),
                                          CircularImage(
                                          size: details.bounds.width*0.25,
                                          image: currentUser.imageUrl!,
                                          color: Theme.of(context).accentColor,
                                          ),
                                        ],
                                      ) : Container(),
                                       */
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
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                                        textAlign: TextAlign.center,
                                        wrapWords: false,
                                        minFontSize: 1,
                                        maxFontSize: 14,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          /*
                                          event.selectedTrainers.contains(currentUser.id!) ? Row(
                                            children: [
                                              CircularImage(
                                                size: details.bounds.width*0.25,
                                                image: currentUser.imageUrl!,
                                                color: Theme.of(context).accentColor,
                                              ),
                                              SizedBox(width: details.bounds.width*0.1,)
                                            ],
                                          ) : Container(),
                                           */
                                          SizedBox(
                                            width: details.bounds.width*0.4,
                                            child: AutoSizeText(
                                              appointment.subject,
                                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                                              textAlign: TextAlign.center,
                                              wrapWords: false,
                                              minFontSize: 1,
                                              maxFontSize: 8,
                                            ),
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
                    );
                  }
                }
            ),
          ),
          floatingActionButton: widget.canEdit ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: MediaQuery.of(context).size.width*0.17,
                width: MediaQuery.of(context).size.width*0.17,
                child: FloatingActionButton(
                  heroTag: "3",
                  onPressed: () {
                    _addEvent();
                  },
                  backgroundColor: Theme.of(context).accentColor,
                  child: Icon(
                    Icons.more_time,
                    size: MediaQuery.of(context).size.width*0.07,
                    color: AppColors.white,
                  ),
                ),
              ),
            ) : Container(), // This trailing comma makes auto-formatting nicer for build methods.
      );
  }

  Event getEvent(String eventId) {
    for (var i=0; i < eventsList.length; i++) {
      Event temp = eventsList[i];
      if (temp.id == eventId) return temp;
    }
    return Event();
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

  void _addEvent({DateTime? dateTimeClicked}) {
    Navigator.push(
        context,
        CupertinoPageRoute<String>(
          builder: (context) => AddEvent(
            locale: Localizations.localeOf(context),
            initialDateTime: dateTimeClicked ?? null,
          ),
        )
    );
  }

  void _viewEvent(String eventId, DateTime startDate) {
      bool canEdit = true;
      if (startDate.isBefore(DateTime.now())) {
        canEdit = false;
      }
      Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => ViewEventTrainer(
              eventId: eventId,
              canEdit: canEdit,
              locale: Localizations.localeOf(context),
            ),
        )
      );
  }

}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
