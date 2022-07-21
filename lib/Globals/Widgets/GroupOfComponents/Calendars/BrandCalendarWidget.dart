import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/AddEditEvent/AddOrEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrandCalendarWidget extends StatefulWidget {
  String brandId;
  DateTime? dateTime;
  bool? onlyView;

  BrandCalendarWidget({Key? key, required this.brandId, this.dateTime, this.onlyView}) : super(key: key);

  @override
  _BrandCalendarWidgetState createState() => _BrandCalendarWidgetState();
}

class _BrandCalendarWidgetState extends State<BrandCalendarWidget> {
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  bool canEdit = false;
  // Boolean Loading
  Brand _brand = Brand();
  // Sesions Controller
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
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
  // Selecte Date Time
  DateTime displayDateTimeStart = DateTime.now();
  DateTime displayDateTimeEnd = DateTime.now();
  DateTime middleMonthDate = DateTime.now();

  @override
  void initState() {
    isLoading = true;
    initAppBarDateTitle();
    getUserBrandDetails();
    super.initState();
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  // Init App Bar Title
  initAppBarDateTitle() {
    if (widget.dateTime == null) {
      DateTime now = DateTime.now();
      int currentDay = now.weekday;
      displayDateTimeStart = now.subtract(Duration(days: currentDay-1));
      displayDateTimeEnd = displayDateTimeStart.add(Duration(days: 6));
    } else {
      DateTime dateTime = widget.dateTime!;
      int currentDay = dateTime.weekday;
      displayDateTimeStart = dateTime.subtract(Duration(days: currentDay-1));
      displayDateTimeEnd = displayDateTimeStart.add(Duration(days: 6));
    }
  }

  void initCalendar() {
    // Init App Bar Title
    if (widget.dateTime == null) {
      DateTime now = DateTime.now();
      int currentDay = now.weekday;
      displayDateTimeStart = now.subtract(Duration(days: currentDay - 1));
      displayDateTimeEnd = displayDateTimeStart.add(Duration(days: 7));
    } else {
      DateTime dateTime = widget.dateTime!;
      int currentDay = dateTime.weekday;
      displayDateTimeStart = dateTime.subtract(Duration(days: currentDay - 1));
      displayDateTimeEnd = displayDateTimeStart.add(Duration(days: 6));
    }
    dateJoined = DateFormat('dd-MM-yyyy').parse(_brand.dateJoined!);
    _startHour = double.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    _endHour = double.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void getUserBrandDetails() async {
    _brand = await _brandDataService.getBrandDetails(widget.brandId);
    if (currentUser.isTrainer! && (widget.onlyView == false || widget.onlyView == null)) canEdit = true;
    initCalendar();
  }

  Event getEvent(String eventId) {
    for (var i=0; i < eventsList.length; i++) {
      Event temp = eventsList[i];
      if (temp.id == eventId) return temp;
    }
    return Event();
  }

  void _addEvent() {
    Navigator.push(
        context,
        CupertinoPageRoute<String>(
          builder: (context) => AddOrEditEvent(
            locale: Localizations.localeOf(context),
          ),
        )
    );
  }

  durationToString(double duration) {
    String temp = "";
    temp = duration.toStringAsFixed(2);
    var hour = temp.split(".")[0];
    var min = temp.split(".")[1];
    return "${hour}h ${min}m ";
  }

  Widget _buildTitleFromDate(DateTime dateTimeStart, DateTime dateTimeEnd, DateTime middleMonthDate) {
    return Text(
      StringUtils().toCapitalized(DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode,).format(middleMonthDate)),
      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w600),
    );
    // Deprecated
    if (_controller.view == CalendarView.month) {
      return Text(
        StringUtils().toCapitalized(DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode,).format(middleMonthDate)),
        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w600),
      );
    } else {
      // Day of the First Date
      String dateTitleStart = DateFormat('dd MMMM yy', Localizations.localeOf(context).languageCode).format(dateTimeStart);
      String dateStartDay = StringUtils().splitByChar(dateTitleStart, " ")[0];
      // Day Month Year of the Last Date
      String dateTitleEnd = DateFormat('dd MMMM yyyy', Localizations.localeOf(context).languageCode).format(dateTimeEnd);
      // Format  the results
      String dateTitle = dateStartDay + " - " + dateTitleEnd;
      // Return the Title
      return Text(
          StringUtils().capitalizedAllWords(dateTitle),
          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w600)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }

    return Scaffold(
          key: _globalKey,
          appBar: AppBar(
            title: _buildTitleFromDate(displayDateTimeStart, displayDateTimeEnd, middleMonthDate),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              Container(
                width: safeAreaWidth*0.15,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _controller.displayDate = DateTime.now();
                    });
                    if (_controller.view == CalendarView.month) {
                      setState(() {
                        _controller.selectedDate = DateTime.now();
                      });
                    }
                  },
                  child: Text(
                      AppLocalizations.of(context)!.todayString,
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_controller.view == CalendarView.month) {
                   setState(() {
                     _controller.view = CalendarView.week;
                   });
                  } else {
                    setState(() {
                      print(_controller.displayDate);
                      _controller.view = CalendarView.month;
                    });
                  }
                },
                icon: _controller.view == CalendarView.month ? Container(
                  width: safeAreaWidth*0.15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_view_week,
                        color: Theme.of(context).primaryColor,
                        size: safeAreaWidth*0.05,
                      ),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                            AppLocalizations.of(context)!.weekString,
                            style: Theme.of(context).textTheme.bodyText2,
                            textAlign: TextAlign.center
                        ),
                      ),
                    ],
                  ),
                ) : Container(
                  width: safeAreaWidth*0.15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_view_month,
                        color: Theme.of(context).primaryColor,
                        size: safeAreaWidth*0.05,
                      ),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                            AppLocalizations.of(context)!.monthString,
                            style: Theme.of(context).textTheme.bodyText2,
                            textAlign: TextAlign.center
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: !isLoading ? StreamBuilder<QuerySnapshot>(
              stream: _eventDataService.getBrandEventsStream(widget.brandId),
              builder: (context, snapshot) {
                if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                  return LoadingViewPurple();
                } else {
                  eventsList = documentsToEvents(snapshot.data!.docs);
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05, vertical: safeAreaWidth*0.08),
                    child: SfCalendar(
                        cellEndPadding: 0,
                        view: CalendarView.week,
                        controller: _controller,
                        showDatePickerButton: true,
                        dataSource: _getCalendarDataSource(),
                        specialRegions: _getTimeRegions(),
                        timeRegionBuilder: timeRegionBuilder,
                        firstDayOfWeek: 1,
                        todayHighlightColor: Theme.of(context).accentColor,
                        showCurrentTimeIndicator: true,
                        initialDisplayDate: widget.dateTime,
                        initialSelectedDate: widget.dateTime,
                        selectionDecoration: _controller.view == CalendarView.week ? BoxDecoration(
                            border: Border.all(width: 0.1, color: Colors.transparent)
                        ) : BoxDecoration(
                          border: Border.all(width: 0.5, color: Theme.of(context).accentColor),
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        headerHeight: 0,
                        headerStyle: CalendarHeaderStyle(
                          textAlign: TextAlign.center,
                          backgroundColor: Colors.transparent,
                          textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.transparent),
                        ),
                        viewHeaderHeight: 50,
                        viewHeaderStyle: ViewHeaderStyle(
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          dateTextStyle: Theme.of(context).textTheme.bodyText2,
                          dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                        ),
                        cellBorderColor: _controller.view == CalendarView.month ? Colors.transparent : AppColors.grey,
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
                        monthViewSettings: MonthViewSettings(
                          appointmentDisplayCount: 5,
                          numberOfWeeksInView: 6,
                          showTrailingAndLeadingDates: false,
                          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                          showAgenda: _controller.selectedDate != null,
                          agendaViewHeight: safeAreaHeight*0.4,
                          agendaItemHeight: safeAreaHeight*0.08,
                          agendaStyle: AgendaStyle(
                            appointmentTextStyle: Theme.of(context).textTheme.bodyText2,
                          ),
                          monthCellStyle: MonthCellStyle(
                            textStyle: Theme.of(context).textTheme.bodyText1,
                            trailingDatesTextStyle: Theme.of(context).textTheme.caption,
                            leadingDatesTextStyle: Theme.of(context).textTheme.caption,
                          ),
                        ),
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
                          final Appointment appointment = details.appointments.first;
                          final DateTime today = DateTime.now();
                          bool isCompleted = appointment.endTime.isBefore(today);
                          final Event event = getEvent(appointment.id.toString());
                          if (_controller.view == CalendarView.month) {
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
                                      height: safeAreaHeight*0.08,
                                      width: details.bounds.width,
                                      padding: EdgeInsets.symmetric(horizontal: details.bounds.width*0.05, vertical: safeAreaHeight*0.01),
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
                                                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white.withOpacity(1), fontWeight: FontWeight.w600),
                                                textAlign: TextAlign.start,
                                              ),

                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                DateFormat('Hm', Localizations.localeOf(context).languageCode).format(appointment.startTime) + " - " + DateFormat('Hm', Localizations.localeOf(context).languageCode).format(appointment.endTime),
                                                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white.withOpacity(0.5)),
                                                textAlign: TextAlign.start,
                                              ),
                                              Text(
                                                "("+appointment.subject+")",
                                                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white.withOpacity(0.5)),
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
                                      height: safeAreaHeight*0.08,
                                      width: details.bounds.width,
                                      padding: EdgeInsets.symmetric(horizontal: details.bounds.width*0.05, vertical: safeAreaHeight*0.01),
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
                          } else {
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
                                      width: details.bounds.width,
                                      height: details.bounds.height,
                                      padding: EdgeInsets.all(details.bounds.width*0.1),
                                      decoration: BoxDecoration(
                                        color: appointment.color.withOpacity(0.2),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          AutoSizeText(
                                            event.title!,
                                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
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
                                      width: details.bounds.width,
                                      height: details.bounds.height,
                                      padding: EdgeInsets.all(details.bounds.height*0.1),
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
                                            maxFontSize: 16,
                                          ),
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
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                  );
                }
              }
          ) : LoadingViewPurple(),
          floatingActionButton: canEdit ? Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              height: MediaQuery.of(context).size.width*0.15,
              width: MediaQuery.of(context).size.width*0.15,
              child: FloatingActionButton(
                heroTag: "3",
                onPressed: () {
                  _addEvent();
                },
                backgroundColor: Theme.of(context).accentColor,
                child: Icon(
                  Icons.more_time,
                  size: MediaQuery.of(context).size.width*0.06,
                  color: AppColors.white,
                ),
              ),
            ),
          ) : Container(), /// This trailing comma makes auto-formatting nicer for build methods.
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

  void navigateToEventScreen(String eventId) {
    // Navigate to Event Screen
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => EventPage(
            eventId: eventId,
            onlyView: widget.onlyView,
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
