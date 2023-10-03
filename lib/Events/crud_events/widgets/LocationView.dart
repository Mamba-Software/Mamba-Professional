import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Auth/utils/enumAuth.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shimmer/shimmer.dart';

Set<Marker> markers = <Marker>{};
CameraPosition _initialPosition = const CameraPosition(target: LatLng(26.8206, 30.8025));
GoogleMapController? mapController;
final Completer<GoogleMapController> _controller = Completer();
Location location = Location();
Event event = Event();

Widget LocationView(BuildContext context, bool editEvent, Event eventFunc) {

  return BlocSelector<CrudEventCubit, CrudEventState, Location>(
      selector: (state) {
        if(state is CrudEventLoaded) {
          print('state');
          location = state.location;
          event = eventFunc;
          initCameraPosition(location);
          createMarker(location);
          return location;
        }
        return Location();
      },
      builder: (context, locationCubit) {
        if(editEvent) {
          if(locationCubit.id == '' || locationCubit.isBaseLocation == null) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: MediaQuery.of(context).size.height*0.13,
                      width: MediaQuery.of(context).size.width*0.9,
                      decoration: const BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(15.0))
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          else {
            return Container();
          }
        }
        else {
          if (locationCubit.id == '') {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery
                  .of(context)
                  .size
                  .width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.02),
                  Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.13,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.9,
                      decoration: const BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(15.0))
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.01),
                Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.13,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.9,
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .backgroundColor,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(15.0))
                  ),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
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
                              initialCameraPosition: _initialPosition,
                              scrollGesturesEnabled: false,
                              zoomGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                              mapToolbarEnabled: false,
                              zoomControlsEnabled: false,
                              minMaxZoomPreference: const MinMaxZoomPreference(
                                  17, 17),
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
                              color: Theme
                                  .of(context)
                                  .scaffoldBackgroundColor
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .secondary,
                                size: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  locationCubit.description!,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyText2,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        }
      }
  );
}

void initCameraPosition( Location location) {
  _initialPosition = CameraPosition(target: LatLng(location.latitude!,location.longitude!));
}

void createMarker(Location location) async{
  Marker marker = Marker(
    markerId: const MarkerId('1'),
    position: LatLng(location.latitude!,location.longitude!),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    onTap: () {},
  );
  markers.add(marker);
}

void _onLaunchCoordinates(latLng) {
  mixpanel!.track('event_view_location_tap', properties: {'isPrivate': event.isPrivate!});
  MapsLauncher.launchCoordinates(location.latitude!, location.longitude!, location.description!);
}


void _onMapCreated(GoogleMapController controller) {
  //context.update
  if (!_controller.isCompleted) {
    _controller.complete(controller);
    mapController = controller;
  }
}
