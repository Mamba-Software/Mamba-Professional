// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:mamba/brand/bloc/brand_bloc.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/events/cubit/events_cubit.dart';
part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  
  // Needed Blocs
  final UserBloc userBloc;
  final BrandBloc brandBloc;
  final EventsCubit eventBloc;

  // Brand
  Brand _brand = Brand();
  DateTime _dateJoined = DateTime.now();
  double _startWorkHour = 8.0;
  double _endWorkHour = 22.0;

  // Calendar Controller
  final CalendarController _controller = CalendarController();

  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();

  // Calendar Controller

  // Horari
  List<int> nonWorkDays = [];

  // Selecte Date Time
  DateTime displayDateTimeStart = DateTime.now();
  DateTime displayDateTimeEnd = DateTime.now();
  DateTime middleMonthDate = DateTime.now();

  //  Heights
  double viewHeaderHeight = 50;

  CalendarCubit({
    required this.userBloc,
    required this.brandBloc,
    required this.eventBloc,
  }) : super(const CalendarInitial()) {
    _initialize();
  }

  // To Be Deleted By Brand and User Blocs
  void getBLOCUserBrandDetails() async {
    // Get Brand Details
    _brand = await _brandDataService.getBrandDetails(brandBloc.getBrandId);
  }

  Future<void> _initialize() async {
    emit(const CalendarLoading());

    // Initial Date Time
    DateTime now = DateTime.now();
    int currentDay = now.weekday;
    displayDateTimeStart = now.subtract(Duration(days: currentDay - 1));
    displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));
    
    _controller.view = CalendarView.week;

    // Brand Date Joined
    _dateJoined = DateFormat('dd-MM-yyyy').parse(_brand.dateJoined!);
    // Brand Date Joined Information
    _startWorkHour =
        double.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    _endWorkHour =
        double.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);

    // Sets User Zoom vs on Scale
    //_timeSlotViewScale = await _userDataService.getUserZoomScale(
    //    widget.brandId, currentUser.id!);
    //_timeSlotViewZoom = _timeSlotViewScale * _baseTimeSlotViewZoom;
  }

  double calculateHourlyHeight(BuildContext context) {
    // The goal of this function is to calculate the height of each HOUR in the calendar.
    // This is calculated depending on the numbers of available hours vs screen height.
    // Final result
    double adjustedHeight;
    // Full screen height
    double screenHeight = MediaQuery.of(context).size.height;
    // Expanded Height of AppBar
    double expandedHeight = MediaQuery.of(context).size.height * 0.15 +
        MediaQuery.of(context).padding.top;
    if (context.isDesktop) {
      expandedHeight = desktopAppBarHeight + MediaQuery.of(context).padding.top;
    }
    // View Header Height Calendar
    viewHeaderHeight = 50;
    if (context.isDesktop) {
      viewHeaderHeight = 70;
    }
    // We're using TargetPlatform to determine the type of device
    adjustedHeight = screenHeight - expandedHeight - viewHeaderHeight;
    // Diferencia de Hores
    double difference = _endWorkHour - _startWorkHour;
    difference = _startWorkHour != 0 ? difference + 1 : difference;
    difference = _endWorkHour != 24 ? difference + 1 : difference;
    return adjustedHeight / difference;
  }

}
