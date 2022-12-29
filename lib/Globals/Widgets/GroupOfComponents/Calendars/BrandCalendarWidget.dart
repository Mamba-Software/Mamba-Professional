import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/BrandEventCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/AddEditEvent/AddOrEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/AddEditEvent/AddOrEditPrivateEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class BrandCalendarWidget extends StatefulWidget {
  String brandId;
  DateTime? dateTime;
  CalendarView? calendarView;
  bool? onlyView;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;

  BrandCalendarWidget({Key? key, required this.brandId, this.dateTime, this.calendarView, this.onlyView, required this.pinned, required this.pinnedChanged}) : super(key: key);

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
  String selectedValue = '0';
  var items = ['0', '1', '2'];

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
  bool isWeekly = false;
  // Dies de la semana que el entrenador no treballa
  List<int> nonWorkDays = [];
  // Horari
  double? _startHour;
  double? _endHour;
  // Descansos
  DateTime dateJoined = DateTime.now();
  // Events From Brand
  List<Event> eventsList = [];
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
    // Initial Date Time
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

  void getUserBrandDetails() async {
    _brand = await _brandDataService.getBrandDetails(widget.brandId);
    if (currentUser.brandRole < 3) {
      canEdit = true;
    } else {
      canEdit = false;
    }
    initCalendar();
  }

  void initCalendar() {
    // Init App Bar Title
    if (widget.dateTime == null) {
      DateTime now = DateTime.now();
      int currentDay = now.weekday;
      displayDateTimeStart = now.subtract(Duration(days: currentDay - 1));
      displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 7));
      _controller.selectedDate = DateTime.now();
    } else {
      DateTime dateTime = widget.dateTime!;
      int currentDay = dateTime.weekday;
      displayDateTimeStart = dateTime.subtract(Duration(days: currentDay - 1));
      displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));
      _controller.selectedDate = dateTime;
    }
    // Initial Calendar View
    if (widget.calendarView == null) {
      _controller.view = CalendarView.month;
      isWeekly = true;
      _controller.displayDate = DateTime.now().subtract(const Duration(hours: 1));
    } else {
      _controller.view = CalendarView.month;
    }
    dateJoined = DateFormat('dd-MM-yyyy').parse(_brand.dateJoined!);
    _startHour = double.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    _endHour = double.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);
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

  void _addEvent([DateTime? dateTime]) {
    mixpanel!.track('brand_calendar_plan_event', properties: {'isPrivate': false});
    Navigator.push(
        context,
        CupertinoPageRoute<String>(
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: AddOrEditEvent(
              locale: Localizations.localeOf(context),
              dateTime: dateTime,
            ),
          ),
        )
    );
  }

  void _addPrivateEvent([DateTime? dateTime]) {
    mixpanel!.track('brand_calendar_plan_event', properties: {'isPrivate': true});
    Navigator.push(
        context,
        CupertinoPageRoute<String>(
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: AddOrEditPrivateEvent(
              locale: Localizations.localeOf(context),
              dateTime: dateTime,
            ),
          ),
        )
    );
  }

  Widget _buildTitleFromDateCalendarView(DateTime dateTimeStart, DateTime dateTimeEnd, DateTime middleMonthDate) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
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
      ),
    );
  }

  Widget _buildTitleFromDate(DateTime dateTimeStart, DateTime dateTimeEnd, DateTime middleMonthDate) {
    return Container(
      color: AppColors.darkGrey,
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.00),
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
        style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
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
                    item == '0' ? AppLocalizations.of(context)!.calendar+" " : AppLocalizations.of(context)!.historic+" ",
                    style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white),
                  ),
                  FaIcon(
                      FontAwesomeIcons.chevronDown,
                      size: MediaQuery.of(context).size.width*0.03,
                      color: AppColors.white
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
                  AppLocalizations.of(context)!.historic,
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
    );
  }

  Widget _buildIconController() {
    if (isWeekly == false) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_view_week,
            color: AppColors.white,
            size: safeAreaWidth*0.05,
          ),
          FittedBox(
            fit: BoxFit.contain,
            child: Text(
                AppLocalizations.of(context)!.weekString,
                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                textAlign: TextAlign.center
            ),
          ),
        ],
      );
    } else if (isWeekly == true) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_view_month,
            color: AppColors.white,
            size: safeAreaWidth * 0.05,
          ),
          FittedBox(
            fit: BoxFit.contain,
            child: Text(
                AppLocalizations.of(context)!.monthString,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyText2
                    ?.copyWith(color: AppColors.white),
                textAlign: TextAlign.center
            ),
          ),
        ],
      );
    }
    return Container();

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
        color: appointment.color,
      ),
    );
  }

  /*
  Widget _buildEventContainer(CalendarAppointmentDetails details) {
    final Appointment appointment = details.appointments.first;
    final DateTime today = DateTime.now();
    bool isCompleted = appointment.endTime.isBefore(today);
    final Event event = getEvent(appointment.id.toString());
    if (_controller.view == CalendarView.day) {
      if (isCompleted) {
        return GestureDetector(
          onTap: () {
            navigateToEventScreen(appointment.id.toString(), isCompleted);
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
            navigateToEventScreen(appointment.id.toString(), isCompleted);
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
    } else if (_controller.view == CalendarView.week) {
      if (isCompleted) {
        return GestureDetector(
          onTap: () {
            navigateToEventScreen(appointment.id.toString(), isCompleted);
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
                padding: const EdgeInsets.all(5),
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
            navigateToEventScreen(appointment.id.toString(), isCompleted);
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
                padding: const EdgeInsets.all(5),
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
    } else if (_controller.view == CalendarView.month){
      if (isCompleted) {
        return GestureDetector(
          onTap: () {
            navigateToEventScreen(appointment.id.toString(), isCompleted);
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
            navigateToEventScreen(appointment.id.toString(), isCompleted);
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
    }
    if (isCompleted) {
      return GestureDetector(
        onTap: () {
          navigateToEventScreen(appointment.id.toString(), isCompleted);
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
          navigateToEventScreen(appointment.id.toString(), isCompleted);
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
  }

   */

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
            backgroundColor: AppColors.darkGrey,
            expandedHeight: MediaQuery.of(context).size.height*0.15,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 4,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                height: MediaQuery.of(context).size.height*0.15,
                color: AppColors.darkGrey,
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
                              width: MediaQuery.of(context).size.width*0.36,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      mixpanel!.track('brand_calendar_today');
                                      setState(() {
                                        _controller.selectedDate = DateTime.now();
                                        _controller.displayDate = DateTime.now().subtract(const Duration(hours: 1));
                                      });
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.todayString,
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                                        textAlign: TextAlign.center
                                    ),
                                  ),
                                  selectedValue == '0' ? TextButton(
                                    onPressed: () {
                                      if (isWeekly == false) {
                                        mixpanel!.track('brand_calendar_week');
                                        setState(() {
                                          isWeekly = true;
                                        });
                                      } else {
                                        mixpanel!.track('brand_calendar_month');
                                        setState(() {
                                          isWeekly = false;
                                        });
                                      }
                                    },
                                    child: _buildIconController(),
                                  ) : Container(),
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
                      color: AppColors.white,
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
                    color: widget.pinned ? AppColors.red : AppColors.white.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width*0.06,
                  ),
                  onPressed: () {
                    if (widget.pinned == true) {
                      mixpanel!.track('brand_calendar_pinned_off');
                    } else {
                      mixpanel!.track('brand_calendar_pinned_on');
                    }
                    setState(() {
                      widget.pinned = !widget.pinned;
                    });
                    widget.pinnedChanged(widget.pinned);
                  },
                ),
              ),
            ],
          ),
          if (isLoading) SliverFillRemaining(
            child: LoadingView(),
          ) else StreamBuilder<QuerySnapshot>(
            stream: _eventDataService.getBrandEventsStream(widget.brandId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.65,
                      child: Center(
                          child: LoadingView()
                      )
                  ),
                );
              } else {
                List<Event> tempEvents = documentsToEvents(snapshot.data!.docs);
                eventsList = List.from(tempEvents);
                return SliverFillRemaining(
                  child: Padding(
                    padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01, left: MediaQuery.of(context).size.width*0.01),
                    child: Column(
                      children: [
                        _controller.view == CalendarView.month && isWeekly == false ? _buildTitleFromDateCalendarView(displayDateTimeStart, displayDateTimeEnd, middleMonthDate) : Container(),
                        Expanded(
                          child: SfCalendarTheme(
                            data: SfCalendarThemeData(
                              brightness: Brightness.dark,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              todayHighlightColor: Theme.of(context).primaryColor,
                              todayBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                dateTextStyle: Theme.of(context).textTheme.bodyText2,
                                dayTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                              ),
                              // Monthly View
                              monthViewSettings: MonthViewSettings(
                                appointmentDisplayCount: 3,
                                numberOfWeeksInView: isWeekly == false ? 6 : 1,
                                showTrailingAndLeadingDates: false,
                                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                                showAgenda: true,
                                agendaViewHeight: isWeekly == false ? MediaQuery.of(context).size.height*0.37 : MediaQuery.of(context).size.height*0.71,
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
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    weekTextStyle: Theme.of(context).textTheme.caption,
                                  ),
                                  monthHeaderSettings: MonthHeaderSettings(
                                    monthFormat: 'MMMM yyyy',
                                    height: 70,
                                    textAlign: TextAlign.start,
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    monthTextStyle: Theme.of(context).textTheme.headline1,
                                  )
                              ),
                              scheduleViewMonthHeaderBuilder: (BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
                                return Container(
                                  color: Theme.of(context).scaffoldBackgroundColor,
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
                  ));
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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      DateTime startDate = DateTime(
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
    return AppointmentDataSource(tempAllAppointments);
  }
/*
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

 */

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

  void navigateToEventScreen(String eventId, bool isCompleted) {
    mixpanel!.track('brand_calendar_event_view', properties: {'Calendar View': _controller.view.toString(), 'isCompleted': isCompleted});
    // Navigate to Event Screen
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => EventPage(
            eventId: eventId,
            onlyView: widget.onlyView,
          ),
        )
    );
  }

  void onTapCalendar(CalendarTapDetails details) async {
    if (details.date!.isAfter(DateTime.now()) && canEdit && _controller.view != CalendarView.month) {
      setState(() {
        _controller.selectedDate = details.date;
      });
      await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.3,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                            AppLocalizations.of(context)!.add,
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.left
                        ),
                        dense: true,
                      ),
                      ListTile(
                        onTap: () {
                          mixpanel!.track('brand_calendar_plan_event_modal', properties: {'isPrivate': false});
                          Navigator.pop(context);
                          _addEvent(details.date);
                        },
                        title: Text(
                            AppLocalizations.of(context)!.groupEvent,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left
                        ),
                        subtitle: Text(
                            AppLocalizations.of(context)!.groupEventDesc,
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.left
                        ),
                        leading: const Icon(
                          Icons.groups,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          mixpanel!.track('brand_calendar_plan_event_modal', properties: {'isPrivate': true});
                          Navigator.pop(context);
                          _addPrivateEvent(details.date);
                        },
                        title: Text(
                            AppLocalizations.of(context)!.privateEvent,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left
                        ),
                        subtitle: Text(
                            AppLocalizations.of(context)!.privateEventDesc,
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.left
                        ),
                        leading: const Icon(
                          Icons.lock_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
      );
      setState(() {
        _controller.selectedDate = null;
      });
    } else {
      if (_controller.view != CalendarView.month) {
        setState(() {
          _controller.selectedDate = null;
        });
      } else {
        setState(() {
          _controller.selectedDate = details.date;
        });
      }
    }
  }

  void onLongPressCalendar(CalendarLongPressDetails details) async {
    if (details.date!.isAfter(DateTime.now()) && canEdit && _controller.view != CalendarView.month) {
      setState(() {
        _controller.selectedDate = details.date;
      });
      await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.3,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                            AppLocalizations.of(context)!.add,
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.left
                        ),
                        dense: true,
                      ),
                      ListTile(
                        onTap: () {
                          mixpanel!.track('brand_calendar_plan_event_modal', properties: {'isPrivate': false});
                          Navigator.pop(context);
                          _addEvent(details.date);
                        },
                        title: Text(
                            AppLocalizations.of(context)!.groupEvent,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left
                        ),
                        subtitle: Text(
                            AppLocalizations.of(context)!.groupEventDesc,
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.left
                        ),
                        leading: const Icon(
                          Icons.groups,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          mixpanel!.track('brand_calendar_plan_event_modal', properties: {'isPrivate': true});
                          Navigator.pop(context);
                          _addPrivateEvent(details.date);
                        },
                        title: Text(
                            AppLocalizations.of(context)!.privateEvent,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.left
                        ),
                        subtitle: Text(
                            AppLocalizations.of(context)!.privateEventDesc,
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.left
                        ),
                        leading: const Icon(
                          Icons.lock_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
      );
      setState(() {
        _controller.selectedDate = null;
      });
    } else {
      if (_controller.view != CalendarView.month) {
        setState(() {
          _controller.selectedDate = null;
        });
      } else {
        setState(() {
          _controller.selectedDate = details.date;
        });
      }
    }
  }

}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
