import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:shimmer/shimmer.dart';

import 'EventFeedback.dart';

class EventListTile extends StatefulWidget {
  String eventId;
  bool showFeedback;
  bool? showAverage;
  var height;
  var width;

  EventListTile({Key? key, required this.eventId, required this.showFeedback, this.showAverage, required this.height, required this.width}) : super(key: key);

  @override
  _EventListTileState createState() => _EventListTileState();
}

class _EventListTileState extends State<EventListTile> with TickerProviderStateMixin {
  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  final _eventDataService = EventDataService();
  final _brandDataService = BrandDataService();
  final _locationDataService = LocationDataService();
  // Brand
  Event _event = Event();
  Brand _brand = Brand();
  Location _location = Location();
  // Event Date
  DateTime eventDate = DateTime.now();
  String eventDateString = "";
  String eventHourString = "";
  // Feedback Event
  bool canAnswerFeedback = true;
  double? eventFeedbackValue;
  // Animation
  AnimationController? motionController;
  Animation? motionAnimation;
  double size = 35;


  @override
  void initState() {
    isLoading = true;
    initEventTile();
    super.initState();
    motionController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
      lowerBound: 0.5,
    );

    motionAnimation = CurvedAnimation(
      parent: motionController!,
      curve: Curves.bounceInOut,
    );

    motionController!.forward();
    motionController!.addStatusListener((status) {
      setState(() {
        if (status == AnimationStatus.completed) {
          motionController!.reverse();
        } else if (status == AnimationStatus.dismissed) {
          motionController!.forward();
        }
      });
    });

