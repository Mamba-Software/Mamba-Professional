import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../Styles/AppColors/AppColors.dart';

class SessionsMade extends StatefulWidget {
  List<Event> events;
  List<Event> backEvents;

  SessionsMade({
    required this.events,
    required this.backEvents,
    Key? key,
  }) : super(key: key);

  @override
  SessionsMadeState createState() => SessionsMadeState();
}

class SessionsMadeState extends State<SessionsMade> {
  bool isLoading = true;
  // Models i base de Dades
  Brand brand = Brand();
  List <Event> filteredEvents = [], filteredBackEvents = [];
  /*ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(enablePinching: true, zoomMode: ZoomMode.x,
    enablePanning: true);*/
  double difference = 0;
  TooltipBehavior _tooltipBehavior =  TooltipBehavior(enable: false);

  final DateFormat formatterCat = DateFormat.yMMMMd('ca_CAT');
  final DateFormat formatterEsp = DateFormat.yMMMMd('es_ES');
  DateFormat formatter = DateFormat.yMMMMd('es_ES');

  List<TotalEvents> totalEvents = [];
  final _brandDataService = BrandDataService();

  @override
  void initState() {
    if(currentUser.idioma == 'es')
      {
        formatter = formatterEsp;
      }
    else if(currentUser.idioma == 'ca')
      {
        formatter = formatterCat;
      }
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

  void orderEvents()
  {
    return filteredEvents.sort((a, b){ //sorting in ascending order
      return a.doneAt!.compareTo(b.doneAt!);
    });
  }

  calculateDifference()
  {
   // print(filteredBackEvents.length);
   // print(filteredEvents.length);
    if(filteredBackEvents.length != 0 && filteredEvents.length != 0) {
      difference = ((filteredEvents.length - filteredBackEvents.length) /
          ((filteredBackEvents.length + filteredEvents.length)/2)) * 100;
      if (difference != 0) {
      //  print(difference);
        difference = roundDouble(difference, 2);
      }
    }
    else {
      difference = 0;
    }
  }

  void mountStat()
  {
    TotalEvents totalEvent;
    String? time;
    String? time2;
    int sumEvents = 0;
    for(int i = 0; i < filteredEvents.length; ++i)
      {
        time2 = formatter.format(filteredEvents[i].doneAt!.toDate());
        //print(filteredEvents[i].id);
        //print(filteredEvents[i].doneAt!.toDate());
        if(time != null && time2 != time)
          {
            totalEvent = TotalEvents(time, sumEvents);
            totalEvents.add(totalEvent);
            sumEvents = 1;
            if(i == filteredEvents.length - 1)
            {
              totalEvent = TotalEvents(time2, sumEvents);
              totalEvents.add(totalEvent);
            }
          }
        else {
          sumEvents = sumEvents + 1;
          if(i == filteredEvents.length - 1)
          {
            totalEvent = TotalEvents(time2, sumEvents);
            totalEvents.add(totalEvent);
          }
        }

        time = time2;
      }
  }

  @override
  Widget build(BuildContext context) {
    _tooltipBehavior =  TooltipBehavior(enable: true, header: AppLocalizations.of(context)!.labelSessionMade);
    return isLoading? LoadingView() :   Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left:  MediaQuery.of(context).size.width*0.06),
          child: Align(
            alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Text(
                      filteredEvents.length.toString(),
            style: Theme.of(context).textTheme.headline4?.copyWith(color: AppColors.mainColor, fontSize: 60),

          ),
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05),
                    child: Text(
                      difference < 0? difference.toString() + '%' :
                      '+' + difference.toString() + '%',
                      style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.grey),

                    ),
                  ),
                ],
              ),),
        ),
        Center(
                child: Container(
                    child: SfCartesianChart(
                      backgroundColor: Colors.transparent,
                        borderColor: Colors.transparent,
                        plotAreaBorderColor: Colors.transparent,
                        plotAreaBorderWidth: 1,
                        primaryXAxis: CategoryAxis(
                          //Hide the gridlines of x-axis
                          majorGridLines: MajorGridLines(width: 0),
                          isVisible: false,
                          //Hide the axis line of x-axis
                          axisLine: AxisLine(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          majorTickLines: MajorTickLines(
                            width: 0,
                          ),
                          enableAutoIntervalOnZooming: false,
                          opposedPosition: true,
                          interval: 1,
                          //maximum: double.parse(maxNumber.toString()),
                          //isVisible: false,
                          //Hide the gridlines of x-axis
                          majorGridLines: MajorGridLines(width: 0),
                          //Hide the axis line of x-axis
                          axisLine: AxisLine(width: 0),
                        ),
                        axes: [],
                        indicators: [],
                        legend: null,
                        tooltipBehavior: _tooltipBehavior,
                      enableSideBySideSeriesPlacement: false,
                      series: <ChartSeries>[
                          // Renders line chart
                        SplineAreaSeries<TotalEvents, String>(
                            borderColor: Styles.mainColor,
                          borderWidth: 2,
                            markerSettings: MarkerSettings(
                                isVisible: true,
                                height:  10,
                                width:  10,
                                shape: DataMarkerType.circle,
                                color: Styles.mainColor),

                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Styles.mainColor,
                                AppColors.mainColor.withOpacity(0.2),
                              ],
                            ),
                              dataSource: totalEvents,
                              xValueMapper: (TotalEvents events, _) => events.day,
                              yValueMapper: (TotalEvents events, _) => events.events,
                          )
                        ]
                    )
                )
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
