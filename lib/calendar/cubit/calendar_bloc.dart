// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba/calendar/models/appointment.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:mamba/brand/bloc/brand_bloc.dart';
import 'package:mamba/events/cubit/events_bloc.dart';
part 'calendar_state.dart';

class CalendarBloc extends Cubit<CalendarState> {
  // Blocs
  final BuildContext context;
  final UserBloc userBloc;
  final BrandBloc brandBloc;
  final EventsBloc eventBloc;

  // Brand Information (To be substituted by Brand CUBIT)
  // All the information that we have here, should be taken from the Brand State
  Brand _brand = Brand();
  DateTime dateJoined = DateTime.now();
  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  List<Usuario> _brandTrainers = [];
  List<Usuario> selectedTrainers = [];
  Future<void> getBrandInformation() async {
    // Get Brand Details
    _brand = await _brandDataService.getBrandDetails(brandBloc.brandId);
    // Get Brand Trainers
    _brandTrainers =
        await _brandDataService.getBrandTrainers(brandBloc.brandId);
    selectedTrainers = List.from(_brandTrainers);
  }
  // Brand Information (To be substituted by Brand CUBIT)

  DateTime displayDateTimeStart = DateTime.now();
  DateTime displayDateTimeEnd = DateTime.now();
  DateTime middleMonthDate = DateTime.now();

  // Horari
  double _startHour = 8.0;
  double _endHour = 22.0;
  double difference = 22.0;

  CalendarBloc({
    required this.context,
    required this.userBloc,
    required this.brandBloc,
    required this.eventBloc,
  }) : super(const CalendarInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Emit Loading State
    emit(const CalendarLoading());

    // TO DO: Remove this by using Brand Bloc
    await getBrandInformation();
    // TO DO: Remove this by using Brand Bloc

    // Get Brand Events
    await eventBloc.getInitialBrandEvents(_brandTrainers);

    // Initial Date Time
    DateTime now = DateTime.now();
    int currentDay = now.weekday;
    displayDateTimeStart = now.subtract(Duration(days: currentDay - 1));
    displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));

    // Date Joined Information
    dateJoined = DateFormat('dd-MM-yyyy').parse(_brand.dateJoined!);
    _startHour =
        double.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    _endHour =
        double.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);
    // Diferencia de Hores
    double difference = _endHour - _startHour;
    difference = _startHour != 0 ? difference + 1 : difference;
    difference = _endHour != 24 ? difference + 1 : difference;

    // Emit New State
    emit(
      CalendarLoaded(
        canEdit: _checkUserCanEditCalendar(),
        brand: _brand,
        events: eventBloc.eventsList,
        displayDateTitle: DateTime.now().toString(),
        calendarView: CalendarView.week,
        startHour: _startHour,
        endHour: _endHour,
        difference: difference,
        specialRegions: getTimeRegions(),
        dataSource: getCalendarDataSource(),
      ),
    );
  }

  Future<void> getMoreBrandEvents(String eventId) async {
   await eventBloc.getMoreBrandEvents(eventId, _brandTrainers);
  }

  void updateUserZoomScale(double timeSlotViewScale) {
    _userDataService.updateUserZoomScale(
      brandBloc.brandId,
      currentUser.id!,
      timeSlotViewScale,
    );
  }

  AppointmentDataSource getCalendarDataSource() {
    List<Appointment> tempAllAppointments = [];
    List<String> selectedTrainersIDs = [];
    for (var trainer in selectedTrainers) {
      selectedTrainersIDs.add(trainer.id!);
    }
    for (var i = 0; i < eventBloc.eventsList.length; i++) {
      var event = eventBloc.eventsList[i];
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
    DateTime dateJoined = DateFormat('dd-MM-yyyy').parse(_brand.dateJoined!);
    // Hora Inactiva Matí
    var startHourWS =
        int.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    var startMinWS =
        int.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[1]);
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
        int.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);
    var endMinWS =
        int.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[1]);
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
