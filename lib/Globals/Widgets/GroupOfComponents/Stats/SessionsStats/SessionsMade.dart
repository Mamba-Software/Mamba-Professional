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

class SessionsMade extends StatefulWidget {
  List<Event> events;

  SessionsMade({
    required this.events,
    Key? key,
  }) : super(key: key);

  @override
  SessionsMadeState createState() => SessionsMadeState();
}

class SessionsMadeState extends State<SessionsMade> {
  bool isLoading = true;
  // Models i base de Dades
  Brand brand = Brand();
  List <Event> filteredEvents = [];
  ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(enableSelectionZooming: true);
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true, header: 'Día y número de entrenos');

  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  List<TotalEvents> totalEvents = [];
  final _brandDataService = BrandDataService();

  Timestamp tm = Timestamp.fromDate(DateTime.now().subtract(Duration(days: 5)));

  @override
  void initState() {
    filteredEvents = widget.events;
    orderEvents();
    mountStat();
    isLoading = false;
    super.initState();
  }

  @override
  void didUpdateWidget(SessionsMade oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredEvents = widget.events;
    totalEvents = [];
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
            print(totalEvent.events);
            print(totalEvent.day);
            totalEvents.add(totalEvent);
            sumEvents = 0;
          }
        else {
          sumEvents = sumEvents + 1;
        }

        time = time2;
      }
    print('he');
    print (totalEvents.length);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? LoadingView() :   Center(
            child: Container(
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    tooltipBehavior: _tooltipBehavior,
                  enableSideBySideSeriesPlacement: false,

                  series: <ChartSeries>[
                      // Renders line chart
                      SplineSeries<TotalEvents, String>(

                        markerSettings: MarkerSettings(
                            isVisible: true,
                            height:  5,
                            width:  5,
                            shape: DataMarkerType.circle,
                            color: Styles.mainColor),
                        width: 2,
                        color: Styles.mainColor,
                          dataSource: totalEvents,
                          xValueMapper: (TotalEvents events, _) => events.day,
                          yValueMapper: (TotalEvents events, _) => events.events,
                      )
                    ]
                )
            )
        );

  }

}

class TotalEvents {
  TotalEvents(this.day, this.events);
  final String day;
  final int events;
}
