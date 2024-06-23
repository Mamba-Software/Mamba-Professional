import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba/Events/crud_events/widgets/mobile/DateTime/DateEvent/TimeEventWidgetWeb.dart';
import 'package:mamba/commons/widgets/Components/CupertinoSelect/SelectDaysDialog.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Calendars/SelectCalendar/SelectCalendarDate.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Calendars/SelectCalendar/SelectCalendarOneDate.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Calendars/SelectCalendar/SelectOneTime.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/widgets/mobile/DateTime/DateEvent/DateEventWidget.dart';
import 'package:mamba/events/crud_events/widgets/mobile/DateTime/DateEvent/TimeEventWidget.dart';
import 'package:mamba/events/crud_events/widgets/mobile/DateTime/DurationEvent/DurationEventSelector.dart';

class DateEventSelector extends StatelessWidget {
  final Locale locale;
  final List<TimeOfDay> _timeSlots = [
    TimeOfDay(hour: 0, minute: 0),
    TimeOfDay(hour: 0, minute: 15),
    TimeOfDay(hour: 0, minute: 30),
    TimeOfDay(hour: 0, minute: 45),
    TimeOfDay(hour: 1, minute: 0),
    TimeOfDay(hour: 1, minute: 15),
    TimeOfDay(hour: 1, minute: 30),
    TimeOfDay(hour: 1, minute: 45),
    TimeOfDay(hour: 2, minute: 0),
    TimeOfDay(hour: 2, minute: 15),
    TimeOfDay(hour: 2, minute: 30),
    TimeOfDay(hour: 2, minute: 45),
    TimeOfDay(hour: 3, minute: 0),
    TimeOfDay(hour: 3, minute: 15),
    TimeOfDay(hour: 3, minute: 30),
    TimeOfDay(hour: 3, minute: 45),
    TimeOfDay(hour: 4, minute: 0),
    TimeOfDay(hour: 4, minute: 15),
    TimeOfDay(hour: 4, minute: 30),
    TimeOfDay(hour: 4, minute: 45),
    TimeOfDay(hour: 5, minute: 0),
    TimeOfDay(hour: 5, minute: 15),
    TimeOfDay(hour: 5, minute: 30),
    TimeOfDay(hour: 5, minute: 45),
    TimeOfDay(hour: 6, minute: 0),
    TimeOfDay(hour: 6, minute: 15),
    TimeOfDay(hour: 6, minute: 30),
    TimeOfDay(hour: 6, minute: 45),
    TimeOfDay(hour: 7, minute: 0),
    TimeOfDay(hour: 7, minute: 15),
    TimeOfDay(hour: 7, minute: 30),
    TimeOfDay(hour: 7, minute: 45),
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 8, minute: 15),
    TimeOfDay(hour: 8, minute: 30),
    TimeOfDay(hour: 8, minute: 45),
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 9, minute: 15),
    TimeOfDay(hour: 9, minute: 30),
    TimeOfDay(hour: 9, minute: 45),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 10, minute: 15),
    TimeOfDay(hour: 10, minute: 30),
    TimeOfDay(hour: 10, minute: 45),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 11, minute: 15),
    TimeOfDay(hour: 11, minute: 30),
    TimeOfDay(hour: 11, minute: 45),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 12, minute: 15),
    TimeOfDay(hour: 12, minute: 30),
    TimeOfDay(hour: 12, minute: 45),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 13, minute: 15),
    TimeOfDay(hour: 13, minute: 30),
    TimeOfDay(hour: 13, minute: 45),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 14, minute: 15),
    TimeOfDay(hour: 14, minute: 30),
    TimeOfDay(hour: 14, minute: 45),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 15, minute: 15),
    TimeOfDay(hour: 15, minute: 30),
    TimeOfDay(hour: 15, minute: 45),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 16, minute: 15),
    TimeOfDay(hour: 16, minute: 30),
    TimeOfDay(hour: 16, minute: 45),
    TimeOfDay(hour: 17, minute: 0),
    TimeOfDay(hour: 17, minute: 15),
    TimeOfDay(hour: 17, minute: 30),
    TimeOfDay(hour: 17, minute: 45),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 18, minute: 15),
    TimeOfDay(hour: 18, minute: 30),
    TimeOfDay(hour: 18, minute: 45),
    TimeOfDay(hour: 19, minute: 0),
    TimeOfDay(hour: 19, minute: 15),
    TimeOfDay(hour: 19, minute: 30),
    TimeOfDay(hour: 19, minute: 45),
    TimeOfDay(hour: 20, minute: 0),
    TimeOfDay(hour: 20, minute: 15),
    TimeOfDay(hour: 20, minute: 30),
    TimeOfDay(hour: 20, minute: 45),
    TimeOfDay(hour: 21, minute: 0),
    TimeOfDay(hour: 21, minute: 15),
    TimeOfDay(hour: 21, minute: 30),
    TimeOfDay(hour: 21, minute: 45),
    TimeOfDay(hour: 22, minute: 0),
    TimeOfDay(hour: 22, minute: 15),
    TimeOfDay(hour: 22, minute: 30),
    TimeOfDay(hour: 22, minute: 45),
    TimeOfDay(hour: 23, minute: 0),
    TimeOfDay(hour: 23, minute: 15),
    TimeOfDay(hour: 23, minute: 30),
    TimeOfDay(hour: 23, minute: 45),
  ];
  DateEventSelector({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    //_generateTimeSlots();
    return BlocSelector<CrudEventCubit, CrudEventLoaded, DateTime>(
        selector: (state) {
      return state.newEvent.startDate!;
    }, builder: (context, startDate) {
      return Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
        child: Column(
          children: [
            dateEventWidget(context, startDate,
                context.read<CrudEventCubit>().state.isBeforeEdit, locale),
            kIsWeb
                ? timeEventWidgetWeb(
                    context,
                    startDate,
                    context.read<CrudEventCubit>().state.isBeforeEdit,
                    locale,
                    TimeOfDay.fromDateTime(startDate),
                    TimeOfDay.fromDateTime(startDate),
                    _getTimeStrings())
                : timeEventWidget(context, startDate,
                    context.read<CrudEventCubit>().state.isBeforeEdit, locale),
            DurationEventSelector(
              locale: locale,
            ),
          ],
        ),
      );
    });
  }

  List<String> _getTimeStrings() {
    return _timeSlots.map((time) => _formatTimeOfDay(time)).toList();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat('HH:mm'); // use 'HH:mm' for 24 hour format
    return format.format(dt);
  }

  void _generateTimeSlots() {
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 15) {
        _timeSlots.add(TimeOfDay(hour: hour, minute: minute));
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? selectedTime = TimeOfDay.fromDateTime(DateTime.now());
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    /*
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }*/
  }

  void showDate(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    List<DateTime>? result = await showDialog<List<DateTime>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.9,
            child: SelectCalendarOneDate(
              dateJoined: DateTime.now(),
              isFuture: true,
              initialDate: DateTime.now(),
            ),
          ),
        );
      },
    );
  }

  void showTime(BuildContext context, DateTime startDate) async {
    FocusManager.instance.primaryFocus?.unfocus();
    List<DateTime>? result = await showDialog<List<DateTime>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.9,
            child: null,
          ),
        );
      },
    );
  }

  Future<int?> selectInteger(
      String text, int initial, int max, BuildContext context) async {
    int? pickedMembers = await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectDaysDialog(
              title: text,
              intialDays: initial,
              daysMax: max,
            ));
    return pickedMembers;
  }
}
