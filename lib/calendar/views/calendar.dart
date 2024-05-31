import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:mamba/calendar/cubit/calendar_bloc.dart';
import 'package:mamba/calendar/widgets/calendar_action_button.dart';
import 'package:mamba/calendar/widgets/calendar_view_dropdown.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/theme_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/mixins/string.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/read_event/views/mobile/ReadEventPage.dart';
import 'package:mamba/events/crud_events/views/mobile/AddorEdtiEvent.dart';
import 'package:mamba/events/crud_events/widgets/mobile/LinearProgressIndicator.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/home/widgets/appbar/AppBarIcon.dart';
import 'package:mamba/home/widgets/appbar/ResponsiveSliverAppBar.dart';
import 'package:mamba/snackbar/cubit/snackbar_cubit.dart';
import 'package:mamba/snackbar/models/custom_snackbar.dart';
import 'package:mamba/snackbar/models/snackbar_type.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
  });

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with PlatformMixin, StringMixin {
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset >
            (MediaQuery.of(context).size.height * 0.25 - kToolbarHeight);
  }

  // Calendar Controller
  final CalendarController _calendarController = CalendarController();

  // Zoom Gesture Detector
  double _timeSlotViewZoom = -1;
  double _baseTimeSlotViewZoom = -1;
  double _timeSlotViewScale = 1;
  double _baseTimeSlotViewScale = 1;

  @override
  void initState() {
    super.initState();
    // Scroll Controller for Mobile App Bar
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
    // Start Week View
    _calendarController.view = CalendarView.week;
  }

  // Add Event / Navigate To Event Functions

  void onCreateEventTap(bool isPrivate) {
    if (context.read<CrudEventCubit>().state.isWorking >= 100) {
      DateTime? eventDate = DateTime.now();
      if (_calendarController.selectedDate != null) {
        eventDate = _calendarController.selectedDate;
      }
      _addEvent(eventDate!, isPrivate);
    } else {
      CustomSnackbar snackbar = CustomSnackbar(
        type: SnackbarType.error,
        message: context.l10n.processOnWork,
      );
      context.read<SnackbarCubit>().enqueueSnackbarAction(snackbar);
    }
  }

  Future<void> _addEvent(DateTime dateTime, bool isPrivate) async {
    context.read<CrudEventCubit>().resetNewEvent();
    context.read<CrudEventCubit>().createNewEvent(dateTime, isPrivate);
    if (!brandIsActive) {
      await navigateToPayWall(context);
    } else {
      mixpanel!.track('brand_calendar_plan_event',
          properties: {'isPrivate': isPrivate});
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
      'Calendar View': _calendarController.view.toString(),
      'isCompleted': isCompleted
    });
    // Navigate to Event Screen
    await Navigator.push(
      context,
      CupertinoPageRoute<bool?>(
        builder: (context) => EventPage(
          eventId: eventId,
        ),
      ),
    );
    // TO DO: Asegurar el Update/Delete correcte que he borrat el codi
  }

  //// UI Interaction Functions ////////////////////////////////////////////////////

  void onCalendarStart(double difference, double userZoomScale) {
    // The goal of this function is to calculate the height of each HOUR in the calendar. This is calculated depending on the numbers of avaiable hours (HORARI).
    double adjustedHeight;
    // Full screen height
    double screenHeight = context.height;
    // Expanded Height of AppBar
    double expandedHeight =
        context.height * 0.15 + MediaQuery.of(context).padding.top;
    if (context.isDesktop) {
      expandedHeight = desktopAppBarHeight + MediaQuery.of(context).padding.top;
    }
    // View Header Height Calendar
    double viewHeaderHeight = 50;
    if (context.isDesktop) {
      viewHeaderHeight = 70;
    }
    // We're using TargetPlatform to determine the type of device
    adjustedHeight = screenHeight - expandedHeight - viewHeaderHeight;
    _baseTimeSlotViewZoom = adjustedHeight / difference;
    // Make User Call to Get Exact Scale
    setState(() {
      _timeSlotViewScale = userZoomScale;
    });
    // Setting the Height of each TimeSlot
    _timeSlotViewZoom = _timeSlotViewScale * _baseTimeSlotViewZoom;
  }

  void onScaleStart(ScaleStartDetails scaleStartDetails) {
    _baseTimeSlotViewScale = _timeSlotViewScale;
  }

  void onScaleUpdate(ScaleUpdateDetails scaleUpdateDetails) {
    if (_calendarController.view == CalendarView.week ||
        _calendarController.view == CalendarView.day) {
      if (scaleUpdateDetails.scale == 1.0) {
        return;
      }
      setState(() {
        _timeSlotViewScale =
            (_baseTimeSlotViewScale * scaleUpdateDetails.scale).clamp(1, 4);
        _timeSlotViewZoom = _timeSlotViewScale * _baseTimeSlotViewZoom;
      });
    }
  }

  void onScaleEnd(ScaleEndDetails scaleEndDetails) {
    context.read<CalendarBloc>().updateUserZoomScale(_timeSlotViewScale);
  }

  void onManualScaleUpdate(bool zoom) {
    if (zoom) {
      _timeSlotViewScale += 0.25;
    } else {
      _timeSlotViewScale -= 0.25;
    }
    setState(() {
      _timeSlotViewZoom = _timeSlotViewScale * _baseTimeSlotViewZoom;
    });
    context.read<CalendarBloc>().updateUserZoomScale(_timeSlotViewScale);
  }

  void onCalendarViewChanged(CalendarView newView) {
    setState(() {
      _calendarController.view = newView;
    });
  }

  void onCalendarDateChanged(ViewChangedDetails viewChangedDetails) {
    context.read<CalendarBloc>().onViewChanged(viewChangedDetails.visibleDates);
  }

  void onTapToday() {
    _calendarController.displayDate =
        DateTime.now().subtract(const Duration(hours: 1));
  }

  void onTapForward() {
    _calendarController.forward!();
  }

  void onTapBackward() {
    _calendarController.backward!();
  }

  void onTapCalendar(CalendarTapDetails details) async {
    // Action Depending on View
    if (_calendarController.view == CalendarView.day) {
      // Select the Date If Possible
      _calendarController.selectedDate = details.date;
    } else if (_calendarController.view == CalendarView.week) {
      // Select the Date If Possible
      _calendarController.view = CalendarView.day;
      _calendarController.selectedDate = details.date;
      setState(() {
        _calendarController.displayDate =
            details.date!.subtract(const Duration(hours: 1));
      });
    } else if (_calendarController.view == CalendarView.month) {
      _calendarController.displayDate = details.date;
      _calendarController.view = CalendarView.day;
    } else if (_calendarController.view == CalendarView.schedule) {}
  }

  void onLongPressCalendar(
      CalendarLongPressDetails details, bool canEdit) async {
    // Action Depending on View
    if (_calendarController.view == CalendarView.day) {
      // Select the Date If Possible
      if (details.date!.isAfter(DateTime.now()) && canEdit) {
        setState(() {
          _calendarController.selectedDate = details.date;
          //isDialOpen.value = true;
        });
      }
    } else if (_calendarController.view == CalendarView.week) {
      // Select the Date If Possible
      if (details.date!.isAfter(DateTime.now()) && canEdit) {
        setState(() {
          _calendarController.selectedDate = details.date;
          //isDialOpen.value = true;
        });
      }
    } else if (_calendarController.view == CalendarView.month) {
    } else if (_calendarController.view == CalendarView.schedule) {}
  }

