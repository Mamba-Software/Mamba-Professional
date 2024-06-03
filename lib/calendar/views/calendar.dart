import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba/calendar/cubit/calendar_bloc.dart';
import 'package:mamba/calendar/widgets/calendar_action_button.dart';
import 'package:mamba/calendar/widgets/calendar_appbar.dart';
import 'package:mamba/calendar/widgets/calendar_event_widget.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/theme_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/mixins/string.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/read_event/views/mobile/ReadEventPage.dart';
import 'package:mamba/events/crud_events/views/mobile/AddorEdtiEvent.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/events/cubit/events_bloc.dart';
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
  }

  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset >
            (MediaQuery.of(context).size.height * 0.25 - kToolbarHeight);
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

  Future<void> navigateToEventScreen(String eventId) async {
    mixpanel!.track('brand_calendar_event_view', properties: {
      'Calendar View': _calendarController.view.toString(),
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
    // Start Week View
    _calendarController.view = CalendarView.week;
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
    double viewHeaderHeight = 55;
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      listenWhen: (previous, current) {
        return previous is CalendarLoading && current is CalendarLoaded;
      },
      listener: (context, state) {
        final loadedState = state as CalendarLoaded;
        onCalendarStart(
          loadedState.difference,
          loadedState.timeSlotViewScale,
        );
      },
      builder: (context, state) {
        if (state is CalendarLoaded) {
          return Scaffold(
            body: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _scrollController,
              slivers: [
                CalendarAppbar(
                  title: state.calendarTitle,
                  appBarExpanded: appBarExpanded,
                  view: _calendarController.view ?? CalendarView.week,
                  timeSlotViewScale: _timeSlotViewScale,
                  onTapToday: onTapToday,
                  onTapForward: onTapForward,
                  onTapBackward: onTapBackward,
                  onCalendarViewChanged: onCalendarViewChanged,
                  onManualScaleUpdate: onManualScaleUpdate,
                ),
                SliverFillRemaining(
                  child: GestureDetector(
                    onScaleStart: onScaleStart,
                    onScaleUpdate: onScaleUpdate,
                    onScaleEnd: onScaleEnd,
                    child: CalendarViewWidget(
                      state: state,
                      calendarController: _calendarController,
                      timeSlotViewZoom: _timeSlotViewZoom,
                      onCalendarDateChanged: onCalendarDateChanged,
                      onTapCalendar: onTapCalendar,
                      onCalendarEventTapped: navigateToEventScreen,
                    ),
                  ),
                )
              ],
            ),
            floatingActionButton: CalendarActionButton(
              timeSlotViewScale: _timeSlotViewScale,
              calendarView: _calendarController.view ?? CalendarView.week,
              onCreateEventTap: onCreateEventTap,
            ),
          );
        } else {
          return LoadingView(
            isSmall: true,
            text: "Aixo no estarà aqui, haurà de carregar directament",
          );
        }
      },
    );
  }
}

class CalendarViewWidget extends StatelessWidget with StringMixin {
  final CalendarLoaded state;
  final CalendarController calendarController;
  final double timeSlotViewZoom;
  final void Function(ViewChangedDetails) onCalendarDateChanged;
  final void Function(CalendarTapDetails) onTapCalendar;
  final Function(String) onCalendarEventTapped;

  const CalendarViewWidget({
    super.key,
    required this.state,
    required this.calendarController,
    required this.timeSlotViewZoom,
    required this.onCalendarDateChanged,
    required this.onTapCalendar,
    required this.onCalendarEventTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Variables
    DateTime dateJoined =
        DateFormat('dd-MM-yyyy').parse(state.brand.dateJoined!);
    // Sizes
    double headerHeight = 0;
    double viewHeaderHeight = context.isDesktop ? 70 : 55;
    double timeRulerSize = 50;
    double timeIntervalWidth = 60;
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
        viewHeaderBackgroundColor: context.isDesktop == false || calendarController.view == CalendarView.day
            ? context.theme.scaffoldBackgroundColor
            : context.colorScheme.background,
        weekNumberBackgroundColor: context.colorScheme.background,
        allDayPanelColor: context.theme.scaffoldBackgroundColor,
        // Main Text Styles
        todayTextStyle: context.textTheme.bodyLarge,
        headerTextStyle: context.textTheme.bodyLarge,
        viewHeaderDateTextStyle: context.isDesktop
            ? context.textTheme.bodyLarge
            : context.textTheme.bodyMedium,
        viewHeaderDayTextStyle: context.isDesktop
            ? context.textTheme.bodyLarge
            : context.textTheme.bodyMedium,
        agendaDayTextStyle: context.textTheme.bodyLarge,
        agendaDateTextStyle: context.textTheme.bodyLarge,
        // Secondary Text Styles
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
        controller: calendarController,
        viewNavigationMode: context.isDesktop
            ? ViewNavigationMode.none
            : ViewNavigationMode.snap,
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
        headerHeight: headerHeight,
        // View Header
        viewHeaderHeight: viewHeaderHeight,
        // Time Slot View Settings
        timeSlotViewSettings: TimeSlotViewSettings(
          timeIntervalHeight: timeSlotViewZoom,
          timeIntervalWidth: timeIntervalWidth,
          startHour:
              state.startHour != 0 ? state.startHour - 1 : state.startHour,
          endHour: state.endHour != 24 ? state.endHour + 1 : state.endHour,
          timeFormat: 'HH:mm',
          dayFormat: 'EE',
          dateFormat: 'd',
          timeRulerSize: timeRulerSize,
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
            dayTextStyle: context.textTheme.bodyMedium,
          ),
          weekHeaderSettings: WeekHeaderSettings(
            startDateFormat: 'd',
            endDateFormat: 'd MMMM',
            textAlign: TextAlign.start,
            backgroundColor: context.theme.scaffoldBackgroundColor,
            weekTextStyle: context.textTheme.bodyMedium,
          ),
          monthHeaderSettings: MonthHeaderSettings(
            height: 50,
            backgroundColor: context.theme.scaffoldBackgroundColor,
          ),
        ),
        scheduleViewMonthHeaderBuilder: buildSchduleMonthHeaderWidget,
        // Style
        selectionDecoration: buildSelectionDecoration(context),
        onViewChanged: onCalendarDateChanged,
        onTap: onTapCalendar,
        appointmentTextStyle: context.textTheme.bodyMedium!,
        appointmentBuilder: buildEventWidget,
      ),
    );
  }

  Decoration buildSelectionDecoration(BuildContext context) {
    return calendarController.view == CalendarView.month
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
          );
  }

  Widget buildSchduleMonthHeaderWidget(
      BuildContext context, ScheduleViewMonthHeaderDetails details) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
        ),
      ],
    );
  }

  Widget buildEventWidget(
      BuildContext context, CalendarAppointmentDetails details) {
    final appointment = details.appointments.first;
    final eventsList = context.read<EventsBloc>().eventsList;
    final event = eventsList.firstWhere(
      (event) => event.id == appointment.id.toString(),
    );
    return CalendarEventWidget(
      event: event,
      appointment: appointment,
      calendarView: calendarController.view!,
      details: details,
      onTap: () => onCalendarEventTapped(event.id!),
    );
  }
}
