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
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DurationEventSelector extends StatelessWidget {
  final Locale locale;
  const DurationEventSelector({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    bool isBeforeEdit = false;
    return BlocSelector<CrudEventCubit, CrudEventLoaded, double>(
        selector: (state) {
      return state.newEvent.duration!;
    }, builder: (context, duration) {
      bool validated = validateDateAndTime(
          context.read<CrudEventCubit>().state.newEvent.startDate!,
          duration,
          context.read<CrudEventCubit>().state.isBeforeEdit);
      isBeforeEdit = context.read<CrudEventCubit>().state.isBeforeEdit;
      return Column(
        children: [
          durationEventWidget(context, duration,
              context.read<CrudEventCubit>().state.isBeforeEdit),
          !validated
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 25, right: 25, top: 10.0),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.errorDate,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.copyWith(color: AppColors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Container(),
          !isBeforeEdit
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 25, right: 25, top: 10.0),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.cantEditText,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.copyWith(color: AppColors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Container(),
          dividerAddEditEvent(
              context, AppLocalizations.of(context)!.selectDayTime, validated),
        ],
      );
    });
  }
}

bool validateDateAndTime(
    DateTime startTime, double duration, bool _isBeforeEdit) {
  if (!_isBeforeEdit) {
    return true;
  }
  // Calculating the Time to check
  var hour = duration.toString().split(".")[0];
  var min = duration.toStringAsFixed(2).split(".")[1];
  var endTime =
      startTime.add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
  // Computing the workshift
  var workshift1 = currentBrand.workShift[0];
  var workshift2 = currentBrand.workShift[1];
  var startWorkHour = workshift1.toStringAsFixed(2).split(".")[0];
  var startWorkMin = workshift1.toStringAsFixed(2).split(".")[1];
  var endWorkHour = workshift2.toStringAsFixed(2).split(".")[0];
  var endWorkMin = workshift2.toStringAsFixed(2).split(".")[1];
  var startWorkDay = DateTime(startTime.year, startTime.month, startTime.day,
      int.parse(startWorkHour), int.parse(startWorkMin));
  var endWorkDay = DateTime(startTime.year, startTime.month, startTime.day,
      int.parse(endWorkHour), int.parse(endWorkMin));
  if ( // Can´t create event in the past
      startTime.isBefore(DateTime.now()) ||
          startTime.isAtSameMomentAs(DateTime.now()) ||
          endTime.isBefore(DateTime.now()) ||
          endTime.isAtSameMomentAs(DateTime.now())
          // Can´t create event outside of working hours
          ||
          startTime.isBefore(startWorkDay) ||
          endTime.isBefore(startWorkDay) ||
          startTime.isAfter(endWorkDay) ||
          endTime.isAfter(endWorkDay)) {
    return false;
  } else {
    /*
    // Can´t create event in break period of working hours
    for (var i = 2; i < currentBrand.workShift.length; i += 2) {
      // Breaks
      var break1 = currentBrand.workShift[i];
      var break2 = currentBrand.workShift[i + 1];
      // Take the minute and the hour
      var startBreakHour = break1.toStringAsFixed(2).split(".")[0];
      var startBreakMin = break1.toStringAsFixed(2).split(".")[1];
      var endBreakHour = break2.toStringAsFixed(2).split(".")[0];
      var endBreakMin = break2.toStringAsFixed(2).split(".")[1];
      // Date Time formatted
      var startBreak = DateTime(startTime.year, startTime.month, startTime.day,
          int.parse(startBreakHour), int.parse(startBreakMin));
      var endBreak = DateTime(startTime.year, startTime.month, startTime.day,
          int.parse(endBreakHour), int.parse(endBreakMin));
      // Condition check
      if (((startTime.isAfter(startBreak) ||
                  startTime.isAtSameMomentAs(startBreak)) &&
              (startTime.isBefore(endBreak))) ||
          ((endTime.isAfter(startBreak)) &&
              (endTime.isBefore(endBreak) ||
                  endTime.isAtSameMomentAs(endBreak)))) {
        return false;
      }
    }*/
    return true;
  }
}
