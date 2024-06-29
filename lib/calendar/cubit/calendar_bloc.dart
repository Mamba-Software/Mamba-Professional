// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba/Events/cubit/events_bloc.dart';
import 'package:mamba/calendar/models/appointment.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/mixins/string.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:mamba/brand/bloc/brand_bloc.dart';
part 'calendar_state.dart';

class CalendarBloc extends Cubit<CalendarState> with StringMixin {
  // Blocs
  final UserBloc _userBloc;
  final BrandBloc _brandBloc;
  final EventsBloc _eventsBloc;

  StreamSubscription? eventBlocSubscription;

  final _userDataService = UserDataService();

  // Calendar View
  CalendarView calendarView = CalendarView.week;
  // Horari
  double _startHour = 8.0;
  double _endHour = 22.0;
  double difference = 22.0;
  String? locale;
  String? displayDateTitleAux;
  double userZoomScale = 1.5;

  CalendarBloc({
    required UserBloc userBloc,
    required BrandBloc brandBloc,
    required EventsBloc eventsBloc,
  })  : _userBloc = userBloc,
        _brandBloc = brandBloc,
        _eventsBloc = eventsBloc,
        super(const CalendarInitial());

  void resetCalendar() {
    eventBlocSubscription?.cancel();
    eventBlocSubscription = null;
  }

