import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/CalendarView/Events/ViewEventTrainer.dart';
import 'package:shimmer/shimmer.dart';

class EventListTile extends StatefulWidget {
  String eventId;
  bool isTrainer;
  var height;
  var width;

  EventListTile({Key? key, required this.eventId, required this.isTrainer, required this.height, required this.width}) : super(key: key);

  @override
  _EventListTileState createState() => _EventListTileState();
}

class _EventListTileState extends State<EventListTile> {
  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  var _eventDataService = new EventDataService();
  var _brandDataService = new BrandDataService();
  var _locationDataService = new LocationDataService();
  // Brand
  Event _event = Event();
  Brand _brand = Brand();
  Location _location = Location();
  // Event Date
  var eventDate;
  var eventDateString;
  var eventHourString;


  @override
  void initState() {
    isLoading = true;
    initEventTile();
    super.initState();
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
      CupertinoPageRoute<Null>(
        builder: (context) => EventPage(
          eventId: widget.eventId,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Container(
          height: widget.height*0.18,
          width: widget.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: widget.width*0.20,
                width: widget.width*0.20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: widget.width*0.20,
                      width: widget.width*0.20,
                      decoration: new BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    height: widget.height*18,
                    width: widget.width*0.56,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: widget.height*0.03,
                          width: widget.width*0.20,
                          decoration: new BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        SizedBox(height: widget.height*0.02,),
                        Container(
                          height: widget.height*0.02,
                          width: widget.width*0.35,
                          decoration: new BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        SizedBox(height: widget.height*0.015,),
                        Container(
                          height: widget.height*0.02,
                          width: widget.width*0.5,
                          decoration: new BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        SizedBox(height: widget.height*0.015,),
                        Container(
                          height: widget.height*0.02,
                          width: widget.width*0.5,
                          decoration: new BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        SizedBox(height: widget.height*0.015,),
                        Container(
                          height: widget.height*0.02,
                          width: widget.width*0.5,
                          decoration: new BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    height: widget.height*15,
                    width: widget.width*0.12,
                    child: Center(
                      child: Container(
                        height: widget.height*0.05,
                        width: widget.height*0.05,
                        decoration: new BoxDecoration(
                          color: AppColors.grey,
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
          child: Container(
            width: widget.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: widget.width*0.20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RectangularImage(
                        image: _brand.logoUrl!,
                        size: widget.width*0.2,
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
                    FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Container(
                        width: widget.width*0.12,
                        child: Center(
                          child: Icon(Icons.poll_outlined, color: AppColors.grey, size: widget.width*0.08,),
                        ),
                      ),
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