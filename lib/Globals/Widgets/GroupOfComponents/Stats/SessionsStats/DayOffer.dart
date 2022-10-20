import 'dart:math';

import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '../../../../Styles/AppColors/AppColors.dart';

class DayOffer extends StatefulWidget {
  List<Event> events;

  DayOffer({
    required this.events,
    Key? key,
  }) : super(key: key);

  @override
  DayOfferState createState() => DayOfferState();
}

class DayOfferState extends State<DayOffer> {
  bool isLoading = true;

  // Models i base de Dades
  Brand brand = Brand();
  List <Event> filteredEvents = [];

  List<int> weekDays = [0,0,0,0,0,0,0];
  ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(enablePinching: true, zoomMode: ZoomMode.x,
    enablePanning: true);
  double difference = 0;
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true, header: 'Día y número de entrenos');

  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  List<TotalEvents> totalEvents = [];
  final _brandDataService = BrandDataService();

  Timestamp tm = Timestamp.fromDate(DateTime.now().subtract(Duration(days: 5)));

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
    weekDays = [0,0,0,0,0,0,0];
    totalEvents = [];
     maxValue = 0;
     maxValueInt = 0;
     maxValueStr = '';
    totalSumClients = 0;
    orderEvents();
    mountStat();
  }

  void orderEvents()
  {
    return filteredEvents.sort((a, b){ //sorting in ascending order
      return a.doneAt!.compareTo(b.doneAt!);
    });
  }

  void mountStat()
  {
    for(int i = 0; i < filteredEvents.length; ++i) {
      sumToWeekDay(i, 0, filteredEvents[i].numClients!);
      sumToWeekDay(i, 1,filteredEvents[i].numClients!);
      sumToWeekDay(i, 2, filteredEvents[i].numClients!);
      sumToWeekDay(i, 3, filteredEvents[i].numClients!);
      sumToWeekDay(i, 4, filteredEvents[i].numClients!);
      sumToWeekDay(i, 5, filteredEvents[i].numClients!);
      sumToWeekDay(i, 6, filteredEvents[i].numClients!);
    }

    addDayInTotalEvent('Lun.', 0);
    addDayInTotalEvent('Mar.', 1);
    addDayInTotalEvent('Mierc.', 2);
    addDayInTotalEvent('Jue.', 3);
    addDayInTotalEvent('Vier.', 4);
    addDayInTotalEvent('Sab.', 5);
    addDayInTotalEvent('Dom.', 6);

    maxValueStr = maxValueInt.toString() + '%';

    totalEvents = totalEvents.reversed.toList();
    }


  void addDayInTotalEvent(String day, int number) {
    TotalEvents totalEvent;
    if(roundDouble(weekDays[number] /totalSumClients,2)*100 > maxValue)
      {
        maxValue = roundDouble(weekDays[number] /totalSumClients,2)*100;
        maxValueInt = maxValue.round();
      }
    totalEvent = new TotalEvents(day, roundDouble(weekDays[number] /totalSumClients, 2));
    totalEvents.add(totalEvent);
  }

  void sumToWeekDay(int i, int number, int clients) {
    int day = number + 1;
    if (filteredEvents[i].doneAt!.toDate().weekday == day) {
      totalSumClients = totalSumClients + clients;
      weekDays[number] = weekDays[number] + clients;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? LoadingView() :   Column(
      children: [
        Center(
                child: Container(
                    child: SfCartesianChart(
                        onDataLabelRender:(DataLabelRenderArgs args){
                          if(args.text == maxValueStr)
                            {
                              args.textStyle = (Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.mainColor))!;
                            }
                          else  args.textStyle = (Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).secondaryHeaderColor))!;


                        },
                        zoomPanBehavior: _zoomPanBehavior,
                      backgroundColor: Colors.transparent,
                        borderColor: Colors.transparent,
                        plotAreaBorderColor: Colors.transparent,
                        plotAreaBorderWidth: 1,
                        primaryYAxis: NumericAxis(

                          numberFormat: NumberFormat.percentPattern(),
                          placeLabelsNearAxisLine: true,
                          //Hide the gridlines of x-axis
                          majorGridLines: MajorGridLines(width: 0),
                          isVisible: false,
                          //Hide the axis line of x-axis
                          axisLine: AxisLine(width: 0),

                        ),
                        primaryXAxis: CategoryAxis(
                          labelStyle: (Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor))!
                          ,
                          placeLabelsNearAxisLine: true,
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
                       // tooltipBehavior: _tooltipBehavior,
                      enableSideBySideSeriesPlacement: false,
                      series: <ChartSeries>[

                        // Renders line chart
                        BarSeries<TotalEvents, String>(
                          spacing: 1,
                          width: 0.3,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
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

                              dataLabelSettings: DataLabelSettings(isVisible: true),
                              xValueMapper: (TotalEvents events, _) => events.day,
                              yValueMapper: (TotalEvents events, _) => events.percentatge,
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
  TotalEvents(this.day, this.percentatge);
  final String day;
  final double percentatge;
}
