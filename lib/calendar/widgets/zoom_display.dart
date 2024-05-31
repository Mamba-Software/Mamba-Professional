import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ZoomDisplay extends StatelessWidget {
  final double timeSlotViewScale;
  final CalendarView calendarView;

  ZoomDisplay({
    required this.timeSlotViewScale,
    required this.calendarView,
  });

  @override
  Widget build(BuildContext context) {
    return calendarView == CalendarView.week || calendarView == CalendarView.day
        ? Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.colorScheme.background,
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadiusMedium),
              ),
            ),
            child: Text(
              "Zoom: ${(timeSlotViewScale * 100).toStringAsFixed(0)} %",
              style: context.textTheme.bodySmall?.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        )
        : Container();
  }
}
