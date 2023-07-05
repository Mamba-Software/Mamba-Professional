import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SelectCalendarDate extends StatefulWidget {
  List<DateTime> dateRange;
  DateTime dateJoined;
  bool isFuture;
  bool acceptToday;

  SelectCalendarDate({Key? key, required this.dateRange, required this.dateJoined, required this.isFuture, this.acceptToday = false}) : super(key: key);

  @override
  _SelectCalendarDateState createState() => _SelectCalendarDateState();
}

class _SelectCalendarDateState extends State<SelectCalendarDate> {

  final ScrollController _controller = ScrollController(initialScrollOffset: 50 * 3);
  final DateRangePickerController _dateRangePickerController = DateRangePickerController();
  String _range = '';
  List<DateTime> dateRangeTemp = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    // Define the Initial and Max Dates for the calendar
    /// SELECT PAST DATES
    if (widget.isFuture) {
      startDate = widget.dateRange.first;
      endDate = DateTime.now().add(const Duration(days: 30*3));
      endDate = endDate.add(const Duration(days: 1));
    } else {
      startDate = DateTime(widget.dateJoined.year, 1, 1, 0, 0);
      if (widget.acceptToday == false) {
        endDate = DateTime.now().subtract(const Duration(days: 1));
      } else {
        endDate = DateTime.now();
      }
    }
    // Define the Initial Range
    _range = '${DateFormat('d MMM, yy\'').format(widget.dateRange.first)}  - '' ${DateFormat('d MMM, yy\'').format(widget.dateRange.last)}';
    _dateRangePickerController.displayDate = widget.dateRange.first;
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
        _range = '${DateFormat('d MMM, yy\'').format(startDate)} -'' ${DateFormat('d MMM, yy\'').format(args.value.endDate ?? args.value.startDate)}';
        dateRangeTemp = [startDate, DateTime(args.value.endDate.year,args.value.endDate.month,args.value.endDate.day, 23, 59)];
      }
    } else {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('d MMM, yy\'').format(args.value.startDate)} -'' ${DateFormat('d MMM, yy\'').format(args.value.endDate ?? args.value.startDate)}';
        dateRangeTemp = [args.value.startDate, DateTime(args.value.endDate.year,args.value.endDate.month,args.value.endDate.day, 23, 59)];
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.15,
        titleSpacing: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.01),
            Container(
              height: MediaQuery.of(context).size.height*0.007,
              width: MediaQuery.of(context).size.width*0.15,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.015),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      _range,
                      style: Theme.of(context).textTheme.headline3,
                      textAlign: TextAlign.left
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.005),
            Divider(color: Theme.of(context).backgroundColor, thickness: 1),
            widget.isFuture ?
            SizedBox(
              height: MediaQuery.of(context).size.height*0.05,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                controller: _controller,
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _dateRangePickerController.selectedRange = PickerDateRange(startDate, startDate.add(const Duration(days: 7)));
                        //_dateRangePickerController.displayDate = startDate.add(const Duration(days: 7));
                        _dateRangePickerController.displayDate = startDate;
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(6),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.comingNDays(7.toString()),
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _dateRangePickerController.selectedRange = PickerDateRange(startDate, startDate.add(const Duration(days: 14)));
                        _dateRangePickerController.displayDate = startDate;
                        //_dateRangePickerController.displayDate = startDate.add(const Duration(days: 14));
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(6),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.comingNDays(14.toString()),
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        DateTime endOfMonth = DateTime(startDate.year, startDate.month+1);
                        _dateRangePickerController.selectedRange = PickerDateRange(startDate, endOfMonth.subtract(const Duration(days: 1)));
                        //_dateRangePickerController.displayDate = endOfMonth.subtract(const Duration(days: 1));
                        _dateRangePickerController.displayDate = startDate;
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(6),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.endOfMonth,
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _dateRangePickerController.selectedRange = PickerDateRange(startDate, startDate.add(const Duration(days: 30)));
                        //_dateRangePickerController.displayDate = startDate.add(const Duration(days: 30));
                        _dateRangePickerController.displayDate = startDate;
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(6),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.comingNDays(30.toString()),
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _dateRangePickerController.selectedRange = PickerDateRange(startDate, startDate.add(const Duration(days: 60)));
                        //_dateRangePickerController.displayDate = startDate.add(const Duration(days: 60));
                        _dateRangePickerController.displayDate = startDate;
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(6),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.comingNDays(60.toString()),
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _dateRangePickerController.selectedRange = PickerDateRange(startDate, startDate.add(const Duration(days: 90)));
                        //_dateRangePickerController.displayDate = startDate.add(const Duration(days: 90));
                        _dateRangePickerController.displayDate = startDate;
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(6),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.comingNDays(90.toString()),
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              )
            ) :
            SizedBox(
              height: MediaQuery.of(context).size.height*0.04,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                controller: _controller,
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _dateRangePickerController.selectedRange = PickerDateRange(DateTime.now().subtract(const Duration(days: 8)), DateTime.now().subtract(Duration(days: widget.acceptToday ? 0 : 1)));
                        _dateRangePickerController.displayDate = DateTime.now().subtract(const Duration(days: 8));
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(6),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.lastNDays(7.toString()),
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _dateRangePickerController.selectedRange = PickerDateRange(DateTime.now().subtract(const Duration(days: 15)), DateTime.now().subtract(Duration(days: widget.acceptToday ? 0 : 1)));
                        _dateRangePickerController.displayDate = DateTime.now().subtract(const Duration(days: 15));
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all( 12),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.lastNDays(14.toString()),
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _dateRangePickerController.selectedRange = PickerDateRange(DateTime.now().subtract(const Duration(days: 31)), DateTime.now().subtract(Duration(days: widget.acceptToday ? 0 : 1)));
                        _dateRangePickerController.displayDate = DateTime.now().subtract(const Duration(days: 31));
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all( 12),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.lastNDays(30.toString()),
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        DateTime now = DateTime.now();
                        DateTime firstDayOfMonth = DateTime(now.year, now.month-1, 1);
                        DateTime lastDayOfMonth = DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
                        _dateRangePickerController.selectedRange = PickerDateRange(firstDayOfMonth, lastDayOfMonth);
                        _dateRangePickerController.displayDate = firstDayOfMonth;
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all( 12),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.previousMonth,
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _dateRangePickerController.selectedRange = PickerDateRange(DateTime.now().subtract(const Duration(days: 91)), DateTime.now().subtract(Duration(days: widget.acceptToday ? 0 : 1)));
                        _dateRangePickerController.displayDate = DateTime.now().subtract(const Duration(days: 91));
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all( 12),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.lastNDays(90.toString()),
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _dateRangePickerController.selectedRange = PickerDateRange(widget.dateJoined, DateTime.now().subtract(Duration(days: widget.acceptToday ? 0 : 1)));
                        _dateRangePickerController.displayDate = widget.dateJoined;
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all( 12),
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )
                          )
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.historic,
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              )
            ),
            Divider(color: Theme.of(context).backgroundColor, thickness: 1),
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
              margin: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05, left: MediaQuery.of(context).size.width*0.05, bottom: MediaQuery.of(context).size.width*0.05),
              child: SfDateRangePicker(
                controller: _dateRangePickerController,
                onSelectionChanged: _onSelectionChanged,
                minDate: startDate,
                maxDate: endDate,
                selectionMode: widget.isFuture ? DateRangePickerSelectionMode.extendableRange : DateRangePickerSelectionMode.range,
                todayHighlightColor: Theme.of(context).primaryColor,
                enableMultiView: true,
                navigationMode: DateRangePickerNavigationMode.scroll,
                navigationDirection: DateRangePickerNavigationDirection.vertical,
                headerHeight: MediaQuery.of(context).size.height*0.05,
                headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.left,
                    textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor
                ),
                monthFormat: 'MMMM',
                monthCellStyle: DateRangePickerMonthCellStyle(
                  textStyle: Theme.of(context).textTheme.bodyText2,
                  todayTextStyle: Theme.of(context).textTheme.bodyText2,
                  todayCellDecoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent, width: 1),
                    shape: BoxShape.circle
                  ),
                  disabledDatesTextStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).backgroundColor.withOpacity(0.89)),
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  firstDayOfWeek: 1,
                  numberOfWeeksInView: 6,
                  dayFormat: 'E',
                  enableSwipeSelection: false,
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 12),
                  ),
                ),
                initialSelectedRange: PickerDateRange(widget.dateRange.first, widget.dateRange.last),
                selectionColor: Theme.of(context).primaryColor,
                selectionTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),
                startRangeSelectionColor: Theme.of(context).primaryColor,
                endRangeSelectionColor: Theme.of(context).primaryColor,
                rangeSelectionColor: Theme.of(context).backgroundColor,
                extendableRangeSelectionDirection: ExtendableRangeSelectionDirection.forward,
                rangeTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
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
          height: MediaQuery.of(context).size.height*0.09,
          width: double.infinity,
          color: Theme.of(context).primaryColor,
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: Platform.isIOS ? MediaQuery.of(context).size.height * 0.01 : 0),
              child: Text(
                AppLocalizations.of(context)!.confirm,
                style: Theme.of(context).textTheme.headline1?.copyWith(color: Theme.of(context).primaryColorDark),
              ),
            ),
          )
        ),
      ),
    );
  }
}

