import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarViewDropdown extends StatefulWidget {
  final CalendarView initialView;
  final Function(CalendarView) onViewChanged;

  CalendarViewDropdown({required this.initialView, required this.onViewChanged});

  @override
  _CalendarViewDropdownState createState() => _CalendarViewDropdownState();
}

class _CalendarViewDropdownState extends State<CalendarViewDropdown> {
  late CalendarView dropdownValue;
  final List<CalendarView> items = [
    CalendarView.day,
    CalendarView.week,
    CalendarView.workWeek,
    CalendarView.month,
    CalendarView.schedule,
  ];

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.initialView;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 250,
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
      decoration: BoxDecoration(
        color: context.colorScheme.background,
        border: Border.all(
          width: 1,
          color: context.theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(
          borderRadiusSmall,
        ),
      ),
      child: Center(
        child: DropdownButtonFormField<CalendarView>(
          alignment: Alignment.bottomCenter,
          value: dropdownValue,
          icon: Icon(Icons.keyboard_arrow_down),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
            labelText: 'Select Calendar View',
            labelStyle: TextStyle(color: Colors.blue),
          ),
          dropdownColor: Colors.blue.shade100,
          items: items.map((CalendarView item) {
            return DropdownMenuItem<CalendarView>(
              value: item,
              child: Row(
                children: [
                  Icon(_getIconForView(item), color: Colors.blue),
                  SizedBox(width: 8),
                  Text(_getTextForView(item)),
                ],
              ),
            );
          }).toList(),
          onChanged: (CalendarView? newValue) {
            setState(() {
              dropdownValue = newValue!;
              widget.onViewChanged(dropdownValue);
            });
          },
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((CalendarView item) {
              return Row(
                children: [
                  Icon(Icons.check, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(_getTextForView(item), style: TextStyle(color: Colors.blue)),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  IconData _getIconForView(CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return Icons.calendar_view_day;
      case CalendarView.week:
        return Icons.view_week;
      case CalendarView.workWeek:
        return Icons.work;
      case CalendarView.month:
        return Icons.calendar_today;
      case CalendarView.schedule:
        return Icons.schedule;
      default:
        return Icons.calendar_today;
    }
  }

  String _getTextForView(CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return 'Day';
      case CalendarView.week:
        return 'Week';
      case CalendarView.workWeek:
        return 'Work Week';
      case CalendarView.month:
        return 'Month';
      case CalendarView.schedule:
        return 'Schedule';
      default:
        return 'Unknown';
    }
  }
}
