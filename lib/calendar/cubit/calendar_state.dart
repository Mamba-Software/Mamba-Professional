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
  // Main Vars
  final bool canEdit;
  final Brand brand;
  final List<Event> events;
  // View Variables
  final String displayDateTitle;
  final CalendarView calendarView;
  // Schedule Variables
  final double startHour;
  final double endHour;
  final double difference;  
  final List<TimeRegion> specialRegions;
  // DataSource
  final AppointmentDataSource dataSource;

  const CalendarLoaded({
    required this.canEdit,
    required this.brand,
    required this.events,
    required this.displayDateTitle,
    required this.calendarView,
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
        displayDateTitle,
        calendarView,
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
    String? displayDateTitle,
    CalendarView? calendarView,
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
      displayDateTitle: displayDateTitle ?? this.displayDateTitle,
      calendarView: calendarView ?? this.calendarView,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      difference: difference ?? this.difference,
      specialRegions: specialRegions ?? this.specialRegions,
      dataSource: dataSource ?? this.dataSource,
    );
  }
}
