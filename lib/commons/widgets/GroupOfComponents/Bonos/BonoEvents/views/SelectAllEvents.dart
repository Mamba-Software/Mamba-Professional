import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/l10n/language_manager.dart';
import 'package:intl/intl.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/data/Models/Purchase.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/BonoEvents/cubit/BonoEventsCubit.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Events/EventPage/UserEventCard.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class SelectAllEvents extends StatelessWidget {
  final parentContext;
  List<Event> selectedEvents;
  List<Event> allEvents;
  String brandId;
  Purchase purchase;

  SelectAllEvents(
      {super.key,
      required this.parentContext,
      required this.selectedEvents,
      required this.allEvents,
      required this.brandId,
      required this.purchase});

  // Search Controller
  bool searchClicked = false;
  var searchController = TextEditingController();

  // Members Page
  List<Appointment> allAppointments = <Appointment>[];

  Widget _buildEventContainer(
      CalendarAppointmentDetails details,
      List<Event> selectedEvents,
      Event event,
      BuildContext context,
      var loadedState) {
    //final Event event = getEvent(appointment.id.toString(), loadedState);
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        UserEventCard(
          event: event,
          height: details.bounds.height,
          width: details.bounds.width,
          isMyEvent: true,
          showEmoji: false,
        ),
        Positioned(
          top: MediaQuery.of(parentContext).size.width * 0.01,
          left: MediaQuery.of(parentContext).size.width * 0.01,
          child: Transform.scale(
            scale: 1.5,
            child: Checkbox(
              checkColor: Colors.white,
              tristate: false,
              fillColor: MaterialStateProperty.resolveWith(getColor),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: selectedEvents.contains(event),
              shape: const CircleBorder(side: BorderSide.none),
              onChanged: (bool? boolean) {
                //context.read<BonoEventsCubit>().updateSelected(event, loadedState.selectedEvents, loadedState.allEvents, loadedState.filteredEvents);
              },
            ),
          ),
        ),
      ],
    );
  }

  Event getEvent(String eventId, BonoEventsLoaded loadedState) {
    for (var i = 0; i < loadedState.filteredEvents.length; i++) {
      Event temp = loadedState.filteredEvents[i];
      if (temp.id == eventId) {
        return temp;
      }
    }
    return Event();
  }

  Color getColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return Theme.of(parentContext).colorScheme.secondary;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: BlocProvider<BonoEventsCubit>(
        lazy: false,
        create: (context) => BonoEventsCubit(
            purchase, currentBrand.id!, selectedEvents, allEvents, false),
        child: BlocBuilder<BonoEventsCubit, BonoEventsState>(
          builder: (context, state) {
            switch (state.runtimeType) {
              case BonoEventsLoaded:
                BonoEventsLoaded loadedState = state as BonoEventsLoaded;
                return DefaultTabController(
                  length: 2,
                  initialIndex: 0,
                  child: Scaffold(
                    appBar: AppBar(
                      title: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          context.read<BonoEventsCubit>().filterSearchResults(
                              value,
                              loadedState.selectedEvents,
                              loadedState.allEvents,
                              loadedState.filteredEvents);
                        },
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          hintStyle: Theme.of(context).textTheme.bodySmall,
                          hintText: context.l10n.search,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.0),
                        ),
                      ),
                      centerTitle: true,
                      leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: MediaQuery.of(context).size.width * 0.06,
                        ),
                        onPressed: () {
                          Navigator.pop(context, null);
                        },
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            searchController.clear();
                            context.read<BonoEventsCubit>().filterSearchResults(
                                "",
                                loadedState.selectedEvents,
                                loadedState.allEvents,
                                loadedState.filteredEvents);
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    resizeToAvoidBottomInset: true,
                    body: Column(
                      children: [
                        loadedState.selectedEvents.isNotEmpty
                            ? Material(
                                elevation: 4,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                  ),
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: loadedState
                                                .selectedEvents.length,
                                            itemBuilder: (context, index) {
                                              Event event = loadedState
                                                  .selectedEvents[index];
                                              return Center(
                                                child: Text(
                                                  index == 0 &&
                                                              loadedState
                                                                      .selectedEvents
                                                                      .length ==
                                                                  1 ||
                                                          index ==
                                                              loadedState
                                                                      .selectedEvents
                                                                      .length -
                                                                  1
                                                      ? event.title!
                                                      : "${event.title!}, ",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              );
                                            }),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.09,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              "( ${loadedState.selectedEvents.length} )",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(fontSize: 8),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                        loadedState.filteredEvents.isNotEmpty
                            ? Expanded(
                                child: SfCalendarTheme(
                                  data: SfCalendarThemeData(
                                    brightness: Brightness.dark,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    todayHighlightColor:
                                        Theme.of(context).primaryColor,
                                    todayBackgroundColor: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ),
                                  child: SfCalendar(
                                    // Controller
                                    view: CalendarView.schedule,
                                    blackoutDatesTextStyle: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.w600),
                                    // Data
                                    initialDisplayDate: DateTime.now(),
                                    initialSelectedDate: DateTime.now(),
                                    dataSource:
                                        _getCalendarDataSource(loadedState),
                                    // Config
                                    cellEndPadding: 0,
                                    firstDayOfWeek: 1,
                                    showCurrentTimeIndicator: true,
                                    cellBorderColor: Colors.transparent,
                                    todayTextStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                    // Style
                                    selectionDecoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.08),
                                        border: Border.all(
                                            width: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                        shape: BoxShape.circle),
                                    headerHeight: 0,
                                    headerStyle: CalendarHeaderStyle(
                                      textAlign: TextAlign.center,
                                      backgroundColor: Colors.transparent,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.transparent),
                                    ),
                                    viewHeaderHeight: 30,
                                    viewHeaderStyle: ViewHeaderStyle(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      dateTextStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      dayTextStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontSize: 10),
                                    ),
                                    // Monthly View
                                    monthViewSettings: MonthViewSettings(
                                      appointmentDisplayCount: 3,
                                      numberOfWeeksInView: 6,
                                      showTrailingAndLeadingDates: false,
                                      appointmentDisplayMode:
                                          MonthAppointmentDisplayMode.indicator,
                                      showAgenda: true,
                                      agendaViewHeight:
                                          MediaQuery.of(context).size.height *
                                              0.35,
                                      agendaItemHeight:
                                          MediaQuery.of(context).size.height *
                                              0.15,
                                      agendaStyle: AgendaStyle(
                                        dateTextStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        dayTextStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(fontSize: 10),
                                        appointmentTextStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      monthCellStyle: MonthCellStyle(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                        trailingDatesTextStyle:
                                            Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                        leadingDatesTextStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                    // Schedule View
                                    scheduleViewSettings: ScheduleViewSettings(
                                        hideEmptyScheduleWeek: true,
                                        appointmentItemHeight:
                                            MediaQuery.of(context).size.height *
                                                0.15,
                                        appointmentTextStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
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
                                          startDateFormat: 'dd/MM',
                                          endDateFormat: 'dd/MM/yyyy',
                                          textAlign: TextAlign.start,
                                          backgroundColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          weekTextStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        monthHeaderSettings:
                                            MonthHeaderSettings(
                                          monthFormat: 'MMMM yyyy',
                                          height: 70,
                                          textAlign: TextAlign.start,
                                          backgroundColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          monthTextStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                        )),
                                    scheduleViewMonthHeaderBuilder:
                                        (BuildContext buildContext,
                                            ScheduleViewMonthHeaderDetails
                                                details) {
                                      return Container(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.03),
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
                                                  .displayLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: AppColors.grey),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    appointmentTextStyle:
                                        Theme.of(context).textTheme.bodyMedium!,
                                    appointmentBuilder: (BuildContext context,
                                        CalendarAppointmentDetails details) {
                                      final Appointment appointment =
                                          details.appointments.first;
                                      final DateTime today = DateTime.now();
                                      bool isCompleted =
                                          appointment.endTime.isBefore(today);
                                      final Event event = getEvent(
                                          appointment.id.toString(),
                                          loadedState);
                                      return GestureDetector(
                                        onTap: () {
                                          context
                                              .read<BonoEventsCubit>()
                                              .updateSelected(
                                                  event,
                                                  loadedState.selectedEvents,
                                                  loadedState.allEvents,
                                                  loadedState.filteredEvents);
                                        },
                                        child: _buildEventContainer(
                                            details,
                                            loadedState.selectedEvents,
                                            event,
                                            context,
                                            loadedState),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Center(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            child: Image.asset(
                                                Assets.emptyCalendar)),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.005),
                                        Text(
                                          context.l10n.noEventsAccesibleBono,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.12),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ),
                    floatingActionButton: Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.05),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.17,
                        width: MediaQuery.of(context).size.width * 0.17,
                        child: FloatingActionButton(
                          heroTag: "64",
                          onPressed: () {
                            Navigator.pop(context, loadedState.selectedEvents);
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: Icon(
                            Icons.add,
                            size: MediaQuery.of(context).size.width * 0.07,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              case BonoEventsLoading:
                return Center(child: LoadingView());
              default:
                // Handle All other States aka Loading or Initial
                return Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.sessions,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                              shape: RoundedRectangleBorder(
                                // add this
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 10.0),
                            ),
                            onPressed: null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.edit,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: AppColors.grey),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.02),
                                Icon(
                                  Icons.edit,
                                  color: AppColors.grey,
                                  size:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                    Material(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        child: Column(
                          children: [
                            Shimmer.fromColors(
                              baseColor:
                                  Theme.of(context).colorScheme.background,
                              highlightColor: Theme.of(context)
                                  .colorScheme
                                  .background
                                  .withOpacity(0.5),
                              child: Container(
                                height: MediaQuery.of(context).size.height *
                                    0.15 *
                                    0.66,
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                            Shimmer.fromColors(
                              baseColor: AppColors.grey,
                              highlightColor: AppColors.grey.withOpacity(0.5),
                              child: Container(
                                height: MediaQuery.of(context).size.height *
                                        0.15 *
                                        0.34 -
                                    1,
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  //border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ],
                );
            }
          },
        ),
      ),
    );
  }

  AppointmentDataSource _getCalendarDataSource(BonoEventsLoaded loadedState) {
    List<Appointment> tempAllAppointments = [];
    for (var i = 0; i < loadedState.filteredEvents.length; i++) {
      var event = loadedState.filteredEvents[i];
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
      var endDate = startDate
          .add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
      // Subject
      String subject;
      Color color = Colors.black;
      if (event.isPrivate!) {
        subject = "${event.numClients}";
        color = Colors.black;
      } else {
        subject = "${event.numClients}/${event.maxMembers}";
        // Colors
        double numClients = double.parse(event.numClients.toString());
        double maxMembers = double.parse(event.maxMembers.toString());
        double bookedCapacity = numClients / maxMembers;
        if (bookedCapacity <= 0.20) {
          color = Colors.green;
        } else if (bookedCapacity > 0.20 && bookedCapacity <= 0.40) {
          color = const Color(0xFFA8C76C);
        } else if (bookedCapacity > 0.40 && bookedCapacity <= 0.60) {
          color = const Color(0xFFECE014);
        } else if (bookedCapacity > 0.60 && bookedCapacity <= 0.80) {
          color = Colors.orangeAccent;
        } else if (bookedCapacity > 0.80 && bookedCapacity < 1) {
          color = Colors.deepOrangeAccent;
        } else if (bookedCapacity >= 1) {
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
    allAppointments = tempAllAppointments;
    return AppointmentDataSource(allAppointments);
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
