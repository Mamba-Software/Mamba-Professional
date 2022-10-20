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

  String timeOffered = '';



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
    mapHours.clear();
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
  {print('dsaf');
    String hourMinuteIni = '';
    String hourMinuteEnd = '';
    String totalHour = '';
    double hourMinuteEndVal = 0;
    int maxHour=0;
    int hoursFinal, minutesFinal = 0;
    String minute = '';
    String hour = '';
    DateTime dt = DateTime.now();
    for(int i = 0; i < filteredEvents.length; ++i) {
      print('dsaf');
      if(filteredEvents[i].minute! == '0')
      {
        minute = '00';
      }
      else minute = filteredEvents[i].minute!;

      if(filteredEvents[i].hour!.length == 1)
      {
        hour = '0' + filteredEvents[i].hour!;
      }
      else {
        hour = filteredEvents[i].hour!;
      }

      hourMinuteIni = hour + ':' + minute;

      /*

      if(filteredEvents[i].duration! < 1)
        {
          hoursFinal = 0;
        }
      else {
        hoursFinal = filteredEvents[i].duration!.toInt();
      }*/
      print('dsaf');
      //minutesFinal = int.parse(((filteredEvents[i].duration! - hoursFinal) * 100).toString());
      //dt = filteredEvents[i].doneAt!.toDate().add( Duration(hours: hoursFinal, minutes: minutesFinal));

      hourMinuteEndVal = roundDouble((double.parse(filteredEvents[i].hour!) + ((double.parse(filteredEvents[i].minute!)) * 0.01)) + filteredEvents[i].duration!,3);

      hourMinuteEnd = hourMinuteEndVal.toString();
      print(hourMinuteEndVal);
      print(hourMinuteEndVal.toString());

      if(hourMinuteEnd.length < 5)
        {
          hourMinuteEnd = '0' + hourMinuteEnd;
        }

      hourMinuteEnd = hourMinuteEnd.replaceFirst('.', ':');

      totalHour = hourMinuteIni + ' - ' + hourMinuteEnd;

      if (!mapHours.containsKey(totalHour)) {
        mapHours[totalHour] = filteredEvents[i].numClients!;
      }
      else {
        mapHours.update(
            totalHour, (value) => value + filteredEvents[i].numClients!);
      }
    }
    print(mapHours);
    mapHours.forEach((key, value) {
      if(value>maxHour) {
        maxHour = value;
        timeOffered = key;
      }
    });
  }




  @override
  Widget build(BuildContext context) {
    return isLoading? LoadingView() :
      Align(
      alignment: Alignment.topLeft,
      child:  Text(
        timeOffered,
        style: Theme.of(context).textTheme.headline4?.copyWith(color: AppColors.mainColor, fontSize: 60),
      ),);

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
