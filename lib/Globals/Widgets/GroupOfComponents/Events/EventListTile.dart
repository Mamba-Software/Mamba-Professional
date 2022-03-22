import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline1.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/ShimmerLoading.dart';

class EventListTile extends StatefulWidget {
  Event event;
  var height;
  var width;

  EventListTile({Key? key, required this.event, required this.height, required this.width,}) : super(key: key);

  @override
  _EventListTileState createState() => _EventListTileState();
}

class _EventListTileState extends State<EventListTile> {
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  var _locationDataService = new LocationDataService();
  // Brand
  Brand _brand = Brand();
  Location _location = Location();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    initEventTile();
  }

  Future<void> initEventTile() async {
    await getBrandDetails();
    await getLocationDetails();
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> getBrandDetails() async {
    _brand = await _brandDataService.getBrandDetails(widget.event.brandID!);
  }

  Future<void> getLocationDetails() async {
    _location = await _locationDataService.getSingleLocation(widget.event.locationId!);
  }

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: isLoading,
      child: Container(
        height: widget.height,
        width: widget.width,
        padding: EdgeInsets.symmetric(horizontal: widget.width*0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isLoading ? Container(
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
            ) : Container(
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
            isLoading ? Container(
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
            ) : Container(
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
                  Text(
                      _brand.name!,
                      style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center
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
