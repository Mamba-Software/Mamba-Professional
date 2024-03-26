import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/Styles.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SessionsMade extends StatefulWidget {
  List<Event> events;
  List<Event> backEvents;

  SessionsMade({
    required this.events,
    required this.backEvents,
    super.key,
  });

  @override
  SessionsMadeState createState() => SessionsMadeState();
}

class SessionsMadeState extends State<SessionsMade> {
  bool isLoading = true;
  // Models i base de Dades
  Brand brand = Brand();
  List<Event> filteredEvents = [], filteredBackEvents = [];
  /*ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(enablePinching: true, zoomMode: ZoomMode.x,
    enablePanning: true);*/
  double difference = 0;
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: false);

  final DateFormat formatterCat = DateFormat.MMMd('ca_CAT');
  final DateFormat formatterEsp = DateFormat.MMMd('es_ES');
  DateFormat formatter = DateFormat.MMMd('es_ES');

  List<TotalEvents> totalEvents = [];
  final _brandDataService = BrandDataService();

  @override
  void initState() {
    if (currentUser.idioma == 'es') {
      formatter = formatterEsp;
    } else if (currentUser.idioma == 'ca') {
      formatter = formatterCat;
    }
    //print(filteredEvents);
    filteredEvents = widget.events;
    filteredBackEvents = widget.backEvents;
    orderEvents();
    calculateDifference();
    mountStat();
    isLoading = false;
    super.initState();
  }

  @override
  void didUpdateWidget(SessionsMade oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredEvents = widget.events;
    filteredBackEvents = widget.backEvents;
    totalEvents = [];
    calculateDifference();
    orderEvents();
    mountStat();
  }

  void orderEvents() {
    return filteredEvents.sort((a, b) {
      //sorting in ascending order
      return a.doneAt!.compareTo(b.doneAt!);
    });
  }

  calculateDifference() {
    // print(filteredBackEvents.length);
    // print(filteredEvents.length);
    if (filteredBackEvents.isNotEmpty && filteredEvents.isNotEmpty) {
      difference = ((filteredEvents.length - filteredBackEvents.length) /
              ((filteredBackEvents.length + filteredEvents.length) / 2)) *
          100;
      if (difference != 0) {
        //  print(difference);
        difference = roundDouble(difference, 2);
      }
    } else {
      difference = 0;
    }
  }

  void mountStat() {
    TotalEvents totalEvent;
    String? time;
    String? time2;
    int sumEvents = 0;
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
    return isLoading
        ? LoadingView()
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        filteredEvents.length.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                color: AppColors.mainColor, fontSize: 45),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05),
                        child: Text(
                          difference < 0
                              ? '${difference.toStringAsFixed(2)}%'
                              : '+${difference.toStringAsFixed(2)}%',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.03),
                child: Center(
                    child: Stack(
                  alignment: Alignment.center,
                  children: [
                    filteredEvents.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.07),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: Image.asset(Assets.emptyCalendar)),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.005),
                              Text(
                                AppLocalizations.of(context)!.noData,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.05),
                            ],
                          )
                        : Container(),
                    Container(
                        child: Column(
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
                      ],
                    )),
                  ],
                )),
              ),
            ],
          );
  }

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
}

class TotalEvents {
  TotalEvents(this.day, this.events);
  final String day;
  final int events;
}
