part of 'calendar_cubit.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();
}

class CalendarInitial extends CalendarState {
  const CalendarInitial();

  @override
  List<Object?> get props => [];
}

class CalendarLoading extends CalendarState {
  const CalendarLoading();

  @override
  List<Object?> get props => [];
}

class CalendarLoaded extends CalendarState {
  final String selectedValue;
  final List<String> items;
  final bool canEdit;
  final Brand brand;
  final List<Usuario> brandTrainers;
  final List<Usuario> selectedTrainers;
  final CalendarController controller;
  final List<int> nonWorkDays;
  final double? startHour;
  final double? endHour;
  final double timeSlotViewZoom;
  final double baseTimeSlotViewZoom;
  final double timeSlotViewScale;
  final double baseTimeSlotViewScale;
  final DateTime dateJoined;
  final DateTime displayDateTimeStart;
  final DateTime displayDateTimeEnd;
  final DateTime middleMonthDate;
  final bool hasFilter;
  final int filterEventsNumber;
  final List<bool> filterByCalendar;
  final DateTime? calendarDateTime;
  final CalendarView? calendarView;

  const CalendarLoaded({
    required this.selectedValue,
    required this.items,
    required this.canEdit,
    required this.brand,
    required this.brandTrainers,
    required this.selectedTrainers,
    required this.controller,
    required this.nonWorkDays,
    required this.startHour,
    required this.endHour,
    required this.timeSlotViewZoom,
    required this.baseTimeSlotViewZoom,
    required this.timeSlotViewScale,
    required this.baseTimeSlotViewScale,
    required this.dateJoined,
    required this.displayDateTimeStart,
    required this.displayDateTimeEnd,
    required this.middleMonthDate,
    required this.hasFilter,
    required this.filterEventsNumber,
    required this.filterByCalendar,
    required this.calendarDateTime,
    required this.calendarView,
  });

  @override
  List<Object?> get props => [
    selectedValue,
    items,
    canEdit,
    brand,
    brandTrainers,
    selectedTrainers,
    controller,
    nonWorkDays,
    startHour,
    endHour,
    timeSlotViewZoom,
    baseTimeSlotViewZoom,
    timeSlotViewScale,
    baseTimeSlotViewScale,
    dateJoined,
    displayDateTimeStart,
    displayDateTimeEnd,
    middleMonthDate,
    hasFilter,
    filterEventsNumber,
    filterByCalendar,
    calendarDateTime,
    calendarView,
  ];
}


class CalendarError extends CalendarState {
  final String message;
  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}