part of 'CalendarFunctionCubit.dart';

abstract class CalendarFunctionState extends Equatable {
  const CalendarFunctionState();
}

class CalendarFunctionInitial extends CalendarFunctionState {
  const CalendarFunctionInitial();

  @override
  List<Object?> get props => [];
}

class CalendarFunctionLoading extends CalendarFunctionState {
  const CalendarFunctionLoading();

  @override
  List<Object?> get props => [];
}

class CalendarFunctionLoaded extends CalendarFunctionState {
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

  CalendarFunctionLoaded({
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


class CalendarFunctionError extends CalendarFunctionState {
  final String message;
  const CalendarFunctionError(this.message);

  @override
  List<Object?> get props => [message];
}