import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/data/Models/Brand.dart';
import 'package:mamba_castelldefels/events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import '../../../../../commons/constants/constants.dart';

class TimeOffer extends StatefulWidget {
  List<Event> events;

  TimeOffer({
    required this.events,
    super.key,
  });

  @override
  TimeOfferState createState() => TimeOfferState();
}

class TimeOfferState extends State<TimeOffer> {
  bool isLoading = true;

  // Models i base de Dades
  Brand brand = Brand();
  List<Event> filteredEvents = [];

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

  void orderEvents() {
    return filteredEvents.sort((a, b) {
      //sorting in ascending order
      return a.doneAt!.compareTo(b.doneAt!);
    });
  }

  void mountStat() {
    String hourMinute = '';
    int maxHour = 0;
    String minute = '';
    String hour = '';
    for (int i = 0; i < filteredEvents.length; ++i) {
      if (filteredEvents[i].minute! == '0') {
        minute = '00';
      } else {
        minute = filteredEvents[i].minute!;
      }

      if (filteredEvents[i].hour!.length == 1) {
        hour = '0${filteredEvents[i].hour!}';
      } else {
        hour = filteredEvents[i].hour!;
      }

      hourMinute = '$hour:$minute';
      if (!mapHours.containsKey(hourMinute)) {
        mapHours[hourMinute] = filteredEvents[i].numClients!;
      } else {
        mapHours.update(
            hourMinute, (value) => value + filteredEvents[i].numClients!);
      }
    }
    //print(mapHours);
    mapHours.forEach((key, value) {
      if (value > maxHour) {
        maxHour = value;
        timeOffered = key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingView()
        : Stack(
            alignment: Alignment.center,
            children: [
              filteredEvents.isEmpty || timeOffered == ''
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: Image.asset(Constants.emptyCalendar)),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005),
                        Text(
                          AppLocalizations.of(context)!.noData,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                      ],
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    timeOffered,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: AppColors.mainColor, fontSize: 60),
                  ),
                ),
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
