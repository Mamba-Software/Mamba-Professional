import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/read_event/views/mobile/ReadEventPage.dart';
import 'package:mamba/events/crud_events/views/mobile/AddorEdtiEvent.dart';
import 'package:mamba/events/crud_events/widgets/mobile/LinearProgressIndicator.dart';
import 'package:mamba/events/cubit/BrandEventsCubit.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/notifications/Unread/widgets/profileImage.dart';
import 'package:mamba/notifications/Unread/widgets/unreadChats.dart';
import 'package:mamba/notifications/Unread/widgets/askSupport.dart';
import 'package:mamba/notifications/Unread/widgets/unreadNotifications.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class BrandCalendarWidget extends StatefulWidget {
  String brandId;
  DateTime? dateTime;
  CalendarView? calendarView;
  bool? onlyView;

  BrandCalendarWidget({
    super.key,
    required this.brandId,
    this.dateTime,
    this.calendarView,
    this.onlyView,
  });

  @override
  _BrandCalendarWidgetState createState() => _BrandCalendarWidgetState();
}

class _BrandCalendarWidgetState extends State<BrandCalendarWidget>
    with PlatformMixin {
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset >
            (MediaQuery.of(context).size.height * 0.25 - kToolbarHeight);
  }

  String selectedValue = '2';
  var items = ['0', '1', '2', '3', '4', '5', '6'];
  final _topSnackBar = TopSnackBarDef();

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();

  // Boolean Loading
  bool isLoading = true;
  bool canEdit = false;
  // Boolean Loading
  Brand _brand = Brand();
  List<Usuario> _brandTrainers = [];
  List<Usuario> selectedTrainers = [];
  // Sesions Controller
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final CalendarController _controller = CalendarController();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  // Dies de la semana que el entrenador no treballa
  List<int> nonWorkDays = [];
  // Horari
  double? _startHour;
  double? _endHour;
  double _timeSlotViewZoom = -1;
  double _baseTimeSlotViewZoom = -1;
  double _timeSlotViewScale = 1;
  double _baseTimeSlotViewScale = 1;
  // Descansos
  DateTime dateJoined = DateTime.now();

  // Selecte Date Time
  DateTime displayDateTimeStart = DateTime.now();
  DateTime displayDateTimeEnd = DateTime.now();
  DateTime middleMonthDate = DateTime.now();

  // Filters
  bool hasFilter = false;
  int filterEventsNumber = 0;
  List<bool> filterByCalendar = [true, true];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(
        () => _isAppBarExpanded
            ? setState(() {
                appBarExpanded = true;
              })
            : setState(() {
                appBarExpanded = false;
              }),
      );
    isLoading = true;
    initAppBarDateTitle();
    getUserBrandDetails();
  }

  // Init App Bar Title
  initAppBarDateTitle() {
    // Initial Date Time
    if (widget.dateTime == null) {
      DateTime now = DateTime.now();
      int currentDay = now.weekday;
      displayDateTimeStart = now.subtract(Duration(days: currentDay - 1));
      displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));
    } else {
      DateTime dateTime = widget.dateTime!;
      int currentDay = dateTime.weekday;
      displayDateTimeStart = dateTime.subtract(Duration(days: currentDay - 1));
      displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));
    }
  }

  Future<void> initCalendar() async {
    // Initial Calendar View
    selectedValue = '2';
    _controller.view = CalendarView.week;
    //timeSlotViewZoom = _controller.view == CalendarView.week ? -1 : MediaQuery.of(context).size.height*0.15;
    // Date Joined Information
    dateJoined = DateFormat('dd-MM-yyyy').parse(_brand.dateJoined!);
    _startHour =
        double.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    _endHour =
        double.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);
    // Calcula el TimeSlotView per cadascuna
    _baseTimeSlotViewZoom = getScreenHeightDifference(context);
    _timeSlotViewScale = await _userDataService.getUserZoomScale(
        widget.brandId, currentUser.id!);
    _timeSlotViewZoom = _timeSlotViewScale * _baseTimeSlotViewZoom;
    // Get The Events Needed
    await context
        .read<BrandEventsCubit>()
        .getInitialBrandEvents(_brandTrainers);
    setState(() {
      isLoading = false;
    });
  }

  double getScreenHeightDifference(BuildContext context) {
    // The goal of this function is to calculate the height of each HOUR in the calendar. This is calculated depending on the numbers of avaiable hours (HORARI).
    // Final result
    double adjustedHeight;
    // Full screen height
    double screenHeight = MediaQuery.of(context).size.height;
    // Expanded Height of AppBar
    double expandedHeight = MediaQuery.of(context).size.height * 0.15 +
        MediaQuery.of(context).padding.top;
    // View Header Height Calendar
    double viewHeaderHeight = 50;
    // We're using TargetPlatform to determine the type of device
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
        //adjustedHeight = screenHeight - expandedHeight - viewHeaderHeight - bottomNavigationBarHeight;
        adjustedHeight = screenHeight - expandedHeight - viewHeaderHeight;
        break;
      case TargetPlatform.iOS:
        adjustedHeight = screenHeight - expandedHeight - viewHeaderHeight;
        break;
      default:
        adjustedHeight = screenHeight - expandedHeight - viewHeaderHeight;
        break;
    }
    // Diferencia de Hores
    double difference = _endHour! - _startHour!;
    difference = _startHour! != 0 ? difference + 1 : difference;
    difference = _endHour! != 24 ? difference + 1 : difference;
    return adjustedHeight / difference;
  }

  void getUserBrandDetails() async {
    _brand = await _brandDataService.getBrandDetails(widget.brandId);
    _brandTrainers = await _brandDataService.getBrandTrainers(widget.brandId);
    selectedTrainers = List.from(_brandTrainers);
    for (Usuario trainer in _brandTrainers) {
      trainer.setEventsList =
          await _eventDataService.getUserEvents(trainer.id!);
    }
    if (currentUser.brandRole < 3) {
      canEdit = true;
    } else {
      canEdit = false;
    }
    initCalendar();
  }

  void getNewEventMemberDetails(Event event) async {
    event.setUserList = await _eventDataService.getEventUsers(event.id!);
    for (Usuario user in event.usersList) {
      if (user.isTrainer == true) {
        for (Usuario trainer in _brandTrainers) {
          if (user.id == trainer.id) {
            List<Event> oldEventList = trainer.eventsList;
            oldEventList.add(event);
            trainer.setEventsList = oldEventList;
            break;
          }
        }
      }
    }
    //setState(() {});
  }

  Event getEvent(String eventId, List<Event> eventsList) {
    for (var i = 0; i < eventsList.length; i++) {
      Event temp = eventsList[i];
      if (temp.id == eventId) return temp;
    }
    return Event();
  }

  Future<void> _addEvent(DateTime dateTime, bool isPrivate) async {
    context.read<CrudEventCubit>().resetNewEvent();
    context.read<CrudEventCubit>().createNewEvent(dateTime, isPrivate);
    if (!brandIsActive) {
      await navigateToPayWall(context);
    } else {
      mixpanel!.track('brand_calendar_plan_event',
          properties: {'isPrivate': isPrivate});
      // Date Time
      DateTime eventDate = DateTime.now();
      eventDate =
          DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour);
      // Navigate to Add or Edit Event
      Navigator.push(
          context,
          CupertinoPageRoute<String>(
            builder: (context) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              child: AddOrEditEvent(
                locale: Localizations.localeOf(context),
              ),
            ),
          )).whenComplete(() {});
    }
  }

  Future<void> navigateToEventScreen(String eventId, bool isCompleted) async {
    mixpanel!.track('brand_calendar_event_view', properties: {
      'Calendar View': _controller.view.toString(),
      'isCompleted': isCompleted
    });
    // Navigate to Event Screen
    var result = await Navigator.push(
        context,
        CupertinoPageRoute<bool?>(
          builder: (context) => EventPage(
            eventId: eventId,
          ),
        ));
    if (result != null) {
      if (result) {
        if (isCompleted) {
          // Event Has Been Updated
          context
              .read<BrandEventsCubit>()
              .updateBrandEvent(eventId, _brandTrainers);
        }
      } else {
        if (isCompleted) {
          // Event Has Been Updated
          context.read<BrandEventsCubit>().deleteBrandEvent(eventId);
        }
      }
    }
  }

  Widget _buildTitleText(
      DateTime dateTimeStart, DateTime dateTimeEnd, DateTime middleMonthDate) {
    switch (_controller.view) {
      case CalendarView.schedule:
        return Text(
          "${context.l10n.schedule} ",
          style: context.textTheme.headlineMedium
              ?.copyWith(color: AppColors.white),
        );
      case CalendarView.day:
        return dateTimeStart.year == DateTime.now().year
            ? Text(
                "${StringUtils().toCapitalized(DateFormat(
                  'EEEE',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))}, ${StringUtils().toCapitalized(DateFormat(
                  'dd',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))} ${StringUtils().toCapitalized(DateFormat(
                      'MMMM',
                      Localizations.localeOf(context).languageCode,
                    ).format(dateTimeStart)).substring(0, 3)} ",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.white),
              )
            : Text(
                //StringUtils().toCapitalized(DateFormat('EE', Localizations.localeOf(context).languageCode,).format(dateTimeStart))+" "+
                "${StringUtils().toCapitalized(DateFormat(
                  'dd',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))} ${StringUtils().toCapitalized(DateFormat(
                  'MMMM yyyy',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))} ",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.white),
              );
      case CalendarView.week:
        return dateTimeStart.year == DateTime.now().year
            ? Text(
                "${StringUtils().toCapitalized(DateFormat(
                  'dd',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))} - ${StringUtils().toCapitalized(DateFormat(
                  'dd',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeEnd))} ${StringUtils().toCapitalized(DateFormat(
                  'MMMM',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))} ",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.white),
              )
            : Text(
                "${StringUtils().toCapitalized(DateFormat(
                  'dd',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))} - ${StringUtils().toCapitalized(DateFormat(
                  'dd',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeEnd))} ${StringUtils().toCapitalized(DateFormat(
                  'MMMM yy',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))} ",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.white),
              );
      case CalendarView.month:
        return Text(
          StringUtils().toCapitalized(DateFormat(
            middleMonthDate.year == DateTime.now().year
                ? 'MMMM '
                : 'MMMM yyyy ',
            Localizations.localeOf(context).languageCode,
          ).format(middleMonthDate)),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.white),
        );
      default:
        return dateTimeStart.year == DateTime.now().year
            ? Text(
                "${StringUtils().toCapitalized(DateFormat(
                  'dd',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))} - ${StringUtils().toCapitalized(DateFormat(
                  'dd',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart.add(const Duration(days: 6))))} ${StringUtils().toCapitalized(DateFormat(
                  'MMMM',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))} ",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.white),
              )
            : Text(
                "${StringUtils().toCapitalized(DateFormat(
                  'dd',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))} - ${StringUtils().toCapitalized(DateFormat(
                  'dd',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart.add(const Duration(days: 6))))} ${StringUtils().toCapitalized(DateFormat(
                  'MMMM yyyy',
                  Localizations.localeOf(context).languageCode,
                ).format(dateTimeStart))} ",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.white),
              );
    }
  }

  Widget _buildTitleFromDate(
      DateTime dateTimeStart, DateTime dateTimeEnd, DateTime middleMonthDate) {
    return Container(
      color: AppColors.darkGrey,
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.00),
      child: DropdownButton2(
        // Initial Value
        value: selectedValue,
        style: Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(color: AppColors.white),
        underline: Container(color: Colors.transparent),
        isExpanded: false,
        // Array list of items
        selectedItemBuilder: (BuildContext context) {
          return items.map((String item) {
            return Container(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  _buildTitleText(displayDateTimeStart, displayDateTimeEnd,
                      middleMonthDate),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.015),
                  FaIcon(
                    FontAwesomeIcons.chevronDown,
                    size: iconSizeSmall,
                    color: AppColors.white,
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
                  minWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  minLeadingWidth: MediaQuery.of(context).size.width * 0.05,
                  leading: Icon(Icons.view_agenda_outlined,
                      size: MediaQuery.of(context).size.width * 0.06,
                      color: Theme.of(context).primaryColor),
                  title: Text(
                    context.l10n.schedule,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: FaIcon(
                    FontAwesomeIcons.check,
                    size: MediaQuery.of(context).size.width * 0.04,
                    color: selectedValue == '0'
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                  ),
                ),
              )),
          const DropdownMenuItem<Divider>(
            enabled: false,
            child: Divider(color: AppColors.grey, height: 2),
          ),
          DropdownMenuItem(
              value: '1',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                minLeadingWidth: MediaQuery.of(context).size.width * 0.05,
                leading: Icon(Icons.view_day_outlined,
                    size: MediaQuery.of(context).size.width * 0.06,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  context.l10n.day,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: FaIcon(
                  FontAwesomeIcons.check,
                  size: MediaQuery.of(context).size.width * 0.04,
                  color: selectedValue == '1'
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                ),
              )),
          const DropdownMenuItem<Divider>(
            enabled: false,
            child: Divider(color: AppColors.grey, height: 2),
          ),
          DropdownMenuItem(
              value: '2',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                minLeadingWidth: MediaQuery.of(context).size.width * 0.05,
                leading: Icon(Icons.calendar_view_week,
                    size: MediaQuery.of(context).size.width * 0.06,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  context.l10n.week,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: FaIcon(
                  FontAwesomeIcons.check,
                  size: MediaQuery.of(context).size.width * 0.04,
                  color: selectedValue == '2'
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                ),
              )),
          const DropdownMenuItem<Divider>(
            enabled: false,
            child: Divider(color: AppColors.grey, height: 2),
          ),
          DropdownMenuItem(
              value: '3',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                minLeadingWidth: MediaQuery.of(context).size.width * 0.05,
                leading: Icon(Icons.calendar_view_month,
                    size: MediaQuery.of(context).size.width * 0.06,
                    color: Theme.of(context).primaryColor),
                title: Text(
                  context.l10n.month,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: FaIcon(
                  FontAwesomeIcons.check,
                  size: MediaQuery.of(context).size.width * 0.04,
                  color: selectedValue == '3'
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                ),
              )),
        ],
        // Down Arrow Icon
        iconStyleData: IconStyleData(
          icon: const FaIcon(FontAwesomeIcons.chevronDown,
              color: Colors.transparent),
          iconSize: MediaQuery.of(context).size.width * 0.03,
          iconEnabledColor: Colors.transparent,
          iconDisabledColor: Colors.transparent,
        ),
        // Drop Down Style
        dropdownStyleData: DropdownStyleData(
            maxHeight: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            offset: const Offset(0, 0),
            elevation: 4),
        menuItemStyleData: MenuItemStyleData(
          height: 40,
          customHeights: [
            MediaQuery.of(context).size.height * 0.06,
            8,
            MediaQuery.of(context).size.height * 0.06,
            8,
            MediaQuery.of(context).size.height * 0.06,
            8,
            MediaQuery.of(context).size.height * 0.06,
          ],
          padding: const EdgeInsets.only(left: 14, right: 14),
        ),
        // After selecting the desired option,it will
        // change button value to selected value
        onChanged: (newValue) {
          if (newValue == '0') {
            _controller.view = CalendarView.schedule;
          } else if (newValue == '1') {
            _controller.view = CalendarView.day;
          } else if (newValue == '2') {
            _controller.view = CalendarView.week;
          } else if (newValue == '3') {
            _controller.view = CalendarView.month;
          }
          setState(() {
            selectedValue = newValue.toString();
          });
        },
      ),
    );
  }

  Widget _buildEventContainer(
      CalendarAppointmentDetails details, List<Event> eventsList) {
    final Appointment appointment = details.appointments.first;
    final DateTime today = DateTime.now();
    bool isCompleted = appointment.endTime.isBefore(today);
    final Event event = getEvent(appointment.id.toString(), eventsList);
    if (_controller.view == CalendarView.day) {
      return GestureDetector(
        onTap: () {
          navigateToEventScreen(appointment.id.toString(), isCompleted);
        },
        child: Container(
          height: details.bounds.height,
          width: details.bounds.width,
          margin: const EdgeInsets.all(0),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: appointment.color,
            borderRadius: const BorderRadius.all(
              Radius.circular(4),
            ),
          ),
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxHeight >
                MediaQuery.of(context).size.height * 0.13) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      event.title!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.start,
                      softWrap: true,
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Text(
                        "${appointment.subject} ${context.l10n.asistants.toLowerCase()}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.white),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                  event.numFreeSessions != null && event.numFreeSessions != 0
                      ? Flexible(
                          child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: Text(
                                event.numFreeSessions == 1
                                    ? "${event.numFreeSessions} ${context.l10n.potentialClient.toLowerCase()}"
                                    : "${event.numFreeSessions} ${context.l10n.potentialClients.toLowerCase()}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.white,
                                      fontStyle: FontStyle.italic,
                                    ),
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false,
                              )),
                        )
                      : Container(),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      height: MediaQuery.of(context).size.width * 0.05,
                      child: ListView.builder(
                          shrinkWrap: false,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: event.usersList.length,
                          clipBehavior: Clip.none,
                          itemBuilder: (context, int index) {
                            var trainer = event.usersList[index];
                            if (trainer.isTrainer == true) {
                              return Container(
                                margin: const EdgeInsets.only(right: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircularImage(
                                      size: MediaQuery.of(context).size.width *
                                          0.05,
                                      image: trainer.imageUrl,
                                      color: AppColors.white,
                                      borderWidth: 0,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${trainer.firstName!} ${trainer.lastName![0]}.",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: AppColors.white,
                                              fontSize: 12),
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ),
                  ),
                ],
              );
            } else if (constraints.maxHeight >
                MediaQuery.of(context).size.height * 0.07) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      event.title!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.start,
                      softWrap: true,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "${appointment.subject} ${context.l10n.asistants.toLowerCase()}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.white),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  Flexible(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.05,
                      child: Row(
                        children: [
                          event.numFreeSessions != null &&
                                  event.numFreeSessions != 0
                              ? Text(
                                  event.numFreeSessions == 1
                                      ? "${event.numFreeSessions} ${context.l10n.potentialClient.toLowerCase()}  -  "
                                      : "${event.numFreeSessions} ${context.l10n.potentialClients.toLowerCase()}   -  ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.white,
                                        fontStyle: FontStyle.italic,
                                      ),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                )
                              : Container(),
                          Flexible(
                            child: ListView.builder(
                                shrinkWrap: false,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: event.usersList.length,
                                clipBehavior: Clip.none,
                                itemBuilder: (context, int index) {
                                  var trainer = event.usersList[index];
                                  if (trainer.isTrainer == true) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          CircularImage(
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                            image: trainer.imageUrl,
                                            color: AppColors.white,
                                            borderWidth: 0,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${trainer.firstName!} ${trainer.lastName![0]}.",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: AppColors.white,
                                                    fontSize: 12),
                                            overflow: TextOverflow.fade,
                                            maxLines: 1,
                                            softWrap: false,
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (constraints.maxHeight >
                MediaQuery.of(context).size.height * 0.05) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: RichText(
                      textAlign: TextAlign.start,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(text: event.title!),
                          event.isPrivate!
                              ? TextSpan(
                                  text:
                                      "   ${appointment.subject} ${context.l10n.asistants.toLowerCase()}   ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.white),
                                )
                              : TextSpan(
                                  text:
                                      "   ${appointment.subject} ${context.l10n.asistants.toLowerCase()}   ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.white),
                                ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.05,
                      child: Row(
                        children: [
                          event.numFreeSessions != null &&
                                  event.numFreeSessions != 0
                              ? Text(
                                  event.numFreeSessions == 1
                                      ? "${event.numFreeSessions} ${context.l10n.potentialClient.toLowerCase()}  -  "
                                      : "${event.numFreeSessions} ${context.l10n.potentialClients.toLowerCase()}   -  ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.white,
                                        fontStyle: FontStyle.italic,
                                      ),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                )
                              : Container(),
                          Flexible(
                            child: ListView.builder(
                                shrinkWrap: false,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: event.usersList.length,
                                clipBehavior: Clip.none,
                                itemBuilder: (context, int index) {
                                  var trainer = event.usersList[index];
                                  if (trainer.isTrainer == true) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          CircularImage(
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                            image: trainer.imageUrl,
                                            color: AppColors.white,
                                            borderWidth: 0,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${trainer.firstName!} ${trainer.lastName![0]}.",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.white,
                                                ),
                                            overflow: TextOverflow.fade,
                                            maxLines: 1,
                                            softWrap: false,
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: RichText(
                      textAlign: TextAlign.start,
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(text: event.title!),
                          event.isPrivate!
                              ? TextSpan(
                                  text:
                                      "   ${appointment.subject} ${context.l10n.asistants.toLowerCase()}   ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.white),
                                )
                              : TextSpan(
                                  text:
                                      "   ${appointment.subject} ${context.l10n.asistants.toLowerCase()}   ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.white),
                                ),
                        ],
                      ),
                    ),
                  ),
                  event.numFreeSessions != null && event.numFreeSessions != 0
                      ? Text(
                          event.numFreeSessions == 1
                              ? "${event.numFreeSessions} ${context.l10n.potentialClient.toLowerCase()}"
                              : "${event.numFreeSessions} ${context.l10n.potentialClients.toLowerCase()}",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.white,
                                    fontStyle: FontStyle.italic,
                                  ),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                        )
                      : Container(),
                  /*
                      event.title!.length+("   "+appointment.subject+" "+context.l10n.asistants.toLowerCase()).length < 35 ? Flexible(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width*0.05,
                          child: ListView.builder(
                              shrinkWrap: false,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: event.usersList.length,
                              clipBehavior: Clip.antiAlias,
                              itemBuilder: (context, int index) {
                                var trainer = event.usersList[index];
                                return Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  child: CircularImage(
                                    size: MediaQuery.of(context).size.width*0.05,
                                    image: trainer.imageUrl,
                                    color: AppColors.white,
                                    borderWidth: 0.5,
                                  ),
                                );
                              }
                          ),
                        ),
                      ) : Container(),
                       */
                ],
              );
            }
          }),
        ),
      );
    } else if (_controller.view == CalendarView.week) {
      return GestureDetector(
        onTap: () {
          navigateToEventScreen(appointment.id.toString(), isCompleted);
        },
        child: Container(
          height: details.bounds.height,
          width: details.bounds.width,
          margin: const EdgeInsets.all(1),
          padding: EdgeInsets.symmetric(
              vertical: details.bounds.width * 0.05,
              horizontal: details.bounds.width * 0.1),
          decoration: BoxDecoration(
            color: appointment.color,
            borderRadius: const BorderRadius.all(
              Radius.circular(4),
            ),
          ),
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: RichText(
                    textAlign: TextAlign.start,
                    softWrap: true,
                    overflow: TextOverflow.clip,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      children: [
                        TextSpan(text: "${event.title!}\n"),
                        TextSpan(
                          text: event.isPrivate!
                              ? "${appointment.subject} ${context.l10n.asistants.toLowerCase().substring(0, 4)}.\n"
                              : "${appointment.subject}\n",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                        event.numFreeSessions != null &&
                                event.numFreeSessions != 0
                            ? TextSpan(
                                text: event.numFreeSessions == 1
                                    ? "${event.numFreeSessions} ${context.l10n.potentialClient.toLowerCase()}\n"
                                    : "${event.numFreeSessions} ${context.l10n.potentialClients.toLowerCase()}\n",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: AppColors.white,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 11),
                              )
                            : const TextSpan(text: ""),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      );
    } else if (_controller.view == CalendarView.month) {
      return Container(
        height: details.bounds.height,
        width: details.bounds.width,
        margin: const EdgeInsets.all(1),
        padding: EdgeInsets.only(left: details.bounds.width * 0.05),
        decoration: BoxDecoration(
          color: appointment.color,
          borderRadius: const BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                event.title!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.clip,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        ),
      );
    } else if (_controller.view == CalendarView.schedule) {
      return GestureDetector(
        onTap: () {
          navigateToEventScreen(appointment.id.toString(), isCompleted);
        },
        child: Container(
          margin: EdgeInsets.only(
              top: details.bounds.width * 0.0,
              bottom: details.bounds.width * 0.02,
              right: MediaQuery.of(context).size.width * 0.02),
          child: Material(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(details.bounds.width * 0.04),
              ),
            ),
            child: SizedBox(
              height: details.bounds.height,
              width: details.bounds.width,
              child: Row(
                children: [
                  Container(
                    width: details.bounds.width * 0.1,
                    decoration: BoxDecoration(
                      color: appointment.color,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(details.bounds.width * 0.04),
                        bottomLeft:
                            Radius.circular(details.bounds.width * 0.04),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: details.bounds.width * 0.04,
                          vertical: details.bounds.width * 0.02),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight:
                              Radius.circular(details.bounds.width * 0.04),
                          bottomRight:
                              Radius.circular(details.bounds.width * 0.04),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              event.title!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${appointment.subject} ${context.l10n.asistants.toLowerCase()}",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                  Text(
                                    "${DateFormat('Hm', Localizations.localeOf(context).languageCode).format(appointment.startTime)} - ${DateFormat('Hm', Localizations.localeOf(context).languageCode).format(appointment.endTime)}",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: Row(
                              children: [
                                event.numFreeSessions != null &&
                                        event.numFreeSessions != 0
                                    ? Text(
                                        event.numFreeSessions == 1
                                            ? "${event.numFreeSessions} ${context.l10n.potentialClient.toLowerCase()}  -  "
                                            : "${event.numFreeSessions} ${context.l10n.potentialClients.toLowerCase()}  -  ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontStyle: FontStyle.italic,
                                            ),
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                      )
                                    : Container(),
                                Flexible(
                                  child: ListView.builder(
                                      shrinkWrap: false,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: event.usersList.length,
                                      clipBehavior: Clip.hardEdge,
                                      itemBuilder: (context, int index) {
                                        var trainer = event.usersList[index];
                                        if (trainer.isTrainer == true) {
                                          return Container(
                                            margin:
                                                const EdgeInsets.only(right: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                CircularImage(
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.05,
                                                  image: trainer.imageUrl,
                                                  color: AppColors.white,
                                                  borderWidth: 0,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  trainer.lastName != null &&
                                                          trainer.lastName!
                                                              .isNotEmpty
                                                      ? "${trainer.firstName!} ${trainer.lastName![0]}."
                                                      : trainer.firstName!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                  overflow: TextOverflow.fade,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Container();
  }

  String returnFilteredRolesString() {
    String filteredEvents = "";
    int cnt = 0;
    if (filterByCalendar[0]) {
      filteredEvents += "${context.l10n.groupEvent}, ";
      cnt += 1;
    }
    if (filterByCalendar[1]) {
      filteredEvents += "${context.l10n.privateEvent}, ";
      cnt += 1;
    }
    if (cnt == 1) {
      return filteredEvents.split(", ")[0];
    }
    if (cnt == 2) {
      return "${filteredEvents.split(", ")[0]}, ${filteredEvents.split(", ")[1]}";
    }
    return filteredEvents;
  }

  String returnFilteredStaffMembersString() {
    String filteredMembers = "";
    for (Usuario trainer in selectedTrainers) {
      filteredMembers += "${trainer.name!}, ";
    }
    return filteredMembers.substring(0, filteredMembers.length - 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _globalKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _scrollController,
          slivers: [
            
            SliverAppBar(
              surfaceTintColor: AppColors.darkGrey,
              backgroundColor: AppColors.darkGrey,
              expandedHeight: MediaQuery.of(context).size.height * 0.15,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              elevation: 4,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  color: AppColors.darkGrey,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTitleFromDate(displayDateTimeStart,
                                    displayDateTimeEnd, middleMonthDate),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        mixpanel!.track('brand_calendar_today');
                                        setState(() {
                                          //_controller.selectedDate = DateTime.now();
                                          _controller.displayDate =
                                              DateTime.now().subtract(
                                                  const Duration(hours: 1));
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.white,
                                      ),
                                      child: Text(context.l10n.todayString,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  color: AppColors.white),
                                          textAlign: TextAlign.center),
                                    ),
                                    SizedBox(
                                      height: iconSize,
                                      width: iconSize,
                                      child: ClipOval(
                                        child: Material(
                                          color: hasFilter
                                              ? AppColors.white
                                              : Colors
                                                  .transparent, // Button color
                                          child: InkWell(
                                            splashColor: Theme.of(context)
                                                .colorScheme
                                                .background, // Splash color
                                            onTap: () => onTapFilterIcon,
                                            child: SizedBox(
                                              width: iconSize,
                                              height: iconSize,
                                              child: Icon(
                                                Icons.filter_list,
                                                color: hasFilter
                                                    ? AppColors.darkGrey
                                                    : AppColors.white,
                                                size: iconSize,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          Container(
                            color: AppColors.grey,
                            height: 1.0,
                          ),
                        ],
                      ),
                      const LinearProgressIndicatorWidget(),
                    ],
                  ),
                ),
                titlePadding: EdgeInsets.zero,
                //centerTitle: true,
              ),
              centerTitle: false,
              leading: Builder(
                builder: (BuildContext innerContext) => IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: iconSize,
                    ),
                    onPressed: () =>
                        navigationDrawerKey.currentState?.openDrawer()),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    askSupport(context),
                    unreadNotifications(context),
                    unreadChats(context),
                    profileImage(context),
                  ],
                ),
              ],
            ),
            BlocBuilder<BrandEventsCubit, BrandEventsState>(
              builder: (context, state) {
                switch (state.runtimeType) {
                  case BrandEventsLoaded:
                    if (isLoading == false) {
                      // Handle loaded state
                      BrandEventsLoaded loadedState =
                          state as BrandEventsLoaded;
                      return SliverFillRemaining(
                          child: GestureDetector(
                        onScaleStart: (ScaleStartDetails scaleStartDetails) {
                          _baseTimeSlotViewScale = _timeSlotViewScale;
                        },
                        onScaleUpdate: _controller.view == CalendarView.week ||
                                _controller.view == CalendarView.day
                            ? (ScaleUpdateDetails scaleUpdateDetails) {
                                // don't update the UI if the scale didn't change
                                if (scaleUpdateDetails.scale == 1.0) {
                                  return;
                                }
                                setState(() {
                                  _timeSlotViewScale = (_baseTimeSlotViewScale *
                                          scaleUpdateDetails.scale)
                                      .clamp(1, 4);
                                  _timeSlotViewZoom = _timeSlotViewScale *
                                      _baseTimeSlotViewZoom;
                                });
                              }
                            : null,
                        onScaleEnd: (ScaleEndDetails scaleEndDetails) {
                          _userDataService.updateUserZoomScale(widget.brandId,
                              currentUser.id!, _timeSlotViewScale);
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            SfCalendarTheme(
                              data: SfCalendarThemeData(
                                brightness: Brightness.dark,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                todayHighlightColor:
                                    Theme.of(context).primaryColor,
                                todayBackgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              child: SfCalendar(
                                // Controller
                                controller: _controller,
                                blackoutDates: [dateJoined],
                                blackoutDatesTextStyle: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600),
                                // Data
                                minDate: dateJoined,
                                dataSource: _getCalendarDataSource(
                                    loadedState.brandEventsList),
                                specialRegions: _getTimeRegions(),
                                // Config
                                cellEndPadding: 0,
                                firstDayOfWeek: 1,
                                showCurrentTimeIndicator: true,
                                cellBorderColor: AppColors.grey,
                                todayTextStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                // Style
                                selectionDecoration: _controller.view ==
                                        CalendarView.month
                                    ? BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.transparent),
                                      )
                                    : BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.08),
                                        border: Border.all(
                                            width: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                headerHeight: 0,
                                headerStyle: CalendarHeaderStyle(
                                  textAlign: TextAlign.center,
                                  backgroundColor: Colors.transparent,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: Colors.transparent),
                                ),
                                viewHeaderHeight: 50,
                                viewHeaderStyle: ViewHeaderStyle(
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  dateTextStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                  dayTextStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 10),
                                ),
                                // Time Slot View Settings
                                timeSlotViewSettings: TimeSlotViewSettings(
                                  timeIntervalHeight: _timeSlotViewZoom,
                                  timeIntervalWidth: 60,
                                  startHour: _startHour! != 0
                                      ? _startHour! - 1
                                      : _startHour!,
                                  endHour: _endHour! != 24
                                      ? _endHour! + 1
                                      : _endHour!,
                                  timeFormat: 'HH:mm',
                                  dayFormat: 'EE',
                                  dateFormat: 'd',
                                  timeRulerSize: 50,
                                  //nonWorkingDays: _controller.view == CalendarView.week && isThreeDays ? [DateTime.friday, DateTime.saturday, DateTime.sunday] : nonWorkDays,
                                  nonWorkingDays: nonWorkDays,
                                  minimumAppointmentDuration:
                                      const Duration(minutes: 30),
                                  timeTextStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                                // Monthly View
                                monthViewSettings: MonthViewSettings(
                                  appointmentDisplayCount: 4,
                                  numberOfWeeksInView: 6,
                                  showTrailingAndLeadingDates: true,
                                  appointmentDisplayMode:
                                      MonthAppointmentDisplayMode.appointment,
                                  monthCellStyle: MonthCellStyle(
                                    textStyle:
                                        Theme.of(context).textTheme.bodyLarge,
                                    trailingDatesTextStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(color: AppColors.grey),
                                    leadingDatesTextStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(color: AppColors.grey),
                                  ),
                                ),
                                // Schedule View
                                scheduleViewSettings: ScheduleViewSettings(
                                    hideEmptyScheduleWeek: true,
                                    appointmentItemHeight:
                                        MediaQuery.of(context).size.height *
                                            0.12,
                                    appointmentTextStyle:
                                        Theme.of(context).textTheme.bodyMedium,
                                    dayHeaderSettings: DayHeaderSettings(
                                      dateTextStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      dayTextStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontSize: 10),
                                    ),
                                    weekHeaderSettings: WeekHeaderSettings(
                                      startDateFormat: 'd',
                                      endDateFormat: 'd MMMM',
                                      textAlign: TextAlign.start,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      weekTextStyle:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    monthHeaderSettings: MonthHeaderSettings(
                                      monthFormat: 'MMMM yyyy',
                                      height: 70,
                                      textAlign: TextAlign.start,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      monthTextStyle: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    )),
                                scheduleViewMonthHeaderBuilder: (BuildContext
                                        buildContext,
                                    ScheduleViewMonthHeaderDetails details) {
                                  return Container(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            MediaQuery.of(context).size.width *
                                                0.03,
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          StringUtils()
                                              .toCapitalized(DateFormat(
                                            'MMMM yyyy',
                                            Localizations.localeOf(context)
                                                .languageCode,
                                          ).format(details.date)),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onViewChanged: (ViewChangedDetails
                                    viewChangedDetails) async {
                                  Future.delayed(Duration.zero, () async {
                                    setState(() {
                                      int indexMiddleMonthDate =
                                          ((viewChangedDetails
                                                      .visibleDates.length -
                                                  1) ~/
                                              2);
                                      middleMonthDate = viewChangedDetails
                                          .visibleDates[indexMiddleMonthDate];
                                      displayDateTimeStart =
                                          viewChangedDetails.visibleDates[0];
                                      displayDateTimeEnd = viewChangedDetails
                                          .visibleDates[viewChangedDetails
                                              .visibleDates.length -
                                          1];
                                    });
                                  });
                                  List<Event> eventsList =
                                      loadedState.brandEventsList;
                                  if (eventsList.isNotEmpty) {
                                    var startDateLastEvent = DateTime(
                                      int.parse(eventsList.first.year!),
                                      int.parse(eventsList.first.month!),
                                      int.parse(eventsList.first.day!),
                                      int.parse(eventsList.first.hour!),
                                      int.parse(eventsList.first.minute!),
                                    );
                                    if (viewChangedDetails.visibleDates[0]
                                            .difference(startDateLastEvent)
                                            .inDays <
                                        60) {
                                      context
                                          .read<BrandEventsCubit>()
                                          .getMoreBrandEvents(
                                              eventsList.first.id!,
                                              _brandTrainers);
                                    }
                                  }
                                },
                                onTap: onTapCalendar,
                                appointmentTextStyle:
                                    Theme.of(context).textTheme.bodyMedium!,
                                appointmentBuilder: (BuildContext context,
                                    CalendarAppointmentDetails details) {
                                  return _buildEventContainer(
                                      details, loadedState.brandEventsList);
                                },
                              ),
                            ),
                            _controller.view == CalendarView.week ||
                                    _controller.view == CalendarView.day
                                ? Padding(
                                    padding: isAndroid
                                        ? EdgeInsets.symmetric(
                                            vertical: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.045)
                                        : EdgeInsets.symmetric(
                                            vertical: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04),
                                    child: Material(
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.0115),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                            "Zoom: ${(_timeSlotViewScale * 100).toStringAsFixed(0)} %",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(fontSize: 11),
                                            textAlign: TextAlign.center),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ));
                    } else {
                      // Handle all other states aka Loading or Initial
                      return SliverFillRemaining(
                        child: LoadingView(),
                      );
                    }
                  default:
                    // Handle all other states aka Loading or Initial
                    return SliverFillRemaining(
                      child: LoadingView(),
                    );
                }
              },
            ),
          ],
        ),
        floatingActionButton: whichFloatingActionButton());
  }

  Widget whichFloatingActionButton() {
    return canEdit
        ? Padding(
            padding: isAndroid
                ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
                : const EdgeInsets.all(10),
            child: SizedBox(
              height: MediaQuery.of(context).size.width * 0.15,
              width: MediaQuery.of(context).size.width * 0.15,
              child: SpeedDial(
                heroTag: "46",
                animatedIcon: AnimatedIcons.add_event,
                animationDuration: const Duration(milliseconds: 300),
                foregroundColor: AppColors.white,
                overlayColor: Theme.of(context).scaffoldBackgroundColor,
                overlayOpacity: 0.95,
                spacing: MediaQuery.of(context).size.height * 0.02,
                spaceBetweenChildren: MediaQuery.of(context).size.height * 0.02,
                openCloseDial: isDialOpen,
                children: [
                  SpeedDialChild(
                      child: const Icon(
                        Icons.groups,
                      ),
                      elevation: 10,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      labelWidget: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.05),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(context.l10n.groupEvent,
                                style: Theme.of(context).textTheme.displaySmall,
                                textAlign: TextAlign.right),
                            Text(context.l10n.groupEventDesc,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.right),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (context.read<CrudEventCubit>().state.isWorking >=
                            100) {
                          DateTime? eventDate = DateTime.now();
                          if (_controller.selectedDate != null) {
                            eventDate = _controller.selectedDate;
                          }
                          _addEvent(eventDate!, false);
                        } else {
                          _topSnackBar.showSnackBarTop(context,
                              context.l10n.processOnWork, AppColors.red);
                        }
                      }),
                  SpeedDialChild(
                      child: const Icon(
                        Icons.person,
                      ),
                      elevation: 10,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      labelWidget: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.05),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(context.l10n.privateEvent,
                                style: Theme.of(context).textTheme.displaySmall,
                                textAlign: TextAlign.right),
                            Text(context.l10n.privateEventDesc,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.right),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (context.read<CrudEventCubit>().state.isWorking >=
                            100) {
                          DateTime? eventDate = DateTime.now();
                          if (_controller.selectedDate != null) {
                            eventDate = _controller.selectedDate;
                          }
                          _addEvent(eventDate!, true);
                        } else {
                          _topSnackBar.showSnackBarTop(context,
                              context.l10n.processOnWork, AppColors.red);
                        }
                      }),
                ],
              ),
            ),
          )
        : Container();
  }

  List<TimeRegion> _getTimeRegions() {
    final List<TimeRegion> regions = <TimeRegion>[];
    // Breaks
    for (var i = 2; i < _brand.workShift.length; i += 2) {
      var start = _brand.workShift[i];
      var startHour = int.parse(start.toStringAsFixed(2).split(".")[0]);
      var startMin = int.parse(start.toStringAsFixed(2).split(".")[1]);
      var end = _brand.workShift[i + 1];
      var endHour = int.parse(end.toStringAsFixed(2).split(".")[0]);
      var endMin = int.parse(end.toStringAsFixed(2).split(".")[1]);
      DateTime inActiveHoursStart = DateTime(dateJoined.year, dateJoined.month,
          dateJoined.day - 7, startHour, startMin, 0);
      DateTime inActiveHoursEnd = DateTime(dateJoined.year, dateJoined.month,
          dateJoined.day - 7, endHour, endMin, 0);
      regions.add(TimeRegion(
        enablePointerInteraction: false,
        startTime: inActiveHoursStart,
        endTime: inActiveHoursEnd,
        color: Colors.grey.withOpacity(0.3),
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
      ));
    }
    // Hora Inactiva Matí
    var startHourWS =
        int.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    var startMinWS =
        int.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[1]);
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day - 7,
          startHourWS - 1, 0, 0),
      endTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day - 7,
          startHourWS, startMinWS, 0),
      color: Colors.grey.withOpacity(0.3),
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
    ));
    // Hora Inactiva Nit
    var endHourWS =
        int.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);
    var endMinWS =
        int.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[1]);
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day - 7,
          endHourWS, endMinWS, 0),
      endTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day - 7,
          endHourWS + 1, 0, 0),
      color: Colors.grey.withOpacity(0.3),
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
    ));
    return regions;
  }

  Color getColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return Theme.of(context).colorScheme.secondary;
    } else {
      return Colors.transparent;
    }
  }

  Widget timeRegionBuilder(
      BuildContext context, TimeRegionDetails timeRegionDetails) {
    return Container(
      color: const Color(0x40B5B5B5),
    );
  }

  AppointmentDataSource _getCalendarDataSource(List<Event> eventsList) {
    List<Appointment> tempAllAppointments = [];
    List<String> selectedTrainersIDs = [];
    for (var trainer in selectedTrainers) {
      selectedTrainersIDs.add(trainer.id!);
    }
    for (var i = 0; i < eventsList.length; i++) {
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
      var endDate = startDate
          .add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
      // Subject
      String subject;
      Color color = Colors.black;
      if (event.isPrivate!) {
        subject = "${event.numClients}";
        if (endDate.isAfter(DateTime.now())) {
          color = Colors.black;
        } else {
          color = Colors.black.withOpacity(0.7);
        }
      } else {
        subject = "${event.numClients}/${event.maxMembers}";
        // Colors
        double numClients = double.parse(event.numClients.toString());
        double maxMembers = double.parse(event.maxMembers.toString());
        double bookedCapacity = numClients / maxMembers;
        if (bookedCapacity <= 0.20) {
          if (endDate.isAfter(DateTime.now())) {
            color = Colors.green;
          } else {
            color = Colors.green.withOpacity(0.5);
          }
        } else if (bookedCapacity > 0.20 && bookedCapacity <= 0.40) {
          if (endDate.isAfter(DateTime.now())) {
            color = const Color(0xFFA8C76C);
          } else {
            color = const Color(0xFFA8C76C).withOpacity(0.5);
          }
        } else if (bookedCapacity > 0.40 && bookedCapacity <= 0.60) {
          if (endDate.isAfter(DateTime.now())) {
            color = const Color(0xFFECE014);
          } else {
            color = const Color(0xFFECE014).withOpacity(0.5);
          }
        } else if (bookedCapacity > 0.60 && bookedCapacity <= 0.80) {
          if (endDate.isAfter(DateTime.now())) {
            color = Colors.orangeAccent;
          } else {
            color = Colors.orangeAccent.withOpacity(0.5);
          }
        } else if (bookedCapacity > 0.80 && bookedCapacity < 1) {
          if (endDate.isAfter(DateTime.now())) {
            color = Colors.deepOrangeAccent;
          } else {
            color = Colors.deepOrangeAccent.withOpacity(0.6);
          }
        } else if (bookedCapacity >= 1) {
          if (endDate.isAfter(DateTime.now())) {
            color = Colors.red;
          } else {
            color = Colors.red.withOpacity(0.6);
          }
        }
      }
      // Only If Selected Trainers
      if (event.usersList.isNotEmpty) {
        int index = event.usersList
            .indexWhere((element) => selectedTrainersIDs.contains(element.id!));
        if (index != -1) {
          if (filterEventsNumber == 1) {
            // Show Only Group Events
            if (event.isPrivate == false) {
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
          } else if (filterEventsNumber == 2) {
            // Show Only Group Events
            if (event.isPrivate == true) {
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
          } else {
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
        }
      } else {
        getNewEventMemberDetails(event);
        if (filterEventsNumber == 1) {
          // Show Only Group Events
          if (event.isPrivate == false) {
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
        } else if (filterEventsNumber == 2) {
          // Show Only Group Events
          if (event.isPrivate == true) {
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
        } else {
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
      }
      //
    }
    return AppointmentDataSource(tempAllAppointments);
  }

  void onTapCalendar(CalendarTapDetails details) async {
    // Action Depending on View
    if (_controller.view == CalendarView.day) {
      // Select the Date If Possible
      _controller.selectedDate = details.date;
    } else if (_controller.view == CalendarView.week) {
      // Select the Date If Possible
      selectedValue = '1';
      _controller.view = CalendarView.day;
      _controller.selectedDate = details.date;
      setState(() {
        _controller.displayDate =
            details.date!.subtract(const Duration(hours: 1));
      });
    } else if (_controller.view == CalendarView.month) {
      _controller.displayDate = details.date;
      _controller.view = CalendarView.day;
      selectedValue = '1';
    } else if (_controller.view == CalendarView.schedule) {}
  }

  void onTapFilterIcon(CalendarTapDetails details) async {
    await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        // Page View Controller
        final PageController pageController = PageController(initialPage: 0);
        int currentPage = 0;
        bool isTypeEvent = true;
        List<Usuario> selectedTrainersBottom = List.from(selectedTrainers);
        // Widget
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateBottom) {
            return FractionallySizedBox(
              heightFactor: 0.33,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(context.l10n.filterBy,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.left),
                        trailing: TextButton(
                            child: Text(context.l10n.clear,
                                style: Theme.of(context).textTheme.bodySmall),
                            onPressed: () {
                              setStateBottom(() {
                                filterByCalendar = [true, true];
                                selectedTrainers = List.from(_brandTrainers);
                              });
                              // Navigator Pop
                              Navigator.pop(context);
                            }),
                        dense: true,
                        onTap: currentPage == 0
                            ? null
                            : () {
                                pageController.previousPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.21,
                        width: MediaQuery.of(context).size.width,
                        child: PageView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: pageController,
                          onPageChanged: (int page) {
                            setStateBottom(() {
                              currentPage = page;
                            });
                          },
                          children: <Widget>[
                            Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    setStateBottom(() {
                                      isTypeEvent = true;
                                    });
                                    pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  },
                                  title: Text(
                                      "${context.l10n.typeProfile.split(" ")[0]} ${context.l10n.typeProfile.split(" ")[1]} ${context.l10n.events.toLowerCase()}",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.left),
                                  subtitle: Text(returnFilteredRolesString(),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.left),
                                  trailing: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Center(
                                        child: Icon(Icons.arrow_forward_ios,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            color: AppColors.grey)),
                                  ),
                                ),
                                ListTile(
                                  onTap: () {
                                    setStateBottom(() {
                                      isTypeEvent = false;
                                    });
                                    pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  },
                                  title: Text(context.l10n.trainers,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.left),
                                  subtitle: Text(
                                    returnFilteredStaffMembersString(),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Center(
                                        child: Icon(Icons.arrow_forward_ios,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            color: AppColors.grey)),
                                  ),
                                ),
                              ],
                            ),
                            isTypeEvent
                                ? Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          // Check if the Only True
                                          var filterActive =
                                              List.from(filterByCalendar);
                                          filterActive.retainWhere(
                                              (element) => element == true);
                                          if (!(filterActive.length == 1 &&
                                              filterByCalendar[0])) {
                                            filterByCalendar[0] =
                                                !filterByCalendar[0];
                                            // Navigator Pop
                                            Navigator.pop(context);
                                          }
                                        },
                                        title: Text(context.l10n.groupEvent,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                            textAlign: TextAlign.left),
                                        trailing: filterByCalendar[0]
                                            ? SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.15,
                                                child: Center(
                                                    child: Icon(Icons.check,
                                                        size: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.08,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary)),
                                              )
                                            : SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.15),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          // Check if the Only True
                                          var filterActive =
                                              List.from(filterByCalendar);
                                          filterActive.retainWhere(
                                              (element) => element == true);
                                          if (!(filterActive.length == 1 &&
                                              filterByCalendar[1])) {
                                            filterByCalendar[1] =
                                                !filterByCalendar[1];
                                            // Navigator Pop
                                            Navigator.pop(context);
                                          }
                                        },
                                        title: Text(context.l10n.privateEvent,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                            textAlign: TextAlign.left),
                                        trailing: filterByCalendar[1]
                                            ? SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.15,
                                                child: Center(
                                                    child: Icon(Icons.check,
                                                        size: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.08,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary)),
                                              )
                                            : SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.15),
                                      ),
                                    ],
                                  )
                                : Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.21,
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.04),
                                    child: GridView.builder(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 3.5,
                                          crossAxisSpacing: 15,
                                          mainAxisSpacing: 15.0,
                                        ),
                                        itemCount: _brandTrainers.length,
                                        itemBuilder: (context, int index) {
                                          var trainer = _brandTrainers[index];
                                          return GestureDetector(
                                            onTap: () {
                                              setStateBottom(() {
                                                if (selectedTrainersBottom
                                                    .contains(trainer)) {
                                                  if (selectedTrainersBottom
                                                          .length >
                                                      1) {
                                                    selectedTrainersBottom
                                                        .remove(trainer);
                                                    selectedTrainers
                                                        .remove(trainer);
                                                    // Navigator Pop
                                                    Navigator.pop(context);
                                                  }
                                                } else {
                                                  selectedTrainersBottom
                                                      .add(trainer);
                                                  selectedTrainers.add(trainer);
                                                  // Navigator Pop
                                                  Navigator.pop(context);
                                                }
                                              });
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  CircularImage(
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.1,
                                                    image: trainer.imageUrl,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    borderWidth: 1.0,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      "${trainer.firstName!} ${trainer.lastName![0]}.",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      maxLines: 1,
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.06,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.06,
                                                    child: MaterialButton(
                                                      elevation: 4,
                                                      color: selectedTrainersBottom
                                                              .contains(trainer)
                                                          ? context.colorScheme
                                                              .secondary
                                                          : Theme.of(context)
                                                              .scaffoldBackgroundColor,
                                                      textColor: selectedTrainersBottom
                                                              .contains(trainer)
                                                          ? context.colorScheme
                                                              .secondary
                                                          : Theme.of(context)
                                                              .scaffoldBackgroundColor,
                                                      padding: EdgeInsets.zero,
                                                      shape:
                                                          const CircleBorder(),
                                                      onPressed: () {
                                                        setStateBottom(() {
                                                          if (selectedTrainersBottom
                                                              .contains(
                                                                  trainer)) {
                                                            if (selectedTrainersBottom
                                                                    .length >
                                                                1) {
                                                              selectedTrainersBottom
                                                                  .remove(
                                                                      trainer);
                                                              selectedTrainers
                                                                  .remove(
                                                                      trainer);
                                                              // Navigator Pop
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          } else {
                                                            selectedTrainersBottom
                                                                .add(trainer);
                                                            selectedTrainers
                                                                .add(trainer);
                                                            // Navigator Pop
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        });
                                                      },
                                                      child: selectedTrainersBottom
                                                              .contains(trainer)
                                                          ? Icon(Icons.check,
                                                              color: AppColors
                                                                  .white,
                                                              size: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.04)
                                                          : SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.03,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.03,
                                                            ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        // Filter By Type Of Events
        if (filterByCalendar[0] && filterByCalendar[1]) {
          // Group/Private Selected
          hasFilter = false;
          filterEventsNumber = 0;
        } else if (filterByCalendar[0]) {
          // Group Selected
          filterEventsNumber = 1;
          hasFilter = true;
        } else if (filterByCalendar[1]) {
          // Private Selected
          filterEventsNumber = 2;
          hasFilter = true;
        }
        // Filter By Staff Members
        if (filterByCalendar[0] && filterByCalendar[1]) {
          if (selectedTrainers.length == _brandTrainers.length) {
            hasFilter = false;
          } else {
            hasFilter = true;
          }
        }
      });
    });
  }

  void onLongPressCalendar(CalendarLongPressDetails details) async {
    // Action Depending on View
    if (_controller.view == CalendarView.day) {
      // Select the Date If Possible
      if (details.date!.isAfter(DateTime.now()) && canEdit) {
        setState(() {
          _controller.selectedDate = details.date;
          isDialOpen.value = true;
        });
      }
    } else if (_controller.view == CalendarView.week) {
      // Select the Date If Possible
      if (details.date!.isAfter(DateTime.now()) && canEdit) {
        setState(() {
          _controller.selectedDate = details.date;
          isDialOpen.value = true;
        });
      }
    } else if (_controller.view == CalendarView.month) {
    } else if (_controller.view == CalendarView.schedule) {}
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
