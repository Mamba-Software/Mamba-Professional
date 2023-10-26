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

class DurationEventSelector extends StatelessWidget {
  final Locale locale;
  const DurationEventSelector({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    bool isBeforeEdit = context.read<CrudEventCubit>().state.isBeforeEdit;
    return BlocSelector<CrudEventCubit, CrudEventLoaded, double>(
        selector: (state) {
      if (state.isLoaded) {
        return state.newEvent.duration!;
      }
      return 1.00;
    }, builder: (context, duration) {
      return Column(
        children: [durationEventWidget(context, duration, isBeforeEdit)],
      );
    });
  }
}
