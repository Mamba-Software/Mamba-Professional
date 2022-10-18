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

  DateRangePickerNavigationMode _navigationMode = DateRangePickerNavigationMode.scroll;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        toolbarHeight: MediaQuery.of(context).size.height*0.1,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Selected date: $_selectedDate'),
                Text('Selected date count: $_dateCount'),
                Text('Selected range: $_range'),
                Text('Selected ranges count: $_rangeCount')
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 80,
            right: 0,
            bottom: 0,
            child: SfDateRangePicker(
              enableMultiView: true,
              navigationDirection: DateRangePickerNavigationDirection.vertical,
              selectionMode: DateRangePickerSelectionMode.range,
              headerHeight: 0,
              headerStyle: DateRangePickerHeaderStyle(backgroundColor: Theme.of(context).scaffoldBackgroundColor),
              monthViewSettings: const DateRangePickerMonthViewSettings(enableSwipeSelection: false),
              navigationMode: _navigationMode,
            )
          )
        ],
      )
    );
  }
}

