import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarActionButton extends StatelessWidget {
  final double timeSlotViewScale;
  final CalendarView calendarView;
  final Function(bool) onCreateEventTap;

  const CalendarActionButton({
    required this.timeSlotViewScale,
    required this.calendarView,
    required this.onCreateEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (context.isMobile || context.isTablet) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CalendarSpeedDial(                
                withLabel: false,
                isDialOpen: ValueNotifier(false),
                onCreateEventTap: onCreateEventTap,                
              ),
              const SizedBox(height: 4),
              ZoomDisplayWidget(
                timeSlotViewScale: timeSlotViewScale,
                calendarView: calendarView,
              ),
            ],
          );
        } else {
          return CalendarSpeedDial(
            withLabel: true,
            isDialOpen: ValueNotifier(false),
            onCreateEventTap: onCreateEventTap,
          );
        }
      },
    );
  }
}

class CalendarSpeedDial extends StatelessWidget {
  final Function(bool) onCreateEventTap;
  final ValueNotifier<bool> isDialOpen;
  final bool withLabel;

  const CalendarSpeedDial({
    required this.onCreateEventTap,
    required this.isDialOpen,
    required this.withLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      heroTag: "46",
      animatedIcon: AnimatedIcons.add_event,
      animationDuration: Duration(milliseconds: animationDefaultDuration),
      foregroundColor: context.colorScheme.onSecondary,
      backgroundColor: context.colorScheme.secondary,
      overlayColor: context.theme.scaffoldBackgroundColor,
      overlayOpacity: 0.95,
      spacing: defaultPadding,
      spaceBetweenChildren: defaultPadding,
      openCloseDial: isDialOpen,
      label: withLabel
          ? Text(
              context.l10n.createEvent,
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: title1,
                color: context.colorScheme.onSecondary,
              ),
              textAlign: TextAlign.right,
            )
          : null,
      children: [
        SpeedDialChildWidget(
          icon: Icons.groups,
          labelText: context.l10n.groupEvent,
          labelDesc: context.l10n.groupEventDesc,
          onTap: () => onCreateEventTap(false),
        ).build(context),
        SpeedDialChildWidget(
          icon: Icons.person,
          labelText: context.l10n.privateEvent,
          labelDesc: context.l10n.privateEventDesc,
          onTap: () => onCreateEventTap(true),
        ).build(context),
      ],
    );
  }
}

class SpeedDialChildWidget {
  final IconData icon;
  final String labelText;
  final String labelDesc;
  final VoidCallback onTap;

  const SpeedDialChildWidget({
    required this.icon,
    required this.labelText,
    required this.labelDesc,
    required this.onTap,
  });

  SpeedDialChild build(BuildContext context) {
    return SpeedDialChild(
      elevation: 4,
      backgroundColor: context.colorScheme.background,
      shape: const CircleBorder(),
      child: Icon(
        icon,
        size: iconSize,
        color: context.colorScheme.onBackground,
      ),
      labelWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: defaultPaddingSmall),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              labelText,
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.right,
            ),
            Text(
              labelDesc,
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}

class ZoomDisplayWidget extends StatelessWidget {
  final double timeSlotViewScale;
  final CalendarView calendarView;

  ZoomDisplayWidget({
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