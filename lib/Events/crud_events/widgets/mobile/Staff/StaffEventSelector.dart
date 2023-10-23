import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateTimeEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DurationEvent/DurationEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/Staff/staffEventWidget.dart';

Event event = Event();

Widget staffEventSelector() {
  return BlocSelector<CrudEventCubit, CrudEventState, List<Usuario>>(
      selector: (state) {
    if (state is CrudEventLoaded) {
      return state.newEvent.selectedTrainers;
    }
    return [];
  }, builder: (context, brandTrainersSelected) {
    return Column(
      children: [
        staffEventWidget(context, brandTrainersSelected),
      ],
    );
  });
}
