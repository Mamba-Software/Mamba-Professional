
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateEvent/DateEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DateEvent/TimeEventWidget.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/mobile/DateTime/DurationEvent/DurationEventSelector.dart';

class DateEventSelector extends StatelessWidget {
  final Locale locale;
  const DateEventSelector({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, DateTime>(
        selector: (state) {
      return state.newEvent.startDate!;
    }, builder: (context, startDate) {
      return Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
        child: Column(
          children: [
            dateEventWidget(context, startDate,
                context.read<CrudEventCubit>().state.isBeforeEdit, locale),
            timeEventWidget(context, startDate,
                context.read<CrudEventCubit>().state.isBeforeEdit, locale),
            DurationEventSelector(
              locale: locale,
            ),
          ],
        ),
      );
    });
  }
}
