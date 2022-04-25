import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/Data/DataService/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shimmer/shimmer.dart';

class LocationImageTile extends StatefulWidget {
  String locationId;
  var height;
  var width;

  LocationImageTile({Key? key, required this.locationId, required this.height, required this.width}) : super(key: key);

  @override
  _LocationImageTileState createState() => _LocationImageTileState();
}

class _LocationImageTileState extends State<LocationImageTile> {
  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  var _locationDataService = new LocationDataService();
  // Location
  Location location = Location();
  Set<Marker> markers = new Set<Marker>();
  CameraPosition? _initialPosition;
  GoogleMapController? mapController;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    isLoading = true;
    initLocationTile();
    super.initState();
  }

  Future<void> initLocationTile() async {
    await getLocationDetails();
    if (mounted) {
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        isLoading = false;
      });
    }
  }

  void initCameraPosition() {
    setState(() {
      _initialPosition = CameraPosition(target: LatLng(location.latitude!,location.longitude!));
    });
  }

  void createMarker() async{
    Marker marker = new Marker(
      markerId: MarkerId('1'),
      position: LatLng(location.latitude!,location.longitude!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {},
    );
    setState(() {
      markers.add(marker);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    setState(() {
      mapController = controller;
    });
  }

  void _onLaunchCoordinates(LatLng) {
    MapsLauncher.launchCoordinates(location.latitude!, location.longitude!, location.description!);
  }

  Future<void> getLocationDetails() async {
    location = await _locationDataService.getSingleLocation(widget.locationId);
    initCameraPosition();
    createMarker();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Shimmer.fromColors(
        baseColor: AppColors.grey,
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: new BoxDecoration(
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
            border: Border.all(color: Theme.of(context).accentColor, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  heightFactor: 1,
                  widthFactor: 2.5,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: _initialPosition!,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                    minMaxZoomPreference: MinMaxZoomPreference(17,17),
                    myLocationButtonEnabled: false,
                    markers: markers,
                    mapType: MapType.hybrid,
                    onTap: _onLaunchCoordinates,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 5.0,
              bottom: 5.0,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).scaffoldBackgroundColor
                ),
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).accentColor,
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
          ],
        ),
    );
  }
}