////// UI Interaction Functions ////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      listener: (context, state) {
        if (state is CalendarLoaded) {
          onCalendarStart(
            state.difference,
            state.timeSlotViewScale,
          );
        }
      },
      builder: (context, state) {
        if (state is CalendarLoaded) {
          return Scaffold(
            body: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _scrollController,
              slivers: [
                if (context.isMobile || context.isTablet) ...[
                  // Mobile / Table App Bar
                  ResponsiveSliverAppBar(
                    height: context.height * 0.15,
                    title: context.l10n.bookings,
                    appBarExpanded: appBarExpanded,
                    flexibleSpace:
                        returnFlexibleSpaceBar(context.height * 0.15),
                  ),
                  // Mobile Body
                  SliverFillRemaining(
                    child: GestureDetector(
                      onScaleStart: onScaleStart,
                      onScaleUpdate: onScaleUpdate,
                      onScaleEnd: onScaleEnd,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          calendarWidget(state),
                          //zoomWidget(),
                        ],
                      ),
                    ),
                  )
                ] else ...[
                  // Desktop App Bar
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        AppBar(
                          foregroundColor: context.colorScheme.background,
                          backgroundColor: context.colorScheme.background,
                          toolbarHeight: desktopAppBarHeight,
                          title: Row(
                            children: [
                              TextButton(
                                onPressed: onTapToday,
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      context.colorScheme.background,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: defaultPadding,
                                      vertical: defaultPaddingSmall),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: context.theme.dividerColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      borderRadiusSmall,
                                    ),
                                  ),
                                  minimumSize: const Size(80, 45),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  context.l10n.todayString,
                                  style: context.textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: defaultPadding),
                              AppBarIcon(
                                icon: Icons.chevron_left,
                                iconSize: iconSize,
                                color: context.colorScheme.onBackground,
                                onTap: onTapBackward,
                              ),
                              AppBarIcon(
                                icon: Icons.chevron_right,
                                iconSize: iconSize,
                                color: context.colorScheme.onBackground,
                                onTap: onTapForward,
                              ),
                              SizedBox(width: defaultPadding),
                              Text(
                                state.calendarTitle,
                                style: context.textTheme.bodyLarge
                                    ?.copyWith(fontSize: headline1),
                              ),
                            ],
                          ),
                          centerTitle: false,
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppBarIcon(
                                  icon: Icons.filter_list,
                                  iconSize: iconSize,
                                  color: context.colorScheme.onBackground,
                                  onTap: () {},
                                ),
                                SizedBox(width: defaultPadding),
                                CalendarViewDropdown(
                                  view: _calendarController.view!,
                                  onViewChanged: onCalendarViewChanged,
                                  zoom: _timeSlotViewScale,
                                  onZoomToogled: onManualScaleUpdate,
                                ),
                                SizedBox(width: defaultPadding),
                                AppBarIcon(
                                  icon: Icons.help_outline_outlined,
                                  iconSize: iconSize,
                                  color: context.colorScheme.onBackground,
                                  onTap: () =>
                                      navigateToMainFeedbackScreen(context),
                                ),
                                AppBarIcon(
                                  icon: Icons.notifications,
                                  iconSize: iconSize,
                                  color: context.colorScheme.onBackground,
                                  onTap: () =>
                                      navigateToNotificationsScreen(context),
                                ),
                                AppBarIcon(
                                  icon: Icons.chat,
                                  iconSize: iconSize,
                                  color: context.colorScheme.onBackground,
                                  onTap: () => navigateToChatScreen(context),
                                ),
                                InkWell(
                                  onTap: () => navigateToProfileScreen(context),
                                  hoverColor: context.colorScheme.onBackground
                                      .withOpacity(0.2),
                                  splashColor: context.colorScheme.onBackground
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                    24,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      8,
                                    ),
                                    child: SizedBox(
                                      height: iconSize,
                                      child: Center(
                                        child: CircularImage(
                                          size: iconSize,
                                          image: currentUser.imageUrl,
                                          color: context.theme.primaryColor,
                                          borderWidth: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: defaultPadding)
                              ],
                            ),
                          ],
                        ),
                        Divider(
                          color: context.theme.dividerColor,
                          thickness: 1,
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                  // Desktop Body
                  SliverFillRemaining(
                    child: Row(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              calendarWidget(state),
                              //zoomWidget(),
                            ],
                          ),
                        ),
                        /*
                        if (selectedEventId != null)
                          Row(
                            children: [
                              VerticalDivider(
                                indent: desktopAppBarHeight,
                                color: context.theme.dividerColor,
                                thickness: 1,
                                width: 1,
                              ),
                              SizedBox(
                                width: sideMenuWidth,
                                child: EventPage(
                                  eventId: selectedEventId!,
                                ),
                              ),
                            ],
                          ),
                        */
                      ],
                    ),
                  ),
                ],
              ],
            ),
            floatingActionButton: CalendarActionButton(
              timeSlotViewScale: _timeSlotViewScale,
              calendarView: _calendarController.view!,              
              onCreateEventTap: onCreateEventTap,
            ),
          );
        } else {
          return Scaffold(
            body: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _scrollController,
              slivers: [
                if (context.isMobile || context.isTablet) ...[
                  // Mobile / Table App Bar
                  ResponsiveSliverAppBar(
                    height: context.height * 0.15,
                    title: context.l10n.bookings,
                    appBarExpanded: appBarExpanded,
                    flexibleSpace:
                        returnFlexibleSpaceBar(context.height * 0.15),
                  )
                ] else ...[
                  // Desktop App Bar
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        AppBar(
                          foregroundColor: context.colorScheme.background,
                          backgroundColor: context.colorScheme.background,
                          toolbarHeight: desktopAppBarHeight,
                          title: Row(
                            children: [
                              TextButton(
                                onPressed: onTapToday,
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      context.colorScheme.background,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: defaultPadding,
                                      vertical: defaultPaddingSmall),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: context.theme.dividerColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      borderRadiusSmall,
                                    ),
                                  ),
                                  minimumSize: const Size(80, 45),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  context.l10n.todayString,
                                  style: context.textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: defaultPadding),
                              AppBarIcon(
                                icon: Icons.chevron_left,
                                iconSize: iconSize,
                                color: context.colorScheme.onBackground,
                                onTap: onTapBackward,
                              ),
                              AppBarIcon(
                                icon: Icons.chevron_right,
                                iconSize: iconSize,
                                color: context.colorScheme.onBackground,
                                onTap: onTapForward,
                              ),
                              SizedBox(width: defaultPadding),
                              Text(
                                "state.calendarTitle",
                                style: context.textTheme.bodyLarge
                                    ?.copyWith(fontSize: headline1),
                              ),
                            ],
                          ),
                          centerTitle: false,
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppBarIcon(
                                  icon: Icons.filter_list,
                                  iconSize: iconSize,
                                  color: context.colorScheme.onBackground,
                                  onTap: () {},
                                ),
                                SizedBox(width: defaultPadding),
                                CalendarViewDropdown(
                                  view: CalendarView.week,
                                  onViewChanged: onCalendarViewChanged,
                                  zoom: _timeSlotViewScale,
                                  onZoomToogled: onManualScaleUpdate,
                                ),
                                SizedBox(width: defaultPadding),
                                AppBarIcon(
                                  icon: Icons.help_outline_outlined,
                                  iconSize: iconSize,
                                  color: context.colorScheme.onBackground,
                                  onTap: () =>
                                      navigateToMainFeedbackScreen(context),
                                ),
                                AppBarIcon(
                                  icon: Icons.notifications,
                                  iconSize: iconSize,
                                  color: context.colorScheme.onBackground,
                                  onTap: () =>
                                      navigateToNotificationsScreen(context),
                                ),
                                AppBarIcon(
                                  icon: Icons.chat,
                                  iconSize: iconSize,
                                  color: context.colorScheme.onBackground,
                                  onTap: () => navigateToChatScreen(context),
                                ),
                                InkWell(
                                  onTap: () => navigateToProfileScreen(context),
                                  hoverColor: context.colorScheme.onBackground
                                      .withOpacity(0.2),
                                  splashColor: context.colorScheme.onBackground
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                    24,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      8,
                                    ),
                                    child: SizedBox(
                                      height: iconSize,
                                      child: Center(
                                        child: CircularImage(
                                          size: iconSize,
                                          image: currentUser.imageUrl,
                                          color: context.theme.primaryColor,
                                          borderWidth: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: defaultPadding)
                              ],
                            ),
                          ],
                        ),
                        Divider(
                          color: context.theme.dividerColor,
                          thickness: 1,
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                ],
                // Loading State
                SliverFillRemaining(
                  child: LoadingView(),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // WIDGETS

  Widget calendarWidget(CalendarLoaded state) {
    // BrandDate Joined
    DateTime dateJoined =
        DateFormat('dd-MM-yyyy').parse(state.brand.dateJoined!);
    return SfCalendarTheme(
      data: SfCalendarThemeData(
        // Background Colors
        brightness: context.read<ThemeManager>().isDarkMode
            ? Brightness.dark
            : Brightness.light,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        headerBackgroundColor: context.theme.scaffoldBackgroundColor,
        agendaBackgroundColor: context.theme.scaffoldBackgroundColor,
        cellBorderColor: context.theme.dividerColor,
        activeDatesBackgroundColor: context.theme.scaffoldBackgroundColor,
        todayBackgroundColor: context.theme.scaffoldBackgroundColor,
        trailingDatesBackgroundColor: context.theme.scaffoldBackgroundColor,
        leadingDatesBackgroundColor: context.theme.scaffoldBackgroundColor,
        selectionBorderColor: context.colorScheme.primary,
        todayHighlightColor: context.colorScheme.primary,
        viewHeaderBackgroundColor: context.colorScheme.background,
        weekNumberBackgroundColor: context.colorScheme.background,
        allDayPanelColor: context.colorScheme.background,
        // Text Styles
        todayTextStyle: context.textTheme.bodyLarge,
        agendaDayTextStyle: context.textTheme.bodyLarge,
        agendaDateTextStyle: context.textTheme.bodyLarge,
        headerTextStyle: context.textTheme.bodyLarge,
        viewHeaderDateTextStyle: context.textTheme.bodyLarge,
        viewHeaderDayTextStyle: context.textTheme.bodyLarge,
        timeTextStyle: context.textTheme.bodyLarge,
        activeDatesTextStyle: context.textTheme.bodyLarge,
        trailingDatesTextStyle: context.textTheme.bodyLarge,
        leadingDatesTextStyle: context.textTheme.bodyLarge,
        blackoutDatesTextStyle: context.textTheme.bodyLarge,
        displayNameTextStyle: context.textTheme.bodyLarge,
        weekNumberTextStyle: context.textTheme.bodyLarge,
        timeIndicatorTextStyle: context.textTheme.bodyLarge,
      ),
      child: SfCalendar(
        // Controller
        controller: _calendarController,
        // Blackout Dates
        blackoutDates: [dateJoined],
        blackoutDatesTextStyle: context.textTheme.titleMedium,
        showWeekNumber: false,
        weekNumberStyle: WeekNumberStyle(
          textStyle: context.textTheme.labelSmall,
        ),
        // Data
        minDate: dateJoined,
        dataSource: state.dataSource,
        specialRegions: state.specialRegions,
        // Config
        cellEndPadding: 0,
        firstDayOfWeek: 1,
        showCurrentTimeIndicator: true,
        cellBorderColor: AppColors.grey,
        todayTextStyle: context.textTheme.bodyLarge
            ?.copyWith(color: context.colorScheme.onPrimary),
        // Header
        headerHeight: 0,
        // View Header
        viewHeaderHeight: context.isDesktop ? 70 : 50,
        // Time Slot View Settings
        timeSlotViewSettings: TimeSlotViewSettings(
          timeIntervalHeight: _timeSlotViewZoom,
          timeIntervalWidth: 60,
          startHour:
              state.startHour != 0 ? state.startHour - 1 : state.startHour,
          endHour: state.endHour != 24 ? state.endHour + 1 : state.endHour,
          timeFormat: 'HH:mm',
          dayFormat: 'EE',
          dateFormat: 'd',
          timeRulerSize: 50,
          nonWorkingDays: const [],
          minimumAppointmentDuration: const Duration(minutes: 30),
          timeTextStyle: context.textTheme.bodyMedium,
        ),
        // Monthly View
        monthViewSettings: MonthViewSettings(
          appointmentDisplayCount: 4,
          numberOfWeeksInView: 6,
          showTrailingAndLeadingDates: true,
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          monthCellStyle: MonthCellStyle(
            textStyle: context.textTheme.bodyLarge,
            trailingDatesTextStyle:
                context.textTheme.bodyLarge?.copyWith(color: AppColors.grey),
            leadingDatesTextStyle:
                context.textTheme.bodyLarge?.copyWith(color: AppColors.grey),
          ),
        ),
        // Schedule View
        scheduleViewSettings: ScheduleViewSettings(
          hideEmptyScheduleWeek: true,
          appointmentItemHeight: MediaQuery.of(context).size.height * 0.12,
          appointmentTextStyle: context.textTheme.bodyMedium,
          dayHeaderSettings: DayHeaderSettings(
            dateTextStyle: context.textTheme.bodyMedium,
            dayTextStyle: context.textTheme.bodySmall,
          ),
          weekHeaderSettings: WeekHeaderSettings(
            startDateFormat: 'd',
            endDateFormat: 'd MMMM',
            textAlign: TextAlign.start,
            backgroundColor: context.theme.scaffoldBackgroundColor,
            weekTextStyle: context.textTheme.bodySmall,
          ),
          monthHeaderSettings: MonthHeaderSettings(
            monthFormat: month_year_dateformat,
            height: 70,
            textAlign: TextAlign.start,
            backgroundColor: context.theme.scaffoldBackgroundColor,
            monthTextStyle: context.textTheme.headlineMedium,
          ),
        ),
        scheduleViewMonthHeaderBuilder: (
          BuildContext context,
          ScheduleViewMonthHeaderDetails details,
        ) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              toCapitalized(
                DateFormat(
                  month_year_dateformat,
                  context.languageCode,
                ).format(details.date),
              ),
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.left,
            ),
          );
        },
        // Style
        selectionDecoration: _calendarController.view == CalendarView.month
            ? BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 1, color: Colors.transparent),
              )
            : BoxDecoration(
                color: context.colorScheme.secondary.withOpacity(0.08),
                border: Border.all(
                  width: 1,
                  color: context.colorScheme.secondary,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
        onViewChanged: onCalendarDateChanged,
        onTap: onTapCalendar,
        appointmentTextStyle: context.textTheme.bodyMedium!,
        appointmentBuilder:
            (BuildContext context, CalendarAppointmentDetails details) {
          return _buildEventContainer(details, state.events);
        },
      ),
    );
  }

  Widget _buildEventContainer(
      CalendarAppointmentDetails details, List<Event> eventsList) {
    final Appointment appointment = details.appointments.first;
    final DateTime today = DateTime.now();
    bool isCompleted = appointment.endTime.isBefore(today);
    final Event event = eventsList.firstWhere(
      (event) => event.id == appointment.id.toString(),
    );
    if (_calendarController.view == CalendarView.day) {
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
                      style: context.textTheme.bodyMedium?.copyWith(
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
                        style: context.textTheme.bodyMedium
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
                                style: context.textTheme.bodyMedium?.copyWith(
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
                                      style: context.textTheme.bodyMedium
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
                      style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.white, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.start,
                      softWrap: true,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "${appointment.subject} ${context.l10n.asistants.toLowerCase()}",
                      style: context.textTheme.bodyMedium
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
                                  style: context.textTheme.bodyMedium?.copyWith(
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
                                            style: context.textTheme.bodyMedium
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
                        style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(text: event.title!),
                          event.isPrivate!
                              ? TextSpan(
                                  text:
                                      "   ${appointment.subject} ${context.l10n.asistants.toLowerCase()}   ",
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.white),
                                )
                              : TextSpan(
                                  text:
                                      "   ${appointment.subject} ${context.l10n.asistants.toLowerCase()}   ",
                                  style: context.textTheme.bodyMedium
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
                                  style: context.textTheme.bodyMedium?.copyWith(
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
                                            style: context.textTheme.bodyMedium
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
                        style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(text: event.title!),
                          event.isPrivate!
                              ? TextSpan(
                                  text:
                                      "   ${appointment.subject} ${context.l10n.asistants.toLowerCase()}   ",
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.white),
                                )
                              : TextSpan(
                                  text:
                                      "   ${appointment.subject} ${context.l10n.asistants.toLowerCase()}   ",
                                  style: context.textTheme.bodyMedium
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
                          style: context.textTheme.bodyMedium?.copyWith(
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
    } else if (_calendarController.view == CalendarView.week) {
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
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(text: "${event.title!}\n"),
                        TextSpan(
                          text: event.isPrivate!
                              ? "${appointment.subject} ${context.l10n.asistants.toLowerCase().substring(0, 4)}.\n"
                              : "${appointment.subject}\n",
                          style: context.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                        event.numFreeSessions != null &&
                                event.numFreeSessions != 0
                            ? TextSpan(
                                text: event.numFreeSessions == 1
                                    ? "${event.numFreeSessions} ${context.l10n.potentialClient.toLowerCase()}\n"
                                    : "${event.numFreeSessions} ${context.l10n.potentialClients.toLowerCase()}\n",
                                style: context.textTheme.bodyMedium?.copyWith(
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
    } else if (_calendarController.view == CalendarView.month) {
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
                style: context.textTheme.bodyMedium?.copyWith(
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
    } else if (_calendarController.view == CalendarView.schedule) {
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
                              style: context.textTheme.bodyMedium
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
                                    style: context.textTheme.bodyMedium,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                  Text(
                                    "${DateFormat('Hm', Localizations.localeOf(context).languageCode).format(appointment.startTime)} - ${DateFormat('Hm', Localizations.localeOf(context).languageCode).format(appointment.endTime)}",
                                    style: context.textTheme.bodyMedium,
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
                                        style: context.textTheme.bodyMedium
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
                                                  style: context
                                                      .textTheme.bodyMedium,
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

  FlexibleSpaceBar returnFlexibleSpaceBar(double height) {
    return FlexibleSpaceBar(
      background: Container(
        height: height,
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
                      Text(
                        "state.calendarTitle",
                        style: context.textTheme.headlineMedium
                            ?.copyWith(color: AppColors.white),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              mixpanel!.track('brand_calendar_today');
                              setState(() {
                                //_calendarController.selectedDate = DateTime.now();
                                _calendarController.displayDate = DateTime.now()
                                    .subtract(const Duration(hours: 1));
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.white,
                            ),
                            child: Text(context.l10n.todayString,
                                style: context.textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.white),
                                textAlign: TextAlign.center),
                          ),
                          SizedBox(
                            height: iconSizeBig,
                            width: iconSizeBig,
                            child: ClipOval(
                              child: Material(
                                color: false
                                    ? AppColors.white
                                    : Colors.transparent, // Button color
                                child: InkWell(
                                  splashColor: AppColors.white
                                      .withOpacity(0.2), // Splash color
                                  onTap: () {},
                                  child: SizedBox(
                                    width: iconSizeBig,
                                    height: iconSizeBig,
                                    child: Icon(
                                      Icons.filter_list,
                                      color: false
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
    );
  }
}

/*
FILTER CODE

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
                            style: context.textTheme.bodySmall,
                            textAlign: TextAlign.left),
                        trailing: TextButton(
                            child: Text(context.l10n.clear,
                                style: context.textTheme.bodySmall),
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
                                      style: context.textTheme.bodyLarge,
                                      textAlign: TextAlign.left),
                                  subtitle: Text(returnFilteredRolesString(),
                                      style: context.textTheme.bodySmall,
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
                                      style: context.textTheme.bodyLarge,
                                      textAlign: TextAlign.left),
                                  subtitle: Text(
                                    returnFilteredStaffMembersString(),
                                    style: context.textTheme.bodySmall,
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
                                            style: context.textTheme.bodyLarge,
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
                                                        color: context
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
                                            style: context.textTheme.bodyLarge,
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
                                                        color: context
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
                                                    color: context
                                                        .colorScheme.primary,
                                                    borderWidth: 1.0,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      "${trainer.firstName!} ${trainer.lastName![0]}.",
                                                      style: context
                                                          .textTheme.bodyLarge,
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
                                                          : context.theme
                                                              .scaffoldBackgroundColor,
                                                      textColor: selectedTrainersBottom
                                                              .contains(trainer)
                                                          ? context.colorScheme
                                                              .secondary
                                                          : context.theme
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
  
   /* 
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

  */
  
  
  */
