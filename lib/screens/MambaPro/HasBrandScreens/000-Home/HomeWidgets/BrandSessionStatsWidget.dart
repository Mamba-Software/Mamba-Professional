import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/app/style/Styles.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

typedef DateCallBack = void Function(int pageIndex);

class BrandSessionStatsWidget extends StatefulWidget {
  String brandId;
  final DateCallBack navigateToPage;

  BrandSessionStatsWidget(
      {super.key, required this.brandId, required this.navigateToPage});

  @override
  _BrandSessionStatsWidgetState createState() =>
      _BrandSessionStatsWidgetState();
}

class _BrandSessionStatsWidgetState extends State<BrandSessionStatsWidget> {
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  // AlL Bonos
  List<Event> filteredEvents = [];
  bool isLoading = true;
  DateTime endDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59)
      .subtract(const Duration(days: 1));

  DateTime startDate = DateTime.now().subtract(const Duration(days: 31));

  final DateFormat formatterCat = DateFormat.MMMd('ca_CAT');
  final DateFormat formatterEsp = DateFormat.MMMd('es_ES');
  DateFormat formatter = DateFormat.MMMd('es_ES');
  List<TotalEvents> totalEvents = [];
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: false);

  @override
  void initState() {
    if (currentUser.idioma == 'es') {
      formatter = formatterEsp;
    } else if (currentUser.idioma == 'ca') {
      formatter = formatterCat;
    }

    getCollections();

    super.initState();
  }

  void orderEvents() {
    return filteredEvents.sort((a, b) {
      //sorting in ascending order
      return a.doneAt!.compareTo(b.doneAt!);
    });
  }

  Future<void> getCollections() async {
    List<Event> events = [];
    events = await _brandDataService.getAllEventsFromBrandStats(widget.brandId);
    filteredEvents = events
        .where((element) =>
            element.doneAt!.compareTo(Timestamp.fromDate(startDate)) >= 0 &&
            element.doneAt!.compareTo(Timestamp.fromDate(endDate)) <= 0)
        .toList();
    setState(() {
      orderEvents();
      mountStat();
      isLoading = false;
    });
  }

  void mountStat() {
    TotalEvents totalEvent;
    String? time;
    String? time2;
    int sumEvents = 0;
    print(filteredEvents.length);
    for (int i = 0; i < filteredEvents.length; ++i) {
      time2 = formatter.format(filteredEvents[i].doneAt!.toDate());
      //print(filteredEvents[i].id);
      //print(filteredEvents[i].doneAt!.toDate());
      if (time != null && time2 != time) {
        totalEvent = TotalEvents(time, sumEvents);
        totalEvents.add(totalEvent);
        sumEvents = 1;
        if (i == filteredEvents.length - 1) {
          totalEvent = TotalEvents(time2, sumEvents);
          totalEvents.add(totalEvent);
        }
      } else {
        sumEvents = sumEvents + 1;
        if (i == filteredEvents.length - 1) {
          totalEvent = TotalEvents(time2, sumEvents);
          totalEvents.add(totalEvent);
        }
      }

      time = time2;
    }
  }

  @override
  Widget build(BuildContext context) {
    _tooltipBehavior = TooltipBehavior(enable: true, header: '');
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Material(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.35,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            minWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius:
                const BorderRadius.all(Radius.circular(15.0)), // BorderRadius
          ), // BoxDecoration
          child: Container(
            margin: const EdgeInsetsDirectional.only(
                start: 1, end: 1, bottom: 1, top: 1),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              minWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.all(Radius.circular(15.0)), // BorderRadius
            ), // BoxDecoration
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (brandIsActive) {
                              mixpanel!.track('brand_stats_view');
                              widget.navigateToPage(9);
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.leaderboard_outlined,
                                size: MediaQuery.of(context).size.width * 0.05,
                                color: AppColors.grey,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02),
                              Text(AppLocalizations.of(context)!.stats,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(color: AppColors.grey),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (brandIsActive) {
                              mixpanel!.track('brand_stats_view');
                              widget.navigateToPage(9);
                            }
                          },
                          child: Column(
                            children: [
                              Text(
                                  "${AppLocalizations.of(context)!.sessions} - 30 ${AppLocalizations.of(context)!.days.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.19,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SfCartesianChart(
                          backgroundColor: Colors.transparent,
                          borderColor: Colors.transparent,
                          plotAreaBorderColor: Colors.transparent,
                          plotAreaBorderWidth: 1,
                          primaryXAxis: CategoryAxis(
                            //Hide the gridlines of x-axis
                            majorGridLines: const MajorGridLines(width: 0),
                            isVisible: false,
                            //Hide the axis line of x-axis
                            axisLine: const AxisLine(width: 0),
                          ),
                          primaryYAxis: NumericAxis(
                            majorTickLines: const MajorTickLines(
                              width: 0,
                            ),
                            enableAutoIntervalOnZooming: false,
                            opposedPosition: true,
                            interval: 1,
                            //maximum: double.parse(maxNumber.toString()),
                            //isVisible: false,
                            //Hide the gridlines of x-axis
                            majorGridLines: const MajorGridLines(width: 0),
                            //Hide the axis line of x-axis
                            axisLine: const AxisLine(width: 0),
                          ),
                          axes: const [],
                          indicators: const [],
                          legend: null,
                          tooltipBehavior: _tooltipBehavior,
                          enableSideBySideSeriesPlacement: false,
                          series: <ChartSeries>[
                            // Renders line chart
                            SplineAreaSeries<TotalEvents, String>(
                              borderColor: Styles.mainColor,
                              borderWidth: 2,
                              markerSettings: MarkerSettings(
                                  borderColor: AppColors.mainColor,
                                  isVisible:
                                      totalEvents.length == 1 ? true : false,
                                  height: 10,
                                  width: 10,
                                  shape: DataMarkerType.circle,
                                  color: AppColors.mainColor),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Styles.mainColor,
                                  AppColors.mainColor.withOpacity(0.2),
                                ],
                              ),
                              dataSource: totalEvents,
                              xValueMapper: (TotalEvents events, _) =>
                                  events.day,
                              yValueMapper: (TotalEvents events, _) =>
                                  events.events,
                            )
                          ]),
                      filteredEvents.isEmpty
                          ? Container(
                              height: MediaQuery.of(context).size.height * 0.1,
                              width: MediaQuery.of(context).size.width * 0.50,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .background
                                      .withOpacity(0.9),
                                  border: Border.all(
                                      width: 2,
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .statsMinimumSessionBrand,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TotalEvents {
  TotalEvents(this.day, this.events);
  final String day;
  final int events;
}

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