  Future<void> initialize() async {
    // Emit Loading State
    emit(const CalendarLoading());

    // Initial Date Time
    DateTime now = DateTime.now();
    int currentDay = now.weekday;
    DateTime startWeekDate = now.subtract(Duration(days: currentDay - 1));
    DateTime endWeekDate = startWeekDate.add(const Duration(days: 6));
    List<DateTime> visibleDates = [startWeekDate, endWeekDate];
    String calendarTitle = getCalendarTitle(calendarView, visibleDates);

    // Date Joined Information
    //DateTime dateJoined = DateFormat('dd-MM-yyyy').parse(_brandBloc.getBrand.dateJoined!);
    _startHour =
        double.parse(_brandBloc.getBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
    _endHour =
        double.parse(_brandBloc.getBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
    // Diferencia de Hores
    double difference = _endHour - _startHour;
    difference = _startHour != 0 ? difference + 1 : difference;
    difference = _endHour != 24 ? difference + 1 : difference;

    // Get Brand Events
    await _eventsBloc.getInitialBrandEvents(_brandBloc.getBrandTrainers);

    // Get User Zoom Scale Events
    userZoomScale = await getUserZoomScale();

    // Emit New State
    emit(
      CalendarLoaded(
        canEdit: _checkUserCanEditCalendar(),
        brand: _brandBloc.getBrand,
        events: _eventsBloc.eventsList,
        displayDate: DateTime.now(),
        visibleDates: visibleDates,
        calendarView: calendarView,
        calendarTitle: calendarTitle,
        timeSlotViewScale: userZoomScale,
        startHour: _startHour,
        endHour: _endHour,
        difference: difference,
        specialRegions: getTimeRegions(),
        dataSource: getCalendarDataSource(),
      ),
    );
  }

  void onViewChanged(CalendarView calendarView, List<DateTime> visibleDates) {
    // Update the Calendar Title;
    String calendarTitle = getCalendarTitle(calendarView, visibleDates);
    // Check if More Events should be Fetched
    getMoreBrandEvents(visibleDates);
    // Emit New State
    emit(
      (state as CalendarLoaded).copyWith(calendarTitle: calendarTitle),
    );
  }

  String getCalendarTitle(
    CalendarView calendarView,
    List<DateTime> visibleDates,
  ) {
    String displayDateTitle;
    DateTime dateTimeStart = visibleDates.first;
    DateTime dateTimeEnd = visibleDates.last;
    DateTime middleMonthDate = visibleDates[visibleDates.length ~/ 2];

    String formatDate(DateTime date, String pattern) {
      return toCapitalized(DateFormat(pattern, locale).format(date));
    }

    String formatDateRange(DateTime start, DateTime end, String pattern) {
      return "${formatDate(start, pattern)} - ${formatDate(end, pattern)}";
    }

    switch (calendarView) {
      case CalendarView.schedule:
        displayDateTitle = "$displayDateTitleAux ";
        break;
      case CalendarView.day:
        displayDateTitle = dateTimeStart.year == DateTime.now().year
            ? "${formatDate(dateTimeStart, 'EEEE')}, ${formatDate(dateTimeStart, 'dd')} ${formatDate(dateTimeStart, 'MMM')}"
            : "${formatDate(dateTimeStart, 'dd')} ${formatDate(dateTimeStart, 'MMMM yyyy')}";
        break;
      case CalendarView.week:
        displayDateTitle = dateTimeStart.year == DateTime.now().year
            ? "${formatDateRange(dateTimeStart, dateTimeEnd, 'dd')} ${formatDate(dateTimeStart, 'MMMM')}"
            : "${formatDateRange(dateTimeStart, dateTimeEnd, 'dd')} ${formatDate(dateTimeStart, 'MMMM yy')}";
        break;
      case CalendarView.month:
        displayDateTitle = formatDate(middleMonthDate,
            middleMonthDate.year == DateTime.now().year ? 'MMMM' : 'MMMM yyyy');
        break;
      default:
        displayDateTitle = dateTimeStart.year == DateTime.now().year
            ? "${formatDateRange(dateTimeStart, dateTimeStart.add(const Duration(days: 6)), 'dd')} ${formatDate(dateTimeStart, 'MMMM')}"
            : "${formatDateRange(dateTimeStart, dateTimeStart.add(const Duration(days: 6)), 'dd')} ${formatDate(dateTimeStart, 'MMMM yyyy')}";
        break;
    }

    return displayDateTitle;
  }

  void getMoreBrandEvents(List<DateTime> visibleDates) async {
    List<Event> eventsList = _eventsBloc.eventsList;
    if (eventsList.isNotEmpty) {
      var startDateLastEvent = DateTime(
        int.parse(eventsList.first.year!),
        int.parse(eventsList.first.month!),
        int.parse(eventsList.first.day!),
        int.parse(eventsList.first.hour!),
        int.parse(eventsList.first.minute!),
      );
      DateTime firstVisibleDate = visibleDates.first;
      int difference = firstVisibleDate.difference(startDateLastEvent).inDays;
      if (difference < 60) {
        await _eventsBloc.getMoreBrandEvents(
            eventsList.first.id!, _brandBloc.getBrandTrainers);
      }
    }
  }

  Future<double> getUserZoomScale() async {
    return await _userDataService.getUserZoomScale(
      _brandBloc.brandId,
      _userBloc.userId,
    );
  }

  void updateUserZoomScale(double timeSlotViewScale) {
    _userDataService.updateUserZoomScale(
      _brandBloc.brandId,
      currentUser.id!,
      timeSlotViewScale,
    );
  }

  AppointmentDataSource getCalendarDataSource() {
    List<Appointment> tempAllAppointments = [];
    List<String> selectedTrainersIDs = [];
    for (var trainer in _brandBloc.getBrandTrainers) {
      selectedTrainersIDs.add(trainer.id!);
    }
    for (var i = 0; i < _eventsBloc.eventsList.length; i++) {
      var event = _eventsBloc.eventsList[i];
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
      // Add Event to Appointment List
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
    return AppointmentDataSource(tempAllAppointments);
  }

  List<TimeRegion> getTimeRegions() {
    final List<TimeRegion> regions = <TimeRegion>[];
    // BrandDate Joined
    DateTime dateJoined = DateFormat('dd-MM-yyyy').parse(_brandBloc.getBrand.dateJoined!);
    // Hora Inactiva Matí
    var startHourWS =
        int.parse(_brandBloc.getBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
    var startMinWS =
        int.parse(_brandBloc.getBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day - 7,
          startHourWS - 1, 0, 0),
      endTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day - 7,
          startHourWS, startMinWS, 0),
      color: Colors.grey.withOpacity(0.15),
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
    ));
    // Hora Inactiva Nit
    var endHourWS =
        int.parse(_brandBloc.getBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
    var endMinWS =
        int.parse(_brandBloc.getBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
    regions.add(TimeRegion(
      enablePointerInteraction: false,
      startTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day - 7,
          endHourWS, endMinWS, 0),
      endTime: DateTime(dateJoined.year, dateJoined.month, dateJoined.day - 7,
          endHourWS + 1, 0, 0),
      color: Colors.grey.withOpacity(0.15),
      recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
    ));
    return regions;
  }

  bool _checkUserCanEditCalendar() {
    if (currentUser.brandRole < 3) {
      return true;
    }
    return false;
  }
}
