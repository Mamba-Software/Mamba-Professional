import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/AddEditEvent/AddOrEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/AddEditEvent/AddOrEditPrivateEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrandCalendarWidget extends StatefulWidget {
  String brandId;
  DateTime? dateTime;
  bool? onlyView;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;

  BrandCalendarWidget({Key? key, required this.brandId, this.dateTime, this.onlyView, required this.pinned, required this.pinnedChanged}) : super(key: key);

  @override
  _BrandCalendarWidgetState createState() => _BrandCalendarWidgetState();
}

class _BrandCalendarWidgetState extends State<BrandCalendarWidget>{

  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.25 - kToolbarHeight);
  }
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
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
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
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
    super.initState();
    _scrollController = ScrollController()
    ..addListener(() => _isAppBarExpanded ?
    setState(() {
      appBarExpanded = true;
    }) :
    setState(() {
      appBarExpanded = false;
    }),
    );
    isLoading = true;
    initAppBarDateTitle();
    getUserBrandDetails();

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
      displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));
    } else {
      DateTime dateTime = widget.dateTime!;
      int currentDay = dateTime.weekday;
      displayDateTimeStart = dateTime.subtract(Duration(days: currentDay-1));
      displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));
    }
  }

  void initCalendar() {
    // Init App Bar Title
    if (widget.dateTime == null) {
      DateTime now = DateTime.now();
      int currentDay = now.weekday;
      displayDateTimeStart = now.subtract(Duration(days: currentDay - 1));
      displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 7));
    } else {
      DateTime dateTime = widget.dateTime!;
      int currentDay = dateTime.weekday;
      displayDateTimeStart = dateTime.subtract(Duration(days: currentDay - 1));
      displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));
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

  void _addPrivateEvent() {
    Navigator.push(
        context,
        CupertinoPageRoute<String>(
          builder: (context) => AddOrEditPrivateEvent(
            locale: Localizations.localeOf(context),
          ),
        )
    );
  }

  Widget _buildTitleFromDate(DateTime dateTimeStart, DateTime dateTimeEnd, DateTime middleMonthDate) {
    return Text(
      StringUtils().toCapitalized(DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode,).format(middleMonthDate)),
      style: Theme.of(context).textTheme.headline1,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }

    return Scaffold(
      key: _globalKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            expandedHeight: MediaQuery.of(context).size.height*0.15,
            elevation: 4,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                height: MediaQuery.of(context).size.height*0.15,
                color: Theme.of(context).backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.025),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTitleFromDate(displayDateTimeStart, displayDateTimeEnd, middleMonthDate),
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.08,
                              width: MediaQuery.of(context).size.width*0.35,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
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
                                        style: Theme.of(context).textTheme.bodyText1,
                                        textAlign: TextAlign.center
                                    ),
                                  ),
                                  TextButton(
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
                                    child: _controller.view == CalendarView.month ? Column(
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
                                    ) : Column(
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
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    Container(
                      color: AppColors.grey,
                      height: 1.0,
                    ),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            //title: appBarExpanded ? Text(AppLocalizations.of(context)!.myRequests, style: Theme.of(context).appBarTheme.titleTextStyle,) : Container(),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: MediaQuery.of(context).size.height*0.04,
                    ),
                    onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
                child: IconButton(
                  icon: Icon(
                    widget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: widget.pinned ? AppColors.red : Theme.of(context).primaryColor.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width*0.06,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.pinned = !widget.pinned;
                    });
                    widget.pinnedChanged(widget.pinned);
                  },
                ),
              ),
            ],
          ),
          isLoading ? SliverFillRemaining(
            child: LoadingView(),
          ) :
          StreamBuilder<QuerySnapshot>(
            stream: _eventDataService.getBrandEventsStream(widget.brandId),
            builder: (context, snapshot) {
              if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.65,
                      child: Center(
                          child: LoadingView()
                      )
                  ),
                );
              } else {
                eventsList = documentsToEvents(snapshot.data!.docs);
                return SliverFillRemaining(
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                    child: SfCalendar(
                      cellEndPadding: 0,
                      view: CalendarView.week,
                      controller: _controller,
                      showDatePickerButton: true,
                      dataSource: _getCalendarDataSource(),
                      specialRegions: _getTimeRegions(),
                      timeRegionBuilder: timeRegionBuilder,
                      firstDayOfWeek: 1,
                      todayHighlightColor: Theme.of(context).colorScheme.secondary,
                      showCurrentTimeIndicator: true,
                      initialDisplayDate: widget.dateTime,
                      initialSelectedDate: widget.dateTime,
                      selectionDecoration: _controller.view == CalendarView.week ? BoxDecoration(
                          border: Border.all(width: 0.1, color: Colors.transparent)
                      ) : BoxDecoration(
                        border: Border.all(width: 0.5, color: Theme.of(context).colorScheme.secondary),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
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
                        minimumAppointmentDuration: const Duration(minutes: 30),
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
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                  elevation: 2,
                                  child: Container(
                                    height: safeAreaHeight*0.08,
                                    width: details.bounds.width,
                                    padding: EdgeInsets.symmetric(horizontal: details.bounds.width*0.05, vertical: safeAreaHeight*0.01),
                                    decoration: BoxDecoration(
                                      color: event.isPrivate! ? AppColors.black.withOpacity(0.2) : appointment.color.withOpacity(0.2),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              event.isPrivate! ? Icons.lock_outlined : Icons.groups,
                                              color: AppColors.white,
                                              size: details.bounds.width*0.05,
                                            ),
                                            SizedBox(width: details.bounds.width*0.02,),
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
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                  elevation: 2,
                                  child: Container(
                                    height: safeAreaHeight*0.08,
                                    width: details.bounds.width,
                                    padding: EdgeInsets.symmetric(horizontal: details.bounds.width*0.05, vertical: safeAreaHeight*0.01),
                                    decoration: BoxDecoration(
                                      color: event.isPrivate! ?  AppColors.black : appointment.color,
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(5),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              event.isPrivate! ? Icons.lock_outlined : Icons.groups,
                                              color: AppColors.white,
                                              size: details.bounds.width*0.05,
                                            ),
                                            SizedBox(width: details.bounds.width*0.02,),
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
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                  elevation: 2,
                                  child: Container(
                                    width: details.bounds.width,
                                    height: details.bounds.height,
                                    padding: EdgeInsets.all(details.bounds.width*0.1),
                                    decoration: BoxDecoration(
                                      color: event.isPrivate! ? AppColors.black.withOpacity(0.2) : appointment.color.withOpacity(0.2),
                                      borderRadius: const BorderRadius.all(
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              event.isPrivate! ? Icons.lock_outlined : Icons.groups,
                                              color: AppColors.white,
                                              size: details.bounds.width*0.2,
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
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                  elevation: 2,
                                  child: Container(
                                    width: details.bounds.width,
                                    height: details.bounds.height,
                                    padding: EdgeInsets.all(details.bounds.height*0.1),
                                    decoration: BoxDecoration(
                                      color: event.isPrivate! ? AppColors.black : appointment.color,
                                      borderRadius: const BorderRadius.all(
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              event.isPrivate! ? Icons.lock_outlined : Icons.groups,
                                              color: AppColors.white,
                                              size: details.bounds.width*0.2,
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
                  ),
                );
              }
            }
          ),
        ],
      ),
      floatingActionButton: whichFloatingActionButton(),
    );
  }

  Widget whichFloatingActionButton() {
    return canEdit ? Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: MediaQuery.of(context).size.width*0.15,
        width: MediaQuery.of(context).size.width*0.15,
        child: SpeedDial(
          animatedIcon: AnimatedIcons.add_event,
          foregroundColor: AppColors.white,
          overlayColor: Theme.of(context).scaffoldBackgroundColor,
          spacing: MediaQuery.of(context).size.height*0.02,
          spaceBetweenChildren: MediaQuery.of(context).size.height*0.02,
          children: [
            SpeedDialChild(
              child: const Icon(
                Icons.groups,
              ),
              elevation: 10,
              backgroundColor: Theme.of(context).backgroundColor,
              labelWidget: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05),
                height: MediaQuery.of(context).size.height*0.1,
                width: MediaQuery.of(context).size.width*0.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        AppLocalizations.of(context)!.groupEvent,
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.right
                    ),
                    Text(
                        AppLocalizations.of(context)!.groupEventDesc,
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.right
                    ),
                  ],
                ),
              ),
              onTap: () {
                _addEvent();
              }
            ),
            SpeedDialChild(
              child: const Icon(
                Icons.lock_outlined,
              ),
              elevation: 10,
              backgroundColor: Theme.of(context).backgroundColor,
              labelWidget: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05),
                height: MediaQuery.of(context).size.height*0.1,
                width: MediaQuery.of(context).size.width*0.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        AppLocalizations.of(context)!.privateEvent,
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.right
                    ),
                    Text(
                        AppLocalizations.of(context)!.privateEventDesc,
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.right
                    ),
                  ],
                ),
              ),
              onTap: () {
                _addPrivateEvent();
              }
            ),
          ],
        ),
      ),
    ) : Container();
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
      color: const Color(0x40B5B5B5),
    );
  }

  AppointmentDataSource _getCalendarDataSource() {
    List<Appointment> tempAllAppointments = [];
    for (var i=0; i < eventsList.length; i++) {
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
        if(bookedCapacity <= 0.20) color = Colors.green;
        else if(bookedCapacity > 0.20 && bookedCapacity <= 0.40) color = const Color(0xFFA8C76C);
        else if(bookedCapacity > 0.40 && bookedCapacity <= 0.60) color = const Color(0xFFECE014);
        else if(bookedCapacity > 0.60 && bookedCapacity <= 0.80) color = Colors.orangeAccent;
        else if(bookedCapacity > 0.80 && bookedCapacity < 1) color = Colors.deepOrangeAccent;
        else if(bookedCapacity == 1) color = Colors.red;
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
      Event evt = Event.fromObjectOnlyCoverData(documents[i].id, documents[i]);
      if (currentUser.isTrainer!) {
        events.add(evt);
      } else {
        if (!evt.isPrivate!) {
          events.add(evt);
        }
      }
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
