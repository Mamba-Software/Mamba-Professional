import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SelectCalendarDate extends StatefulWidget {
  String brandId;

  SelectCalendarDate({Key? key, required this.brandId}) : super(key: key);

  @override
  _SelectCalendarDateState createState() => _SelectCalendarDateState();
}

class _SelectCalendarDateState extends State<SelectCalendarDate> {

  // App Bar and Scroll View
  ScrollController? _scrollController;
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  // Bool Max Images Added
  bool maxImagesAdded = false;
  // Max Number of Images
  final int _maxImages = 10;
  // Images uploaded
  List<ImageObject> _imagesUploaded = [];
  List<Widget> imageSliders = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    isLoading = true;
  }

  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

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
    setState(() {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
        // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
    print('Selected date: $_selectedDate');
    print('Selected date count: $_dateCount');
    print('Selected range: $_range');
    print('Selected ranges count: $_rangeCount');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.18,
        titleSpacing: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.02),
            Container(
              height: MediaQuery.of(context).size.height*0.007,
              width: MediaQuery.of(context).size.width*0.15,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.left
                      )
                  ),
                  Text(
                      _range,
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.left
                  ),
                  TextButton(
                      onPressed: () {

                      },
                      child: Text(
                          AppLocalizations.of(context)!.update,
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.left
                      )
                  ),
                ],
              ),
            ),
            Divider(color: Theme.of(context).backgroundColor, thickness: 1),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.left
                      )
                  ),
                  TextButton(
                      onPressed: () {

                      },
                      child: Text(
                          AppLocalizations.of(context)!.update,
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.left
                      )
                  ),
                ],
              ),
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.02),
              child: SfDateRangePicker(
                onSelectionChanged: _onSelectionChanged,
                minDate: DateTime(2020, 02, 05),
                maxDate: DateTime.now().subtract(const Duration(days: 1)),
                selectionMode: DateRangePickerSelectionMode.range,
                todayHighlightColor: Theme.of(context).primaryColor,
                enableMultiView: true,
                navigationMode: DateRangePickerNavigationMode.scroll,
                navigationDirection: DateRangePickerNavigationDirection.vertical,
                headerHeight: MediaQuery.of(context).size.height*0.05,
                headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.left,
                    textStyle: Theme.of(context).textTheme.headline3,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor
                ),
                monthFormat: 'LLLL',
                monthCellStyle: DateRangePickerMonthCellStyle(
                  textStyle: Theme.of(context).textTheme.bodyText2,
                  todayCellDecoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent, width: 1),
                    shape: BoxShape.circle
                  ),
                  disabledDatesTextStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).backgroundColor.withOpacity(0.89)),
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  firstDayOfWeek: 1,
                  dayFormat: 'E',
                  enableSwipeSelection: false,
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: Theme.of(context).textTheme.caption,
                  ),
                ),
                selectionTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),
                startRangeSelectionColor: Theme.of(context).primaryColor,
                endRangeSelectionColor: Theme.of(context).primaryColor,
                rangeSelectionColor: Theme.of(context).primaryColorDark.withOpacity(0.5),
                rangeTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
              ),
            ),
          )
        ],
      )
    );
  }
}

