import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Auth/utils/enumAuth.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/Bonos/EventBonosWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/Location/LocationLoading.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/Location/LocationWidget.dart';

Event event = Event();

Widget eventBonosBlocSelector() {
  return BlocSelector<CrudEventCubit, CrudEventState, Map<Bono, bool>>(
      selector: (state) {
    if (state is CrudEventLoaded) {
      return state.newEvent.eventBonos;
    }
    return {};
  }, builder: (context, eventBonosMap) {
    return eventBonosWidget(context, eventBonosMap);
  });
}
