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

class TimeOffer extends StatefulWidget {
  List<Event> events;

  TimeOffer({
    required this.events,
    Key? key,
  }) : super(key: key);

  @override
  TimeOfferState createState() => TimeOfferState();
}

class TimeOfferState extends State<TimeOffer> {
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
  void didUpdateWidget(TimeOffer oldWidget) {
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
  {
    String hourMinute = '';
    int maxHour=0;
    String minute = '';
    String hour = '';
    for(int i = 0; i < filteredEvents.length; ++i) {
      if(filteredEvents[i].minute! == '0')
      {
        minute = '00';
      }
      else minute = filteredEvents[i].minute!;

      if(filteredEvents[i].hour!.length == 1)
      {
        hour = '0' + filteredEvents[i].hour!;
      }
      else hour = filteredEvents[i].hour!;

      hourMinute = hour + ':' + minute;
      if (!mapHours.containsKey(hourMinute)) {
        mapHours[hourMinute] = filteredEvents[i].numClients!;
      }
      else {
        mapHours.update(
            hourMinute, (value) => value + filteredEvents[i].numClients!);
      }
    }
    //print(mapHours);
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
