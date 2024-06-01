import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:mamba/calendar/cubit/calendar_bloc.dart';
import 'package:mamba/calendar/widgets/calendar_action_button.dart';
import 'package:mamba/calendar/widgets/calendar_event_widget.dart';
import 'package:mamba/calendar/widgets/calendar_view.dart';
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
import 'package:mamba/events/cubit/events_bloc.dart';
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
                      child: CalendarWidgetView(
                        state: state,
                        calendarController: _calendarController,
                        timeSlotViewZoom: _timeSlotViewZoom,
                        onCalendarDateChanged: onCalendarDateChanged,
                        onTapCalendar: onTapCalendar,
                        onCalendarEventTapped: navigateToEventScreen,
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
                    child: CalendarWidgetView(
                      state: state,
                      calendarController: _calendarController,
                      timeSlotViewZoom: _timeSlotViewZoom,
                      onCalendarDateChanged: onCalendarDateChanged,
                      onTapCalendar: onTapCalendar,
                      onCalendarEventTapped: navigateToEventScreen,
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
          return LoadingView(
            isSmall: true,
            text: "Aixo no estarà aqui, haurà de carregar directament",
          );
        }
      },
    );
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
