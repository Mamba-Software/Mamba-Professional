import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SessionsMade extends StatefulWidget {
  List<Event> events;
  List<Event> backEvents;
  bool? isYearly;
  SessionsMade({
    required this.events,
    required this.backEvents,
    required this.isYearly,
    Key? key,
  }) : super(key: key);

  @override
  SessionsMadeState createState() => SessionsMadeState();
}

class SessionsMadeState extends State<SessionsMade> {

  // Boolean is Loading
  bool isLoading = true;
  bool isYearly = true;
  // Events and Difference
  List<Event> filteredEvents = [], filteredBackEvents = [];
  double difference = 0;
  TooltipBehavior _tooltipBehavior =  TooltipBehavior(enable: false);
  // Date Formatter
  final DateFormat formatterCat = DateFormat.MMM('ca_CAT');
  final DateFormat formatterEsp = DateFormat.MMM('es_ES');
  DateFormat formatter = DateFormat.MMMM('es_ES');
  // Chart Data
  List<TotalEvents> chartDataYear = [];
  List<TotalEvents> chartDataSixMonths = [];

  @override
  void initState() {
    if (currentUser.idioma == 'es') {
      formatter = formatterEsp;
    } else if(currentUser.idioma == 'ca') {
      formatter = formatterCat;
    }
    isYearly = widget.isYearly!;
    filteredEvents = widget.events;
    filteredBackEvents = widget.backEvents;
    mountStat();
    super.initState();
  }

  @override
  void didUpdateWidget(SessionsMade oldWidget) {
    isYearly = widget.isYearly!;
    filteredEvents = widget.events;
    filteredBackEvents = widget.backEvents;
    mountStat();
    super.didUpdateWidget(oldWidget);
  }

  void mountStat() {
    // Only when there are events
    if (filteredEvents.isNotEmpty) {
      // Sort Events
      filteredEvents.sort((a, b){ //sorting in ascending order
        return a.doneAt!.compareTo(b.doneAt!);
      });
      List<Event> eventList = List.from(filteredEvents);
      // Get Current Month
      DateTime now = DateTime.now();
      DateTime currentMonth = DateTime(now.year, now.month, 20);
      // Create Temp Variables
      int totalEventsNumber = eventList.length;
      List<TotalEvents> yearList = [];
      List<TotalEvents> sixMonthsList = [];
      // Iterate 12 Months Back
      for (var i=0; i<12; i++) {
        // Get Number of Events in current Month
        eventList.removeWhere((element) => element.month == currentMonth.month.toString());
        int numberOfEvents = totalEventsNumber-eventList.length;
        // Get month String
        String month = StringUtils().toCapitalized(formatter.format(currentMonth));
        // Build Total Events Object
        TotalEvents chartEntry = TotalEvents(month, numberOfEvents);
        // Add to Temp Variables
        yearList.insert(0, chartEntry);
        if (i<6) sixMonthsList.insert(0,chartEntry);
        // Update Values
        totalEventsNumber = eventList.length;
        currentMonth = currentMonth.subtract(const Duration(days: 30));
      }
      // Update Global Values
      chartDataYear = yearList;
      chartDataSixMonths = sixMonthsList;
    } else {
      // Get Current Month
      DateTime now = DateTime.now();
      DateTime currentMonth = DateTime(now.year, now.month, 20);
      // Create Temp Variables
      List<TotalEvents> yearList = [];
      List<TotalEvents> sixMonthsList = [];
      // Iterate 12 Months Back
      for (var i=0; i<12; i++) {
        // Get month String
        String month = StringUtils().toCapitalized(formatter.format(currentMonth));
        // Build Total Events Object
        TotalEvents chartEntry = TotalEvents(month, (currentMonth.month*Random().nextInt(i+1)));
        // Add to Temp Variables
        yearList.insert(0, chartEntry);
        if (i<6) sixMonthsList.insert(0,chartEntry);
        // Update Values
        currentMonth = currentMonth.subtract(const Duration(days: 30));
        // Update Global Values
        chartDataYear = yearList;
        chartDataSixMonths = sixMonthsList;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _tooltipBehavior =  TooltipBehavior(
      enable: filteredEvents.isNotEmpty ? true : false,
      header: '',
      color: Theme.of(context).primaryColor
    );
    return SizedBox(
      height: MediaQuery.of(context).size.height*0.25,
      width: MediaQuery.of(context).size.width*0.9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SfCartesianChart(
              margin: const EdgeInsets.all(0),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              //borderColor: AppColors.grey,
              plotAreaBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
              plotAreaBorderColor: AppColors.grey,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelAlignment: LabelAlignment.center,
                plotOffset: 0,
                isVisible: true,
                interval: 1,
                minorTicksPerInterval: 1,
                // Major Lines
                majorGridLines: const MajorGridLines(width: 0),
                majorTickLines: const MajorTickLines(width: 0.5, color: Colors.transparent),
                // Minor Lines
                minorGridLines: const MinorGridLines(
                    width: 0.5,
                    color: AppColors.grey,
                    dashArray: <double>[5,20]
                ),
                minorTickLines: null,
                tickPosition: TickPosition.inside,
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                isVisible: false,
                maximumLabelWidth: 0,
                // Major Lines
                majorGridLines: const MajorGridLines(width: 0.5,
                    color: AppColors.grey,
                    dashArray: <double>[5,20]
                ),
                majorTickLines: const MajorTickLines(width: 0.5, color: Colors.transparent),
                // Minor Lines
                minorGridLines: const MinorGridLines(
                    width: 0.5,
                    color: AppColors.grey,
                    dashArray: <double>[5,20]
                ),
                minorTickLines: null,
                enableAutoIntervalOnZooming: false,
                opposedPosition: true,
                interval: 1,
                //Hide the axis line of x-axis
                axisLine: const AxisLine(width: 0),
              ),
              enableSideBySideSeriesPlacement: false,
              axes: [],
              indicators: [],
              legend: null,
              tooltipBehavior: _tooltipBehavior,
              series: <ChartSeries>[
                // Renders line chart
                SplineAreaSeries<TotalEvents, String>(
                  animationDuration: 0,
                  borderColor: Styles.mainColor,
                  borderWidth: 5,
                  emptyPointSettings: EmptyPointSettings(
                      mode: EmptyPointMode.gap,
                      color: Colors.red,
                      borderColor: Colors.black,
                      borderWidth: 2
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Styles.mainColor,
                      AppColors.mainColor.withOpacity(0.2),
                    ],
                  ),
                  dataSource: isYearly ? chartDataYear : chartDataSixMonths,
                  xValueMapper: (TotalEvents events, _) => events.month,
                  yValueMapper: (TotalEvents events, _) => events.events,
                )
              ]
          ),
          filteredEvents.isEmpty ? Container(
            height: MediaQuery.of(context).size.height*0.1,
            width: MediaQuery.of(context).size.width*0.50,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor.withOpacity(0.9),
                border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(10)
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.statsMinimumSession(5.toString()),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ) : Container(),
        ],
      ),
    );

  }

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

}

class TotalEvents {
  TotalEvents(this.month, this.events);
  final String month;
  final int events;
}
