import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/events/crud_events/widgets/mobile/DividerAddEditEvent.dart';
import 'package:mamba_castelldefels/events/crud_events/widgets/mobile/MaxClients/MaxClientEventWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Event event = Event();

class MaxClientsEventSelector extends StatelessWidget {
  const MaxClientsEventSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CrudEventCubit, CrudEventLoaded, int>(
        selector: (state) {
      if (state.newEvent.maxMembers != null) {
        return state.newEvent.maxMembers!;
      }
      return 1;
    }, builder: (context, maxMembers) {
      return Column(
        children: [
          titleEventWidget(
              context, AppLocalizations.of(context)!.maxNumberClients),
          MaxClientEventWidget(maxMembers: maxMembers),
        ],
      );
    });
  }
}
