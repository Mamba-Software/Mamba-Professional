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
import 'package:mamba_castelldefels/Events/crud_events/widgets/Location/LocationWidget.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shimmer/shimmer.dart';

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
    if (locationCubit.id == '') {
      return LoadingView(
        isSmall: true,
        hasLogo: false,
      );
    }
    return LocationWidget(
      location: locationCubit,
    );
  });
}
