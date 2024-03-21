import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
part 'CalendarFunctionState.dart';

class CalendarFunctionCubit extends Cubit<CalendarFunctionState> {
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  String selectedValue = '2';
  var items = ['0', '1', '2', '3', '4', '5', '6'];

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
  bool canEdit = false;
  // Boolean Loading
  Brand _brand = Brand();
  List<Usuario> _brandTrainers = [];
  List<Usuario> selectedTrainers = [];
  // Sesions Controller
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final CalendarController _controller = CalendarController();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  // Dies de la semana que el entrenador no treballa
  List<int> nonWorkDays = [];
  // Horari
  double? _startHour;
  double? _endHour;
  double _timeSlotViewZoom = -1;
  double _baseTimeSlotViewZoom = -1;
  double _timeSlotViewScale = 1;
  final double _baseTimeSlotViewScale = 1;
  // Descansos
  DateTime dateJoined = DateTime.now();

  // Selecte Date Time
  DateTime displayDateTimeStart = DateTime.now();
  DateTime displayDateTimeEnd = DateTime.now();
  DateTime middleMonthDate = DateTime.now();

  // Filters
  bool hasFilter = false;
  int filterEventsNumber = 0;
  List<bool> filterByCalendar = [true, true];

  DateTime? calendarDateTime;
  CalendarView? calendarView;

  CalendarFunctionCubit(context, brandId)
      : super(const CalendarFunctionInitial()) {
    emit(const CalendarFunctionLoading());
    initAppBarDateTitle();
    getUserBrandDetails(context, brandId);
    emit(CalendarFunctionLoaded(
      selectedValue: selectedValue,
      items: items,
      canEdit: canEdit,
      brand: _brand,
      brandTrainers: _brandTrainers,
      selectedTrainers: selectedTrainers,
      controller: _controller,
      nonWorkDays: nonWorkDays,
      startHour: _startHour,
      endHour: _endHour,
      timeSlotViewZoom: _timeSlotViewZoom,
      baseTimeSlotViewZoom: _baseTimeSlotViewZoom,
      timeSlotViewScale: _timeSlotViewScale,
      baseTimeSlotViewScale: _baseTimeSlotViewScale,
      dateJoined: dateJoined,
      displayDateTimeStart: displayDateTimeStart,
      displayDateTimeEnd: displayDateTimeEnd,
      middleMonthDate: middleMonthDate,
      hasFilter: hasFilter,
      filterEventsNumber: filterEventsNumber,
      filterByCalendar: filterByCalendar,
      calendarDateTime: calendarDateTime,
      calendarView: calendarView,
    ));
  }

  Future<void> initCalendar(BuildContext context, String brandId) async {
    // Initial Calendar View
    selectedValue = '2';
    _controller.view = CalendarView.week;
    //timeSlotViewZoom = _controller.view == CalendarView.week ? -1 : MediaQuery.of(context).size.height*0.15;
    // Date Joined Information
    dateJoined = DateFormat('dd-MM-yyyy').parse(_brand.dateJoined!);
    _startHour =
        double.parse(_brand.workShift[0].toStringAsFixed(2).split(".")[0]);
    _endHour =
        double.parse(_brand.workShift[1].toStringAsFixed(2).split(".")[0]);
    // Calcula el TimeSlotView per cadascuna
    _baseTimeSlotViewZoom = getScreenHeightDifference(context);
    _timeSlotViewScale =
        await _userDataService.getUserZoomScale(brandId, currentUser.id!);
    _timeSlotViewZoom = _timeSlotViewScale * _baseTimeSlotViewZoom;
  }

  // Init App Bar Title
  initAppBarDateTitle() {
    // Initial Date Time
    if (calendarDateTime == null) {
      DateTime now = DateTime.now();
      int currentDay = now.weekday;
      displayDateTimeStart = now.subtract(Duration(days: currentDay - 1));
      displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));
    } else {
      DateTime dateTime = calendarDateTime!;
      int currentDay = dateTime.weekday;
      displayDateTimeStart = dateTime.subtract(Duration(days: currentDay - 1));
      displayDateTimeEnd = displayDateTimeStart.add(const Duration(days: 6));
    }
  }

  void getUserBrandDetails(BuildContext context, String brandId) async {
    _brand = await _brandDataService.getBrandDetails(brandId);
    _brandTrainers = await _brandDataService.getBrandTrainers(brandId);
    selectedTrainers = List.from(_brandTrainers);
    for (Usuario trainer in _brandTrainers) {
      trainer.setEventsList =
          await _eventDataService.getUserEvents(trainer.id!);
    }
    if (currentUser.brandRole < 3) {
      canEdit = true;
    } else {
      canEdit = false;
    }
    initCalendar(context, brandId);
  }

  double getScreenHeightDifference(BuildContext context) {
    // The goal of this function is to calculate the height of each HOUR in the calendar. This is calculated depending on the numbers of avaiable hours (HORARI).
    // Final result
    double adjustedHeight;
    // Full screen height
    double screenHeight = MediaQuery.of(context).size.height;
    // Expanded Height of AppBar
    double expandedHeight = MediaQuery.of(context).size.height * 0.15 +
        MediaQuery.of(context).padding.top;
    // View Header Height Calendar
    double viewHeaderHeight = 50;
    // We're using TargetPlatform to determine the type of device
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
        //adjustedHeight = screenHeight - expandedHeight - viewHeaderHeight - bottomNavigationBarHeight;
        adjustedHeight = screenHeight - expandedHeight - viewHeaderHeight;
        break;
      case TargetPlatform.iOS:
        adjustedHeight = screenHeight - expandedHeight - viewHeaderHeight;
        break;
      default:
        adjustedHeight = screenHeight - expandedHeight - viewHeaderHeight;
        break;
    }
    // Diferencia de Hores
    double difference = _endHour! - _startHour!;
    difference = _startHour! != 0 ? difference + 1 : difference;
    difference = _endHour! != 24 ? difference + 1 : difference;
    return adjustedHeight / difference;
  }
}

List<Event> documentsToEvents(
    List<DocumentSnapshot> documents, List<Usuario> brandTrainers) {
  List<Event> events = [];
  List<Usuario> eventTrainers = [];
  for (int i = 0; i < documents.length; i++) {
    Event evt = Event.fromObjectOnlyCoverData(documents[i].id, documents[i]);
    // Check Trainers in Event
    for (Usuario trainer in brandTrainers) {
      int index =
          trainer.eventsList.indexWhere((element) => element.id == evt.id);
      if (index != -1) {
        eventTrainers.add(trainer);
      }
    }
    evt.setUserList = eventTrainers;
    events.add(evt);
    eventTrainers = [];
  }
  // Order By
  events.sort((a, b) {
    var aDate = a.doneAt!.toDate();
    var bDate = b.doneAt!.toDate();
    return aDate.compareTo(bDate);
  });
  // Return List of Events
  return events;
}

Event documentToEvent(DocumentSnapshot document, List<Usuario> brandTrainers) {
  List<Usuario> eventTrainers = [];
  Event evt = Event.fromObjectOnlyCoverData(document.id, document);
  // Check Trainers in Event
  for (Usuario trainer in brandTrainers) {
    int index =
        trainer.eventsList.indexWhere((element) => element.id == evt.id);
    if (index != -1) {
      eventTrainers.add(trainer);
    }
  }
  evt.setUserList = eventTrainers;
  return evt;
}
