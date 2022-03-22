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
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventListTile.dart';
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
    await getEventsDone();
    initCalendar();
  }

  // Gets the events passed by the trainer.
  Future<void> getEventsDone() async {
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
                    height: safeAreaHeight*0.08,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Mi Calendario",
                          style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center
                        ),
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
                                    textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.transparent),
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
                                    color: AppColors.grey.withOpacity(0.8),
                                    borderRadius: new BorderRadius.vertical(
                                      top: Radius.circular(10.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_back_ios, color: AppColors.white, size: safeAreaHeight*0.02,),
                                        alignment: Alignment.center,
                                        onPressed: () {
                                          _calendarController.backward!();
                                        },
                                      ),
                                      Text(
                                        toCapitalized(DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode,).format(middleMonthDate)),
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                                        textAlign: TextAlign.start,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward_ios, color: AppColors.white, size: safeAreaHeight*0.02,),
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
                      height: safeAreaHeight*0.08,
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
                          return Column(
                            children: [
                              EventListTile(
                                eventId: event.id!,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: safeAreaHeight*0.03,horizontal: safeAreaWidth*0.05),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 1,
                                      width: safeAreaWidth*0.68,
                                      color: AppColors.grey,
                                    ),
                                  ],
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
