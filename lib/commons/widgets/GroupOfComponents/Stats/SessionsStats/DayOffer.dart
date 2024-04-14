import 'dart:math';

import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/app/style/Styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DayOffer extends StatefulWidget {
  List<Event> events;
  var context;

  DayOffer({
    required this.events,
    required this.context,
    super.key,
  });

  @override
  DayOfferState createState() => DayOfferState();
}

class DayOfferState extends State<DayOffer> {
  bool isLoading = true;

  // Models i base de Dades
  Brand brand = Brand();
  List<Event> filteredEvents = [];

  List<int> weekDays = [0, 0, 0, 0, 0, 0, 0];

  List<TotalEvents> totalEvents = [];

  Timestamp tm =
      Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5)));

  double maxValue = 0;
  int maxValueInt = 0;
  String maxValueStr = '';

  int totalSumClients = 0;

  @override
  void initState() {
    filteredEvents = widget.events;
    orderEvents();
    mountStat();
    isLoading = false;
    super.initState();
  }

  @override
  void didUpdateWidget(DayOffer oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredEvents = widget.events;
    weekDays = [0, 0, 0, 0, 0, 0, 0];
    totalEvents = [];
    maxValue = 0;
    maxValueInt = 0;
    maxValueStr = '';
    totalSumClients = 0;
    orderEvents();
    mountStat();
  }

  void orderEvents() {
    return filteredEvents.sort((a, b) {
      //sorting in ascending order
      return a.doneAt!.compareTo(b.doneAt!);
    });
  }

  void mountStat() {
    for (int i = 0; i < filteredEvents.length; ++i) {
      sumToWeekDay(i, 0, filteredEvents[i].numClients!);
      sumToWeekDay(i, 1, filteredEvents[i].numClients!);
      sumToWeekDay(i, 2, filteredEvents[i].numClients!);
      sumToWeekDay(i, 3, filteredEvents[i].numClients!);
      sumToWeekDay(i, 4, filteredEvents[i].numClients!);
      sumToWeekDay(i, 5, filteredEvents[i].numClients!);
      sumToWeekDay(i, 6, filteredEvents[i].numClients!);
    }

    if (totalSumClients == 0) {
      addBaseDayInTotalEvent(AppLocalizations.of(widget.context)!.mon, 0);
      addBaseDayInTotalEvent(AppLocalizations.of(widget.context)!.tue, 1);
      addBaseDayInTotalEvent(AppLocalizations.of(widget.context)!.wed, 2);
      addBaseDayInTotalEvent(AppLocalizations.of(widget.context)!.thur, 3);
      addBaseDayInTotalEvent(AppLocalizations.of(widget.context)!.fri, 4);
      addBaseDayInTotalEvent(AppLocalizations.of(widget.context)!.sat, 5);
      addBaseDayInTotalEvent(AppLocalizations.of(widget.context)!.sun, 6);
    }

    addDayInTotalEvent(AppLocalizations.of(widget.context)!.mon, 0);
    addDayInTotalEvent(AppLocalizations.of(widget.context)!.tue, 1);
    addDayInTotalEvent(AppLocalizations.of(widget.context)!.wed, 2);
    addDayInTotalEvent(AppLocalizations.of(widget.context)!.thur, 3);
    addDayInTotalEvent(AppLocalizations.of(widget.context)!.fri, 4);
    addDayInTotalEvent(AppLocalizations.of(widget.context)!.sat, 5);
    addDayInTotalEvent(AppLocalizations.of(widget.context)!.sun, 6);

    maxValueStr = '$maxValueInt%';

    totalEvents = totalEvents.reversed.toList();
  }

  void addDayInTotalEvent(String day, int number) {
    TotalEvents totalEvent;
    if (totalSumClients != 0) {
      if (roundDouble(weekDays[number] / totalSumClients, 2) * 100 > maxValue) {
        maxValue = roundDouble(weekDays[number] / totalSumClients, 2) * 100;
        maxValueInt = maxValue.round();
      }

      totalEvent =
          TotalEvents(day, roundDouble(weekDays[number] / totalSumClients, 2));
      totalEvents.add(totalEvent);
    }
  }

  void addBaseDayInTotalEvent(String day, int number) {
    TotalEvents totalEvent;
    totalEvent = TotalEvents(day, 0);
    totalEvents.add(totalEvent);
  }

  void sumToWeekDay(int i, int number, int clients) {
    int day = number + 1;
    if (filteredEvents[i].doneAt!.toDate().weekday == day) {
      totalSumClients = totalSumClients + clients;
      weekDays[number] = weekDays[number] + clients;
      //print(weekDays[number]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingView()
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.03),
                child: Center(
                    child: Container(
                        child: SfCartesianChart(
                            onDataLabelRender: (DataLabelRenderArgs args) {
                              if (args.text == maxValueStr) {
                                args.textStyle = (Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: AppColors.mainColor));
                              } else {
                                args.textStyle = (Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .primaryColorLight));
                              }
                            },
                            backgroundColor: Colors.transparent,
                            borderColor: Colors.transparent,
                            plotAreaBorderColor: Colors.transparent,
                            plotAreaBorderWidth: 1,
                            primaryYAxis: NumericAxis(
                              numberFormat: NumberFormat.percentPattern(),
                              placeLabelsNearAxisLine: true,
                              //Hide the gridlines of x-axis
                              majorGridLines: const MajorGridLines(width: 0),
                              isVisible: false,
                              //Hide the axis line of x-axis
                              axisLine: const AxisLine(width: 0),
                            ),
                            primaryXAxis: CategoryAxis(
                              majorTickLines: const MajorTickLines(
                                width: 0,
                              ),
                              labelStyle: (Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context).primaryColor)),
                              placeLabelsNearAxisLine: true,
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
                            // tooltipBehavior: _tooltipBehavior,
                            enableSideBySideSeriesPlacement: false,
                            series: <ChartSeries>[
                              // Renders line chart
                              BarSeries<TotalEvents, String>(
                                spacing: 1,
                                width: 0.3,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                borderColor: Styles.mainColor,
                                borderWidth: 0,
                                /*
                              markerSettings: MarkerSettings(
                                  isVisible: true,
                                  height:  5,
                                  width:  5,
                                  shape: DataMarkerType.circle,
                                  color: Styles.mainColor),
*/
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [
                                    AppColors.mainColor,
                                    AppColors.mainColor.withOpacity(0.2),
                                  ],
                                ),
                                dataSource: totalEvents,
                                dataLabelSettings:
                                    const DataLabelSettings(isVisible: true),
                                xValueMapper: (TotalEvents events, _) =>
                                    events.day,
                                yValueMapper: (TotalEvents events, _) =>
                                    events.percentatge,
                              )
                            ]))),
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
  TotalEvents(this.day, this.percentatge);
  final String day;
  final double percentatge;
}
