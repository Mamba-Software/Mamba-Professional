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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../Constants.dart';
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

  int clientsInEvents = 0;




  @override
  void initState() {
    filteredEvents = widget.events;
    //orderEvents();
    mountStat();
    isLoading = false;
    super.initState();
  }

  @override
  void didUpdateWidget(TimeToTimeOffer oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredEvents = widget.events;
    clientsInEvents = 0;
    timeOffered = '';
    timeDemand = [];
    mapHours.clear();
    //orderEvents();
    mountStat();
  }

  void orderEvents()
  {
    return filteredEvents.sort((a, b){
      //print(a.doneAt);
      //print(int.parse(a.hour!));//sorting in ascending order
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
      else
        {
          return 0;
        }
      return 0;
    });
  }

  void mountStat() {

    int maxHour = 0;
    Event event;
    mapHours["08 \n - \n 10"] = 0;
    mapHours["10 \n - \n 12"] = 0;
    mapHours["12 \n - \n 14"] = 0;
    mapHours["14 \n - \n 16"] = 0;
    mapHours["16 \n - \n 18"] = 0;
    mapHours["18 \n - \n 20"] = 0;
    mapHours["20 \n - \n 22"] = 0;
    //mapHours["21 \n - \n 23"] = 0;

    for (int i = 0; i < filteredEvents.length; ++i) {
      event = filteredEvents[i];
      clientsInEvents = clientsInEvents + filteredEvents[i].numClients!;
      setHour(8,10,"08 \n - \n 10",event);
      setHour(10,12,"10 \n - \n 12",event);
      setHour(12,14,"12 \n - \n 14",event);
      setHour(14,16,"14 \n - \n 16",event);
      setHour(16,18,"16 \n - \n 18",event);
      setHour(18,20,"18 \n - \n 20",event);
      setHour(20,22,"20 \n - \n 22",event);
      //setHour(21,23,"21 \n - \n 23",event);
    }

    mapHours.forEach((key, value) {
      if(value>maxHour) {
        maxHour = value;
        timeOffered = key;
      }
    });


    mapHours.forEach((k, v)
    {
      if(v == maxHour) {
        timeDemand.add(TimeDemand(k, v, AppColors.mainColor));
      }
      else {
        timeDemand.add(TimeDemand(k, v, AppColors.grey));
      }

    });

  }

  setHour(int initHour, int endHour, String totalHour, Event event)
  {
    if(int.parse(event.hour!) >= initHour && int.parse(event.hour!) < endHour)
    {

      if (!mapHours.containsKey(totalHour)) {
        mapHours[totalHour] = event.numClients!;
      }
      else {
        mapHours.update(
            totalHour, (value) => value + event.numClients!);
      }
    }
  }

  void mountStatOld() {
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
     // print((DateFormat.Hm().format(startDate)));
     // print((DateFormat.Hm().format(startDate)));

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
    Stack(
      alignment: Alignment.center,
      children: [

        Padding(
          padding:
          EdgeInsets.only(left:  MediaQuery.of(context).size.width*0.01),
          child: Center(
              child: Container(
                  child: SfCartesianChart(
                      plotAreaBorderWidth: 0,

                      primaryYAxis: NumericAxis(
                        majorTickLines: MajorTickLines(
                          width: 0,
                        ),
                        labelStyle: TextStyle(color: Colors.transparent),
                        labelPosition: ChartDataLabelPosition.inside,

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
                        interval: 1,
                        majorTickLines: MajorTickLines(
                          width: 0,
                        ),
                        labelStyle: (Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor, fontSize: 12)),
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
          ),
        ),
        filteredEvents.isEmpty || clientsInEvents == 0? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width*0.15,
                child: Image.asset(Constants.emptyCalendar)
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.005),
            Text(AppLocalizations.of(context)!.noData, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
            SizedBox(height: MediaQuery.of(context).size.height*0.05),
          ],
        ) : Container(),
      ],
    );

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
