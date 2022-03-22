import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  EventListTile({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventListTileState createState() => _EventListTileState();
}

class _EventListTileState extends State<EventListTile> {
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
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

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
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
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }
    return !isLoading ?
      Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.white,
        child: Container(
          height: safeAreaHeight*0.12,
          width: safeAreaWidth,
          padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: safeAreaHeight*0.10,
                width: safeAreaWidth*0.20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: safeAreaHeight*0.10,
                      width: safeAreaWidth*0.20,
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
                    height: safeAreaHeight*15,
                    width: safeAreaWidth*0.56,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: safeAreaHeight*0.03,
                          width: safeAreaWidth*0.20,
                          decoration: new BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        SizedBox(height: safeAreaHeight*0.01,),
                        Container(
                          height: safeAreaHeight*0.02,
                          width: safeAreaWidth*0.35,
                          decoration: new BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        SizedBox(height: safeAreaHeight*0.01,),
                        Container(
                          height: safeAreaHeight*0.02,
                          width: safeAreaWidth*0.5,
                          decoration: new BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        SizedBox(height: safeAreaHeight*0.01,),
                        Container(
                          height: safeAreaHeight*0.02,
                          width: safeAreaWidth*0.5,
                          decoration: new BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    height: safeAreaHeight*15,
                    width: safeAreaWidth*0.12,
                    child: Center(
                      child: Container(
                        height: safeAreaHeight*0.05,
                        width: safeAreaHeight*0.05,
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
      FittedBox(
        fit: BoxFit.fitHeight,
        child: Container(
          width: safeAreaWidth,
          padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: safeAreaWidth*0.20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RectangularImage(
                      image: _brand.logoUrl!,
                      size: safeAreaHeight*0.10,
                      borderRadius: 5,
                    ),
                  ],
                ),
              ),
              Container(
                width: safeAreaWidth*0.68,
                decoration: new BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  /*
                  border: Border(
                      bottom: BorderSide(color: Theme.of(context).backgroundColor, width: 1)
                  ),
                   */
                ),
                child: Row(
                  children: [
                    FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: safeAreaHeight*0.15
                        ),
                        width: safeAreaWidth*0.56,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _brand.name!,
                              style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center
                            ),
                            SizedBox(height: safeAreaHeight*0.01,),
                            Text(
                                _event.title!,
                                style: Theme.of(context).textTheme.caption,
                                textAlign: TextAlign.center
                            ),
                            SizedBox(height: safeAreaHeight*0.015,),
                            Row(
                              children: [
                                Icon(Icons.date_range_outlined, color: AppColors.grey, size: safeAreaWidth*0.05,),
                                SizedBox(width: safeAreaWidth*0.02),
                                Text(
                                    toCapitalized(eventDateString),
                                    style: Theme.of(context).textTheme.caption,
                                    textAlign: TextAlign.center
                                ),
                              ],
                            ),
                            SizedBox(height: safeAreaHeight*0.01,),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.grey, size: safeAreaWidth*0.05,),
                                SizedBox(width: safeAreaWidth*0.02),
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
                        width: safeAreaWidth*0.12,
                        child: Center(
                          child: Icon(Icons.poll_outlined, color: AppColors.grey, size: safeAreaWidth*0.08,),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}