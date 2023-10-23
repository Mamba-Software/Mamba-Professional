import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateEvent/DateEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateEvent/TimeEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateTimeEventWidget.dart';

Event event = Event();

Widget dateEventSelector(BuildContext context, Locale locale) {
  return BlocSelector<CrudEventCubit, CrudEventState, DateTime>(
      selector: (state) {
    if (state is CrudEventLoaded) {
      return state.newEvent.startDate;
    }
    return DateTime.now();
  }, builder: (context, startDate) {
    return Column(
      children: [
        dateEventWidget(context, startDate, isBeforeEdit, locale),
        timeEventWidget(context, startDate, isBeforeEdit, locale),
      ],
    );
  });
}
