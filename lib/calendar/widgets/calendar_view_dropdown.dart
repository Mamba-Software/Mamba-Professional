import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CalendarViewDropdown extends StatefulWidget {
  final CalendarView view;
  final Function(CalendarView) onViewChanged;
  final double zoom;
  final Function(bool) onZoomToogled;

  CalendarViewDropdown({
    required this.view,
    required this.onViewChanged,
    required this.zoom,
    required this.onZoomToogled,
  });

  @override
  _CalendarViewDropdownState createState() => _CalendarViewDropdownState();
}

class _CalendarViewDropdownState extends State<CalendarViewDropdown> {
  late CalendarView dropdownValue;  
  final List<CalendarView> items = [
    CalendarView.day,
    CalendarView.week,
    CalendarView.month,
    CalendarView.schedule,
  ];

  late double zoomValueMin;
  late double zoomValue;
  late double zoomValueMax;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.view;
    zoomValue = widget.zoom;
    zoomValueMin = ((zoomValue * 100)-25); 
    zoomValueMax = ((zoomValue * 100)+25); 
  }

  @override
  void didUpdateWidget(CalendarViewDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    dropdownValue = widget.view;
    zoomValue = widget.zoom;
    zoomValueMin = ((zoomValue * 100)-25); 
    zoomValueMax = ((zoomValue * 100)+25); 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: context.theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(borderRadiusSmall),
      ),
      child: DropdownButton2(
        value: dropdownValue,
        style: context.textTheme.bodyLarge,
        underline: Container(color: Colors.transparent),
        items: [
          ...items.map((CalendarView item) {
            return DropdownMenuItem<CalendarView>(
              value: item,
              alignment: Alignment.topCenter,
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: defaultPadding),
                splashColor: context.theme.scaffoldBackgroundColor,
                hoverColor: context.theme.scaffoldBackgroundColor,
                focusColor: context.theme.scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadiusSmall),
                ),
                leading: Icon(
                  _getIconForView(item),
                  color: context.colorScheme.primary,
                  size: iconSizeMedium,
                ),
                title: Text(
                  _getTextForView(item),
                  style: context.textTheme.bodyLarge,
                  textAlign: TextAlign.start,
                ),
              ),
            );
          }),
          DropdownMenuItem<Divider>(
            enabled: false,
            child: Divider(
              color: context.theme.dividerColor,
              height: 1,
              thickness: 1,
            ),
          ),
          DropdownMenuItem(
            enabled: zoomValueMax <= 400,
            onTap: () => widget.onZoomToogled(true),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: defaultPadding),
              splashColor: context.theme.scaffoldBackgroundColor,
              hoverColor: context.theme.scaffoldBackgroundColor,
              focusColor: context.theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadiusSmall),
              ),
              leading: Icon(
                Icons.zoom_in_outlined,
                color: context.colorScheme.primary,
                size: iconSize,
              ),
              title: Text(
                "Zoom In",
                style: context.textTheme.bodyLarge,
                textAlign: TextAlign.start,
              ),
              trailing: zoomValueMax <= 400 ? Text(
                "${zoomValueMax.toStringAsFixed(0)} %",
                style: context.textTheme.labelLarge,
                textAlign: TextAlign.end,
              ) : null,
            ),
          ),
          DropdownMenuItem(
            enabled: zoomValueMin >= 100,
            onTap: () => widget.onZoomToogled(false),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: defaultPadding),
              splashColor: context.theme.scaffoldBackgroundColor,
              hoverColor: context.theme.scaffoldBackgroundColor,
              focusColor: context.theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadiusSmall),
              ),
              leading: Icon(
                Icons.zoom_out_outlined,
                color: context.colorScheme.primary,
                size: iconSize,
              ),
              title: Text(
                "Zoom Out",
                style: context.textTheme.bodyLarge,
                textAlign: TextAlign.start,
              ),
              trailing: zoomValueMin >= 100 ? Text(
                "${zoomValueMin.toStringAsFixed(0)} %",
                style: context.textTheme.labelLarge,
                textAlign: TextAlign.end,
              ) : null,
            ),
          ),
        ],
        menuItemStyleData: const MenuItemStyleData(
          customHeights: [
            45,
            45,            
            45,
            45,
            16,
            45,
            45,
          ],
          padding: EdgeInsets.zero,
        ),
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((CalendarView item) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForView(item),
                    color: context.colorScheme.primary,
                    size: iconSizeMedium,
                  ),
                  SizedBox(width: defaultPaddingSmall),
                  Text(
                    _getTextForView(item),
                    style: context.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }).toList();
        },
        // Down Arrow Icon
        iconStyleData: IconStyleData(
          icon: Padding(
            padding: EdgeInsets.only(right: defaultPadding),
            child: FaIcon(
              FontAwesomeIcons.chevronDown,
              color: context.colorScheme.primary,
              size: iconSizeExtraSmall,
            ),
          ),
          iconSize: iconSizeExtraSmall,
          iconEnabledColor: context.colorScheme.primary,
          iconDisabledColor: context.colorScheme.primary,
        ),
        dropdownStyleData: DropdownStyleData(
          width: 250,
          padding: EdgeInsets.symmetric(vertical: defaultPaddingSmall),
          decoration: BoxDecoration(
            color: context.colorScheme.background,
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadiusSmall),
            ),
          ),
          offset: Offset(0, -defaultPaddingSmall),
          elevation: 4,
        ),
        onChanged: (newValue) {
          if (newValue is CalendarView) {
            setState(() {
              dropdownValue = newValue;
              widget.onViewChanged(dropdownValue);
            });
          }
        },
      ),
    );
  }

  IconData _getIconForView(CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return Icons.calendar_view_day_outlined;
      case CalendarView.week:
        return Icons.view_week_outlined;
      case CalendarView.month:
        return Icons.calendar_today_outlined;
      case CalendarView.schedule:
        return Icons.schedule_outlined;
      default:
        return Icons.calendar_today_outlined;
    }
  }

  String _getTextForView(CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return context.l10n.day;
      case CalendarView.week:
        return context.l10n.week;
      case CalendarView.month:
        return context.l10n.month;
      case CalendarView.schedule:
        return context.l10n.schedule;
      default:
        return context.l10n.day;
    }
  }
}
