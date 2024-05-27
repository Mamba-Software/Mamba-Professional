part of 'calendar_bloc.dart';

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
  // Main Variables
  final bool canEdit;
  final Brand brand;
  final List<Event> events;
  // Calendar View Variables  
  final DateTime displayDate;
  final List<DateTime> visibleDates;
  final CalendarView calendarView;
  final String calendarTitle;
  final double timeSlotViewScale;
  // Schedule Variables
  final double startHour;
  final double endHour;
  final double difference;  
  final List<TimeRegion> specialRegions;
  // Data Source Variables
  final AppointmentDataSource dataSource;

  const CalendarLoaded({
    required this.canEdit,
    required this.brand,
    required this.events,        
    required this.displayDate,
    required this.visibleDates,
    required this.calendarView,
    required this.calendarTitle,
    required this.timeSlotViewScale,
    required this.startHour,
    required this.endHour,
    required this.difference,
    required this.specialRegions,
    required this.dataSource,
  });

  @override
  List<Object?> get props => [
        canEdit,
        brand,
        events,
        displayDate,
        visibleDates,
        calendarView,
        calendarTitle,
        timeSlotViewScale,
        startHour,
        endHour,
        difference,
        specialRegions,
        dataSource,
      ];

  CalendarLoaded copyWith({
    bool? canEdit,
    Brand? brand,
    List<Event>? events,
    DateTime? displayDate,
    List<DateTime>? visibleDates,
    CalendarView? calendarView,
    String? calendarTitle,
    double? timeSlotViewScale,
    double? startHour,
    double? endHour,
    double? difference,
    List<TimeRegion>? specialRegions,
    AppointmentDataSource? dataSource,
  }) {
    return CalendarLoaded(
      canEdit: canEdit ?? this.canEdit,
      brand: brand ?? this.brand,
      events: events ?? this.events,
      displayDate: displayDate ?? this.displayDate,
      visibleDates: visibleDates ?? this.visibleDates,      
      calendarView: calendarView ?? this.calendarView,
      calendarTitle: calendarTitle ?? this.calendarTitle,
      timeSlotViewScale: timeSlotViewScale ?? this.timeSlotViewScale,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      difference: difference ?? this.difference,
      specialRegions: specialRegions ?? this.specialRegions,
      dataSource: dataSource ?? this.dataSource,
    );
  }
}
