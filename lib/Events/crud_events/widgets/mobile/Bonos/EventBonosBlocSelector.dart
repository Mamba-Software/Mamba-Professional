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
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Bonos/EventBonosWidget.dart';

Event event = Event();

class EventBonosBlocSelector extends StatelessWidget {
  const EventBonosBlocSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, Map<Bono, bool>>(
        selector: (state) {
      Map<Bono, bool> newEventBonos = Map.from(state.newEvent.eventBonos!);
      return newEventBonos;
    }, builder: (context, eventBonosMap) {
      return eventBonosWidget(context, eventBonosMap);
    });
  }
}
