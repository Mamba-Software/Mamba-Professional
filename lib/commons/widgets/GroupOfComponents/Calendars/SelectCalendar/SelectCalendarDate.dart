import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SelectCalendarDate extends StatefulWidget {
  List<DateTime> dateRange;
  DateTime dateJoined;
  bool isFuture;
  bool acceptToday;

  SelectCalendarDate(
      {super.key,
      required this.dateRange,
      required this.dateJoined,
      required this.isFuture,
      this.acceptToday = false});

  @override
  _SelectCalendarDateState createState() => _SelectCalendarDateState();
}

class _SelectCalendarDateState extends State<SelectCalendarDate> with PlatformMixin {
  final ScrollController _controller =
      ScrollController(initialScrollOffset: 50 * 3);
  final DateRangePickerController _dateRangePickerController =
      DateRangePickerController();
  String _range = '';
  List<DateTime> dateRangeTemp = [];
  DateTime today = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    // Dates
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime tomorrow = today.add(const Duration(days: 1));
    // Define the Initial and Max Dates for the calendar
    if (widget.isFuture) {
      // Start Date as purchase date to give context:
      startDate = widget.dateRange.first;
      endDate = today
          .add(const Duration(days: 360)); // 12 months from today or tomorrow
    } else {
      startDate = DateTime(widget.dateJoined.year, 1, 1, 0, 0);
      // If acceptToday is true, we can go until today, otherwise until yesterday
      endDate = widget.acceptToday ? today : yesterday;
    }
    // Define the Initial Range
    _range = '${DateFormat('d MMM, yy\'').format(widget.dateRange.first)}  - '
        ' ${DateFormat('d MMM, yy\'').format(widget.dateRange.last)}';
    if (widget.isFuture) {
      _dateRangePickerController.displayDate = widget.dateRange.last;
    } else {
      _dateRangePickerController.displayDate = widget.dateRange.first;
    }
    super.initState();
  }

  /// The method for [DateRangePickerSelectionChanged] callback, which will be
  /// called whenever a selection changed on the date picker widget.
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    if (widget.isFuture) {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('d MMM, yy\'').format(startDate)} -'
            ' ${DateFormat('d MMM, yy\'').format(args.value.endDate ?? args.value.startDate)}';
        dateRangeTemp = [
          startDate,
          DateTime(args.value.endDate.year, args.value.endDate.month,
              args.value.endDate.day, 23, 59)
        ];
      }
    } else {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('d MMM, yy\'').format(args.value.startDate)} -'
            ' ${DateFormat('d MMM, yy\'').format(args.value.endDate ?? args.value.startDate)}';
        dateRangeTemp = [
          args.value.startDate,
          DateTime(args.value.endDate.year, args.value.endDate.month,
              args.value.endDate.day, 23, 59)
        ];
      }
    }
    setState(() {});
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
                  Text(_range,
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.left),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.005),
            const Divider(color: AppColors.grey, thickness: 1),
            widget.isFuture
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      controller: _controller,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                          vertical: MediaQuery.of(context).size.width * 0.01),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime startDateButton = startDate;
                              DateTime endDateButton = today.add(const Duration(
                                  days:
                                      6)); // For next 7 days from today/tomorrow
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDateButton, endDateButton);
                              _dateRangePickerController.displayDate =
                                  endDateButton;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.black.withOpacity(0.5)),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.comingNDays(7.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime startDateButton = startDate;
                              DateTime endDateButton =
                                  today.add(const Duration(days: 13));
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDateButton, endDateButton);
                              _dateRangePickerController.displayDate =
                                  endDateButton;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.black.withOpacity(0.5)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.comingNDays(14.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime endOfMonth =
                                  DateTime(today.year, today.month + 1);
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDate,
                                      endOfMonth
                                          .subtract(const Duration(days: 1)));
                              //_dateRangePickerController.displayDate = endOfMonth.subtract(const Duration(days: 1));
                              _dateRangePickerController.displayDate =
                                  endOfMonth.subtract(const Duration(days: 1));
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.endOfMonth,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime startDateButton = startDate;
                              DateTime endDateButton =
                                  today.add(const Duration(days: 29));
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDateButton, endDateButton);
                              _dateRangePickerController.displayDate =
                                  endDateButton;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.comingNDays(30.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime startDateButton = startDate;
                              DateTime endDateButton =
                                  today.add(const Duration(days: 59));
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDateButton, endDateButton);
                              _dateRangePickerController.displayDate =
                                  endDateButton;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.comingNDays(60.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime startDateButton = startDate;
                              DateTime endDateButton =
                                  today.add(const Duration(days: 89));
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDateButton, endDateButton);
                              _dateRangePickerController.displayDate =
                                  endDateButton;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.comingNDays(90.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ))
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      controller: _controller,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                          vertical: MediaQuery.of(context).size.width * 0.01),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime endDateButton = widget.acceptToday
                                  ? DateTime.now()
                                  : DateTime.now()
                                      .subtract(const Duration(days: 1));
                              DateTime startDateButton = endDateButton.subtract(
                                  const Duration(
                                      days:
                                          7)); // For last 7 days including today/yesterday
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDateButton, endDateButton);
                              _dateRangePickerController.displayDate =
                                  startDateButton;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.lastNDays(7.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime endDateButton = widget.acceptToday
                                  ? DateTime.now()
                                  : DateTime.now()
                                      .subtract(const Duration(days: 1));
                              DateTime startDateButton = endDateButton.subtract(
                                  const Duration(
                                      days:
                                          14)); // For last 7 days including today/yesterday
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDateButton, endDateButton);
                              _dateRangePickerController.displayDate =
                                  startDateButton;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.lastNDays(14.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime endDateButton = widget.acceptToday
                                  ? DateTime.now()
                                  : DateTime.now()
                                      .subtract(const Duration(days: 1));
                              DateTime startDateButton = endDateButton.subtract(
                                  const Duration(
                                      days:
                                          30)); // For last 7 days including today/yesterday
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDateButton, endDateButton);
                              _dateRangePickerController.displayDate =
                                  startDateButton;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.lastNDays(30.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime now = DateTime.now();
                              DateTime startDateButton = DateTime(now.year,
                                  now.month, 1); // First day of current month
                              DateTime endDateButton = widget.acceptToday
                                  ? now
                                  : now.subtract(const Duration(
                                      days: 1)); // Today or yesterday
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDateButton, endDateButton);
                              _dateRangePickerController.displayDate =
                                  startDateButton;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              "${context.l10n.thisEventAndRest.split(" ")[0]} ${StringUtils().toCapitalized(context.l10n.month)}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime now = DateTime.now();
                              DateTime startDateButton = DateTime(
                                  now.year,
                                  now.month - 1,
                                  1); // First day of previous month
                              DateTime endDateButton = DateTime(now.year,
                                  now.month, 0); // Last day of previous month
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDateButton, endDateButton);
                              _dateRangePickerController.displayDate =
                                  startDateButton;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.previousMonth,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              DateTime endDateButton = widget.acceptToday
                                  ? DateTime.now()
                                  : DateTime.now()
                                      .subtract(const Duration(days: 1));
                              DateTime startDateButton = endDateButton.subtract(
                                  const Duration(
                                      days:
                                          90)); // For last 7 days including today/yesterday
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      startDateButton, endDateButton);
                              _dateRangePickerController.displayDate =
                                  startDateButton;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.lastNDays(90.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _dateRangePickerController.selectedRange =
                                  PickerDateRange(
                                      widget.dateJoined,
                                      DateTime.now().subtract(Duration(
                                          days: widget.acceptToday ? 0 : 1)));
                              _dateRangePickerController.displayDate =
                                  widget.dateJoined;
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.black),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ))),
                            child: Text(
                              context.l10n.historic,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    )),
            const Divider(color: AppColors.grey, thickness: 1),
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
                minDate: startDate,
                maxDate: endDate,
                selectionMode: widget.isFuture
                    ? DateRangePickerSelectionMode.extendableRange
                    : DateRangePickerSelectionMode.range,
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
                initialSelectedRange: PickerDateRange(
                    widget.dateRange.first, widget.dateRange.last),
                selectionColor: Theme.of(context).primaryColor,
                selectionTextStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).primaryColorDark),
                startRangeSelectionColor: Theme.of(context).primaryColor,
                endRangeSelectionColor: Theme.of(context).primaryColor,
                rangeSelectionColor: Theme.of(context).colorScheme.background,
                extendableRangeSelectionDirection:
                    ExtendableRangeSelectionDirection.forward,
                rangeTextStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).primaryColor),
              ),
            ),
          )
        ],
      ),
      bottomSheet: GestureDetector(
        onTap: () {
          Navigator.pop(context, dateRangeTemp);
        },
        child: Container(
            height: MediaQuery.of(context).size.height * 0.09,
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: isIOS
                        ? MediaQuery.of(context).size.height * 0.01
                        : 0),
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
