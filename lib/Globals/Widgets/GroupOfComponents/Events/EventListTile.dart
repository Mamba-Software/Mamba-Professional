import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:shimmer/shimmer.dart';

class EventListTile extends StatefulWidget {
  String eventId;
  var height;
  var width;

  EventListTile({Key? key, required this.eventId, required this.height, required this.width,}) : super(key: key);

  @override
  _EventListTileState createState() => _EventListTileState();
}

class _EventListTileState extends State<EventListTile> {
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
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


  @override
  void initState() {
    super.initState();
    isLoading = true;
    initEventTile();
  }

  Future<void> initEventTile() async {
    await getEventDetails();
    await getBrandDetails();
    await getLocationDetails();
    setState(() {
      isLoading = false;
    });
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
  }

  Future<void> getBrandDetails() async {
    _brand = await _brandDataService.getBrandDetails(_event.brandID!);
  }

  Future<void> getLocationDetails() async {
    _location = await _locationDataService.getSingleLocation(_event.locationId!);
  }

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.white,
        child: Container(
          height: widget.height,
          width: widget.width,
          padding: EdgeInsets.symmetric(horizontal: widget.width*0.05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: widget.height*0.8,
                width: widget.width*0.20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: widget.height*0.8,
                      width: widget.width*0.20,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
              Container(
                height: widget.height,
                width: widget.width*0.65,
                decoration: new BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                      bottom: BorderSide(color: Theme.of(context).backgroundColor, width: 1)
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: widget.height*0.1,
                      width: widget.width*0.20,
                      color: Theme.of(context).backgroundColor,
                    ),
                    Container(
                      height: widget.height*0.1,
                      width: widget.width*0.20,
                      color: Theme.of(context).backgroundColor,
                    ),
                    Container(
                      height: widget.height*0.1,
                      width: widget.width*0.20,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )
        :
      Container(
        height: widget.height,
        width: widget.width,
        padding: EdgeInsets.symmetric(horizontal: widget.width*0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: widget.height*0.8,
              width: widget.width*0.20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RectangularImage(
                    image: _brand.logoUrl!,
                    size: widget.height*0.7,
                    borderRadius: 5,
                  ),
                ],
              ),
            ),
            Container(
              height: widget.height,
              width: widget.width*0.65,
              decoration: new BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                    bottom: BorderSide(color: Theme.of(context).backgroundColor, width: 1)
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                        _brand.name!,
                        style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center
                    ),
                  ),
                  Expanded(
                    child: Text(
                        _event.title!,
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.center
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.date_range_outlined, color: AppColors.grey, size: widget.height*0.13,),
                        Text(
                            toCapitalized(eventDateString),
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.center
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
