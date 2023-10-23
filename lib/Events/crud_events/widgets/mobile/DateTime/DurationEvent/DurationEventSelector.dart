import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateEvent/DateEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateEvent/TimeEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateTimeEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DurationEvent/DurationEventWidget.dart';

Event event = Event();

Widget durationEventSelector(BuildContext context) {
  return BlocSelector<CrudEventCubit, CrudEventState, double>(
      selector: (state) {
    if (state is CrudEventLoaded) {
      return state.newEvent.duration!;
    }
    return 1.00;
  }, builder: (context, duration) {
    return Column(
      children: [durationEventWidget(context, duration, isBeforeEdit)],
    );
  });
}
