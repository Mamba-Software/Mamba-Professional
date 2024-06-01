import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba/calendar/cubit/calendar_bloc.dart';
import 'package:mamba/calendar/widgets/calendar_event_widget.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/theme_manager.dart';
import 'package:mamba/commons/mixins/string.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/events/cubit/events_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class CalendarWidgetView extends StatelessWidget with StringMixin {
  final CalendarLoaded state;
  final CalendarController calendarController;
  final double timeSlotViewZoom;
  final void Function(ViewChangedDetails) onCalendarDateChanged; // Corrected type
  final void Function(CalendarTapDetails) onTapCalendar;
  final Function(String) onCalendarEventTapped;

  const CalendarWidgetView({
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
        viewHeaderBackgroundColor: calendarController.view == CalendarView.day
            ? context.theme.scaffoldBackgroundColor
            : context.colorScheme.background,
        weekNumberBackgroundColor: context.colorScheme.background,
        allDayPanelColor: context.theme.scaffoldBackgroundColor,
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
        controller: calendarController,
        // Blackout Dates
        blackoutDates: [
          DateFormat('dd-MM-yyyy').parse(state.brand.dateJoined!)
        ],
        blackoutDatesTextStyle: context.textTheme.titleMedium,
        showWeekNumber: false,
        weekNumberStyle: WeekNumberStyle(
          textStyle: context.textTheme.labelSmall,
        ),
        // Data
        minDate: DateFormat('dd-MM-yyyy').parse(state.brand.dateJoined!),
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
          timeIntervalHeight: timeSlotViewZoom,
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
