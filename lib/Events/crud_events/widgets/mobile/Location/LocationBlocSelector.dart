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
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Location/LocationLoading.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Location/LocationWidget.dart';

Set<Marker> markers = <Marker>{};
CameraPosition _initialPosition =
    const CameraPosition(target: LatLng(26.8206, 30.8025));
GoogleMapController? mapController;
final Completer<GoogleMapController> _controller = Completer();
Location location = Location();
Event event = Event();

Widget locationBlocSelector() {
  return BlocSelector<CrudEventCubit, CrudEventState, Location>(
      selector: (state) {
    if (state is CrudEventLoaded) {
      location = state.newEvent.location;
      return location;
    }
    return Location();
  }, builder: (context, locationCubit) {
    if (locationCubit.id == null) {
      return locationLoading(context);
    }
    return LocationWidget(
      location: locationCubit,
    );
  });
}
