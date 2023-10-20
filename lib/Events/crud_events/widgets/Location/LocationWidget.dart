import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/DividerAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LocationAutoComplete/MyLocationsSelect.dart';

import '../../../../Data/Models/Location.dart';

class LocationWidget extends StatefulWidget {
  final Location location;

  LocationWidget({required this.location});

  @override
  _LocationWidgetState createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  bool isLoading = false;
  Location location = Location();
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    location = widget.location;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.028,
              bottom: MediaQuery.of(context).size.height * 0.028),
          child: GestureDetector(
            onTap: () async {
              var result = await Navigator.push(
                  context,
                  CupertinoPageRoute<String>(
                    builder: (context) => MyLocationsSelect(
                      brandId: currentBrand.id!,
                    ),
                  ));
              if (result != null) {
                context
                    .read<CrudEventCubit>()
                    .editEventInfo(result, EditEventType.location);
              }
            },
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.height * 0.1,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: location.initialPosition,
                          scrollGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          rotateGesturesEnabled: false,
                          mapToolbarEnabled: false,
                          zoomControlsEnabled: false,
                          minMaxZoomPreference:
                              const MinMaxZoomPreference(16, 16),
                          myLocationButtonEnabled: false,
                          mapType: MapType.satellite,
                          markers: location.markers!,
                          trafficEnabled: false,
                          indoorViewEnabled: false,
                          buildingsEnabled: false,
                          onTap: null,
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.description!,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          location.isBaseLocation!
                              ? Text(
                                  AppLocalizations.of(context)!.baseLocation,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      ?.copyWith(height: 1.5),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Icon(Icons.swap_horiz,
                        color: Theme.of(context).primaryColor,
                        size: MediaQuery.of(context).size.width * 0.08),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ),
        dividerAddEditEvent(context, AppLocalizations.of(context)!.location)
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
      setState(() {
        mapController = controller;
      });
    }
  }
}
