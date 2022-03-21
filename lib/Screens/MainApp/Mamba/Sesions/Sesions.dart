import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline1.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline3.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Sesions extends StatefulWidget {
  Sesions({Key? key}) : super(key: key);

  @override
  _SesionsState createState() => _SesionsState();
}

class _SesionsState extends State<Sesions> {
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  // Boolean Loading
  Brand _brand = Brand();
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

  final CalendarController _calendarController = CalendarController();
  DateTime middleMonthDate = DateTime.now();

  // Event List
  String month = "";
  List<Event> listEvents = [];

  @override
  void initState() {
    isLoading = true;
    getBrandDetails();
    super.initState();
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  void getBrandDetails() async {
    _brand = await _brandDataService.getBrandDetails(currentBrand.id!);
    getEventsDone();
    initCalendar();
  }

  // Gets the events passed by the trainer.
  void getEventsDone() async {
    DateTime today = DateTime.now();
    var tempMonth = 0;
    List<Event> list = await _eventDataService.getUserEvents(currentUser.id!);
    for (var i=0; i<list.length; i++) {
      Event event = list[i];
      var startDate =  DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      if (startDate.isBefore(today)) {
        listEvents.add(event);
        if (startDate.year == today.year && startDate.month == today.month) {
          tempMonth += 1;
        }
      }
    }
    listEvents.sort((a,b) {
      var aDate =  DateTime(
        int.parse(a.year!),
        int.parse(a.month!),
        int.parse(a.day!),
        int.parse(a.hour!),
        int.parse(a.minute!),
      );
      var bDate =  DateTime(
        int.parse(b.year!),
        int.parse(b.month!),
        int.parse(b.day!),
        int.parse(b.hour!),
        int.parse(b.minute!),
      );
      return aDate.compareTo(bDate);
    });
    listEvents = List.from(listEvents.reversed);
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

  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }
    return isLoading ?
    Center(
        child: LoadingViewPurple()
    )
        :
    Scaffold (
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: SafeArea(
        right: false,
        left: false,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    height: safeAreaHeight*0.1,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TitleHeadline1(text: "Mi Calendario"),
                      ],
                    ),
                  ),
                  Container(
                    height: safeAreaHeight*0.4,
                    width: safeAreaWidth*0.9,
                    decoration: new BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: AppColors.grey,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: new BorderRadius.vertical(
                        top: Radius.circular(15.0),
                        bottom: Radius.circular(10.0),
                      ),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _eventDataService.getUserEventsStream(currentUser.id!),
                        builder: (context, snapshot) {
                          if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                            return LoadingViewPurple();
                          } else {
                            eventsList = documentsToEvents(snapshot.data!.docs);
                            return Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                SfCalendar(
                                  view: CalendarView.month,
                                  controller: _calendarController,
                                  dataSource: _getCalendarDataSource(),
                                  firstDayOfWeek: 1,
                                  showDatePickerButton: false,
                                  showCurrentTimeIndicator: false,
                                  showNavigationArrow: true,
                                  todayHighlightColor: Theme.of(context).accentColor,
                                  headerHeight: safeAreaHeight*0.07,
                                  headerDateFormat: "MMMM yyyy",
                                  headerStyle: CalendarHeaderStyle(
                                    textAlign: TextAlign.center,
                                    backgroundColor: Colors.transparent,
                                    textStyle: Theme.of(context).textTheme.bodyText1,
                                  ),
                                  monthViewSettings: MonthViewSettings(navigationDirection: MonthNavigationDirection.horizontal),
                                  onViewChanged: (ViewChangedDetails viewChangedDetails) {
                                    Future.delayed(Duration.zero, () async {
                                      setState(() {
                                        middleMonthDate = viewChangedDetails.visibleDates[14];
                                      });
                                    });
                                  },
                                ),
                                Container(
                                  height: safeAreaHeight*0.06,
                                  width: safeAreaWidth*0.9,
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: new BorderRadius.vertical(
                                      top: Radius.circular(10.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).primaryColorDark, size: safeAreaHeight*0.03,),
                                        alignment: Alignment.center,
                                        onPressed: () {
                                          _calendarController.backward!();
                                        },
                                      ),
                                      Text(
                                        toCapitalized(DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode,).format(middleMonthDate)),
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).primaryColorDark),
                                        textAlign: TextAlign.start,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColorDark, size: safeAreaHeight*0.03,),
                                        alignment: Alignment.center,
                                        onPressed: () {
                                          _calendarController.forward!();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                    ),
                  ),
                ],
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      height: safeAreaHeight*0.1,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TitleHeadline1(text: "Sesiones"),
                        ],
                      ),
                    ),
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: listEvents.length,
                        itemBuilder: (context,int index) {
                          Event event = listEvents[index];
                          bool addLabel = false;
                          var startDate =  DateTime(
                            int.parse(event.year!),
                            int.parse(event.month!),
                            int.parse(event.day!),
                            int.parse(event.hour!),
                            int.parse(event.minute!),
                          );
                          String day = DateFormat('EEEE', Localizations.localeOf(context).languageCode).format(startDate);
                          String _month = DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode).format(startDate);
                          if (_month != month) {
                            month = _month;
                            addLabel = true;
                          }
                          return Column(
                            children: [
                              addLabel ? Container(
                                padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          Localizations.localeOf(context).languageCode == 'ca' ? month.substring(3).toUpperCase() : month.toUpperCase(),
                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).accentColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ) : Container(),
                              ListTile(
                                onTap: () {
                                  if (currentUser.isTrainer!) {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute<Null>(
                                            builder: (context) => ViewEventTrainer(
                                              eventId: event.id!,
                                              canEdit: false,
                                              locale: Localizations.localeOf(context),
                                            )
                                        )
                                    );
                                  } else {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute<Null>(
                                            builder: (context) => ViewEventClient(
                                              eventId: event.id!,
                                              canJoin: false,
                                              locale: Localizations.localeOf(context),
                                            )
                                        )
                                    );
                                  }
                                },
                                leading: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      toCapitalized(day),
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ),
                                    Text(
                                      "${event.day}/${event.month}/${event.year!.substring(2, 4)}",
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                                minLeadingWidth: MediaQuery.of(context).size.width*0.15,
                                title: Text(
                                  event.title!,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                subtitle: Column(
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          color: Theme.of(context).primaryColor,
                                          size: 15,
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                        Text(
                                          event.hour.toString(),
                                          style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                                        ),
                                        Text(
                                          ":",
                                          style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                                        ),
                                        Text(
                                          event.minute=="0" ? "00" : event.minute.toString(),
                                          style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                                        ),
                                        Container(
                                            height: 8,
                                            width: 24,
                                            child: VerticalDivider(color: Theme.of(context).primaryColor, width: MediaQuery.of(context).size.width*0.01, thickness: 1,)
                                        ),
                                        Icon(
                                          Icons.timer,
                                          color: Theme.of(context).primaryColor,
                                          size: 15,
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                        Text(
                                          durationToString(event.duration!),
                                          style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                                        ),
                                        Container(
                                            height: 8,
                                            width: 24,
                                            child: VerticalDivider(color: Theme.of(context).primaryColor, width: MediaQuery.of(context).size.width*0.01, thickness: 1,)
                                        ),
                                        Icon(
                                          Icons.record_voice_over,
                                          color: Theme.of(context).primaryColor,
                                          size: 15,
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                        Text(
                                          event.numTrainers.toString(),
                                          style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                                        ),
                                        Container(
                                            height: 8,
                                            width: 24,
                                            child: VerticalDivider(color: Theme.of(context).primaryColor, width: MediaQuery.of(context).size.width*0.01, thickness: 1,)
                                        ),
                                        Icon(
                                          Icons.directions_run,
                                          color: Theme.of(context).primaryColor,
                                          size: 15,
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                        Text(
                                          event.numClients.toString(),
                                          style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Theme.of(context).primaryColor,
                                  size: MediaQuery.of(context).size.width*0.04,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
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
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
