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

class TimeToTimeOffer extends StatefulWidget {
  List<Event> events;

  TimeToTimeOffer({
    required this.events,
    Key? key,
  }) : super(key: key);

  @override
  TimeToTimeOfferState createState() => TimeToTimeOfferState();
}

class TimeToTimeOfferState extends State<TimeToTimeOffer> {
  bool isLoading = true;

  // Models i base de Dades
  Brand brand = Brand();
  List <Event> filteredEvents = [];

  Map<String, int> mapHours = {};

  List<TimeDemand> timeDemand = [];

  String timeOffered = '';

  final DateFormat formatter = DateFormat.Hm();



  @override
  void initState() {
    filteredEvents = widget.events;
    orderEvents();
    mountStat();
    isLoading = false;
    super.initState();
  }

  @override
  void didUpdateWidget(TimeToTimeOffer oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredEvents = widget.events;
    timeOffered = '';
    timeDemand = [];
    mapHours.clear();
    orderEvents();
    mountStat();
    orderTimeOffer();
  }

  void orderEvents()
  {
    return filteredEvents.sort((a, b){ //sorting in ascending order
      if(int.parse(a.hour!) == int.parse(b.hour!))
        {
          if(int.parse(a.minute!) >= int.parse(b.minute!))
            {
              return 1;
            }
          else return 0;
        }
      else if(int.parse(a.hour!) > int.parse(b.hour!))
      {
        return 1;
      }
      else return 0;
    });
  }

  void orderTimeOffer()
  {

  }

  void mountStat() {
    String hourMinuteIni = '';
    String hourMinuteEnd = '';
    String totalHour = '';
    double hourMinuteEndVal = 0;
    int maxHour = 0;
    int hoursFinal,
        minutesFinal = 0;
    String minute = '';
    String hour = '';
    Event event;
    DateTime dt = DateTime.now();
    for (int i = 0; i < filteredEvents.length; ++i) {
      event = filteredEvents[i];
      var startDate = DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      var hour = event.duration.toString().split(".")[0];
      var min = event.duration!.toStringAsFixed(2).split(".")[1];
      var endDate = startDate.add(
          Duration(hours: int.parse(hour), minutes: int.parse(min)));
      print((DateFormat.Hm().format(startDate)));
      print((DateFormat.Hm().format(startDate)));

      totalHour = DateFormat.Hm().format(startDate) + ' - ' +
          DateFormat.Hm().format(endDate);

      if (!mapHours.containsKey(totalHour)) {
        mapHours[totalHour] = event.numClients!;
      }
      else {
        mapHours.update(
            totalHour, (value) => value + event.numClients!);
      }
    }

      mapHours.forEach((key, value) {
        if(value>maxHour) {
          maxHour = value;
          timeOffered = key;
        }
      });


      mapHours.forEach((k, v)
          {
            print(maxHour);
            print(v);
            if(v == maxHour) {
              timeDemand.add(TimeDemand(k, v, AppColors.mainColor));
            }
            else {
              timeDemand.add(TimeDemand(k, v, AppColors.grey));
            }

          });

  }




  @override
  Widget build(BuildContext context) {
    return isLoading? LoadingView() :
      Align(
      alignment: Alignment.topLeft,
      child:   Center(
          child: Container(
              child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryYAxis: NumericAxis(
                    majorTickLines: MajorTickLines(
                      width: 0,
                    ),

                    //Hide the gridlines of x-axis
                      //majorGridLines: MajorGridLines(width: 0),
                    majorGridLines: MajorGridLines(
                        dashArray: <double>[5,5]
                    ),
                    minorGridLines: MinorGridLines(
                        dashArray: <double>[5,5]
                    ),
                    isVisible: true,
                    //Hide the axis line of x-axis
                    axisLine: AxisLine(width: 0),
                    borderWidth: 0,

                  ),
                  primaryXAxis: CategoryAxis(
                    majorTickLines: MajorTickLines(
                      width: 0,
                    ),
                    labelStyle: (Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor, fontSize: 12))!
                    ,
                    labelRotation: 90,
                    placeLabelsNearAxisLine: true,
                    //maximum: double.parse(maxNumber.toString()),
                    //isVisible: false,
                    //Hide the gridlines of x-axis
                    majorGridLines: MajorGridLines(width: 0),
                    //Hide the axis line of x-axis
                    axisLine: AxisLine(width: 0),
                  ),
                  series: <ChartSeries<TimeDemand, String>>[
                    ColumnSeries<TimeDemand, String>(
                        dataSource: timeDemand,
                        xValueMapper: (TimeDemand data, _) => data.time,
                        yValueMapper: (TimeDemand data, _) => data.demand,
                        pointColorMapper: (TimeDemand data, _) => data.color,
                        // Sets the corner radius
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    )
                  ]
              )
          )
      ));

  }

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

}

class TimeDemand {
  TimeDemand(this.time, this.demand, this.color);
  final String time;
  final int demand;
  final Color? color;
}
