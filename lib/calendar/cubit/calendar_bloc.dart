// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
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
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
  List<Usuario> _brandTrainers = [];
  List<Usuario> selectedTrainers = [];
  Future<void> getBrandInformation() async {
    // Get Brand Details
    _brand = await _brandDataService.getBrandDetails(brandBloc.brandId);
    // Get Brand Trainers
    _brandTrainers =
        await _brandDataService.getBrandTrainers(brandBloc.brandId);
    selectedTrainers = List.from(_brandTrainers);
    // Get Events Per Trainer
    for (Usuario trainer in _brandTrainers) {
      trainer.setEventsList =
          await _eventDataService.getUserEvents(trainer.id!);
    }
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
    _startHour = double.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    _endHour = double.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);
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
      ),
    );
  }

  double getScreenHeightDifference(BuildContext context) {
    // The goal of this function is to calculate the height of each HOUR in the calendar. This is calculated depending on the numbers of avaiable hours (HORARI).
    // Final result
    double adjustedHeight;
    // Full screen height
    double screenHeight = context.height;
    // Expanded Height of AppBar
    double expandedHeight = context.height * 0.15 +
        MediaQuery.of(context).padding.top;
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
    // Diferencia de Hores
    double difference = _endHour - _startHour;
    difference = _startHour != 0 ? difference + 1 : difference;
    difference = _endHour != 24 ? difference + 1 : difference;
    return adjustedHeight / difference;
  }

  bool _checkUserCanEditCalendar() {   
    if (currentUser.brandRole < 3) {
      return true;
    }
    return false;
  }
}