    motionController!.addListener(() {
      setState(() {
        size = motionController!.value * 50;
      });
    });
    // motionController.repeat();
  }

  Future<void> initEventTile() async {
    await getEventDetails();
    await getBrandDetails();
    await getLocationDetails();
    if (mounted) {
      //await Future.delayed(const Duration(milliseconds: 2000));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getEventDetails() async {
    _event = await _eventDataService.getSingleEvent(widget.eventId);
    eventDate =  DateTime(
      int.parse(_event.year!),
      int.parse(_event.month!),
      int.parse(_event.day!),
      int.parse(_event.hour!),
      int.parse(_event.minute!),
    );
    eventDateString = DateFormat('EEEE dd/MM/yy', Localizations.localeOf(context).languageCode).format(eventDate);
    eventHourString = DateFormat('Hm', Localizations.localeOf(context).languageCode).format(eventDate);
    if (widget.showFeedback) {
      // Get Feedback you have been in this event
      eventFeedbackValue = await _eventDataService.getEventUserFeedback(_event.id!,currentUser.id!);
    } else {
      if (widget.showAverage != null && widget.showAverage!) {
        // Get Average Feedback of the Event
        eventFeedbackValue = await _eventDataService.getEventAverageUserFeedback(_event.id!);
      }
    }
  }

  Future<void> getBrandDetails() async {
    _brand = await _brandDataService.getBrandDetails(_event.brandID!);
  }

  Future<void> getLocationDetails() async {
    _location = await _locationDataService.getSingleLocation(_event.locationId!);
  }

  // Navigate to Event Screen
  void navigateToEventScreen() {
    Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => EventPage(
          eventId: widget.eventId,
        ),
      )
    );
  }

  // Navigate to Event Feedback Screen
  Future<void> navigateToFeedbackEventScreen() async {
    if (eventFeedbackValue == null) {
      var result = await Navigator.push(
          context,
          CupertinoPageRoute<double?>(
            builder: (context) =>
                EventFeedback(
                  eventId: widget.eventId,
                ),
          )
      );

      if (result != null) {
        setState(() {
          eventFeedbackValue = result;
        });
      }
    }
  }

  // Build EventFeedback Value
  Widget buildEventFeedbackWidget() {
    return eventFeedbackValue != null ?
      buildEventFeedbackIcon(eventFeedbackValue!)
        :
     widget.showAverage! == false ? buildAnswerFeedbackIcon() : Container();
  }

  // Build EventFeedback Value
  Widget buildAnswerFeedbackIcon() {
    var limitDateToAnswer = eventDate.add(const Duration(days: 7));
    if (DateTime.now().isBefore(limitDateToAnswer)) {
      return Icon(
        Icons.question_mark,
        color: AppColors.red,
        size: size,
      );
    } else {
      setState(() {
        canAnswerFeedback = false;
      });
      return Container();
    }
  }

  // Build EventFeedback Value
  Widget buildEventFeedbackIcon(double eventFeedbackValue) {
      return SizedBox(
        width: widget.width*0.1,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: widget.width*0.04,
                child: Image.asset(Constants.fireEmojiImage),
              ),
              Text(
                eventFeedbackValue.toString(),
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center
              ),
            ],
          ),
        ),
      );

  }

  @override
  void dispose() {
    motionController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: SizedBox(
          height: widget.height*0.18,
          width: widget.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: widget.width*0.20,
                width: widget.width*0.20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: widget.width*0.20,
                      width: widget.width*0.20,
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    height: widget.height*18,
                    width: widget.width*0.56,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: widget.height*0.03,
                          width: widget.width*0.20,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        SizedBox(height: widget.height*0.02,),
                        Container(
                          height: widget.height*0.02,
                          width: widget.width*0.35,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        SizedBox(height: widget.height*0.015,),
                        Container(
                          height: widget.height*0.02,
                          width: widget.width*0.5,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        SizedBox(height: widget.height*0.015,),
                        Container(
                          height: widget.height*0.02,
                          width: widget.width*0.5,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        SizedBox(height: widget.height*0.015,),
                        Container(
                          height: widget.height*0.02,
                          width: widget.width*0.5,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),

                      ],
                    ),
                  ),
                  widget.showFeedback ? SizedBox(
                    height: widget.height*15,
                    width: widget.width*0.12,
                    child: Center(
                      child: Container(
                        height: widget.height*0.05,
                        width: widget.height*0.05,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ) : SizedBox(
                    height: widget.height*15,
                    width: widget.width*0.12,
                    child: Center(
                      child: Container(
                        height: widget.height*0.05,
                        width: widget.height*0.05,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      )
        :
      GestureDetector(
        onTap: navigateToEventScreen,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: SizedBox(
            width: widget.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: widget.width*0.20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RectangularImage(
                        image: _event.imageUrl!,
                        height: widget.width*0.2,
                        width: widget.width*0.2,
                        borderRadius: 5,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Container(
                        width: widget.width*0.61,
                        constraints: BoxConstraints(
                            minHeight: widget.height*0.15
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                _brand.name!,
                                style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center
                            ),
                            SizedBox(height: widget.height*0.02,),
                            Text(
                                _event.title!,
                                style: Theme.of(context).textTheme.caption,
                                textAlign: TextAlign.center
                            ),
                            SizedBox(height: widget.height*0.015,),
                            Row(
                              children: [
                                Icon(Icons.date_range_outlined, color: AppColors.grey, size: widget.width*0.05,),
                                SizedBox(width: widget.width*0.02),
                                Text(
                                    StringUtils().toCapitalized(eventDateString),
                                    style: Theme.of(context).textTheme.caption,
                                    textAlign: TextAlign.center
                                ),
                              ],
                            ),
                            SizedBox(height: widget.height*0.02,),
                            Row(
                              children: [
                                Icon(Icons.schedule, color: AppColors.grey, size: widget.width*0.05,),
                                SizedBox(width: widget.width*0.02),
                                Text(
                                    StringUtils().toCapitalized(eventHourString),
                                    style: Theme.of(context).textTheme.caption,
                                    textAlign: TextAlign.center
                                ),
                              ],
                            ),
                            SizedBox(height: widget.height*0.015,),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.grey, size: widget.width*0.05,),
                                SizedBox(width: widget.width*0.02),
                                Expanded(
                                  child: Text(
                                      _location.description!,
                                      style: Theme.of(context).textTheme.caption,
                                      textAlign: TextAlign.left
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    widget.showFeedback ? GestureDetector(
                      onTap: canAnswerFeedback ? navigateToFeedbackEventScreen : null,
                      child: SizedBox(
                        width: widget.width*0.12,
                        child: Center(
                            child: buildEventFeedbackWidget()
                        ),
                      ),
                    ) : widget.showAverage != null && widget.showAverage! ? SizedBox(
                      width: widget.width*0.12,
                      child: Center(
                          child: buildEventFeedbackWidget()
                      ),
                    ) : SizedBox(
                        width: widget.width*0.12,
                        child: const Center()
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  }
}