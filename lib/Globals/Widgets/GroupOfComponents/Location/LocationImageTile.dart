import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shimmer/shimmer.dart';

class LocationImageTile extends StatefulWidget {
  String locationId;
  String brandId;
  var height;
  var width;

  LocationImageTile({Key? key, required this.brandId, required this.locationId, required this.height, required this.width}) : super(key: key);

  @override
  _LocationImageTileState createState() => _LocationImageTileState();
}

class _LocationImageTileState extends State<LocationImageTile> {
  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  final _locationDataService = LocationDataService();
  // Location
  Location location = Location();
  double locationPercentatgeEvents = 0;
  Set<Marker> markers = <Marker>{};
  CameraPosition? _initialPosition;
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();
  Map<String, double> dataMap = {
    "1": 1,
  };

  @override
  void initState() {
    isLoading = true;
    initLocationTile();
    super.initState();
  }

  Future<void> initLocationTile() async {
    await getLocationDetails();
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onLaunchCoordinates() {
    MapsLauncher.launchCoordinates(location.latitude!, location.longitude!, location.description!);
  }

  Future<void> getLocationDetails() async {
    location = await _locationDataService.getSingleLocation(widget.locationId);
    locationPercentatgeEvents = await _locationDataService.getLocationPercentatgeEvents(widget.brandId, widget.locationId);
    print(locationPercentatgeEvents);
    dataMap = {
      "1": locationPercentatgeEvents,
    };
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Shimmer.fromColors(
        baseColor: Theme.of(context).backgroundColor,
        highlightColor: AppColors.grey.withOpacity(0.3),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      )
        :
      Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            border: Border.all(color: Theme.of(context).primaryColor, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(15.0))
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: widget.height,
              width: widget.width*0.69,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Container(
                  width: widget.width*0.69,
                  constraints: BoxConstraints(
                      minHeight: widget.height*0.15
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          location.description!,
                          style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center
                      ),
                      location.isBaseLocation! ? Column(
                        children: [
                          SizedBox(height: widget.height*0.07,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_filled, color: Theme.of(context).colorScheme.secondary, size: MediaQuery.of(context).size.width*0.035,),
                              SizedBox(width: widget.width*0.02,),
                              Text(
                                  AppLocalizations.of(context)!.baseLocation,
                                  style: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center
                              ),
                            ],
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: widget.height*0.05,),
                      SizedBox(
                        height: widget.height*0.35,
                        width: widget.width*0.7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: widget.height*0.4,
                              child: PieChart(
                              legendOptions: const LegendOptions(showLegends: false),
                              dataMap: dataMap,
                              chartType: ChartType.disc,
                              baseChartColor: Theme.of(context).backgroundColor,
                              colorList: const <Color>[
                                AppColors.grey
                              ],
                              chartValuesOptions: const ChartValuesOptions(
                                showChartValues: false,
                                showChartValuesInPercentage: true,
                                decimalPlaces: 0
                              ),
                              totalValue: 100,
                            ),
                            ),
                            SizedBox(
                              width: widget.width*0.3,
                              child: Text(
                                AppLocalizations.of(context)!.percentageEvents(locationPercentatgeEvents.toStringAsFixed(0)),
                                style: Theme.of(context).textTheme.caption,
                                textAlign: TextAlign.center
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: widget.height,
              width: widget.width*0.3,
              child: IconButton(
                onPressed: _onLaunchCoordinates,
                icon: Icon(
                  Icons.directions,
                  size: widget.width*0.2,
                  color: Colors.blue,
                ),
              )
            ),
            /*
            Positioned(
              left: 5.0,
              bottom: 5.0,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).scaffoldBackgroundColor
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        location.description!,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    )
                  ],
                ),
              ),
            ),
             */
          ],
        ),
    );
  }
}