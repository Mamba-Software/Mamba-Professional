import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SelectCalendarOneDate extends StatefulWidget {
  DateTime initialDate;
  DateTime dateJoined;
  bool isFuture;
  bool acceptToday;

  SelectCalendarOneDate({
    super.key,
    required this.initialDate,
    required this.dateJoined,
    required this.isFuture,
    this.acceptToday = false,
  });

  @override
  _SelectCalendarOneDateState createState() => _SelectCalendarOneDateState();
}

class _SelectCalendarOneDateState extends State<SelectCalendarOneDate>
    with PlatformMixin {
  final ScrollController _controller =
      ScrollController(initialScrollOffset: 50 * 3);
  final DateRangePickerController _dateRangePickerController =
      DateRangePickerController();
  String _selectedDateText = '';
  DateTime? selectedDate;
  DateTime? minDate;
  DateTime? maxDate;

  @override
  void initState() {
    super.initState();

    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (widget.isFuture) {
      minDate = widget.initialDate;
      maxDate = today.add(const Duration(days: 360));
    } else {
      minDate = DateTime(widget.dateJoined.year, 1, 1, 0, 0);
      maxDate = widget.acceptToday ? today : yesterday;
    }

    selectedDate = widget.initialDate;
    _selectedDateText = DateFormat('d MMM, yy').format(widget.initialDate);
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is DateTime) {
      setState(() {
        selectedDate = args.value;
        _selectedDateText = DateFormat('d MMM, yy').format(selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.15,
        titleSpacing: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              height: MediaQuery.of(context).size.height * 0.007,
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_selectedDateText,
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.left),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.005),
            const Divider(color: AppColors.grey, thickness: 1),
            // Future buttons can go here if needed
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.05,
                  left: MediaQuery.of(context).size.width * 0.05,
                  bottom: MediaQuery.of(context).size.height * 0.09),
              child: SfDateRangePicker(
                controller: _dateRangePickerController,
                onSelectionChanged: _onSelectionChanged,
                minDate: minDate,
                maxDate: maxDate,
                selectionMode: DateRangePickerSelectionMode.single,
                todayHighlightColor: Theme.of(context).primaryColor,
                enableMultiView: true,
                navigationMode: DateRangePickerNavigationMode.scroll,
                navigationDirection:
                    DateRangePickerNavigationDirection.vertical,
                headerHeight: MediaQuery.of(context).size.height * 0.05,
                headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.left,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor),
                monthFormat: 'MMMM',
                monthCellStyle: DateRangePickerMonthCellStyle(
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                  todayTextStyle: Theme.of(context).textTheme.bodyMedium,
                  todayCellDecoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent, width: 1),
                      shape: BoxShape.circle),
                  specialDatesTextStyle: Theme.of(context).textTheme.bodyMedium,
                  specialDatesDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    border: Border.all(
                        width: 1, color: Theme.of(context).primaryColor),
                    shape: BoxShape.circle,
                  ),
                  disabledDatesTextStyle: Theme.of(context).textTheme.bodySmall,
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  firstDayOfWeek: 1,
                  numberOfWeeksInView: 6,
                  dayFormat: 'E',
                  enableSwipeSelection: false,
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 12),
                  ),
                  specialDates: <DateTime>[widget.dateJoined],
                ),
                allowViewNavigation: false,
                initialSelectedDate: widget.initialDate,
                selectionColor: Theme.of(context).primaryColor,
                selectionTextStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).primaryColorDark),
              ),
            ),
          )
        ],
      ),
      bottomSheet: GestureDetector(
        onTap: () {
          Navigator.pop(context, selectedDate);
        },
        child: Container(
            height: MediaQuery.of(context).size.height * 0.09,
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom:
                        isIOS ? MediaQuery.of(context).size.height * 0.01 : 0),
                child: Text(
                  context.l10n.confirm,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(color: Theme.of(context).primaryColorDark),
                ),
              ),
            )),
      ),
    );
  }
}
