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

class LocationBlocSelector extends StatelessWidget {
  const LocationBlocSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, Location>(
        selector: (state) {
      if (state.isLoaded) {
        return state.newEvent.location;
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
}
